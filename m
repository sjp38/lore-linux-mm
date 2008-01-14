Date: Mon, 14 Jan 2008 11:55:03 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Remove set_migrateflags()
Message-ID: <20080114115503.GB32446@csn.ul.ie>
References: <Pine.LNX.4.64.0801101841570.23644@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801101841570.23644@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (10/01/08 18:42), Christoph Lameter didst pronounce:
> set_migrateflagsi() sole purpose is to set migrate flags on slab allocations.
> However, the migrate flags must set on slab creation as agreed upon when the
> antifrag logic was reviewed. Otherwise some slabs of a slabcache will end up
> in the unmovable and others in the reclaimable section depending on what
> flags was active when a new slab was allocated.
> 
> This likely slid in somehow when antifrag was merged. Remove it.
> 
> The buffer_heads are always allocated with __GFP_RECLAIMABLE because
> the SLAB_RECLAIM_ACCOUNT option is set.
> 
> The set_migrateflags() never had any effect.
> 

Ok, this part I agree with.

> Radix tree allocations are not reclaimable.

The thinking behind this was that radix nodes are often (but not always)
indirectly reclaimable as they are cleaned up when related data structures
(that are reclaimable) get taken back. This does not apply to them all of
course but enough that this seemed fair.

Grouping the radix nodes into the same TLB entries as the inode and dcaches
does appear to help performance a small amount on kernbench at least. Applying
this patch showed a performance difference on elapsed time between -4.45%
and 0.23% and between -0.36% and 0.28% on total CPU time which appears to
support that position.

Applying this patch also reduces high allocation success rates although I
will freely admit that this *could* be related to the type of workload.

> And thus setting __GFP_RECLAIMABLE
> is a bit strange. We could set SLAB_RECLAIM_ACCOUNT on radix tree slab
> creation if we want those to be placed in the reclaimable section.
> Then we are sure that the radix tree slabs are consistently placed in the
> reclaimable section and then the radix tree slabs will also be accounted as
> such.
> 

What is there right now places the pages appropriately but should they really
be accounted for as such too? I know that marking them like that will
cause SLUB to treat them differently and I don't fully understand the
implications of that.

> The simple removal of set_migrateflags() here will place the allocations
> in the unmovable section.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 

NAK for now. I'm still of the opinion that radix nodes should be marked
reclaimable because they are often cleaned up at the same time as slabs that
are really reclaimable.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
