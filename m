Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C06C36B0264
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d199so24183213wmd.0
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:32:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z19si10053834wmc.139.2016.10.23.21.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:32:30 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4Sxto026793
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:29 -0400
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2692jqfpns-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:29 -0400
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 10:02:25 +0530
Received: from d28relay08.in.ibm.com (d28relay08.in.ibm.com [9.184.220.159])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 8A6BDE0040
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:13 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay08.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4W28337290094
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:02 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4WKMs021021
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:22 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 7/8] mm: Add a new migration function migrate_virtual_range()
Date: Mon, 24 Oct 2016 10:01:56 +0530
In-Reply-To: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477283517-2504-8-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

This adds a new virtual address range based migration interface which
can migrate all the mapped pages from a virtual range of a process to
a destination node. This also exports this new function symbol.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/mempolicy.h |  7 ++++
 include/linux/migrate.h   |  3 ++
 mm/mempolicy.c            |  7 ++--
 mm/migrate.c              | 84 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 96 insertions(+), 5 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 09d4b70..f18c0ea 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -152,6 +152,9 @@ extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
 extern bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 				const nodemask_t *mask);
 extern unsigned int mempolicy_slab_node(void);
+extern int queue_pages_range(struct mm_struct *mm, unsigned long start,
+			unsigned long end, nodemask_t *nodes,
+			unsigned long flags, struct list_head *pagelist);
 
 extern enum zone_type policy_zone;
 
@@ -319,4 +322,8 @@ static inline void mpol_put_task_policy(struct task_struct *task)
 {
 }
 #endif /* CONFIG_NUMA */
+
+#define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
+#define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
+
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ae8d475..e2a1af5 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -49,6 +49,9 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
 		struct buffer_head *head, enum migrate_mode mode,
 		int extra_count);
+
+extern int migrate_virtual_range(int pid, unsigned long vaddr,
+				unsigned long size, int nid);
 #else
 
 static inline void putback_movable_pages(struct list_head *l) {}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index b983cea..aa8479b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -100,10 +100,6 @@
 
 #include "internal.h"
 
-/* Internal flags */
-#define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
-#define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
-
 static struct kmem_cache *policy_cache;
 static struct kmem_cache *sn_cache;
 
@@ -703,7 +699,7 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
  * @nodes and @flags,) it's isolated and queued to the pagelist which is
  * passed via @private.)
  */
-static int
+int
 queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		nodemask_t *nodes, unsigned long flags,
 		struct list_head *pagelist)
@@ -724,6 +720,7 @@ queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 
 	return walk_page_range(start, end, &queue_pages_walk);
 }
+EXPORT_SYMBOL(queue_pages_range);
 
 /*
  * Apply policy to a single VMA
diff --git a/mm/migrate.c b/mm/migrate.c
index 99250ae..06300bb 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1367,6 +1367,90 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	return rc;
 }
 
+static struct page *new_node_page(struct page *page,
+		unsigned long node, int **x)
+{
+	return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE
+					| __GFP_THISNODE, 0);
+}
+
+#ifdef COHERENT_DEVICE
+static void mark_vma_cdm(struct vm_area_struct *vma)
+{
+	vma->vm_flags |= VM_CDM;
+}
+#else
+static void mark_vma_cdm(struct vm_area_struct *vma) {}
+#endif
+
+/*
+ * migrate_virtual_range - migrate all the pages faulted within a virtual
+ *			address range to a specified node.
+ *
+ * @pid:		PID of the task
+ * @start:		Virtual address range beginning
+ * @end:		Virtual address range end
+ * @nid:		Target migration node
+ *
+ * The function first scans the process VMA list to find out the VMA which
+ * contains the given virtual range. Then validates that the virtual range
+ * is within the given VMA's limits.
+ *
+ * Returns the number of pages that were not migrated or an error code.
+ */
+int migrate_virtual_range(int pid, unsigned long start,
+			unsigned long end, int nid)
+{
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	nodemask_t nmask;
+	int ret = -EINVAL;
+
+	LIST_HEAD(mlist);
+
+	nodes_clear(nmask);
+	nodes_setall(nmask);
+
+	if ((!start) || (!end))
+		return -EINVAL;
+
+	rcu_read_lock();
+	mm = find_task_by_vpid(pid)->mm;
+	rcu_read_unlock();
+
+	start &= PAGE_MASK;
+	end &= PAGE_MASK;
+	down_write(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if  ((start < vma->vm_start) || (end > vma->vm_end))
+			continue;
+
+		ret = queue_pages_range(mm, start, end, &nmask, MPOL_MF_MOVE_ALL
+						| MPOL_MF_DISCONTIG_OK, &mlist);
+		if (ret) {
+			putback_movable_pages(&mlist);
+			break;
+		}
+
+		if (list_empty(&mlist)) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		ret = migrate_pages(&mlist, new_node_page, NULL, nid,
+					MIGRATE_SYNC, MR_COMPACTION);
+		if (ret) {
+			putback_movable_pages(&mlist);
+		} else {
+			if (isolated_cdm_node(nid))
+				mark_vma_cdm(vma);
+		}
+	}
+	up_write(&mm->mmap_sem);
+	return ret;
+}
+EXPORT_SYMBOL(migrate_virtual_range);
+
 #ifdef CONFIG_NUMA
 /*
  * Move a list of individual pages
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
