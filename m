Date: Wed, 1 Nov 2006 17:39:26 +0000
Subject: Re: Page allocator: Single Zone optimizations
Message-ID: <20061101173926.GA27386@skynet.ie>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com> <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com> <45347288.6040808@yahoo.com.au> <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com> <45360CD7.6060202@yahoo.com.au> <20061018123840.a67e6a44.akpm@osdl.org> <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com> <20061026150938.bdf9d812.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20061026150938.bdf9d812.akpm@osdl.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (26/10/06 15:09), Andrew Morton didst pronounce:
> On Mon, 23 Oct 2006 16:08:20 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Single Zone Optimizations V2
> > 
> > V1->V2 Use a config variable setup im mm/KConfig
> > 
> > If we only have a single zone then various macros can be optimized.
> > We do not need to protect higher zones, we know that zones are
> > always present, can remove useless data from /proc etc etc. Various
> > code paths become unnecessary with a single zone setup.
> 
> I don't know about all of this.  It's making core mm increasingly revolting
> and increases dissimilarities between different kernel builds and generally
> makes it harder for us to remotely diagnose and solve people's bug reports.
> Harder to understand architecture A's behaviour based upon one's knowledge
> of architecture B, etc.
> 
> I really really want to drop all those patches[1] and rethink it all.
> 
> Like...  would it make sense to eliminate the hard-coded concepts of DMA,
> DMA32, NORMAL and HIGHMEM and simply say "we support 1 to N zones" per
> node?  Obviously we'd need to keep the DMA/NORMAL/HIGHMEM nomenclature in
> the interfaces so the rest of the kernel builds and works, but the core mm
> just shouldn't need to care: all it cares about is one or more zones.
> 

This feels vaguely similar to http://lkml.org/lkml/2001/6/7/117  . The
basic idea is that zones would be dynamically created at runtime and the
allowable GFP flags would be registered for a zone and zonelists built
based on that. I'm not saying this is the right thing to do, but it's not
the first time this has come up for one reason or another.

> 
> 
> Or something like that.  Something which makes the mm easier to understand,
> easier to maintain and faster.  Rather than harder to understand, harder to
> maintain and faster.
> 
> 
> 
> 
> 
> 
> [1] These:
> 
> get-rid-of-zone_table.patch
> deal-with-cases-of-zone_dma-meaning-the-first-zone.patch
> get-rid-of-zone_table-fix-3.patch
> introduce-config_zone_dma.patch
> optional-zone_dma-in-the-vm.patch
> optional-zone_dma-in-the-vm-no-gfp_dma-check-in-the-slab-if-no-config_zone_dma-is-set.patch
> optional-zone_dma-for-ia64.patch
> remove-zone_dma-remains-from-parisc.patch
> remove-zone_dma-remains-from-sh-sh64.patch
> set-config_zone_dma-for-arches-with-generic_isa_dma.patch
> zoneid-fix-up-calculations-for-zoneid_pgshift.patch
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
