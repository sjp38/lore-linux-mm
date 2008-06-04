Message-Id: <20080604113111.647714612@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
Date: Wed, 04 Jun 2008 21:29:44 +1000
From: npiggin@suse.de
Subject: [patch 05/21] hugetlb: new sysfs interface
Content-Disposition: inline; filename=hugetlb-sysfs-reporting.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Provide new hugepages user APIs that are more suited to multiple hstates in
sysfs. There is a new directory, /sys/kernel/hugepages. Underneath that
directory there will be a directory per-supported hugepage size, e.g.:

/sys/kernel/hugepages/hugepages-64kB
/sys/kernel/hugepages/hugepages-16384kB
/sys/kernel/hugepages/hugepages-16777216kB

corresponding to 64k, 16m and 16g respectively. Within each
hugepages-size directory there are a number of files, corresponding to
the tracked counters in the hstate, e.g.:

/sys/kernel/hugepages/hugepages-64/nr_hugepages
/sys/kernel/hugepages/hugepages-64/nr_overcommit_hugepages
/sys/kernel/hugepages/hugepages-64/free_hugepages
/sys/kernel/hugepages/hugepages-64/resv_hugepages
/sys/kernel/hugepages/hugepages-64/surplus_hugepages

Of these files, the first two are read-write and the latter three are
read-only. The size of the hugepage being manipulated is trivially
deducible from the enclosing directory and is always expressed in kB (to
match meminfo).

Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>

---
Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h	2008-06-04 20:51:19.000000000 +1000
+++ linux-2.6/include/linux/hugetlb.h	2008-06-04 20:51:20.000000000 +1000
@@ -164,6 +164,7 @@ unsigned long hugetlb_get_unmapped_area(
 
 #ifdef CONFIG_HUGETLB_PAGE
 
+#define HSTATE_NAME_LEN 32
 /* Defines one hugetlb page size */
 struct hstate {
 	int hugetlb_next_nid;
@@ -179,6 +180,7 @@ struct hstate {
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+	char name[HSTATE_NAME_LEN];
 };
 
 void __init hugetlb_add_hstate(unsigned order);
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-06-04 20:51:19.000000000 +1000
+++ linux-2.6/mm/hugetlb.c	2008-06-04 20:51:20.000000000 +1000
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/sysfs.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -867,72 +868,6 @@ static void __init report_hugepages(void
 	}
 }
 
-static int __init hugetlb_init(void)
-{
-	BUILD_BUG_ON(HPAGE_SHIFT == 0);
-
-	if (!size_to_hstate(HPAGE_SIZE)) {
-		hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
-		parsed_hstate->max_huge_pages = default_hstate_max_huge_pages;
-	}
-	default_hstate_idx = size_to_hstate(HPAGE_SIZE) - hstates;
-
-	hugetlb_init_hstates();
-
-	report_hugepages();
-
-	return 0;
-}
-module_init(hugetlb_init);
-
-/* Should be called on processing a hugepagesz=... option */
-void __init hugetlb_add_hstate(unsigned order)
-{
-	struct hstate *h;
-	if (size_to_hstate(PAGE_SIZE << order)) {
-		printk(KERN_WARNING "hugepagesz= specified twice, ignoring\n");
-		return;
-	}
-	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
-	BUG_ON(order == 0);
-	h = &hstates[max_hstate++];
-	h->order = order;
-	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
-	hugetlb_init_one_hstate(h);
-	parsed_hstate = h;
-}
-
-static int __init hugetlb_setup(char *s)
-{
-	unsigned long *mhp;
-
-	/*
-	 * !max_hstate means we haven't parsed a hugepagesz= parameter yet,
-	 * so this hugepages= parameter goes to the "default hstate".
-	 */
-	if (!max_hstate)
-		mhp = &default_hstate_max_huge_pages;
-	else
-		mhp = &parsed_hstate->max_huge_pages;
-
-	if (sscanf(s, "%lu", mhp) <= 0)
-		*mhp = 0;
-
-	return 1;
-}
-__setup("hugepages=", hugetlb_setup);
-
-static unsigned int cpuset_mems_nr(unsigned int *array)
-{
-	int node;
-	unsigned int nr = 0;
-
-	for_each_node_mask(node, cpuset_current_mems_allowed)
-		nr += array[node];
-
-	return nr;
-}
-
 #ifdef CONFIG_SYSCTL
 #ifdef CONFIG_HIGHMEM
 static void try_to_free_low(struct hstate *h, unsigned long count)
@@ -1030,6 +965,233 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_SYSFS
+#define HSTATE_ATTR_RO(_name) \
+	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
+
+#define HSTATE_ATTR(_name) \
+	static struct kobj_attribute _name##_attr = \
+		__ATTR(_name, 0644, _name##_show, _name##_store)
+
+static struct kobject *hugepages_kobj;
+static struct kobject *hstate_kobjs[HUGE_MAX_HSTATE];
+
+static struct hstate *kobj_to_hstate(struct kobject *kobj)
+{
+	int i;
+	for (i = 0; i < HUGE_MAX_HSTATE; i++)
+		if (hstate_kobjs[i] == kobj)
+			return &hstates[i];
+	BUG();
+	return NULL;
+}
+
+static ssize_t nr_hugepages_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct hstate *h = kobj_to_hstate(kobj);
+	return sprintf(buf, "%lu\n", h->nr_huge_pages);
+}
+static ssize_t nr_hugepages_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	int err;
+	unsigned long input;
+	struct hstate *h = kobj_to_hstate(kobj);
+
+	err = strict_strtoul(buf, 10, &input);
+	if (err)
+		return 0;
+
+	h->max_huge_pages = set_max_huge_pages(h, input);
+
+	return count;
+}
+HSTATE_ATTR(nr_hugepages);
+
+static ssize_t nr_overcommit_hugepages_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct hstate *h = kobj_to_hstate(kobj);
+	return sprintf(buf, "%lu\n", h->nr_overcommit_huge_pages);
+}
+static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	int err;
+	unsigned long input;
+	struct hstate *h = kobj_to_hstate(kobj);
+
+	err = strict_strtoul(buf, 10, &input);
+	if (err)
+		return 0;
+
+	spin_lock(&hugetlb_lock);
+	h->nr_overcommit_huge_pages = input;
+	spin_unlock(&hugetlb_lock);
+
+	return count;
+}
+HSTATE_ATTR(nr_overcommit_hugepages);
+
+static ssize_t free_hugepages_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct hstate *h = kobj_to_hstate(kobj);
+	return sprintf(buf, "%lu\n", h->free_huge_pages);
+}
+HSTATE_ATTR_RO(free_hugepages);
+
+static ssize_t resv_hugepages_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct hstate *h = kobj_to_hstate(kobj);
+	return sprintf(buf, "%lu\n", h->resv_huge_pages);
+}
+HSTATE_ATTR_RO(resv_hugepages);
+
+static ssize_t surplus_hugepages_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct hstate *h = kobj_to_hstate(kobj);
+	return sprintf(buf, "%lu\n", h->surplus_huge_pages);
+}
+HSTATE_ATTR_RO(surplus_hugepages);
+
+static struct attribute *hstate_attrs[] = {
+	&nr_hugepages_attr.attr,
+	&nr_overcommit_hugepages_attr.attr,
+	&free_hugepages_attr.attr,
+	&resv_hugepages_attr.attr,
+	&surplus_hugepages_attr.attr,
+	NULL,
+};
+
+static struct attribute_group hstate_attr_group = {
+	.attrs = hstate_attrs,
+};
+
+static int __init hugetlb_sysfs_add_hstate(struct hstate *h)
+{
+	int retval;
+
+	hstate_kobjs[h - hstates] = kobject_create_and_add(h->name,
+							hugepages_kobj);
+	if (!hstate_kobjs[h - hstates])
+		return -ENOMEM;
+
+	retval = sysfs_create_group(hstate_kobjs[h - hstates],
+							&hstate_attr_group);
+	if (retval)
+		kobject_put(hstate_kobjs[h - hstates]);
+
+	return retval;
+}
+
+static void __init hugetlb_sysfs_init(void)
+{
+	struct hstate *h;
+	int err;
+
+	hugepages_kobj = kobject_create_and_add("hugepages", kernel_kobj);
+	if (!hugepages_kobj)
+		return;
+
+	for_each_hstate(h) {
+		err = hugetlb_sysfs_add_hstate(h);
+		if (err)
+			printk(KERN_ERR "Hugetlb: Unable to add hstate %s",
+								h->name);
+	}
+}
+#else
+static void __init hugetlb_sysfs_init(void)
+{
+}
+#endif
+
+static int __init hugetlb_init(void)
+{
+	BUILD_BUG_ON(HPAGE_SHIFT == 0);
+
+	if (!size_to_hstate(HPAGE_SIZE)) {
+		hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
+		parsed_hstate->max_huge_pages = default_hstate_max_huge_pages;
+	}
+	default_hstate_idx = size_to_hstate(HPAGE_SIZE) - hstates;
+
+	hugetlb_init_hstates();
+
+	report_hugepages();
+
+	hugetlb_sysfs_init();
+
+	return 0;
+}
+module_init(hugetlb_init);
+
+static void __exit hugetlb_exit(void)
+{
+	struct hstate *h;
+
+	for_each_hstate(h) {
+		kobject_put(hstate_kobjs[h - hstates]);
+	}
+
+	kobject_put(hugepages_kobj);
+}
+module_exit(hugetlb_exit);
+
+/* Should be called on processing a hugepagesz=... option */
+void __init hugetlb_add_hstate(unsigned order)
+{
+	struct hstate *h;
+	if (size_to_hstate(PAGE_SIZE << order)) {
+		printk(KERN_WARNING "hugepagesz= specified twice, ignoring\n");
+		return;
+	}
+	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
+	BUG_ON(order == 0);
+	h = &hstates[max_hstate++];
+	h->order = order;
+	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
+	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
+					huge_page_size(h)/1024);
+	hugetlb_init_one_hstate(h);
+	parsed_hstate = h;
+}
+
+static int __init hugetlb_setup(char *s)
+{
+	unsigned long *mhp;
+
+	/*
+	 * !max_hstate means we haven't parsed a hugepagesz= parameter yet,
+	 * so this hugepages= parameter goes to the "default hstate".
+	 */
+	if (!max_hstate)
+		mhp = &default_hstate_max_huge_pages;
+	else
+		mhp = &parsed_hstate->max_huge_pages;
+
+	if (sscanf(s, "%lu", mhp) <= 0)
+		*mhp = 0;
+
+	return 1;
+}
+__setup("hugepages=", hugetlb_setup);
+
+static unsigned int cpuset_mems_nr(unsigned int *array)
+{
+	int node;
+	unsigned int nr = 0;
+
+	for_each_node_mask(node, cpuset_current_mems_allowed)
+		nr += array[node];
+
+	return nr;
+}
+
 int hugetlb_sysctl_handler(struct ctl_table *table, int write,
 			   struct file *file, void __user *buffer,
 			   size_t *length, loff_t *ppos)
Index: linux-2.6/Documentation/ABI/testing/sysfs-kernel-hugepages
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/Documentation/ABI/testing/sysfs-kernel-hugepages	2008-06-04 20:51:20.000000000 +1000
@@ -0,0 +1,14 @@
+What:		/sys/kernel/hugepages/
+Date:		June 2008
+Contact:	Nishanth Aravamudan <nacc@us.ibm.com>, hugetlb maintainers
+Description:
+		/sys/kernel/hugepages/ contains a number of subdirectories
+		of the form hugepages-<size>kb, where <size> is the page size
+		of the hugepages supported by the kernel/CPU combination.
+
+		Under these directories are a number of files:
+		nr_hugepages - minimum number of hugepages reserved
+		nr_overcommit_hugepages - maximum number that can be allocated
+		free_hugepages - number of hugepages free
+		surplus_hugepages -
+		resv_hugepages -

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
