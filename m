Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 10D59600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 03:57:22 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o727vJEb002253
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 2 Aug 2010 16:57:20 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AD0A445DE54
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 16:57:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EEE945DE4C
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 16:57:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E3431DB8014
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 16:57:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A09F1DB8019
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 16:57:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when reclaim is encountering dirty pages
In-Reply-To: <1280679686.3081.28.camel@heimdal.trondhjem.org>
References: <20100801170115.4AFC.A69D9226@jp.fujitsu.com> <1280679686.3081.28.camel@heimdal.trondhjem.org>
Message-Id: <20100802133259.4F89.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon,  2 Aug 2010 16:57:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>, Chris Mason <chris.mason@oracle.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

> The problem that I am seeing is that the try_to_release_page() needs to
> be told to act as a non-blocking call when the process is kswapd, just
> like the pageout() call.
> 
> Currently, the sc->gfp_mask is set to GFP_KERNEL, which normally means
> that the call may wait on I/O to complete. However, what I'm seeing in
> the bugzilla above is that if kswapd waits on an RPC call, then the
> whole VM may gum up: typically, the traces show that the socket layer
> cannot allocate memory to hold the RPC reply from the server, and so it
> is kicking kswapd to have it reclaim some pages, however kswapd is stuck
> in try_to_release_page() waiting for that same I/O to complete, hence
> the deadlock...

Ah, I see. so as far as I understand, you mean
 - Socket layer use GFP_ATOMIC, then they don't call try_to_free_pages().
   IOW, kswapd is only memory reclaiming thread.
 - Kswapd got stuck in ->release_page().
 - In usual use case, another thread call kmalloc(GFP_KERNEL) and makes
   foreground reclaim, then, restore kswapd stucking. but your case
   there is no such thread.

Hm, interesting.

In short term, current nfs fix (checking PF_MEMALLOC in nfs_wb_page())
seems best way. it's no side effect if my understanding is correct.


> IOW: I think kswapd at least should be calling try_to_release_page()
> with a gfp-flag of '0' to avoid deadlocking on I/O.

Hmmm.
0 seems to have very strong meanings rather than nfs required. 
There is no reason to prevent grabbing mutex, calling cond_resched() etc etc...

[digging old git history]

Ho hum...

Old commit log says passing gfp-flag=0 break xfs. but current xfs doesn't
use gfp_mask argument. hm.


============================================================
commit 68678e2fc6cfdfd013a2513fe416726f3c05b28d
Author: akpm <akpm>
Date:   Tue Sep 10 18:09:08 2002 +0000

    [PATCH] pass the correct flags to aops->releasepage()

    Restore the gfp_mask in the VM's call to a_ops->releasepage().  We can
    block in there again, and XFS (at least) can use that.

    BKrev: 3d7e35445skDsKDFM6rdiwTY-5elsw

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5ed1ec3..89d801e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -208,7 +208,7 @@ shrink_list(struct list_head *page_list, int nr_pages,
                 * Otherwise, leave the page on the LRU so it is swappable.
                 */
                if (PagePrivate(page)) {
-                       if (!try_to_release_page(page, 0))
+                       if (!try_to_release_page(page, gfp_mask))
                                goto keep_locked;
                        if (!mapping && page_count(page) == 1)
                                goto free_it;
============================================================

Now, gfp_mask of try_to_release_page() are used in two place.

btrfs: btrfs_releasepage		(check GFP_WAIT)
nfs: nfs_release_page			((gfp & GFP_KERNEL) == GFP_KERNEL)

Probably, btrfs can remove such GFP_WAIT check from try_release_extent_mapping
because it doesn't sleep. I dunno. if so, we can change it to 0 again. but
I'm not sure it has enough worth thing.

Chris, can we hear how btrfs handle gfp_mask argument of release_page()?



btw, VM fokls need more consider kswapd design. now kswapd oftern sleep.
But Trond's bug report says, waiting itself can makes deadlock potentially.
Perhaps it's merely imagine thing. but need to some consider...




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
