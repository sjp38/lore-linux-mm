Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m42HwP3J016983
	for <linux-mm@kvack.org>; Fri, 2 May 2008 13:58:25 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m42HwPF3201362
	for <linux-mm@kvack.org>; Fri, 2 May 2008 11:58:25 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m42HwOwN019705
	for <linux-mm@kvack.org>; Fri, 2 May 2008 11:58:25 -0600
Date: Fri, 2 May 2008 10:58:22 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
	[Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs
	ABI]
Message-ID: <20080502175822.GA9418@us.ibm.com>
References: <20080427034942.GB12129@us.ibm.com> <20080427051029.GA22858@suse.de> <20080428172239.GA24169@us.ibm.com> <20080428172951.GA764@suse.de> <20080429171115.GD24967@us.ibm.com> <20080429172243.GA16176@suse.de> <20080429181415.GF24967@us.ibm.com> <20080429182613.GA17373@suse.de> <20080430191941.GC8597@us.ibm.com> <20080501030844.GB4911@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080501030844.GB4911@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.04.2008 [20:08:44 -0700], Greg KH wrote:
> On Wed, Apr 30, 2008 at 12:19:41PM -0700, Nishanth Aravamudan wrote:
> > On 29.04.2008 [11:26:13 -0700], Greg KH wrote:
> > > On Tue, Apr 29, 2008 at 11:14:15AM -0700, Nishanth Aravamudan wrote:
> > > > On 29.04.2008 [10:22:43 -0700], Greg KH wrote:
> > > > > On Tue, Apr 29, 2008 at 10:11:15AM -0700, Nishanth Aravamudan wrote:
> > > > > > +struct hstate_attribute {
> > > > > > +	struct attribute attr;
> > > > > > +	ssize_t (*show)(struct hstate *h, char *buf);
> > > > > > +	ssize_t (*store)(struct hstate *h, const char *buf, size_t count);
> > > > > > +};
> > > > > 
> > > > > Do you need your own attribute type with show and store?  Can't you just
> > > > > use the "default" kobject attributes?
> > > > 
> > > > Hrm, I don't know? Probably. Like I said, I was using the
> > > > /sys/kernel/slab code as my reference. Can you explain this more? Or
> > > > just point me to the source/documentation I should read for info.
> > > 
> > > Documentation/kobject.txt, with sample examples in samples/kobject/ for
> > > you to copy and use.
> > > 
> > > > Are you referring to kobj_attr_show/kobj_attr_store? Should I just be
> > > > using kobj_sysfs_ops, then, most likely?
> > > 
> > > See the above examples for more details.
> > > 
> > > > > Also, you have no release function for your kobject to be cleaned up,
> > > > > that's a major bug.
> > > > 
> > > > Well, these kobjects never go away? They will be statically initialized
> > > > at boot-time and then stick around until the kernel goes away. Looking
> > > > at /sys/kernel/slab's code, again, the release() function there does a
> > > > kfree() on the containing kmem_cache, but for hugetlb, the hstates are
> > > > static... If we do move to dynamic allocations ever (or allow adding
> > > > hugepage sizes at run-time somehow), then perhaps we'll need a release
> > > > method then?
> > > 
> > > Yes you will.  Please always create one, what happens when you want to
> > > clean them up at shut-down time...
> > 
> > Does this look better? I really appreciate the review, Greg.
> 
> See my previous email, you should not embed a kobject into this
> structure.  Just use a pointer to one, it will shrink this patch a lot.

Ok, I did that -- and the patch grew (due to adding a helper
function to figure out which hstate a kobject corresponds to?). I'm
sure I'm doing something stupid.

FWIW, this patch does work with Jon's efforts and shows 64k/16m/16g at
run-time, all correct and such.

commit 164d446024a76b9d785b11141e1b53b330f6ce4d
Author: Nishanth Aravamudan <nacc@us.ibm.com>
Date:   Fri Apr 25 15:34:58 2008 -0700

    hugetlb: present information in sysfs
    
    Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 4fe8d16..4898f32 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -3,6 +3,9 @@
 
 #include <linux/fs.h>
 #include <linux/shm.h>
+#include <linux/mempolicy.h>
+#include <asm/tlbflush.h>
+#include <asm/hugetlb.h>
 
 #ifdef CONFIG_HUGETLBFS
 struct hugetlbfs_config {
@@ -69,10 +72,6 @@ static inline void set_file_hugepages(struct file *file)
 
 #ifdef CONFIG_HUGETLB_PAGE
 
-#include <linux/mempolicy.h>
-#include <asm/tlbflush.h>
-#include <asm/hugetlb.h>
-
 struct ctl_table;
 
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
@@ -132,6 +131,7 @@ struct hstate {
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+	char name[32];
 };
 
 struct huge_bm_page {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bd07510..c87eeca 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -15,6 +15,7 @@
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
 #include <linux/bootmem.h>
+#include <linux/sysfs.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -659,76 +660,6 @@ static void __init report_hugepages(void)
         }
 }
 
-static int __init hugetlb_init(void)
-{
-	BUILD_BUG_ON(HPAGE_SHIFT == 0);
-
-	if (!size_to_hstate(HPAGE_SIZE)) {
-		huge_add_hstate(HUGETLB_PAGE_ORDER);
-		parsed_hstate->max_huge_pages = default_hstate_resv;
-	}
-
-	hugetlb_init_hstates();
-
-	gather_bootmem_prealloc();
-
-	report_hugepages();
-
-	return 0;
-}
-module_init(hugetlb_init);
-
-/* Should be called on processing a hugepagesz=... option */
-void __init huge_add_hstate(unsigned order)
-{
-	struct hstate *h;
-	if (size_to_hstate(PAGE_SIZE << order)) {
-		printk("hugepagesz= specified twice, ignoring\n");
-		return;
-	}
-	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
-	h = &hstates[max_hstate++];
-	h->order = order;
-	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
-	hugetlb_init_hstate(h);
-	parsed_hstate = h;
-}
-
-static int __init hugetlb_setup(char *s)
-{
-	unsigned long *mhp;
-
-	if (!max_hstate)
-		mhp = &default_hstate_resv;
-	else
-		mhp = &parsed_hstate->max_huge_pages;
-
-	if (sscanf(s, "%lu", mhp) <= 0)
-		*mhp = 0;
-
-	/*
-	 * Global state is always initialized later in hugetlb_init.
-	 * But we need to allocate >= MAX_ORDER hstates here early to still
-	 * use the bootmem allocator.
-	 */
-	if (max_hstate > 0 && parsed_hstate->order >= MAX_ORDER)
-		hugetlb_init_hstate(parsed_hstate);
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
@@ -839,6 +770,236 @@ out:
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
+	hstate_kobjs[h - hstates] = kobject_create_and_add(h->name, hugepages_kobj);
+	if (!hstate_kobjs[h - hstates])
+		return -ENOMEM;
+
+	retval = sysfs_create_group(hstate_kobjs[h - hstates], &hstate_attr_group);
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
+		huge_add_hstate(HUGETLB_PAGE_ORDER);
+		parsed_hstate->max_huge_pages = default_hstate_resv;
+	}
+
+	hugetlb_init_hstates();
+
+	gather_bootmem_prealloc();
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
+	for_each_hstate(h)
+		kobject_put(hstate_kobjs[h - hstates]);
+
+	kobject_put(hugepages_kobj);
+}
+module_exit(hugetlb_exit);
+
+/* Should be called on processing a hugepagesz=... option */
+void __init huge_add_hstate(unsigned order)
+{
+	struct hstate *h;
+	if (size_to_hstate(PAGE_SIZE << order)) {
+		printk("hugepagesz= specified twice, ignoring\n");
+		return;
+	}
+	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
+	h = &hstates[max_hstate++];
+	h->order = order;
+	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
+	snprintf(h->name, 32, "hugepages-%lu", huge_page_size(h)/1024);
+	hugetlb_init_hstate(h);
+	parsed_hstate = h;
+}
+
+static int __init hugetlb_setup(char *s)
+{
+	unsigned long *mhp;
+
+	if (!max_hstate)
+		mhp = &default_hstate_resv;
+	else
+		mhp = &parsed_hstate->max_huge_pages;
+
+	if (sscanf(s, "%lu", mhp) <= 0)
+		*mhp = 0;
+
+	/*
+	 * Global state is always initialized later in hugetlb_init.
+	 * But we need to allocate >= MAX_ORDER hstates here early to still
+	 * use the bootmem allocator.
+	 */
+	if (max_hstate > 0 && parsed_hstate->order >= MAX_ORDER)
+		hugetlb_init_hstate(parsed_hstate);
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
