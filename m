Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id D4B586B0038
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 15:40:22 -0400 (EDT)
Received: by ykei199 with SMTP id i199so21464344yke.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 12:40:22 -0700 (PDT)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id f62si9949638ywa.28.2015.09.02.12.40.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 12:40:21 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so21407484ykd.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 12:40:21 -0700 (PDT)
Date: Wed, 2 Sep 2015 15:40:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: Use-after-free in page_cache_async_readahead
Message-ID: <20150902194019.GL22326@mtj.duckdns.org>
References: <CAAeHK+zUJ74Zn17=rOyxacHU18SgCfC6bsYW=6kCY5GXJBwGfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+zUJ74Zn17=rOyxacHU18SgCfC6bsYW=6kCY5GXJBwGfQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>

Hello, Andrey.

On Wed, Sep 02, 2015 at 01:08:52PM +0200, Andrey Konovalov wrote:
> While running KASAN on 4.2 with Trinity I got the following report:
> 
> ==================================================================
> BUG: KASan: use after free in page_cache_async_readahead+0x2cb/0x3f0
> at addr ffff880034bf6690
> Read of size 8 by task sshd/2571
> =============================================================================
> BUG kmalloc-16 (Tainted: G        W      ): kasan: bad access detected
> -----------------------------------------------------------------------------
> 
> Disabling lock debugging due to kernel taint
> INFO: Allocated in bdi_init+0x168/0x960 age=554826 cpu=0 pid=6

Can you please verify that the following patch fixes the issue?

Thanks.

---
 block/blk-core.c            |    2 +-
 block/blk-sysfs.c           |    1 +
 include/linux/backing-dev.h |    6 +++++-
 mm/backing-dev.c            |   12 +++++++++++-
 4 files changed, 18 insertions(+), 3 deletions(-)

--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -578,7 +578,7 @@ void blk_cleanup_queue(struct request_qu
 		q->queue_lock = &q->__queue_lock;
 	spin_unlock_irq(lock);
 
-	bdi_destroy(&q->backing_dev_info);
+	bdi_unregister(&q->backing_dev_info);
 
 	/* @q is and will stay empty, shutdown and put */
 	blk_put_queue(q);
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -502,6 +502,7 @@ static void blk_release_queue(struct kob
 	struct request_queue *q =
 		container_of(kobj, struct request_queue, kobj);
 
+	bdi_exit(&q->backing_dev_info);
 	blkcg_exit_queue(q);
 
 	if (q->elevator) {
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -18,13 +18,17 @@
 #include <linux/slab.h>
 
 int __must_check bdi_init(struct backing_dev_info *bdi);
-void bdi_destroy(struct backing_dev_info *bdi);
+void bdi_exit(struct backing_dev_info *bdi);
 
 __printf(3, 4)
 int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 		const char *fmt, ...);
 int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
+void bdi_unregister(struct backing_dev_info *bdi);
+
 int __must_check bdi_setup_and_register(struct backing_dev_info *, char *);
+void bdi_destroy(struct backing_dev_info *bdi);
+
 void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 			bool range_cyclic, enum wb_reason reason);
 void wb_start_background_writeback(struct bdi_writeback *wb);
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -823,7 +823,7 @@ static void bdi_remove_from_list(struct
 	synchronize_rcu_expedited();
 }
 
-void bdi_destroy(struct backing_dev_info *bdi)
+void bdi_unregister(struct backing_dev_info *bdi)
 {
 	/* make sure nobody finds us on the bdi_list anymore */
 	bdi_remove_from_list(bdi);
@@ -835,9 +835,19 @@ void bdi_destroy(struct backing_dev_info
 		device_unregister(bdi->dev);
 		bdi->dev = NULL;
 	}
+}
 
+void bdi_exit(struct backing_dev_info *bdi)
+{
+	WARN_ON_ONCE(bdi->dev);
 	wb_exit(&bdi->wb);
 }
+
+void bdi_destroy(struct backing_dev_info *bdi)
+{
+	bdi_unregister(bdi);
+	bdi_exit(bdi);
+}
 EXPORT_SYMBOL(bdi_destroy);
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
