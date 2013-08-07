Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id E8EFD6B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 16:00:39 -0400 (EDT)
Date: Wed, 7 Aug 2013 22:00:32 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/23] radix-tree: implement preload for multiple
 contiguous elements
Message-ID: <20130807200032.GE26516@quack.suse.cz>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20130805111739.GA25691@quack.suse.cz>
 <20130807163236.0F17DE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807163236.0F17DE0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 07-08-13 19:32:36, Kirill A. Shutemov wrote:
> Jan Kara wrote:
> > On Sun 04-08-13 05:17:03, Kirill A. Shutemov wrote:
> > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
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
> > > The feature costs about 5KiB per-CPU, details below.
> > > 
> > > Worst case for adding N contiguous items is adding entries at indexes
> > > (ULONG_MAX - N) to ULONG_MAX. It requires nodes to insert single worst-case
> > > item plus extra nodes if you cross the boundary from one node to the next.
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
> > > On 64-bit system:
> > > For RADIX_TREE_MAP_SHIFT=3, old array size is 43, new is 107.
> > > For RADIX_TREE_MAP_SHIFT=4, old array size is 31, new is 63.
> > > For RADIX_TREE_MAP_SHIFT=6, old array size is 21, new is 30.
> > > 
> > > On 32-bit system:
> > > For RADIX_TREE_MAP_SHIFT=3, old array size is 21, new is 84.
> > > For RADIX_TREE_MAP_SHIFT=4, old array size is 15, new is 46.
> > > For RADIX_TREE_MAP_SHIFT=6, old array size is 11, new is 19.
> > > 
> > > On most machines we will have RADIX_TREE_MAP_SHIFT=6. In this case,
> > > on 64-bit system the per-CPU feature overhead is
> > >  for preload array:
> > >    (30 - 21) * sizeof(void*) = 72 bytes
> > >  plus, if the preload array is full
> > >    (30 - 21) * sizeof(struct radix_tree_node) = 9 * 560 = 5040 bytes
> > >  total: 5112 bytes
> > > 
> > > on 32-bit system the per-CPU feature overhead is
> > >  for preload array:
> > >    (19 - 11) * sizeof(void*) = 32 bytes
> > >  plus, if the preload array is full
> > >    (19 - 11) * sizeof(struct radix_tree_node) = 8 * 296 = 2368 bytes
> > >  total: 2400 bytes
> > > 
> > > Since only THP uses batched preload at the moment, we disable (set max
> > > preload to 1) it if !CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE. This can be
> > > changed in the future.
> > > 
> > > Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
> > > ---
> > >  include/linux/radix-tree.h | 11 +++++++++++
> > >  lib/radix-tree.c           | 41 ++++++++++++++++++++++++++++++++---------
> > >  2 files changed, 43 insertions(+), 9 deletions(-)
> > ...
> > > diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> > > index 7811ed3..99ab73c 100644
> > > --- a/lib/radix-tree.c
> > > +++ b/lib/radix-tree.c
> > > @@ -82,16 +82,24 @@ static struct kmem_cache *radix_tree_node_cachep;
> > >   * The worst case is a zero height tree with just a single item at index 0,
> > >   * and then inserting an item at index ULONG_MAX. This requires 2 new branches
> > >   * of RADIX_TREE_MAX_PATH size to be created, with only the root node shared.
> > > + *
> > > + * Worst case for adding N contiguous items is adding entries at indexes
> > > + * (ULONG_MAX - N) to ULONG_MAX. It requires nodes to insert single worst-case
> > > + * item plus extra nodes if you cross the boundary from one node to the next.
> > > + *
> > >   * Hence:
> > >   */
> > > -#define RADIX_TREE_PRELOAD_SIZE (RADIX_TREE_MAX_PATH * 2 - 1)
> > > +#define RADIX_TREE_PRELOAD_MIN (RADIX_TREE_MAX_PATH * 2 - 1)
> > > +#define RADIX_TREE_PRELOAD_MAX \
> > > +	(RADIX_TREE_PRELOAD_MIN + \
> > > +	 DIV_ROUND_UP(RADIX_TREE_PRELOAD_NR - 1, RADIX_TREE_MAP_SIZE))
> >   Umm, is this really correct? I see two problems:
> > 1) You may need internal tree nodes at various levels but you seem to
> > account only for the level 1.
> > 2) The rounding doesn't seem right because RADIX_TREE_MAP_SIZE+2 nodes may
> > require 3 nodes at level 1 if the indexes are like:
> > i_0 | i_1 .. i_{RADIX_TREE_MAP_SIZE} | i_{RADIX_TREE_MAP_SIZE+1}
> >     ^                                ^
> >     node boundary                    node boundary
> 
> My bad. Let's try to calculate once again.
> 
> We want to insert N contiguous items without restriction on alignment.
> 
> Let's limit N <= 1UL << (2 * RADIX_TREE_MAP_SHIFT), without
> CONFIG_BASE_SMALL it's 4096. It will simplify calculation a bit.
> 
> Worst case scenario, I can imagine, is tree with only one element at index
> 0 and we add N items where at least one index requires max tree high and
> we cross boundary between items in root node.
> 
> Basically, at least one index is less then
> 
> 1UL << ((RADIX_TREE_MAX_PATH - 1) * RADIX_TREE_MAP_SHIFT)
> 
> and one equal or more.
> 
> In this case we need:
> 
> - RADIX_TREE_MAX_PATH nodes to build new path to item with index 0;
> - DIV_ROUND_UP(N, RADIX_TREE_MAP_SIZE) nodes for last level nodes for new
>   items;
  Here, I think you need to count with
DIV_ROUND_UP(N + RADIX_TREE_MAP_SIZE - 1, RADIX_TREE_MAP_SIZE) to propely
account for the situation b) I described.

> - 2 * (RADIX_TREE_MAX_PATH - 2) nodes to build path to last level nodes.
>   (-2, because root node and last level nodes are already accounted).
> 
> The macro:
> 
> #define RADIX_TREE_PRELOAD_MAX \
> 	( RADIX_TREE_MAX_PATH + \
> 	  DIV_ROUND_UP(RADIX_TREE_PRELOAD_NR, RADIX_TREE_MAP_SIZE) + \
> 	  2 * (RADIX_TREE_MAX_PATH - 2) )
> 
> For 64-bit system and N=512, RADIX_TREE_PRELOAD_MAX is 37.
> 
> Does it sound correct? Any thoughts?
  Otherwise I agree with your math (given the limitation on N). But please
add a comment explaining how we arrived to the math in
RADIX_TREE_PRELOAD_MAX. Thanks!

Another option I could live with is the one Matthew described - rely on
inserted range being aligned, but then comment about it and add some
assertion checking it.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
