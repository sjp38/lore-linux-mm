Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2BE2D6007FC
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 07:40:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6SBeQlZ018971
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 28 Jul 2010 20:40:26 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AA0D45DE51
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 20:40:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0934645DE56
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 20:40:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DF1A1DB803C
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 20:40:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6569E1DB8042
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 20:40:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Why PAGEOUT_IO_SYNC stalls for a long time
In-Reply-To: <20100728071705.GA22964@localhost>
References: <20100728071705.GA22964@localhost>
Message-Id: <20100728191322.4A85.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 28 Jul 2010 20:40:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

In this week, I've tested some IO congested workload for a while. and probably
I did reproduced Andreas's issue.

So, I would like to explain current lumpy reclaim how works and why so much sucks.


1. Now isolate_lru_pages() have following pfn neighber grabbing logic.

                for (; pfn < end_pfn; pfn++) {
(snip)
                        if (__isolate_lru_page(cursor_page, mode, file) == 0) {
                                list_move(&cursor_page->lru, dst);
                                mem_cgroup_del_lru(cursor_page);
                                nr_taken++;
                                nr_lumpy_taken++;
                                if (PageDirty(cursor_page))
                                        nr_lumpy_dirty++;
                                scan++;
                        } else {
                                if (mode == ISOLATE_BOTH &&
                                                page_count(cursor_page))
                                        nr_lumpy_failed++;
                        }
                }

Mainly, __isolate_lru_page() failure can be caused following reasons.
  (1) the page have already been freed and is in buddy.
  (2) the page is used for non user process purpose
  (3) the page is unevictable (e.g. mlocked)

(2), (3) have very different characteristic from (1). the lumpy reclaim
mean 'contenious physical memory reclaiming'. that said, if we are trying
order 9 reclaim, 512 pages reclaim success and 511 pages reclaim success
are completely differennt. former mean lumpy reclaim successfull, latter mean
failure. So, if (2) or (3) occur, that pfn have lost a possibility of lumpy
reclaim successfull. then, we should stop pfn neighbor search immediately and
try to get lru next page. (i.e. we should use 'break' statement instead 'continue')

2. synchronous lumpy reclaim condition is insane.

currently, synchrounous lumpy reclaim will be invoked when following
condition.

        if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
                        sc->lumpy_reclaim_mode) {

but "nr_reclaimed < nr_taken" is pretty stupid. if isolated pages have
much dirty pages, pageout() only issue first 113 IOs.
(if io queue have >113 requests, bdi_write_congested() return true and
 may_write_to_queue() return false)

So, we haven't call ->writepage(), congestion_wait() and wait_on_page_writeback()
are surely stupid.


3. pageout() is intended anynchronous api. but doesn't works so.

pageout() call ->writepage with wbc->nonblocking=1. because if the system have
default vm.dirty_ratio (i.e. 20), we have 80% clean memory. so, getting stuck
on one page is stupid, we should scan much pages as soon as possible.

HOWEVER, block layer ignore this argument. if slow usb memory device connect
to the system, ->writepage() will sleep long time. because submit_bio() call
get_request_wait() unconditionally and it doesn't have any PF_MEMALLOC task
bonus.


4. synchronous lumpy reclaim call clear_active_flags(). but it is also silly.

Now, page_check_references() ignore pte young bit when we are processing lumpy reclaim.
Then, In almostly case, PageActive() mean "swap device is full". Therefore,
waiting IO and retry pageout() are just silly.


In andres's case, congestion_wait() and get_request_wait() are root cause.
Other issue is problematic when more higher order lumpy reclaim.


Now, I'm preparing some patches and probably I can send them tommorow.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
