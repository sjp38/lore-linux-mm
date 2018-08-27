Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59B386B4166
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 12:27:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m9-v6so1456725eds.17
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 09:27:17 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k19-v6si3130155edq.27.2018.08.27.09.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 09:27:15 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 1/3] mm: rework memcg kernel stack accounting
Date: Mon, 27 Aug 2018 09:26:19 -0700
Message-ID: <20180827162621.30187-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

If CONFIG_VMAP_STACK is set, kernel stacks are allocated
using __vmalloc_node_range() with __GFP_ACCOUNT. So kernel
stack pages are charged against corresponding memory cgroups
on allocation and uncharged on releasing them.

The problem is that we do cache kernel stacks in small
per-cpu caches and do reuse them for new tasks, which can
belong to different memory cgroups.

Each stack page still holds a reference to the original cgroup,
so the cgroup can't be released until the vmap area is released.

To make this happen we need more than two subsequent exits
without forks in between on the current cpu, which makes it
very unlikely to happen. As a result, I saw a significant number
of dying cgroups (in theory, up to 2 * number_of_cpu +
number_of_tasks), which can't be released even by significant
memory pressure.

As a cgroup structure can take a significant amount of memory
(first of all, per-cpu data like memcg statistics), it leads
to a noticeable waste of memory.

Fixes: ac496bf48d97 ("fork: Optimize task creation by caching
two thread stacks per CPU if CONFIG_VMAP_STACK=y")
Signed-off-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h | 13 ++++++++-
 kernel/fork.c              | 55 +++++++++++++++++++++++++++++++++-----
 2 files changed, 61 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 652f602167df..4399cc3f00e4 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1268,10 +1268,11 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
 void memcg_kmem_put_cache(struct kmem_cache *cachep);
 int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 			    struct mem_cgroup *memcg);
+
+#ifdef CONFIG_MEMCG_KMEM
 int memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
 void memcg_kmem_uncharge(struct page *page, int order);
 
-#ifdef CONFIG_MEMCG_KMEM
 extern struct static_key_false memcg_kmem_enabled_key;
 extern struct workqueue_struct *memcg_kmem_cache_wq;
 
@@ -1307,6 +1308,16 @@ extern int memcg_expand_shrinker_maps(int new_id);
 extern void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
 				   int nid, int shrinker_id);
 #else
+
+static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
+{
+	return 0;
+}
+
+static inline void memcg_kmem_uncharge(struct page *page, int order)
+{
+}
+
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 6ad26f6ef456..c0fb8d00f3cb 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -224,9 +224,14 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 		return s->addr;
 	}
 
+	/*
+	 * Allocated stacks are cached and later reused by new threads,
+	 * so memcg accounting is performed manually on assigning/releasing
+	 * stacks to tasks. Drop __GFP_ACCOUNT.
+	 */
 	stack = __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
 				     VMALLOC_START, VMALLOC_END,
-				     THREADINFO_GFP,
+				     THREADINFO_GFP & ~__GFP_ACCOUNT,
 				     PAGE_KERNEL,
 				     0, node, __builtin_return_address(0));
 
@@ -249,9 +254,19 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 static inline void free_thread_stack(struct task_struct *tsk)
 {
 #ifdef CONFIG_VMAP_STACK
-	if (task_stack_vm_area(tsk)) {
+	struct vm_struct *vm = task_stack_vm_area(tsk);
+
+	if (vm) {
 		int i;
 
+		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
+			mod_memcg_page_state(vm->pages[i],
+					     MEMCG_KERNEL_STACK_KB,
+					     -(int)(PAGE_SIZE / 1024));
+
+			memcg_kmem_uncharge(vm->pages[i], 0);
+		}
+
 		for (i = 0; i < NR_CACHED_STACKS; i++) {
 			if (this_cpu_cmpxchg(cached_stacks[i],
 					NULL, tsk->stack_vm_area) != NULL)
@@ -352,10 +367,6 @@ static void account_kernel_stack(struct task_struct *tsk, int account)
 					    NR_KERNEL_STACK_KB,
 					    PAGE_SIZE / 1024 * account);
 		}
-
-		/* All stack pages belong to the same memcg. */
-		mod_memcg_page_state(vm->pages[0], MEMCG_KERNEL_STACK_KB,
-				     account * (THREAD_SIZE / 1024));
 	} else {
 		/*
 		 * All stack pages are in the same zone and belong to the
@@ -371,6 +382,35 @@ static void account_kernel_stack(struct task_struct *tsk, int account)
 	}
 }
 
+static int memcg_charge_kernel_stack(struct task_struct *tsk)
+{
+#ifdef CONFIG_VMAP_STACK
+	struct vm_struct *vm = task_stack_vm_area(tsk);
+	int ret;
+
+	if (vm) {
+		int i;
+
+		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
+			/*
+			 * If memcg_kmem_charge() fails, page->mem_cgroup
+			 * pointer is NULL, and both memcg_kmem_uncharge()
+			 * and mod_memcg_page_state() in free_thread_stack()
+			 * will ignore this page. So it's safe.
+			 */
+			ret = memcg_kmem_charge(vm->pages[i], GFP_KERNEL, 0);
+			if (ret)
+				return ret;
+
+			mod_memcg_page_state(vm->pages[i],
+					     MEMCG_KERNEL_STACK_KB,
+					     PAGE_SIZE / 1024);
+		}
+	}
+#endif
+	return 0;
+}
+
 static void release_task_stack(struct task_struct *tsk)
 {
 	if (WARN_ON(tsk->state != TASK_DEAD))
@@ -808,6 +848,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	if (!stack)
 		goto free_tsk;
 
+	if (memcg_charge_kernel_stack(tsk))
+		goto free_stack;
+
 	stack_vm_area = task_stack_vm_area(tsk);
 
 	err = arch_dup_task_struct(tsk, orig);
-- 
2.17.1
