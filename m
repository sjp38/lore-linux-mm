Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8B3C56B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 16:00:01 -0400 (EDT)
Date: Wed, 11 Mar 2009 20:59:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311195935.GO27823@random.random>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 12:01:56PM -0700, Linus Torvalds wrote:
> Btw, I think your patch has a race. Admittedly a really small one.
> 
> When you look up the page in gup.c, and then set the GUP flag on the 
> "struct page", in between the lookup and the setting of the flag, another 
> thread can come in and do that same fork+write thing.
> 
> 	CPU0:			CPU1
> 
> 	gup:			fork:
> 	 - look up page
> 	 - it's read-write
> 	...
> 				set_wr_protect
> 				test GUP bit - not set, good
> 				done
> 
> 	- Mark it GUP
> 				tlb_flush
> 
> 				write to it from user space - COW

Did you notice the check after 'mark it gup' that will run in CPU0?

+		if (PageAnon(page)) {
+			if (!PageGUP(page))
+				SetPageGUP(page);
+			smp_mb();
+			/*
+			 * Fork doesn't want to flush the smp-tlb for
+			 * every pte that it marks readonly but newly
+			 * created shared anon pages cannot have
+			 * direct-io going to them, so check if fork
+			 * made the page shared before we taken the
+			 * page pin.
+			 */
+			if ((pte_flags(gup_get_pte(ptep)) &
+			     (mask | _PAGE_SPECIAL)) != mask) {
+				put_page(page);
+				pte_unmap(ptep);
+				return 0;
+			}
+		}

gup-fast will _not_ succeed because of the set_wr_protect that just
happened on CPU1. That's why I added the above check after setpagegup/get_page.

> since there is no lockng on the GUP side (there's the TLB flush that will 
> wait for interrupts being enabled again on CPU0, but that's later in the 
> fork sequence).

Right, I preferred to 'recheck' the wrprotect bit before allowing
gup-fast to succeed to avoid sending a flood of IPI in the fork fast
path. So I leave the tlb flush at the end of the fork sequence and a
single IPI in the common case.

Only exception is the forcecow path where the copy has to happen
atomically per-page, so I have to flush the smp-tlb before the copy
after marking the parent wrprotected temporarly (later the parent pte
is marked read-write again by fork_pre_cow after the copy), or NPTL
will never have a chance to fix its bug as its glibc-parent data
structures that could be modified by threads won't be copied
atomically to the child. But that's a slow path so it's ok to flush
tlb there.

> Also, having to set the PG_GUP bit means that the "fast" gup is likely not 
> much faster than the slow one. It now has two atomics per page it looks 
> up, afaik, which sounds like it would delete any advantage it had over the 
> slow version that needed locking.

gup-fast has already to get_page, so I don't see it. gup-fast will
always dirty that cacheline and take over it regardless of PG_gup,
gup-fast will never be able to run without running
get_page. Furthermore starting from the second access GUP is already
set and it's only a read from l1 from a cacheline that was already
dirtied and taken over a few instructions before. So I think it can't
be slowing down gup-fast in any measurable way, given how close
mark-gup is set after get_page.

> What we _could_ try to do is to always make the COW breaking be a 
> _directed_ event - we'd make sure that we always break COW in the 
> direction of the first owner (going to the rmap chains). That might solve 
> everything, and be purely local to the logic in mm/memory.c (do_wp_page).

That's a really interesting idea and frankly I didn't think about it.
Probably one reason is that it can't work for ksm where we take two
random anon pages and create one out of them so each one could already
have O_DIRECT in progress on them and we've to prevent to merge pages
that have in-flight O_DIRECT to be merged no matter what (ordering is
irrelevant for ksm, page contents must be stable or ksm will
break). I was thinking of using the same logic for both ksm and fork.

But theoretically, ksm can keep doing the page_count check to truly
ensure no in-flight I/O is going on, and fork could fix it in whatever
way it wants (I wonder if it'd be ok for fork to map a 'changing' page
in the child because of the not-defined behavior of forking while a
read is in progress, at least at the first write the page would stop
changing contents). In fact ksm doesn't even require the above change
to gup-fast because it does ptep_clear_flush_notify when it tries to
wrprotect a not-shared anon page.

> I dunno. I have not looked at how horrible that would be.

For fork I think it would work, not sure if the current data
structures would be enough, but at first glance I think besides how
horrible that would be, I think from a practical standpoint the main
problem is the slowdown it'd generate in the do_wp_page fast path. The
anon_vma list can be huge in some weird case, which we normally cannot
care less as swap algorithms and disk I/O (even on no-seeking SSD) is
even slower than that. The coolness of rmap w/o pte_chains is that
rmap is zerocost for all page faults (a check on vma->anon_vma being
not null is the only cost) and I'd like to keep it that way.

The cost of my fix to fork is not measurable with fork microbenchmark,
while the cost of finding who owns the original shared page in
do_wp_page would be potentially be much bigger. The only slowdown to
fork is in the O_DIRECT slow path which we don't care about and in the
worst case is limited to the total amount of in-flight I/O.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
