Date: Thu, 13 Jul 2006 15:16:02 -0400 (EDT)
From: Jason Baron <jbaron@redhat.com>
Subject: Re: [PATCH] ia64: race flushing icache in COW path
In-Reply-To: <200607131700.k6DH0c5t001038@agluck-lia64.sc.intel.com>
Message-ID: <Pine.LNX.4.64.0607131514430.12852@dhcp83-20.boston.redhat.com>
References: <200607131700.k6DH0c5t001038@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: torvalds@osdl.org, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jul 2006, Luck, Tony wrote:

> From: Anil Keshavamurthy <anil.s.keshavamurthy@intel.com>
> 
> There is a race condition that showed up in a threaded JIT environment. The
> situation is that a process with a JIT code page forks, so the page is marked
> read-only, then some threads are created in the child.  One of the threads
> attempts to add a new code block to the JIT page, so a copy-on-write fault is
> taken, and the kernel allocates a new page, copies the data, installs the new
> pte, and then calls lazy_mmu_prot_update() to flush caches to make sure that
> the icache and dcache are in sync.  Unfortunately, the other thread runs right
> after the new pte is installed, but before the caches have been flushed. It
> tries to execute some old JIT code that was already in this page, but it sees
> some garbage in the i-cache from the previous users of the new physical page.
> 
> Fix: we must make the caches consistent before installing the pte. This is
> an ia64 only fix because lazy_mmu_prot_update() is a no-op on all other
> architectures.
> 
> Signed-off-by: Anil Keshavamurthy <anil.s.keshavamurthy@intel.com>
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> ---
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index dc0d82c..de8bc85 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1549,9 +1549,9 @@ gotten:
>  		flush_cache_page(vma, address, pte_pfn(orig_pte));
>  		entry = mk_pte(new_page, vma->vm_page_prot);
>  		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		lazy_mmu_prot_update(entry);
>  		ptep_establish(vma, address, page_table, entry);
>  		update_mmu_cache(vma, address, entry);
> -		lazy_mmu_prot_update(entry);
>  		lru_cache_add_active(new_page);
>  		page_add_new_anon_rmap(new_page, vma, address);
>  
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 


lazy_mmu_prot_update() is used in a number of other places *after* the pte 
is established. An explanation as to why this case is different, would be 
interesting.

thanks,

-Jason 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
