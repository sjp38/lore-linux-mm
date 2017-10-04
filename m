Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E42C56B0260
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 17:29:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l188so15051756pfc.7
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 14:29:22 -0700 (PDT)
Received: from out0-241.mail.aliyun.com (out0-241.mail.aliyun.com. [140.205.0.241])
        by mx.google.com with ESMTPS id t9si6746170pfl.418.2017.10.04.14.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 14:29:21 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 3/3] mm: oom: show unreclaimable slab info when unreclaimable slabs > user memory
Date: Thu, 05 Oct 2017 05:29:10 +0800
Message-Id: <1507152550-46205-4-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1507152550-46205-1-git-send-email-yang.s@alibaba-inc.com>
References: <1507152550-46205-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Kernel may panic when oom happens without killable process sometimes it
is caused by huge unreclaimable slabs used by kernel.

Although kdump could help debug such problem, however, kdump is not
available on all architectures and it might be malfunction sometime.
And, since kernel already panic it is worthy capturing such information
in dmesg to aid touble shooting.

Print out unreclaimable slab info (used size and total size) which
actual memory usage is not zero (num_objs * size != 0) when
unreclaimable slabs amount is greater than total user memory (LRU
pages).

The output looks like:

Unreclaimable slab info:
Name                      Used          Total
rpc_buffers               31KB         31KB
rpc_tasks                  7KB          7KB
ebitmap_node            1964KB       1964KB
avtab_node              5024KB       5024KB
xfs_buf                 1402KB       1402KB
xfs_ili                  134KB        134KB
xfs_efi_item             115KB        115KB
xfs_efd_item             115KB        115KB
xfs_buf_item             134KB        134KB
xfs_log_item_desc        342KB        342KB
xfs_trans               1412KB       1412KB
xfs_ifork                212KB        212KB

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 mm/oom_kill.c    | 27 +++++++++++++++++++++++++--
 mm/slab.h        |  2 ++
 mm/slab_common.c | 35 +++++++++++++++++++++++++++++++++++
 3 files changed, 62 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dee0f75..3023919 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -44,6 +44,7 @@
 
 #include <asm/tlb.h>
 #include "internal.h"
+#include "slab.h"
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
@@ -161,6 +162,25 @@ static bool oom_unkillable_task(struct task_struct *p,
 	return false;
 }
 
+/*
+ * Print out unreclaimble slabs info when unreclaimable slabs amount is greater
+ * than all user memory (LRU pages)
+ */
+static bool is_dump_unreclaim_slabs(void)
+{
+	unsigned long nr_lru;
+
+	nr_lru = global_node_page_state(NR_ACTIVE_ANON) +
+		 global_node_page_state(NR_INACTIVE_ANON) +
+		 global_node_page_state(NR_ACTIVE_FILE) +
+		 global_node_page_state(NR_INACTIVE_FILE) +
+		 global_node_page_state(NR_ISOLATED_ANON) +
+		 global_node_page_state(NR_ISOLATED_FILE) +
+		 global_node_page_state(NR_UNEVICTABLE);
+
+	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
+}
+
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
@@ -420,10 +440,13 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 
 	cpuset_print_current_mems_allowed();
 	dump_stack();
-	if (oc->memcg)
+	if (is_memcg_oom(oc))
 		mem_cgroup_print_oom_info(oc->memcg, p);
-	else
+	else {
 		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
+		if (is_dump_unreclaim_slabs())
+			dump_unreclaimable_slab();
+	}
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(oc->memcg, oc->nodemask);
 }
diff --git a/mm/slab.h b/mm/slab.h
index 0733628..6fc4d5d 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -505,6 +505,8 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 void memcg_slab_stop(struct seq_file *m, void *p);
 int memcg_slab_show(struct seq_file *m, void *p);
 
+void dump_unreclaimable_slab(void);
+
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
 
 #ifdef CONFIG_SLAB_FREELIST_RANDOM
diff --git a/mm/slab_common.c b/mm/slab_common.c
index c1629cb..5c8fac5 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1278,6 +1278,41 @@ static int slab_show(struct seq_file *m, void *p)
 	return 0;
 }
 
+void dump_unreclaimable_slab(void)
+{
+	struct kmem_cache *s, *s2;
+	struct slabinfo sinfo;
+
+	/*
+	 * Here acquiring slab_mutex is risky since we don't prefer to get
+	 * sleep in oom path. But, without mutex hold, it may introduce a
+	 * risk of crash.
+	 * Use mutex_trylock to protect the list traverse, dump nothing
+	 * without acquiring the mutex.
+	 */
+	if (!mutex_trylock(&slab_mutex)) {
+		pr_warn("excessive unreclaimable slab but cannot dump stats\n");
+		return;
+	}
+
+	pr_info("Unreclaimable slab info:\n");
+	pr_info("Name                      Used          Total\n");
+
+	list_for_each_entry_safe(s, s2, &slab_caches, list) {
+		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
+			continue;
+
+		memset(&sinfo, 0, sizeof(sinfo));
+		get_slabinfo(s, &sinfo);
+
+		if (sinfo.num_objs > 0)
+			pr_info("%-17s %10luKB %10luKB\n", cache_name(s),
+				(sinfo.active_objs * s->size) / 1024,
+				(sinfo.num_objs * s->size) / 1024);
+	}
+	mutex_unlock(&slab_mutex);
+}
+
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 void *memcg_slab_start(struct seq_file *m, loff_t *pos)
 {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
