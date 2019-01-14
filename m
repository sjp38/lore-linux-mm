Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF0618E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:54:59 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id f22so15950923qkm.11
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 01:54:59 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 52si15977999qvf.121.2019.01.14.01.54.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 01:54:57 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0E9mVF5050500
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:54:57 -0500
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q0pskkmxt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:54:57 -0500
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 14 Jan 2019 09:54:56 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V7 2/4] mm: Update get_user_pages_longterm to migrate pages allocated from CMA region
Date: Mon, 14 Jan 2019 15:24:34 +0530
In-Reply-To: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
References: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190114095438.32470-3-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

This patch updates get_user_pages_longterm to migrate pages allocated out
of CMA region. This makes sure that we don't keep non-movable pages (due to page
reference count) in the CMA area.

This will be used by ppc64 in a later patch to avoid pinning pages in the CMA
region. ppc64 uses CMA region for allocation of the hardware page table (hash page
table) and not able to migrate pages out of CMA region results in page table
allocation failures.

One case where we hit this easy is when a guest using a VFIO passthrough device.
VFIO locks all the guest's memory and if the guest memory is backed by CMA
region, it becomes unmovable resulting in fragmenting the CMA and possibly
preventing other guests from allocation a large enough hash page table.

NOTE: We allocate the new page without using __GFP_THISNODE

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 include/linux/hugetlb.h |   2 +
 include/linux/mm.h      |   3 +-
 mm/gup.c                | 200 +++++++++++++++++++++++++++++++++++-----
 mm/hugetlb.c            |   4 +-
 4 files changed, 182 insertions(+), 27 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 087fd5f48c91..1eed0cdaec0e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -371,6 +371,8 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 				nodemask_t *nmask);
 struct page *alloc_huge_page_vma(struct hstate *h, struct vm_area_struct *vma,
 				unsigned long address);
+struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
+				     int nid, nodemask_t *nmask);
 int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 			pgoff_t idx);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..20ec56f8e2bb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1536,7 +1536,8 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 		    unsigned int gup_flags, struct page **pages, int *locked);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    struct page **pages, unsigned int gup_flags);
-#ifdef CONFIG_FS_DAX
+
+#if defined(CONFIG_FS_DAX) || defined(CONFIG_CMA)
 long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    struct vm_area_struct **vmas);
diff --git a/mm/gup.c b/mm/gup.c
index 05acd7e2eb22..6e8152594e83 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -13,6 +13,9 @@
 #include <linux/sched/signal.h>
 #include <linux/rwsem.h>
 #include <linux/hugetlb.h>
+#include <linux/migrate.h>
+#include <linux/mm_inline.h>
+#include <linux/sched/mm.h>
 
 #include <asm/mmu_context.h>
 #include <asm/pgtable.h>
@@ -1126,7 +1129,167 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 }
 EXPORT_SYMBOL(get_user_pages);
 
+#if defined(CONFIG_FS_DAX) || defined (CONFIG_CMA)
+
 #ifdef CONFIG_FS_DAX
+static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
+{
+	long i;
+	struct vm_area_struct *vma_prev = NULL;
+
+	for (i = 0; i < nr_pages; i++) {
+		struct vm_area_struct *vma = vmas[i];
+
+		if (vma == vma_prev)
+			continue;
+
+		vma_prev = vma;
+
+		if (vma_is_fsdax(vma))
+			return true;
+	}
+	return false;
+}
+#else
+static inline bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
+{
+	return false;
+}
+#endif
+
+#ifdef CONFIG_CMA
+static struct page *new_non_cma_page(struct page *page, unsigned long private)
+{
+	/*
+	 * We want to make sure we allocate the new page from the same node
+	 * as the source page.
+	 */
+	int nid = page_to_nid(page);
+	/*
+	 * Trying to allocate a page for migration. Ignore allocation
+	 * failure warnings. We don't force __GFP_THISNODE here because
+	 * this node here is the node where we have CMA reservation and
+	 * in some case these nodes will have really less non movable
+	 * allocation memory.
+	 */
+	gfp_t gfp_mask = GFP_USER | __GFP_NOWARN;
+
+	if (PageHighMem(page))
+		gfp_mask |= __GFP_HIGHMEM;
+
+#ifdef CONFIG_HUGETLB_PAGE
+	if (PageHuge(page)) {
+		struct hstate *h = page_hstate(page);
+		/*
+		 * We don't want to dequeue from the pool because pool pages will
+		 * mostly be from the CMA region.
+		 */
+		return alloc_migrate_huge_page(h, gfp_mask, nid, NULL);
+	}
+#endif
+	if (PageTransHuge(page)) {
+		struct page *thp;
+		/*
+		 * ignore allocation failure warnings
+		 */
+		gfp_t thp_gfpmask = GFP_TRANSHUGE | __GFP_NOWARN;
+
+		/*
+		 * Remove the movable mask so that we don't allocate from
+		 * CMA area again.
+		 */
+		thp_gfpmask &= ~__GFP_MOVABLE;
+		thp = __alloc_pages_node(nid, thp_gfpmask, HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	}
+
+	return __alloc_pages_node(nid, gfp_mask, 0);
+}
+
+static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
+					unsigned int gup_flags,
+					struct page **pages,
+					struct vm_area_struct **vmas)
+{
+	long i;
+	bool drain_allow = true;
+	bool migrate_allow = true;
+	LIST_HEAD(cma_page_list);
+
+check_again:
+	for (i = 0; i < nr_pages; i++) {
+		/*
+		 * If we get a page from the CMA zone, since we are going to
+		 * be pinning these entries, we might as well move them out
+		 * of the CMA zone if possible.
+		 */
+		if (is_migrate_cma_page(pages[i])) {
+
+			struct page *head = compound_head(pages[i]);
+
+			if (PageHuge(head)) {
+				isolate_huge_page(head, &cma_page_list);
+			} else {
+				if (!PageLRU(head) && drain_allow) {
+					lru_add_drain_all();
+					drain_allow = false;
+				}
+
+				if (!isolate_lru_page(head)) {
+					list_add_tail(&head->lru, &cma_page_list);
+					mod_node_page_state(page_pgdat(head),
+							    NR_ISOLATED_ANON +
+							    page_is_file_cache(head),
+							    hpage_nr_pages(head));
+				}
+			}
+		}
+	}
+
+	if (!list_empty(&cma_page_list)) {
+		/*
+		 * drop the above get_user_pages reference.
+		 */
+		for (i = 0; i < nr_pages; i++)
+			put_page(pages[i]);
+
+		if (migrate_pages(&cma_page_list, new_non_cma_page,
+				  NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE)) {
+			/*
+			 * some of the pages failed migration. Do get_user_pages
+			 * without migration.
+			 */
+			migrate_allow = false;
+
+			if (!list_empty(&cma_page_list))
+				putback_movable_pages(&cma_page_list);
+		}
+		/*
+		 * We did migrate all the pages, Try to get the page references again
+		 * migrating any new CMA pages which we failed to isolate earlier.
+		 */
+		nr_pages = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
+		if ((nr_pages > 0) && migrate_allow) {
+			drain_allow = true;
+			goto check_again;
+		}
+	}
+
+	return nr_pages;
+}
+#else
+static inline long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
+					       unsigned int gup_flags,
+					       struct page **pages,
+					       struct vm_area_struct **vmas)
+{
+	return nr_pages;
+}
+#endif
+
 /*
  * This is the same as get_user_pages() in that it assumes we are
  * operating on the current task's mm, but it goes further to validate
@@ -1140,11 +1303,11 @@ EXPORT_SYMBOL(get_user_pages);
  * Contrast this to iov_iter_get_pages() usages which are transient.
  */
 long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
-		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas_arg)
+			     unsigned int gup_flags, struct page **pages,
+			     struct vm_area_struct **vmas_arg)
 {
 	struct vm_area_struct **vmas = vmas_arg;
-	struct vm_area_struct *vma_prev = NULL;
+	unsigned long flags;
 	long rc, i;
 
 	if (!pages)
@@ -1157,31 +1320,20 @@ long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
 			return -ENOMEM;
 	}
 
+	flags = memalloc_nocma_save();
 	rc = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
+	memalloc_nocma_restore(flags);
+	if (rc < 0)
+		goto out;
 
-	for (i = 0; i < rc; i++) {
-		struct vm_area_struct *vma = vmas[i];
-
-		if (vma == vma_prev)
-			continue;
-
-		vma_prev = vma;
-
-		if (vma_is_fsdax(vma))
-			break;
-	}
-
-	/*
-	 * Either get_user_pages() failed, or the vma validation
-	 * succeeded, in either case we don't need to put_page() before
-	 * returning.
-	 */
-	if (i >= rc)
+	if (check_dax_vmas(vmas, rc)) {
+		for (i = 0; i < rc; i++)
+			put_page(pages[i]);
+		rc = -EOPNOTSUPP;
 		goto out;
+	}
 
-	for (i = 0; i < rc; i++)
-		put_page(pages[i]);
-	rc = -EOPNOTSUPP;
+	rc = check_and_migrate_cma_pages(start, rc, gup_flags, pages, vmas);
 out:
 	if (vmas != vmas_arg)
 		kfree(vmas);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index df2e7dd5ff17..913862771808 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1586,8 +1586,8 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 	return page;
 }
 
-static struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
-		int nid, nodemask_t *nmask)
+struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
+				     int nid, nodemask_t *nmask)
 {
 	struct page *page;
 
-- 
2.20.1
