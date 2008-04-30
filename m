Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3UJJhVY001977
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 15:19:43 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3UJJhkQ259064
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 15:19:43 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3UJJgKt017986
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 15:19:42 -0400
Date: Wed, 30 Apr 2008 12:19:41 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
	[Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs
	ABI]
Message-ID: <20080430191941.GC8597@us.ibm.com>
References: <20080423183252.GA10548@us.ibm.com> <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com> <20080427051029.GA22858@suse.de> <20080428172239.GA24169@us.ibm.com> <20080428172951.GA764@suse.de> <20080429171115.GD24967@us.ibm.com> <20080429172243.GA16176@suse.de> <20080429181415.GF24967@us.ibm.com> <20080429182613.GA17373@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080429182613.GA17373@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.04.2008 [11:26:13 -0700], Greg KH wrote:
> On Tue, Apr 29, 2008 at 11:14:15AM -0700, Nishanth Aravamudan wrote:
> > On 29.04.2008 [10:22:43 -0700], Greg KH wrote:
> > > On Tue, Apr 29, 2008 at 10:11:15AM -0700, Nishanth Aravamudan wrote:
> > > > +struct hstate_attribute {
> > > > +	struct attribute attr;
> > > > +	ssize_t (*show)(struct hstate *h, char *buf);
> > > > +	ssize_t (*store)(struct hstate *h, const char *buf, size_t count);
> > > > +};
> > > 
> > > Do you need your own attribute type with show and store?  Can't you just
> > > use the "default" kobject attributes?
> > 
> > Hrm, I don't know? Probably. Like I said, I was using the
> > /sys/kernel/slab code as my reference. Can you explain this more? Or
> > just point me to the source/documentation I should read for info.
> 
> Documentation/kobject.txt, with sample examples in samples/kobject/ for
> you to copy and use.
> 
> > Are you referring to kobj_attr_show/kobj_attr_store? Should I just be
> > using kobj_sysfs_ops, then, most likely?
> 
> See the above examples for more details.
> 
> > > Also, you have no release function for your kobject to be cleaned up,
> > > that's a major bug.
> > 
> > Well, these kobjects never go away? They will be statically initialized
> > at boot-time and then stick around until the kernel goes away. Looking
> > at /sys/kernel/slab's code, again, the release() function there does a
> > kfree() on the containing kmem_cache, but for hugetlb, the hstates are
> > static... If we do move to dynamic allocations ever (or allow adding
> > hugepage sizes at run-time somehow), then perhaps we'll need a release
> > method then?
> 
> Yes you will.  Please always create one, what happens when you want to
> clean them up at shut-down time...

Does this look better? I really appreciate the review, Greg.

 include/linux/hugetlb.h |    9 +-
 mm/hugetlb.c            |  292 +++++++++++++++++++++++++++++++++++------------
 2 files changed, 226 insertions(+), 75 deletions(-)

Still-not-Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 7aa22e7..cac63bd 100644
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
@@ -131,6 +130,8 @@ struct hstate {
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+	const char *name;
+	struct kobject kobj;
 };
 
 void __init huge_add_hstate(unsigned order);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index de03a14..8a40afa 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -15,6 +15,7 @@
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
 #include <linux/bootmem.h>
+#include <linux/sysfs.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -624,6 +625,8 @@ static void __init hugetlb_init_hstate(struct hstate *h)
 			break;
 	}
 	h->max_huge_pages = i;
+	h->name = kasprintf(GFP_KERNEL, "hugepages-%lu",
+						huge_page_size(h) / 1024);
 }
 
 static void __init hugetlb_init_hstates(void)
@@ -662,77 +665,6 @@ static void __init report_hugepages(void)
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
-	BUG_ON(order < HPAGE_SHIFT - PAGE_SHIFT);
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
@@ -843,6 +775,224 @@ out:
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
+static ssize_t nr_hugepages_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct hstate *h = container_of(kobj, struct hstate, kobj);
+	return sprintf(buf, "%lu\n", h->nr_huge_pages);
+}
+static ssize_t nr_hugepages_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	int tmp, err;
+	unsigned long input;
+	struct hstate *h = container_of(kobj, struct hstate, kobj);
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
+	struct hstate *h = container_of(kobj, struct hstate, kobj);
+	return sprintf(buf, "%lu\n", h->nr_overcommit_huge_pages);
+}
+static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	int err;
+	unsigned long input;
+	struct hstate *h = container_of(kobj, struct hstate, kobj);
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
+	struct hstate *h = container_of(kobj, struct hstate, kobj);
+	return sprintf(buf, "%lu\n", h->free_huge_pages);
+}
+HSTATE_ATTR_RO(free_hugepages);
+
+static ssize_t resv_hugepages_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct hstate *h = container_of(kobj, struct hstate, kobj);
+	return sprintf(buf, "%lu\n", h->resv_huge_pages);
+}
+HSTATE_ATTR_RO(resv_hugepages);
+
+static ssize_t surplus_hugepages_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct hstate *h = container_of(kobj, struct hstate, kobj);
+	return sprintf(buf, "%lu\n", h->surplus_huge_pages);
+}
+HSTATE_ATTR_RO(surplus_hugepages);
+
+static void hstate_release(struct kobject *kobj)
+{
+	struct hstate *h = container_of(kobj, struct hstate, kobj);
+	kfree(h->name);
+}
+
+static struct kset *hstate_kset;
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
+static struct kobj_type hstate_ktype = {
+	.sysfs_ops = &kobj_sysfs_ops,
+	.default_attrs = hstate_attrs,
+	.release = hstate_release,
+};
+
+static int __init hugetlb_sysfs_add_hstate(struct hstate *h)
+{
+	int retval;
+
+	h->kobj.kset = hstate_kset;
+
+	retval = kobject_init_and_add(&h->kobj, &hstate_ktype, NULL, h->name);
+	if (retval) {
+		kfree(h->name);
+		return retval;
+	}
+
+	kobject_uevent(&h->kobj, KOBJ_ADD);
+
+	return 0;
+}
+
+static void __init hugetlb_sysfs_init(void)
+{
+	struct hstate *h;
+	int err;
+
+	hstate_kset = kset_create_and_add("hugepages", NULL, kernel_kobj);
+	if (!hstate_kset)
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
+/* Should be called on processing a hugepagesz=... option */
+void __init huge_add_hstate(unsigned order)
+{
+	struct hstate *h;
+	if (size_to_hstate(PAGE_SIZE << order)) {
+		printk("hugepagesz= specified twice, ignoring\n");
+		return;
+	}
+	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
+	BUG_ON(order < HPAGE_SHIFT - PAGE_SHIFT);
+	h = &hstates[max_hstate++];
+	h->order = order;
+	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
