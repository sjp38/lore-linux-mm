Date: Tue, 01 Jul 2003 07:42:56 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <15810000.1057070575@[10.10.2.4]>
In-Reply-To: <20030701074915.GQ3040@dualathlon.random>
References: <Pine.LNX.4.53.0307010238210.22576@skynet> <20030701022516.GL3040@dualathlon.random> <20030701032531.GC20413@holomorphy.com> <20030701043902.GP3040@dualathlon.random> <20030701063317.GF20413@holomorphy.com> <20030701074915.GQ3040@dualathlon.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, William Lee Irwin III <wli@holomorphy.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> last time we got stuck in objrmap due the complexty complains ( the
> i_mmap links all the vmas of the file, not only the ones relative to the
> range that maps the page that we need to free, so we would end checking
> lots of vmas multiple times for each page)

Here's my proposed solution for this, coded by myself and Dave McCracken
(who actually made the damned thing work ;-)) 

Basically we group vmas with identical start and end address together into
one linked list, which works great for most situations (though there's a 
theoretical case where everyone maps different ranges, but I suspect 
nobody actually does that). Ranges can overlap (unlike an earlier proposal
I made), and the list of ranges is sorted by start address. 

Because we still need to walk the rest of the list, turning the list of
address ranges into a simple tree doesn't help much (seems like instead of
O(n) we get O(log(n)) + O(n/2)) ... I guess a 2-d tree would help, but it
seems like overkill & overcomplex to me.

It's in 72-mjb2, and seems to work fine, but increases i_shared_sem
contention in extreme cases - wli has a nice RCU patch for this that I need
to integrate before re-adding this to my tree. Any comments on the patch
would be much appreciated.

M.

diff -urpN -X /home/fletch/.diff.exclude 820-numa_large_pages/include/linux/fs.h 830-list-of-lists/include/linux/fs.h
--- 820-numa_large_pages/include/linux/fs.h	Sat Jun 14 18:37:37 2003
+++ 830-list-of-lists/include/linux/fs.h	Wed Jun 18 23:29:38 2003
@@ -331,6 +331,25 @@ struct address_space {
 	struct address_space	*assoc_mapping;	/* ditto */
 };
 
+/*
+ * s = address_space, r = address_range, v = vma
+ *
+ * s - r - r - r - r - r
+ *     |   |   |   |   |
+ *     v   v   v   v   v
+ *     |   |           |
+ *     v   v           v
+ *         |
+ *         v
+ */
+struct address_range {
+	unsigned long		start;	/* Offset into file in PAGE_SIZE units */
+	unsigned long		end;	/* Offset of end in PAGE_SIZE units */
+					/* (last page, not beginning of next region) */
+	struct list_head	ranges;
+	struct list_head	vmas;
+};
+
 struct block_device {
 	struct list_head	bd_hash;
 	atomic_t		bd_count;
diff -urpN -X /home/fletch/.diff.exclude 820-numa_large_pages/mm/memory.c 830-list-of-lists/mm/memory.c
--- 820-numa_large_pages/mm/memory.c	Wed Jun 18 23:29:14 2003
+++ 830-list-of-lists/mm/memory.c	Wed Jun 18 23:29:38 2003
@@ -1076,36 +1076,76 @@ out:
 	return ret;
 }
 
-static void vmtruncate_list(struct list_head *head, unsigned long pgoff)
+/*
+ * Helper function for invalidate_mmap_range().
+ * Both hba and hlen are page numbers in PAGE_SIZE units.
+ * An hlen of zero blows away the entire portion file after hba.
+ */
+static void 
+invalidate_mmap_range_list(struct list_head *head,
+			   unsigned long const hba,
+			   unsigned long const hlen)
 {
-	unsigned long start, end, len, diff;
-	struct vm_area_struct *vma;
-	struct list_head *curr;
-
-	list_for_each(curr, head) {
-		vma = list_entry(curr, struct vm_area_struct, shared);
-		start = vma->vm_start;
-		end = vma->vm_end;
-		len = end - start;
-
-		/* mapping wholly truncated? */
-		if (vma->vm_pgoff >= pgoff) {
-			zap_page_range(vma, start, len);
+	unsigned long hea;	/* last page of hole. */
+	struct address_range *range;
+	struct vm_area_struct *vp;
+	unsigned long zba;
+	unsigned long zea;
+
+	hea = hba + hlen - 1;	/* avoid overflow. */
+	if (hea < hba)
+		hea = ULONG_MAX;
+	list_for_each_entry(range, head, ranges) {
+		if ((hea < range->start) || (hba > range->end))
 			continue;
+		zba = (hba <= range->start) ? range->start : hba;
+		zea = (hea > range->end) ? range->end : hea;
+		list_for_each_entry(vp, &range->vmas, shared) {
+			zap_page_range(vp,
+				       ((zba - range->start) << PAGE_SHIFT) +
+				       vp->vm_start,
+				       (zea - zba + 1) << PAGE_SHIFT);
 		}
+	}
+}
 
-		/* mapping wholly unaffected? */
-		len = len >> PAGE_SHIFT;
-		diff = pgoff - vma->vm_pgoff;
-		if (diff >= len)
-			continue;
+/**
+ * invalidate_mmap_range - invalidate the portion of all mmaps
+ * in the specified address_space corresponding to the specified
+ * page range in the underlying file.
+ * @address_space: the address space containing mmaps to be invalidated.
+ * @holebegin: byte in first page to invalidate, relative to the start of
+ * the underlying file.  This will be rounded down to a PAGE_SIZE
+ * boundary.  Note that this is different from vmtruncate(), which
+ * must keep the partial page.  In contrast, we must get rid of
+ * partial pages.
+ * @holelen: size of prospective hole in bytes.  This will be rounded
+ * up to a PAGE_SIZE boundary.  A holelen of zero truncates to the
+ * end of the file.
+ */
+void 
+invalidate_mmap_range(struct address_space *mapping,
+		      loff_t const holebegin,
+		      loff_t const holelen)
+{
+	unsigned long hba = holebegin >> PAGE_SHIFT;
+	unsigned long hlen = (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
-		/* Ok, partially affected.. */
-		start += diff << PAGE_SHIFT;
-		len = (len - diff) << PAGE_SHIFT;
-		zap_page_range(vma, start, len);
+	/* Check for overflow. */
+	if (sizeof(holelen) > sizeof(hlen)) {
+		long long holeend =
+			(holebegin + holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
+
+		if (holeend & ~(long long)ULONG_MAX)
+			hlen = ULONG_MAX - hba + 1;
 	}
-}
+	down(&mapping->i_shared_sem);
+	if (unlikely(!list_empty(&mapping->i_mmap)))
+		invalidate_mmap_range_list(&mapping->i_mmap, hba, hlen);
+	if (unlikely(!list_empty(&mapping->i_mmap_shared)))
+		invalidate_mmap_range_list(&mapping->i_mmap_shared, hba, hlen);
+	up(&mapping->i_shared_sem);
+}       
 
 /*
  * Handle all mappings that got truncated by a "truncate()"
@@ -1125,12 +1165,7 @@ int vmtruncate(struct inode * inode, lof
 		goto do_expand;
 	inode->i_size = offset;
 	pgoff = (offset + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	down(&mapping->i_shared_sem);
-	if (unlikely(!list_empty(&mapping->i_mmap)))
-		vmtruncate_list(&mapping->i_mmap, pgoff);
-	if (unlikely(!list_empty(&mapping->i_mmap_shared)))
-		vmtruncate_list(&mapping->i_mmap_shared, pgoff);
-	up(&mapping->i_shared_sem);
+	invalidate_mmap_range(mapping, offset + PAGE_SIZE - 1, 0);
 	truncate_inode_pages(mapping, offset);
 	goto out_truncate;
 
diff -urpN -X /home/fletch/.diff.exclude 820-numa_large_pages/mm/mmap.c 830-list-of-lists/mm/mmap.c
--- 820-numa_large_pages/mm/mmap.c	Wed Jun 18 21:49:20 2003
+++ 830-list-of-lists/mm/mmap.c	Wed Jun 18 23:29:38 2003
@@ -306,6 +306,56 @@ static void __vma_link_rb(struct mm_stru
 	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
 }
 
+static void vma_add (struct vm_area_struct *vma, 
+						struct list_head *range_list)
+{
+	struct address_range *range;
+	struct list_head *prev, *next;
+	unsigned long start = vma->vm_pgoff;
+	unsigned long end = vma->vm_pgoff +
+		(((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) - 1);
+
+	/* First, look for an existing range that matches ours */
+	prev = range_list;
+	list_for_each(next, range_list) {
+		range = list_entry(next, struct address_range, ranges);
+		if (range->start > start)
+			break;    /* this list is sorted by start */
+		if ((range->start == start) && (range->end == end)) {
+			goto found;
+		}
+		prev = next;
+	}
+
+	/* 
+	 * No existing range was found that matched.
+	 * But we left range pointing at the last address range 
+	 * that was <= start ... so we can just shove ourselves in there.
+	 */
+	range = kmalloc(sizeof(struct address_range), GFP_KERNEL);
+	range->start = start;
+	range->end   = end;
+	INIT_LIST_HEAD(&range->ranges);
+	INIT_LIST_HEAD(&range->vmas);
+	list_add(&range->ranges, prev);
+found:
+	list_add_tail(&vma->shared, &range->vmas);
+}
+
+static void vma_del (struct vm_area_struct *vma)
+{
+	struct address_range *range;
+	struct list_head *next;
+
+	next = vma->shared.next;	/* stash the range list we're on */
+	list_del(&vma->shared);		/* remove us from the list of vmas */
+	if (list_empty(next)) {		/* we were the last vma for range */
+		range = list_entry(next, struct address_range, vmas);
+		list_del(&range->ranges);
+		kfree(range);
+	}
+}
+
 static inline void __vma_link_file(struct vm_area_struct *vma)
 {
 	struct file * file;
@@ -319,9 +369,9 @@ static inline void __vma_link_file(struc
 			atomic_dec(&inode->i_writecount);
 
 		if (vma->vm_flags & VM_SHARED)
-			list_add_tail(&vma->shared, &mapping->i_mmap_shared);
+			vma_add(vma, &mapping->i_mmap_shared);
 		else
-			list_add_tail(&vma->shared, &mapping->i_mmap);
+			vma_add(vma, &mapping->i_mmap);
 	}
 }
 
@@ -1224,6 +1274,7 @@ int split_vma(struct mm_struct * mm, str
 	      unsigned long addr, int new_below)
 {
 	struct vm_area_struct *new;
+	struct address_space *mapping = NULL;
 
 	if (mm->map_count >= MAX_MAP_COUNT)
 		return -ENOMEM;
@@ -1237,6 +1288,9 @@ int split_vma(struct mm_struct * mm, str
 
 	INIT_LIST_HEAD(&new->shared);
 
+	if (vma->vm_file)
+		mapping = vma->vm_file->f_dentry->d_inode->i_mapping;
+
 	if (new_below) {
 		new->vm_end = addr;
 		move_vma_start(vma, addr);
@@ -1244,6 +1298,16 @@ int split_vma(struct mm_struct * mm, str
 		vma->vm_end = addr;
 		new->vm_start = addr;
 		new->vm_pgoff += ((addr - vma->vm_start) >> PAGE_SHIFT);
+	}
+
+	if (mapping) {
+		down(&mapping->i_shared_sem);
+		vma_del(vma);
+		if (vma->vm_flags & VM_SHARED)
+			vma_add(vma, &mapping->i_mmap_shared);
+		else
+			vma_add(vma, &mapping->i_mmap);
+		up(&mapping->i_shared_sem);
 	}
 
 	if (new->vm_file)
diff -urpN -X /home/fletch/.diff.exclude 820-numa_large_pages/mm/rmap.c 830-list-of-lists/mm/rmap.c
--- 820-numa_large_pages/mm/rmap.c	Wed Jun 18 21:49:20 2003
+++ 830-list-of-lists/mm/rmap.c	Wed Jun 18 23:29:38 2003
@@ -37,6 +37,12 @@
 
 /* #define DEBUG_RMAP */
 
+#define foreach_vma_starting_below(vma, listp, shared, page)		\
+	list_for_each_entry_while(vma, listp, shared,			\
+		page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT) )
+
+
+	
 /*
  * Shared pages have a chain of pte_chain structures, used to locate
  * all the mappings to this page. We only need a pointer to the pte
@@ -205,8 +211,10 @@ static int
 page_referenced_obj(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+	struct address_range *range;
 	struct vm_area_struct *vma;
 	int referenced = 0;
+	unsigned long index = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
 	if (!page->pte.mapcount)
 		return 0;
@@ -220,11 +228,23 @@ page_referenced_obj(struct page *page)
 	if (down_trylock(&mapping->i_shared_sem))
 		return 1;
 	
-	list_for_each_entry(vma, &mapping->i_mmap, shared)
-		referenced += page_referenced_obj_one(vma, page);
-
-	list_for_each_entry(vma, &mapping->i_mmap_shared, shared)
-		referenced += page_referenced_obj_one(vma, page);
+	list_for_each_entry(range, &mapping->i_mmap, ranges) {
+		if (range->start > index)
+			break;     /* Sorted by start address => we are done */
+		if (range->end < index)
+			continue;
+		list_for_each_entry(vma, &range->vmas, shared)
+			referenced += page_referenced_obj_one(vma, page);
+	}
+
+	list_for_each_entry(range, &mapping->i_mmap_shared, ranges) {
+		if (range->start > index)
+			break;     /* Sorted by start address => we are done */
+		if (range->end < index)
+			continue;
+		list_for_each_entry(vma, &range->vmas, shared)
+			referenced += page_referenced_obj_one(vma, page);
+	}
 
 	up(&mapping->i_shared_sem);
 
@@ -512,7 +532,9 @@ static int
 try_to_unmap_obj(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+	struct address_range *range;
 	struct vm_area_struct *vma;
+	unsigned long index = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	int ret = SWAP_AGAIN;
 
 	if (!mapping)
@@ -524,16 +546,28 @@ try_to_unmap_obj(struct page *page)
 	if (down_trylock(&mapping->i_shared_sem))
 		return ret;
 	
-	list_for_each_entry(vma, &mapping->i_mmap, shared) {
-		ret = try_to_unmap_obj_one(vma, page);
-		if (ret == SWAP_FAIL || !page->pte.mapcount)
-			goto out;
+	list_for_each_entry(range, &mapping->i_mmap, ranges) {
+		if (range->start > index)
+			break;     /* Sorted by start address => we are done */
+		if (range->end < index)
+			continue;
+		list_for_each_entry(vma, &range->vmas, shared) {
+			ret = try_to_unmap_obj_one(vma, page);
+			if (ret == SWAP_FAIL || !page->pte.mapcount)
+				goto out;
+		}
 	}
 
-	list_for_each_entry(vma, &mapping->i_mmap_shared, shared) {
-		ret = try_to_unmap_obj_one(vma, page);
-		if (ret == SWAP_FAIL || !page->pte.mapcount)
-			goto out;
+	list_for_each_entry(range, &mapping->i_mmap_shared, ranges) {
+		if (range->start > index)
+			break;     /* Sorted by start address => we are done */
+		if (range->end < index)
+			continue;
+		list_for_each_entry(vma, &range->vmas, shared) {
+			ret = try_to_unmap_obj_one(vma, page);
+			if (ret == SWAP_FAIL || !page->pte.mapcount)
+				goto out;
+		}
 	}
 
 out:
@@ -752,7 +786,9 @@ out:
 int page_convert_anon(struct page *page)
 {
 	struct address_space *mapping;
+	struct address_range *range;
 	struct vm_area_struct *vma;
+	unsigned long index = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct pte_chain *pte_chain = NULL;
 	pte_t *pte;
 	int err = 0;
@@ -788,41 +824,54 @@ int page_convert_anon(struct page *page)
 	 */
 	pte_chain_unlock(page);
 
-	list_for_each_entry(vma, &mapping->i_mmap, shared) {
-		if (!pte_chain) {
-			pte_chain = pte_chain_alloc(GFP_KERNEL);
+	list_for_each_entry(range, &mapping->i_mmap, ranges) {
+		if (range->start > index)
+			break;     /* Sorted by start address => we are done */
+		if (range->end < index)
+			continue;
+		list_for_each_entry(vma, &range->vmas, shared) {
 			if (!pte_chain) {
-				err = -ENOMEM;
-				goto out_unlock;
+				pte_chain = pte_chain_alloc(GFP_KERNEL);
+				if (!pte_chain) {
+					err = -ENOMEM;
+					goto out_unlock;
+				}
 			}
+			spin_lock(&vma->vm_mm->page_table_lock);
+			pte = find_pte(vma, page, NULL);
+			if (pte) {
+				/* Make sure this isn't a duplicate */
+				page_remove_rmap(page, pte);
+				pte_chain = page_add_rmap(page, pte, pte_chain);
+				pte_unmap(pte);
+			}
+			spin_unlock(&vma->vm_mm->page_table_lock);
 		}
-		spin_lock(&vma->vm_mm->page_table_lock);
-		pte = find_pte(vma, page, NULL);
-		if (pte) {
-			/* Make sure this isn't a duplicate */
-			page_remove_rmap(page, pte);
-			pte_chain = page_add_rmap(page, pte, pte_chain);
-			pte_unmap(pte);
-		}
-		spin_unlock(&vma->vm_mm->page_table_lock);
-	}
-	list_for_each_entry(vma, &mapping->i_mmap_shared, shared) {
-		if (!pte_chain) {
-			pte_chain = pte_chain_alloc(GFP_KERNEL);
+	}
+
+	list_for_each_entry(range, &mapping->i_mmap_shared, ranges) {
+		if (range->start > index)
+			break;     /* Sorted by start address => we are done */
+		if (range->end < index)
+			continue;
+		list_for_each_entry(vma, &range->vmas, shared) {
 			if (!pte_chain) {
-				err = -ENOMEM;
-				goto out_unlock;
+				pte_chain = pte_chain_alloc(GFP_KERNEL);
+				if (!pte_chain) {
+					err = -ENOMEM;
+					goto out_unlock;
+				}
 			}
+			spin_lock(&vma->vm_mm->page_table_lock);
+			pte = find_pte(vma, page, NULL);
+			if (pte) {
+				/* Make sure this isn't a duplicate */
+				page_remove_rmap(page, pte);
+				pte_chain = page_add_rmap(page, pte, pte_chain);
+				pte_unmap(pte);
+			}
+			spin_unlock(&vma->vm_mm->page_table_lock);
 		}
-		spin_lock(&vma->vm_mm->page_table_lock);
-		pte = find_pte(vma, page, NULL);
-		if (pte) {
-			/* Make sure this isn't a duplicate */
-			page_remove_rmap(page, pte);
-			pte_chain = page_add_rmap(page, pte, pte_chain);
-			pte_unmap(pte);
-		}
-		spin_unlock(&vma->vm_mm->page_table_lock);
 	}
 
 out_unlock:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
