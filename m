Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A60294403DA
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:29:23 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m18so555043pgd.13
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:29:23 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p1si2681136pgr.812.2017.10.31.16.29.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:29:22 -0700 (PDT)
Subject: [PATCH 15/15] wait_bit: introduce {wait_on,wake_up}_devmap_idle
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 16:22:56 -0700
Message-ID: <150949217671.24061.13258957060358089669.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hch@lst.de

Add hashed waitqueue infrastructure to wait for ZONE_DEVICE pages to
drop their reference counts and be considered idle for DMA. This
facility will be used for filesystem callbacks / wakeups when DMA to a
DAX mapped range of a file ends.

For now, this implementation does not have functional behavior change
outside of waking waitqueues that do not have any waiters present.

Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/super.c      |    1 +
 include/linux/wait_bit.h |   10 +++++++
 kernel/sched/wait_bit.c  |   64 ++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 67 insertions(+), 8 deletions(-)

diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index 4ac359e14777..a5a4b95ffdaf 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -167,6 +167,7 @@ struct dax_device {
 #if IS_ENABLED(CONFIG_FS_DAX)
 static void generic_dax_pagefree(struct page *page, void *data)
 {
+	wake_up_devmap_idle(&page->_refcount);
 }
 
 struct dax_device *fs_dax_claim_bdev(struct block_device *bdev, void *owner)
diff --git a/include/linux/wait_bit.h b/include/linux/wait_bit.h
index 12b26660d7e9..6186ecdb9df7 100644
--- a/include/linux/wait_bit.h
+++ b/include/linux/wait_bit.h
@@ -30,10 +30,12 @@ int __wait_on_bit(struct wait_queue_head *wq_head, struct wait_bit_queue_entry *
 int __wait_on_bit_lock(struct wait_queue_head *wq_head, struct wait_bit_queue_entry *wbq_entry, wait_bit_action_f *action, unsigned int mode);
 void wake_up_bit(void *word, int bit);
 void wake_up_atomic_t(atomic_t *p);
+void wake_up_devmap_idle(atomic_t *p);
 int out_of_line_wait_on_bit(void *word, int, wait_bit_action_f *action, unsigned int mode);
 int out_of_line_wait_on_bit_timeout(void *word, int, wait_bit_action_f *action, unsigned int mode, unsigned long timeout);
 int out_of_line_wait_on_bit_lock(void *word, int, wait_bit_action_f *action, unsigned int mode);
 int out_of_line_wait_on_atomic_t(atomic_t *p, int (*)(atomic_t *), unsigned int mode);
+int out_of_line_wait_on_devmap_idle(atomic_t *p, int (*)(atomic_t *), unsigned int mode);
 struct wait_queue_head *bit_waitqueue(void *word, int bit);
 extern void __init wait_bit_init(void);
 
@@ -258,4 +260,12 @@ int wait_on_atomic_t(atomic_t *val, int (*action)(atomic_t *), unsigned mode)
 	return out_of_line_wait_on_atomic_t(val, action, mode);
 }
 
+static inline
+int wait_on_devmap_idle(atomic_t *val, int (*action)(atomic_t *), unsigned mode)
+{
+	might_sleep();
+	if (atomic_read(val) == 1)
+		return 0;
+	return out_of_line_wait_on_devmap_idle(val, action, mode);
+}
 #endif /* _LINUX_WAIT_BIT_H */
diff --git a/kernel/sched/wait_bit.c b/kernel/sched/wait_bit.c
index f8159698aa4d..6ea93149614a 100644
--- a/kernel/sched/wait_bit.c
+++ b/kernel/sched/wait_bit.c
@@ -162,11 +162,17 @@ static inline wait_queue_head_t *atomic_t_waitqueue(atomic_t *p)
 	return bit_waitqueue(p, 0);
 }
 
-static int wake_atomic_t_function(struct wait_queue_entry *wq_entry, unsigned mode, int sync,
-				  void *arg)
+static inline struct wait_bit_queue_entry *to_wait_bit_q(
+		struct wait_queue_entry *wq_entry)
+{
+	return container_of(wq_entry, struct wait_bit_queue_entry, wq_entry);
+}
+
+static int wake_atomic_t_function(struct wait_queue_entry *wq_entry,
+		unsigned mode, int sync, void *arg)
 {
 	struct wait_bit_key *key = arg;
-	struct wait_bit_queue_entry *wait_bit = container_of(wq_entry, struct wait_bit_queue_entry, wq_entry);
+	struct wait_bit_queue_entry *wait_bit = to_wait_bit_q(wq_entry);
 	atomic_t *val = key->flags;
 
 	if (wait_bit->key.flags != key->flags ||
@@ -176,14 +182,29 @@ static int wake_atomic_t_function(struct wait_queue_entry *wq_entry, unsigned mo
 	return autoremove_wake_function(wq_entry, mode, sync, key);
 }
 
+static int wake_devmap_idle_function(struct wait_queue_entry *wq_entry,
+		unsigned mode, int sync, void *arg)
+{
+	struct wait_bit_key *key = arg;
+	struct wait_bit_queue_entry *wait_bit = to_wait_bit_q(wq_entry);
+	atomic_t *val = key->flags;
+
+	if (wait_bit->key.flags != key->flags ||
+	    wait_bit->key.bit_nr != key->bit_nr ||
+	    atomic_read(val) != 1)
+		return 0;
+	return autoremove_wake_function(wq_entry, mode, sync, key);
+}
+
 /*
  * To allow interruptible waiting and asynchronous (i.e. nonblocking) waiting,
  * the actions of __wait_on_atomic_t() are permitted return codes.  Nonzero
  * return codes halt waiting and return.
  */
 static __sched
-int __wait_on_atomic_t(struct wait_queue_head *wq_head, struct wait_bit_queue_entry *wbq_entry,
-		       int (*action)(atomic_t *), unsigned mode)
+int __wait_on_atomic_t(struct wait_queue_head *wq_head,
+		struct wait_bit_queue_entry *wbq_entry,
+		int (*action)(atomic_t *), unsigned mode, int target)
 {
 	atomic_t *val;
 	int ret = 0;
@@ -191,10 +212,10 @@ int __wait_on_atomic_t(struct wait_queue_head *wq_head, struct wait_bit_queue_en
 	do {
 		prepare_to_wait(wq_head, &wbq_entry->wq_entry, mode);
 		val = wbq_entry->key.flags;
-		if (atomic_read(val) == 0)
+		if (atomic_read(val) == target)
 			break;
 		ret = (*action)(val);
-	} while (!ret && atomic_read(val) != 0);
+	} while (!ret && atomic_read(val) != target);
 	finish_wait(wq_head, &wbq_entry->wq_entry);
 	return ret;
 }
@@ -210,16 +231,37 @@ int __wait_on_atomic_t(struct wait_queue_head *wq_head, struct wait_bit_queue_en
 		},							\
 	}
 
+#define DEFINE_WAIT_DEVMAP_IDLE(name, p)					\
+	struct wait_bit_queue_entry name = {				\
+		.key = __WAIT_ATOMIC_T_KEY_INITIALIZER(p),		\
+		.wq_entry = {						\
+			.private	= current,			\
+			.func		= wake_devmap_idle_function,	\
+			.entry		=				\
+				LIST_HEAD_INIT((name).wq_entry.entry),	\
+		},							\
+	}
+
 __sched int out_of_line_wait_on_atomic_t(atomic_t *p, int (*action)(atomic_t *),
 					 unsigned mode)
 {
 	struct wait_queue_head *wq_head = atomic_t_waitqueue(p);
 	DEFINE_WAIT_ATOMIC_T(wq_entry, p);
 
-	return __wait_on_atomic_t(wq_head, &wq_entry, action, mode);
+	return __wait_on_atomic_t(wq_head, &wq_entry, action, mode, 0);
 }
 EXPORT_SYMBOL(out_of_line_wait_on_atomic_t);
 
+__sched int out_of_line_wait_on_devmap_idle(atomic_t *p, int (*action)(atomic_t *),
+					 unsigned mode)
+{
+	struct wait_queue_head *wq_head = atomic_t_waitqueue(p);
+	DEFINE_WAIT_DEVMAP_IDLE(wq_entry, p);
+
+	return __wait_on_atomic_t(wq_head, &wq_entry, action, mode, 1);
+}
+EXPORT_SYMBOL(out_of_line_wait_on_devmap_idle);
+
 /**
  * wake_up_atomic_t - Wake up a waiter on a atomic_t
  * @p: The atomic_t being waited on, a kernel virtual address
@@ -235,6 +277,12 @@ void wake_up_atomic_t(atomic_t *p)
 }
 EXPORT_SYMBOL(wake_up_atomic_t);
 
+void wake_up_devmap_idle(atomic_t *p)
+{
+	__wake_up_bit(atomic_t_waitqueue(p), p, WAIT_ATOMIC_T_BIT_NR);
+}
+EXPORT_SYMBOL(wake_up_devmap_idle);
+
 __sched int bit_wait(struct wait_bit_key *word, int mode)
 {
 	schedule();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
