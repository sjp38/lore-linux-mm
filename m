Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 8908B6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 06:59:26 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id ee20so3933543lab.11
        for <linux-mm@kvack.org>; Mon, 21 Jan 2013 03:59:24 -0800 (PST)
Subject: [PATCH] mm/rmap: rename anon_vma_unlock() => anon_vma_unlock_write()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 21 Jan 2013 15:59:21 +0400
Message-ID: <20130121115921.23500.7190.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>

comment in 4fc3f1d66b1ef0d7b8dc11f4ff1cc510f78b37d6 ("mm/rmap, migration:
Make rmap_walk_anon() and try_to_unmap_anon() more scalable") says:

| Rename anon_vma_[un]lock() => anon_vma_[un]lock_write(),
| to make it clearer that it's an exclusive write-lock in
| that case - suggested by Rik van Riel.

But that commit renames only anon_vma_lock()

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
---
 include/linux/huge_mm.h |    2 +-
 include/linux/rmap.h    |    2 +-
 mm/huge_memory.c        |    6 +++---
 mm/mmap.c               |    4 ++--
 mm/mremap.c             |    2 +-
 mm/rmap.c               |    6 +++---
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 1d76f8c..ee1c244 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -113,7 +113,7 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
 		anon_vma_lock_write(__anon_vma);			\
-		anon_vma_unlock(__anon_vma);				\
+		anon_vma_unlock_write(__anon_vma);			\
 		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
 		       pmd_trans_huge(*____pmd));			\
 	} while (0)
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index c20635c..6dacb93 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -123,7 +123,7 @@ static inline void anon_vma_lock_write(struct anon_vma *anon_vma)
 	down_write(&anon_vma->root->rwsem);
 }
 
-static inline void anon_vma_unlock(struct anon_vma *anon_vma)
+static inline void anon_vma_unlock_write(struct anon_vma *anon_vma)
 {
 	up_write(&anon_vma->root->rwsem);
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6001ee6..62acd6b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1842,7 +1842,7 @@ int split_huge_page(struct page *page)
 
 	BUG_ON(PageCompound(page));
 out_unlock:
-	anon_vma_unlock(anon_vma);
+	anon_vma_unlock_write(anon_vma);
 	put_anon_vma(anon_vma);
 out:
 	return ret;
@@ -2364,7 +2364,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		BUG_ON(!pmd_none(*pmd));
 		set_pmd_at(mm, address, pmd, _pmd);
 		spin_unlock(&mm->page_table_lock);
-		anon_vma_unlock(vma->anon_vma);
+		anon_vma_unlock_write(vma->anon_vma);
 		goto out;
 	}
 
@@ -2372,7 +2372,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * All pages are isolated and locked so anon_vma rmap
 	 * can't run anymore.
 	 */
-	anon_vma_unlock(vma->anon_vma);
+	anon_vma_unlock_write(vma->anon_vma);
 
 	__collapse_huge_page_copy(pte, new_page, vma, address, ptl);
 	pte_unmap(pte);
diff --git a/mm/mmap.c b/mm/mmap.c
index 35730ee..0fb6805 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -800,7 +800,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 		anon_vma_interval_tree_post_update_vma(vma);
 		if (adjust_next)
 			anon_vma_interval_tree_post_update_vma(next);
-		anon_vma_unlock(anon_vma);
+		anon_vma_unlock_write(anon_vma);
 	}
 	if (mapping)
 		mutex_unlock(&mapping->i_mmap_mutex);
@@ -3001,7 +3001,7 @@ static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 		if (!__test_and_clear_bit(0, (unsigned long *)
 					  &anon_vma->root->rb_root.rb_node))
 			BUG();
-		anon_vma_unlock(anon_vma);
+		anon_vma_unlock_write(anon_vma);
 	}
 }
 
diff --git a/mm/mremap.c b/mm/mremap.c
index e1031e1..7b26643 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -134,7 +134,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	pte_unmap(new_pte - 1);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (anon_vma)
-		anon_vma_unlock(anon_vma);
+		anon_vma_unlock_write(anon_vma);
 	if (mapping)
 		mutex_unlock(&mapping->i_mmap_mutex);
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 2c78f8c..92b4529 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -105,7 +105,7 @@ static inline void anon_vma_free(struct anon_vma *anon_vma)
 	 */
 	if (rwsem_is_locked(&anon_vma->root->rwsem)) {
 		anon_vma_lock_write(anon_vma);
-		anon_vma_unlock(anon_vma);
+		anon_vma_unlock_write(anon_vma);
 	}
 
 	kmem_cache_free(anon_vma_cachep, anon_vma);
@@ -191,7 +191,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 			avc = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
-		anon_vma_unlock(anon_vma);
+		anon_vma_unlock_write(anon_vma);
 
 		if (unlikely(allocated))
 			put_anon_vma(allocated);
@@ -308,7 +308,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	vma->anon_vma = anon_vma;
 	anon_vma_lock_write(anon_vma);
 	anon_vma_chain_link(vma, avc, anon_vma);
-	anon_vma_unlock(anon_vma);
+	anon_vma_unlock_write(anon_vma);
 
 	return 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
