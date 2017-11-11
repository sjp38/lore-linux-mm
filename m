Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67F332802A5
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 19:53:03 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v78so8974953pfk.8
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 16:53:03 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id c193si10704464pfc.25.2017.11.10.16.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 16:53:02 -0800 (PST)
Subject: [PATCH 4/4] mm: replace pte_write with pte_access_permitted in
 fault + gup paths
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 10 Nov 2017 16:44:47 -0800
Message-ID: <151036108744.32713.17165900700881849202.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151036106541.32713.16875776773735515483.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151036106541.32713.16875776773735515483.stgit@dwillia2-desk3.amr.corp.intel.com>
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
index b2b4d4263768..bb6542c47b08 100644
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
index cbdd47bf6a48..3d2e49fd851a 100644
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
index 157fd4320bb3..a8cbc2c3e3c9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3922,7 +3922,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
 	if (unlikely(!pte_same(*vmf->pte, entry)))
 		goto unlock;
 	if (vmf->flags & FAULT_FLAG_WRITE) {
-		if (!pte_write(entry))
+		if (!pte_access_permitted(entry, WRITE))
 			return do_wp_page(vmf);
 		entry = pte_mkdirty(entry);
 	}
@@ -4308,7 +4308,7 @@ int follow_phys(struct vm_area_struct *vma,
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
