Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4GMW18R030344
	for <linux-mm@kvack.org>; Wed, 16 May 2007 18:32:01 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GNXrIG543016
	for <linux-mm@kvack.org>; Wed, 16 May 2007 19:33:53 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GNXrHs016865
	for <linux-mm@kvack.org>; Wed, 16 May 2007 19:33:53 -0400
Date: Wed, 16 May 2007 16:33:52 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 3/3] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20070516233352.GP20535@us.ibm.com>
References: <20070516233053.GN20535@us.ibm.com> <20070516233155.GO20535@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070516233155.GO20535@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: Lee.Schermerhorn@hp.com, anton@samba.org, clameter@sgi.com, akpm@linux-foundation.org, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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
index cae346e..42c17fc 100644
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
@@ -168,7 +176,9 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_meminfo);
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
+#ifdef CONFIG_HUGETLB_PAGE
+	sysdev_remove_file(&node->sysdev, &attr_nr_hugepages);
+#endif

 	sysdev_unregister(&node->sysdev);
 }
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index b4570b6..cd21086 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -5,6 +5,7 @@
 
 #include <linux/mempolicy.h>
 #include <linux/shm.h>
+#include <linux/sysdev.h>
 #include <asm/tlbflush.h>
 
 struct ctl_table;
@@ -22,6 +23,8 @@ void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned lon
 int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 int hugetlb_report_meminfo(char *);
 int hugetlb_report_node_meminfo(int, char *);
+ssize_t hugetlb_read_nr_hugepages_node(struct sys_device *, char *);
+ssize_t hugetlb_write_nr_hugepages_node(struct sys_device *, const char *, size_t);
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 51f412e..9e79624 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -207,7 +207,6 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 	return nr;
 }
 
-#ifdef CONFIG_SYSCTL
 static void update_and_free_page(int nid, struct page *page)
 {
 	int i;
@@ -260,6 +259,7 @@ static inline void try_to_free_low(unsigned long count)
 }
 #endif
 
+#ifdef CONFIG_SYSCTL
 static unsigned long set_max_huge_pages(unsigned long count)
 {
 	while (count > nr_huge_pages) {
@@ -314,6 +314,50 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
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
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
