Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04A756B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:58:00 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id t8so123129523vke.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 11:57:59 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k124si6654758vke.195.2017.01.25.11.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 11:57:59 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v5 2/4] mm: Add functions to support extra actions on swap in/out
Date: Wed, 25 Jan 2017 12:57:14 -0700
Message-Id: <4706f9a6c626df850d1442f0051395d34ed0b448.1485362562.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1485362562.git.khalid.aziz@oracle.com>
References: <cover.1485362562.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1485362562.git.khalid.aziz@oracle.com>
References: <cover.1485362562.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, davem@davemloft.net, arnd@arndb.de
Cc: Khalid Aziz <khalid.aziz@oracle.com>, kirill.shutemov@linux.intel.com, mhocko@suse.com, jmarchan@redhat.com, vbabka@suse.cz, dan.j.williams@intel.com, lstoakes@gmail.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, mgorman@suse.de, hughd@google.com, vdavydov.dev@gmail.com, minchan@kernel.org, namit@vmware.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

If a processor supports special metadata for a page, for example ADI
version tags on SPARC M7, this metadata must be saved when the page is
swapped out. The same metadata must be restored when the page is swapped
back in. This patch adds two new architecture specific functions -
arch_do_swap_page() to be called when a page is swapped in,
arch_unmap_one() to be called when a page is being unmapped for swap
out.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
v5:
	- Replaced set_swp_pte() function with new architecture
          functions arch_do_swap_page() and arch_unmap_one()

 include/asm-generic/pgtable.h | 16 ++++++++++++++++
 mm/memory.c                   |  1 +
 mm/rmap.c                     |  2 ++
 3 files changed, 19 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index c4f8fd2..cccc4e4 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -282,6 +282,22 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
+#ifndef __HAVE_ARCH_DO_SWAP_PAGE
+static inline void arch_do_swap_page(struct mm_struct *mm, unsigned long addr,
+				     pte_t pte, pte_t orig_pte)
+{
+
+}
+#endif
+
+#ifndef __HAVE_ARCH_UNMAP_ONE
+static inline void arch_unmap_one(struct mm_struct *mm, unsigned long addr,
+				  pte_t pte, pte_t orig_pte)
+{
+
+}
+#endif
+
 #ifndef __HAVE_ARCH_PGD_OFFSET_GATE
 #define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
 #endif
diff --git a/mm/memory.c b/mm/memory.c
index e18c57b..10abae2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2643,6 +2643,7 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	if (pte_swp_soft_dirty(orig_pte))
 		pte = pte_mksoft_dirty(pte);
 	set_pte_at(vma->vm_mm, fe->address, fe->pte, pte);
+	arch_do_swap_page(vma->vm_mm, fe->address, pte, orig_pte);
 	if (page == swapcache) {
 		do_page_add_anon_rmap(page, vma, fe->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true, false);
diff --git a/mm/rmap.c b/mm/rmap.c
index 1ef3640..940939d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1539,6 +1539,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		swp_pte = swp_entry_to_pte(entry);
 		if (pte_soft_dirty(pteval))
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
+		arch_unmap_one(mm, address, swp_pte, pteval);
 		set_pte_at(mm, address, pte, swp_pte);
 	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
@@ -1572,6 +1573,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		swp_pte = swp_entry_to_pte(entry);
 		if (pte_soft_dirty(pteval))
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
+		arch_unmap_one(mm, address, swp_pte, pteval);
 		set_pte_at(mm, address, pte, swp_pte);
 	} else
 		dec_mm_counter(mm, mm_counter_file(page));
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
