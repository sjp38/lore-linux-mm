Date: Tue, 29 Jan 2008 14:18:41 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [-mm PATCH] updates for hotplug memory remove
In-Reply-To: <1201566946.29357.18.camel@dyn9047017100.beaverton.ibm.com>
References: <1201566682.29357.15.camel@dyn9047017100.beaverton.ibm.com> <1201566946.29357.18.camel@dyn9047017100.beaverton.ibm.com>
Message-Id: <20080129120318.5BDF.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

Hello. Badari-san.

Is your patch for notification the event of removing to firmware, right?

Have you ever tested hotadd(probe) of the removed memory?
I'm afraid there are some differences of the status between pre hot-add
section and the removed section by this patch. I think the mem_section of
removed memory should be invalidated at least.

But anyway, this is a great first step for physical memory remove.

Thanks.


> On Mon, 2008-01-28 at 16:31 -0800, Badari Pulavarty wrote:
> 
> 
> > 2) Can you replace the following patch with this ?
> > 
> > add-remove_memory-for-ppc64-2.patch
> > 
> > I found that, I do need arch-specific hooks to get the memory remove
> > working on ppc64 LPAR. Earlier, I tried to make remove_memory() arch
> > neutral, but we do need arch specific hooks.
> > 
> > Thanks,
> > Badari
> 
> Andrew,
> 
> Here is the patch which provides arch-specific code to complete memory
> remove on ppc64 LPAR. So far, it works fine in my testing - but waiting
> for ppc-experts for review and completeness. 
> 
> FYI.
> 
> Thanks,
> Badari
> 
> For memory remove, we need to clean up htab mappings for the
> section of the memory we are removing.
> 
> This patch implements support for removing htab bolted mappings
> for ppc64 lpar. Other sub-archs, may need to implement similar
> functionality for the hotplug memory remove to work. 
> 
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> ---
>  arch/powerpc/mm/hash_utils_64.c       |   23 +++++++++++++++++++++++
>  arch/powerpc/mm/mem.c                 |    4 +++-
>  arch/powerpc/platforms/pseries/lpar.c |   15 +++++++++++++++
>  include/asm-powerpc/machdep.h         |    2 ++
>  include/asm-powerpc/sparsemem.h       |    1 +
>  5 files changed, 44 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.24-rc8/arch/powerpc/mm/hash_utils_64.c
> ===================================================================
> --- linux-2.6.24-rc8.orig/arch/powerpc/mm/hash_utils_64.c	2008-01-25 08:04:32.000000000 -0800
> +++ linux-2.6.24-rc8/arch/powerpc/mm/hash_utils_64.c	2008-01-28 11:45:40.000000000 -0800
> @@ -191,6 +191,24 @@ int htab_bolt_mapping(unsigned long vsta
>  	return ret < 0 ? ret : 0;
>  }
>  
> +static void htab_remove_mapping(unsigned long vstart, unsigned long vend,
> +		      int psize, int ssize)
> +{
> +	unsigned long vaddr;
> +	unsigned int step, shift;
> +
> +	shift = mmu_psize_defs[psize].shift;
> +	step = 1 << shift;
> +
> +	if (!ppc_md.hpte_removebolted) {
> +		printk("Sub-arch doesn't implement hpte_removebolted\n");
> +		return;
> +	}
> +
> +	for (vaddr = vstart; vaddr < vend; vaddr += step)
> +		ppc_md.hpte_removebolted(vaddr, psize, ssize);
> +}
> +
>  static int __init htab_dt_scan_seg_sizes(unsigned long node,
>  					 const char *uname, int depth,
>  					 void *data)
> @@ -436,6 +454,11 @@ void create_section_mapping(unsigned lon
>  			_PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_COHERENT | PP_RWXX,
>  			mmu_linear_psize, mmu_kernel_ssize));
>  }
> +
> +void remove_section_mapping(unsigned long start, unsigned long end)
> +{
> +	htab_remove_mapping(start, end, mmu_linear_psize, mmu_kernel_ssize);
> +}
>  #endif /* CONFIG_MEMORY_HOTPLUG */
>  
>  static inline void make_bl(unsigned int *insn_addr, void *func)
> Index: linux-2.6.24-rc8/include/asm-powerpc/sparsemem.h
> ===================================================================
> --- linux-2.6.24-rc8.orig/include/asm-powerpc/sparsemem.h	2008-01-15 20:22:48.000000000 -0800
> +++ linux-2.6.24-rc8/include/asm-powerpc/sparsemem.h	2008-01-25 08:18:11.000000000 -0800
> @@ -20,6 +20,7 @@
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  extern void create_section_mapping(unsigned long start, unsigned long end);
> +extern void remove_section_mapping(unsigned long start, unsigned long end);
>  #ifdef CONFIG_NUMA
>  extern int hot_add_scn_to_nid(unsigned long scn_addr);
>  #else
> Index: linux-2.6.24-rc8/arch/powerpc/mm/mem.c
> ===================================================================
> --- linux-2.6.24-rc8.orig/arch/powerpc/mm/mem.c	2008-01-25 08:16:37.000000000 -0800
> +++ linux-2.6.24-rc8/arch/powerpc/mm/mem.c	2008-01-25 08:20:33.000000000 -0800
> @@ -156,7 +156,9 @@ int remove_memory(u64 start, u64 size)
>  	ret = offline_pages(start_pfn, end_pfn, 120 * HZ);
>  	if (ret)
>  		goto out;
> -	/* Arch-specific calls go here - next patch */
> +
> +	start = (unsigned long)__va(start);
> +	remove_section_mapping(start, start + size);
>  out:
>  	return ret;
>  }
> Index: linux-2.6.24-rc8/arch/powerpc/platforms/pseries/lpar.c
> ===================================================================
> --- linux-2.6.24-rc8.orig/arch/powerpc/platforms/pseries/lpar.c	2008-01-15 20:22:48.000000000 -0800
> +++ linux-2.6.24-rc8/arch/powerpc/platforms/pseries/lpar.c	2008-01-28 14:10:58.000000000 -0800
> @@ -520,6 +520,20 @@ static void pSeries_lpar_hpte_invalidate
>  	BUG_ON(lpar_rc != H_SUCCESS);
>  }
>  
> +static void pSeries_lpar_hpte_removebolted(unsigned long ea,
> +					   int psize, int ssize)
> +{
> +	unsigned long slot, vsid, va;
> +
> +	vsid = get_kernel_vsid(ea, ssize);
> +	va = hpt_va(ea, vsid, ssize);
> +
> +	slot = pSeries_lpar_hpte_find(va, psize, ssize);
> +	BUG_ON(slot == -1);
> +
> +	pSeries_lpar_hpte_invalidate(slot, va, psize, ssize, 0);
> +}
> +
>  /* Flag bits for H_BULK_REMOVE */
>  #define HBR_REQUEST	0x4000000000000000UL
>  #define HBR_RESPONSE	0x8000000000000000UL
> @@ -597,6 +611,7 @@ void __init hpte_init_lpar(void)
>  	ppc_md.hpte_updateboltedpp = pSeries_lpar_hpte_updateboltedpp;
>  	ppc_md.hpte_insert	= pSeries_lpar_hpte_insert;
>  	ppc_md.hpte_remove	= pSeries_lpar_hpte_remove;
> +	ppc_md.hpte_removebolted = pSeries_lpar_hpte_removebolted;
>  	ppc_md.flush_hash_range	= pSeries_lpar_flush_hash_range;
>  	ppc_md.hpte_clear_all   = pSeries_lpar_hptab_clear;
>  }
> Index: linux-2.6.24-rc8/include/asm-powerpc/machdep.h
> ===================================================================
> --- linux-2.6.24-rc8.orig/include/asm-powerpc/machdep.h	2008-01-25 08:04:41.000000000 -0800
> +++ linux-2.6.24-rc8/include/asm-powerpc/machdep.h	2008-01-28 11:45:17.000000000 -0800
> @@ -68,6 +68,8 @@ struct machdep_calls {
>  				       unsigned long vflags,
>  				       int psize, int ssize);
>  	long		(*hpte_remove)(unsigned long hpte_group);
> +	void            (*hpte_removebolted)(unsigned long ea,
> +					     int psize, int ssize);
>  	void		(*flush_hash_range)(unsigned long number, int local);
>  
>  	/* special for kexec, to be called in real mode, linar mapping is
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
