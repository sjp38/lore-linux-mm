Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1B61D6B02C0
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 13:36:02 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id c7so10439176wjb.7
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 10:36:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x89si5379717wrb.281.2017.01.19.10.36.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 10:36:00 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0JISlfB046312
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 13:35:59 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2832af1cp3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 13:35:59 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Thu, 19 Jan 2017 18:35:57 -0000
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [PATCH v2 1/1] mm/ksm: improve deduplication of zero pages with colouring
Date: Thu, 19 Jan 2017 19:35:53 +0100
Message-Id: <1484850953-23941-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: borntraeger@de.ibm.com, hughd@google.com, aarcange@redhat.com, chrisw@sous-sol.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Some architectures have a set of zero pages (coloured zero pages)
instead of only one zero page, in order to improve the cache
performance. In those cases, the kernel samepage merger (KSM) would
merge all the allocated pages that happen to be filled with zeroes to
the same deduplicated page, thus losing all the advantages of coloured
zero pages.

This behaviour is noticeable when a process accesses large arrays of
allocated pages containing zeroes. A test I conducted on s390 shows
that there is a speed penalty when KSM merges such pages, compared to
not merging them or using actual zero pages from the start without
breaking the COW.

This patch fixes this behaviour. When coloured zero pages are present,
the checksum of a zero page is calculated during initialisation, and
compared with the checksum of the current canditate during merging. In
case of a match, the normal merging routine is used to merge the page
with the correct coloured zero page, which ensures the candidate page
is checked to be equal to the target zero page.

A sysfs entry is also added to toggle this behaviour, since it can
potentially introduce performance regressions, especially on
architectures without coloured zero pages. The default value is
disabled, for backwards compatibility.

With this patch, the performance with KSM is the same as with non
COW-broken actual zero pages, which is also the same as without KSM.

Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
---
 mm/ksm.c | 68 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 65 insertions(+), 3 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 9ae6011..88b7fc9 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -223,6 +223,12 @@ struct rmap_item {
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+/* Checksum of an empty (zeroed) page */
+static unsigned int zero_checksum;
+
+/* Whether to merge empty (zeroed) pages with actual zero pages */
+static bool ksm_use_zero_pages;
+
 #ifdef CONFIG_NUMA
 /* Zeroed when merging across nodes is not allowed */
 static unsigned int ksm_merge_across_nodes = 1;
@@ -926,6 +932,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t *pmd;
 	pte_t *ptep;
+	pte_t newpte;
 	spinlock_t *ptl;
 	unsigned long addr;
 	int err = -EFAULT;
@@ -950,12 +957,22 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 		goto out_mn;
 	}
 
-	get_page(kpage);
-	page_add_anon_rmap(kpage, vma, addr, false);
+	/*
+	 * No need to check ksm_use_zero_pages here: we can only have a
+	 * zero_page here if ksm_use_zero_pages was enabled alreaady.
+	 */
+	if (!is_zero_pfn(page_to_pfn(kpage))) {
+		get_page(kpage);
+		page_add_anon_rmap(kpage, vma, addr, false);
+		newpte = mk_pte(kpage, vma->vm_page_prot);
+	} else {
+		newpte = pte_mkspecial(pfn_pte(page_to_pfn(kpage),
+					       vma->vm_page_prot));
+	}
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush_notify(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+	set_pte_at_notify(mm, addr, ptep, newpte);
 
 	page_remove_rmap(page, false);
 	if (!page_mapped(page))
@@ -1467,6 +1484,23 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 		return;
 	}
 
+	/*
+	 * Same checksum as an empty page. We attempt to merge it with the
+	 * appropriate zero page if the user enabled this via sysfs.
+	 */
+	if (ksm_use_zero_pages && (checksum == zero_checksum)) {
+		struct vm_area_struct *vma;
+
+		vma = find_mergeable_vma(rmap_item->mm, rmap_item->address);
+		err = try_to_merge_one_page(vma, page,
+					    ZERO_PAGE(rmap_item->address));
+		/*
+		 * In case of failure, the page was not really empty, so we
+		 * need to continue. Otherwise we're done.
+		 */
+		if (!err)
+			return;
+	}
 	tree_rmap_item =
 		unstable_tree_search_insert(rmap_item, page, &tree_page);
 	if (tree_rmap_item) {
@@ -2233,6 +2267,28 @@ static ssize_t merge_across_nodes_store(struct kobject *kobj,
 KSM_ATTR(merge_across_nodes);
 #endif
 
+static ssize_t use_zero_pages_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_use_zero_pages);
+}
+static ssize_t use_zero_pages_store(struct kobject *kobj,
+				   struct kobj_attribute *attr,
+				   const char *buf, size_t count)
+{
+	int err;
+	bool value;
+
+	err = kstrtobool(buf, &value);
+	if (err)
+		return -EINVAL;
+
+	ksm_use_zero_pages = value;
+
+	return count;
+}
+KSM_ATTR(use_zero_pages);
+
 static ssize_t pages_shared_show(struct kobject *kobj,
 				 struct kobj_attribute *attr, char *buf)
 {
@@ -2290,6 +2346,7 @@ static ssize_t full_scans_show(struct kobject *kobj,
 #ifdef CONFIG_NUMA
 	&merge_across_nodes_attr.attr,
 #endif
+	&use_zero_pages_attr.attr,
 	NULL,
 };
 
@@ -2304,6 +2361,11 @@ static int __init ksm_init(void)
 	struct task_struct *ksm_thread;
 	int err;
 
+	/* The correct value depends on page size and endianness */
+	zero_checksum = calc_checksum(ZERO_PAGE(0));
+	/* Default to false for backwards compatibility */
+	ksm_use_zero_pages = false;
+
 	err = ksm_slab_init();
 	if (err)
 		goto out;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
