Date: Tue, 11 Apr 2006 11:32:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm1 3/6] Migrate-on-fault - migrate misplaced
 page
In-Reply-To: <1144441424.5198.42.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0604111124090.878@schroedinger.engr.sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
 <1144441424.5198.42.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2006, Lee Schermerhorn wrote:

> @@ -184,6 +185,31 @@ int do_migrate_pages(struct mm_struct *m
>  int mpol_misplaced(struct page *, struct vm_area_struct *,
>  		unsigned long, int *);
>  
> +#if defined(CONFIG_MIGRATION) && defined(_LINUX_MM_H)

Remove the defined(_LINUX_MM_H). This is pretty obscure.

> Index: linux-2.6.17-rc1-mm1/mm/migrate.c
> ===================================================================
> --- linux-2.6.17-rc1-mm1.orig/mm/migrate.c	2006-04-05 10:14:38.000000000 -0400
> +++ linux-2.6.17-rc1-mm1/mm/migrate.c	2006-04-05 10:14:41.000000000 -0400
> @@ -59,7 +59,8 @@ int isolate_lru_page(struct page *page, 
>  				del_page_from_active_list(zone, page);
>  			else
>  				del_page_from_inactive_list(zone, page);
> -			list_add_tail(&page->lru, pagelist);
> +			if (pagelist)
> +				list_add_tail(&page->lru, pagelist);
>  		}
>  		spin_unlock_irq(&zone->lru_lock);
>  	}

isolate lru page can be called without a pagelist now?


> -int fail_migrate_page(struct page *newpage, struct page *page)
> +int fail_migrate_page(struct page *newpage, struct page *page, int faulting)

I do not think the faulting parameter is needed. mapcount == 0 if 
we are faulting on an unmapped page. try_to_unmap() will do nothing or 
you can check for mapcount.

>  	 *
>  	 * Note that a real pte entry will allow processes that are not
>  	 * waiting on the page lock to use the new page via the page tables
>  	 * before the new page is unlocked.
>  	 */
> -	remove_from_swap(newpage);
> +	if (!faulting)
> +		remove_from_swap(newpage);
>  	return 0;

If we are faulting then there is nothing to remove. remove_from_swap would 
do nothing.

> +out:
> +	putback_lru_page(page);		/* drops a page ref */

We already have a ref from the fault patch and do not need another one 
in isolate_lru page right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
