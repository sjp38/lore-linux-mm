Date: Wed, 23 May 2007 14:58:24 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070523195824.GF11115@waste.org>
References: <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com> <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com> <20070523061702.GA9449@wotan.suse.de> <Pine.LNX.4.64.0705222326260.16694@schroedinger.engr.sgi.com> <20070523071200.GB9449@wotan.suse.de> <Pine.LNX.4.64.0705230956160.19822@schroedinger.engr.sgi.com> <20070523183224.GD11115@waste.org> <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 12:15:16PM -0700, Christoph Lameter wrote:
> On Wed, 23 May 2007, Matt Mackall wrote:
> 
> > You keep saying something like this but I'm never quite clear what you
> > mean. There are no slabs so reclaiming unused slabs is a non-issue.
> > Things like shrinking the dcache should work:
> > 
> >  __alloc_pages
> >   try_to_free_pages
> >    shrink_slab
> >     shrink_dcache_memory
> > 
> > I don't see any checks of ZVCs interfering with that path.
> 
> One example is the NR_SLAB_RECLAIMABLE ZVC. SLOB does not handle it thus 
> it is always zero.
> 
> slab reclaim is entered in mm/vsmscan shrink_all_memory():
> 
>   nr_slab = global_page_state(NR_SLAB_RECLAIMABLE);
>   /* If slab caches are huge, it's better to hit them first */
>   while (nr_slab >= lru_pages) {
>                reclaim_state.reclaimed_slab = 0;
>                 shrink_slab(nr_pages, sc.gfp_mask, lru_pages);
>                 if (!reclaim_state.reclaimed_slab)
> 
> 
> nr_slab will always be zero.

That's line 1448, but won't we hit that again unconditionally at 1485?
And again at 1503?

Meanwhile this function is only called from swsusp.c.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
