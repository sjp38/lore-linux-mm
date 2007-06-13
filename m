Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5DJJPU7030492
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 15:19:25 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5DJJNLa263218
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 13:19:25 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5DJJM1h025857
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 13:19:23 -0600
Date: Wed, 13 Jun 2007 12:19:08 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH v4][RFC] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20070613191908.GR3798@us.ibm.com>
References: <20070612001542.GJ14458@us.ibm.com> <20070612034407.GB11773@holomorphy.com> <20070612050910.GU3798@us.ibm.com> <20070612051512.GC11773@holomorphy.com> <20070612174503.GB3798@us.ibm.com> <20070612191347.GE11781@holomorphy.com> <20070613000446.GL3798@us.ibm.com> <20070613152649.GN3798@us.ibm.com> <20070613152847.GO3798@us.ibm.com> <1181759027.6148.77.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1181759027.6148.77.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.06.2007 [14:23:47 -0400], Lee Schermerhorn wrote:
> On Wed, 2007-06-13 at 08:28 -0700, Nishanth Aravamudan wrote:
> <snip>
> > 
> > commit 05a7edb8c909c674cdefb0323348825cf3e2d1d0
> > Author: Nishanth Aravamudan <nacc@us.ibm.com>
> > Date:   Thu Jun 7 08:54:48 2007 -0700
> > 
> > hugetlb: add per-node nr_hugepages sysfs attribute
> > 
> > Allow specifying the number of hugepages to allocate on a particular
> > node. Our current global sysctl will try its best to put hugepages
> > equally on each node, but htat may not always be desired. This allows
> > the admin to control the layout of hugepage allocation at a finer level
> > (while not breaking the existing interface). Add callbacks in the sysfs
> > node registration and unregistration functions into hugetlb to add the
> > nr_hugepages attribute, which is a no-op if !NUMA or !HUGETLB.
> > 
> > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > Cc: William Lee Irwin III <wli@holomorphy.com>
> > Cc: Christoph Lameter <clameter@sgi.com>
> > Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > Cc: Anton Blanchard <anton@sambar.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > 
> > ---
> > Do the dummy function definitions need to be (void)0?
> > 
> 
> <snip>
> 
> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > index aa0dc9b..e9f5928 100644
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -5,6 +5,7 @@
> >  
> >  #include <linux/mempolicy.h>
> >  #include <linux/shm.h>
> > +#include <linux/sysdev.h>
> >  #include <asm/tlbflush.h>
> >  
> >  struct ctl_table;
> > @@ -23,6 +24,11 @@ void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned lon
> >  int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
> >  int hugetlb_report_meminfo(char *);
> >  int hugetlb_report_node_meminfo(int, char *);
> > +int hugetlb_register_node(struct sys_device *);
> > +void hugetlb_unregister_node(struct sys_device *);
> 
> The parameter type for the two functions above need to be "struct
> node".  You'll need to include <linux/node.h> after <linux/sysdev.h>,
> as well.  Otherwise, doesn't build.

Sigh... Actually a few fixes worth doing. Make stuff static, since it's
now all in hugetlb.c and only compile if NUMA. And don't export the
nr_hugepages functions any more via hugetlb.h, as they are now private.

Compile-tested with HUGETLB && NUMA, HUGETLB && !NUMA, !HUGETLB && NUMA,
!HUGETLB && !NUMA.

Will throw it at the machines I ran the previous set on, to verify
everything runs as expected, but for review:


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
index aa0dc9b..7872031 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -4,7 +4,9 @@
 #ifdef CONFIG_HUGETLB_PAGE
 
 #include <linux/mempolicy.h>
+#include <linux/node.h>
 #include <linux/shm.h>
+#include <linux/sysdev.h>
 #include <asm/tlbflush.h>
 
 struct ctl_table;
@@ -23,6 +25,13 @@ void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned lon
 int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 int hugetlb_report_meminfo(char *);
 int hugetlb_report_node_meminfo(int, char *);
+#ifdef CONFIG_NUMA
+int hugetlb_register_node(struct node *);
+void hugetlb_unregister_node(struct node *);
+#else
+#define hugetlb_register_node(node)		0
+#define hugetlb_unregister_node(node)		0
+#endif
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
@@ -114,6 +123,8 @@ static inline unsigned long hugetlb_total_pages(void)
 #define unmap_hugepage_range(vma, start, end)	BUG()
 #define hugetlb_report_meminfo(buf)		0
 #define hugetlb_report_node_meminfo(n, buf)	0
+#define hugetlb_register_node(node)		0
+#define hugetlb_unregister_node(node)		0
 #define follow_huge_pmd(mm, addr, pmd, write)	NULL
 #define prepare_hugepage_range(addr,len,pgoff)	(-EINVAL)
 #define pmd_huge(x)	0
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c4a966e..e6ba07d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -137,6 +137,9 @@ static int alloc_fresh_huge_page(struct mempolicy *policy)
 	nid = start_nid;
 
 	do {
+		/*
+		 * this allocation will fail for unpopulated nodes
+		 */
 		page = alloc_fresh_huge_page_node(nid);
 		nid = interleave_nodes(policy);
 	} while (!page && nid != start_nid);
@@ -217,7 +220,6 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 	return nr;
 }
 
-#ifdef CONFIG_SYSCTL
 static void update_and_free_page(int nid, struct page *page)
 {
 	int i;
@@ -270,6 +272,7 @@ static inline void try_to_free_low(unsigned long count)
 }
 #endif
 
+#ifdef CONFIG_SYSCTL
 static unsigned long set_max_huge_pages(unsigned long count)
 {
 	struct mempolicy *pol;
@@ -343,6 +346,67 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
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
