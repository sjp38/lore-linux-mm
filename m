Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 55E296B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:14:40 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id x63so82311277ybg.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:14:40 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m128si1847781yba.164.2017.01.11.08.14.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 08:14:39 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v4 2/4] mm: Add function to support extra actions on swap in/out
Date: Wed, 11 Jan 2017 09:12:52 -0700
Message-Id: <c24c7a844c61d6f8d57dd3791ad7ab5f05305c6b.1483999591.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1483999591.git.khalid.aziz@oracle.com>
References: <cover.1483999591.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1483999591.git.khalid.aziz@oracle.com>
References: <cover.1483999591.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, davem@davemloft.net, arnd@arndb.de
Cc: Khalid Aziz <khalid.aziz@oracle.com>, kirill.shutemov@linux.intel.com, mhocko@suse.com, jmarchan@redhat.com, vbabka@suse.cz, dan.j.williams@intel.com, lstoakes@gmail.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, mgorman@suse.de, hughd@google.com, vdavydov.dev@gmail.com, minchan@kernel.org, namit@vmware.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

If a processor supports special metadata for a page, for example ADI
version tags on SPARC M7, this metadata must be saved when the page is
swapped out. The same metadata must be restored when the page is swapped
back in. This patch adds a new function, set_swp_pte_at(), to set pte
upon a swap in/out of page that allows kernel to take special action
like saving and restoring version tags after or before setting a new pte
or saving a swap pte. For architectures that do not need to take special
action on page swap, this function defaults to set_pte_at().

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
 include/asm-generic/pgtable.h | 5 +++++
 mm/memory.c                   | 2 +-
 mm/rmap.c                     | 4 ++--
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index c4f8fd2..5043e5a 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -294,6 +294,11 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 # define pte_accessible(mm, pte)	((void)(pte), 1)
 #endif
 
+#ifndef set_swp_pte_at
+#define set_swp_pte_at(mm, addr, ptep, pte, oldpte)	\
+		set_pte_at(mm, addr, ptep, pte)
+#endif
+
 #ifndef flush_tlb_fix_spurious_fault
 #define flush_tlb_fix_spurious_fault(vma, address) flush_tlb_page(vma, address)
 #endif
diff --git a/mm/memory.c b/mm/memory.c
index e18c57b..1cc3b55 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2642,7 +2642,7 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(orig_pte))
 		pte = pte_mksoft_dirty(pte);
-	set_pte_at(vma->vm_mm, fe->address, fe->pte, pte);
+	set_swp_pte_at(vma->vm_mm, fe->address, fe->pte, pte, orig_pte);
 	if (page == swapcache) {
 		do_page_add_anon_rmap(page, vma, fe->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true, false);
diff --git a/mm/rmap.c b/mm/rmap.c
index 1ef3640..d58cb94 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1539,7 +1539,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		swp_pte = swp_entry_to_pte(entry);
 		if (pte_soft_dirty(pteval))
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
-		set_pte_at(mm, address, pte, swp_pte);
+		set_swp_pte_at(mm, address, pte, swp_pte, pteval);
 	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
@@ -1572,7 +1572,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		swp_pte = swp_entry_to_pte(entry);
 		if (pte_soft_dirty(pteval))
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
-		set_pte_at(mm, address, pte, swp_pte);
+		set_swp_pte_at(mm, address, pte, swp_pte, pteval);
 	} else
 		dec_mm_counter(mm, mm_counter_file(page));
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
