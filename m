Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2D36B025E
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 01:17:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so209490408pfd.3
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 22:17:39 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id z86si35854650pfd.171.2016.08.16.22.17.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 22:17:37 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0OC100N5VG1CI2E0@mailout2.samsung.com> for linux-mm@kvack.org;
 Wed, 17 Aug 2016 14:17:36 +0900 (KST)
From: Daeho Jeong <daeho.jeong@samsung.com>
Subject: [RFC 2/3] cfq: add cfq_find_async_wb_req
Date: Wed, 17 Aug 2016 14:20:44 +0900
Message-id: <1471411245-5186-3-git-send-email-daeho.jeong@samsung.com>
In-reply-to: <1471411245-5186-1-git-send-email-daeho.jeong@samsung.com>
References: <1471411245-5186-1-git-send-email-daeho.jeong@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, tytso@mit.edu, adilger.kernel@dilger.ca, jack@suse.com, linux-block@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Daeho Jeong <daeho.jeong@samsung.com>

Implemented a function to find asynchronous writeback I/O with a
specified sector number and remove the found I/O from the queue
and return that to the caller.

Signed-off-by: Daeho Jeong <daeho.jeong@samsung.com>
---
 block/cfq-iosched.c      |   29 +++++++++++++++++++++++++++++
 block/elevator.c         |   24 ++++++++++++++++++++++++
 include/linux/elevator.h |    3 +++
 3 files changed, 56 insertions(+)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 4a34978..69355e2 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2524,6 +2524,32 @@ static void cfq_remove_request(struct request *rq)
 	}
 }
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+static struct request *
+cfq_find_async_wb_req(struct request_queue *q, sector_t sector)
+{
+	struct cfq_data *cfqd = q->elevator->elevator_data;
+	struct cfq_queue *cfqq;
+	struct request *found_req = NULL;
+	int i;
+
+	for (i = 0; i < IOPRIO_BE_NR; i++) {
+		cfqq = cfqd->root_group->async_cfqq[1][i];
+		if (cfqq) {
+			if (cfqq->queued[0])
+				found_req = elv_rb_find_incl(&cfqq->sort_list,
+							      sector);
+			if (found_req) {
+				cfq_remove_request(found_req);
+				return found_req;
+			}
+		}
+	}
+
+	return NULL;
+}
+#endif
+
 static int cfq_merge(struct request_queue *q, struct request **req,
 		     struct bio *bio)
 {
@@ -4735,6 +4761,9 @@ static struct elevator_type iosched_cfq = {
 		.elevator_add_req_fn =		cfq_insert_request,
 		.elevator_activate_req_fn =	cfq_activate_request,
 		.elevator_deactivate_req_fn =	cfq_deactivate_request,
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+		.elevator_find_async_wb_req_fn = cfq_find_async_wb_req,
+#endif
 		.elevator_completed_req_fn =	cfq_completed_request,
 		.elevator_former_req_fn =	elv_rb_former_request,
 		.elevator_latter_req_fn =	elv_rb_latter_request,
diff --git a/block/elevator.c b/block/elevator.c
index e4081ce..d34267a 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -343,6 +343,30 @@ struct request *elv_rb_find(struct rb_root *root, sector_t sector)
 }
 EXPORT_SYMBOL(elv_rb_find);
 
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+struct request *elv_rb_find_incl(struct rb_root *root, sector_t sector)
+{
+	struct rb_node *n = root->rb_node;
+	struct request *rq;
+
+	while (n) {
+		rq = rb_entry(n, struct request, rb_node);
+
+		if (sector < blk_rq_pos(rq))
+			n = n->rb_left;
+		else if (sector > blk_rq_pos(rq)) {
+			if (sector < blk_rq_pos(rq) + blk_rq_sectors(rq))
+				return rq;
+			n = n->rb_right;
+		} else
+			return rq;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(elv_rb_find_incl);
+#endif
+
 /*
  * Insert rq into dispatch queue of q.  Queue lock must be held on
  * entry.  rq is sort instead into the dispatch queue. To be used by
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index 08ce155..efc202a 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -183,6 +183,9 @@ extern struct request *elv_rb_latter_request(struct request_queue *, struct requ
 extern void elv_rb_add(struct rb_root *, struct request *);
 extern void elv_rb_del(struct rb_root *, struct request *);
 extern struct request *elv_rb_find(struct rb_root *, sector_t);
+#ifdef CONFIG_BOOST_URGENT_ASYNC_WB
+extern struct request *elv_rb_find_incl(struct rb_root *, sector_t);
+#endif
 
 /*
  * Return values from elevator merger
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
