Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id D8AAC6B0036
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 20:02:48 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id w61so8150673wes.40
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:02:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n2si5130231wiz.53.2014.02.13.17.02.45
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 17:02:47 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Date: Thu, 13 Feb 2014 20:02:08 -0500
Message-Id: <1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, rientjes@google.com

From: Luiz capitulino <lcapitulino@redhat.com>

The HugeTLB command-line option hugepages= allows a user to specify how
many huge pages should be allocated at boot. This option is needed because
it improves reliability when allocating 1G huge pages, which are better
allocated as early as possible due to fragmentation.

However, hugepages= has a limitation. On NUMA systems, hugepages= will
automatically distribute memory allocation equally among nodes. For
example, if you have a 2-node NUMA system and allocate 200 huge pages,
than hugepages= will try to allocate 100 huge pages from node0 and 100
from node1.

This is very unflexible, as it doesn't allow you to specify which nodes
the huge pages should be allocated from. For example, there are use-cases
where the user wants to specify that a 1GB huge page should be allocated
from node 2 or that 300 2MB huge pages should be allocated from node 0.

The hugepages_node= command-line option introduced by this commit allows
just that.

The syntax is:

  hugepages_node=nid:nr_pages:size,...

For example, to allocate one 1GB page from node 2, you can do:

  hugepages_node=2:1:1G

Or, to allocate 300 2MB huge pages from node 0 and 5 1GB huge pages from node 1:

 hugepages_node=0:300:2M,1:5:1G

Also, please note the following:

 - All the hugepages_node= option does is to set initial memory allocation
   distribution among nodes. It doesn't do anything intrusive. All functions
   and the array added by this commit are run onlt once at boot and discarded
   thereafter

 - This commit adds support only for the x86 architecture. Adding support for
   other archs is welcome and should be simple, it's just a matter of porting
   setup_hugepages_node()

 - When an error is encountered while parsing, allocations are obeyed
   up to the error and parsing is then aborted. This is simplest way to
   deal with errors

 - Mixing hugepages_node= and hugepages= options is not supported

Signed-off-by: Luiz capitulino <lcapitulino@redhat.com>
---
 Documentation/kernel-parameters.txt |   8 +++
 arch/x86/mm/hugetlbpage.c           |  52 ++++++++++++++++++
 include/linux/hugetlb.h             |   2 +
 mm/hugetlb.c                        | 106 ++++++++++++++++++++++++++++++++++++
 4 files changed, 168 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 7116fda..bbceb73 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1133,6 +1133,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			(when the CPU supports the "pdpe1gb" cpuinfo flag)
 			Note that 1GB pages can only be allocated at boot time
 			using hugepages= and not freed afterwards.
+	hugepages_node= [X86-64] HugeTLB pages to allocate at boot on a NUMA system.
+				Format: <nid>:<nrpages>:<size>,...
+				nid: NUMA node id to allocate pages from
+				nrpages: number of huge pages to allocate
+				size: huge pages size (same as hugepagesz= above)
+			On error, allocations are obeyed up to the error and then parsing
+			is aborted. This option shouldn't be mixed with other hugepages=
+			options.
 
 	hvc_iucv=	[S390] Number of z/VM IUCV hypervisor console (HVC)
 			       terminal devices. Valid values: 0..8
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 968db71..88318818 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -201,4 +201,56 @@ static __init int setup_hugepagesz(char *opt)
 	return 1;
 }
 __setup("hugepagesz=", setup_hugepagesz);
+
+/* 
+ * Format is "nid:nr_pages:size,...". Example: "0:300:2M,1:10:1G"
+ *
+ * To make error handling simple we halt parsing on the first error,
+ * which means that the user's allocation requests will be obeyed until
+ * an error is found (if any).
+ */
+static __init int setup_hugepages_node(char *opt)
+{
+	unsigned nid, nr_pages, order;
+	char *p, size_str[16];
+	int ret;
+
+	do {
+		p = strchr(opt, ',');
+		if (p)
+			*p = '\0';
+
+		ret = sscanf(opt, "%u:%u:%15s", &nid, &nr_pages, size_str);
+		if (ret != 3) {
+			pr_err("hugepages_node: bad syntax, aborting\n");
+			return 0;
+		}
+
+		if (nid >= MAX_NUMNODES) {
+			pr_err("hugepages_node: invalid numa node: %u, "
+				"aborting\n", nid);
+			return 0;
+		}
+
+		ret = parse_pagesize_str(size_str, &order);
+		if (ret < 0) {
+			pr_err("hugepages_node: unsupported page size: %s, "
+				"aborting\n", size_str);
+			return 0;
+		}
+
+		ret = hugetlb_boot_alloc_add_nid(nid, nr_pages, order);
+		if (ret < 0)
+			return 0;
+
+		if (p) {
+			*p = ',';
+			opt = ++p;
+		}
+	} while (p);
+
+	return 1;
+}
+__setup("hugepages_node=", setup_hugepages_node);
+
 #endif
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8c43cc4..2c1c01a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -274,6 +274,8 @@ struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
 int __init alloc_bootmem_huge_page(struct hstate *h);
 
 void __init hugetlb_add_hstate(unsigned order);
+int __init hugetlb_boot_alloc_add_nid(unsigned nid, unsigned nr_pages,
+				unsigned order);
 struct hstate *size_to_hstate(unsigned long size);
 
 #ifndef HUGE_MAX_HSTATE
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c01cb9f..3e9e929 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -46,6 +46,7 @@ __initdata LIST_HEAD(huge_boot_pages);
 static struct hstate * __initdata parsed_hstate;
 static unsigned long __initdata default_hstate_max_huge_pages;
 static unsigned long __initdata default_hstate_size;
+static unsigned int __initdata boot_alloc_nodes[HUGE_MAX_HSTATE][MAX_NUMNODES];
 
 /*
  * Protects updates to hugepage_freelists, hugepage_activelist, nr_huge_pages,
@@ -1348,6 +1349,50 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 	h->max_huge_pages = i;
 }
 
+static unsigned long __init alloc_huge_pages_nid(struct hstate *h,
+						int nid,
+						unsigned long nr_pages)
+{
+	unsigned long i;
+	struct page *page;
+
+	for (i = 0; i < nr_pages; i++) {
+		page = alloc_fresh_huge_page_node(h, nid);
+		if (!page) {
+			count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
+			break;
+		}
+		count_vm_event(HTLB_BUDDY_PGALLOC);
+	}
+
+	return i;
+}
+
+static unsigned __init alloc_huge_pages_nodes(struct hstate *h)
+{
+	unsigned i, *entry, ret = 0;
+
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		entry = &boot_alloc_nodes[hstate_index(h)][i];
+		if (*entry > 0)
+			ret += alloc_huge_pages_nid(h, i, *entry);
+	}
+
+	return ret;
+}
+
+static void __init hugetlb_init_hstates_nodes(void)
+{
+	struct hstate *h;
+	unsigned ret;
+
+	for_each_hstate(h)
+		if (h->order < MAX_ORDER) {
+			ret = alloc_huge_pages_nodes(h);
+			h->max_huge_pages += ret;
+		}
+}
+
 static void __init hugetlb_init_hstates(void)
 {
 	struct hstate *h;
@@ -1966,6 +2011,7 @@ static int __init hugetlb_init(void)
 		default_hstate.max_huge_pages = default_hstate_max_huge_pages;
 
 	hugetlb_init_hstates();
+	hugetlb_init_hstates_nodes();
 	gather_bootmem_prealloc();
 	report_hugepages();
 
@@ -2005,6 +2051,66 @@ void __init hugetlb_add_hstate(unsigned order)
 	parsed_hstate = h;
 }
 
+static void __init hugetlb_hstate_alloc_pages_nid(struct hstate *h,
+						int nid,
+						unsigned long nr_pages)
+{
+	struct huge_bootmem_page *m;
+	unsigned long i;
+	void *addr;
+
+	for (i = 0; i < nr_pages; i++) {
+		addr = memblock_virt_alloc_nid_nopanic(
+				huge_page_size(h), huge_page_size(h),
+				0, BOOTMEM_ALLOC_ACCESSIBLE, nid);
+		if (!addr)
+			break;
+		m = addr;
+		BUG_ON(!IS_ALIGNED((unsigned long) virt_to_phys(m),
+			huge_page_size(h)));
+		list_add(&m->list, &huge_boot_pages);
+		m->hstate = h;
+	}
+
+	h->max_huge_pages += i;
+}
+
+int __init hugetlb_boot_alloc_add_nid(unsigned nid, unsigned nr_pages,
+				unsigned order)
+{
+	struct hstate *h;
+	unsigned *p;
+
+	if (parsed_hstate) {
+		pr_err("hugepages_node: hugepagesz has been specified, "
+			"aborting\n");
+		return -1;
+	}
+
+	for_each_hstate(h)
+		if (h->order == order)
+			break;
+
+	if (h->order != order) {
+		hugetlb_add_hstate(order);
+		parsed_hstate = NULL;
+	}
+
+	p = &boot_alloc_nodes[hstate_index(h)][nid];
+	if (*p != 0) {
+		pr_err("hugepages_node: node %u already specified, "
+			"aborting\n", nid);
+		return -1;
+	}
+
+	*p = nr_pages;
+
+	if (h->order >= MAX_ORDER)
+		hugetlb_hstate_alloc_pages_nid(h, nid, nr_pages);
+
+	return 0;
+}
+
 static int __init hugetlb_nrpages_setup(char *s)
 {
 	unsigned long *mhp;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
