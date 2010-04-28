Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1F1B16B01F2
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 13:47:54 -0400 (EDT)
Date: Wed, 28 Apr 2010 13:47:19 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH] take all anon_vma locks in anon_vma_lock
Message-ID: <20100428134719.32e8011b@annuminas.surriel.com>
In-Reply-To: <20100428162305.GX510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-3-git-send-email-mel@csn.ul.ie>
	<20100427231007.GA510@random.random>
	<20100428091555.GB15815@csn.ul.ie>
	<20100428153525.GR510@random.random>
	<20100428155558.GI15815@csn.ul.ie>
	<20100428162305.GX510@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Take all the locks for all the anon_vmas in anon_vma_lock, this properly
excludes migration and the transparent hugepage code from VMA changes done
by mmap/munmap/mprotect/expand_stack/etc...

Also document the locking rules for the same_vma list in the anon_vma_chain
and remove the anon_vma_lock call from expand_upwards, which does not need it.

Signed-off-by: Rik van Riel <riel@redhat.com>

--- 
Posted quickly as an RFC patch, only compile tested so far.
Andrea, Mel, does this look like a reasonable approach?

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index d25bd22..1eef42c 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -52,11 +52,15 @@ struct anon_vma {
  * all the anon_vmas associated with this VMA.
  * The "same_anon_vma" list contains the anon_vma_chains
  * which link all the VMAs associated with this anon_vma.
+ *
+ * The "same_vma" list is locked by either having mm->mmap_sem
+ * locked for writing, or having mm->mmap_sem locked for reading
+ * AND holding the mm->page_table_lock.
  */
 struct anon_vma_chain {
 	struct vm_area_struct *vma;
 	struct anon_vma *anon_vma;
-	struct list_head same_vma;   /* locked by mmap_sem & page_table_lock */
+	struct list_head same_vma;	/* see above */
 	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
 };
 
@@ -90,11 +94,14 @@ static inline struct anon_vma *page_anon_vma(struct page *page)
 	return page_rmapping(page);
 }
 
-static inline void anon_vma_lock(struct vm_area_struct *vma)
+static inline void anon_vma_lock(struct vm_area_struct *vma, void *nest_lock)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
-	if (anon_vma)
-		spin_lock(&anon_vma->lock);
+	if (anon_vma) {
+		struct anon_vma_chain *avc;
+		list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+			spin_lock_nest_lock(&avc->anon_vma->lock, nest_lock);
+	}
 }
 
 static inline void anon_vma_unlock(struct vm_area_struct *vma)
diff --git a/mm/mmap.c b/mm/mmap.c
index f90ea92..2c13bbb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -452,7 +452,7 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 		spin_lock(&mapping->i_mmap_lock);
 		vma->vm_truncate_count = mapping->truncate_count;
 	}
-	anon_vma_lock(vma);
+	anon_vma_lock(vma, &mm->mmap_sem);
 
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	__vma_link_file(vma);
@@ -1705,12 +1705,11 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 		return -EFAULT;
 
 	/*
-	 * We must make sure the anon_vma is allocated
-	 * so that the anon_vma locking is not a noop.
+	 * Unlike expand_downwards, we do not need to take the anon_vma lock,
+	 * because we leave vma->vm_start and vma->pgoff untouched. 
+	 * This means rmap lookups of pages inside this VMA stay valid
+	 * throughout the stack expansion.
 	 */
-	if (unlikely(anon_vma_prepare(vma)))
-		return -ENOMEM;
-	anon_vma_lock(vma);
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
@@ -1721,7 +1720,6 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 	if (address < PAGE_ALIGN(address+4))
 		address = PAGE_ALIGN(address+4);
 	else {
-		anon_vma_unlock(vma);
 		return -ENOMEM;
 	}
 	error = 0;
@@ -1737,7 +1735,6 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 		if (!error)
 			vma->vm_end = address;
 	}
-	anon_vma_unlock(vma);
 	return error;
 }
 #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
@@ -1749,6 +1746,7 @@ static int expand_downwards(struct vm_area_struct *vma,
 				   unsigned long address)
 {
 	int error;
+	struct mm_struct *mm = vma->vm_mm;
 
 	/*
 	 * We must make sure the anon_vma is allocated
@@ -1762,7 +1760,8 @@ static int expand_downwards(struct vm_area_struct *vma,
 	if (error)
 		return error;
 
-	anon_vma_lock(vma);
+	spin_lock(&mm->page_table_lock);
+	anon_vma_lock(vma, &mm->page_table_lock);
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
@@ -1784,6 +1783,8 @@ static int expand_downwards(struct vm_area_struct *vma,
 		}
 	}
 	anon_vma_unlock(vma);
+	spin_unlock(&mm->page_table_lock);
+
 	return error;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
