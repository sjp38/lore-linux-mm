Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BNEPp4021807
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:14:25 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BNDJag528210
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:13:19 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BNDJGi013564
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:13:19 -0400
Date: Mon, 11 Jun 2007 16:13:14 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH][RFC] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20070611231314.GF14458@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <20070611231149.GE14458@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070611231149.GE14458@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Applies to 2.6.22-rc4-mm2 with
add-populated_map-to-account-for-memoryless-nodes
fix-interleave-with-memoryless-nodes
fix-hugetlb-pool-allocation-with-empty-nodes
hugetlb-numafy-several-functions
applied.

Allow specifying the number of hugepages to allocate on a particular
node. Our current global sysctl will try its best to put hugepages
equally on each node, but htat may not always be desired. This allows
the admin to control the layout of hugepage allocation at a finer level
(while not breaking the existing interface).

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---

I would have liked to have avoided the #ifdef's in node.c, but I
couldn't figure out a simple way to conditionalize the
create_file/remove_file calls.

diff --git a/drivers/base/node.c b/drivers/base/node.c
index cae346e..fc0b4a1 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -131,6 +131,11 @@ static ssize_t node_read_distance(struct sys_device * dev, char * buf)
 }
 static SYSDEV_ATTR(distance, S_IRUGO, node_read_distance, NULL);
 
+#ifdef CONFIG_HUGETLB_PAGE
+static SYSDEV_ATTR(nr_hugepages, S_IRUGO | S_IWUSR,
+				hugetlb_read_nr_hugepages_node,
+				hugetlb_write_nr_hugepages_node);
+#endif
 
 /*
  * register_node - Setup a sysfs device for a node.
@@ -151,6 +156,9 @@ int register_node(struct node *node, int num, struct node *parent)
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+#ifdef CONFIG_HUGETLB_PAGE
+		sysdev_create_file(&node->sysdev, &attr_nr_hugepages);
+#endif
 	}
 	return error;
 }
@@ -168,6 +176,9 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_meminfo);
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
+#ifdef CONFIG_HUGETLB_PAGE
+	sysdev_remove_file(&node->sysdev, &attr_nr_hugepages);
+#endif
 
 	sysdev_unregister(&node->sysdev);
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index aa0dc9b..7df75c1 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -5,6 +5,7 @@
 
 #include <linux/mempolicy.h>
 #include <linux/shm.h>
+#include <linux/sysdev.h>
 #include <asm/tlbflush.h>
 
 struct ctl_table;
@@ -23,6 +24,9 @@ void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned lon
 int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 int hugetlb_report_meminfo(char *);
 int hugetlb_report_node_meminfo(int, char *);
+ssize_t hugetlb_read_nr_hugepages_node(struct sys_device *, char *);
+ssize_t hugetlb_write_nr_hugepages_node(struct sys_device *, const char *,
+					 size_t);
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d1e1063..9f1cb16 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -215,7 +215,6 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 	return nr;
 }
 
-#ifdef CONFIG_SYSCTL
 static void update_and_free_page(int nid, struct page *page)
 {
 	int i;
@@ -268,6 +267,7 @@ static inline void try_to_free_low(unsigned long count)
 }
 #endif
 
+#ifdef CONFIG_SYSCTL
 static unsigned long set_max_huge_pages(unsigned long count)
 {
 	while (count > nr_huge_pages) {
@@ -335,6 +335,58 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
 		nid, free_huge_pages_node[nid]);
 }
 
+ssize_t hugetlb_read_nr_hugepages_node(struct sys_device *dev,
+							char *buf)
+{
+	return sprintf(buf, "%u\n", nr_huge_pages_node[dev->id]);
+}
+
+ssize_t hugetlb_write_nr_hugepages_node(struct sys_device *dev,
+					const char *buf, size_t count)
+{
+	int nid = dev->id;
+	unsigned long target;
+	unsigned long free_on_other_nodes;
+	unsigned long nr_huge_pages_req = simple_strtoul(buf, NULL, 10);
+
+ 	/*
+	 * unpopulated nodes can return pages from other nodes for
+	 * THISNODE requests, so do a populated check and avoid
+	 * double-checking in the sysctl path
+ 	 */
+ 	if (!node_populated(nid))
+ 		return count;
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
 /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
 unsigned long hugetlb_total_pages(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
