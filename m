Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id DD68D6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:12:32 -0400 (EDT)
Message-ID: <5045C749.80904@cn.fujitsu.com>
Date: Tue, 04 Sep 2012 17:18:01 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/4] mm: introduce a safer interface to check whether
 a page is managed by SLxB
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

At 07/03/2012 11:57 AM, Jiang Liu Wrote:
> Several subsystems, including memory-failure, swap, sparse, DRBD etc,
> use PageSlab() to check whether a page is managed by SLAB/SLUB/SLOB.
> And they treat slab pages differently from pagecache/anonymous pages.
> 
> But it's unsafe to use PageSlab() to detect whether a page is managed by
> SLUB. SLUB allocates compound pages when page order is bigger than 0 and
> only sets PG_slab on head pages. So if a SLUB object is hosted by a tail
> page, PageSlab() will incorrectly return false for that object.
> 
> Following code from sparse.c triggers this issue, which causes failure
> when removing a hot-added memory device.

Hi, Liu

What is the status of this patch?
I encounter the same problem when removing a hot-added memory device. It
causes the kernel panicked

Thanks
Wen Congyang

>         /*
>          * Check to see if allocation came from hot-plug-add
>          */
>         if (PageSlab(usemap_page)) {
>                 kfree(usemap);
>                 if (memmap)
>                         __kfree_section_memmap(memmap, PAGES_PER_SECTION);
>                 return;
>         }
> 
> So introduce a transparent huge page and compound page safe macro as below
> to check whether a page is managed by SLAB/SLUB/SLOB allocator.
> 
> #define page_managed_by_slab(page)     (!!PageSlab(compound_trans_head(page)))
> 
> Signed-off-by: Jiang Liu <liuj97@gmail.com>
> ---
>  arch/arm/mm/init.c             |    3 ++-
>  arch/ia64/kernel/mca_drv.c     |    2 +-
>  arch/unicore32/mm/init.c       |    3 ++-
>  crypto/scatterwalk.c           |    2 +-
>  drivers/ata/libata-sff.c       |    3 ++-
>  drivers/block/drbd/drbd_main.c |    3 ++-
>  fs/proc/page.c                 |    4 ++--
>  include/linux/slab.h           |    7 +++++++
>  mm/memory-failure.c            |    6 +++---
>  mm/sparse.c                    |    4 +---
>  10 files changed, 23 insertions(+), 14 deletions(-)
> 
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index f54d592..73ff340 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -18,6 +18,7 @@
>  #include <linux/initrd.h>
>  #include <linux/of_fdt.h>
>  #include <linux/highmem.h>
> +#include <linux/huge_mm.h>
>  #include <linux/gfp.h>
>  #include <linux/memblock.h>
>  #include <linux/dma-contiguous.h>
> @@ -116,7 +117,7 @@ void show_mem(unsigned int filter)
>  				reserved++;
>  			else if (PageSwapCache(page))
>  				cached++;
> -			else if (PageSlab(page))
> +			else if (page_managed_by_slab(page))
>  				slab++;
>  			else if (!page_count(page))
>  				free++;
> diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
> index 1c2e894..4415bb6 100644
> --- a/arch/ia64/kernel/mca_drv.c
> +++ b/arch/ia64/kernel/mca_drv.c
> @@ -136,7 +136,7 @@ mca_page_isolate(unsigned long paddr)
>  		return ISOLATE_NG;
>  
>  	/* kick pages having attribute 'SLAB' or 'Reserved' */
> -	if (PageSlab(p) || PageReserved(p))
> +	if (page_managed_by_slab(p) || PageReserved(p))
>  		return ISOLATE_NG;
>  
>  	/* add attribute 'Reserved' and register the page */
> diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
> index de186bd..829a0d9 100644
> --- a/arch/unicore32/mm/init.c
> +++ b/arch/unicore32/mm/init.c
> @@ -21,6 +21,7 @@
>  #include <linux/sort.h>
>  #include <linux/dma-mapping.h>
>  #include <linux/export.h>
> +#include <linux/huge_mm.h>
>  
>  #include <asm/sections.h>
>  #include <asm/setup.h>
> @@ -83,7 +84,7 @@ void show_mem(unsigned int filter)
>  				reserved++;
>  			else if (PageSwapCache(page))
>  				cached++;
> -			else if (PageSlab(page))
> +			else if (page_managed_by_slab(page))
>  				slab++;
>  			else if (!page_count(page))
>  				free++;
> diff --git a/crypto/scatterwalk.c b/crypto/scatterwalk.c
> index 7281b8a..a20e019 100644
> --- a/crypto/scatterwalk.c
> +++ b/crypto/scatterwalk.c
> @@ -54,7 +54,7 @@ static void scatterwalk_pagedone(struct scatter_walk *walk, int out,
>  		struct page *page;
>  
>  		page = sg_page(walk->sg) + ((walk->offset - 1) >> PAGE_SHIFT);
> -		if (!PageSlab(page))
> +		if (!page_managed_by_slab(page))
>  			flush_dcache_page(page);
>  	}
>  
> diff --git a/drivers/ata/libata-sff.c b/drivers/ata/libata-sff.c
> index d8af325..1ab8378 100644
> --- a/drivers/ata/libata-sff.c
> +++ b/drivers/ata/libata-sff.c
> @@ -38,6 +38,7 @@
>  #include <linux/module.h>
>  #include <linux/libata.h>
>  #include <linux/highmem.h>
> +#include <linux/huge_mm.h>
>  
>  #include "libata.h"
>  
> @@ -734,7 +735,7 @@ static void ata_pio_sector(struct ata_queued_cmd *qc)
>  				       do_write);
>  	}
>  
> -	if (!do_write && !PageSlab(page))
> +	if (!do_write && !page_managed_by_slab(page))
>  		flush_dcache_page(page);
>  
>  	qc->curbytes += qc->sect_size;
> diff --git a/drivers/block/drbd/drbd_main.c b/drivers/block/drbd/drbd_main.c
> index 920ede2..de5b395 100644
> --- a/drivers/block/drbd/drbd_main.c
> +++ b/drivers/block/drbd/drbd_main.c
> @@ -2734,7 +2734,8 @@ static int _drbd_send_page(struct drbd_conf *mdev, struct page *page,
>  	 * put_page(); and would cause either a VM_BUG directly, or
>  	 * __page_cache_release a page that would actually still be referenced
>  	 * by someone, leading to some obscure delayed Oops somewhere else. */
> -	if (disable_sendpage || (page_count(page) < 1) || PageSlab(page))
> +	if (disable_sendpage || (page_count(page) < 1) ||
> +	    page_managed_by_slab(page))
>  		return _drbd_no_send_page(mdev, page, offset, size, msg_flags);
>  
>  	msg_flags |= MSG_NOSIGNAL;
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index 7fcd0d6..ae42dc7 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -40,7 +40,7 @@ static ssize_t kpagecount_read(struct file *file, char __user *buf,
>  			ppage = pfn_to_page(pfn);
>  		else
>  			ppage = NULL;
> -		if (!ppage || PageSlab(ppage))
> +		if (!ppage || page_managed_by_slab(ppage))
>  			pcount = 0;
>  		else
>  			pcount = page_mapcount(ppage);
> @@ -98,7 +98,7 @@ u64 stable_page_flags(struct page *page)
>  	 * Note that page->_mapcount is overloaded in SLOB/SLUB/SLQB, so the
>  	 * simple test in page_mapped() is not enough.
>  	 */
> -	if (!PageSlab(page) && page_mapped(page))
> +	if (!page_managed_by_slab(page) && page_mapped(page))
>  		u |= 1 << KPF_MMAP;
>  	if (PageAnon(page))
>  		u |= 1 << KPF_ANON;
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 67d5d94..bb26fab 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -364,4 +364,11 @@ static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
>  
>  void __init kmem_cache_init_late(void);
>  
> +/*
> + * Check whether a page is allocated/managed by SLAB/SLUB/SLOB allocator.
> + * Defined as macro instead of function to avoid header file pollution.
> + */
> +#define page_managed_by_slab(page)	(!!PageSlab(compound_trans_head(page)))
> +#define mem_managed_by_slab(addr)	page_managed_by_slab(virt_to_page(addr))
> +
>  #endif	/* _LINUX_SLAB_H */
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index ab1e714..684e7f7 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -88,7 +88,7 @@ static int hwpoison_filter_dev(struct page *p)
>  	/*
>  	 * page_mapping() does not accept slab pages.
>  	 */
> -	if (PageSlab(p))
> +	if (page_managed_by_slab(p))
>  		return -EINVAL;
>  
>  	mapping = page_mapping(p);
> @@ -233,7 +233,7 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
>   */
>  void shake_page(struct page *p, int access)
>  {
> -	if (!PageSlab(p)) {
> +	if (!page_managed_by_slab(p)) {
>  		lru_add_drain_all();
>  		if (PageLRU(p))
>  			return;
> @@ -862,7 +862,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  	struct page *hpage = compound_head(p);
>  	struct page *ppage;
>  
> -	if (PageReserved(p) || PageSlab(p))
> +	if (PageReserved(p) || page_managed_by_slab(p))
>  		return SWAP_SUCCESS;
>  
>  	/*
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 6a4bf91..32a908b 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -688,17 +688,15 @@ static void free_map_bootmem(struct page *page, unsigned long nr_pages)
>  
>  static void free_section_usemap(struct page *memmap, unsigned long *usemap)
>  {
> -	struct page *usemap_page;
>  	unsigned long nr_pages;
>  
>  	if (!usemap)
>  		return;
>  
> -	usemap_page = virt_to_page(usemap);
>  	/*
>  	 * Check to see if allocation came from hot-plug-add
>  	 */
> -	if (PageSlab(usemap_page)) {
> +	if (mem_managed_by_slab(usemap)) {
>  		kfree(usemap);
>  		if (memmap)
>  			__kfree_section_memmap(memmap, PAGES_PER_SECTION);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
