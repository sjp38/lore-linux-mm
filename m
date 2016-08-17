Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7206B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 01:17:38 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so184496283pab.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 22:17:38 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id c190si35829060pfg.285.2016.08.16.22.17.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 22:17:37 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0OC100N5TG1BI2E0@mailout2.samsung.com> for linux-mm@kvack.org;
 Wed, 17 Aug 2016 14:17:35 +0900 (KST)
From: Daeho Jeong <daeho.jeong@samsung.com>
Subject: [RFC 1/3] block, mm: add support for boosting urgent asynchronous
 writeback io
Date: Wed, 17 Aug 2016 14:20:43 +0900
Message-id: <1471411245-5186-2-git-send-email-daeho.jeong@samsung.com>
In-reply-to: <1471411245-5186-1-git-send-email-daeho.jeong@samsung.com>
References: <1471411245-5186-1-git-send-email-daeho.jeong@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, tytso@mit.edu, adilger.kernel@dilger.ca, jack@suse.com, linux-block@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Daeho Jeong <daeho.jeong@samsung.com>

We define an async I/O as urgent async I/O when a process starts to
wait for its writeback completion and can easily detect the moment in
wait_on_page_writeback().

To convert urgent async I/O to sync I/O, we need to check whether the
page is under async I/O writeback in wait_on_page_writeback(), first.
If it is, we have to request for I/O scheduler to find a request
relating to the page, but we need to more wait in case of that the I/O
of the page still stays in the plug list. After found the async I/O
request, we allocate a new sync I/O request copying the properties of
the async I/O request, if possible. Otherwise, just re-insert the async
I/O request setting with REQ_PRIO.

Added two page flags as follows:
PG_asyncwb: represents the page is under async I/O writeback
PG_plugged: represents the I/O related to this page stays in the
            plug list

Signed-off-by: Daeho Jeong <daeho.jeong@samsung.com>
---
 block/Kconfig.iosched          |    9 ++++
 block/blk-core.c               |   28 ++++++++++
 block/elevator.c               |  117 ++++++++++++++++++++++++++++++++++++++++
 include/linux/blk_types.h      |    3 ++
 include/linux/elevator.h       |   10 ++++
 include/linux/page-flags.h     |   12 +++++
 include/linux/pagemap.h        |   12 +++++
 include/trace/events/mmflags.h |   10 +++-
 mm/filemap.c                   |   39 ++++++++++++++
 9 files changed, 239 insertions(+), 1 deletion(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 421bef9..c21ae30 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -39,6 +39,15 @@ config CFQ_GROUP_IOSCHED
 	---help---
 	  Enable group IO scheduling in CFQ.
 
+config BOOST_URGENT_ASYNC_WB
+	bool "Enable boosting urgent asynchronous writeback (EXPERIMENTAL)"
+	default n
+	---help---
+	  Enabling this option allows I/O scheduler convert the urgent
+	  asynchronous I/Os, which are flushed by kworker but its completion
+	  is still being waited by another process, into synchronous I/Os for
+	  better responsiveness.
+
 choice
 	prompt "Default I/O scheduler"
 	default DEFAULT_CFQ
diff --git a/block/blk-core.c b/block/blk-core.c
index 2475b1c7..f8ce24a 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1694,6 +1694,23 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+void clear_plugged_flag_in_bio(struct bio *bio)
+{
+	if (bio_flagged(bio, BIO_ASYNC_WB)) {
+		struct bio_vec bv;
+		struct bvec_iter iter;
+
+		bio_for_each_segment(bv, bio, iter) {
+			if (TestClearPagePlugged(bv.bv_page)) {
+				smp_mb__after_atomic();
+				wake_up_page(bv.bv_page, PG_plugged);
+			}
+		}
+	}
+}
+#endif
+
 void init_request_from_bio(struct request *req, struct bio *bio)
 {
 	req->cmd_type = REQ_TYPE_FS;
@@ -1702,6 +1719,11 @@ void init_request_from_bio(struct request *req, struct bio *bio)
 	if (bio->bi_rw & REQ_RAHEAD)
 		req->cmd_flags |= REQ_FAILFAST_MASK;
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+	if (bio_flagged(bio, BIO_ASYNC_WB))
+		req->cmd_flags |= REQ_ASYNC_WB;
+#endif
+
 	req->errors = 0;
 	req->__sector = bio->bi_iter.bi_sector;
 	req->ioprio = bio_prio(bio);
@@ -1752,6 +1774,9 @@ static blk_qc_t blk_queue_bio(struct request_queue *q, struct bio *bio)
 	el_ret = elv_merge(q, &req, bio);
 	if (el_ret == ELEVATOR_BACK_MERGE) {
 		if (bio_attempt_back_merge(q, req, bio)) {
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+			clear_plugged_flag_in_bio(bio);
+#endif
 			elv_bio_merged(q, req, bio);
 			if (!attempt_back_merge(q, req))
 				elv_merged_request(q, req, el_ret);
@@ -1759,6 +1784,9 @@ static blk_qc_t blk_queue_bio(struct request_queue *q, struct bio *bio)
 		}
 	} else if (el_ret == ELEVATOR_FRONT_MERGE) {
 		if (bio_attempt_front_merge(q, req, bio)) {
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+			clear_plugged_flag_in_bio(bio);
+#endif
 			elv_bio_merged(q, req, bio);
 			if (!attempt_front_merge(q, req))
 				elv_merged_request(q, req, el_ret);
diff --git a/block/elevator.c b/block/elevator.c
index c3555c9..e4081ce 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -598,6 +598,20 @@ void __elv_add_request(struct request_queue *q, struct request *rq, int where)
 
 	rq->q = q;
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+	if (rq->cmd_flags & REQ_ASYNC_WB) {
+		struct req_iterator iter;
+		struct bio_vec bvec;
+
+		rq_for_each_segment(bvec, rq, iter) {
+			if (TestClearPagePlugged(bvec.bv_page)) {
+				smp_mb__after_atomic();
+				wake_up_page(bvec.bv_page, PG_plugged);
+			}
+		}
+	}
+#endif
+
 	if (rq->cmd_flags & REQ_SOFTBARRIER) {
 		/* barriers are scheduling boundary, update end_sector */
 		if (rq->cmd_type == REQ_TYPE_FS) {
@@ -681,6 +695,109 @@ void elv_add_request(struct request_queue *q, struct request *rq, int where)
 }
 EXPORT_SYMBOL(elv_add_request);
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+void elv_boost_async_wb_req(struct request_queue *q, struct page *page)
+{
+	struct elevator_queue *e = q->elevator;
+	struct request *new_req, *found_req = NULL;
+	struct buffer_head *bh, *head;
+	struct bio *bio;
+	int i, scnt = 0;
+	sector_t sectors[MAX_BUF_PER_PAGE];
+	sector_t start_sect, end_sect, part_start = 0;
+	struct block_device *bdev;
+	elevator_find_async_wb_req_fn *find_async_wb_req_fn;
+
+	if (!e)
+		return;
+	find_async_wb_req_fn = e->type->ops.elevator_find_async_wb_req_fn;
+	if (!find_async_wb_req_fn)
+		return;
+
+	wait_on_page_plugged(page);
+	if (!PageAsyncWB(page))
+		return;
+
+	spin_lock(&page->mapping->private_lock);
+	if (!page_has_buffers(page)) {
+		spin_unlock(&page->mapping->private_lock);
+		return;
+	}
+	head = page_buffers(page);
+	bdev = head->b_bdev;
+	if (bdev != bdev->bd_contains) {
+		struct hd_struct *p = bdev->bd_part;
+
+		part_start = p->start_sect;
+	}
+	bh = head;
+	do {
+		sectors[scnt++] = bh->b_blocknr * (bh->b_size >> 9)
+				  + part_start;
+		bh = bh->b_this_page;
+	} while (bh != head);
+	spin_unlock(&page->mapping->private_lock);
+
+	spin_lock_irq(q->queue_lock);
+	for (i = 0; i < scnt; i++) {
+		found_req = find_async_wb_req_fn(q, sectors[i]);
+
+		if (found_req) {
+			start_sect = blk_rq_pos(found_req);
+			end_sect = blk_rq_pos(found_req) +
+				   blk_rq_sectors(found_req);
+
+			spin_unlock_irq(q->queue_lock);
+			new_req = blk_get_request(q, REQ_WRITE | REQ_SYNC,
+						  GFP_ATOMIC);
+			spin_lock_irq(q->queue_lock);
+
+			if (IS_ERR(new_req)) {
+				found_req->cmd_flags |= REQ_PRIO;
+				q->elevator->type->ops.elevator_add_req_fn(q,
+								     found_req);
+			} else {
+				new_req->bio = found_req->bio;
+				new_req->biotail = found_req->biotail;
+				found_req->bio = found_req->biotail = NULL;
+				for (bio = new_req->bio; bio;
+				     bio = bio->bi_next)
+					bio->bi_rw |= REQ_SYNC;
+				new_req->cpu = found_req->cpu;
+				new_req->cmd_flags = found_req->cmd_flags |
+						     REQ_SYNC;
+				new_req->cmd_type = found_req->cmd_type;
+				new_req->__sector = blk_rq_pos(found_req);
+				new_req->__data_len = blk_rq_bytes(found_req);
+				new_req->nr_phys_segments =
+						found_req->nr_phys_segments;
+				new_req->rq_disk = found_req->rq_disk;
+				new_req->ioprio = task_nice_ioprio(current);
+				new_req->part = found_req->part;
+
+				if (q->last_merge == found_req)
+					q->last_merge = NULL;
+				elv_rqhash_del(q, found_req);
+				q->nr_sorted--;
+				__blk_put_request(q, found_req);
+				q->elevator->type->ops.elevator_add_req_fn(q,
+								       new_req);
+			}
+
+			while (i < scnt - 1) {
+				if (sectors[i + 1] >= start_sect &&
+				    sectors[i + 1] < end_sect)
+					i++;
+				else
+					break;
+			}
+		}
+	}
+	spin_unlock_irq(q->queue_lock);
+}
+EXPORT_SYMBOL(elv_boost_async_wb_req);
+#endif
+
 struct request *elv_latter_request(struct request_queue *q, struct request *rq)
 {
 	struct elevator_queue *e = q->elevator;
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 77e5d81..152d670 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -120,6 +120,7 @@ struct bio {
 #define BIO_QUIET	6	/* Make BIO Quiet */
 #define BIO_CHAIN	7	/* chained bio, ->bi_remaining in effect */
 #define BIO_REFFED	8	/* bio has elevated ->bi_cnt */
+#define BIO_ASYNC_WB	9	/* flushed as asynchronous I/O by kworker */
 
 /*
  * Flags starting here get preserved by bio_reset() - this includes
@@ -188,6 +189,7 @@ enum rq_flag_bits {
 	__REQ_PM,		/* runtime pm request */
 	__REQ_HASHED,		/* on IO scheduler merge hash */
 	__REQ_MQ_INFLIGHT,	/* track inflight for MQ */
+	__REQ_ASYNC_WB,		/* flushed as asynchronous I/O by kworker */
 	__REQ_NR_BITS,		/* stops here */
 };
 
@@ -241,6 +243,7 @@ enum rq_flag_bits {
 #define REQ_PM			(1ULL << __REQ_PM)
 #define REQ_HASHED		(1ULL << __REQ_HASHED)
 #define REQ_MQ_INFLIGHT		(1ULL << __REQ_MQ_INFLIGHT)
+#define REQ_ASYNC_WB		(1ULL << __REQ_ASYNC_WB)
 
 typedef unsigned int blk_qc_t;
 #define BLK_QC_T_NONE	-1U
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index 638b324..08ce155 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -35,6 +35,10 @@ typedef int (elevator_set_req_fn) (struct request_queue *, struct request *,
 typedef void (elevator_put_req_fn) (struct request *);
 typedef void (elevator_activate_req_fn) (struct request_queue *, struct request *);
 typedef void (elevator_deactivate_req_fn) (struct request_queue *, struct request *);
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+typedef struct request *(elevator_find_async_wb_req_fn) (struct request_queue *,
+							 sector_t sector);
+#endif
 
 typedef int (elevator_init_fn) (struct request_queue *,
 				struct elevator_type *e);
@@ -53,6 +57,9 @@ struct elevator_ops
 	elevator_add_req_fn *elevator_add_req_fn;
 	elevator_activate_req_fn *elevator_activate_req_fn;
 	elevator_deactivate_req_fn *elevator_deactivate_req_fn;
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+	elevator_find_async_wb_req_fn *elevator_find_async_wb_req_fn;
+#endif
 
 	elevator_completed_req_fn *elevator_completed_req_fn;
 
@@ -123,6 +130,9 @@ extern void elv_dispatch_sort(struct request_queue *, struct request *);
 extern void elv_dispatch_add_tail(struct request_queue *, struct request *);
 extern void elv_add_request(struct request_queue *, struct request *, int);
 extern void __elv_add_request(struct request_queue *, struct request *, int);
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+extern void elv_boost_async_wb_req(struct request_queue *, struct page *);
+#endif
 extern int elv_merge(struct request_queue *, struct request **, struct bio *);
 extern void elv_merge_requests(struct request_queue *, struct request *,
 			       struct request *);
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e5a3244..16999f6 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -105,6 +105,10 @@ enum pageflags {
 	PG_young,
 	PG_idle,
 #endif
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+	PG_asyncwb,
+	PG_plugged,
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -351,6 +355,14 @@ TESTCLEARFLAG(Young, young, PF_ANY)
 PAGEFLAG(Idle, idle, PF_ANY)
 #endif
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+PAGEFLAG(AsyncWB, asyncwb, PF_ANY)
+PAGEFLAG(Plugged, plugged, PF_ANY) TESTCLEARFLAG(Plugged, plugged, PF_ANY)
+#else
+PAGEFLAG_FALSE(AsyncWB)
+PAGEFLAG_FALSE(Plugged) TESTCLEARFLAG_FALSE(Plugged)
+#endif
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9735410..0cc5872 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -498,14 +498,26 @@ static inline void wait_on_page_locked(struct page *page)
 		wait_on_page_bit(compound_head(page), PG_locked);
 }
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+static inline void wait_on_page_plugged(struct page *page)
+{
+	if (PagePlugged(page))
+		wait_on_page_bit(page, PG_plugged);
+}
+#endif
+
 /* 
  * Wait for a page to complete writeback
  */
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+extern void wait_on_page_writeback(struct page *page);
+#else
 static inline void wait_on_page_writeback(struct page *page)
 {
 	if (PageWriteback(page))
 		wait_on_page_bit(page, PG_writeback);
 }
+#endif
 
 extern void end_page_writeback(struct page *page);
 void wait_for_stable_page(struct page *page);
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 43cedbf0c..5f09ea6 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -78,6 +78,12 @@
 #define IF_HAVE_PG_IDLE(flag,string)
 #endif
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+#define IF_HAVE_PG_ASYNCWB(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_ASYNCWB(flag,string)
+#endif
+
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
 	{1UL << PG_error,		"error"		},		\
@@ -103,7 +109,9 @@ IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
 IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
 IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
 IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
-IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
+IF_HAVE_PG_IDLE(PG_idle,		"idle"		)		\
+IF_HAVE_PG_ASYNCWB(PG_asyncwb,		"asyncwb"	)		\
+IF_HAVE_PG_ASYNCWB(PG_plugged,		"plugged"	)
 
 #define show_page_flags(flags)						\
 	(flags) ? __print_flags(flags, "|",				\
diff --git a/mm/filemap.c b/mm/filemap.c
index 20f3b1f..4c62bce 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -837,6 +837,37 @@ void unlock_page(struct page *page)
 }
 EXPORT_SYMBOL(unlock_page);
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+void wait_on_page_writeback(struct page *page)
+{
+	struct buffer_head *head;
+	struct block_device *bdev;
+	struct request_queue *q = NULL;
+
+	if (PageWriteback(page)) {
+		if (PageAsyncWB(page)) {
+			spin_lock(&page->mapping->private_lock);
+			if (!page_has_buffers(page)) {
+				spin_unlock(&page->mapping->private_lock);
+				goto wait;
+			}
+			head = page_buffers(page);
+			get_bh(head);
+			spin_unlock(&page->mapping->private_lock);
+			bdev = head->b_bdev;
+			if (bdev)
+				q = bdev->bd_queue;
+			if (q)
+				elv_boost_async_wb_req(q, page);
+			put_bh(head);
+			ClearPageAsyncWB(page);
+		}
+wait:
+		wait_on_page_bit(page, PG_writeback);
+	}
+}
+#endif
+
 /**
  * end_page_writeback - end writeback against a page
  * @page: the page
@@ -855,6 +886,14 @@ void end_page_writeback(struct page *page)
 		rotate_reclaimable_page(page);
 	}
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+	ClearPageAsyncWB(page);
+	if (TestClearPagePlugged(page)) {
+		smp_mb__after_atomic();
+		wake_up_page(page, PG_plugged);
+	}
+#endif
+
 	if (!test_clear_page_writeback(page))
 		BUG();
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
