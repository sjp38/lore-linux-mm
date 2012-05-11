Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id B5DC48D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 09:14:12 -0400 (EDT)
Date: Fri, 11 May 2012 14:14:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Allow migration of mlocked page?
Message-ID: <20120511131404.GQ11435@suse.de>
References: <4FAC9786.9060200@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FAC9786.9060200@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>

On Fri, May 11, 2012 at 01:37:26PM +0900, Minchan Kim wrote:
> > <SNIP>
> > promise mlock don't change physical page.
> > I wonder if any realtime guys page migration is free lunch. they should
> > disable both auto migration and compaction.
> 
> I think disable migration is overkill. We can do better than it.

The reason why we do not migrate mlock() pages is down to expectations of the
application developer.  mlock historically was a real-time extention. For
files, there is no guarantee of latency because obviously things like
writing to the page can stall in balance_dirty_pages() but for anonymous
memory, there is an expectation that access be low or zero latency. This
would be particularly true if they used something like MAP_POPULATE.

> Quote from discussion last year from me.
> 
> "
> We can solve a bit that by another approach if it's really problem
> with RT processes. The another approach is to separate mlocked pages
> with allocation time like below pseudo patch which just show the
> concept)
> 
> ex)
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index 3a93f73..8ae2e60 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -175,7 +175,8 @@ static inline struct page *
>  alloc_zeroed_user_highpage_movable(struct vm_area_struct *vma,
>                                         unsigned long vaddr)
>  {
> -       return __alloc_zeroed_user_highpage(__GFP_MOVABLE, vma, vaddr);
> +       gfp_t gfp_flag = vma->vm_flags & VM_LCOKED ? 0 : __GFP_MOVABLE;
> +       return __alloc_zeroed_user_highpage(gfp_flag, vma, vaddr);
>  }
> 
> But it's a solution about newly allocated page on mlocked vma.
> Old pages in the VMA is still a problem.

Yes.

> We can solve it at mlock system call through migrating the pages to
> UNMOVABLE block.

Combining the two would be suitable because once mlock returns, any mapped
page is locked in place and future allocations will be placed suitable. I'd
also be ok allowing file-backed mlocked pages to be migrated on the grounds
that no assumptions can be made about access latency anyway.

> "
> It would be a solution to enhance compaction/CMA and we can make that compaction doesn't migrate
> UNMOVABLE_PAGE_GROUP which make full by unevictable pages so mlocked page is still pinning page.
> But get_user_pages in drivers still a problem. Or we can migrate unevictable pages, too so that
> compaction/CMA would be good much but we lost pinning concept(It would break man page of mlocked
> about real-time application stuff). Hmm.
> 
> > 
> > And, think if application explictly use migrate_pages(2) or admins uses
> > cpusets. driver code can't assume such scenario
> > doesn't occur, yes?
> 
> Yes. it seems to migrate mlocked page now.
> Hmm,
> Johannes, Mel.
> Why should we be unfair on only compaction?
> 

If CMA decide they want to alter mlocked pages in this way, it's sortof
ok. While CMA is being used, there are no expectations on the RT
behaviour of the system - stalls are expected. In their use cases, CMA
failing is far worse than access latency to an mlocked page being
variable while CMA is running.

Compaction on the other hand is during the normal operation of the
machine. There are applications that assume that if anonymous memory
is mlocked() then access to it is close to zero latency. They are
not RT-critical processes (or they would disable THP) but depend on
this. Allowing compaction to migrate mlocked() pages will result in bugs
being reported by these people.

I've received one bug this year about access latency to mlocked() regions but
it turned out to be a file-backed region and related to when the write-fault
is incurred. The ultimate fix was in the application but we'll get new bug
reports if anonymous mlocked pages do not preserve the current guarantees
on access latency.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
