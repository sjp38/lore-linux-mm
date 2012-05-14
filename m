Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 0EB016B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 09:32:16 -0400 (EDT)
Date: Mon, 14 May 2012 14:32:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Allow migration of mlocked page?
Message-ID: <20120514133210.GE29102@suse.de>
References: <4FAC9786.9060200@kernel.org>
 <20120511131404.GQ11435@suse.de>
 <4FADA007.3020309@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FADA007.3020309@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>

On Fri, May 11, 2012 at 07:25:59PM -0400, KOSAKI Motohiro wrote:
> >>diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> >>index 3a93f73..8ae2e60 100644
> >>--- a/include/linux/highmem.h
> >>+++ b/include/linux/highmem.h
> >>@@ -175,7 +175,8 @@ static inline struct page *
> >>  alloc_zeroed_user_highpage_movable(struct vm_area_struct *vma,
> >>                                         unsigned long vaddr)
> >>  {
> >>-       return __alloc_zeroed_user_highpage(__GFP_MOVABLE, vma, vaddr);
> >>+       gfp_t gfp_flag = vma->vm_flags&  VM_LCOKED ? 0 : __GFP_MOVABLE;
> >>+       return __alloc_zeroed_user_highpage(gfp_flag, vma, vaddr);
> >>  }
> >>
> >>But it's a solution about newly allocated page on mlocked vma.
> >>Old pages in the VMA is still a problem.
> >
> >Yes.
> 
> I disagree. __GFP_MOVABLE is one of zone mask. therefore, To turn off __GFP_MOVABLE
> will break memory hotplug. mlock may easily invoke oom killer.
> 

Fair point.

> >>We can solve it at mlock system call through migrating the pages to
> >>UNMOVABLE block.
> >
> >Combining the two would be suitable because once mlock returns, any mapped
> >page is locked in place and future allocations will be placed suitable. I'd
> >also be ok allowing file-backed mlocked pages to be migrated on the grounds
> >that no assumptions can be made about access latency anyway.
> >
> >>"
> >>It would be a solution to enhance compaction/CMA and we can make that compaction doesn't migrate
> >>UNMOVABLE_PAGE_GROUP which make full by unevictable pages so mlocked page is still pinning page.
> >>But get_user_pages in drivers still a problem. Or we can migrate unevictable pages, too so that
> >>compaction/CMA would be good much but we lost pinning concept(It would break man page of mlocked
> >>about real-time application stuff). Hmm.
> >>
> >>>
> >>>And, think if application explictly use migrate_pages(2) or admins uses
> >>>cpusets. driver code can't assume such scenario
> >>>doesn't occur, yes?
> >>
> >>Yes. it seems to migrate mlocked page now.
> >>Hmm,
> >>Johannes, Mel.
> >>Why should we be unfair on only compaction?
> >>
> >
> >If CMA decide they want to alter mlocked pages in this way, it's sortof
> >ok. While CMA is being used, there are no expectations on the RT
> >behaviour of the system - stalls are expected. In their use cases, CMA
> >failing is far worse than access latency to an mlocked page being
> >variable while CMA is running.
> 
> That's strange. CMA caller can't know the altered page is under mlock or not.
> and almost all CMA user is in embedded world. ie RT realm.

Embedded does not imply realtime constraints.

> So, I don't think
> CMA and compaction are significantly different.
> 

CMA is used in cases such as a mobile phone needing to allocate a large
contiguous range of memory for video decoding. Compaction is used by
features such as THP with khugepaged potentially using it frequently on
x86-64 machines. The use cases are different and compaction is used by
THP a lot more than CMA is used by anything.

If compaction can move mlocked pages then khugepaged can introduce unexpected
latencies on mlocked anonymous regions of memory.

> >Compaction on the other hand is during the normal operation of the
> >machine. There are applications that assume that if anonymous memory
> >is mlocked() then access to it is close to zero latency. They are
> >not RT-critical processes (or they would disable THP) but depend on
> >this. Allowing compaction to migrate mlocked() pages will result in bugs
> >being reported by these people.
> >
> >I've received one bug this year about access latency to mlocked() regions but
> >it turned out to be a file-backed region and related to when the write-fault
> >is incurred. The ultimate fix was in the application but we'll get new bug
> >reports if anonymous mlocked pages do not preserve the current guarantees
> >on access latency.
> 
> Can you please tell us your opinion about autonuma?

I think it will have the same problem as THP using compaction. If
mlocked pages can move then there may be unexpected latencies accessing
mlocked anonymous regions.

> I doubt we can keep such
> mlock guarantee. I think we need to suggest application fix. maybe to introduce
> MADV_UNMOVABLE is good start. it seems to solve autonuma issue too.
> 

That'll regress existing applications. It would be preferable to me that
it be the other way around to not move mlocked pages unless the user says
it's allowed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
