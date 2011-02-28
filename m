Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 953378D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 05:17:11 -0500 (EST)
From: Andrea Righi <arighi@develer.com>
Subject: [PATCH 1/3] block: introduce REQ_DIRECT to track direct io bio
Date: Mon, 28 Feb 2011 11:15:03 +0100
Message-Id: <1298888105-3778-2-git-send-email-arighi@develer.com>
In-Reply-To: <1298888105-3778-1-git-send-email-arighi@develer.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Righi <arighi@develer.com>

Introduce a new flag to identify if a bio has been generated for a
direct IO operation.

This flag is used by the blkio controller to identify if a write IO
request has been issued by the current task and can be limited directly
or if it has been generated from another IO context, as a result of a
buffered IO operation.

Signed-off-by: Andrea Righi <arighi@develer.com>
---
 fs/direct-io.c            |    1 +
 include/linux/blk_types.h |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index b044705..fe364a4 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -361,6 +361,7 @@ static void dio_bio_submit(struct dio *dio)
 	unsigned long flags;
 
 	bio->bi_private = dio;
+	bio->bi_rw |= REQ_DIRECT;
 
 	spin_lock_irqsave(&dio->bio_lock, flags);
 	dio->refcount++;
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 46ad519..2f98c03 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -130,6 +130,7 @@ enum rq_flag_bits {
 	/* bio only flags */
 	__REQ_UNPLUG,		/* unplug the immediately after submission */
 	__REQ_RAHEAD,		/* read ahead, can fail anytime */
+	__REQ_DIRECT,		/* direct io request */
 	__REQ_THROTTLED,	/* This bio has already been subjected to
 				 * throttling rules. Don't do it again. */
 
@@ -173,6 +174,7 @@ enum rq_flag_bits {
 #define REQ_UNPLUG		(1 << __REQ_UNPLUG)
 #define REQ_RAHEAD		(1 << __REQ_RAHEAD)
 #define REQ_THROTTLED		(1 << __REQ_THROTTLED)
+#define REQ_DIRECT		(1 << __REQ_DIRECT)
 
 #define REQ_SORTED		(1 << __REQ_SORTED)
 #define REQ_SOFTBARRIER		(1 << __REQ_SOFTBARRIER)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
