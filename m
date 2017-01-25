Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AFCBF6B026A
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:27:02 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 194so281328646pgd.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:27:02 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id d20si9188338pfb.20.2017.01.25.10.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:27:01 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 05/12] mm, rmap: check all VMAs that PTE-mapped THP can be part of
Date: Wed, 25 Jan 2017 21:25:31 +0300
Message-Id: <20170125182538.86249-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Current rmap code can miss a VMA that maps PTE-mapped THP if the first
suppage of the THP was unmapped from the VMA.

We need to walk rmap for the whole range of offsets that THP covers, not
only the first one.

vma_address() also need to be corrected to check the range instead of
the first subpage.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/internal.h |  9 ++++++---
 mm/rmap.c     | 16 ++++++++++------
 2 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 03763f5c42c5..1f90c65df7fb 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -333,12 +333,15 @@ __vma_address(struct page *page, struct vm_area_struct *vma)
 static inline unsigned long
 vma_address(struct page *page, struct vm_area_struct *vma)
 {
-	unsigned long address = __vma_address(page, vma);
+	unsigned long start, end;
+
+	start = __vma_address(page, vma);
+	end = start + PAGE_SIZE * (hpage_nr_pages(page) - 1);
 
 	/* page should be within @vma mapping range */
-	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
+	VM_BUG_ON_VMA(end < vma->vm_start || start >= vma->vm_end, vma);
 
-	return address;
+	return max(start, vma->vm_start);
 }
 
 #else /* !CONFIG_MMU */
diff --git a/mm/rmap.c b/mm/rmap.c
index 0dff8accd629..c4bad599cc7b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1757,7 +1757,7 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 		bool locked)
 {
 	struct anon_vma *anon_vma;
-	pgoff_t pgoff;
+	pgoff_t pgoff_start, pgoff_end;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
@@ -1771,8 +1771,10 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 	if (!anon_vma)
 		return ret;
 
-	pgoff = page_to_pgoff(page);
-	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+	pgoff_start = page_to_pgoff(page);
+	pgoff_end = pgoff_start + hpage_nr_pages(page) - 1;
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root,
+			pgoff_start, pgoff_end) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
 
@@ -1810,7 +1812,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
 		bool locked)
 {
 	struct address_space *mapping = page_mapping(page);
-	pgoff_t pgoff;
+	pgoff_t pgoff_start, pgoff_end;
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
 
@@ -1825,10 +1827,12 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
 	if (!mapping)
 		return ret;
 
-	pgoff = page_to_pgoff(page);
+	pgoff_start = page_to_pgoff(page);
+	pgoff_end = pgoff_start + hpage_nr_pages(page) - 1;
 	if (!locked)
 		i_mmap_lock_read(mapping);
-	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+	vma_interval_tree_foreach(vma, &mapping->i_mmap,
+			pgoff_start, pgoff_end) {
 		unsigned long address = vma_address(page, vma);
 
 		cond_resched();
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
