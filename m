Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id E556B6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 16:17:17 -0400 (EDT)
Date: Tue, 6 Aug 2013 22:17:09 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/23] radix-tree: implement preload for multiple
 contiguous elements
Message-ID: <20130806201709.GA11383@quack.suse.cz>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20130805111739.GA25691@quack.suse.cz>
 <20130806163414.GA4707@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130806163414.GA4707@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 06-08-13 12:34:14, Matthew Wilcox wrote:
> On Mon, Aug 05, 2013 at 01:17:39PM +0200, Jan Kara wrote:
> > On Sun 04-08-13 05:17:03, Kirill A. Shutemov wrote:
> > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > The radix tree is variable-height, so an insert operation not only has
> > > to build the branch to its corresponding item, it also has to build the
> > > branch to existing items if the size has to be increased (by
> > > radix_tree_extend).
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
> >
> >   Umm, is this really correct? I see two problems:
> > 1) You may need internal tree nodes at various levels but you seem to
> > account only for the level 1.
> > 2) The rounding doesn't seem right because RADIX_TREE_MAP_SIZE+2 nodes may
> > require 3 nodes at level 1 if the indexes are like:
> > i_0 | i_1 .. i_{RADIX_TREE_MAP_SIZE} | i_{RADIX_TREE_MAP_SIZE+1}
> >     ^                                ^
> >     node boundary                    node boundary
> > 
> >   Otherwise the patch looks good.
> 
> You are correct that in the fully general case, these things are needed,
> and the patch undercounts the number of nodes needed.  However, in the
> specific case of THP pagecache, insertions are naturally aligned, and
> we end up needing very few internal nodes (so few that we've never hit
> the end of this array in some fairly heavy testing).
  Have you checked that you really didn't hit end of the array? Because if
we run out of preloaded nodes, we just try atomic kmalloc to get new
nodes. And that has high chances of success...

> There are two penalties for getting the general case correct.  One is
> that the calculation becomes harder to understand, and the other is
> that we consume more per-CPU memory.  I think we should document that
> the current code requires "natural alignment", and include a note about
> what things will need to change in order to support arbitrary alignment
> in case anybody needs to do it in the future, but not include support
> for arbitrary alignment in this patchset.
> 
> What do you think?
  I'm OK with expecting things to be naturally aligned if that's documented
and there's WARN_ON_ONCE which checks that someone isn't misusing the code.
It is true that you actually implemented only 'maybe_preload' variant for
contiguous extent preloading so leaving out higher level nodes might be OK.
But it would be good to at least document this at the place where you
estimate how much nodes to preload.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
