Date: Tue, 29 May 2007 11:01:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/7] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA
In-Reply-To: <20070529173710.1570.91203.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705291057170.24126@schroedinger.engr.sgi.com>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
 <20070529173710.1570.91203.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 29 May 2007, Mel Gorman wrote:

> CONFIG_MIGRATION currently depends on CONFIG_NUMA. move_pages() is the only
> user of migration today and as this system call is only meaningful on NUMA,
> it makes sense. However, memory compaction will operate within a zone and is
> useful on both NUMA and non-NUMA systems. This patch allows CONFIG_MIGRATION
> to be used in all memory models. To preserve existing behaviour, move_pages()
> is only available when CONFIG_NUMA is set.

Hmmm... I thought I had this already set up so that it would be easy to 
switch page migration to not depend on CONFIG_NUMA. Not so it seems.

> --- linux-2.6.22-rc2-mm1-005_migrate_nocontext/include/linux/migrate.h	2007-05-28 14:11:32.000000000 +0100
> +++ linux-2.6.22-rc2-mm1-015_migration_flatmem/include/linux/migrate.h	2007-05-29 10:00:09.000000000 +0100
> @@ -7,7 +7,7 @@
>  
>  typedef struct page *new_page_t(struct page *, unsigned long private, int **);
>  
> -#ifdef CONFIG_MIGRATION
> +#ifdef CONFIG_SYSCALL_MOVE_PAGES
>  /* Check if a vma is migratable */
>  static inline int vma_migratable(struct vm_area_struct *vma)
>  {
> @@ -24,7 +24,14 @@ static inline int vma_migratable(struct 
>  			return 0;
>  	return 1;
>  }
> +#else
> +static inline int vma_migratable(struct vm_area_struct *vma)
> +{
> +	return 0;
> +}
> +#endif

I guess we get compilation failures because of the reference to 
policy_zone here for the !NUMA case? I think vma migratable is not used at 
all if !NUMA.


> +#ifdef CONFIG_MIGRATION
>  extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
>  extern int putback_lru_pages(struct list_head *l);
>  extern int migrate_page(struct address_space *,
> @@ -40,8 +47,6 @@ extern int migrate_vmas(struct mm_struct
>  		const nodemask_t *from, const nodemask_t *to,
>  		unsigned long flags);
>  #else
> -static inline int vma_migratable(struct vm_area_struct *vma)
> -					{ return 0; }

Maybe this block is not necessary?

> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-005_migrate_nocontext/include/linux/mm.h linux-2.6.22-rc2-mm1-015_migration_flatmem/include/linux/mm.h
> --- linux-2.6.22-rc2-mm1-005_migrate_nocontext/include/linux/mm.h	2007-05-24 10:13:34.000000000 +0100
> +++ linux-2.6.22-rc2-mm1-015_migration_flatmem/include/linux/mm.h	2007-05-28 14:13:44.000000000 +0100
> @@ -242,6 +242,8 @@ struct vm_operations_struct {
>  	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
>  	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
>  					unsigned long addr);
> +#endif /* CONFIG_NUMA */
> +#ifdef CONFIG_MIGRATION
>  	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
>  		const nodemask_t *to, unsigned long flags);
>  #endif

Correct.

> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-005_migrate_nocontext/mm/Kconfig linux-2.6.22-rc2-mm1-015_migration_flatmem/mm/Kconfig
> --- linux-2.6.22-rc2-mm1-005_migrate_nocontext/mm/Kconfig	2007-05-24 10:13:34.000000000 +0100
> +++ linux-2.6.22-rc2-mm1-015_migration_flatmem/mm/Kconfig	2007-05-29 09:57:23.000000000 +0100
> @@ -145,13 +145,16 @@ config SPLIT_PTLOCK_CPUS
>  config MIGRATION
>  	bool "Page migration"
>  	def_bool y
> -	depends on NUMA
>  	help
>  	  Allows the migration of the physical location of pages of processes
>  	  while the virtual addresses are not changed. This is useful for
>  	  example on NUMA systems to put pages nearer to the processors accessing
>  	  the page.
>  
> +config SYSCALL_MOVE_PAGES
> +	def_bool y
> +	depends on MIGRATION && NUMA
> +

Do we really need the CONFIG_SYSCALL_MOVE_PAGES? I think you will directly 
access the lower levels. So why have it? CONFIG_SYSCALL_MOVE_PAGES == 
CONFIG_NUMA.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
