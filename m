Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 93A7B6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 22:23:10 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id c11so18974ieb.10
        for <linux-mm@kvack.org>; Mon, 22 Jul 2013 19:23:09 -0700 (PDT)
Message-ID: <51EDE903.6010608@ozlabs.ru>
Date: Tue, 23 Jul 2013 12:22:59 +1000
From: Alexey Kardashevskiy <aik@ozlabs.ru>
MIME-Version: 1.0
Subject: Re: [PATCH 04/10] powerpc: Prepare to support kernel handling of
 IOMMU map/unmap
References: <1373936045-22653-1-git-send-email-aik@ozlabs.ru> <1373936045-22653-5-git-send-email-aik@ozlabs.ru>
In-Reply-To: <1373936045-22653-5-git-send-email-aik@ozlabs.ru>
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: linuxppc-dev@lists.ozlabs.org, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Alexander Graf <agraf@suse.de>, Alex Williamson <alex.williamson@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>

Ping, anyone, please?

Ben needs ack from any of MM people before proceeding with this patch. Thanks!


On 07/16/2013 10:53 AM, Alexey Kardashevskiy wrote:
> The current VFIO-on-POWER implementation supports only user mode
> driven mapping, i.e. QEMU is sending requests to map/unmap pages.
> However this approach is really slow, so we want to move that to KVM.
> Since H_PUT_TCE can be extremely performance sensitive (especially with
> network adapters where each packet needs to be mapped/unmapped) we chose
> to implement that as a "fast" hypercall directly in "real
> mode" (processor still in the guest context but MMU off).
> 
> To be able to do that, we need to provide some facilities to
> access the struct page count within that real mode environment as things
> like the sparsemem vmemmap mappings aren't accessible.
> 
> This adds an API to increment/decrement page counter as
> get_user_pages API used for user mode mapping does not work
> in the real mode.
> 
> CONFIG_SPARSEMEM_VMEMMAP and CONFIG_FLATMEM are supported.
> 
> Cc: linux-mm@kvack.org
> Reviewed-by: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
> 
> ---
> 
> Changes:
> 2013/07/10:
> * adjusted comment (removed sentence about virtual mode)
> * get_page_unless_zero replaced with atomic_inc_not_zero to minimize
> effect of a possible get_page_unless_zero() rework (if it ever happens).
> 
> 2013/06/27:
> * realmode_get_page() fixed to use get_page_unless_zero(). If failed,
> the call will be passed from real to virtual mode and safely handled.
> * added comment to PageCompound() in include/linux/page-flags.h.
> 
> 2013/05/20:
> * PageTail() is replaced by PageCompound() in order to have the same checks
> for whether the page is huge in realmode_get_page() and realmode_put_page()
> 
> Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
> ---
>  arch/powerpc/include/asm/pgtable-ppc64.h |  4 ++
>  arch/powerpc/mm/init_64.c                | 76 +++++++++++++++++++++++++++++++-
>  include/linux/page-flags.h               |  4 +-
>  3 files changed, 82 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
> index 46db094..aa7b169 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -394,6 +394,10 @@ static inline void mark_hpte_slot_valid(unsigned char *hpte_slot_array,
>  	hpte_slot_array[index] = hidx << 4 | 0x1 << 3;
>  }
>  
> +struct page *realmode_pfn_to_page(unsigned long pfn);
> +int realmode_get_page(struct page *page);
> +int realmode_put_page(struct page *page);
> +
>  static inline char *get_hpte_slot_array(pmd_t *pmdp)
>  {
>  	/*
> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> index d0cd9e4..dcbb806 100644
> --- a/arch/powerpc/mm/init_64.c
> +++ b/arch/powerpc/mm/init_64.c
> @@ -300,5 +300,79 @@ void vmemmap_free(unsigned long start, unsigned long end)
>  {
>  }
>  
> -#endif /* CONFIG_SPARSEMEM_VMEMMAP */
> +/*
> + * We do not have access to the sparsemem vmemmap, so we fallback to
> + * walking the list of sparsemem blocks which we already maintain for
> + * the sake of crashdump. In the long run, we might want to maintain
> + * a tree if performance of that linear walk becomes a problem.
> + *
> + * Any of realmode_XXXX functions can fail due to:
> + * 1) As real sparsemem blocks do not lay in RAM continously (they
> + * are in virtual address space which is not available in the real mode),
> + * the requested page struct can be split between blocks so get_page/put_page
> + * may fail.
> + * 2) When huge pages are used, the get_page/put_page API will fail
> + * in real mode as the linked addresses in the page struct are virtual
> + * too.
> + */
> +struct page *realmode_pfn_to_page(unsigned long pfn)
> +{
> +	struct vmemmap_backing *vmem_back;
> +	struct page *page;
> +	unsigned long page_size = 1 << mmu_psize_defs[mmu_vmemmap_psize].shift;
> +	unsigned long pg_va = (unsigned long) pfn_to_page(pfn);
>  
> +	for (vmem_back = vmemmap_list; vmem_back; vmem_back = vmem_back->list) {
> +		if (pg_va < vmem_back->virt_addr)
> +			continue;
> +
> +		/* Check that page struct is not split between real pages */
> +		if ((pg_va + sizeof(struct page)) >
> +				(vmem_back->virt_addr + page_size))
> +			return NULL;
> +
> +		page = (struct page *) (vmem_back->phys + pg_va -
> +				vmem_back->virt_addr);
> +		return page;
> +	}
> +
> +	return NULL;
> +}
> +EXPORT_SYMBOL_GPL(realmode_pfn_to_page);
> +
> +#elif defined(CONFIG_FLATMEM)
> +
> +struct page *realmode_pfn_to_page(unsigned long pfn)
> +{
> +	struct page *page = pfn_to_page(pfn);
> +	return page;
> +}
> +EXPORT_SYMBOL_GPL(realmode_pfn_to_page);
> +
> +#endif /* CONFIG_SPARSEMEM_VMEMMAP/CONFIG_FLATMEM */
> +
> +#if defined(CONFIG_SPARSEMEM_VMEMMAP) || defined(CONFIG_FLATMEM)
> +int realmode_get_page(struct page *page)
> +{
> +	if (PageCompound(page))
> +		return -EAGAIN;
> +
> +	if (!atomic_inc_not_zero(&page->_count))
> +		return -EAGAIN;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(realmode_get_page);
> +
> +int realmode_put_page(struct page *page)
> +{
> +	if (PageCompound(page))
> +		return -EAGAIN;
> +
> +	if (!atomic_add_unless(&page->_count, -1, 1))
> +		return -EAGAIN;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(realmode_put_page);
> +#endif
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 6d53675..98ada58 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -329,7 +329,9 @@ static inline void set_page_writeback(struct page *page)
>   * System with lots of page flags available. This allows separate
>   * flags for PageHead() and PageTail() checks of compound pages so that bit
>   * tests can be used in performance sensitive paths. PageCompound is
> - * generally not used in hot code paths.
> + * generally not used in hot code paths except arch/powerpc/mm/init_64.c
> + * and arch/powerpc/kvm/book3s_64_vio_hv.c which use it to detect huge pages
> + * and avoid handling those in real mode.
>   */
>  __PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
>  __PAGEFLAG(Tail, tail)
> 


-- 
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
