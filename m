Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 480C26B056A
	for <linux-mm@kvack.org>; Fri, 18 May 2018 00:29:54 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id a14-v6so4300883plt.7
        for <linux-mm@kvack.org>; Thu, 17 May 2018 21:29:54 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id e92-v6si6440102pld.601.2018.05.17.21.29.52
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 21:29:53 -0700 (PDT)
Subject: [PATCH v2 1/7] hugetlb: introduce charge_surplus_huge_pages to struct
 hstate
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <a6a46388-347c-8422-c3f3-1061ccfed26f@ascade.co.jp>
Date: Fri, 18 May 2018 13:29:43 +0900
MIME-Version: 1.0
In-Reply-To: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, tsukada@ascade.co.jp

The charge_surplus_huge_pages indicates to charge surplus huge pages
obteined from the normal page pool to memory cgroup. The default value is
false.

This patch implements the core part of charging surplus hugepages. Use the
private and mem_cgroup member of the second entry of compound hugepage for
surplus hugepage charging.

Mark when surplus hugepage is obtained from normal pool, and charge to
memory cgroup at alloc_huge_page. Once the mapping of the page is decided,
commit the charge. surplus hugepages will uncharge or cancel at
free_huge_page.

Signed-off-by: TSUKADA Koutaro <tsukada@ascade.co.jp>
---
 include/linux/hugetlb.h |    2
 mm/hugetlb.c            |  100 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 102 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 36fa6a2..33fe5be 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -158,6 +158,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot);

 bool is_hugetlb_entry_migration(pte_t pte);
+bool PageSurplusCharge(struct page *page);

 #else /* !CONFIG_HUGETLB_PAGE */

@@ -338,6 +339,7 @@ struct hstate {
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+	bool charge_surplus_huge_pages;	/* default to off */
 #ifdef CONFIG_CGROUP_HUGETLB
 	/* cgroup control files */
 	struct cftype cgroup_files[5];
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2186791..679c151f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -36,6 +36,7 @@
 #include <linux/node.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/page_owner.h>
+#include <linux/memcontrol.h>
 #include "internal.h"

 int hugetlb_max_hstate __read_mostly;
@@ -1236,6 +1237,90 @@ static inline void ClearPageHugeTemporary(struct page *page)
 	page[2].mapping = NULL;
 }

+#define HUGETLB_SURPLUS_CHARGE		1UL
+
+bool PageSurplusCharge(struct page *page)
+{
+	if (!PageHuge(page))
+		return false;
+	return page[1].private == HUGETLB_SURPLUS_CHARGE;
+}
+
+static inline void SetPageSurplusCharge(struct page *page)
+{
+	page[1].private = HUGETLB_SURPLUS_CHARGE;
+}
+
+static inline void ClearPageSurplusCharge(struct page *page)
+{
+	page[1].private = 0;
+}
+
+static inline void
+set_surplus_hugepage_memcg(struct page *page, struct mem_cgroup *memcg)
+{
+	page[1].mem_cgroup = memcg;
+}
+
+static inline struct mem_cgroup *get_surplus_hugepage_memcg(struct page *page)
+{
+	return page[1].mem_cgroup;
+}
+
+static void surplus_hugepage_set_charge(struct hstate *h, struct page *page)
+{
+	if (likely(!h->charge_surplus_huge_pages))
+		return;
+	if (unlikely(!page))
+		return;
+	SetPageSurplusCharge(page);
+}
+
+static int surplus_hugepage_try_charge(struct page *page, struct mm_struct *mm)
+{
+	struct mem_cgroup *memcg;
+
+	if (likely(!PageSurplusCharge(page)))
+		return 0;
+
+	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg, true)) {
+		/* mem_cgroup oom invoked */
+		ClearPageSurplusCharge(page);
+		return -ENOMEM;
+	}
+	set_surplus_hugepage_memcg(page, memcg);
+
+	return 0;
+}
+
+static void surplus_hugepage_commit_charge(struct page *page)
+{
+	struct mem_cgroup *memcg;
+
+	if (likely(!PageSurplusCharge(page)))
+		return;
+
+	memcg = get_surplus_hugepage_memcg(page);
+	mem_cgroup_commit_charge(page, memcg, false, true);
+	set_surplus_hugepage_memcg(page, NULL);
+}
+
+static void surplus_hugepage_finalize_charge(struct page *page)
+{
+	struct mem_cgroup *memcg;
+
+	if (likely(!PageSurplusCharge(page)))
+		return;
+
+	memcg = get_surplus_hugepage_memcg(page);
+	if (memcg)
+		mem_cgroup_cancel_charge(page, memcg, true);
+	else
+		mem_cgroup_uncharge(page);
+	set_surplus_hugepage_memcg(page, NULL);
+	ClearPageSurplusCharge(page);
+}
+
 void free_huge_page(struct page *page)
 {
 	/*
@@ -1248,6 +1333,8 @@ void free_huge_page(struct page *page)
 		(struct hugepage_subpool *)page_private(page);
 	bool restore_reserve;

+	surplus_hugepage_finalize_charge(page);
+
 	set_page_private(page, 0);
 	page->mapping = NULL;
 	VM_BUG_ON_PAGE(page_count(page), page);
@@ -1583,6 +1670,8 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 out_unlock:
 	spin_unlock(&hugetlb_lock);

+	surplus_hugepage_set_charge(h, page);
+
 	return page;
 }

@@ -2062,6 +2151,11 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
 	spin_unlock(&hugetlb_lock);

+	if (unlikely(surplus_hugepage_try_charge(page, vma->vm_mm))) {
+		put_page(page);
+		return ERR_PTR(-ENOMEM);
+	}
+
 	set_page_private(page, (unsigned long)spool);

 	map_commit = vma_commit_reservation(h, vma, addr);
@@ -3610,6 +3704,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 				make_huge_pte(vma, new_page, 1));
 		page_remove_rmap(old_page, true);
 		hugepage_add_new_anon_rmap(new_page, vma, address);
+		surplus_hugepage_commit_charge(new_page);
 		/* Make the old page be freed below */
 		new_page = old_page;
 	}
@@ -3667,6 +3762,9 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,

 	if (err)
 		return err;
+
+	surplus_hugepage_commit_charge(page);
+
 	ClearPagePrivate(page);

 	spin_lock(&inode->i_lock);
@@ -3809,6 +3907,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (anon_rmap) {
 		ClearPagePrivate(page);
 		hugepage_add_new_anon_rmap(page, vma, address);
+		surplus_hugepage_commit_charge(page);
 	} else
 		page_dup_rmap(page, true);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
@@ -4108,6 +4207,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	} else {
 		ClearPagePrivate(page);
 		hugepage_add_new_anon_rmap(page, dst_vma, dst_addr);
+		surplus_hugepage_commit_charge(page);
 	}

 	_dst_pte = make_huge_pte(dst_vma, page, dst_vma->vm_flags & VM_WRITE);
-- 
Tsukada
