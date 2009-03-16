Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EE8266B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:28:37 -0400 (EDT)
Date: Mon, 16 Mar 2009 19:28:14 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090316182814.GA20555@random.random>
References: <1237007189.25062.91.camel@pasglop> <200903170350.13665.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903160955490.3675@localhost.localdomain> <200903170419.38988.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161034030.3675@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903161034030.3675@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 10:42:48AM -0700, Linus Torvalds wrote:
> Maybe we could go back to also looking at page counts?

Hugh just recently reminded me why we switched to mapcount and
explanation is here: c475a8ab625d567eacf5e30ec35d6d8704558062
which wasn't entirely safe until this was added too:
ab967d86015a19777955370deebc8262d50fed63 which reliably allowed to
takeover swapcache pages taken by gup and at the same time it allowed
the VM to unmap ptes pointing to swapcache taken by GUP.

Yes it's possible to go back to page counts, then we have only to
reintroduce by 2.6.7 solution that will prevent the VM to unmap ptes
that are mapping pages take by GUP. Otherwise do_wp_page won't be able
to remap into the pte the same swapcache that was unmapped by the pte
by the VM leading to disk corruption with swapping (the 2.4 bug, fixed
in 2.4 with a simpler PG_lock local to direct-io, that prevented the
VM to unmap ptes on the page as long as I/O was in progress, and
PG_lock was released by the ->end_io async handler from irq IIRC).

The only problem I can see is if mapcount and page count can change
freely while PT lock and rmap locks are taken, comparing them won't be
as reliable as in ksm/fork (in my version of the fix) where we're
guaranteed mapcount is 1 and stays 1 as long as we hold PT lock,
because pte_write(pte) == true and PageAnon == true (I also added a
BUG_ON to check mapcount to be always 1 with the other two conditions
are true). That makes ksm/forkfix quite obviously safe in this regard.

But for the VM to decide not to unmap a pte taken by GUP, we also have
to deal with a mapcount > 1 and pte_write(pte) == false and PageAnon
== true. So if we solve that ordering issue between reading mapcount
and page count I don't see much of a problem to returning checking the
page count in the VM code to prevent the pte to be unmapped while page
is under GUP and then remove the mapcount-only check from do_wp_page
swapcache-reuse logic.

If we'd return using the page_count instead of mapcount, my first
patch I posted here would then not require any change to take care of
the 'reverse' race (modulo hugetlb) of the child writing to the pages
that are being written to disk by the parent, there would be no need
to de-cow in GUP (again modulo hugetlb).

> I really think we should be able to fix this without _anything_ like that 
> at all. Just the lock (and some reuse_swap_page() logic changes).

I don't see why we should introduce mm wide locks outside GUP
(worrying about the SetPageGUP in gup-fast when gup-fast would then
instead have to take a mm-wide lock sounds small issue) when we can be
page-granular and lockless. I agree it could be simpler and less
invasive into the gup details to add any logic outside of gup, but I
don't think the result will be superior, given it'll most certainly
become an havier-weight lock bouncing across all cpus calling
gup-fast, and it won't make a speed difference for the CPU to execute
an atomic lock op inner or outer of gup-fast. OTOH if the argument for
an outer mm wide lock is to keep the code simpler or more
maintainable, that would explain it. I think fixing it my way is not
more complicated than by fixing outside gup, but then I clearly may be
biased in what it looks simpler to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
