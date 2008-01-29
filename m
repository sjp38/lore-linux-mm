Date: Tue, 29 Jan 2008 17:20:04 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080129162004.GL7233@v2.random>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080128202923.849058104@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2008 at 12:28:42PM -0800, Christoph Lameter wrote:
> Index: linux-2.6/mm/fremap.c
> ===================================================================
> --- linux-2.6.orig/mm/fremap.c	2008-01-25 19:31:05.000000000 -0800
> +++ linux-2.6/mm/fremap.c	2008-01-25 19:32:49.000000000 -0800
> @@ -15,6 +15,7 @@
>  #include <linux/rmap.h>
>  #include <linux/module.h>
>  #include <linux/syscalls.h>
> +#include <linux/mmu_notifier.h>
>  
>  #include <asm/mmu_context.h>
>  #include <asm/cacheflush.h>
> @@ -211,6 +212,7 @@ asmlinkage long sys_remap_file_pages(uns
>  		spin_unlock(&mapping->i_mmap_lock);
>  	}
>  
> +	mmu_notifier(invalidate_range, mm, start, start + size, 0);
>  	err = populate_range(mm, vma, start, size, pgoff);

How can it be right to invalidate_range _before_ ptep_clear_flush?

> @@ -1634,6 +1639,8 @@ gotten:
>  	/*
>  	 * Re-check the pte - we dropped the lock
>  	 */
> +	mmu_notifier(invalidate_range, mm, address,
> +				address + PAGE_SIZE - 1, 0);
>  	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
>  	if (likely(pte_same(*page_table, orig_pte))) {
>  		if (old_page) {

What's the point of invalidate_range when the size is PAGE_SIZE? And
how can it be right to invalidate_range _before_ ptep_clear_flush?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
