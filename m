Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l790qILi012327
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 20:52:18 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l790qIeO269834
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 18:52:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l790qHM6010607
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 18:52:18 -0600
Date: Wed, 8 Aug 2007 17:52:17 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 4/4] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20070809005217.GK16588@us.ibm.com>
References: <20070809004726.GH16588@us.ibm.com> <20070809004914.GI16588@us.ibm.com> <20070809005128.GJ16588@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070809005128.GJ16588@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: anton@samba.org, lee.schermerhorn@hp.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Allow specifying the number of hugepages to allocate on a particular
node. Our current global sysctl will try its best to put hugepages
equally on each node, but htat may not always be desired. This allows
the admin to control the layout of hugepage allocation at a finer level
(while not breaking the existing interface).  Add callbacks in the sysfs
node registration and unregistration functions into hugetlb to add the
nr_hugepages attribute, which is a no-op if !NUMA or !HUGETLB.

Tested on 4-node ppc64 (2 memoryless nodes), 2-node IA64, 4-node x86
(NUMAQ), !NUMA x86.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/drivers/base/node.c b/drivers/base/node.c
index cae346e..c9d531f 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -151,6 +151,7 @@ int register_node(struct node *node, int num, struct node *parent)
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+		hugetlb_register_node(node);
 	}
 	return error;
 }
@@ -168,6 +169,7 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_meminfo);
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
+	hugetlb_unregister_node(node);
 
 	sysdev_unregister(&node->sysdev);
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index e6a71c8..aad43e0 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -6,7 +6,9 @@
 #ifdef CONFIG_HUGETLB_PAGE
 
 #include <linux/mempolicy.h>
+#include <linux/node.h>
 #include <linux/shm.h>
+#include <linux/sysdev.h>
 #include <asm/tlbflush.h>
 
 struct ctl_table;
@@ -25,6 +27,13 @@ void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned lon
 int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 int hugetlb_report_meminfo(char *);
 int hugetlb_report_node_meminfo(int, char *);
+#ifdef CONFIG_NUMA
+int hugetlb_register_node(struct node *);
+void hugetlb_unregister_node(struct node *);
+#else
+#define hugetlb_register_node(node)		0
+#define hugetlb_unregister_node(node)		((void)0)
+#endif
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
@@ -116,6 +125,8 @@ static inline unsigned long hugetlb_total_pages(void)
 #define unmap_hugepage_range(vma, start, end)	BUG()
 #define hugetlb_report_meminfo(buf)		0
 #define hugetlb_report_node_meminfo(n, buf)	0
+#define hugetlb_register_node(node)		0
+#define hugetlb_unregister_node(node)		((void)0)
 #define follow_huge_pmd(mm, addr, pmd, write)	NULL
 #define prepare_hugepage_range(addr,len,pgoff)	(-EINVAL)
 #define pmd_huge(x)	0
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8139568..6e4311b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -261,12 +261,11 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 	return nr;
 }
 
-#ifdef CONFIG_SYSCTL
-static void update_and_free_page(struct page *page)
+static void update_and_free_page(int nid, struct page *page)
 {
 	int i;
 	nr_huge_pages--;
-	nr_huge_pages_node[page_to_nid(page)]--;
+	nr_huge_pages_node[nid]--;
 	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
 				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
@@ -278,30 +277,42 @@ static void update_and_free_page(struct page *page)
 }
 
 #ifdef CONFIG_HIGHMEM
+static void try_to_free_low_node(int nid, unsigned long count)
+{
+	struct page *page, *next;
+	list_for_each_entry_safe(page, next, &hugepage_freelists[nid], lru) {
+		if (PageHighMem(page))
+			continue;
+		list_del(&page->lru);
+		update_and_free_page(nid, page);
+		free_huge_pages--;
+		free_huge_pages_node[nid]--;
+		if (count >= nr_huge_pages_node[nid])
+			return;
+	}
+}
+
 static void try_to_free_low(unsigned long count)
 {
 	int i;
 
 	for (i = 0; i < MAX_NUMNODES; ++i) {
-		struct page *page, *next;
-		list_for_each_entry_safe(page, next, &hugepage_freelists[i], lru) {
-			if (PageHighMem(page))
-				continue;
-			list_del(&page->lru);
-			update_and_free_page(page);
-			free_huge_pages--;
-			free_huge_pages_node[page_to_nid(page)]--;
-			if (count >= nr_huge_pages)
-				return;
-		}
+		try_to_free_low_node(i, count);
+		if (count >= nr_huge_pages)
+			return;
 	}
 }
 #else
+static inline void try_to_free_low_node(int nid, unsigned long count)
+{
+}
+
 static inline void try_to_free_low(unsigned long count)
 {
 }
 #endif
 
+#ifdef CONFIG_SYSCTL
 static unsigned long set_max_huge_pages(unsigned long count)
 {
 	while (count > nr_huge_pages) {
@@ -318,7 +329,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 		struct page *page = dequeue_huge_page();
 		if (!page)
 			break;
-		update_and_free_page(page);
+		update_and_free_page(page_to_nid(page), page);
 	}
 	spin_unlock(&hugetlb_lock);
 	return nr_huge_pages;
@@ -369,6 +380,67 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
 		nid, free_huge_pages_node[nid]);
 }
 
+#ifdef CONFIG_NUMA
+static ssize_t hugetlb_read_nr_hugepages_node(struct sys_device *dev,
+							char *buf)
+{
+	return sprintf(buf, "%u\n", nr_huge_pages_node[dev->id]);
+}
+
+static ssize_t hugetlb_write_nr_hugepages_node(struct sys_device *dev,
+					const char *buf, size_t count)
+{
+	int nid = dev->id;
+	unsigned long target;
+	unsigned long free_on_other_nodes;
+	unsigned long nr_huge_pages_req = simple_strtoul(buf, NULL, 10);
+
+	while (nr_huge_pages_req > nr_huge_pages_node[nid]) {
+		if (!alloc_fresh_huge_page_node(nid))
+			return count;
+	}
+	if (nr_huge_pages_req >= nr_huge_pages_node[nid])
+		return count;
+
+	/* need to ensure that our counts are accurate */
+	spin_lock(&hugetlb_lock);
+	free_on_other_nodes = free_huge_pages - free_huge_pages_node[nid];
+	if (free_on_other_nodes >= resv_huge_pages) {
+		/* other nodes can satisfy reserve */
+		target = nr_huge_pages_req;
+	} else {
+		/* this node needs some free to satisfy reserve */
+		target = max((resv_huge_pages - free_on_other_nodes),
+						nr_huge_pages_req);
+	}
+	try_to_free_low_node(nid, target);
+	while (target < nr_huge_pages_node[nid]) {
+		struct page *page = dequeue_huge_page_node(nid);
+		if (!page)
+			break;
+		update_and_free_page(nid, page);
+	}
+	spin_unlock(&hugetlb_lock);
+
+	return count;
+}
+
+static SYSDEV_ATTR(nr_hugepages, S_IRUGO | S_IWUSR,
+			hugetlb_read_nr_hugepages_node,
+			hugetlb_write_nr_hugepages_node);
+
+int hugetlb_register_node(struct node *node)
+{
+	return sysdev_create_file(&node->sysdev, &attr_nr_hugepages);
+}
+
+void hugetlb_unregister_node(struct node *node)
+{
+	sysdev_remove_file(&node->sysdev, &attr_nr_hugepages);
+}
+
+#endif
+
 /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
 unsigned long hugetlb_total_pages(void)
 {
-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
