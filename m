Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 26FFF6B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 14:24:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x78so1663576pff.7
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 11:24:40 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTPS id e78si34950pfk.415.2017.09.18.11.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 11:24:38 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 2/2] mm: oom: show unreclaimable slab info when kernel panic
Date: Tue, 19 Sep 2017 02:23:58 +0800
Message-Id: <1505759038-101668-2-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1505759038-101668-1-git-send-email-yang.s@alibaba-inc.com>
References: <1505759038-101668-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Kernel may panic when oom happens without killable process sometimes it
is caused by huge unreclaimable slabs used by kernel.

Altough kdump could help debug such problem, however, kdump is not
available on all architectures and it might be malfunction sometime.
And, since kernel already panic it is worthy capturing such information
in dmesg to aid touble shooting.

Add a field in struct slibinfo to show if this slab is reclaimable or
not, and a helper function to achieve the value from
SLAB_RECLAIM_ACCOUNT flag.

Print out unreclaimable slab info which actual memory usage is not zero
(num_objs * size != 0) when panic_on_oom is set or no killable process.
Since such information is just showed when kernel panic, so it will not
lead too verbose message for normal oom.

The output looks like:

rpc_buffers 31KB
rpc_tasks 31KB
avtab_node 46735KB
xfs_buf 624KB
xfs_ili 48KB
xfs_efi_item 31KB
xfs_efd_item 31KB
xfs_buf_item 78KB
xfs_log_item_desc 141KB
xfs_trans 108KB
xfs_ifork 744KB
xfs_trans 108KB
xfs_ifork 744KB
xfs_da_state 126KB

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 mm/oom_kill.c    | 13 +++++++++++--
 mm/slab.c        |  1 +
 mm/slab.h        |  7 +++++++
 mm/slab_common.c | 30 ++++++++++++++++++++++++++++++
 mm/slub.c        |  1 +
 5 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 99736e0..173c423 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -43,6 +43,7 @@
 
 #include <asm/tlb.h>
 #include "internal.h"
+#include "slab.h"
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
@@ -427,6 +428,14 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 		dump_tasks(oc->memcg, oc->nodemask);
 }
 
+static void dump_header_with_slabinfo(struct oom_control *oc, struct task_struct *p)
+{
+	dump_header(oc, p);
+
+	if (IS_ENABLED(CONFIG_SLABINFO))
+		show_unreclaimable_slab();
+}
+
 /*
  * Number of OOM victims in flight
  */
@@ -959,7 +968,7 @@ static void check_panic_on_oom(struct oom_control *oc,
 	/* Do not panic for oom kills triggered by sysrq */
 	if (is_sysrq_oom(oc))
 		return;
-	dump_header(oc, NULL);
+	dump_header_with_slabinfo(oc, NULL);
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
 }
@@ -1043,7 +1052,7 @@ bool out_of_memory(struct oom_control *oc)
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
-		dump_header(oc, NULL);
+		dump_header_with_slabinfo(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
 	if (oc->chosen && oc->chosen != (void *)-1UL) {
diff --git a/mm/slab.c b/mm/slab.c
index 04dec48..4f4971c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4132,6 +4132,7 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 	sinfo->shared = cachep->shared;
 	sinfo->objects_per_slab = cachep->num;
 	sinfo->cache_order = cachep->gfporder;
+	sinfo->reclaim = is_reclaimable(cachep);
 }
 
 void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *cachep)
diff --git a/mm/slab.h b/mm/slab.h
index 0733628..2f1ebce 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -186,6 +186,7 @@ struct slabinfo {
 	unsigned int shared;
 	unsigned int objects_per_slab;
 	unsigned int cache_order;
+	unsigned int reclaim;
 };
 
 void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo);
@@ -352,6 +353,11 @@ static inline void memcg_link_cache(struct kmem_cache *s)
 
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
+static inline bool is_reclaimable(struct kmem_cache *s)
+{
+	return (s->flags & SLAB_RECLAIM_ACCOUNT) ? true : false;
+}
+
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
 	struct kmem_cache *cachep;
@@ -504,6 +510,7 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 void *memcg_slab_next(struct seq_file *m, void *p, loff_t *pos);
 void memcg_slab_stop(struct seq_file *m, void *p);
 int memcg_slab_show(struct seq_file *m, void *p);
+void show_unreclaimable_slab(void);
 
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 904a83b..665baf2 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -35,6 +35,8 @@
 static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
 		    slab_caches_to_rcu_destroy_workfn);
 
+#define K(x) ((x)/1024)
+
 /*
  * Set of flags that will prevent slab merging
  */
@@ -1272,6 +1274,34 @@ static int slab_show(struct seq_file *m, void *p)
 	return 0;
 }
 
+void show_unreclaimable_slab()
+{
+	struct kmem_cache *s = NULL;
+	struct slabinfo sinfo;
+
+	memset(&sinfo, 0, sizeof(sinfo));
+
+	printk("Unreclaimable slabs:\n");
+
+	/*
+	 * Here acquiring slab_mutex is unnecessary since we don't prefer to
+	 * get sleep in oom path right before kernel panic, and avoid race condition.
+	 * Since it is already oom, so there should be not any big allocation
+	 * which could change the statistics significantly.
+	 */
+	list_for_each_entry(s, &slab_caches, list) {
+		if (!is_root_cache(s))
+			continue;
+
+		get_slabinfo(s, &sinfo);
+
+		if (!is_reclaimable(s) && sinfo.num_objs > 0)
+			printk("%-17s %luKB\n", cache_name(s), K(sinfo.num_objs * s->size));
+	}
+}
+EXPORT_SYMBOL(show_unreclaimable_slab);
+#undef K
+
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 void *memcg_slab_start(struct seq_file *m, loff_t *pos)
 {
diff --git a/mm/slub.c b/mm/slub.c
index 163352c..5c17c0a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5872,6 +5872,7 @@ void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
 	sinfo->num_slabs = nr_slabs;
 	sinfo->objects_per_slab = oo_objects(s->oo);
 	sinfo->cache_order = oo_order(s->oo);
+	sinfo->reclaim = is_reclaimable(s);
 }
 
 void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *s)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
