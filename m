Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 29A5D6B01EE
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 06:48:38 -0400 (EDT)
Date: Wed, 28 Apr 2010 11:48:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs
	when page tables are being moved after the VMA has already moved
Message-ID: <20100428104813.GD15815@csn.ul.ie>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie> <1272403852-10479-4-git-send-email-mel@csn.ul.ie> <20100427223004.GF8860@random.random> <20100427225852.GH8860@random.random> <20100428102928.a3b25066.kamezawa.hiroyu@jp.fujitsu.com> <20100428014434.GM510@random.random> <20100428111248.2797801c.kamezawa.hiroyu@jp.fujitsu.com> <20100428024227.GN510@random.random> <20100428114944.3570105f.kamezawa.hiroyu@jp.fujitsu.com> <20100428162838.c762fcda.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100428162838.c762fcda.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Thanks to you both for looking into this. I far prefer this general approach
than cleaning up the migration PTEs as the page tables get copied. While it
might "work", it's sloppy in the same way as having migration_entry_wait()
do the cleanup was sloppy. It's far preferable to make the VMA move and
page table copy atomic with anon_vma->lock.

On Wed, Apr 28, 2010 at 04:28:38PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 28 Apr 2010 11:49:44 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 28 Apr 2010 04:42:27 +0200
> > Andrea Arcangeli <aarcange@redhat.com> wrote:
>  
> > > migrate.c requires rmap to be able to find all ptes mapping a page at
> > > all times, otherwise the migration entry can be instantiated, but it
> > > can't be removed if the second rmap_walk fails to find the page.
> > > 
> > > So shift_arg_pages must run atomically with respect of rmap_walk, and
> > > it's enough to run it under the anon_vma lock to make it atomic.
> > > 
> > > And split_huge_page() will have the same requirements as migrate.c
> > > already has.
> > > 
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Seems good.
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > I'll test this and report if I see trouble again.
> > 
> > Unfortunately, I'll have a week of holidays (in Japan) in 4/29-5/05,
> > my office is nearly closed. So, please consider no-mail-from-me is
> > good information.
> > 
> Here is bad news. When move_page_tables() fails, "some ptes" are moved
> but others are not and....there is no rollback routine.
> 

The biggest problem is that the reverse mapping is temporarily out of
sync until do_exit gets rid of the mess, but how serious is that really?

If there is a migration entry in there, the mapcount should already be zero and
migration holds a reference to the page to prevent it going away. rmap_walk()
may then miss the migration_pte so it gets left behind. Ordinarily this
would be bad but in exec(), we cannot be faulting this page so we won't
trigger the bug in swapops. Instead, do_exit ultimately will skip over the
migration PTE doing nothing with the page but as the mapcount is still zero,
the page won't leak.

> I bet the best way to fix this mess up is 
>  - disable overlap moving of arg pages
>  - use do_mremap().
> 
> But maybe you guys want to fix this directly.
> Here is a temporal fix from me. But don't trust me..

I see the point of your patch but I'm not yet seeing why it is
necessary to back out if move_page_tables fails.

That said, both patches have a greater problem. Both of them hold a spinlock
(anon_vma->lock) while calling into the page allocator with GFP_KERNEL (to
allocate the page tables). We don't want to change that to GFP_ATOMIC so
either we need to allocate the pages in advance or special case rmap_walk()
to not walk processes that are in exec.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
