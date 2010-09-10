Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 50C996B008A
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 06:25:48 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8AAPjYM030298
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Sep 2010 19:25:45 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D392645DE4F
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 19:25:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A963E45DE51
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 19:25:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E0AFE18002
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 19:25:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A4A0E08005
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 19:25:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 05/10] vmscan: Synchrounous lumpy reclaim use lock_page() instead trylock_page()
In-Reply-To: <20100909092203.GL29263@csn.ul.ie>
References: <20100909131211.C93C.A69D9226@jp.fujitsu.com> <20100909092203.GL29263@csn.ul.ie>
Message-Id: <20100909182649.C94F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Sep 2010 19:25:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Thu, Sep 09, 2010 at 01:13:22PM +0900, KOSAKI Motohiro wrote:
> > > On Thu, 9 Sep 2010 12:04:48 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Mon,  6 Sep 2010 11:47:28 +0100
> > > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > > 
> > > > > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > 
> > > > > With synchrounous lumpy reclaim, there is no reason to give up to reclaim
> > > > > pages even if page is locked. This patch uses lock_page() instead of
> > > > > trylock_page() in this case.
> > > > > 
> > > > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > > 
> > > > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > 
> > > Ah......but can't this change cause dead lock ??
> > 
> > Yes, this patch is purely crappy. please drop. I guess I was poisoned
> > by poisonous mushroom of Mario Bros.
> > 
> 
> Lets be clear on what the exact dead lock conditions are. The ones I had
> thought about when I felt this patch was ok were;
> 
> o We are not holding the LRU lock (or any lock, we just called cond_resched())
> o We do not have another page locked because we cannot lock multiple pages
> o Kswapd will never be in LUMPY_MODE_SYNC so it is not getting blocked
> o lock_page() itself is not allocating anything that we could recurse on

True, all.

> 
> One potential dead lock would be if the direct reclaimer held a page
> lock and ended up here but is that situation even allowed?

example, 

__do_fault()
{
(snip)
        if (unlikely(!(ret & VM_FAULT_LOCKED)))
                lock_page(vmf.page);
        else
                VM_BUG_ON(!PageLocked(vmf.page));

        /*
         * Should we do an early C-O-W break?
         */
        page = vmf.page;
        if (flags & FAULT_FLAG_WRITE) {
                if (!(vma->vm_flags & VM_SHARED)) {
                        anon = 1;
                        if (unlikely(anon_vma_prepare(vma))) {
                                ret = VM_FAULT_OOM;
                                goto out;
                        }
                        page = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
                                                vma, address);


Afaik, detailed rule is,

o kswapd can call lock_page() because they never take page lock outside vmscan
o if try_lock() is successed, we can call lock_page_nosync() against its page after unlock.
  because the task have gurantee of no lock taken.
o otherwise, direct reclaimer can't call lock_page(). the task may have a lock already.

I think.


>  I did not
> think of an obvious example of when this would happen. Similarly,
> deadlock situations with mmap_sem shouldn't happen unless multiple page
> locks are being taken.
> 
> (prepares to feel foolish)
> 
> What did I miss?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
