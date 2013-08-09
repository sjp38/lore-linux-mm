Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id D365D6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 07:36:37 -0400 (EDT)
Date: Fri, 9 Aug 2013 13:36:34 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/23] radix-tree: implement preload for multiple
 contiguous elements
Message-ID: <20130809113634.GB14574@quack.suse.cz>
References: <1375582645-29274-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20130805111739.GA25691@quack.suse.cz>
 <20130807163236.0F17DE0090@blue.fi.intel.com>
 <20130807200032.GE26516@quack.suse.cz>
 <20130807202403.7BCEEE0090@blue.fi.intel.com>
 <20130807203650.GI26516@quack.suse.cz>
 <20130807213736.AC732E0090@blue.fi.intel.com>
 <20130808084505.31EACE0090@blue.fi.intel.com>
 <20130808100404.GA4325@quack.suse.cz>
 <20130809111351.DE8BAE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130809111351.DE8BAE0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@linux.intel.com>, Dave Hansen <dave@sr71.net>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 09-08-13 14:13:51, Kirill A. Shutemov wrote:
> Jan Kara wrote:
> > On Thu 08-08-13 11:45:05, Kirill A. Shutemov wrote:
> > > From 35ba5687ea7aea98645da34ddd0be01a9de8b32d Mon Sep 17 00:00:00 2001
> > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > Date: Wed, 9 Jan 2013 13:25:47 +0200
> > > Subject: [PATCH] radix-tree: implement preload for multiple contiguous
> > >  elements
> > > 
> > > The radix tree is variable-height, so an insert operation not only has
> > > to build the branch to its corresponding item, it also has to build the
> > > branch to existing items if the size has to be increased (by
> > > radix_tree_extend).
> > > 
> > > The worst case is a zero height tree with just a single item at index 0,
> > > and then inserting an item at index ULONG_MAX. This requires 2 new branches
> > > of RADIX_TREE_MAX_PATH size to be created, with only the root node shared.
> > > 
> > > Radix tree is usually protected by spin lock. It means we want to
> > > pre-allocate required memory before taking the lock.
> > > 
> > > Currently radix_tree_preload() only guarantees enough nodes to insert
> > > one element. It's a hard limit. For transparent huge page cache we want
> > > to insert HPAGE_PMD_NR (512 on x86-64) entries to address_space at once.
> > > 
> > > This patch introduces radix_tree_preload_count(). It allows to
> > > preallocate nodes enough to insert a number of *contiguous* elements.
> > > The feature costs about 9KiB per-CPU on x86_64, details below.
> > > 
> > > Preload uses per-CPU array to store nodes. The total cost of preload is
> > > "array size" * sizeof(void*) * NR_CPUS. We want to increase array size
> > > to be able to handle 512 entries at once.
> > > 
> > > Size of array depends on system bitness and on RADIX_TREE_MAP_SHIFT.
> > > 
> > > We have three possible RADIX_TREE_MAP_SHIFT:
> > > 
> > >  #ifdef __KERNEL__
> > >  #define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
> > >  #else
> > >  #define RADIX_TREE_MAP_SHIFT	3	/* For more stressful testing */
> > >  #endif
> > > 
> > > We are not going to use transparent huge page cache on small machines or
> > > in userspace, so we are interested in RADIX_TREE_MAP_SHIFT=6.
> > > 
> > > On 64-bit system old array size is 21, new is 37. Per-CPU feature
> > > overhead is
> > >  for preload array:
> > >    (37 - 21) * sizeof(void*) = 128 bytes
> > >  plus, if the preload array is full
> > >    (37 - 21) * sizeof(struct radix_tree_node) = 16 * 560 = 8960 bytes
> > >  total: 9088 bytes
> > > 
> > > On 32-bit system old array size is 11, new is 22. Per-CPU feature
> > > overhead is
> > >  for preload array:
> > >    (22 - 11) * sizeof(void*) = 44 bytes
> > >  plus, if the preload array is full
> > >    (22 - 11) * sizeof(struct radix_tree_node) = 11 * 296 = 3256 bytes
> > >  total: 3300 bytes
> > > 
> > > Since only THP uses batched preload at the moment, we disable (set max
> > > preload to 1) it if !CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE. This can be
> > > changed in the future.
> > > 
> > > Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
> > > ---
> > >  include/linux/radix-tree.h | 11 ++++++
> > >  lib/radix-tree.c           | 89 +++++++++++++++++++++++++++++++++++++++++-----
> > >  2 files changed, 91 insertions(+), 9 deletions(-)
> > > 
> > > diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> > > index 4039407..3bf0b3e 100644
> > > --- a/include/linux/radix-tree.h
> > > +++ b/include/linux/radix-tree.h
> > > @@ -83,6 +83,16 @@ do {									\
> > >  	(root)->rnode = NULL;						\
> > >  } while (0)
> > >  
> > > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
> > > +/*
> > > + * At the moment only THP uses preload for more then on item for batched
> > > + * pagecache manipulations.
> > > + */
> > > +#define RADIX_TREE_PRELOAD_NR	512
> > > +#else
> > > +#define RADIX_TREE_PRELOAD_NR	1
> > > +#endif
> > > +
> > >  /**
> > >   * Radix-tree synchronization
> > >   *
> > > @@ -232,6 +242,7 @@ unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
> > >  				unsigned long index, unsigned long max_scan);
> > >  int radix_tree_preload(gfp_t gfp_mask);
> > >  int radix_tree_maybe_preload(gfp_t gfp_mask);
> > > +int radix_tree_maybe_preload_contig(unsigned size, gfp_t gfp_mask);
> > >  void radix_tree_init(void);
> > >  void *radix_tree_tag_set(struct radix_tree_root *root,
> > >  			unsigned long index, unsigned int tag);
> > > diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> > > index 7811ed3..980e4c4 100644
> > > --- a/lib/radix-tree.c
> > > +++ b/lib/radix-tree.c
> > > @@ -84,14 +84,54 @@ static struct kmem_cache *radix_tree_node_cachep;
> > >   * of RADIX_TREE_MAX_PATH size to be created, with only the root node shared.
> > >   * Hence:
> > >   */
> > > -#define RADIX_TREE_PRELOAD_SIZE (RADIX_TREE_MAX_PATH * 2 - 1)
> > > +#define RADIX_TREE_PRELOAD_MIN (RADIX_TREE_MAX_PATH * 2 - 1)
> > > +
> > > +/*
> > > + * Inserting N contiguous items is more complex. To simplify calculation, let's
> > > + * limit N (validated in radix_tree_init()):
> > > + *  - N is multiplier of RADIX_TREE_MAP_SIZE (or 1);
> >   Is this limitation really worth the one reserved item you save?
> 
> It's not really limitation, It just doesn't make any sense to lower
> RADIX_TREE_PRELOAD_NR not to RADIX_TREE_MAP_SIZE boundary, since we will
> have to round it up anyway.
> 
> I made one more mistake: I've modeled not the situation I've describe, so
> last -1 is wrong. Fixed in patch below.
> 
> > > -static int __radix_tree_preload(gfp_t gfp_mask)
> > > +static int __radix_tree_preload_contig(unsigned size, gfp_t gfp_mask)
> > >  {
> > >  	struct radix_tree_preload *rtp;
> > >  	struct radix_tree_node *node;
> > >  	int ret = -ENOMEM;
> > > +	int preload_target = RADIX_TREE_PRELOAD_MIN +
> > > +		DIV_ROUND_UP(size - 1, RADIX_TREE_MAP_SIZE);
> >   So you should also warn if size % RADIX_TREE_MAP_SIZE != 0, right?
> 
> I've reworked logic here to match RADIX_TREE_PRELOAD_MAX calculation math.
> 
> > Otherwise the patch looks fine.
> 
> Ack?
  Yes. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> 
> From 0e7d481093a4ded0dfb58e87d4edda003f3b2fd6 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Wed, 9 Jan 2013 13:25:47 +0200
> Subject: [PATCH] radix-tree: implement preload for multiple contiguous
>  elements
> 
> The radix tree is variable-height, so an insert operation not only has
> to build the branch to its corresponding item, it also has to build the
> branch to existing items if the size has to be increased (by
> radix_tree_extend).
> 
> The worst case is a zero height tree with just a single item at index 0,
> and then inserting an item at index ULONG_MAX. This requires 2 new branches
> of RADIX_TREE_MAX_PATH size to be created, with only the root node shared.
> 
> Radix tree is usually protected by spin lock. It means we want to
> pre-allocate required memory before taking the lock.
> 
> Currently radix_tree_preload() only guarantees enough nodes to insert
> one element. It's a hard limit. For transparent huge page cache we want
> to insert HPAGE_PMD_NR (512 on x86-64) entries to address_space at once.
> 
> This patch introduces radix_tree_preload_count(). It allows to
> preallocate nodes enough to insert a number of *contiguous* elements.
> The feature costs about 9.5KiB per-CPU on x86_64, details below.
> 
> Preload uses per-CPU array to store nodes. The total cost of preload is
> "array size" * sizeof(void*) * NR_CPUS. We want to increase array size
> to be able to handle 512 entries at once.
> 
> Size of array depends on system bitness and on RADIX_TREE_MAP_SHIFT.
> 
> We have three possible RADIX_TREE_MAP_SHIFT:
> 
>  #ifdef __KERNEL__
>  #define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
>  #else
>  #define RADIX_TREE_MAP_SHIFT	3	/* For more stressful testing */
>  #endif
> 
> We are not going to use transparent huge page cache on small machines or
> in userspace, so we are interested in RADIX_TREE_MAP_SHIFT=6.
> 
> On 64-bit system old array size is 21, new is 37. Per-CPU feature
> overhead is
>  for preload array:
>    (38 - 21) * sizeof(void*) = 136 bytes
>  plus, if the preload array is full
>    (38 - 21) * sizeof(struct radix_tree_node) = 17 * 560 = 9520 bytes
>  total: 9656 bytes
> 
> On 32-bit system old array size is 11, new is 22. Per-CPU feature
> overhead is
>  for preload array:
>    (23 - 11) * sizeof(void*) = 48 bytes
>  plus, if the preload array is full
>    (23 - 11) * sizeof(struct radix_tree_node) = 12 * 296 = 3552 bytes
>  total: 3600 bytes
> 
> Since only THP uses batched preload at the moment, we disable (set max
> preload to 1) it if !CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE. This can be
> changed in the future.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
>  include/linux/radix-tree.h | 11 ++++++
>  lib/radix-tree.c           | 95 +++++++++++++++++++++++++++++++++++++++++-----
>  2 files changed, 97 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 4039407..3bf0b3e 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -83,6 +83,16 @@ do {									\
>  	(root)->rnode = NULL;						\
>  } while (0)
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
> +/*
> + * At the moment only THP uses preload for more then on item for batched
> + * pagecache manipulations.
> + */
> +#define RADIX_TREE_PRELOAD_NR	512
> +#else
> +#define RADIX_TREE_PRELOAD_NR	1
> +#endif
> +
>  /**
>   * Radix-tree synchronization
>   *
> @@ -232,6 +242,7 @@ unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
>  				unsigned long index, unsigned long max_scan);
>  int radix_tree_preload(gfp_t gfp_mask);
>  int radix_tree_maybe_preload(gfp_t gfp_mask);
> +int radix_tree_maybe_preload_contig(unsigned size, gfp_t gfp_mask);
>  void radix_tree_init(void);
>  void *radix_tree_tag_set(struct radix_tree_root *root,
>  			unsigned long index, unsigned int tag);
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 7811ed3..1c19595 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -84,14 +84,52 @@ static struct kmem_cache *radix_tree_node_cachep;
>   * of RADIX_TREE_MAX_PATH size to be created, with only the root node shared.
>   * Hence:
>   */
> -#define RADIX_TREE_PRELOAD_SIZE (RADIX_TREE_MAX_PATH * 2 - 1)
> +#define RADIX_TREE_PRELOAD_MIN (RADIX_TREE_MAX_PATH * 2 - 1)
> +
> +/*
> + * Inserting N contiguous items is more complex. To simplify calculation, let's
> + * limit N (validated in radix_tree_init()):
> + *  - N is multiplier of RADIX_TREE_MAP_SIZE (or 1);
> + *  - N <= number of items 2-level tree can contain:
> + *    1UL << (2 * RADIX_TREE_MAP_SHIFT).
> + *
> + * No limitation on insert index alignment.
> + *
> + * Then the worst case is tree with only one element at index 0 and we add N
> + * items where at least one index requires max tree high and we cross boundary
> + * between items in root node.
> + *
> + * Basically, at least one index is less then
> + *
> + * 1UL << ((RADIX_TREE_MAX_PATH - 1) * RADIX_TREE_MAP_SHIFT)
> + *
> + * and one is equal to.
> + *
> + * In this case we need:
> + *
> + * - RADIX_TREE_MAX_PATH nodes to build new path to item with index 0;
> + * - N / RADIX_TREE_MAP_SIZE + 1 nodes for last level nodes for new items:
> + *    - +1 is for misalinged case;
> + * - 2 * (RADIX_TREE_MAX_PATH - 2) - 1 nodes to build path to last level nodes:
> + *    - -2, because root node and last level nodes are already accounted).
> + *
> + * Hence:
> + */
> +#if RADIX_TREE_PRELOAD_NR > 1
> +#define RADIX_TREE_PRELOAD_MAX \
> +	( RADIX_TREE_MAX_PATH + \
> +	  RADIX_TREE_PRELOAD_NR / RADIX_TREE_MAP_SIZE + 1 + \
> +	  2 * (RADIX_TREE_MAX_PATH - 2))
> +#else
> +#define RADIX_TREE_PRELOAD_MAX RADIX_TREE_PRELOAD_MIN
> +#endif
>  
>  /*
>   * Per-cpu pool of preloaded nodes
>   */
>  struct radix_tree_preload {
>  	int nr;
> -	struct radix_tree_node *nodes[RADIX_TREE_PRELOAD_SIZE];
> +	struct radix_tree_node *nodes[RADIX_TREE_PRELOAD_MAX];
>  };
>  static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
>  
> @@ -263,29 +301,43 @@ radix_tree_node_free(struct radix_tree_node *node)
>  
>  /*
>   * Load up this CPU's radix_tree_node buffer with sufficient objects to
> - * ensure that the addition of a single element in the tree cannot fail.  On
> - * success, return zero, with preemption disabled.  On error, return -ENOMEM
> + * ensure that the addition of *contiguous* items in the tree cannot fail.
> + * On success, return zero, with preemption disabled.  On error, return -ENOMEM
>   * with preemption not disabled.
>   *
>   * To make use of this facility, the radix tree must be initialised without
>   * __GFP_WAIT being passed to INIT_RADIX_TREE().
>   */
> -static int __radix_tree_preload(gfp_t gfp_mask)
> +static int __radix_tree_preload_contig(unsigned size, gfp_t gfp_mask)
>  {
>  	struct radix_tree_preload *rtp;
>  	struct radix_tree_node *node;
>  	int ret = -ENOMEM;
> +	int preload_target = RADIX_TREE_PRELOAD_MIN;
>  
> +	if (size > 1) {
> +		size = round_up(size, RADIX_TREE_MAP_SIZE);
> +		if (WARN_ONCE(size > RADIX_TREE_PRELOAD_NR,
> +					"too large preload requested"))
> +			return -ENOMEM;
> +
> +		/* The same math as with RADIX_TREE_PRELOAD_MAX */
> +		preload_target = RADIX_TREE_MAX_PATH +
> +			size / RADIX_TREE_MAP_SIZE + 1 +
> +			2 * (RADIX_TREE_MAX_PATH - 2);
> +	}
> +
> +	BUG_ON(preload_target > RADIX_TREE_PRELOAD_MAX);
>  	preempt_disable();
>  	rtp = &__get_cpu_var(radix_tree_preloads);
> -	while (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
> +	while (rtp->nr < preload_target) {
>  		preempt_enable();
>  		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
>  		if (node == NULL)
>  			goto out;
>  		preempt_disable();
>  		rtp = &__get_cpu_var(radix_tree_preloads);
> -		if (rtp->nr < ARRAY_SIZE(rtp->nodes))
> +		if (rtp->nr < preload_target)
>  			rtp->nodes[rtp->nr++] = node;
>  		else
>  			kmem_cache_free(radix_tree_node_cachep, node);
> @@ -308,7 +360,7 @@ int radix_tree_preload(gfp_t gfp_mask)
>  {
>  	/* Warn on non-sensical use... */
>  	WARN_ON_ONCE(!(gfp_mask & __GFP_WAIT));
> -	return __radix_tree_preload(gfp_mask);
> +	return __radix_tree_preload_contig(1, gfp_mask);
>  }
>  EXPORT_SYMBOL(radix_tree_preload);
>  
> @@ -320,13 +372,22 @@ EXPORT_SYMBOL(radix_tree_preload);
>  int radix_tree_maybe_preload(gfp_t gfp_mask)
>  {
>  	if (gfp_mask & __GFP_WAIT)
> -		return __radix_tree_preload(gfp_mask);
> +		return __radix_tree_preload_contig(1, gfp_mask);
>  	/* Preloading doesn't help anything with this gfp mask, skip it */
>  	preempt_disable();
>  	return 0;
>  }
>  EXPORT_SYMBOL(radix_tree_maybe_preload);
>  
> +int radix_tree_maybe_preload_contig(unsigned size, gfp_t gfp_mask)
> +{
> +	if (gfp_mask & __GFP_WAIT)
> +		return __radix_tree_preload_contig(size, gfp_mask);
> +	/* Preloading doesn't help anything with this gfp mask, skip it */
> +	preempt_disable();
> +	return 0;
> +}
> +
>  /*
>   *	Return the maximum key which can be store into a
>   *	radix tree with height HEIGHT.
> @@ -1483,6 +1544,22 @@ static int radix_tree_callback(struct notifier_block *nfb,
>  
>  void __init radix_tree_init(void)
>  {
> +	/*
> +	 * Restrictions on RADIX_TREE_PRELOAD_NR simplify RADIX_TREE_PRELOAD_MAX
> +	 * calculation, it's already complex enough:
> +	 *  - it must be multiplier of RADIX_TREE_MAP_SIZE, otherwise we will
> +	 *    have to round it up to next RADIX_TREE_MAP_SIZE multiplier and we
> +	 *    don't win anything;
> +	 *  - must be less then number of items 2-level tree can contain.
> +	 *    It's easier to calculate number of internal nodes required
> +	 *    this way.
> +	 */
> +	if (RADIX_TREE_PRELOAD_NR != 1) {
> +		BUILD_BUG_ON(RADIX_TREE_PRELOAD_NR % RADIX_TREE_MAP_SIZE != 0);
> +		BUILD_BUG_ON(RADIX_TREE_PRELOAD_NR >
> +				1UL << (2 * RADIX_TREE_MAP_SHIFT));
> +	}
> +
>  	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
>  			sizeof(struct radix_tree_node), 0,
>  			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
> -- 
>  Kirill A. Shutemov
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
