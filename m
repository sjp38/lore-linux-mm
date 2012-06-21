Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 611FF6B00D3
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 10:47:20 -0400 (EDT)
Date: Thu, 21 Jun 2012 15:47:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH -mm 1/7] mm: track free size between VMAs in VMA rbtree
Message-ID: <20120621144716.GC3953@csn.ul.ie>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
 <1340057126-31143-2-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1340057126-31143-2-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On Mon, Jun 18, 2012 at 06:05:20PM -0400, Rik van Riel wrote:
> From: Rik van Riel <riel@surriel.com>
> 
> Track the size of free areas between VMAs in the VMA rbtree.
> 
> This will allow get_unmapped_area_* to find a free area of the
> right size in O(log(N)) time, instead of potentially having to
> do a linear walk across all the VMAs.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  include/linux/mm_types.h |    7 ++++
>  mm/internal.h            |    5 +++
>  mm/mmap.c                |   76 +++++++++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 87 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index dad95bd..bf56d66 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -213,6 +213,13 @@ struct vm_area_struct {
>  	struct rb_node vm_rb;
>  
>  	/*
> +	 * Largest free memory gap "behind" this VMA (in the direction mmap
> +	 * grows from), or of VMAs down the rb tree below us. This helps
> +	 * get_unmapped_area find a free area of the right size.
> +	 */
> +	unsigned long free_gap;
> +
> +	/*
>  	 * For areas with an address space and backing store,
>  	 * linkage into the address_space->i_mmap prio tree, or
>  	 * linkage to the list of like vmas hanging off its node, or
> diff --git a/mm/internal.h b/mm/internal.h
> index 2ba87fb..f59f97a 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -159,6 +159,11 @@ static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
>  	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
>  }
>  
> +static inline struct vm_area_struct *rb_to_vma(struct rb_node *node)
> +{
> +	return container_of(node, struct vm_area_struct, vm_rb);
> +}
> +
>  /*
>   * Called only in fault path via page_evictable() for a new page
>   * to determine if it's being mapped into a LOCKED vma.
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 3edfcdf..1963ef9 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -205,6 +205,51 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
>  	flush_dcache_mmap_unlock(mapping);
>  }
>  
> +static unsigned long max_free_space(struct rb_node *node)
> +{

Ok, this is not impenetrable but it took me a while to work out what it
means and even then I'm not sure I have it right. Certainly I'll have it
all forgotten in a weeks time.

At the *very least*, this function does not return "max free space" at
all. It instead gives information on the largest gap within a local part
of the rb tree. When used in conjunction with rb_augment_erase_end then the
end result is that free space information is propogated throughout the tree.

How about this?

/*
 * local_largest_gap - Returns the largest gap "nearby"
 *
 * This function is called when propgating "up" the rbtree for each
 * node encountered during the ascent to propogate free space
 * information.
 *
 * Take a simple example of a VMA in an rb tree
 *
 *   G1   LEFT      G2       VMA        G3       RIGHT  G4
 * H----|oooooo|----------|ooooooo|-------------|ooooo|----H
 *
 * This function returns the largest "local" gap to VMA. It will return
 * one of the following
 * 1. The gap between this VMA and the prev (G2
 * 2. The largest gap left of "LEFT"
 * 3. The largest gap left of "RIGHT"
 *
 * The gap is always searched to the left to bias what direction we are
 * searching for free space in. This left-most packing of VMAs is an
 * attempt to reduce address space fragmentation
 */

There are two consequences of this that I can see.

1. Insertion time must be higher now because a tree propagation of
   information is necessary. Searching time for adding a new VMA is
   lower but insertion time in the tree is higher. How high depends on
   the number of VMAs because it'll be related to the height of the RB
   tree. Please mention this in the changelog if I'm right. If I'm wrong,
   slap your knee heartily and laugh all the day long then write down
   what is right and stick that in the changelog or a comment.

2. How this largest_gap information is used is important. As I write
   this I am having serious trouble visualising how an RB tree walk that is
   ordered by address space layout can always find the smallest hole. It'll
   find *a* small hole and it should be able to do some packing but I
   fear that there is an increased risk of an adverse workload externally
   fragmenting the address space.

> +	struct vm_area_struct *vma, *prev, *left = NULL, *right = NULL;
> +	unsigned long largest = 0;
> +
> +	if (node->rb_left)
> +		left = rb_to_vma(node->rb_left);
> +	if (node->rb_right)
> +		right = rb_to_vma(node->rb_right);
> +
> +	/*
> +	 * Calculate the free gap size between us and the
> +	 * VMA to our left.
> +	 */
> +	vma = rb_to_vma(node);
> +	prev = vma->vm_prev;
> +
> +	if (prev)
> +		largest = vma->vm_start - prev->vm_end;
> +	else
> +		largest = vma->vm_start;
> +
> +	/* We propagate the largest of our own, or our children's free gaps. */
> +	if (left)
> +		largest = max(largest, left->free_gap);
> +	if (right)
> +		largest = max(largest, right->free_gap);
> +
> +	return largest;
> +}
> +
> +static void vma_rb_augment_cb(struct rb_node *node, void *__unused)
> +{
> +	struct vm_area_struct *vma;
> +
> +	vma = rb_to_vma(node);
> +
> +	vma->free_gap = max_free_space(node);
> +}
> +
> +static void adjust_free_gap(struct vm_area_struct *vma)
> +{
> +	rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
> +}
> +

That thing needs a comment too saying how it uses local_largest_gap (or
whatever you call it) to propagate information throughout the tree.

>  /*
>   * Unlink a file-based vm structure from its prio_tree, to hide
>   * vma from rmap and vmtruncate before freeing its page tables.
> @@ -342,6 +387,8 @@ void validate_mm(struct mm_struct *mm)
>  	int i = 0;
>  	struct vm_area_struct *tmp = mm->mmap;
>  	while (tmp) {
> +		if (tmp->free_gap != max_free_space(&tmp->vm_rb))
> +			printk("free space %lx, correct %lx\n", tmp->free_gap, max_free_space(&tmp->vm_rb)), bug = 1;
>  		tmp = tmp->vm_next;
>  		i++;
>  	}
> @@ -398,6 +445,10 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
>  {
>  	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
>  	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
> +	adjust_free_gap(vma);
> +	/* Propagate the new free gap between next and us up the tree. */
> +	if (vma->vm_next)
> +		adjust_free_gap(vma->vm_next);
>  }
>  
>  static void __vma_link_file(struct vm_area_struct *vma)
> @@ -473,11 +524,17 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
>  		struct vm_area_struct *prev)
>  {
>  	struct vm_area_struct *next = vma->vm_next;
> +	struct rb_node *deepest;
>  
>  	prev->vm_next = next;
> -	if (next)
> +	if (next) {
>  		next->vm_prev = prev;
> +		adjust_free_gap(next);
> +	}
> +	deepest = rb_augment_erase_begin(&vma->vm_rb);
>  	rb_erase(&vma->vm_rb, &mm->mm_rb);
> +	rb_augment_erase_end(deepest, vma_rb_augment_cb, NULL);
> +
>  	if (mm->mmap_cache == vma)
>  		mm->mmap_cache = prev;
>  }
> @@ -657,6 +714,15 @@ again:			remove_next = 1 + (end > next->vm_end);
>  	if (insert && file)
>  		uprobe_mmap(insert);
>  
> +	/* Adjust the rb tree for changes in the free gaps between VMAs. */
> +	adjust_free_gap(vma);
> +	if (insert)
> +		adjust_free_gap(insert);
> +	if (vma->vm_next && vma->vm_next != insert)
> +		adjust_free_gap(vma->vm_next);
> +	if (insert && insert->vm_next && insert->vm_next != vma)
> +		adjust_free_gap(insert->vm_next);
> +

I feel this should move into a helper that is right below adjust_free_gap
with bonus points for explaining why each of the three additional
adjust_free_gaps() are necessary.

>  	validate_mm(mm);
>  
>  	return 0;
> @@ -1760,6 +1826,8 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  			error = acct_stack_growth(vma, size, grow);
>  			if (!error) {
>  				vma->vm_end = address;
> +				if (vma->vm_next)
> +					adjust_free_gap(vma->vm_next);
>  				perf_event_mmap(vma);
>  			}
>  		}
> @@ -1811,6 +1879,7 @@ int expand_downwards(struct vm_area_struct *vma,
>  			if (!error) {
>  				vma->vm_start = address;
>  				vma->vm_pgoff -= grow;
> +				adjust_free_gap(vma);
>  				perf_event_mmap(vma);
>  			}
>  		}
> @@ -1933,7 +2002,10 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
>  	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
>  	vma->vm_prev = NULL;
>  	do {
> +		struct rb_node *deepest;
> +		deepest = rb_augment_erase_begin(&vma->vm_rb);
>  		rb_erase(&vma->vm_rb, &mm->mm_rb);
> +		rb_augment_erase_end(deepest, vma_rb_augment_cb, NULL);
>  		mm->map_count--;
>  		tail_vma = vma;
>  		vma = vma->vm_next;
> @@ -1941,6 +2013,8 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
>  	*insertion_point = vma;
>  	if (vma)
>  		vma->vm_prev = prev;
> +	if (vma)
> +		rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
>  	tail_vma->vm_next = NULL;
>  	if (mm->unmap_area == arch_unmap_area)
>  		addr = prev ? prev->vm_end : mm->mmap_base;
> -- 
> 1.7.7.6
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
