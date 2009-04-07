Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 240DA5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 11:10:03 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
Subject: [PATCH] [1/16] POISON: Add support for high priority work items
Message-Id: <20090407150957.9B2F71D046E@basil.firstfloor.org>
Date: Tue,  7 Apr 2009 17:09:57 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


The machine check poison handling needs to go to process context very 
quickly.  Add a new high priority queueing mechanism for work items.
This should be only used in exceptional cases! (but a machine check
is definitely exceptional)

The insert is not fully O(1) in regards to other high priority
items, but those should be rather rare anyways.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/workqueue.h |    3 +++
 kernel/workqueue.c        |   15 +++++++++++++++
 2 files changed, 18 insertions(+)

Index: linux/include/linux/workqueue.h
===================================================================
--- linux.orig/include/linux/workqueue.h	2009-04-07 16:39:28.000000000 +0200
+++ linux/include/linux/workqueue.h	2009-04-07 16:39:39.000000000 +0200
@@ -25,6 +25,7 @@
 struct work_struct {
 	atomic_long_t data;
 #define WORK_STRUCT_PENDING 0		/* T if work item pending execution */
+#define WORK_STRUCT_HIGHPRI 1		/* work is high priority */
 #define WORK_STRUCT_FLAG_MASK (3UL)
 #define WORK_STRUCT_WQ_DATA_MASK (~WORK_STRUCT_FLAG_MASK)
 	struct list_head entry;
@@ -163,6 +164,8 @@
 #define work_clear_pending(work) \
 	clear_bit(WORK_STRUCT_PENDING, work_data_bits(work))
 
+#define set_work_highpri(work) \
+	set_bit(WORK_STRUCT_HIGHPRI, work_data_bits(work))
 
 extern struct workqueue_struct *
 __create_workqueue_key(const char *name, int singlethread,
Index: linux/kernel/workqueue.c
===================================================================
--- linux.orig/kernel/workqueue.c	2009-04-07 16:39:28.000000000 +0200
+++ linux/kernel/workqueue.c	2009-04-07 16:39:39.000000000 +0200
@@ -132,6 +132,21 @@
 	 * result of list_add() below, see try_to_grab_pending().
 	 */
 	smp_wmb();
+	/*
+	 * Insert after last high priority item. This avoids
+	 * them starving each other.
+	 * High priority items should be rare, so it's ok to not have
+	 * O(1) insert for them.
+	 */
+	if (test_bit(WORK_STRUCT_HIGHPRI, work_data_bits(work)) &&
+		!list_empty(head)) {
+		struct work_struct *w;
+		list_for_each_entry (w, head, entry) {
+			if (!test_bit(WORK_STRUCT_HIGHPRI, work_data_bits(w)))
+				break;
+		}
+		head = &w->entry;
+	}
 	list_add_tail(&work->entry, head);
 	wake_up(&cwq->more_work);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
