Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0CB6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 04:18:33 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so87894341pdb.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 01:18:32 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sz9si14402452pac.80.2015.04.09.01.18.31
        for <linux-mm@kvack.org>;
        Thu, 09 Apr 2015 01:18:32 -0700 (PDT)
Message-ID: <1428567498.2910.32.camel@jlahtine-mobl1>
Subject: Re: [PATCH 4/5] mm: Export remap_io_mapping()
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Thu, 09 Apr 2015 11:18:18 +0300
In-Reply-To: <1428424299-13721-5-git-send-email-chris@chris-wilson.co.uk>
References: <1428424299-13721-1-git-send-email-chris@chris-wilson.co.uk>
	 <1428424299-13721-5-git-send-email-chris@chris-wilson.co.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On ti, 2015-04-07 at 17:31 +0100, Chris Wilson wrote:
> This is similar to remap_pfn_range(), and uses the recently refactor
> code to do the page table walking. The key difference is that is back
> propagates its error as this is required for use from within a pagefault
> handler. The other difference, is that it combine the page protection
> from io-mapping, which is known from when the io-mapping is created,
> with the per-vma page protection flags. This avoids having to walk the
> entire system description to rediscover the special page protection
> established for the io-mapping.
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: linux-mm@kvack.org
> ---
>  include/linux/mm.h |  4 ++++
>  mm/memory.c        | 46 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 50 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 47a93928b90f..3dfecd58adb0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2083,6 +2083,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
>  struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
>  int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
>  			unsigned long pfn, unsigned long size, pgprot_t);
> +struct io_mapping;

This is unconditional code, so just move the struct forward declaration
to the top of the file after "struct writeback_control" and others.

> +int remap_io_mapping(struct vm_area_struct *,
> +		     unsigned long addr, unsigned long pfn, unsigned long size,
> +		     struct io_mapping *iomap);
>  int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
>  int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  			unsigned long pfn);
> diff --git a/mm/memory.c b/mm/memory.c
> index acb06f40d614..83bc5df3fafc 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -61,6 +61,7 @@
>  #include <linux/string.h>
>  #include <linux/dma-debug.h>
>  #include <linux/debugfs.h>
> +#include <linux/io-mapping.h>
>  
>  #include <asm/io.h>
>  #include <asm/pgalloc.h>
> @@ -1762,6 +1763,51 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
>  EXPORT_SYMBOL(remap_pfn_range);
>  
>  /**
> + * remap_io_mapping - remap an IO mapping to userspace
> + * @vma: user vma to map to
> + * @addr: target user address to start at
> + * @pfn: physical address of kernel memory
> + * @size: size of map area
> + * @iomap: the source io_mapping
> + *
> + *  Note: this is only safe if the mm semaphore is held when called.
> + */
> +int remap_io_mapping(struct vm_area_struct *vma,
> +		     unsigned long addr, unsigned long pfn, unsigned long size,
> +		     struct io_mapping *iomap)
> +{
> +	unsigned long end = addr + PAGE_ALIGN(size);
> +	struct remap_pfn r;
> +	pgd_t *pgd;
> +	int err;
> +
> +	if (WARN_ON(addr >= end))
> +		return -EINVAL;
> +
> +#define MUST_SET (VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP)
> +	BUG_ON(is_cow_mapping(vma->vm_flags));
> +	BUG_ON((vma->vm_flags & MUST_SET) != MUST_SET);
> +#undef MUST_SET
> +

I think that is bit general for define name, maybe something along
REMAP_IO_NEEDED_FLAGS outside of the function... and then it doesn't
have to be #undeffed. And if it is kept inside function then at least _
prefix it. But I don't see why not make it available outside too.

Otherwise looking good.

Regards, Joonas

> +	r.mm = vma->vm_mm;
> +	r.addr = addr;
> +	r.pfn = pfn;
> +	r.prot = __pgprot((pgprot_val(iomap->prot) & _PAGE_CACHE_MASK) |
> +			  (pgprot_val(vma->vm_page_prot) & ~_PAGE_CACHE_MASK));
> +
> +	pgd = pgd_offset(r.mm, addr);
> +	do {
> +		err = remap_pud_range(&r, pgd++, pgd_addr_end(r.addr, end));
> +	} while (err == 0 && r.addr < end);
> +
> +	if (err)
> +		zap_page_range_single(vma, addr, r.addr - addr, NULL);
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(remap_io_mapping);
> +
> +/**
>   * vm_iomap_memory - remap memory to userspace
>   * @vma: user vma to map to
>   * @start: start of area


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
