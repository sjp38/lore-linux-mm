Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C67D7440D52
	for <linux-mm@kvack.org>; Sat, 11 Nov 2017 15:20:06 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 207so7727519pgc.21
        for <linux-mm@kvack.org>; Sat, 11 Nov 2017 12:20:06 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m15si10960327pga.413.2017.11.11.12.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Nov 2017 12:20:05 -0800 (PST)
Subject: [PATCH v2 3/4] mm: replace pmd_write with pmd_access_permitted in
 fault + gup paths
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 11 Nov 2017 12:11:50 -0800
Message-ID: <151043111049.2842.15241454964150083466.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151043109403.2842.11607911965674122836.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151043109403.2842.11607911965674122836.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The 'access_permitted' helper is used in the gup-fast path and goes
beyond the simple _PAGE_RW check to also:

* validate that the mapping is writable from a protection keys
  standpoint

* validate that the pte has _PAGE_USER set since all fault paths where
  pmd_write is must be referencing user-memory.

Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/sparc/mm/gup.c |    2 +-
 fs/dax.c            |    3 ++-
 mm/hmm.c            |    4 ++--
 mm/huge_memory.c    |    4 ++--
 mm/memory.c         |    2 +-
 5 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index 5ae2d0a01a70..33c0f8bb0f33 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -75,7 +75,7 @@ static int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 	if (!(pmd_val(pmd) & _PAGE_VALID))
 		return 0;
 
-	if (write && !pmd_write(pmd))
+	if (!pmd_access_permitted(pmd, write))
 		return 0;
 
 	refs = 0;
diff --git a/fs/dax.c b/fs/dax.c
index f001d8c72a06..3cc40eebbb9e 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -620,7 +620,8 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 
 			if (pfn != pmd_pfn(*pmdp))
 				goto unlock_pmd;
-			if (!pmd_dirty(*pmdp) && !pmd_write(*pmdp))
+			if (!pmd_dirty(*pmdp)
+					&& !pmd_access_permitted(*pmdp, WRITE))
 				goto unlock_pmd;
 
 			flush_cache_page(vma, address, pfn);
diff --git a/mm/hmm.c b/mm/hmm.c
index a88a847bccba..cbdd47bf6a48 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -391,11 +391,11 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (pmd_protnone(pmd))
 			return hmm_vma_walk_clear(start, end, walk);
 
-		if (write_fault && !pmd_write(pmd))
+		if (!pmd_access_permitted(pmd, write_fault))
 			return hmm_vma_walk_clear(start, end, walk);
 
 		pfn = pmd_pfn(pmd) + pte_index(addr);
-		flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
+		flag |= pmd_access_permitted(pmd, WRITE) ? HMM_PFN_WRITE : 0;
 		for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
 			pfns[i] = hmm_pfn_t_from_pfn(pfn) | flag;
 		return 0;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1e4e11275856..411ba3ba45f8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -875,7 +875,7 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 	 */
 	WARN_ONCE(flags & FOLL_COW, "mm: In follow_devmap_pmd with FOLL_COW set");
 
-	if (flags & FOLL_WRITE && !pmd_write(*pmd))
+	if (!pmd_access_permitted(*pmd, flags & FOLL_WRITE))
 		return NULL;
 
 	if (pmd_present(*pmd) && pmd_devmap(*pmd))
@@ -1379,7 +1379,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
  */
 static inline bool can_follow_write_pmd(pmd_t pmd, unsigned int flags)
 {
-	return pmd_write(pmd) ||
+	return pmd_access_permitted(pmd, WRITE) ||
 	       ((flags & FOLL_FORCE) && (flags & FOLL_COW) && pmd_dirty(pmd));
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 64f86beadcca..157fd4320bb3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4020,7 +4020,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
 				return do_huge_pmd_numa_page(&vmf, orig_pmd);
 
-			if (dirty && !pmd_write(orig_pmd)) {
+			if (dirty && !pmd_access_permitted(orig_pmd, WRITE)) {
 				ret = wp_huge_pmd(&vmf, orig_pmd);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
