Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8D2D6B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:52:41 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id k186so2671899ith.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:52:41 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id l64si664653iod.208.2017.12.19.09.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 09:52:39 -0800 (PST)
From: rao.shoaib@oracle.com
Subject: [PATCH] kfree_rcu() should use the new kfree_bulk() interface for freeing rcu structures
Date: Tue, 19 Dec 2017 09:52:27 -0800
Message-Id: <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
In-Reply-To: <rao.shoaib@oracle.com>
References: <rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org, Rao Shoaib <rao.shoaib@oracle.com>

From: Rao Shoaib <rao.shoaib@oracle.com>

This patch updates kfree_rcu to use new bulk memory free functions as they
are more efficient. It also moves kfree_call_rcu() out of rcu related code to
mm/slab_common.c

Signed-off-by: Rao Shoaib <rao.shoaib@oracle.com>
---
 include/linux/mm.h |   5 ++
 kernel/rcu/tree.c  |  14 ----
 kernel/sysctl.c    |  40 +++++++++++
 mm/slab.h          |  23 +++++++
 mm/slab_common.c   | 198 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 264 insertions(+), 16 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea818ff..8ae4f25 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2669,5 +2669,10 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+extern int sysctl_kfree_rcu_drain_limit;
+extern int sysctl_kfree_rcu_poll_limit;
+extern int sysctl_kfree_rcu_empty_limit;
+extern int sysctl_kfree_rcu_caching_allowed;
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index f9c0ca2..69951ef 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -3209,20 +3209,6 @@ void call_rcu_bh(struct rcu_head *head, rcu_callback_t func)
 EXPORT_SYMBOL_GPL(call_rcu_bh);
 
 /*
- * Queue an RCU callback for lazy invocation after a grace period.
- * This will likely be later named something like "call_rcu_lazy()",
- * but this change will require some way of tagging the lazy RCU
- * callbacks in the list of pending callbacks. Until then, this
- * function may only be called from __kfree_rcu().
- */
-void kfree_call_rcu(struct rcu_head *head,
-		    rcu_callback_t func)
-{
-	__call_rcu(head, func, rcu_state_p, -1, 1);
-}
-EXPORT_SYMBOL_GPL(kfree_call_rcu);
-
-/*
  * Because a context switch is a grace period for RCU-sched and RCU-bh,
  * any blocking grace-period wait automatically implies a grace period
  * if there is only one CPU online at any point time during execution
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 557d467..47b48f7 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1655,6 +1655,46 @@ static struct ctl_table vm_table[] = {
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
index ad657ff..2541f70 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -78,6 +78,29 @@ extern const struct kmalloc_info_struct {
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
 unsigned long calculate_alignment(slab_flags_t flags,
 		unsigned long align, unsigned long size);
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index c8cb367..06fd12c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -20,6 +20,7 @@
 #include <asm/tlbflush.h>
 #include <asm/page.h>
 #include <linux/memcontrol.h>
+#include <linux/types.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/kmem.h>
@@ -129,6 +130,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 
 	for (i = 0; i < nr; i++) {
 		void *x = p[i] = kmem_cache_alloc(s, flags);
+
 		if (!x) {
 			__kmem_cache_free_bulk(s, i, p);
 			return 0;
@@ -353,6 +355,7 @@ unsigned long calculate_alignment(slab_flags_t flags,
 	 */
 	if (flags & SLAB_HWCACHE_ALIGN) {
 		unsigned long ralign = cache_line_size();
+
 		while (size <= ralign / 2)
 			ralign /= 2;
 		align = max(align, ralign);
@@ -444,9 +447,8 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 	mutex_lock(&slab_mutex);
 
 	err = kmem_cache_sanity_check(name, size);
-	if (err) {
+	if (err)
 		goto out_unlock;
-	}
 
 	/* Refuse requests with allocator specific flags */
 	if (flags & ~SLAB_FLAGS_PERMITTED) {
@@ -1131,6 +1133,7 @@ EXPORT_SYMBOL(kmalloc_order);
 void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
 {
 	void *ret = kmalloc_order(size, flags, order);
+
 	trace_kmalloc(_RET_IP_, ret, size, PAGE_SIZE << order, flags);
 	return ret;
 }
@@ -1483,6 +1486,197 @@ void kzfree(const void *p)
 }
 EXPORT_SYMBOL(kzfree);
 
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
+static void
+__rcu_bulk_free_impl(struct rcu_head *rbfc_rcu)
+{
+	struct rcu_bulk_free *rbf = NULL;
+	struct rcu_bulk_free_container *rbfc = container_of(rbfc_rcu,
+	    struct rcu_bulk_free_container, rbfc_rcu);
+
+	WARN_ON(rbfc->rbfc_entries <= 0);
+	kfree_bulk(rbfc->rbfc_entries, rbfc->rbfc_data);
+
+	rbf = rbfc->rbfc_rbf;
+	if (!sysctl_kfree_rcu_caching_allowed ||
+	    cmpxchg(&rbf->rbf_cached_container, NULL, rbfc) != NULL) {
+		kfree(rbfc);
+	}
+}
+
+/* processes list of rcu structures
+ * used when conatiner can not be allocated
+ */
+
+static void
+__rcu_bulk_schedule_list(struct rcu_bulk_free *rbf)
+{
+	int i = 0;
+
+	for (i = 0; i < rbf->rbf_list_size; i++) {
+		struct rcu_head *free_head;
+
+		free_head = rbf->rbf_list_head;
+		rbf->rbf_list_head = free_head->next;
+		free_head->next = NULL;
+		call_rcu(free_head, free_head->func);
+	}
+	WARN_ON(rbf->rbf_list_head != NULL);
+	rbf->rbf_list_size = 0;
+}
+
+
+/* RCU monitoring function -- submits elements for RCU reclaim */
+static void
+__rcu_bulk_free_monitor(struct rcu_head *rbf_rcu)
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
+	if (rbf->rbf_list_size > 0) {
+		WARN_ON(rbfc != NULL);
+		if ((rbf->rbf_list_size >= sysctl_kfree_rcu_drain_limit) ||
+		    rbf->rbf_polled >= sysctl_kfree_rcu_poll_limit) {
+			rbf->rbf_polled = 0;
+			__rcu_bulk_schedule_list(rbf);
+		} else {
+			rbf->rbf_polled++;
+		}
+	} else if (rbfc != NULL) {
+		WARN_ON(rbfc->rbfc_entries <= 0);
+		if ((rbfc->rbfc_entries > sysctl_kfree_rcu_drain_limit) ||
+		    rbf->rbf_polled++ >= sysctl_kfree_rcu_poll_limit) {
+			rbf->rbf_polled = 0;
+			call_rcu(&rbfc->rbfc_rcu, __rcu_bulk_free_impl);
+			rbf->rbf_container = NULL;
+		}
+	} else {
+		 /* Nothing to do, keep track */
+		rbf->rbf_empty++;
+	}
+
+	if (rbf->rbf_empty >= sysctl_kfree_rcu_empty_limit) {
+		rbf->rbf_monitor = false;
+		rbf->rbf_empty = 0;
+	}
+
+	spin_unlock(&rbf->rbf_lock);
+
+	if (rbf->rbf_monitor)
+		call_rcu(&rbf->rbf_rcu, __rcu_bulk_free_monitor);
+}
+
+/* Main RCU function that is called to free RCU structures */
+static void
+__rcu_bulk_free(struct rcu_head *head, rcu_callback_t func, int cpu, bool lazy)
+{
+	unsigned long offset;
+	void *ptr;
+	struct rcu_bulk_free *rbf;
+	struct rcu_bulk_free_container *rbfc = NULL;
+
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
+	if (rbfc == NULL) {
+		if (rbf->rbf_cached_container == NULL) {
+			rbf->rbf_container =
+			    kmalloc(sizeof(struct rcu_bulk_free_container),
+			    GFP_ATOMIC);
+			rbf->rbf_container->rbfc_rbf = rbf;
+		} else {
+			rbf->rbf_container = rbf->rbf_cached_container;
+			rbf->rbf_container->rbfc_rbf = rbf;
+			cmpxchg(&rbf->rbf_cached_container,
+			    rbf->rbf_cached_container, NULL);
+		}
+
+		if (unlikely(rbf->rbf_container == NULL)) {
+
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
+		rbfc->rbfc_entries = 0;
+
+		if (rbf->rbf_list_head != NULL)
+			__rcu_bulk_schedule_list(rbf);
+	}
+
+	offset = (unsigned long)func;
+	ptr = (void *)head - offset;
+
+	rbfc->rbfc_data[rbfc->rbfc_entries++] = ptr;
+	if (rbfc->rbfc_entries == RCU_MAX_ACCUMULATE_SIZE) {
+
+		WRITE_ONCE(rbf->rbf_container, NULL);
+		spin_unlock_bh(&rbf->rbf_lock);
+		call_rcu(&rbfc->rbfc_rcu, __rcu_bulk_free_impl);
+		return;
+	}
+
+done:
+	if (!rbf->rbf_monitor) {
+
+		call_rcu(&rbf->rbf_rcu, __rcu_bulk_free_monitor);
+		rbf->rbf_monitor = true;
+	}
+
+	spin_unlock_bh(&rbf->rbf_lock);
+}
+
+/*
+ * Queue an RCU callback for lazy invocation after a grace period.
+ * This will likely be later named something like "call_rcu_lazy()",
+ * but this change will require some way of tagging the lazy RCU
+ * callbacks in the list of pending callbacks. Until then, this
+ * function may only be called from __kfree_rcu().
+ */
+void kfree_call_rcu(struct rcu_head *head, rcu_callback_t func)
+{
+	__rcu_bulk_free(head, func, -1, 1);
+}
+EXPORT_SYMBOL_GPL(kfree_call_rcu);
+
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
