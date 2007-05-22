Date: Tue, 22 May 2007 11:49:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch] memory unplug v3 [2/4] migration by kernel
In-Reply-To: <20070522160437.6607f445.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705221143450.29456@schroedinger.engr.sgi.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
 <20070522160437.6607f445.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007, KAMEZAWA Hiroyuki wrote:

> +config MIGRATION_BY_KERNEL
> +	bool "Page migration by kernel's page scan"
> +	def_bool y
> +	depends on MIGRATION
> +	help
> +	  Allows page migration from kernel context. This means page migration
> +	  can be done by codes other than sys_migrate() system call. Will add
> +	  some additional check code in page migration.

I think the scope of this is much bigger than you imagine. This is also 
going to be useful when Mel is going to implement defragmentation. So I 
think this should not be a separate option but be on by default.

> Index: devel-2.6.22-rc1-mm1/mm/migrate.c
> ===================================================================
> --- devel-2.6.22-rc1-mm1.orig/mm/migrate.c	2007-05-22 14:30:39.000000000 +0900
> +++ devel-2.6.22-rc1-mm1/mm/migrate.c	2007-05-22 15:12:29.000000000 +0900
> @@ -607,11 +607,12 @@
>   * to the newly allocated page in newpage.
>   */
>  static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> -			struct page *page, int force)
> +			struct page *page, int force, int context)

context is set if there is no context? Call this nocontext instead?

>  
> -	if (rc)
> +	if (rc) {
>  		remove_migration_ptes(page, page);
> +	}

Why are you adding { } here?

> +#ifdef CONFIG_MIGRATION_BY_KERNEL
> +	if (anon_vma)
> +		anon_vma_release(anon_vma);
> +#endif

The check for anon_vma != NULL could be put into anon_vma_release to avoid 
the ifdef.

> Index: devel-2.6.22-rc1-mm1/mm/rmap.c
> ===================================================================
> --- devel-2.6.22-rc1-mm1.orig/mm/rmap.c	2007-05-22 14:30:39.000000000 +0900
> +++ devel-2.6.22-rc1-mm1/mm/rmap.c	2007-05-22 15:12:29.000000000 +0900
> @@ -203,6 +203,28 @@
>  	spin_unlock(&anon_vma->lock);
>  	rcu_read_unlock();
>  }
> +#ifdef CONFIG_MIGRATION_BY_KERNEL
> +struct anon_vma *anon_vma_hold(struct page *page) {
> +	struct anon_vma *anon_vma;
> +	anon_vma = page_lock_anon_vma(page);
> +	if (!anon_vma)
> +		return NULL;
> +	atomic_set(&anon_vma->ref, 1);

Why use an atomic value if it is set and cleared within a spinlock?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
