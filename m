Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E92006B026E
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:25 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y68so16829407pfb.6
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 06:20:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 133si28632275pgh.245.2016.11.22.06.20.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 06:20:25 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAMEIrqL144834
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:24 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26vpp6p13u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:24 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 Nov 2016 00:20:21 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id F03EA2CE8057
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:19 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAMEKJvE33751276
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:19 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAMEKJcI016651
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:19 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 10/12] mm: Add a new migration function migrate_virtual_range()
Date: Tue, 22 Nov 2016 19:49:46 +0530
In-Reply-To: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1479824388-30446-11-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com

This adds a new virtual address range based migration interface which
can migrate all the mapped pages from a virtual range of a process to
a destination node. This also exports this new function symbol.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/mempolicy.h |  7 +++++
 include/linux/migrate.h   |  3 ++
 mm/mempolicy.c            |  7 ++---
 mm/migrate.c              | 71 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 83 insertions(+), 5 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 5e5b296..c2b4a18 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -152,6 +152,9 @@ extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 extern bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 				const nodemask_t *mask);
 extern unsigned int mempolicy_slab_node(void);
+extern int queue_pages_range(struct mm_struct *mm, unsigned long start,
+			unsigned long end, nodemask_t *nodes,
+			unsigned long flags, struct list_head *pagelist);
 
 extern enum zone_type policy_zone;
 
@@ -302,4 +305,8 @@ static inline void mpol_put_task_policy(struct task_struct *task)
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
index 0b859af..728347a 100644
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
 
@@ -662,7 +658,7 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
  * @nodes and @flags,) it's isolated and queued to the pagelist which is
  * passed via @private.)
  */
-static int
+int
 queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		nodemask_t *nodes, unsigned long flags,
 		struct list_head *pagelist)
@@ -683,6 +679,7 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 
 	return walk_page_range(start, end, &queue_pages_walk);
 }
+EXPORT_SYMBOL(queue_pages_range);
 
 /*
  * Apply policy to a single VMA
diff --git a/mm/migrate.c b/mm/migrate.c
index 99250ae..4f20415 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1367,6 +1367,77 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	return rc;
 }
 
+static struct page *new_node_page(struct page *page,
+		unsigned long node, int **x)
+{
+	return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE
+					| __GFP_THISNODE, 0);
+}
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
+		if (ret)
+			putback_movable_pages(&mlist);
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
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
