Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m16NNXnN015948
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 18:23:33 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m16NNX0f218474
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 16:23:33 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m16NNWrl003113
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 16:23:33 -0700
Date: Wed, 6 Feb 2008 15:23:31 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [UPDATED][PATCH 2/3] hugetlb: add per-node nr_hugepages sysfs
	attribute
Message-ID: <20080206232331.GL3477@us.ibm.com>
References: <20080206231558.GI3477@us.ibm.com> <20080206231845.GJ3477@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080206231845.GJ3477@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On 06.02.2008 [15:18:45 -0800], Nishanth Aravamudan wrote:
> hugetlb: add per-node nr_hugepages sysfs attribute

Sorry, a few checkpatch errors slipped through, fixed below.

hugetlb: add per-node nr_hugepages sysfs attribute

Allow specifying the number of hugepages to allocate on a particular
node. Our current global sysctl will try its best to put hugepages
equally on each node, but htat may not always be desired. This allows
the admin to control the layout of hugepage allocation at a finer level
(while not breaking the existing interface).  Add callbacks in the sysfs
node registration and unregistration functions into hugetlb to add the
nr_hugepages attribute, which is a no-op if !NUMA or !HUGETLB.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/drivers/base/node.c b/drivers/base/node.c
index e59861f..daf5b2b 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -152,6 +152,7 @@ int register_node(struct node *node, int num, struct node *parent)
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+		hugetlb_register_node(node);
 	}
 	return error;
 }
@@ -169,6 +170,7 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_meminfo);
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
+	hugetlb_unregister_node(node);
 
 	sysdev_unregister(&node->sysdev);
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 7ca198b..a4f7559 100644
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
@@ -26,6 +28,13 @@ void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned lon
 int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 int hugetlb_report_meminfo(char *);
 int hugetlb_report_node_meminfo(int, char *);
+#ifdef CONFIG_NUMA
+int hugetlb_register_node(struct node *);
+void hugetlb_unregister_node(struct node *);
+#else
+#define hugetlb_register_node(node)		do {} while (0)
+#define hugetlb_unregister_node(node)		do {} while (0)
+#endif
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
@@ -114,6 +123,8 @@ static inline unsigned long hugetlb_total_pages(void)
 #define unmap_hugepage_range(vma, start, end)	BUG()
 #define hugetlb_report_meminfo(buf)		0
 #define hugetlb_report_node_meminfo(n, buf)	0
+#define hugetlb_register_node(node)		do {} while (0)
+#define hugetlb_unregister_node(node)		do {} while (0)
 #define follow_huge_pmd(mm, addr, pmd, write)	NULL
 #define prepare_hugepage_range(addr,len)	(-EINVAL)
 #define pmd_huge(x)	0
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d1f6c5a..05dac46 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -497,7 +497,6 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 	return nr;
 }
 
-#ifdef CONFIG_SYSCTL
 #ifdef CONFIG_HIGHMEM
 static void try_to_free_low_node(unsigned long count, int nid)
 {
@@ -513,7 +512,14 @@ static void try_to_free_low_node(unsigned long count, int nid)
 			return;
 	}
 }
+#else
+static inline void try_to_free_low_node(unsigned long count, int nid)
+{
+}
+#endif
 
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_HIGHMEM
 static void try_to_free_low(unsigned long count)
 {
 	int i;
@@ -525,9 +531,6 @@ static void try_to_free_low(unsigned long count)
 	}
 }
 #else
-static inline void try_to_free_low_node(unsigned long count, int nid)
-{
-}
 static inline void try_to_free_low(unsigned long count)
 {
 }
@@ -661,6 +664,117 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
 		nid, free_huge_pages_node[nid]);
 }
 
+#ifdef CONFIG_NUMA
+static ssize_t hugetlb_read_nr_hugepages_node(struct sys_device *dev,
+							char *buf)
+{
+	return sprintf(buf, "%u\n", nr_huge_pages_node[dev->id]);
+}
+
+#define persistent_huge_pages_node(nid)	\
+		(nr_huge_pages_node[nid] - surplus_huge_pages_node[nid])
+static ssize_t hugetlb_write_nr_hugepages_node(struct sys_device *dev,
+					const char *buf, size_t count)
+{
+	int nid = dev->id;
+	unsigned long target;
+	unsigned long free_on_other_nodes;
+	unsigned long nr_huge_pages_req = simple_strtoul(buf, NULL, 10);
+	ssize_t ret;
+
+	/*
+	 * Increase the pool size on the node
+	 * First take pages out of surplus state.  Then make up the
+	 * remaining difference by allocating fresh huge pages.
+	 *
+	 * We might race with alloc_buddy_huge_page() here and be unable
+	 * to convert a surplus huge page to a normal huge page. That is
+	 * not critical, though, it just means the overall size of the
+	 * pool might be one hugepage larger than it needs to be, but
+	 * within all the constraints specified by the sysctls.
+	 */
+	spin_lock(&hugetlb_lock);
+	while (surplus_huge_pages_node[nid] &&
+		nr_huge_pages_req > persistent_huge_pages_node(nid)) {
+		if (!adjust_pool_surplus_node(-1, nid))
+			break;
+	}
+
+	while (nr_huge_pages_req > persistent_huge_pages_node(nid)) {
+		struct page *ret;
+		/*
+		 * If this allocation races such that we no longer need the
+		 * page, free_huge_page will handle it by freeing the page
+		 * and reducing the surplus.
+		 */
+		spin_unlock(&hugetlb_lock);
+		ret = alloc_fresh_huge_page_node(nid);
+		spin_lock(&hugetlb_lock);
+		if (!ret)
+			goto out;
+
+	}
+
+	if (nr_huge_pages_req >= nr_huge_pages_node[nid])
+		goto out;
+
+	/*
+	 * Decrease the pool size
+	 * First return free pages to the buddy allocator (being careful
+	 * to keep enough around to satisfy reservations).  Then place
+	 * pages into surplus state as needed so the pool will shrink
+	 * to the desired size as pages become free.
+	 *
+	 * By placing pages into the surplus state independent of the
+	 * overcommit value, we are allowing the surplus pool size to
+	 * exceed overcommit. There are few sane options here. Since
+	 * alloc_buddy_huge_page() is checking the global counter,
+	 * though, we'll note that we're not allowed to exceed surplus
+	 * and won't grow the pool anywhere else. Not until one of the
+	 * sysctls are changed, or the surplus pages go out of use.
+	 */
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
+	while (target < persistent_huge_pages_node(nid)) {
+		struct page *page = dequeue_huge_page_node(NULL, nid);
+		if (!page)
+			break;
+		update_and_free_page(nid, page);
+	}
+
+	while (target < persistent_huge_pages_node(nid)) {
+		if (!adjust_pool_surplus_node(1, nid))
+			break;
+	}
+out:
+	ret = persistent_huge_pages_node(nid);
+	spin_unlock(&hugetlb_lock);
+	return ret;
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
+#endif
+
 /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
 unsigned long hugetlb_total_pages(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
