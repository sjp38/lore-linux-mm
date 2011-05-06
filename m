Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 455BE6B0022
	for <linux-mm@kvack.org>; Fri,  6 May 2011 04:42:55 -0400 (EDT)
Date: Fri, 6 May 2011 16:42:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH] writeback: limit number of moved inodes in queue_io()
Message-ID: <20110506084238.GA487@localhost>
References: <20110420080336.441157866@intel.com>
 <20110420080918.560499032@intel.com>
 <20110504073931.GA22675@localhost>
 <20110505163708.GN5323@quack.suse.cz>
 <20110506052955.GA24904@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110506052955.GA24904@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "Li, Shaohua" <shaohua.li@intel.com>

> patched trace-tar-dd-ext4-2.6.39-rc3+

>        flush-8:0-3048  [004]  1929.981734: writeback_queue_io: bdi 8:0: older=4296600898 age=2 enqueue=13227

> vanilla trace-tar-dd-ext4-2.6.39-rc3

>        flush-8:0-2911  [004]    77.158312: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=18938

>        flush-8:0-2911  [000]    82.461064: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=6957

It looks too much to move 13227 and 18938 inodes at once. So I tried
arbitrarily limiting the max move number to 1000 and it helps reduce
the lock hold time and contentions a lot.

---
Subject: writeback: limit number of moved inodes in queue_io()
Date: Fri May 06 13:34:08 CST 2011

Only move 1000 inodes from b_dirty to b_io at one time. This reduces
lock hold time and lock contentions by many times in a simple dd+tar
workload in a 8p test box. This workload was observed to move 10000+
inodes in one shot on ext4 which was obviously too much.

                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-b
ounces   acquisitions   holdtime-min   holdtime-max holdtime-total
----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------
                      inode_wb_list_lock:          2063           2065           0.12        2648.66        5948.99
 27475         943778           0.09        2704.76      498340.24
                      ------------------
                      inode_wb_list_lock             89          [<ffffffff8115cf3a>] sync_inode+0x28/0x5f
                      inode_wb_list_lock             38          [<ffffffff8115ccab>] inode_wait_for_writeback+0xa8/0xc6
                      inode_wb_list_lock            629          [<ffffffff8115da35>] __mark_inode_dirty+0x170/0x1d0
                      inode_wb_list_lock            842          [<ffffffff8115d334>] writeback_sb_inodes+0x10f/0x157
                      ------------------
                      inode_wb_list_lock            891          [<ffffffff8115ce3e>] writeback_single_inode+0x175/0x249
                      inode_wb_list_lock             13          [<ffffffff8115dc4e>] writeback_inodes_wb+0x3a/0x143
                      inode_wb_list_lock            499          [<ffffffff8115da35>] __mark_inode_dirty+0x170/0x1d0
                      inode_wb_list_lock            617          [<ffffffff8115d334>] writeback_sb_inodes+0x10f/0x157


                &(&wb->list_lock)->rlock:           842            842           0.14         101.10        1013.34
 20489         970892           0.09         234.11      509829.79
                ------------------------
                &(&wb->list_lock)->rlock            275          [<ffffffff8115db09>] __mark_inode_dirty+0x173/0x1cf
                &(&wb->list_lock)->rlock            114          [<ffffffff8115cdd3>] writeback_single_inode+0x18a/0x27e
                &(&wb->list_lock)->rlock             56          [<ffffffff8115cc29>] inode_wait_for_writeback+0xac/0xcc
                &(&wb->list_lock)->rlock            132          [<ffffffff8115cf2a>] sync_inode+0x63/0xa2
                ------------------------
                &(&wb->list_lock)->rlock              2          [<ffffffff8115dfea>] inode_wb_list_del+0x5f/0x85
                &(&wb->list_lock)->rlock             33          [<ffffffff8115cf2a>] sync_inode+0x63/0xa2
                &(&wb->list_lock)->rlock              9          [<ffffffff8115cc29>] inode_wait_for_writeback+0xac/0xcc
                &(&wb->list_lock)->rlock            430          [<ffffffff8115cdd3>] writeback_single_inode+0x18a/0x27e

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2011-05-06 13:32:41.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-05-06 13:34:08.000000000 +0800
@@ -279,6 +279,8 @@ static int move_expired_inodes(struct li
 		sb = inode->i_sb;
 		list_move(&inode->i_wb_list, &tmp);
 		moved++;
+		if (unlikely(moved >= 1000))	/* limit spinlock hold time */
+			break;
 	}
 
 	/* just one sb in list, splice to dispatch_queue and we're done */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
