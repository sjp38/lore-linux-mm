Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 624686B0253
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 16:52:44 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q75so11901193pfl.1
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 13:52:44 -0700 (PDT)
Received: from out0-199.mail.aliyun.com (out0-199.mail.aliyun.com. [140.205.0.199])
        by mx.google.com with ESMTPS id c4si1574732pfg.151.2017.09.21.13.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 13:52:43 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 2/2] mm: oom: show unreclaimable slab info when kernel panic
Date: Fri, 22 Sep 2017 04:52:25 +0800
Message-Id: <1506027145-93950-3-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1506027145-93950-1-git-send-email-yang.s@alibaba-inc.com>
References: <1506027145-93950-1-git-send-email-yang.s@alibaba-inc.com>
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
actual memory usage is not zero (num_objs * size != 0) when panic_on_oom
is set or no killable process. Since such information is just showed when
kernel panic, so it will not lead too verbose message for normal oom.

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
 mm/oom_kill.c    |  3 +++
 mm/slab.h        |  8 ++++++++
 mm/slab_common.c | 29 +++++++++++++++++++++++++++++
 3 files changed, 40 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 99736e0..bd48d34 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -43,6 +43,7 @@
 
 #include <asm/tlb.h>
 #include "internal.h"
+#include "slab.h"
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
@@ -960,6 +961,7 @@ static void check_panic_on_oom(struct oom_control *oc,
 	if (is_sysrq_oom(oc))
 		return;
 	dump_header(oc, NULL);
+	dump_unreclaimable_slab();
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
 }
@@ -1044,6 +1046,7 @@ bool out_of_memory(struct oom_control *oc)
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
 		dump_header(oc, NULL);
+		dump_unreclaimable_slab();
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
index 904a83b..72331ae 100644
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
+			pr_info("%-17s %10luKB %10luKB\n", cache_name(s), \
+				(sinfo.active_objs * s->size) / 1024, \
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
