Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5281F6B02D5
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 05:16:09 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o729G5Fw007516
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 2 Aug 2010 18:16:05 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 16B1245DE53
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 18:16:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E608B45DE51
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 18:16:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C01FD1DB8040
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 18:16:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DC981DB803C
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 18:16:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Bug 12309 - Large I/O operations result in poor interactive performance and high iowait times
In-Reply-To: <20100802081253.GA27492@localhost>
References: <20100802003616.5b31ed8b@digital-domain.net> <20100802081253.GA27492@localhost>
Message-Id: <20100802171954.4F95.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon,  2 Aug 2010 18:16:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Clayton <andrew@digital-domain.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, pvz@pvz.pp.se, bgamari@gmail.com, larppaxyz@gmail.com, seanj@xyke.com, kernel-bugs.dev1world@spamgourmet.com, akatopaz@gmail.com, frankrq2009@gmx.com, thomas.pi@arcor.de, spawels13@gmail.com, vshader@gmail.com, rockorequin@hotmail.com, ylalym@gmail.com, theholyettlz@googlemail.com, hassium@yandex.ru
List-ID: <linux-mm.kvack.org>

> > I've pointed to your two patches in the bug report, so hopefully someone
> > who is seeing the issues can try them out.
> 
> Thanks.
> 
> > I noticed your comment about the no swap situation
> > 
> > "#26: Per von Zweigbergk
> > Disabling swap makes the terminal launch much faster while copying;
> > However Firefox and vim hang much more aggressively and frequently
> > during copying.
> > 
> > It's interesting to see processes behave differently. Is this
> > reproducible at all?"
> > 
> > Recently there have been some other people who have noticed this.
> > 
> > Comment #460 From  SA,ren Holm   2010-07-22 20:33:00   (-) [reply] -------
> > 
> > I've tried stress also.
> > I have 2 Gb og memory and 1.5 Gb swap
> > 
> > With swap activated stress -d 1 hangs my machine
> > 
> > Same does stress -d while swapiness set to 0
> > 
> > Widh swap deactivated things runs pretty fine. Of couse apps utilizing
> > syncronous disk-io fight stress for priority.
> > 
> > Comment #461 From  Nels Nielson   2010-07-23 16:23:06   (-) [reply] -------
> > 
> > I can also confirm this. Disabling swap with swapoff -a solves the problem.
> > I have 8gb of ram and 8gb of swap with a fake raid mirror.
> > 
> > Before this I couldn't do backups without the whole system grinding to a halt.
> > Right now I am doing a backup from the drives, watching a movie from the same
> > drives and more. No more iowait times and programs freezing as they are starved
> > from being able to access the drives.
> 
> So swapping is another major cause of responsiveness lags.
> 
> I just tested the heavy swapping case with the patches to remove
> the congestion_wait() and wait_on_page_writeback() stalls on high
> order allocations. The patches work as expected. No single stall shows
> up with the debug patch posted in http://lkml.org/lkml/2010/8/1/10.
> 
> However there are still stalls on get_request_wait():
> - kswapd trying to pageout anonymous pages
> - _any_ process in direct reclaim doing pageout()

Well, not any.

current check is following.

-----------------------------------------------------------
static int may_write_to_queue(struct backing_dev_info *bdi)
{
        if (current->flags & PF_SWAPWRITE)
                return 1;
        if (!bdi_write_congested(bdi))
                return 1;
        if (bdi == current->backing_dev_info)
                return 1;
        return 0;
}
-----------------------------------------------------------

It mean congestion ignorerance is happend when followings
  (1) the task is kswapd
  (2) the task is flusher thread
  (3) this reclaim is called from zone reclaim (note: I'm thinking this is bug)
  (4) this reclaim is called from __generic_file_aio_write()

(4) is root cause of this latency issue. this behavior was introduced
by following.


-------------------------------------------------------------------
commit 94bc3c9279ae182ca996d89dc9a56b66b06d5d8f
Author: akpm <akpm>
Date:   Mon Sep 23 05:17:02 2002 +0000

    [PATCH] low-latency page reclaim

    Convert the VM to not wait on other people's dirty data.

     - If we find a dirty page and its queue is not congested, do some writeback.

     - If we find a dirty page and its queue _is_ congested then just
       refile the page.

     - If we find a PageWriteback page then just refile the page.

     - There is additional throttling for write(2) callers.  Within
       generic_file_write(), record their backing queue in ->current.
       Within page reclaim, if this tasks encounters a page which is dirty
       or under writeback onthis queue, block on it.  This gives some more
       writer throttling and reduces the page refiling frequency.

    It's somewhat CPU expensive - under really heavy load we only get a 50%
    reclaim rate in pages coming off the tail of the LRU.  This can be
    fixed by splitting the inactive list into reclaimable and
    non-reclaimable lists.  But the CPU load isn't too bad, and latency is
    much, much more important in these situations.

    Example: with `mem=512m', running 4 instances of `dbench 100', 2.5.34
    took 35 minutes to compile a kernel.  With this patch, it took three
    minutes, 45 seconds.

    I haven't done swapcache or MAP_SHARED pages yet.  If there's tons of
    dirty swapcache or mmap data around we still stall heavily in page
    reclaim.  That's less important.

    This patch also has a tweak for swapless machines: don't even bother
    bringing anon pages onto the inactive list if there is no swap online.

    BKrev: 3d8ea3cekcPCHjOJ65jQtjjrJMyYeA

diff --git a/mm/filemap.c b/mm/filemap.c
index a27d273..9118a57 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1755,6 +1755,9 @@ generic_file_write_nolock(struct file *file, const struct iovec *iov,
        if (unlikely(pos < 0))
                return -EINVAL;

+       /* We can write back this queue in page reclaim */
+       current->backing_dev_info = mapping->backing_dev_info;
+
        pagevec_init(&lru_pvec);

        if (unlikely(file->f_error)) {
-------------------------------------------------------------------

But is this still necessary? now we have per-hask dirty accounting, the
write hog tasks have already got some waiting penalty.

As I said, per-task dirty accounting only makes a penalty to lots writing
tasks. but the above makes a penalty to all of write(2) user.

> 
> Since 90% pages are dirty anonymous pages, the chances to stall is high.
> kswapd can hardly make smooth progress. The applications end up doing
> direct reclaim by themselves, which also ends up stuck in pageout().
> They are not explicitly stalled in vmscan code, but implicitly in
> get_request_wait() when trying to swapping out the dirty pages.
> 
> It sure hurts responsiveness with so many applications stalled on
> get_request_wait(). But question is, what can we do otherwise? The
> system is running short of memory and cannot keep up freeing enough
> memory anyway. So page allocations have to be throttled somewhere..
> 
> But wait.. What if there are only 50% anonymous pages? In this case
> applications don't necessarily need to sleep in get_request_wait().
> The memory pressure is not really high. The poor man's solution is to
> disable swapping totally, as the bug reporters find to be helpful..
> 
> One easy fix is to skip swap-out when bdi is congested and priority is
> close to DEF_PRIORITY. However it would be unfair to selectively
> (largely in random) keep some pages and reclaim the others that
> actually have the same age.
> 
> A more complete fix may be to introduce some swap_out LRU list(s).
> Pages in it will be swap out as fast as possible by a dedicated
> kernel thread. And pageout() can freely add pages to it until it
> grows larger than some threshold, eg. 30% reclaimable memory, at which
> point pageout() will stall on the list. The basic idea is to switch
> the random get_request_wait() stalls to some more global wise stalls.

Yup, I'd prefer this idea. but probably it should retrieve writeback general,
not only swapout.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
