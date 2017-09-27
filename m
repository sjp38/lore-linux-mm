Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F1B956B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 03:11:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 188so25448121pgb.3
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 00:11:48 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id b3si6946702plb.691.2017.09.27.00.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 00:11:47 -0700 (PDT)
From: Zumeng Chen <zumeng.chen@gmail.com>
Subject: [PATCH ] mm/backing-dev.c: remove a null kfree and fix a false kmemleak in backing-dev
Date: Wed, 27 Sep 2017 15:15:08 +0800
Message-ID: <1506496508-31715-1-git-send-email-zumeng.chen@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: axboe@fb.com, jack@suse.cz, tj@kernel.org, geliangtang@gmail.com

It seems kfree(new_congested) does nothing since new_congested has already
been set null pointer before kfree, so remove it.

Meanwhile kmemleak reports the following memory leakage:

unreferenced object 0xcadbb440 (size 64):
comm "kworker/0:4", pid 1399, jiffies 4294946504 (age 808.290s)
hex dump (first 32 bytes):
  00 00 00 00 01 00 00 00 00 00 00 00 01 00 00 00  ................
  01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
backtrace:
  [<c028fb64>] kmem_cache_alloc_trace+0x2c4/0x3cc
  [<c025fe70>] wb_congested_get_create+0x9c/0x140
  [<c0260100>] wb_init+0x184/0x1f4
  [<c02601fc>] bdi_init+0x8c/0xd4
  [<c051f75c>] blk_alloc_queue_node+0x9c/0x2d8
  [<c05227e8>] blk_init_queue_node+0x2c/0x64
  [<c052283c>] blk_init_queue+0x1c/0x20
  [<c06c7b30>] __scsi_alloc_queue+0x28/0x44
  [<c06caf4c>] scsi_alloc_queue+0x24/0x80
  [<c06cc0b8>] scsi_alloc_sdev+0x21c/0x34c
  [<c06ccc00>] scsi_probe_and_add_lun+0x878/0xb04
  [<c06cd114>] __scsi_scan_target+0x288/0x59c
  [<c06cd4b0>] scsi_scan_channel+0x88/0x9c
  [<c06cd9b8>] scsi_scan_host_selected+0x118/0x130
  [<c06cda70>] do_scsi_scan_host+0xa0/0xa4
  [<c06cdbe4>] scsi_scan_host+0x170/0x1b4

wb_congested allocates memory for congested when wb_congested_get_create,
and release it when exit or failure by wb_congested_put.

Signed-off-by: Zumeng Chen <zumeng.chen@gmail.com>
---
 mm/backing-dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e19606b..d816b2a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -457,6 +457,7 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
 
 	/* allocate storage for new one and retry */
 	new_congested = kzalloc(sizeof(*new_congested), gfp);
+	kmemleak_ignore(new_congested);
 	if (!new_congested)
 		return NULL;
 
@@ -468,7 +469,6 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
 found:
 	atomic_inc(&congested->refcnt);
 	spin_unlock_irqrestore(&cgwb_lock, flags);
-	kfree(new_congested);
 	return congested;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
