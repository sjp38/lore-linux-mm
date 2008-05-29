Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4T6fnI5012123
	for <linux-mm@kvack.org>; Thu, 29 May 2008 02:41:49 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4T6dJPU158912
	for <linux-mm@kvack.org>; Thu, 29 May 2008 02:39:19 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4T6dI1s028773
	for <linux-mm@kvack.org>; Thu, 29 May 2008 02:39:19 -0400
Date: Wed, 28 May 2008 23:39:15 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 1/2] hugetlb: present information in sysfs
Message-ID: <20080529063915.GC11357@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.841211000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525143452.841211000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, greg@kroah.com
List-ID: <linux-mm.kvack.org>

While the procfs presentation of the hstate counters has tried to be as
backwards compatible as possible, I do not believe trying to maintain
all of the information in the same files is a good long-term plan. This
particularly matters for architectures that can support many hugepage
sizes (sparc64 might be one). Even with the three potential pagesizes on
power (64k, 16m and 16g), I found the proc interface to be a little
awkward.

Instead, migrate the information to sysfs in a new directory,
/sys/kernel/hugepages. Underneath that directory there will be a
directory per-supported hugepage size, e.g.:

/sys/kernel/hugepages/hugepages-64
/sys/kernel/hugepages/hugepages-16384
/sys/kernel/hugepages/hugepages-16777216

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

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
Nick, I tested this patch and the following one at this point the
series, that is between patches 7 and 8. This does require a few compile
fixes/patch modifications in the later parts of the series. If we decide
that 2/2 is undesirable, there will be fewer of those and 1/2 could also
apply at the end, with less work. I can send you that diff, if you'd
prefer.

Greg, I didn't hear back from you on the last posting of this patch. Not
intended as a complaint, just an indication of why I didn't make any
changes relative to that version. Does this seem like a reasonable
patch as far as using the sysfs API? I realize a follow-on patch will be
needed to updated Documentation/ABI.

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 36624f1..3fe461d 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -169,6 +169,7 @@ struct hstate {
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+	char name[32];
 };
 
 void __init hugetlb_add_hstate(unsigned order);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 080f17a..da7a4aa 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/sysfs.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -578,67 +579,6 @@ static void __init report_hugepages(void)
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
@@ -740,6 +680,229 @@ out:
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
+	int tmp, err;
+	unsigned long input;
+	struct hstate *h = kobj_to_hstate(kobj);
+
+	err = strict_strtoul(buf, 10, &input);
+	if (err)
+		return 0;
+
+	h->max_huge_pages = set_max_huge_pages(h, input, &tmp);
+	max_huge_pages[h - hstates] = h->max_huge_pages;
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
+	sysctl_overcommit_huge_pages[h - hstates] = h->nr_overcommit_huge_pages;
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
+	snprintf(h->name, 32, "hugepages-%lu", huge_page_size(h)/1024);
+	hugetlb_init_one_hstate(h);
+	parsed_hstate = h;
+}
+
+static int __init hugetlb_setup(char *s)
+{
+	unsigned long *mhp;
+
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

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
