Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5EF6B0317
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g143so37710293wme.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i24si19777395wrb.104.2017.05.24.04.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 04:20:29 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OB9iKx122455
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:27 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2an16acjty-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:27 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 24 May 2017 12:20:25 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v2 08/10] mm: Define mem range lock operations
Date: Wed, 24 May 2017 13:19:59 +0200
In-Reply-To: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1495624801-8063-9-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

This patch introduce new mm_down/up*() operation which will run on
mmap_sem as a semaphore or as a range lock depending on
CONFIG_MEM_RANGE_LOCK.

When CONFIG_MEM_RANGE_LOCK is defined, the additional range parameter
is used, otherwise it is ignored to avoid any useless additional stack
parameter.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h       | 27 +++++++++++++++++++++++++++
 include/linux/mm_types.h |  5 +++++
 2 files changed, 32 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b09048386152..d47b28eb0a53 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -15,6 +15,7 @@
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
 #include <linux/range.h>
+#include <linux/range_lock.h>
 #include <linux/pfn.h>
 #include <linux/percpu-refcount.h>
 #include <linux/bit_spinlock.h>
@@ -2588,5 +2589,31 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+#ifdef CONFIG_MEM_RANGE_LOCK
+#define mm_range_define(r)						\
+	struct range_lock r = __RANGE_LOCK_INITIALIZER(0, RANGE_LOCK_FULL)
+#define mm_read_lock(m, r)	range_read_lock(&(m)->mmap_sem, r)
+#define mm_read_trylock(m, r)	range_read_trylock(&(m)->mmap_sem, r)
+#define mm_read_unlock(m, r)	range_read_unlock(&(m)->mmap_sem, r)
+#define mm_write_lock(m, r)	range_write_lock(&(m)->mmap_sem, r)
+#define mm_write_trylock(m, r)	range_write_trylock(&(m)->mmap_sem, r)
+#define mm_write_unlock(m, r)	range_write_unlock(&(m)->mmap_sem, r)
+#define mm_write_lock_killable(m, r) \
+	range_write_lock_interruptible(&(m)->mmap_sem, r)
+#define mm_downgrade_write(m, r) range_downgrade_write(&(m)->mmap_sem, r)
+
+#else /* CONFIG_MEM_RANGE_LOCK */
+#define mm_range_define(r)	do { } while (0)
+#define mm_read_lock(m, r)	down_read(&(m)->mmap_sem)
+#define mm_read_trylock(m, r)	down_read_trylock(&(m)->mmap_sem)
+#define mm_read_unlock(m, r)	up_read(&(m)->mmap_sem)
+#define mm_write_lock(m, r)	down_write(&(m)->mmap_sem)
+#define mm_write_trylock(m, r)	down_write_trylock(&(m)->mmap_sem)
+#define mm_write_unlock(m, r)	up_write(&(m)->mmap_sem)
+#define mm_write_lock_killable(m, r) down_write_killable(&(m)->mmap_sem)
+#define mm_downgrade_write(m, r) downgrade_write(&(m)->mmap_sem)
+
+#endif /* CONFIG_MEM_RANGE_LOCK */
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 45cdb27791a3..d40611490200 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -8,6 +8,7 @@
 #include <linux/spinlock.h>
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
+#include <linux/range_lock.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/uprobes.h>
@@ -403,7 +404,11 @@ struct mm_struct {
 	int map_count;				/* number of VMAs */
 
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
+#ifdef CONFIG_MEM_RANGE_LOCK
+	struct range_lock_tree mmap_sem;
+#else
 	struct rw_semaphore mmap_sem;
+#endif
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
 						 * together off init_mm.mmlist, and are protected
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
