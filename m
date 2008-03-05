Date: Wed, 5 Mar 2008 14:02:50 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUG] 2.6.25-rc3-mm1 kernel panic while bootup on powerpc ()
Message-ID: <20080305140249.GA7592@csn.ul.ie>
References: <20080304011928.e8c82c0c.akpm@linux-foundation.org> <47CD4AB3.3080409@linux.vnet.ibm.com> <20080304103636.3e7b8fdd.akpm@linux-foundation.org> <47CDA081.7070503@cs.helsinki.fi> <20080304193532.GC9051@csn.ul.ie> <84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com> <Pine.LNX.4.64.0803041151360.18160@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0803042200410.8545@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0803041205370.18277@schroedinger.engr.sgi.com> <20080304123459.364f879b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080304123459.364f879b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, penberg@cs.helsinki.fi, kamalesh@linux.vnet.ibm.com, linuxppc-dev@ozlabs.org, apw@shadowen.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On (04/03/08 12:34), Andrew Morton didst pronounce:
> On Tue, 4 Mar 2008 12:07:39 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > I think this is the correct fix.
> > 
> > The NUMA fallback logic should be passing local_flags to kmem_get_pages() 
> > and not simply the flags.
> > 
> > Maybe a stable candidate since we are now simply 
> > passing on flags to the page allocator on the fallback path.
> 
> Do we know why this is only reported in 2.6.25-rc3-mm1?
> 
> Why does this need fixing in 2.6.24.x?
> 

I don't believe it needs to be fixed in 2.6.24.3. The call-sites in
lib/radix-tree.c there look like

        ret = kmem_cache_alloc(radix_tree_node_cachep,
                                set_migrateflags(gfp_mask, __GFP_RECLAIMABLE));

        node = kmem_cache_alloc(radix_tree_node_cachep,
                               set_migrateflags(gfp_mask, __GFP_RECLAIMABLE));

and set_migrateflags() looks like

#define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
static inline gfp_t set_migrateflags(gfp_t gfp, gfp_t migrate_flags)
{
        BUG_ON((gfp & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
        return (gfp & ~(GFP_MOVABLE_MASK)) | migrate_flags;
}

so the flags were already getting cleared and the WARN_ON could not
trigger in this path. In 2.6.25-rc3-mm1, the patch
remove-set_migrateflags.patch gets rid of set_migateflags()
which led to this situation.

The surprise is that it didn't get caught in an earlier -mm but it could
be because it only affected slab.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
