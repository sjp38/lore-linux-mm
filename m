Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABC796B025F
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 20:53:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a7so20264247pfj.3
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 17:53:48 -0700 (PDT)
Received: from out0-206.mail.aliyun.com (out0-206.mail.aliyun.com. [140.205.0.206])
        by mx.google.com with ESMTPS id 66si6540622plb.414.2017.09.26.17.53.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 17:53:47 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel panic
Date: Wed, 27 Sep 2017 08:53:35 +0800
Message-Id: <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
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
actual memory usage is not zero (num_objs * size != 0) when:
  - unreclaimable slabs : all user memory > unreclaim_slabs_oom_ratio
  - panic_on_oom is set or no killable process

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
 include/linux/oom.h         |  1 +
 include/uapi/linux/sysctl.h |  1 +
 kernel/sysctl.c             |  9 +++++++++
 kernel/sysctl_binary.c      |  1 +
 mm/oom_kill.c               | 31 +++++++++++++++++++++++++++++++
 mm/slab.h                   |  8 ++++++++
 mm/slab_common.c            | 29 +++++++++++++++++++++++++++++
 7 files changed, 80 insertions(+)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 76aac4c..a732c74 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -105,4 +105,5 @@ extern unsigned long oom_badness(struct task_struct *p,
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern int sysctl_unreclaim_slabs_oom_ratio;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
index e13d480..9c4155e 100644
--- a/include/uapi/linux/sysctl.h
+++ b/include/uapi/linux/sysctl.h
@@ -194,6 +194,7 @@ enum
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
+	VM_UNRECLAIM_SLABS_OOM_RATIO=36,/* Percent pages dumping unreclaimable slabs when oom */
 };
 
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6648fbb..81a93ee 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1266,6 +1266,15 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "unreclaim_slabs_oom_ratio",
+		.data		= &sysctl_unreclaim_slabs_oom_ratio,
+		.maxlen		= sizeof(sysctl_unreclaim_slabs_oom_ratio),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
+	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
 		.maxlen		= sizeof(sysctl_overcommit_ratio),
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 58ea8c0..23f1e18 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -170,6 +170,7 @@ struct bin_table {
 	{ CTL_INT,	VM_PANIC_ON_OOM,		"panic_on_oom" },
 	{ CTL_INT,	VM_VDSO_ENABLED,		"vdso_enabled" },
 	{ CTL_INT,	VM_MIN_SLAB,			"min_slab_ratio" },
+	{ CTL_INT,	VM_UNRECLAIM_SLABS_OOM_RATIO,	"unreclaim_slabs_oom_ratio" },
 
 	{}
 };
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 99736e0..6359edb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -43,6 +43,7 @@
 
 #include <asm/tlb.h>
 #include "internal.h"
+#include "slab.h"
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
@@ -50,6 +51,8 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+/* unreclaimable slabs is 50% of all LRU pages */
+int sysctl_unreclaim_slabs_oom_ratio = 50;
 
 DEFINE_MUTEX(oom_lock);
 
@@ -160,6 +163,30 @@ static bool oom_unkillable_task(struct task_struct *p,
 	return false;
 }
 
+/*
+ * Print out unreclaimble slabs info unconditionally when
+ * sysctl_unreclaim_slabs_oom_ratio is 0. Otherwise when
+ * unreclaimable slabs : all LRU pages > sysctl_unreclaim_slabs_oom_ratio.
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
+	if (sysctl_unreclaim_slabs_oom_ratio > 0)
+		return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) * 100 /
+			nr_lru) > (unsigned long)sysctl_unreclaim_slabs_oom_ratio;
+	else
+		return true;
+}
+
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
@@ -960,6 +987,8 @@ static void check_panic_on_oom(struct oom_control *oc,
 	if (is_sysrq_oom(oc))
 		return;
 	dump_header(oc, NULL);
+	if (is_dump_unreclaim_slabs())
+		dump_unreclaimable_slab();
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
 }
@@ -1044,6 +1073,8 @@ bool out_of_memory(struct oom_control *oc)
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
 		dump_header(oc, NULL);
+		if (is_dump_unreclaim_slabs())
+			dump_unreclaimable_slab();
 		panic("Out of memory and no killable processes...\n");
 	}
 	if (oc->chosen && oc->chosen != (void *)-1UL) {
diff --git a/mm/slab.h b/mm/slab.h
index 0733628..b0496d1 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -505,6 +505,14 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 void memcg_slab_stop(struct seq_file *m, void *p);
 int memcg_slab_show(struct seq_file *m, void *p);
 
+#ifdef CONFIG_SLABINFO
+void dump_unreclaimable_slab(void);
+#else
+static inline void dump_unreclaimable_slab(void)
+{
+}
+#endif
+
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
 
 #ifdef CONFIG_SLAB_FREELIST_RANDOM
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 904a83b..d08213d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1272,6 +1272,35 @@ static int slab_show(struct seq_file *m, void *p)
 	return 0;
 }
 
+void dump_unreclaimable_slab(void)
+{
+	struct kmem_cache *s, *s2;
+	struct slabinfo sinfo;
+
+	pr_info("Unreclaimable slab info:\n");
+	pr_info("Name                      Used          Total\n");
+
+	/*
+	 * Here acquiring slab_mutex is unnecessary since we don't prefer to
+	 * get sleep in oom path right before kernel panic, and avoid race
+	 * condition.
+	 * Since it is already oom, so there should be not any big allocation
+	 * which could change the statistics significantly.
+	 */
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
