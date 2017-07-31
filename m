Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF3AC6B05F5
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:41:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h126so20087928wmf.10
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 05:41:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w71si26225353wrc.225.2017.07.31.05.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 05:41:07 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6VCeN1l116594
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:41:06 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c20c64yq3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:41:06 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 31 Jul 2017 13:41:03 +0100
Date: Mon, 31 Jul 2017 14:40:53 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [RFC PATCH 2/5] mm, arch: unify vmemmap_populate altmap
 handling
In-Reply-To: <20170726083333.17754-3-mhocko@kernel.org>
References: <20170726083333.17754-1-mhocko@kernel.org>
	<20170726083333.17754-3-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20170731144053.38c8b012@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, gerald.schaefer@de.ibm.com

On Wed, 26 Jul 2017 10:33:30 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> vmem_altmap allows vmemmap_populate to allocate memmap (struct page
> array) from an alternative allocator rather than bootmem resp.
> kmalloc. Only x86 currently supports altmap handling, most likely
> because only nvdim code uses this mechanism currently and the code
> depends on ZONE_DEVICE which is present only for x86_64. This will
> change in follow up changes so we would like other architectures
> to support it as well.
> 
> Provide vmemmap_populate generic implementation which simply resolves
> altmap and then call into arch specific __vmemmap_populate.
> Architectures then only need to use __vmemmap_alloc_block_buf to
> allocate the memmap. vmemmap_free then needs to call vmem_altmap_free
> if there is any altmap associated with the address.
> 
> This patch shouldn't introduce any functional changes because
> to_vmem_altmap always returns NULL on !x86_x64.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-ia64@vger.kernel.org
> Cc: x86@kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/arm64/mm/mmu.c       |  9 ++++++---
>  arch/ia64/mm/discontig.c  |  4 +++-
>  arch/powerpc/mm/init_64.c | 29 ++++++++++++++++++++---------
>  arch/s390/mm/vmem.c       |  7 ++++---
>  arch/sparc/mm/init_64.c   |  6 +++---
>  arch/x86/mm/init_64.c     |  4 ++--
>  include/linux/memremap.h  | 13 ++-----------
>  include/linux/mm.h        | 19 ++++++++++++++++++-
>  mm/sparse-vmemmap.c       |  2 +-
>  9 files changed, 59 insertions(+), 34 deletions(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 0c429ec6fde8..5de1161e7a1b 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -649,12 +649,15 @@ int kern_addr_valid(unsigned long addr)
>  }
>  #ifdef CONFIG_SPARSEMEM_VMEMMAP
>  #if !ARM64_SWAPPER_USES_SECTION_MAPS
> -int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
> +int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
> +		struct vmem_altmap *altmap)
>  {
> +	WARN(altmap, "altmap unsupported\n");
>  	return vmemmap_populate_basepages(start, end, node);
>  }
>  #else	/* !ARM64_SWAPPER_USES_SECTION_MAPS */
> -int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
> +int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
> +		struct vmem_altmap *altmap)
>  {
>  	unsigned long addr = start;
>  	unsigned long next;
> @@ -677,7 +680,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
>  		if (pmd_none(*pmd)) {
>  			void *p = NULL;
> 
> -			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
> +			p = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
>  			if (!p)
>  				return -ENOMEM;
> 
> diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
> index 878626805369..2a939e877ced 100644
> --- a/arch/ia64/mm/discontig.c
> +++ b/arch/ia64/mm/discontig.c
> @@ -753,8 +753,10 @@ void arch_refresh_nodedata(int update_node, pg_data_t *update_pgdat)
>  #endif
> 
>  #ifdef CONFIG_SPARSEMEM_VMEMMAP
> -int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
> +int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
> +		struct vmem_altmap *altmap)
>  {
> +	WARN(altmap, "altmap unsupported\n");
>  	return vmemmap_populate_basepages(start, end, node);
>  }
> 
> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> index ec84b31c6c86..5ea5e870a589 100644
> --- a/arch/powerpc/mm/init_64.c
> +++ b/arch/powerpc/mm/init_64.c
> @@ -44,6 +44,7 @@
>  #include <linux/slab.h>
>  #include <linux/of_fdt.h>
>  #include <linux/libfdt.h>
> +#include <linux/memremap.h>
> 
>  #include <asm/pgalloc.h>
>  #include <asm/page.h>
> @@ -115,7 +116,8 @@ static struct vmemmap_backing *next;
>  static int num_left;
>  static int num_freed;
> 
> -static __meminit struct vmemmap_backing * vmemmap_list_alloc(int node)
> +static __meminit struct vmemmap_backing * vmemmap_list_alloc(int node,
> +		struct vmem_altmap *altmap)
>  {
>  	struct vmemmap_backing *vmem_back;
>  	/* get from freed entries first */
> @@ -129,7 +131,7 @@ static __meminit struct vmemmap_backing * vmemmap_list_alloc(int node)
> 
>  	/* allocate a page when required and hand out chunks */
>  	if (!num_left) {
> -		next = vmemmap_alloc_block(PAGE_SIZE, node);
> +		next = __vmemmap_alloc_block_buf(PAGE_SIZE, node, altmap);
>  		if (unlikely(!next)) {
>  			WARN_ON(1);
>  			return NULL;
> @@ -144,11 +146,12 @@ static __meminit struct vmemmap_backing * vmemmap_list_alloc(int node)
> 
>  static __meminit void vmemmap_list_populate(unsigned long phys,
>  					    unsigned long start,
> -					    int node)
> +					    int node,
> +					    struct vmem_altmap *altmap)
>  {
>  	struct vmemmap_backing *vmem_back;
> 
> -	vmem_back = vmemmap_list_alloc(node);
> +	vmem_back = vmemmap_list_alloc(node, altmap);
>  	if (unlikely(!vmem_back)) {
>  		WARN_ON(1);
>  		return;
> @@ -161,14 +164,15 @@ static __meminit void vmemmap_list_populate(unsigned long phys,
>  	vmemmap_list = vmem_back;
>  }
> 
> -int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
> +int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
> +		struct vmem_altmap *altmap)
>  {
>  	unsigned long page_size = 1 << mmu_psize_defs[mmu_vmemmap_psize].shift;
> 
>  	/* Align to the page size of the linear mapping. */
>  	start = _ALIGN_DOWN(start, page_size);
> 
> -	pr_debug("vmemmap_populate %lx..%lx, node %d\n", start, end, node);
> +	pr_debug("__vmemmap_populate %lx..%lx, node %d\n", start, end, node);
> 
>  	for (; start < end; start += page_size) {
>  		void *p;
> @@ -177,11 +181,11 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
>  		if (vmemmap_populated(start, page_size))
>  			continue;
> 
> -		p = vmemmap_alloc_block(page_size, node);
> +		p = __vmemmap_alloc_block_buf(page_size, node, altmap);
>  		if (!p)
>  			return -ENOMEM;
> 
> -		vmemmap_list_populate(__pa(p), start, node);
> +		vmemmap_list_populate(__pa(p), start, node, altmap);
> 
>  		pr_debug("      * %016lx..%016lx allocated at %p\n",
>  			 start, start + page_size, p);
> @@ -189,7 +193,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
>  		rc = vmemmap_create_mapping(start, page_size, __pa(p));
>  		if (rc < 0) {
>  			pr_warning(
> -				"vmemmap_populate: Unable to create vmemmap mapping: %d\n",
> +				"__vmemmap_populate: Unable to create vmemmap mapping: %d\n",
>  				rc);
>  			return -EFAULT;
>  		}
> @@ -253,6 +257,12 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
>  		addr = vmemmap_list_free(start);
>  		if (addr) {
>  			struct page *page = pfn_to_page(addr >> PAGE_SHIFT);
> +			struct vmem_altmap *altmap = to_vmem_altmap((unsigned long) page);
> +
> +			if (altmap) {
> +				vmem_altmap_free(altmap, page_size >> PAGE_SHIFT);
> +				goto unmap;
> +			}
> 
>  			if (PageReserved(page)) {
>  				/* allocated from bootmem */
> @@ -272,6 +282,7 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
>  				free_pages((unsigned long)(__va(addr)),
>  							get_order(page_size));
> 
> +unmap:
>  			vmemmap_remove_mapping(start, page_size);
>  		}
>  	}
> diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
> index c33c94b4be60..07120bc137a1 100644
> --- a/arch/s390/mm/vmem.c
> +++ b/arch/s390/mm/vmem.c
> @@ -208,7 +208,8 @@ static void vmem_remove_range(unsigned long start, unsigned long size)
>  /*
>   * Add a backed mem_map array to the virtual mem_map array.
>   */
> -int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
> +int __meminit __vmemmap_populate(unsigned long start, unsigned long end, int node,
> +		struct vmem_altmap *altmap)
>  {
>  	unsigned long pgt_prot, sgt_prot;
>  	unsigned long address = start;
> @@ -247,12 +248,12 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
>  			 * use large frames even if they are only partially
>  			 * used.
>  			 * Otherwise we would have also page tables since
> -			 * vmemmap_populate gets called for each section
> +			 * __vmemmap_populate gets called for each section
>  			 * separately. */
>  			if (MACHINE_HAS_EDAT1) {
>  				void *new_page;
> 
> -				new_page = vmemmap_alloc_block(PMD_SIZE, node);
> +				new_page = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
>  				if (!new_page)
>  					goto out;
>  				pmd_val(*pm_dir) = __pa(new_page) | sgt_prot;

There is another call to vmemmap_alloc_block() in this function, a couple
of lines below, this should also be replaced by __vmemmap_alloc_block_buf().

We won't be able to use this directly on s390 yet, but your work should
get us a big step closer, thanks.

Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
