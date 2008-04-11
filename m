Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3BNl5iY000898
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 19:47:05 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3BNl5hV222644
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:47:05 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3BNl4Kt009873
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:47:04 -0600
Date: Fri, 11 Apr 2008 16:47:12 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 2/5] hugetlb: numafy several functions
Message-ID: <20080411234712.GF19078@us.ibm.com>
References: <20080411234449.GE19078@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080411234449.GE19078@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: clameter@sgi.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Allow specifying the number of hugepages to allocate on a particular
node. Our current global sysctl will try its best to put hugepages
equally on each node, but htat may not always be desired. This allows
the admin to control the layout of hugepage allocation at a finer level
(while not breaking the existing interface).  Add callbacks in the sysfs
node registration and unregistration functions into hugetlb to add the
nr_hugepages attribute, which is a no-op if !NUMA or !HUGETLB.

This new interface requires some changes to the nr_hugepages sysctl as
well. We update max_huge_pages via a call to set_max_huge_pages() with
the value written into the nr_hugepages sysctl, even when only reading.
This is not very efficient. More importantly when nr_hugepages can be
altered by other interfaces (per-node sysfs attributes), this side
effect of reading can invoke set_max_huge_pages with a value less than
nr_hugepages, resulting in hugepages being freed! Rather than relying on
set_max_huge_pages() at all in the read-path, update max_huge_pages
(which is still the syctl variable) to the appropriate value on reads
(before invoking the generic sysctl handler) and call
set_max_huge_pages() on writes (after invoking the generic sysctl
handler).

Thanks to Dean Luick for finding some bugs in my previous posting of the
patch.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
Same patch as before, but an RFC this time to decide if
/sys/devices/system/node is where we want to be putting the pool
allocators. As discussed in a separate thread with Nick ("[patch 00/17]
multi size, and giatn hugetlb page support, 1GB hugetlb for x86" on
linux-mm), perhaps a better location would be /sys/kernel, but then we'd
need to replicate a bit of the NUMA layout into /sys/kernel. However,
the advantage would be when we put the multiple hugepage pool
allocation interfaces in /sys/kernel, all of the hugetlb related
interfaces will be in one place (as presumably we'll want per-node
control on a per-pool basis!).

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 4c2caff..96aa493 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -154,6 +154,7 @@ int register_node(struct node *node, int num, struct node *parent)
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+		hugetlb_register_node(node);
 	}
 	return error;
 }
@@ -171,6 +172,7 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_meminfo);
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
+	hugetlb_unregister_node(node);
 
 	sysdev_unregister(&node->sysdev);
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index a79e80b..ac8c8d9 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -6,7 +6,9 @@
 #ifdef CONFIG_HUGETLB_PAGE
 
 #include <linux/mempolicy.h>
+#include <linux/node.h>
 #include <linux/shm.h>
+#include <linux/sysdev.h>
 #include <asm/tlbflush.h>
 #include <asm/hugetlb.h>
 
@@ -27,6 +29,13 @@ void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned lon
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
@@ -70,6 +79,8 @@ static inline unsigned long hugetlb_total_pages(void)
 #define unmap_hugepage_range(vma, start, end)	BUG()
 #define hugetlb_report_meminfo(buf)		0
 #define hugetlb_report_node_meminfo(n, buf)	0
+#define hugetlb_register_node(node)		do {} while (0)
+#define hugetlb_unregister_node(node)		do {} while (0)
 #define follow_huge_pmd(mm, addr, pmd, write)	NULL
 #define prepare_hugepage_range(addr,len)	(-EINVAL)
 #define pmd_huge(x)	0
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8faaa16..d35b087 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -562,7 +562,6 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 	return nr;
 }
 
-#ifdef CONFIG_SYSCTL
 #ifdef CONFIG_HIGHMEM
 static void try_to_free_low_node(unsigned long count, int nid)
 {
@@ -578,7 +577,14 @@ static void try_to_free_low_node(unsigned long count, int nid)
 		free_huge_pages_node[nid]--;
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
@@ -590,18 +596,15 @@ static void try_to_free_low(unsigned long count)
 	}
 }
 #else
-static inline void try_to_free_low_node(unsigned long count, int nid)
-{
-}
 static inline void try_to_free_low(unsigned long count)
 {
 }
 #endif
 
 #define persistent_huge_pages (nr_huge_pages - surplus_huge_pages)
-static unsigned long set_max_huge_pages(unsigned long count)
+static void set_max_huge_pages(unsigned long count)
 {
-	unsigned long min_count, ret;
+	unsigned long min_count;
 
 	/*
 	 * Increase the pool size
@@ -664,17 +667,21 @@ static unsigned long set_max_huge_pages(unsigned long count)
 			break;
 	}
 out:
-	ret = persistent_huge_pages;
 	spin_unlock(&hugetlb_lock);
-	return ret;
 }
 
 int hugetlb_sysctl_handler(struct ctl_table *table, int write,
 			   struct file *file, void __user *buffer,
 			   size_t *length, loff_t *ppos)
 {
+	if (!write) {
+		spin_lock(&hugetlb_lock);
+		max_huge_pages = persistent_huge_pages;
+		spin_unlock(&hugetlb_lock);
+	}
 	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
-	max_huge_pages = set_max_huge_pages(max_huge_pages);
+	if (write)
+		set_max_huge_pages(max_huge_pages);
 	return 0;
 }
 
@@ -729,6 +736,115 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
 		nid, surplus_huge_pages_node[nid]);
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
+	spin_unlock(&hugetlb_lock);
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
