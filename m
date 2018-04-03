Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90F8D6B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 13:23:33 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d186so4095546iog.10
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 10:23:33 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q2-v6si795887ite.119.2018.04.03.10.23.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 10:23:32 -0700 (PDT)
From: rao.shoaib@oracle.com
Subject: [PATCH 2/2] kfree_rcu() should use kfree_bulk() interface
Date: Tue,  3 Apr 2018 10:22:53 -0700
Message-Id: <1522776173-7190-3-git-send-email-rao.shoaib@oracle.com>
In-Reply-To: <1522776173-7190-1-git-send-email-rao.shoaib@oracle.com>
References: <1522776173-7190-1-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paulmck@linux.vnet.ibm.com, joe@perches.com, willy@infradead.org, brouer@redhat.com, linux-mm@kvack.org, Rao Shoaib <rao.shoaib@oracle.com>

From: Rao Shoaib <rao.shoaib@oracle.com>

kfree_rcu() should use the new kfree_bulk() interface for freeing
rcu structures as it is more efficient.

Signed-off-by: Rao Shoaib <rao.shoaib@oracle.com>
---
 include/linux/mm.h       |   5 ++
 include/linux/rcupdate.h |   4 +-
 include/linux/rcutiny.h  |   8 ++-
 kernel/sysctl.c          |  40 ++++++++++++
 mm/slab.h                |  23 +++++++
 mm/slab_common.c         | 166 ++++++++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 242 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42..fb1e54c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2673,5 +2673,10 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+extern int sysctl_kfree_rcu_drain_limit;
+extern int sysctl_kfree_rcu_poll_limit;
+extern int sysctl_kfree_rcu_empty_limit;
+extern int sysctl_kfree_rcu_caching_allowed;
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 6338fb6..102a93f 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -55,8 +55,6 @@ void call_rcu(struct rcu_head *head, rcu_callback_t func);
 #define	call_rcu	call_rcu_sched
 #endif /* #else #ifdef CONFIG_PREEMPT_RCU */
 
-/* only for use by kfree_call_rcu() */
-void call_rcu_lazy(struct rcu_head *head, rcu_callback_t func);
 
 void call_rcu_bh(struct rcu_head *head, rcu_callback_t func);
 void call_rcu_sched(struct rcu_head *head, rcu_callback_t func);
@@ -210,6 +208,8 @@ do { \
 
 #if defined(CONFIG_TREE_RCU) || defined(CONFIG_PREEMPT_RCU)
 #include <linux/rcutree.h>
+/* only for use by kfree_call_rcu() */
+void call_rcu_lazy(struct rcu_head *head, rcu_callback_t func);
 #elif defined(CONFIG_TINY_RCU)
 #include <linux/rcutiny.h>
 #else
diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
index ce9beec..b9e9025 100644
--- a/include/linux/rcutiny.h
+++ b/include/linux/rcutiny.h
@@ -84,10 +84,16 @@ static inline void synchronize_sched_expedited(void)
 	synchronize_sched();
 }
 
+static inline void call_rcu_lazy(struct rcu_head *head,
+				 rcu_callback_t func)
+{
+	call_rcu(head, func);
+}
+
 static inline void kfree_call_rcu(struct rcu_head *head,
 				  rcu_callback_t func)
 {
-	call_rcu(head, func);
+	call_rcu_lazy(head, func);
 }
 
 #define rcu_note_context_switch(preempt) \
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f98f28c..ab70c99 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1650,6 +1650,46 @@ static struct ctl_table vm_table[] = {
 		.extra2		= (void *)&mmap_rnd_compat_bits_max,
 	},
 #endif
+	{
+		.procname	= "kfree_rcu_drain_limit",
+		.data		= &sysctl_kfree_rcu_drain_limit,
+		.maxlen		= sizeof(sysctl_kfree_rcu_drain_limit),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
+		.extra2		= &one_hundred,
+	},
+
+	{
+		.procname	= "kfree_rcu_poll_limit",
+		.data		= &sysctl_kfree_rcu_poll_limit,
+		.maxlen		= sizeof(sysctl_kfree_rcu_poll_limit),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
+		.extra2		= &one_hundred,
+	},
+
+	{
+		.procname	= "kfree_rcu_empty_limit",
+		.data		= &sysctl_kfree_rcu_empty_limit,
+		.maxlen		= sizeof(sysctl_kfree_rcu_empty_limit),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &four,
+	},
+
+	{
+		.procname	= "kfree_rcu_caching_allowed",
+		.data		= &sysctl_kfree_rcu_caching_allowed,
+		.maxlen		= sizeof(sysctl_kfree_rcu_caching_allowed),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+
 	{ }
 };
 
diff --git a/mm/slab.h b/mm/slab.h
index 5181323..a332ea6 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -80,6 +80,29 @@ extern const struct kmalloc_info_struct {
 	unsigned long size;
 } kmalloc_info[];
 
+#define	RCU_MAX_ACCUMULATE_SIZE	25
+
+struct rcu_bulk_free_container {
+	struct	rcu_head rbfc_rcu;
+	int	rbfc_entries;
+	void	*rbfc_data[RCU_MAX_ACCUMULATE_SIZE];
+	struct	rcu_bulk_free *rbfc_rbf;
+};
+
+struct rcu_bulk_free {
+	struct	rcu_head rbf_rcu; /* used to schedule monitor process */
+	spinlock_t	rbf_lock;
+	struct		rcu_bulk_free_container *rbf_container;
+	struct		rcu_bulk_free_container *rbf_cached_container;
+	struct		rcu_head *rbf_list_head;
+	int		rbf_list_size;
+	int		rbf_cpu;
+	int		rbf_empty;
+	int		rbf_polled;
+	bool		rbf_init;
+	bool		rbf_monitor;
+};
+
 #ifndef CONFIG_SLOB
 /* Kmalloc array related functions */
 void setup_kmalloc_cache_index_table(void);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2ea9866..f126d08 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -20,6 +20,7 @@
 #include <asm/tlbflush.h>
 #include <asm/page.h>
 #include <linux/memcontrol.h>
+#include <linux/types.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/kmem.h>
@@ -1525,15 +1526,178 @@ void kzfree(const void *p)
 }
 EXPORT_SYMBOL(kzfree);
 
+#if defined(CONFIG_TREE_RCU) || defined(CONFIG_PREEMPT_RCU)
+static DEFINE_PER_CPU(struct rcu_bulk_free, cpu_rbf);
+
+/* drain if atleast these many objects */
+int sysctl_kfree_rcu_drain_limit __read_mostly = 10;
+
+/* time to poll if fewer than drain_limit */
+int sysctl_kfree_rcu_poll_limit __read_mostly = 5;
+
+/* num of times to check bfr exit */
+int sysctl_kfree_rcu_empty_limit __read_mostly = 2;
+
+int sysctl_kfree_rcu_caching_allowed __read_mostly = 1;
+
+/* RCU call back function. Frees the memory */
+static void __rcu_bulk_free_impl(struct rcu_head *rbfc_rcu)
+{
+	struct rcu_bulk_free *rbf = NULL;
+	struct rcu_bulk_free_container *rbfc = container_of(rbfc_rcu,
+	    struct rcu_bulk_free_container, rbfc_rcu);
+
+	kfree_bulk(rbfc->rbfc_entries, rbfc->rbfc_data);
+
+	rbf = rbfc->rbfc_rbf;
+	if (!sysctl_kfree_rcu_caching_allowed ||
+	    cmpxchg(&rbf->rbf_cached_container, NULL, rbfc)) {
+		kfree(rbfc);
+	}
+}
+
+/* processes list of rcu structures
+ * used when conatiner can not be allocated
+ */
+static void __rcu_bulk_schedule_list(struct rcu_bulk_free *rbf)
+{
+	int i;
+
+	for (i = 0; i < rbf->rbf_list_size; i++) {
+		struct rcu_head *free_head;
+
+		free_head = rbf->rbf_list_head;
+		rbf->rbf_list_head = free_head->next;
+		free_head->next = NULL;
+		call_rcu(free_head, free_head->func);
+	}
+	rbf->rbf_list_size = 0;
+}
+
+/* RCU monitoring function -- submits elements for RCU reclaim */
+static void __rcu_bulk_free_monitor(struct rcu_head *rbf_rcu)
+{
+	struct rcu_bulk_free *rbf = NULL;
+	struct rcu_bulk_free_container *rbfc = NULL;
+
+	rbf = container_of(rbf_rcu, struct rcu_bulk_free, rbf_rcu);
+
+	spin_lock(&rbf->rbf_lock);
+
+	rbfc = rbf->rbf_container;
+
+	rbf->rbf_polled++;
+	if (rbf->rbf_list_size > 0) {
+		if (rbf->rbf_list_size >= sysctl_kfree_rcu_drain_limit ||
+		    rbf->rbf_polled >= sysctl_kfree_rcu_poll_limit) {
+			rbf->rbf_polled = 0;
+			__rcu_bulk_schedule_list(rbf);
+		}
+	} else if (rbfc) {
+		if (rbfc->rbfc_entries >= sysctl_kfree_rcu_drain_limit ||
+		    rbf->rbf_polled >= sysctl_kfree_rcu_poll_limit) {
+			rbf->rbf_polled = 0;
+			call_rcu(&rbfc->rbfc_rcu, __rcu_bulk_free_impl);
+			rbf->rbf_container = NULL;
+		}
+	} else if (rbf->rbf_polled >= sysctl_kfree_rcu_empty_limit) {
+		rbf->rbf_monitor = false;
+		rbf->rbf_polled = 0;
+	}
+
+	spin_unlock(&rbf->rbf_lock);
+
+	if (rbf->rbf_monitor)
+		call_rcu(&rbf->rbf_rcu, __rcu_bulk_free_monitor);
+}
+
+/* Main RCU function that is called to free RCU structures */
+static void __rcu_bulk_free(struct rcu_head *head, rcu_callback_t func)
+{
+	unsigned long offset;
+	void *ptr;
+	struct rcu_bulk_free *rbf;
+	struct rcu_bulk_free_container *rbfc = NULL;
+
+	preempt_disable();
+	rbf = this_cpu_ptr(&cpu_rbf);
+
+	if (unlikely(!rbf->rbf_init)) {
+		spin_lock_init(&rbf->rbf_lock);
+		rbf->rbf_cpu = smp_processor_id();
+		rbf->rbf_init = true;
+	}
+
+	/* hold lock to protect against other cpu's */
+	spin_lock_bh(&rbf->rbf_lock);
+
+	rbfc = rbf->rbf_container;
+
+	if (!rbfc) {
+		if (!rbf->rbf_cached_container) {
+			rbf->rbf_container =
+			    kmalloc(sizeof(struct rcu_bulk_free_container),
+				    GFP_ATOMIC);
+		} else {
+			rbf->rbf_container =
+			    READ_ONCE(rbf->rbf_cached_container);
+			cmpxchg(&rbf->rbf_cached_container,
+				rbf->rbf_container, NULL);
+		}
+
+		if (unlikely(!rbf->rbf_container)) {
+			/* Memory allocation failed maintain a list */
+
+			head->func = (void *)func;
+			head->next = rbf->rbf_list_head;
+			rbf->rbf_list_head = head;
+			rbf->rbf_list_size++;
+			if (rbf->rbf_list_size == RCU_MAX_ACCUMULATE_SIZE)
+				__rcu_bulk_schedule_list(rbf);
+
+			goto done;
+		}
+
+		rbfc = rbf->rbf_container;
+		rbfc->rbfc_rbf = rbf;
+		rbfc->rbfc_entries = 0;
+
+		if (!rbf->rbf_list_head)
+			__rcu_bulk_schedule_list(rbf);
+	}
+
+	offset = (unsigned long)func;
+	ptr = (void *)head - offset;
+
+	rbfc->rbfc_data[rbfc->rbfc_entries++] = ptr;
+	if (rbfc->rbfc_entries == RCU_MAX_ACCUMULATE_SIZE) {
+		rbf->rbf_container = NULL;
+		spin_unlock_bh(&rbf->rbf_lock);
+		call_rcu_lazy(&rbfc->rbfc_rcu, __rcu_bulk_free_impl);
+		preempt_enable();
+		return;
+	}
+
+done:
+	if (!rbf->rbf_monitor) {
+		call_rcu_lazy(&rbf->rbf_rcu, __rcu_bulk_free_monitor);
+		rbf->rbf_monitor = true;
+	}
+
+	spin_unlock_bh(&rbf->rbf_lock);
+	preempt_enable();
+}
+
 /*
  * Queue Memory to be freed by RCU after a grace period.
  */
 void kfree_call_rcu(struct rcu_head *head,
 		    rcu_callback_t func)
 {
-	call_rcu_lazy(head, func);
+	__rcu_bulk_free(head, func);
 }
 EXPORT_SYMBOL_GPL(kfree_call_rcu);
+#endif
 
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
-- 
2.7.4
