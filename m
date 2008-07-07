Date: Mon, 07 Jul 2008 15:22:24 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] Make CONFIG_MIGRATION available for s390
In-Reply-To: <1215354957.9842.19.camel@localhost.localdomain>
References: <1215354957.9842.19.camel@localhost.localdomain>
Message-Id: <20080707150413.5A51.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Looks good to me.

Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Bye.


> Subject: [PATCH] Make CONFIG_MIGRATION available for s390
> 
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

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
