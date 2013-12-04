Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 692566B00A5
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 19:10:25 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so22157619pbb.36
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 16:10:25 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id f4si24646103pbm.115.2013.12.03.16.10.23
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 16:10:24 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 8/9] mm/rmap: use rmap_walk() in page_referenced()
Date: Wed,  4 Dec 2013 09:12:19 +0900
Message-Id: <1386115940-21425-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386115940-21425-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have an infrastructure in rmap_walk() to handle difference
from variants of rmap traversing functions.

So, just use it in page_referenced().

In this patch, I change following things.

1. remove some variants of rmap traversing functions.
	cf> page_referenced_ksm, page_referenced_anon,
	page_referenced_file
2. introduce new struct page_referenced_arg and pass it to
page_referenced_one(), main function of rmap_walk, in order to
count reference, to store vm_flags and to check finish condition.
3. mechanical change to use rmap_walk() in page_referenced().

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 91b9719..3be6bb1 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -73,8 +73,6 @@ static inline void set_page_stable_node(struct page *page,
 struct page *ksm_might_need_to_copy(struct page *page,
 			struct vm_area_struct *vma, unsigned long address);
 
-int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
 int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
 
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 2462458..1da693d 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -184,7 +184,7 @@ static inline void page_dup_rmap(struct page *page)
 int page_referenced(struct page *, int is_locked,
 			struct mem_cgroup *memcg, unsigned long *vm_flags);
 int page_referenced_one(struct page *, struct vm_area_struct *,
-	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
+	unsigned long address, void *arg);
 
 #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
 
diff --git a/mm/ksm.c b/mm/ksm.c
index 646d45a..c9a28dd 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1891,61 +1891,6 @@ struct page *ksm_might_need_to_copy(struct page *page,
 	return new_page;
 }
 
-int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
-			unsigned long *vm_flags)
-{
-	struct stable_node *stable_node;
-	struct rmap_item *rmap_item;
-	unsigned int mapcount = page_mapcount(page);
-	int referenced = 0;
-	int search_new_forks = 0;
-
-	VM_BUG_ON(!PageKsm(page));
-	VM_BUG_ON(!PageLocked(page));
-
-	stable_node = page_stable_node(page);
-	if (!stable_node)
-		return 0;
-again:
-	hlist_for_each_entry(rmap_item, &stable_node->hlist, hlist) {
-		struct anon_vma *anon_vma = rmap_item->anon_vma;
-		struct anon_vma_chain *vmac;
-		struct vm_area_struct *vma;
-
-		anon_vma_lock_read(anon_vma);
-		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
-					       0, ULONG_MAX) {
-			vma = vmac->vma;
-			if (rmap_item->address < vma->vm_start ||
-			    rmap_item->address >= vma->vm_end)
-				continue;
-			/*
-			 * Initially we examine only the vma which covers this
-			 * rmap_item; but later, if there is still work to do,
-			 * we examine covering vmas in other mms: in case they
-			 * were forked from the original since ksmd passed.
-			 */
-			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
-				continue;
-
-			if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
-				continue;
-
-			referenced += page_referenced_one(page, vma,
-				rmap_item->address, &mapcount, vm_flags);
-			if (!search_new_forks || !mapcount)
-				break;
-		}
-		anon_vma_unlock_read(anon_vma);
-		if (!mapcount)
-			goto out;
-	}
-	if (!search_new_forks++)
-		goto again;
-out:
-	return referenced;
-}
-
 int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct stable_node *stable_node;
diff --git a/mm/rmap.c b/mm/rmap.c
index 8724c06..7944d4b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -656,17 +656,22 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 	return 1;
 }
 
+struct page_referenced_arg {
+	int mapcount;
+	int referenced;
+	unsigned long vm_flags;
+	struct mem_cgroup *memcg;
+};
 /*
- * Subfunctions of page_referenced: page_referenced_one called
- * repeatedly from either page_referenced_anon or page_referenced_file.
+ * arg: page_referenced_arg will be passed
  */
 int page_referenced_one(struct page *page, struct vm_area_struct *vma,
-			unsigned long address, unsigned int *mapcount,
-			unsigned long *vm_flags)
+			unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
 	int referenced = 0;
+	struct page_referenced_arg *pra = arg;
 
 	if (unlikely(PageTransHuge(page))) {
 		pmd_t *pmd;
@@ -678,13 +683,12 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		pmd = page_check_address_pmd(page, mm, address,
 					     PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
 		if (!pmd)
-			goto out;
+			return SWAP_AGAIN;
 
 		if (vma->vm_flags & VM_LOCKED) {
 			spin_unlock(ptl);
-			*mapcount = 0;	/* break early from loop */
-			*vm_flags |= VM_LOCKED;
-			goto out;
+			pra->vm_flags |= VM_LOCKED;
+			return SWAP_FAIL; /* To break the loop */
 		}
 
 		/* go ahead even if the pmd is pmd_trans_splitting() */
@@ -700,13 +704,12 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		 */
 		pte = page_check_address(page, mm, address, &ptl, 0);
 		if (!pte)
-			goto out;
+			return SWAP_AGAIN;
 
 		if (vma->vm_flags & VM_LOCKED) {
 			pte_unmap_unlock(pte, ptl);
-			*mapcount = 0;	/* break early from loop */
-			*vm_flags |= VM_LOCKED;
-			goto out;
+			pra->vm_flags |= VM_LOCKED;
+			return SWAP_FAIL; /* To break the loop */
 		}
 
 		if (ptep_clear_flush_young_notify(vma, address, pte)) {
@@ -723,113 +726,27 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		pte_unmap_unlock(pte, ptl);
 	}
 
-	(*mapcount)--;
-
-	if (referenced)
-		*vm_flags |= vma->vm_flags;
-out:
-	return referenced;
-}
-
-static int page_referenced_anon(struct page *page,
-				struct mem_cgroup *memcg,
-				unsigned long *vm_flags)
-{
-	unsigned int mapcount;
-	struct anon_vma *anon_vma;
-	pgoff_t pgoff;
-	struct anon_vma_chain *avc;
-	int referenced = 0;
-
-	anon_vma = page_lock_anon_vma_read(page);
-	if (!anon_vma)
-		return referenced;
-
-	mapcount = page_mapcount(page);
-	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
-		struct vm_area_struct *vma = avc->vma;
-		unsigned long address = vma_address(page, vma);
-		/*
-		 * If we are reclaiming on behalf of a cgroup, skip
-		 * counting on behalf of references from different
-		 * cgroups
-		 */
-		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
-			continue;
-		referenced += page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
-		if (!mapcount)
-			break;
+	if (referenced) {
+		pra->referenced++;
+		pra->vm_flags |= vma->vm_flags;
 	}
 
-	page_unlock_anon_vma_read(anon_vma);
-	return referenced;
+	pra->mapcount--;
+	if (!pra->mapcount)
+		return SWAP_SUCCESS; /* To break the loop */
+
+	return SWAP_AGAIN;
 }
 
-/**
- * page_referenced_file - referenced check for object-based rmap
- * @page: the page we're checking references on.
- * @memcg: target memory control group
- * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
- *
- * For an object-based mapped page, find all the places it is mapped and
- * check/clear the referenced flag.  This is done by following the page->mapping
- * pointer, then walking the chain of vmas it holds.  It returns the number
- * of references it found.
- *
- * This function is only called from page_referenced for object-based pages.
- */
-static int page_referenced_file(struct page *page,
-				struct mem_cgroup *memcg,
-				unsigned long *vm_flags)
+static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
 {
-	unsigned int mapcount;
-	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-	struct vm_area_struct *vma;
-	int referenced = 0;
-
-	/*
-	 * The caller's checks on page->mapping and !PageAnon have made
-	 * sure that this is a file page: the check for page->mapping
-	 * excludes the case just before it gets set on an anon page.
-	 */
-	BUG_ON(PageAnon(page));
-
-	/*
-	 * The page lock not only makes sure that page->mapping cannot
-	 * suddenly be NULLified by truncation, it makes sure that the
-	 * structure at mapping cannot be freed and reused yet,
-	 * so we can safely take mapping->i_mmap_mutex.
-	 */
-	BUG_ON(!PageLocked(page));
+	struct page_referenced_arg *pra = arg;
+	struct mem_cgroup *memcg = pra->memcg;
 
-	mutex_lock(&mapping->i_mmap_mutex);
-
-	/*
-	 * i_mmap_mutex does not stabilize mapcount at all, but mapcount
-	 * is more likely to be accurate if we note it after spinning.
-	 */
-	mapcount = page_mapcount(page);
-
-	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
-		unsigned long address = vma_address(page, vma);
-		/*
-		 * If we are reclaiming on behalf of a cgroup, skip
-		 * counting on behalf of references from different
-		 * cgroups
-		 */
-		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
-			continue;
-		referenced += page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
-		if (!mapcount)
-			break;
-	}
+	if (!mm_match_cgroup(vma->vm_mm, memcg))
+		return true;
 
-	mutex_unlock(&mapping->i_mmap_mutex);
-	return referenced;
+	return false;
 }
 
 /**
@@ -847,32 +764,47 @@ int page_referenced(struct page *page,
 		    struct mem_cgroup *memcg,
 		    unsigned long *vm_flags)
 {
-	int referenced = 0;
+	int ret;
 	int we_locked = 0;
+	struct page_referenced_arg pra = {
+		.mapcount = page_mapcount(page),
+		.memcg = memcg,
+	};
+	struct rmap_walk_control rwc = {
+		.rmap_one = page_referenced_one,
+		.arg = (void *)&pra,
+		.anon_lock = page_lock_anon_vma_read,
+	};
 
 	*vm_flags = 0;
-	if (page_mapped(page) && page_rmapping(page)) {
-		if (!is_locked && (!PageAnon(page) || PageKsm(page))) {
-			we_locked = trylock_page(page);
-			if (!we_locked) {
-				referenced++;
-				goto out;
-			}
-		}
-		if (unlikely(PageKsm(page)))
-			referenced += page_referenced_ksm(page, memcg,
-								vm_flags);
-		else if (PageAnon(page))
-			referenced += page_referenced_anon(page, memcg,
-								vm_flags);
-		else if (page->mapping)
-			referenced += page_referenced_file(page, memcg,
-								vm_flags);
-		if (we_locked)
-			unlock_page(page);
+	if (!page_mapped(page))
+		return 0;
+
+	if (!page_rmapping(page))
+		return 0;
+
+	if (!is_locked && (!PageAnon(page) || PageKsm(page))) {
+		we_locked = trylock_page(page);
+		if (!we_locked)
+			return 1;
 	}
-out:
-	return referenced;
+
+	/*
+	 * If we are reclaiming on behalf of a cgroup, skip
+	 * counting on behalf of references from different
+	 * cgroups
+	 */
+	if (memcg) {
+		rwc.invalid_vma = invalid_page_referenced_vma;
+	}
+
+	ret = rmap_walk(page, &rwc);
+	*vm_flags = pra.vm_flags;
+
+	if (we_locked)
+		unlock_page(page);
+
+	return pra.referenced;
 }
 
 static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
