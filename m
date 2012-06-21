Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id E38606B00A4
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 05:02:12 -0400 (EDT)
Date: Thu, 21 Jun 2012 11:01:57 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 2/7] mm: get unmapped area from VMA tree
Message-ID: <20120621090157.GG27816@cmpxchg.org>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
 <1340057126-31143-3-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340057126-31143-3-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On Mon, Jun 18, 2012 at 06:05:21PM -0400, Rik van Riel wrote:
> From: Rik van Riel <riel@surriel.com>
> 
> Change the generic implementations of arch_get_unmapped_area(_topdown)
> to use the free space info in the VMA rbtree. This makes it possible
> to find free address space in O(log(N)) complexity.
> 
> For bottom-up allocations, we pick the lowest hole that is large
> enough for our allocation. For topdown allocations, we pick the
> highest hole of sufficient size.
> 
> For topdown allocations, we need to keep track of the highest
> mapped VMA address, because it might be below mm->mmap_base,
> and we only keep track of free space to the left of each VMA
> in the VMA tree.  It is tempting to try and keep track of
> the free space to the right of each VMA when running in
> topdown mode, but that gets us into trouble when running on
> x86, where a process can switch direction in the middle of
> execve.
> 
> We have to leave the mm->free_area_cache and mm->largest_hole_size
> in place for now, because the architecture specific versions still
> use those.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  include/linux/mm_types.h |    1 +
>  mm/mmap.c                |  270 +++++++++++++++++++++++++++++++---------------
>  2 files changed, 184 insertions(+), 87 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index bf56d66..8ccb4e1 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -307,6 +307,7 @@ struct mm_struct {
>  	unsigned long task_size;		/* size of task vm space */
>  	unsigned long cached_hole_size; 	/* if non-zero, the largest hole below free_area_cache */
>  	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
> +	unsigned long highest_vma;		/* highest vma end address */

It's not clear from the name that this is an end address.  Would
highest_vm_end be better?

>  	pgd_t * pgd;
>  	atomic_t mm_users;			/* How many users with user space? */
>  	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 1963ef9..40c848e 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -4,6 +4,7 @@
>   * Written by obz.
>   *
>   * Address space accounting code	<alan@lxorguk.ukuu.org.uk>
> + * Rbtree get_unmapped_area Copyright (C) 2012  Rik van Riel
>   */
>  
>  #include <linux/slab.h>
> @@ -250,6 +251,17 @@ static void adjust_free_gap(struct vm_area_struct *vma)
>  	rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
>  }
>  
> +static unsigned long node_free_hole(struct rb_node *node)
> +{
> +	struct vm_area_struct *vma;
> +
> +	if (!node)
> +		return 0;
> +
> +	vma = container_of(node, struct vm_area_struct, vm_rb);
> +	return vma->free_gap;
> +}
> +
>  /*
>   * Unlink a file-based vm structure from its prio_tree, to hide
>   * vma from rmap and vmtruncate before freeing its page tables.
> @@ -386,12 +398,16 @@ void validate_mm(struct mm_struct *mm)
>  	int bug = 0;
>  	int i = 0;
>  	struct vm_area_struct *tmp = mm->mmap;
> +	unsigned long highest_address = 0;
>  	while (tmp) {
>  		if (tmp->free_gap != max_free_space(&tmp->vm_rb))
>  			printk("free space %lx, correct %lx\n", tmp->free_gap, max_free_space(&tmp->vm_rb)), bug = 1;
> +		highest_address = tmp->vm_end;
>  		tmp = tmp->vm_next;
>  		i++;
>  	}
> +	if (highest_address != mm->highest_vma)
> +		printk("mm->highest_vma %lx, found %lx\n", mm->highest_vma, highest_address), bug = 1;
>  	if (i != mm->map_count)
>  		printk("map_count %d vm_next %d\n", mm->map_count, i), bug = 1;
>  	i = browse_rb(&mm->mm_rb);
> @@ -449,6 +465,9 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
>  	/* Propagate the new free gap between next and us up the tree. */
>  	if (vma->vm_next)
>  		adjust_free_gap(vma->vm_next);
> +	else
> +		/* This is the VMA with the highest address. */
> +		mm->highest_vma = vma->vm_end;
>  }
>  
>  static void __vma_link_file(struct vm_area_struct *vma)
> @@ -648,6 +667,8 @@ again:			remove_next = 1 + (end > next->vm_end);
>  	vma->vm_start = start;
>  	vma->vm_end = end;
>  	vma->vm_pgoff = pgoff;
> +	if (!next)
> +		mm->highest_vma = end;
>  	if (adjust_next) {
>  		next->vm_start += adjust_next << PAGE_SHIFT;
>  		next->vm_pgoff += adjust_next;
> @@ -1456,13 +1477,29 @@ unacct_error:
>   * This function "knows" that -ENOMEM has the bits set.
>   */
>  #ifndef HAVE_ARCH_UNMAPPED_AREA
> +struct rb_node *continue_next_right(struct rb_node *node)
> +{
> +	struct rb_node *prev;
> +
> +	while ((prev = node) && (node = rb_parent(node))) {
> +		if (prev == node->rb_right)
> +			continue;
> +
> +		if (node->rb_right)
> +			return node->rb_right;
> +	}
> +
> +	return NULL;
> +}
> +
>  unsigned long
>  arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  		unsigned long len, unsigned long pgoff, unsigned long flags)
>  {
>  	struct mm_struct *mm = current->mm;
> -	struct vm_area_struct *vma;
> -	unsigned long start_addr;
> +	struct vm_area_struct *vma = NULL;
> +	struct rb_node *rb_node;
> +	unsigned long lower_limit = TASK_UNMAPPED_BASE;
>  
>  	if (len > TASK_SIZE)
>  		return -ENOMEM;
> @@ -1477,40 +1514,76 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
>  		    (!vma || addr + len <= vma->vm_start))
>  			return addr;
>  	}
> -	if (len > mm->cached_hole_size) {
> -	        start_addr = addr = mm->free_area_cache;
> -	} else {
> -	        start_addr = addr = TASK_UNMAPPED_BASE;
> -	        mm->cached_hole_size = 0;
> -	}
>  
> -full_search:
> -	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
> -		/* At this point:  (!vma || addr < vma->vm_end). */
> -		if (TASK_SIZE - len < addr) {
> -			/*
> -			 * Start a new search - just in case we missed
> -			 * some holes.
> -			 */
> -			if (start_addr != TASK_UNMAPPED_BASE) {
> -				addr = TASK_UNMAPPED_BASE;
> -			        start_addr = addr;
> -				mm->cached_hole_size = 0;
> -				goto full_search;
> +	/* Find the left-most free area of sufficient size. */
> +	for (addr = 0, rb_node = mm->mm_rb.rb_node; rb_node; ) {
> +		unsigned long vma_start;
> +		int found_here = 0;
> +
> +		vma = rb_to_vma(rb_node);
> +
> +		if (vma->vm_start > len) {

vmas can abut, and vma->vm_end == vma->vm_next->vm_start.  Should this
be >=?

> +			if (!vma->vm_prev) {
> +				/* This is the left-most VMA. */
> +				if (vma->vm_start - len >= lower_limit) {
> +					addr = lower_limit;
> +					goto found_addr;
> +				}
> +			} else {
> +				/* Is this hole large enough? Remember it. */
> +				vma_start = max(vma->vm_prev->vm_end, lower_limit);
> +				if (vma->vm_start - len >= vma_start) {
> +					addr = vma_start;
> +					found_here = 1;
> +				}
>  			}
> -			return -ENOMEM;
>  		}
> -		if (!vma || addr + len <= vma->vm_start) {
> -			/*
> -			 * Remember the place where we stopped the search:
> -			 */
> -			mm->free_area_cache = addr + len;
> -			return addr;
> +
> +		/* Go left if it looks promising. */
> +		if (node_free_hole(rb_node->rb_left) >= len &&
> +					vma->vm_start - len >= lower_limit) {
> +			rb_node = rb_node->rb_left;
> +			continue;

If we already are at a vma whose start has a lower address than the
overall length, does it make sense to check for a left hole?
I.e. shouldn't this be inside the if (vma->vm_start > len) block?

>  		}
> -		if (addr + mm->cached_hole_size < vma->vm_start)
> -		        mm->cached_hole_size = vma->vm_start - addr;
> -		addr = vma->vm_end;
> +
> +		if (!found_here && node_free_hole(rb_node->rb_right) >= len) {
> +			/* Last known hole is to the right of this subtree. */
> +			rb_node = rb_node->rb_right;
> +			continue;
> +		} else if (!addr) {
> +			rb_node = continue_next_right(rb_node);
> +			continue;
> +		}
> +
> +		/* This is the left-most hole. */
> +		goto found_addr;
>  	}
> +
> +	/*
> +	 * There is not enough space to the left of any VMA.
> +	 * Check the far right-hand side of the VMA tree.
> +	 */
> +	rb_node = mm->mm_rb.rb_node;
> +	while (rb_node->rb_right)
> +		rb_node = rb_node->rb_right;
> +	vma = rb_to_vma(rb_node);
> +	addr = vma->vm_end;

Unless I missed something, we only reach here when
continue_next_right(rb_node) above returned NULL.  And if it does, the
rb_node it was passed was the right-most node in the tree, so we could
do something like

	} else if (!addr) {
		struct rb_node *rb_right = continue_next_right(rb_node);
		if (!rb_right)
			break;
		rb_node = rb_right;
		continue;
	}

above and then save the lookup after the loop.

Also, dereferencing mm->mm_rb.rb_node unconditionally after the loop
assumes that the tree always contains at least one vma.  Is this
guaranteed for all architectures?

> -fail:
> -	/*
> -	 * if hint left us with no space for the requested
> -	 * mapping then try again:
> -	 *
> -	 * Note: this is different with the case of bottomup
> -	 * which does the fully line-search, but we use find_vma
> -	 * here that causes some holes skipped.
> -	 */
> -	if (start_addr != mm->mmap_base) {
> -		mm->free_area_cache = mm->mmap_base;
> -		mm->cached_hole_size = 0;
> -		goto try_again;
> +		if (!found_here && node_free_hole(rb_node->rb_left) >= len) {
> +			/* Last known hole is to the right of this subtree. */

"to the left"

So, nothing major from me, either.  The patch looks really good!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
