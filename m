Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 569586B025E
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 12:52:53 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so445857982pab.1
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 09:52:53 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 62si36168094pfc.60.2016.09.06.09.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 09:52:51 -0700 (PDT)
Subject: [PATCH 5/5] mm: cleanup pfn_t usage in track_pfn_insert()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 06 Sep 2016 09:49:47 -0700
Message-ID: <147318058712.30325.12749411762275637099.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Now that track_pfn_insert() is no longer used in the DAX path, it no
longer needs to comprehend pfn_t values.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/pat.c             |    4 ++--
 include/asm-generic/pgtable.h |    4 ++--
 mm/memory.c                   |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index ecb1b69c1651..e8aed3a30e29 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -971,7 +971,7 @@ int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 }
 
 int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-		     pfn_t pfn)
+		     unsigned long pfn)
 {
 	enum page_cache_mode pcm;
 
@@ -979,7 +979,7 @@ int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
 		return 0;
 
 	/* Set prot based on lookup */
-	pcm = lookup_memtype(pfn_t_to_phys(pfn));
+	pcm = lookup_memtype(PFN_PHYS(pfn));
 	*prot = __pgprot((pgprot_val(*prot) & (~_PAGE_CACHE_MASK)) |
 			 cachemode2protval(pcm));
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index d4458b6dbfb4..f9a4f708227d 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -559,7 +559,7 @@ static inline int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
  * by vm_insert_pfn().
  */
 static inline int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-				   pfn_t pfn)
+				   unsigned long pfn)
 {
 	return 0;
 }
@@ -594,7 +594,7 @@ extern int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 			   unsigned long pfn, unsigned long addr,
 			   unsigned long size);
 extern int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-			    pfn_t pfn);
+			    unsigned long pfn);
 extern int track_pfn_copy(struct vm_area_struct *vma);
 extern void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 			unsigned long size);
diff --git a/mm/memory.c b/mm/memory.c
index 83be99d9d8a1..5d4826a28e3f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1637,7 +1637,7 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
-	if (track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV)))
+	if (track_pfn_insert(vma, &pgprot, pfn))
 		return -EINVAL;
 
 	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
