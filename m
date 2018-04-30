Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C17A36B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 18:52:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a1so3226747pfn.11
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 15:52:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a16-v6si6941530pgn.39.2018.04.30.15.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 15:52:09 -0700 (PDT)
Date: Mon, 30 Apr 2018 15:52:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: vmalloc: Clean up vunmap to avoid pgtable ops
 twice
Message-Id: <20180430155207.35a3dd94c31503c7a6268a8f@linux-foundation.org>
In-Reply-To: <1523876342-10545-1-git-send-email-cpandya@codeaurora.org>
References: <1523876342-10545-1-git-send-email-cpandya@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 16 Apr 2018 16:29:02 +0530 Chintan Pandya <cpandya@codeaurora.org> wrote:

> vunmap does page table clear operations twice in the
> case when DEBUG_PAGEALLOC_ENABLE_DEFAULT is enabled.
> 
> So, clean up the code as that is unintended.
> 
> As a perf gain, we save few us. Below ftrace data was
> obtained while doing 1 MB of vmalloc/vfree on ARM64
> based SoC *without* this patch applied. After this
> patch, we can save ~3 us (on 1 extra vunmap_page_range).
> 
>   CPU  DURATION                  FUNCTION CALLS
>   |     |   |                     |   |   |   |
>  6)               |  __vunmap() {
>  6)               |    vmap_debug_free_range() {
>  6)   3.281 us    |      vunmap_page_range();
>  6) + 45.468 us   |    }
>  6)   2.760 us    |    vunmap_page_range();
>  6) ! 505.105 us  |  }

It's been a long time since I looked at the vmap code :(

> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -603,26 +603,6 @@ static void unmap_vmap_area(struct vmap_area *va)
>  	vunmap_page_range(va->va_start, va->va_end);
>  }
>  
> -static void vmap_debug_free_range(unsigned long start, unsigned long end)
> -{
> -	/*
> -	 * Unmap page tables and force a TLB flush immediately if pagealloc
> -	 * debugging is enabled.  This catches use after free bugs similarly to
> -	 * those in linear kernel virtual address space after a page has been
> -	 * freed.
> -	 *
> -	 * All the lazy freeing logic is still retained, in order to minimise
> -	 * intrusiveness of this debugging feature.
> -	 *
> -	 * This is going to be *slow* (linear kernel virtual address debugging
> -	 * doesn't do a broadcast TLB flush so it is a lot faster).
> -	 */
> -	if (debug_pagealloc_enabled()) {
> -		vunmap_page_range(start, end);
> -		flush_tlb_kernel_range(start, end);
> -	}
> -}
> -
>  /*
>   * lazy_max_pages is the maximum amount of virtual address space we gather up
>   * before attempting to purge with a TLB flush.
> @@ -756,6 +736,9 @@ static void free_unmap_vmap_area(struct vmap_area *va)
>  {
>  	flush_cache_vunmap(va->va_start, va->va_end);
>  	unmap_vmap_area(va);
> +	if (debug_pagealloc_enabled())
> +		flush_tlb_kernel_range(va->va_start, va->va_end);
> +
>  	free_vmap_area_noflush(va);
>  }
>  
> @@ -1142,7 +1125,6 @@ void vm_unmap_ram(const void *mem, unsigned int count)
>  	BUG_ON(!PAGE_ALIGNED(addr));
>  
>  	debug_check_no_locks_freed(mem, size);
> -	vmap_debug_free_range(addr, addr+size);

This appears to be a functional change: if (count <= VMAP_MAX_ALLOC)
and we're in debug mode then the
vunmap_page_range/flush_tlb_kernel_range will no longer be performed. 
Why is this ok?

>  	if (likely(count <= VMAP_MAX_ALLOC)) {
>  		vb_free(mem, size);
> @@ -1499,7 +1481,6 @@ struct vm_struct *remove_vm_area(const void *addr)
>  		va->flags |= VM_LAZY_FREE;
>  		spin_unlock(&vmap_area_lock);
>  
> -		vmap_debug_free_range(va->va_start, va->va_end);
>  		kasan_free_shadow(vm);
>  		free_unmap_vmap_area(va);
>  
