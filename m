Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 0A6206B007B
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 05:46:02 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <514B2D94.8040206@sr71.net>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-5-git-send-email-kirill.shutemov@linux.intel.com>
 <514B2D94.8040206@sr71.net>
Subject: Re: [PATCHv2, RFC 04/30] radix-tree: implement preload for multiple
 contiguous elements
Content-Transfer-Encoding: 7bit
Message-Id: <20130322094745.E20D9E0085@blue.fi.intel.com>
Date: Fri, 22 Mar 2013 11:47:45 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > Currently radix_tree_preload() only guarantees enough nodes to insert
> > one element. It's a hard limit. You cannot batch a number insert under
> > one tree_lock.
> > 
> > This patch introduces radix_tree_preload_count(). It allows to
> > preallocate nodes enough to insert a number of *contiguous* elements.
> 
> You don't need to write a paper on how radix trees work, but it might be
> nice to include a wee bit of text in here about how the existing preload
> works, and how this new guarantee works.

Reasonable, will do.

> > diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> > index ffc444c..81318cb 100644
> > --- a/include/linux/radix-tree.h
> > +++ b/include/linux/radix-tree.h
> > @@ -83,6 +83,8 @@ do {									\
> >  	(root)->rnode = NULL;						\
> >  } while (0)
> >  
> > +#define RADIX_TREE_PRELOAD_NR		512 /* For THP's benefit */
> 
> This eventually boils down to making the radix_tree_preload array
> larger.  Do we really want to do this unconditionally if it's only for
> THP's benefit?

It will be useful not only for THP. Batching can be useful to solve
scalability issues.

> >  /**
> >   * Radix-tree synchronization
> >   *
> > @@ -231,6 +233,7 @@ unsigned long radix_tree_next_hole(struct radix_tree_root *root,
> >  unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
> >  				unsigned long index, unsigned long max_scan);
> >  int radix_tree_preload(gfp_t gfp_mask);
> > +int radix_tree_preload_count(unsigned size, gfp_t gfp_mask);
> >  void radix_tree_init(void);
> >  void *radix_tree_tag_set(struct radix_tree_root *root,
> >  			unsigned long index, unsigned int tag);
> > diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> > index e796429..9bef0ac 100644
> > --- a/lib/radix-tree.c
> > +++ b/lib/radix-tree.c
> > @@ -81,16 +81,24 @@ static struct kmem_cache *radix_tree_node_cachep;
> >   * The worst case is a zero height tree with just a single item at index 0,
> >   * and then inserting an item at index ULONG_MAX. This requires 2 new branches
> >   * of RADIX_TREE_MAX_PATH size to be created, with only the root node shared.
> > + *
> > + * Worst case for adding N contiguous items is adding entries at indexes
> > + * (ULONG_MAX - N) to ULONG_MAX. It requires nodes to insert single worst-case
> > + * item plus extra nodes if you cross the boundary from one node to the next.
> > + *
> >   * Hence:
> >   */
> > -#define RADIX_TREE_PRELOAD_SIZE (RADIX_TREE_MAX_PATH * 2 - 1)
> > +#define RADIX_TREE_PRELOAD_MIN (RADIX_TREE_MAX_PATH * 2 - 1)
> > +#define RADIX_TREE_PRELOAD_MAX \
> > +	(RADIX_TREE_PRELOAD_MIN + \
> > +	 DIV_ROUND_UP(RADIX_TREE_PRELOAD_NR - 1, RADIX_TREE_MAP_SIZE))
> >  
> >  /*
> >   * Per-cpu pool of preloaded nodes
> >   */
> >  struct radix_tree_preload {
> >  	int nr;
> > -	struct radix_tree_node *nodes[RADIX_TREE_PRELOAD_SIZE];
> > +	struct radix_tree_node *nodes[RADIX_TREE_PRELOAD_MAX];
> >  };
> 
> For those of us too lazy to go compile a kernel and figure this out in
> practice, how much bigger does this make the nodes[] array?

We have three possible RADIX_TREE_MAP_SHIFT:

#ifdef __KERNEL__
#define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
#else
#define RADIX_TREE_MAP_SHIFT	3	/* For more stressful testing */
#endif

On 64-bit system:
For RADIX_TREE_MAP_SHIFT=3, old array size is 43, new is 107.
For RADIX_TREE_MAP_SHIFT=4, old array size is 31, new is 63.
For RADIX_TREE_MAP_SHIFT=6, old array size is 21, new is 30.

On 32-bit system:
For RADIX_TREE_MAP_SHIFT=3, old array size is 21, new is 84.
For RADIX_TREE_MAP_SHIFT=4, old array size is 15, new is 46.
For RADIX_TREE_MAP_SHIFT=6, old array size is 11, new is 19.

On most machines we will have RADIX_TREE_MAP_SHIFT=6.

> 
> >  static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
> >  
> > @@ -257,29 +265,34 @@ radix_tree_node_free(struct radix_tree_node *node)
> >  
> >  /*
> >   * Load up this CPU's radix_tree_node buffer with sufficient objects to
> > - * ensure that the addition of a single element in the tree cannot fail.  On
> > - * success, return zero, with preemption disabled.  On error, return -ENOMEM
> > + * ensure that the addition of *contiguous* elements in the tree cannot fail.
> > + * On success, return zero, with preemption disabled.  On error, return -ENOMEM
> >   * with preemption not disabled.
> >   *
> >   * To make use of this facility, the radix tree must be initialised without
> >   * __GFP_WAIT being passed to INIT_RADIX_TREE().
> >   */
> > -int radix_tree_preload(gfp_t gfp_mask)
> > +int radix_tree_preload_count(unsigned size, gfp_t gfp_mask)
> >  {
> >  	struct radix_tree_preload *rtp;
> >  	struct radix_tree_node *node;
> >  	int ret = -ENOMEM;
> > +	int alloc = RADIX_TREE_PRELOAD_MIN +
> > +		DIV_ROUND_UP(size - 1, RADIX_TREE_MAP_SIZE);
> 
> Any chance I could talk you in to giving 'alloc' a better name?  Maybe
> "preload_target" or "preload_fill_to".

Ok.

> > +	if (size > RADIX_TREE_PRELOAD_NR)
> > +		return -ENOMEM;
> 
> I always wonder if these deep, logical -ENOMEMs deserve a WARN_ONCE().
> We really don't expect to hit this unless something really funky is
> going on, right?

Correct. Will add WARN.

> >  	preempt_disable();
> >  	rtp = &__get_cpu_var(radix_tree_preloads);
> > -	while (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
> > +	while (rtp->nr < alloc) {
> >  		preempt_enable();
> >  		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
> >  		if (node == NULL)
> >  			goto out;
> >  		preempt_disable();
> >  		rtp = &__get_cpu_var(radix_tree_preloads);
> > -		if (rtp->nr < ARRAY_SIZE(rtp->nodes))
> > +		if (rtp->nr < alloc)
> >  			rtp->nodes[rtp->nr++] = node;
> >  		else
> >  			kmem_cache_free(radix_tree_node_cachep, node);
> > @@ -288,6 +301,11 @@ int radix_tree_preload(gfp_t gfp_mask)
> >  out:
> >  	return ret;
> >  }

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
