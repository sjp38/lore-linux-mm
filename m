Date: Tue, 26 Oct 2004 15:37:31 +0900 (JST)
Message-Id: <20041026.153731.38067476.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041025213923.GD23133@logos.cnet>
References: <20041025213923.GD23133@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi,

I tested your patch and dead-locked has been occured in
do_swap_page().

> This is an improved version of the migration cache patch - 
> thanks to everyone who contributed - Hirokazu, Iwamoto, Dave,
> Hugh.

> diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/memory.c linux-2.6.9-rc2-mm4.build/mm/memory.c
> --- linux-2.6.9-rc2-mm4.mhp.orig/mm/memory.c	2004-10-05 15:08:23.000000000 -0300
> +++ linux-2.6.9-rc2-mm4.build/mm/memory.c	2004-10-25 19:35:18.000000000 -0200
> @@ -1433,15 +1440,22 @@ again:
>  		inc_page_state(pgmajfault);
>  		grab_swap_token();
>  	}
> -
>  	mark_page_accessed(page);
>  	lock_page(page);
>  	if (!PageSwapCache(page)) {
> +		/* hiro: add !PageMigration(page) here */
>  		/* page-migration has occured */
>  		unlock_page(page);
>  		page_cache_release(page);
>  		goto again;
>  	}
> +	}
> +
> +
> +	if (pte_is_migration(orig_pte)) {
> +		mark_page_accessed(page);
> +		lock_page(page);


The previous code will cause deadlock, as the page is already locked.

> +	}
>  
>  	/*
>  	 * Back out if somebody else faulted in this pte while we
> @@ -1459,10 +1473,14 @@ again:
>  	}
>  
>  	/* The page isn't present yet, go ahead with the fault. */
> -		
> -	swap_free(entry);
> -	if (vm_swap_full())
> -		remove_exclusive_swap_page(page);
> +
> +	if (!pte_is_migration(orig_pte)) {
> +		swap_free(entry);
> +		if (vm_swap_full())
> +			remove_exclusive_swap_page(page);
> +	} else {
> +		migration_remove_reference(page);

migration_remove_reference() also tries to lock the page that is
already locked.

> +	}
>  
>  	mm->rss++;
>  	pte = mk_pte(page, vma->vm_page_prot);
> diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/mmigrate.c linux-2.6.9-rc2-mm4.build/mm/mmigrate.c
> --- linux-2.6.9-rc2-mm4.mhp.orig/mm/mmigrate.c	2004-10-05 15:08:23.000000000 -0300
> +++ linux-2.6.9-rc2-mm4.build/mm/mmigrate.c	2004-10-25 20:34:35.324971872 -0200

> +int migration_remove_reference(struct page *page)
> +{
> +	struct counter *c;
> +	swp_entry_t entry;
> +
> +	entry.val = page->private;
> +
> +	read_lock_irq(&migration_space.tree_lock);
> +
> +	c = idr_find(&migration_idr, swp_offset(entry));
> +
> +	read_unlock_irq(&migration_space.tree_lock);
> +
> +	if (!c->i)
> +		BUG();
> +
> +	c->i--;
> +
> +	if (!c->i) {
> +		lock_page(page);

It will be dead-locked when this function is called from do_swap_page().

> +		remove_from_migration_cache(page, page->private);
> +		unlock_page(page);
> +		kfree(c);
> +	}
> +		
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
