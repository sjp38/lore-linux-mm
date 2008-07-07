Date: Mon, 7 Jul 2008 10:16:38 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH] Make CONFIG_MIGRATION available for s390
Message-ID: <20080707090635.GA6797@shadowen.org>
References: <1215354957.9842.19.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1215354957.9842.19.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 06, 2008 at 04:35:57PM +0200, Gerald Schaefer wrote:
> From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> 
> We'd like to support CONFIG_MEMORY_HOTREMOVE on s390, which depends on
> CONFIG_MIGRATION. So far, CONFIG_MIGRATION is only available with NUMA
> support.
> 
> This patch makes CONFIG_MIGRATION selectable for architectures that define
> ARCH_ENABLE_MEMORY_HOTREMOVE. When MIGRATION is enabled w/o NUMA, the kernel
> won't compile because of a missing migrate() function in vm_operations_struct
> and a missing policy_zone reference in vma_migratable(). To avoid this,
> "#ifdef CONFIG_NUMA" is added to vma_migratable() and the vm_ops migrate()
> definition is moved from "#ifdef CONFIG_NUMA" to "#ifdef CONFIG_MIGRATION".
> 
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> ---
> 
>  include/linux/migrate.h |    2 ++
>  include/linux/mm.h      |    2 ++
>  mm/Kconfig              |    2 +-
>  3 files changed, 5 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/include/linux/migrate.h
> ===================================================================
> --- linux-2.6.orig/include/linux/migrate.h
> +++ linux-2.6/include/linux/migrate.h
> @@ -13,6 +13,7 @@ static inline int vma_migratable(struct 
>  {
>  	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
>  		return 0;
> +#ifdef CONFIG_NUMA
>  	/*
>  	 * Migration allocates pages in the highest zone. If we cannot
>  	 * do so then migration (at least from node to node) is not
> @@ -22,6 +23,7 @@ static inline int vma_migratable(struct 
>  		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
>  								< policy_zone)
>  			return 0;
> +#endif

include/linux/mempolicy.h already has a !NUMA section could we not just
define policy_zone as 0 in that and leave this code unconditionally
compiled?  Perhaps also adding a NUMA_BUILD && to this 'if' should that
be clearer.

But this does make me feel uneasy.  Are we really saying all memory on
an s390 is migratable.  That seems unlikely.  As I understand the NUMA
case, we only allow migration of memory in the last zone (last two if we
have a MOVABLE zone) why are things different just because we have a
single 'node'.  Hmmm.  I suspect strongly that something is missnamed
more than there is a problem.

>  	return 1;
>  }
>  
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -193,6 +193,8 @@ struct vm_operations_struct {
>  	 */
>  	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
>  					unsigned long addr);
> +#endif
> +#ifdef CONFIG_MIGRATION
>  	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
>  		const nodemask_t *to, unsigned long flags);
>  #endif
> Index: linux-2.6/mm/Kconfig
> ===================================================================
> --- linux-2.6.orig/mm/Kconfig
> +++ linux-2.6/mm/Kconfig
> @@ -174,7 +174,7 @@ config SPLIT_PTLOCK_CPUS
>  config MIGRATION
>  	bool "Page migration"
>  	def_bool y
> -	depends on NUMA
> +	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE
>  	help
>  	  Allows the migration of the physical location of pages of processes
>  	  while the virtual addresses are not changed. This is useful for
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
