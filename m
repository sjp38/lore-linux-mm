Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 717D18D003C
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 05:17:15 -0500 (EST)
From: Andrea Righi <arighi@develer.com>
Subject: [PATCH 3/3] blkio-throttle: async write io instrumentation
Date: Mon, 28 Feb 2011 11:15:05 +0100
Message-Id: <1298888105-3778-4-git-send-email-arighi@develer.com>
In-Reply-To: <1298888105-3778-1-git-send-email-arighi@develer.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Righi <arighi@develer.com>

Enforce IO throttling policy to asynchronous IO writes at the time tasks
write pages in the page cache.

Signed-off-by: Andrea Righi <arighi@develer.com>
---
 mm/page-writeback.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2cb01f6..e3f5f4f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -607,6 +607,19 @@ void set_page_dirty_balance(struct page *page, int page_mkwrite)
 	}
 }
 
+/*
+ * Get a request_queue of the underlying superblock device from an
+ * address_space.
+ */
+static struct request_queue *as_to_rq(struct address_space *mapping)
+{
+	struct block_device *bdev;
+
+	bdev = (mapping->host && mapping->host->i_sb->s_bdev) ?
+				mapping->host->i_sb->s_bdev : NULL;
+	return bdev ? bdev_get_queue(bdev) : NULL;
+}
+
 static DEFINE_PER_CPU(unsigned long, bdp_ratelimits) = 0;
 
 /**
@@ -628,6 +641,7 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 {
 	unsigned long ratelimit;
 	unsigned long *p;
+	struct request_queue *q;
 
 	ratelimit = ratelimit_pages;
 	if (mapping->backing_dev_info->dirty_exceeded)
@@ -644,6 +658,9 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 		ratelimit = sync_writeback_pages(*p);
 		*p = 0;
 		preempt_enable();
+		q = as_to_rq(mapping);
+		if (q)
+			blk_throtl_async(q, ratelimit << PAGE_SHIFT);
 		balance_dirty_pages(mapping, ratelimit);
 		return;
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
