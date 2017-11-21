Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 652DD6B0260
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:16:19 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id k84so4778890pfj.18
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 11:16:19 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id c25si11666758pgf.517.2017.11.21.11.16.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 11:16:18 -0800 (PST)
Subject: [PATCH v3 5/5] mm: replace pte_write with pte_access_permitted in
 fault + gup paths
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 21 Nov 2017 11:08:03 -0800
Message-ID: <151129128299.37405.7432659716165048225.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151129125625.37405.15953656230804875212.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151129125625.37405.15953656230804875212.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org

The 'access_permitted' helper is used in the gup-fast path and goes
beyond the simple _PAGE_RW check to also:

* validate that the mapping is writable from a protection keys
  standpoint

* validate that the pte has _PAGE_USER set since all fault paths where
  pte_write is must be referencing user-memory.

Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/gup.c    |    2 +-
 mm/hmm.c    |    4 ++--
 mm/memory.c |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index dfcde13f289a..85cc822fd403 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -66,7 +66,7 @@ static int follow_pfn_pte(struct vm_area_struct *vma, unsigned long address,
  */
 static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
 {
-	return pte_write(pte) ||
+	return pte_access_permitted(pte, WRITE) ||
 		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_dirty(pte));
 }
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 93718a391611..3a5c172af560 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -456,11 +456,11 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			continue;
 		}
 
-		if (write_fault && !pte_write(pte))
+		if (!pte_access_permitted(pte, write_fault))
 			goto fault;
 
 		pfns[i] = hmm_pfn_t_from_pfn(pte_pfn(pte)) | flag;
-		pfns[i] |= pte_write(pte) ? HMM_PFN_WRITE : 0;
+		pfns[i] |= pte_access_permitted(pte, WRITE) ? HMM_PFN_WRITE : 0;
 		continue;
 
 fault:
diff --git a/mm/memory.c b/mm/memory.c
index 07eef971dbeb..5eb3d2524bdc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3948,7 +3948,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
 	if (unlikely(!pte_same(*vmf->pte, entry)))
 		goto unlock;
 	if (vmf->flags & FAULT_FLAG_WRITE) {
-		if (!pte_write(entry))
+		if (!pte_access_permitted(entry, WRITE))
 			return do_wp_page(vmf);
 		entry = pte_mkdirty(entry);
 	}
@@ -4336,7 +4336,7 @@ int follow_phys(struct vm_area_struct *vma,
 		goto out;
 	pte = *ptep;
 
-	if ((flags & FOLL_WRITE) && !pte_write(pte))
+	if (!pte_access_permitted(pte, flags & FOLL_WRITE))
 		goto unlock;
 
 	*prot = pgprot_val(pte_pgprot(pte));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
