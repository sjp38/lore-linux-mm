Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F34A46B00F3
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 05:14:21 -0400 (EDT)
Date: Mon, 13 Sep 2010 10:14:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05/10] vmscan: Synchrounous lumpy reclaim use
	lock_page() instead trylock_page()
Message-ID: <20100913091405.GB23508@csn.ul.ie>
References: <20100909131211.C93C.A69D9226@jp.fujitsu.com> <20100909092203.GL29263@csn.ul.ie> <20100909182649.C94F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100909182649.C94F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 10, 2010 at 07:25:43PM +0900, KOSAKI Motohiro wrote:
> > On Thu, Sep 09, 2010 at 01:13:22PM +0900, KOSAKI Motohiro wrote:
> > > > On Thu, 9 Sep 2010 12:04:48 +0900
> > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > 
> > > > > On Mon,  6 Sep 2010 11:47:28 +0100
> > > > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > > > 
> > > > > > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > > 
> > > > > > With synchrounous lumpy reclaim, there is no reason to give up to reclaim
> > > > > > pages even if page is locked. This patch uses lock_page() instead of
> > > > > > trylock_page() in this case.
> > > > > > 
> > > > > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > > > 
> > > > > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > > 
> > > > Ah......but can't this change cause dead lock ??
> > > 
> > > Yes, this patch is purely crappy. please drop. I guess I was poisoned
> > > by poisonous mushroom of Mario Bros.
> > > 
> > 
> > Lets be clear on what the exact dead lock conditions are. The ones I had
> > thought about when I felt this patch was ok were;
> > 
> > o We are not holding the LRU lock (or any lock, we just called cond_resched())
> > o We do not have another page locked because we cannot lock multiple pages
> > o Kswapd will never be in LUMPY_MODE_SYNC so it is not getting blocked
> > o lock_page() itself is not allocating anything that we could recurse on
> 
> True, all.
> 
> > 
> > One potential dead lock would be if the direct reclaimer held a page
> > lock and ended up here but is that situation even allowed?
> 
> example, 
> 
> __do_fault()
> {
> (snip)
>         if (unlikely(!(ret & VM_FAULT_LOCKED)))
>                 lock_page(vmf.page);
>         else
>                 VM_BUG_ON(!PageLocked(vmf.page));
> 
>         /*
>          * Should we do an early C-O-W break?
>          */
>         page = vmf.page;
>         if (flags & FAULT_FLAG_WRITE) {
>                 if (!(vma->vm_flags & VM_SHARED)) {
>                         anon = 1;
>                         if (unlikely(anon_vma_prepare(vma))) {
>                                 ret = VM_FAULT_OOM;
>                                 goto out;
>                         }
>                         page = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
>                                                 vma, address);
> 

Correct, this is a problem. I already had dropped the patch but thanks for
pointing out a deadlock because I was missing this case. Nothing stops the
page being faulted being sent to shrink_page_list() when alloc_page_vma()
is called. The deadlock might be hard to hit, but it's there.

> 
> Afaik, detailed rule is,
> 
> o kswapd can call lock_page() because they never take page lock outside vmscan

lock_page_nosync as you point out in your next mail. While it can call
it, kswapd shouldn't because normally it avoids stalls but it would not
deadlock as a result of calling it.

> o if try_lock() is successed, we can call lock_page_nosync() against its page after unlock.
>   because the task have gurantee of no lock taken.
> o otherwise, direct reclaimer can't call lock_page(). the task may have a lock already.
> 

I think the safer bet is simply to say "direct reclaimers should not
call lock_page() because the fault path could be holding a lock on that
page already".

Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
