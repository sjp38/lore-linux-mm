Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3R3o35O020601
	for <linux-mm@kvack.org>; Sat, 26 Apr 2008 23:50:03 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3R3o3uw158750
	for <linux-mm@kvack.org>; Sat, 26 Apr 2008 23:50:03 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3R3nqWF002964
	for <linux-mm@kvack.org>; Sat, 26 Apr 2008 23:49:53 -0400
Date: Sat, 26 Apr 2008 20:49:42 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH] hugetlb: add information and interface in sysfs [Was
	Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI]
Message-ID: <20080427034942.GB12129@us.ibm.com>
References: <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com> <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com> <20080423010259.GA17572@wotan.suse.de> <20080423183252.GA10548@us.ibm.com> <20080424071352.GB14543@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080424071352.GB14543@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Greg KH <gregkh@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 24.04.2008 [09:13:52 +0200], Nick Piggin wrote:
> On Wed, Apr 23, 2008 at 11:32:52AM -0700, Nishanth Aravamudan wrote:
> > 
> > So, I think, we pretty much agree on how things should be:
> > 
> > Direct translation of the current sysctl:
> > 
> > /sys/kernel/hugepages/nr_hugepages
> >                       nr_overcommit_hugepages
> > 
> > Adding multiple pools:
> > 
> > /sys/kernel/hugepages/nr_hugepages -> nr_hugepages_${default_size}
> >                       nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
> >                       nr_hugepages_${default_size}
> >                       nr_overcommit_hugepages_${default_size}
> >                       nr_hugepages_${other_size1}
> >                       nr_overcommit_hugepages_${other_size2}
> > 
> > Adding per-node control:
> > 
> > /sys/kernel/hugepages/nr_hugepages -> nr_hugepages_${default_size}
> >                       nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
> >                       nr_hugepages_${default_size}
> >                       nr_overcommit_hugepages_${default_size}
> >                       nr_hugepages_${other_size1}
> >                       nr_overcommit_hugepages_${other_size2}
> >                       nodeX/nr_hugepages -> nr_hugepages_${default_size}
> >                             nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
> >                             nr_hugepages_${default_size}
> >                             nr_overcommit_hugepages_${default_size}
> >                             nr_hugepages_${other_size1}
> >                             nr_overcommit_hugepages_${other_size2}
> > 
> > How does that look? Does anyone have any problems with such an
> > arrangement?
> 
> Looks pretty good. I would personally lean toward subdirectories for
> hstates. Pros are that it would be a little easier to navigate from
> the shell, and maybe more regular to program for.
> 
> You could possibly have hugepages_default symlink as well to one of
> the directories of your choice. This could be used by apps which do
> not specify exactly what size they want...
> 
> I don't know, just ideas.

So, here's the first cut of the patch. Still very rough, but it builds
and I'm running it now:

[20:41:34]nacc@arkanoid:/sys/kernel/hugepages$ tree
.
`-- hugepages-2MB
    |-- meminfo
    |-- nr_huge_pages
    `-- nr_overcommit_huge_pages

1 directory, 3 files

[20:41:56]nacc@arkanoid:/sys/kernel/hugepages$ cat /sys/kernel/hugepages/hugepages-2MB/meminfo
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
HugePages_Surp:      0
Hugepagesize:     2048 kB

[20:42:20]nacc@arkanoid:/sys/kernel/hugepages$ sudo echo 10 > /sys/kernel/hugepages/hugepages-2MB/nr_huge_pages 
[20:42:57]nacc@arkanoid:/sys/kernel/hugepages$ cat /sys/kernel/hugepages/hugepages-2MB/nr_huge_pages 
10
[20:43:02]nacc@arkanoid:/sys/kernel/hugepages$ cat /sys/kernel/hugepages/hugepages-2MB/meminfo 
HugePages_Total:    10
HugePages_Free:     10
HugePages_Rsvd:      0
HugePages_Surp:      0
Hugepagesize:     2048 kB
[20:43:05]nacc@arkanoid:/sys/kernel/hugepages$ cat /proc/m
[20:43:10]nacc@arkanoid:/sys/kernel/hugepages$ grep Huge /proc/meminfo 
HugePages_Total:    10
HugePages_Free:     10
HugePages_Rsvd:      0
HugePages_Surp:      0
Hugepagesize:     2048 kB

I haven't tested yet with multiple pools, will hopefully get to that Monday. I
see one obvious issue, in that I left an underscore in huge_pages :) Will fix.
How does the naming seem? I don't like having two memfmt()s but I couldn't
think of a good way, beyond perhaps having two strings, one for the magnitude
and one for the units, but that seemed gross.

A lot of the functions and macros, perhaps all of them, are clones of the ones
used for /sys/kernel/slab. Thanks to those authors for that code!

Greg, do you see any obvious violations of sysfs rules here? Well, beyond
meminfo itself, I guess, but given our previous snapshot discussion, I left it
simple and the same, rather than split it up.

Not-yet-Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

 include/linux/hugetlb.h |    9 +-
 mm/hugetlb.c            |  317 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 251 insertions(+), 75 deletions(-)

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
index de03a14..c30e45d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -15,6 +15,7 @@
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
 #include <linux/bootmem.h>
+#include <linux/sysfs.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -604,9 +605,21 @@ static void __init gather_bootmem_prealloc(void)
 	}
 }
 
+static __init char *memfmt_nospaces(char *buf, unsigned long n)
+{
+	if (n >= (1UL << 30))
+		sprintf(buf, "%luGB", n >> 30);
+	else if (n >= (1UL << 20))
+		sprintf(buf, "%luMB", n >> 20);
+	else
+		sprintf(buf, "%luKB", n >> 10);
+	return buf;
+}
+
 static void __init hugetlb_init_hstate(struct hstate *h)
 {
 	unsigned long i;
+	char buf[32];
 
 	/* Don't reinitialize lists if they have been already init'ed */
 	if (!h->hugepage_freelists[0].next) {
@@ -624,6 +637,8 @@ static void __init hugetlb_init_hstate(struct hstate *h)
 			break;
 	}
 	h->max_huge_pages = i;
+	h->name = kasprintf(GFP_KERNEL, "hugepages-%s",
+				memfmt_nospaces(buf, huge_page_size(h)));
 }
 
 static void __init hugetlb_init_hstates(void)
@@ -662,77 +677,6 @@ static void __init report_hugepages(void)
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
@@ -843,6 +787,237 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_SYSFS
+#define to_hstate_attr(n) container_of(n, struct hstate_attribute, attr)
+#define to_hstate(n) container_of(n, struct hstate, kobj)
+
+struct hstate_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct hstate *h, char *buf);
+	ssize_t (*store)(struct hstate *h, const char *buf, size_t count);
+};
+
+#define HSTATE_ATTR_RO(_name) \
+	static struct hstate_attribute _name##_attr = __ATTR_RO(_name)
+
+#define HSTATE_ATTR(_name) \
+	static struct hstate_attribute _name##_attr = \
+		__ATTR(_name, 0644, _name##_show, _name##_store)
+
+static ssize_t nr_huge_pages_show(struct hstate *h, char *buf)
+{
+	return sprintf(buf, "%lu\n", h->nr_huge_pages);
+}
+static ssize_t nr_huge_pages_store(struct hstate *h, const char *buf, size_t count)
+{
+	int tmp;
+
+	h->max_huge_pages = set_max_huge_pages(h,
+					simple_strtoul(buf, NULL, 10), &tmp);
+	max_huge_pages[h - hstates] = h->max_huge_pages;
+	return count;
+}
+HSTATE_ATTR(nr_huge_pages);
+
+static ssize_t nr_overcommit_huge_pages_show(struct hstate *h, char *buf)
+{
+	return sprintf(buf, "%lu\n", h->nr_overcommit_huge_pages);
+}
+static ssize_t nr_overcommit_huge_pages_store(struct hstate *h, const char *buf, size_t count)
+{
+	spin_lock(&hugetlb_lock);
+	h->nr_overcommit_huge_pages = simple_strtoul(buf, NULL, 10);
+	sysctl_overcommit_huge_pages[h - hstates] = h->nr_overcommit_huge_pages;
+	spin_unlock(&hugetlb_lock);
+	return count;
+}
+HSTATE_ATTR(nr_overcommit_huge_pages);
+
+static ssize_t meminfo_show(struct hstate *h, char *buf)
+{
+	return sprintf(buf,
+			"HugePages_Total: %5lu\n"
+			"HugePages_Free:  %5lu\n"
+			"HugePages_Rsvd:  %5lu\n"
+			"HugePages_Surp:  %5lu\n"
+			"Hugepagesize:    %5lu kB\n",
+			h->nr_huge_pages,
+			h->free_huge_pages,
+			h->resv_huge_pages,
+			h->surplus_huge_pages,
+			huge_page_size(h) / 1024);
+}
+HSTATE_ATTR_RO(meminfo);
+
+static struct kset *hstate_kset;
+
+static struct attribute *hstate_attrs[] = {
+	&meminfo_attr.attr,
+	&nr_huge_pages_attr.attr,
+	&nr_overcommit_huge_pages_attr.attr,
+};
+
+static struct attribute_group hstate_attr_group = {
+	.attrs = hstate_attrs,
+};
+
+static ssize_t hstate_attr_show(struct kobject *kobj,
+					struct attribute *attr,
+					char *buf)
+{
+	struct hstate_attribute *attribute;
+	struct hstate *h;
+	int err;
+
+	attribute = to_hstate_attr(attr);
+	h = to_hstate(kobj);
+
+	if (!attribute->show)
+		return -EIO;
+
+	err = attribute->show(h, buf);
+
+	return err;
+}
+
+static ssize_t hstate_attr_store(struct kobject *kobj,
+					struct attribute *attr,
+					const char *buf, size_t len)
+{
+	struct hstate_attribute *attribute;
+	struct hstate *h;
+	int err;
+
+	attribute = to_hstate_attr(attr);
+	h = to_hstate(kobj);
+
+	if (!attribute->store)
+		return -EIO;
+
+	err = attribute->store(h, buf, len);
+
+	return err;
+}
+
+static struct sysfs_ops hstate_sysfs_ops = {
+	.show = hstate_attr_show,
+	.store = hstate_attr_store,
+};
+
+static struct kobj_type hstate_ktype = {
+	.sysfs_ops = &hstate_sysfs_ops,
+};
+
+static int __init hugetlb_sysfs_add_hstate(struct hstate *h)
+{
+	int err;
+	h->kobj.kset = hstate_kset;
+	err = kobject_init_and_add(&h->kobj, &hstate_ktype, NULL, h->name);
+	if (err) {
+		kobject_put(&h->kobj);
+		return err;
+	}
+	err = sysfs_create_group(&h->kobj, &hstate_attr_group);
+	if (err)
+		return err;
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
+			printk(KERN_ERR "Hugetlb: Unable to add hstate %s", h->name);
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
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
