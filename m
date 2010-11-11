Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2256B009F
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 17:25:14 -0500 (EST)
Date: Thu, 11 Nov 2010 14:25:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
Message-Id: <20101111142511.c98c3808.akpm@linux-foundation.org>
In-Reply-To: <1289512924.428.112.camel@oralap>
References: <1289421759.11149.59.camel@oralap>
	<20101111120643.22dcda5b.akpm@linux-foundation.org>
	<1289512924.428.112.camel@oralap>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Cc: linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Nov 2010 23:02:04 +0100
"Ricardo M. Correia" <ricardo.correia@oracle.com> wrote:

> On Thu, 2010-11-11 at 12:06 -0800, Andrew Morton wrote:
> > > I also suggested that it would be nice to have a per-task
> > > gfp_allowed_mask, similar to the existing gfp_allowed_mask /
> > > set_gfp_allowed_mask() interface that exists in the kernel, but instead
> > > of being global to the entire system, it would be stored in the thread's
> > > task_struct and only apply in the context of the current thread.
> > 
> > Possibly we should have done pass-via-task_struct for the gfp mode
> > everywhere.  Fifteen years ago...  Sites which modify the mask should
> > do a save/restore on the stack, so there would be no stack savings, but
> > I suspect there would be some nice text size savings from all that
> > pass-it-on-to-the-next-guy stuff we do.  Note that this approach could
> > perhaps be used to move PF_MEMALLOC, PF_KSWAPD and maybe a few other
> > things into task_struct.gfp_flags.
> 
> Yes.. makes sense to me.
> 
> > But that's history.  Before embarking on that path (and introducing a
> > mixture of both forms of argument-passing) we should take a look at how
> > big and ugly it is to fix this bug via the normal passing convention,
> > so we can make a better-informed decision.  Is that something which
> > you've looked into in any detail?
> 
> Ok, I took a more detailed look... it seems we have to change at least
> these interfaces in order to make __vmalloc() propagate the gfp_mask:
> 
> Function/macro (dependency): references
> 
> map_vm_area (__vmalloc_area_node):  7
> vmap_page_range (map_vm_area): 3
> vmap_page_range_noflush (vmap_page_range): 3
> vmap_pud_range (vmap_vmap_page_range_noflush): 2
> pud_alloc (vmap_pud_range): 25
> __pud_alloc (pud_alloc): 4
> pud_alloc_one (__pud_alloc): 8
> crst_table_alloc (pud_alloc_one, pmd_alloc_one): 6
> vmap_pmd_range (vmap_pud_range): 2
> pmd_alloc (vmap_pmd_range): 31
> __pmd_alloc (pmd_alloc): 5
> pmd_alloc_one (__pmd_alloc): 28
> vmap_pte_range (vmap_pud_range): 2
> get_pointer_table (pmd_alloc_one): 4
> srmmu_pmd_alloc_one (pmd_alloc_one): 2
> sun4c_pmd_alloc_one (pmd_alloc_one): 2
> pte_alloc_kernel (vmap_pte_range): 14
> pte_alloc_one (pmd_alloc_one, pte_alloc_one_kernel): 38
> __pte_alloc_kernel (pte_alloc_kernel): 3
> pte_alloc_one_kernel (pte_alloc_one, __pte_alloc_kernel): 38
> page_table_alloc (pte_alloc_one, pte_alloc_one_kernel): 5
> srmmu_pte_alloc_one (pte_alloc_one): 2
> sun4c_pte_alloc_one (pte_alloc_one): 2
> srmmu_pte_alloc_one_kernel (pte_alloc_one_kernel): 3
> sun4c_pte_alloc_one_kernel (pte_alloc_one_kernel, sun4c_pte_alloc_one):
> 3
> 
> By looking at the number of references, we can get a rough idea of the
> number of LoC that needs to be changed, but this doesn't take into
> account changing the implementation of the leaf allocating functions
> themselves (e.g. pte_alloc_one_kernel, pmd_alloc_one, ..). Since these
> functions have one implementation for each architecture, we're looking
> at changing perhaps more than a hundred function implementations...
> 
> Also, it's entirely possible that I may have missed something, since I
> looked at all this manually (well, with the help of cscope).
> 
> There was one relatively extensive call chain which I didn't look into
> with much detail: pte_alloc_one_kernel() -> early_get_page () ->
> alloc_bootmem_pages() / memblock_alloc_base() -> ....
> 
> The names seem to indicate that there are allocations going on there,
> but from a quick glance I only saw a couple of them with GFP_NOWAIT (I
> wouldn't be surprised if I missed others).
> 
> It's also interesting that some of the leaf allocating functions
> sometimes take different flags on different architectures...
> 
> So do you think we should change all that?

Oh God, what have you done :(

No, I don't think we want to add a gfp_t to all of that code to fix one
stupid bug in vmalloc().

> Or do you prefer the per-task mask? Or maybe even both? :-)

Right now I'm thinking that the thing to do is to do the
pass-gfp_t-via-task_struct thing.

Which really commits us to doing that *everywhere*.  We won't need to
change every kmalloc()/etc callsite, but the conversion should probably
be done at the as-soon-as-we-enter-core-mm boundary.  Where "enter"
means "start running non-inlined code".

And then we can set current->gfp_mask to GFP_ATOMIC when we take an
interrupt, or take a spinlock.

And leave it at GFP_KERNEL when in process context.

And switch GFP_KERNEL to GFP_NOFS in the VM.

And switch to GFP_NOIO in the block layer.

So the allocation mode becomes implicit to the task state, so callers
usually don't need to track it.

So, ultimately, kmalloc(), alloc_pages() etc don't actually need a mode
arg at all.  We'll need new, special functions which _do_ take the
gfp_t but they will be rarely-called specialised things.

And probably we'll need interfaces like

	gfp_t mm_set_alloc_mode(gfp_t flags);
	void mm_restore_alloc_mode(gfp_t flags);

	gfp_t flags;

	flags = mm_set_alloc_mode(GFP_NOIO);
	...
	mm_restore_alloc_mode(flags);


argh, someone save us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
