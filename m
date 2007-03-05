Date: Mon, 5 Mar 2007 17:40:05 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
Message-ID: <20070305164005.GA10449@wotan.suse.de>
References: <20070305161746.GD8128@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070305161746.GD8128@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 05, 2007 at 05:17:46PM +0100, Nick Piggin wrote:
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -60,6 +60,8 @@
>  #include <linux/swapops.h>
>  #include <linux/elf.h>
>  
> +#include "internal.h"
> +
>  #ifndef CONFIG_NEED_MULTIPLE_NODES
>  /* use the per-pgdat data instead for discontigmem - mbligh */
>  unsigned long max_mapnr;
> @@ -855,6 +857,9 @@ unsigned long unmap_vmas(struct mmu_gath
>  
>  			tlb_finish_mmu(*tlbp, tlb_start, start);
>  
> +			if (vma->vm_flags & VM_LOCKED)
> +				munlock_vma_pages_range(vma, start, end);
> +
>  			if (need_resched() ||
>  				(i_mmap_lock && need_lockbreak(i_mmap_lock))) {
>  				if (i_mmap_lock) {


Argh, I missed fixing this. It is only supposed to munlock if i_mmap_lock
is not set (because munlock requires taking the page lock).

Those paths which do take i_mmap_lock here (unmap_mapping...) already do
their own handling of mlocked.

There are probably other bugs in my patchset, but this was the obvious
one.

BTW. anything that invalidates pagecache breaks mlock I think (not with
my patch but in general). I'll have to fix this...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
