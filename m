Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 8C1826B0073
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 18:06:08 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 2/7] mm: get unmapped area from VMA tree
Date: Mon, 18 Jun 2012 18:05:21 -0400
Message-Id: <1340057126-31143-3-git-send-email-riel@redhat.com>
In-Reply-To: <1340057126-31143-1-git-send-email-riel@redhat.com>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, Rik van Riel <riel@redhat.com>

From: Rik van Riel <riel@surriel.com>

Change the generic implementations of arch_get_unmapped_area(_topdown)
to use the free space info in the VMA rbtree. This makes it possible
to find free address space in O(log(N)) complexity.

For bottom-up allocations, we pick the lowest hole that is large
enough for our allocation. For topdown allocations, we pick the
highest hole of sufficient size.

For topdown allocations, we need to keep track of the highest
mapped VMA address, because it might be below mm->mmap_base,
and we only keep track of free space to the left of each VMA
in the VMA tree.  It is tempting to try and keep track of
the free space to the right of each VMA when running in
topdown mode, but that gets us into trouble when running on
x86, where a process can switch direction in the middle of
execve.

We have to leave the mm->free_area_cache and mm->largest_hole_size
in place for now, because the architecture specific versions still
use those.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mm_types.h |    1 +
 mm/mmap.c                |  270 +++++++++++++++++++++++++++++++---------------
 2 files changed, 184 insertions(+), 87 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bf56d66..8ccb4e1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -307,6 +307,7 @@ struct mm_struct {
 	unsigned long task_size;		/* size of task vm space */
 	unsigned long cached_hole_size; 	/* if non-zero, the largest hole below free_area_cache */
 	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
+	unsigned long highest_vma;		/* highest vma end address */
 	pgd_t * pgd;
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
diff --git a/mm/mmap.c b/mm/mmap.c
index 1963ef9..40c848e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -4,6 +4,7 @@
  * Written by obz.
  *
  * Address space accounting code	<alan@lxorguk.ukuu.org.uk>
+ * Rbtree get_unmapped_area Copyright (C) 2012  Rik van Riel
  */
 
 #include <linux/slab.h>
@@ -250,6 +251,17 @@ static void adjust_free_gap(struct vm_area_struct *vma)
 	rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
 }
 
+static unsigned long node_free_hole(struct rb_node *node)
+{
+	struct vm_area_struct *vma;
+
+	if (!node)
+		return 0;
+
+	vma = container_of(node, struct vm_area_struct, vm_rb);
+	return vma->free_gap;
+}
+
 /*
  * Unlink a file-based vm structure from its prio_tree, to hide
  * vma from rmap and vmtruncate before freeing its page tables.
@@ -386,12 +398,16 @@ void validate_mm(struct mm_struct *mm)
 	int bug = 0;
 	int i = 0;
 	struct vm_area_struct *tmp = mm->mmap;
+	unsigned long highest_address = 0;
 	while (tmp) {
 		if (tmp->free_gap != max_free_space(&tmp->vm_rb))
 			printk("free space %lx, correct %lx\n", tmp->free_gap, max_free_space(&tmp->vm_rb)), bug = 1;
+		highest_address = tmp->vm_end;
 		tmp = tmp->vm_next;
 		i++;
 	}
+	if (highest_address != mm->highest_vma)
+		printk("mm->highest_vma %lx, found %lx\n", mm->highest_vma, highest_address), bug = 1;
 	if (i != mm->map_count)
 		printk("map_count %d vm_next %d\n", mm->map_count, i), bug = 1;
 	i = browse_rb(&mm->mm_rb);
@@ -449,6 +465,9 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 	/* Propagate the new free gap between next and us up the tree. */
 	if (vma->vm_next)
 		adjust_free_gap(vma->vm_next);
+	else
+		/* This is the VMA with the highest address. */
+		mm->highest_vma = vma->vm_end;
 }
 
 static void __vma_link_file(struct vm_area_struct *vma)
@@ -648,6 +667,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_pgoff = pgoff;
+	if (!next)
+		mm->highest_vma = end;
 	if (adjust_next) {
 		next->vm_start += adjust_next << PAGE_SHIFT;
 		next->vm_pgoff += adjust_next;
@@ -1456,13 +1477,29 @@ unacct_error:
  * This function "knows" that -ENOMEM has the bits set.
  */
 #ifndef HAVE_ARCH_UNMAPPED_AREA
+struct rb_node *continue_next_right(struct rb_node *node)
+{
+	struct rb_node *prev;
+
+	while ((prev = node) && (node = rb_parent(node))) {
+		if (prev == node->rb_right)
+			continue;
+
+		if (node->rb_right)
+			return node->rb_right;
+	}
+
+	return NULL;
+}
+
 unsigned long
 arch_get_unmapped_area(struct file *filp, unsigned long addr,
 		unsigned long len, unsigned long pgoff, unsigned long flags)
 {
 	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
-	unsigned long start_addr;
+	struct vm_area_struct *vma = NULL;
+	struct rb_node *rb_node;
+	unsigned long lower_limit = TASK_UNMAPPED_BASE;
 
 	if (len > TASK_SIZE)
 		return -ENOMEM;
@@ -1477,40 +1514,76 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
-	if (len > mm->cached_hole_size) {
-	        start_addr = addr = mm->free_area_cache;
-	} else {
-	        start_addr = addr = TASK_UNMAPPED_BASE;
-	        mm->cached_hole_size = 0;
-	}
 
-full_search:
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
-		/* At this point:  (!vma || addr < vma->vm_end). */
-		if (TASK_SIZE - len < addr) {
-			/*
-			 * Start a new search - just in case we missed
-			 * some holes.
-			 */
-			if (start_addr != TASK_UNMAPPED_BASE) {
-				addr = TASK_UNMAPPED_BASE;
-			        start_addr = addr;
-				mm->cached_hole_size = 0;
-				goto full_search;
+	/* Find the left-most free area of sufficient size. */
+	for (addr = 0, rb_node = mm->mm_rb.rb_node; rb_node; ) {
+		unsigned long vma_start;
+		int found_here = 0;
+
+		vma = rb_to_vma(rb_node);
+
+		if (vma->vm_start > len) {
+			if (!vma->vm_prev) {
+				/* This is the left-most VMA. */
+				if (vma->vm_start - len >= lower_limit) {
+					addr = lower_limit;
+					goto found_addr;
+				}
+			} else {
+				/* Is this hole large enough? Remember it. */
+				vma_start = max(vma->vm_prev->vm_end, lower_limit);
+				if (vma->vm_start - len >= vma_start) {
+					addr = vma_start;
+					found_here = 1;
+				}
 			}
-			return -ENOMEM;
 		}
-		if (!vma || addr + len <= vma->vm_start) {
-			/*
-			 * Remember the place where we stopped the search:
-			 */
-			mm->free_area_cache = addr + len;
-			return addr;
+
+		/* Go left if it looks promising. */
+		if (node_free_hole(rb_node->rb_left) >= len &&
+					vma->vm_start - len >= lower_limit) {
+			rb_node = rb_node->rb_left;
+			continue;
 		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
-		addr = vma->vm_end;
+
+		if (!found_here && node_free_hole(rb_node->rb_right) >= len) {
+			/* Last known hole is to the right of this subtree. */
+			rb_node = rb_node->rb_right;
+			continue;
+		} else if (!addr) {
+			rb_node = continue_next_right(rb_node);
+			continue;
+		}
+
+		/* This is the left-most hole. */
+		goto found_addr;
 	}
+
+	/*
+	 * There is not enough space to the left of any VMA.
+	 * Check the far right-hand side of the VMA tree.
+	 */
+	rb_node = mm->mm_rb.rb_node;
+	while (rb_node->rb_right)
+		rb_node = rb_node->rb_right;
+	vma = rb_to_vma(rb_node);
+	addr = vma->vm_end;
+
+	/*
+	 * The right-most VMA ends below the lower limit. Can only happen
+	 * if a binary personality loads the stack below the executable.
+	 */
+	if (addr < lower_limit)
+		addr = lower_limit;
+
+ found_addr:
+	if (TASK_SIZE - len < addr)
+		return -ENOMEM;
+
+	/* This "free area" was not really free. Tree corrupted? */
+	VM_BUG_ON(find_vma_intersection(mm, addr, addr+len));
+
+	return addr;
 }
 #endif	
 
@@ -1528,14 +1601,31 @@ void arch_unmap_area(struct mm_struct *mm, unsigned long addr)
  * stack's low limit (the base):
  */
 #ifndef HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
+struct rb_node *continue_next_left(struct rb_node *node)
+{
+	struct rb_node *prev;
+
+	while ((prev = node) && (node = rb_parent(node))) {
+		if (prev == node->rb_left)
+			continue;
+
+		if (node->rb_left)
+			return node->rb_left;
+	}
+
+	return NULL;
+}
+
 unsigned long
 arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			  const unsigned long len, const unsigned long pgoff,
 			  const unsigned long flags)
 {
-	struct vm_area_struct *vma;
+	struct vm_area_struct *vma = NULL;
 	struct mm_struct *mm = current->mm;
-	unsigned long addr = addr0, start_addr;
+	unsigned long addr = addr0;
+	struct rb_node *rb_node = NULL;
+	unsigned long upper_limit = mm->mmap_base;
 
 	/* requested length too big for entire address space */
 	if (len > TASK_SIZE)
@@ -1553,68 +1643,65 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			return addr;
 	}
 
-	/* check if free_area_cache is useful for us */
-	if (len <= mm->cached_hole_size) {
- 	        mm->cached_hole_size = 0;
- 		mm->free_area_cache = mm->mmap_base;
- 	}
+	/* requested length too big; prevent integer underflow below */
+	if (len > upper_limit)
+		return -ENOMEM;
 
-try_again:
-	/* either no address requested or can't fit in requested address hole */
-	start_addr = addr = mm->free_area_cache;
+	/*
+	 * Does the highest VMA end far enough below the upper limit
+	 * of our search space?
+	 */
+	if (upper_limit - len > mm->highest_vma) {
+		addr = upper_limit - len;
+		goto found_addr;
+	}
 
-	if (addr < len)
-		goto fail;
+	/* Find the right-most free area of sufficient size. */
+	for (addr = 0, rb_node = mm->mm_rb.rb_node; rb_node; ) {
+		unsigned long vma_start;
+		int found_here = 0;
 
-	addr -= len;
-	do {
-		/*
-		 * Lookup failure means no vma is above this address,
-		 * else if new region fits below vma->vm_start,
-		 * return with success:
-		 */
-		vma = find_vma(mm, addr);
-		if (!vma || addr+len <= vma->vm_start)
-			/* remember the address as a hint for next time */
-			return (mm->free_area_cache = addr);
+		vma = container_of(rb_node, struct vm_area_struct, vm_rb);
 
- 		/* remember the largest hole we saw so far */
- 		if (addr + mm->cached_hole_size < vma->vm_start)
- 		        mm->cached_hole_size = vma->vm_start - addr;
+		/* Is this hole large enough? Remember it. */
+		vma_start = min(vma->vm_start, upper_limit);
+		if (vma_start > len) {
+			if (!vma->vm_prev ||
+			    (vma_start - len >= vma->vm_prev->vm_end)) {
+				addr = vma_start - len;
+				found_here = 1;
+			}
+		}
 
-		/* try just below the current vma->vm_start */
-		addr = vma->vm_start-len;
-	} while (len < vma->vm_start);
+		/* Go right if it looks promising. */
+		if (node_free_hole(rb_node->rb_right) >= len) {
+			if (upper_limit - len > vma->vm_end) {
+				rb_node = rb_node->rb_right;
+				continue;
+			}
+		}
 
-fail:
-	/*
-	 * if hint left us with no space for the requested
-	 * mapping then try again:
-	 *
-	 * Note: this is different with the case of bottomup
-	 * which does the fully line-search, but we use find_vma
-	 * here that causes some holes skipped.
-	 */
-	if (start_addr != mm->mmap_base) {
-		mm->free_area_cache = mm->mmap_base;
-		mm->cached_hole_size = 0;
-		goto try_again;
+		if (!found_here && node_free_hole(rb_node->rb_left) >= len) {
+			/* Last known hole is to the right of this subtree. */
+			rb_node = rb_node->rb_left;
+			continue;
+		} else if (!addr) {
+			rb_node = continue_next_left(rb_node);
+			continue;
+		}
+
+		/* This is the right-most hole. */
+		goto found_addr;
 	}
 
-	/*
-	 * A failed mmap() very likely causes application failure,
-	 * so fall back to the bottom-up function here. This scenario
-	 * can happen with large stack limits and large mmap()
-	 * allocations.
-	 */
-	mm->cached_hole_size = ~0UL;
-  	mm->free_area_cache = TASK_UNMAPPED_BASE;
-	addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
-	/*
-	 * Restore the topdown base:
-	 */
-	mm->free_area_cache = mm->mmap_base;
-	mm->cached_hole_size = ~0UL;
+	return -ENOMEM;
+
+ found_addr:
+	if (TASK_SIZE - len < addr)
+		return -ENOMEM;
+
+	/* This "free area" was not really free. Tree corrupted? */
+	VM_BUG_ON(find_vma_intersection(mm, addr, addr+len));
 
 	return addr;
 }
@@ -1828,6 +1915,8 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 				vma->vm_end = address;
 				if (vma->vm_next)
 					adjust_free_gap(vma->vm_next);
+				if (!vma->vm_next)
+					vma->vm_mm->highest_vma = vma->vm_end;
 				perf_event_mmap(vma);
 			}
 		}
@@ -2013,6 +2102,13 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 	*insertion_point = vma;
 	if (vma)
 		vma->vm_prev = prev;
+	else {
+		/* We just unmapped the highest VMA. */
+		if (prev)
+			mm->highest_vma = prev->vm_end;
+		else
+			mm->highest_vma = 0;
+	}
 	if (vma)
 		rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
 	tail_vma->vm_next = NULL;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
