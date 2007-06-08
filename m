Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l58JBCbG006143
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 15:11:12 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l58JB8mU249096
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 13:11:10 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l58JB7Rn022759
	for <linux-mm@kvack.org>; Fri, 8 Jun 2007 13:11:08 -0600
Date: Fri, 8 Jun 2007 12:10:59 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH][3/3] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20070608191059.GE8017@us.ibm.com>
References: <20070608190620.GB8017@us.ibm.com> <20070608190738.GC8017@us.ibm.com> <20070608190857.GD8017@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070608190857.GD8017@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linuxfoundation.org, lee.schermerhorn@hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.06.2007 [12:08:57 -0700], Nishanth Aravamudan wrote:
> hugetlb: add per-node nr_hugepages sysfs attribute

Sorry, meant to send the non-gitified version of the patch...

hugetlb: add per-node nr_hugepages sysfs attribute

Rebased against 2.6.22-rc4-mm2 with:
fix-hugetlb-pool-allocation-with-empty-nodes-v5.patch
hugetlb-numafy-several-functions

Allow specifying the number of hugepages to allocate on a particular
node. Our current global sysctl will try its best to put hugepages
equally on each node, but htat may not always be desired. This allows
the admin to control the layout of hugepage allocation at a finer level
(while not breaking the existing interface).

Note: this requires making the same sort of check in the sysfs write
callback as in the normal allocation path, for populated nodes.

Tested on non-NUMA x86, non-NUMA ppc64, 2-node IA64, 4-node x86_64 and
4-node ppc64 with 2 unpopulated nodes.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---

I would have liked to have avoided the #ifdef's in node.c, but I
couldn't figure out a simple way to conditionalize the
create_file/remove_file calls.

diff a/drivers/base/node.c b/drivers/base/node.c
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
diff a/include/linux/hugetlb.h b/include/linux/hugetlb.h
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
diff a/mm/hugetlb.c b/mm/hugetlb.c
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
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
