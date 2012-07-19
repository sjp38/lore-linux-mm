Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id EA6256B0044
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:16:53 -0400 (EDT)
Date: Thu, 19 Jul 2012 15:16:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm: hugetlbfs: Close race during teardown of
 hugetlbfs shared page tables
Message-ID: <20120719141644.GW9222@suse.de>
References: <20120718104220.GR9222@suse.de>
 <alpine.LSU.2.00.1207190457380.4949@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207190457380.4949@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 19, 2012 at 05:38:03AM -0700, Hugh Dickins wrote:
> On Wed, 18 Jul 2012, Mel Gorman wrote:
> 
> > (Sending as RFC as this one is tricky and as it is timing dependent the
> > patch may accidentally be papering over a more fundamental problem. Even
> > if it is not, it may be more heavy handed than necessary but am suffering
> > from tunnel vision from looking at this. I wanted to get comments on this
> > version before trying to be clever.)
> 
> I haven't been able to spend as long on this as I'd like, and can't
> look more today, nor probably tomorrow: premature reply and hope I'm
> getting it right.
> 

Any reply is good. Thanks for taking the time. Thanks as well for
correcting Ken Chen's email address as I had no idea where he was any
more :)

> The bug looks genuine to me: good job you both tracking it down.
> 

Cheers

> I am a bit surprised we didn't notice back when reviewing, it does
> seem exactly the kind of issue one would be on the lookout for;
> but I've not read through those old mails.
> 

I read through some of the old mails and there were a lot of revisions that
caught a wide variety of problems. It looked exhausting and I can see how
this one might have been missed.  Even when I had a test case demonstrating
the problem, it took me a long time to spot exactly where we might be racing.

> Your interim trylock fix looks just too worrying to me to spend any
> time considering it - and does it even work?

Yes - or at least the test case was able to run for 2 hours without
triggering the bug when normally it would trigger in under 3 minutes.

My concern with the trylock thing actually was that in theory it could
retry forever. If Peter happens to read this patch his "unbounded latency"
detector is going to tut at me. I wondered if it would be better to just
fail sharing in the contended case but I expected that it would only need
to retry for a very short period of time for any real workload.

My main concern is that I might be papering over the problem and I have
the wrong race. One impact of this patch is that holding mmap_sem of the
remote process prevents shmdt running in parallel as it takes mmap_sem
for write so the fix may be coincidental even if it is effective.


> given that an exiting mm
> does not take mmap_sem, where munmap would have down_write mmap_sem.
> 
> As I understand it, there would be no problem at all if the entry (and
> here I'm rushed and avoid making a fool of myself by not saying whether
> I mean pmd entry or pud entry! I get so confused amongst the levels)

I'll take the risk for you: you almost certainly mean clearing the PUD entry.

> were cleared under lock in or near the huge_pmd_unshare(), but it's
> left set so that the subsequent free_pgtables() gets the freeing via
> TLB mmu_gather right.
> 
> I'd feel much happier with a fix approaching it from that direction:
> which is probably just what you have in mind when you're thinking
> of trying to be clever - please advance to that.
> 

I'm relieved that you thought along these lines as well. I also considered
the possibility of clearing the PUD entry on unsharing and doing the freeing
there. I abandoned the approach early on  because I concluded there would
be a few problems with it.

1. When sharing, it is obvious if there are other users of the shared
   page table - elevated page count on the PTE. For the last user of the
   shared page table, it is not known if we shared in the past. In itself
   this is not a major problem but it does mean that huge_pmd_unshare
   would always have to tear down page tables below the PUD level

2. It means duplicating some logic of free_pgtables() and moving it into
   arch-specific code or into mm/hugetlb.c. I did not want to move any
   details related to mmu_gather into a rarely used path

3. Pagetable teardown and free of hugetlbfs pages on x86 would be
   different to every other arch. x86 and hugetlbfs is already different
   to other architectures but I did not want to compound this problem more
   than necessary

4. If I'm right about the race conditions then a parallel process running
   free_pgtables() could conceivably be operating on the same area at the
   same time because it is holding the wrong mm->page_table_lock. They
   are both freeing so may not be a problem but it felt wrong.

5. In general, I felt this would be significantly more complex than my
   heavy-handed approach unless I missed an obvious way of implementing
   it which is always possible :)

> If nothing but x86 uses sharing at this level (again I've not checked)

AFAIK, only x86 shares like this.

> then you may be able to clear the entry and put the page directly into
> into the mmu_gather like an ordinary page, leaving nothing for
> free_pgtables() to do there.  Ah, that might leave a danger that the
> table above never gets freed. 

It's a risk albeit it a small one.

> Well, another possibility is to use a
> special pte bit (perhaps the one we play with for PROT_NONE, or a THP
> bit) to flag this: to prevent more sharing but get the freeing right.
> 

I think it would have to be a VMA flag because that's what
page_table_shareable() is using. I don't think I can use a new VMA flag
for a user case like pagetable sharing but I could use an "impossible"
flag.

> Anyway, over to you: just a couple of further comments below.
> 

I'm not keen on the idea of doing the page table teardown and free on or
near huge_pmd_unshare because I think it'll be more complex. Abusing VMA
flags might work but there is a problem that the VMA flag might "leak".
If we are truncating for example, we call unmap_hugepage_range and if
that thing sets a VMA flag it might persist to trip on some BUG check
later or introduce weird race conditions depending on what flag was
abused (e.g. abusing VM_GROWSDOWN might introduce a weird race with
fault)

I could set the impossible flag in unmap_vmas() but then it is moving a
hack necessary for arch-specific code to the core MM. Would that be ok
or is it just ugly?


> > <SNIP>
> > The test case was mostly written by Michal Hocko with a few minor changes
> > by me to reproduce this bug. Michal did a lot of heavy lifting eliminating
> > possible sources of the race and saved me the embarrassment of posting a
> > completely broken patch yesterday. He did not see this patch before
> > going to the lists so any flaws are mine!
> 
> Well, I think you're being grossly unfair to Michal there:
> you're saying that he only has to look at a patch to put flaws in it ?-)
> 

See, this is exactly the sort of mistake I am responsible for :)

> > 
> > The basic problem is a race between page table sharing and teardown. For
> > the most part page table sharing depends on i_mmap_mutex. In some cases,
> > it is also taking the mm->page_table_lock for the PTE updates but with
> > shared page tables, it is the i_mmap_mutex that is more important.
> > 
> > Unfortunately it appears to be also insufficient. Consider the following
> > situation
> > 
> > Process A					Process B
> > ---------					---------
> > hugetlb_fault					shmdt
> >   huge_pte_alloc				LockWrite(mmap_sem)
> >     Lock(i_mmap_mutex)				  do_munmap
> 
> You meant to erase the huge_pte_alloc and Lock(i_mmap_mutex)
> above, didn't you?  They're repeated in the right place below.
> 

Yes, I was cut&pasting a bit here. 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
