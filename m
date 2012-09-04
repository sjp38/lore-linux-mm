Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 651226B0069
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:21:18 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so9747862pbb.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:21:18 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 5/7] mm rmap: remove vma_address check for address inside vma
Date: Tue,  4 Sep 2012 02:20:55 -0700
Message-Id: <1346750457-12385-6-git-send-email-walken@google.com>
In-Reply-To: <1346750457-12385-1-git-send-email-walken@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org

In file and anon rmap, we use interval trees to find potentially relevant
vmas and then call vma_address() to find the virtual address the given
page might be found at in these vmas. vma_address() used to include a
check that the returned address falls within the limits of the vma, but
this check isn't necessary now that we always use interval trees in rmap:
the interval tree just doesn't return any vmas which this check would find
to be irrelevant. As a result, we can replace the use of -EFAULT error code
(which then needed to be checked in every call site) with a VM_BUG_ON().

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/huge_memory.c |    4 ----
 mm/rmap.c        |   48 +++++++++++++++++++++---------------------------
 2 files changed, 21 insertions(+), 31 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fe119cb71b41..91b65f962320 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1432,8 +1432,6 @@ static void __split_huge_page(struct page *page,
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long addr = vma_address(page, vma);
 		BUG_ON(is_vma_temporary_stack(vma));
-		if (addr == -EFAULT)
-			continue;
 		mapcount += __split_huge_page_splitting(page, vma, addr);
 	}
 	/*
@@ -1458,8 +1456,6 @@ static void __split_huge_page(struct page *page,
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long addr = vma_address(page, vma);
 		BUG_ON(is_vma_temporary_stack(vma));
-		if (addr == -EFAULT)
-			continue;
 		mapcount2 += __split_huge_page_map(page, vma, addr);
 	}
 	if (mapcount != mapcount2)
diff --git a/mm/rmap.c b/mm/rmap.c
index 9c61bf387fd1..28777412de62 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -510,22 +510,26 @@ void page_unlock_anon_vma(struct anon_vma *anon_vma)
 
 /*
  * At what user virtual address is page expected in @vma?
- * Returns virtual address or -EFAULT if page's index/offset is not
- * within the range mapped the @vma.
  */
-inline unsigned long
-vma_address(struct page *page, struct vm_area_struct *vma)
+static inline unsigned long
+__vma_address(struct page *page, struct vm_area_struct *vma)
 {
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-	unsigned long address;
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		pgoff = page->index << huge_page_order(page_hstate(page));
-	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
-	if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {
-		/* page should be within @vma mapping range */
-		return -EFAULT;
-	}
+
+	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+}
+
+inline unsigned long
+vma_address(struct page *page, struct vm_area_struct *vma)
+{
+	unsigned long address = __vma_address(page, vma);
+
+	/* page should be within @vma mapping range */
+	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
+
 	return address;
 }
 
@@ -535,6 +539,7 @@ vma_address(struct page *page, struct vm_area_struct *vma)
  */
 unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 {
+	unsigned long address;
 	if (PageAnon(page)) {
 		struct anon_vma *page__anon_vma = page_anon_vma(page);
 		/*
@@ -550,7 +555,10 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 			return -EFAULT;
 	} else
 		return -EFAULT;
-	return vma_address(page, vma);
+	address = __vma_address(page, vma);
+	if (unlikely(address < vma->vm_start || address >= vma->vm_end))
+		return -EFAULT;
+	return address;
 }
 
 /*
@@ -624,8 +632,8 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	address = vma_address(page, vma);
-	if (address == -EFAULT)		/* out of vma range */
+	address = __vma_address(page, vma);
+	if (unlikely(address < vma->vm_start || address >= vma->vm_end))
 		return 0;
 	pte = page_check_address(page, vma->vm_mm, address, &ptl, 1);
 	if (!pte)			/* the page is not in this mm */
@@ -732,8 +740,6 @@ static int page_referenced_anon(struct page *page,
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
-		if (address == -EFAULT)
-			continue;
 		/*
 		 * If we are reclaiming on behalf of a cgroup, skip
 		 * counting on behalf of references from different
@@ -799,8 +805,6 @@ static int page_referenced_file(struct page *page,
 
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
-		if (address == -EFAULT)
-			continue;
 		/*
 		 * If we are reclaiming on behalf of a cgroup, skip
 		 * counting on behalf of references from different
@@ -904,8 +908,6 @@ static int page_mkclean_file(struct address_space *mapping, struct page *page)
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		if (vma->vm_flags & VM_SHARED) {
 			unsigned long address = vma_address(page, vma);
-			if (address == -EFAULT)
-				continue;
 			ret += page_mkclean_one(page, vma, address);
 		}
 	}
@@ -1468,8 +1470,6 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 			continue;
 
 		address = vma_address(page, vma);
-		if (address == -EFAULT)
-			continue;
 		ret = try_to_unmap_one(page, vma, address, flags);
 		if (ret != SWAP_AGAIN || !page_mapped(page))
 			break;
@@ -1508,8 +1508,6 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
-		if (address == -EFAULT)
-			continue;
 		ret = try_to_unmap_one(page, vma, address, flags);
 		if (ret != SWAP_AGAIN || !page_mapped(page))
 			goto out;
@@ -1684,8 +1682,6 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
-		if (address == -EFAULT)
-			continue;
 		ret = rmap_one(page, vma, address, arg);
 		if (ret != SWAP_AGAIN)
 			break;
@@ -1707,8 +1703,6 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
-		if (address == -EFAULT)
-			continue;
 		ret = rmap_one(page, vma, address, arg);
 		if (ret != SWAP_AGAIN)
 			break;
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
