Date: Mon, 30 Jul 2007 19:19:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
In-Reply-To: <20070727232753.GA10311@localdomain>
Message-ID: <Pine.LNX.4.64.0707301913060.27023@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007, Ravikiran G Thirumalai wrote:

>  		       "Node %d Mapped:       %8lu kB\n"
>  		       "Node %d AnonPages:    %8lu kB\n"
>  		       "Node %d PageTables:   %8lu kB\n"
> +		       "Node %d PseudoFS:     %8lu kB\n"
>  		       "Node %d NFS_Unstable: %8lu kB\n"

			 Extempt from Reclaim: %8lu kb ?
Call this NR_FILE_UNRECLAIMABLE? Those pages should not end up on the LRU.

We likely will need NR_ANON_UNRECLAIMABLE if we do the removal of mlocked 
pages from the LRU. Mlocked pages then may have
to be accounted depending on them being file backed or not.

And keep this count out of NR_FILE_PAGES. Then we wont have to change zone 
reclaim.

> Index: linux-2.6.22/mm/filemap.c
> ===================================================================
> --- linux-2.6.22.orig/mm/filemap.c
> +++ linux-2.6.22/mm/filemap.c
> @@ -119,6 +119,8 @@ void __remove_from_page_cache(struct pag
>  	radix_tree_delete(&mapping->page_tree, page->index);
>  	page->mapping = NULL;
>  	mapping->nrpages--;
> +	if (mapping->backing_dev_info->capabilities & BDI_CAP_NO_WRITEBACK)
> +		__dec_zone_page_state(page, NR_PSEUDO_FS_PAGES);

We probably need a BDI_CAP_UNRECLAIMABLE or so?
Do not increment NR_FILE_PAGES for BDI_CAP_UNRECLAIMABLE.


	else

	>  	__dec_zone_page_state(page, NR_FILE_PAGES);
>  }
>  
> @@ -448,6 +450,9 @@ int add_to_page_cache(struct page *page,
>  			page->mapping = mapping;
>  			page->index = offset;
>  			mapping->nrpages++;
> +			if (mapping->backing_dev_info->capabilities
> +				& BDI_CAP_NO_WRITEBACK)
> +				__inc_zone_page_state(page, NR_PSEUDO_FS_PAGES);
			else
	>  			__inc_zone_page_state(page, NR_FILE_PAGES);
>  		}
>  		write_unlock_irq(&mapping->tree_lock);

> Index: linux-2.6.22/mm/migrate.c
> ===================================================================
> --- linux-2.6.22.orig/mm/migrate.c
> +++ linux-2.6.22/mm/migrate.c
> @@ -346,6 +346,11 @@ static int migrate_page_move_mapping(str
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
>  	__inc_zone_page_state(newpage, NR_FILE_PAGES);
>  
> +	if (mapping->backing_dev_info->capabilities & BDI_CAP_NO_WRITEBACK) {
> +		__dec_zone_page_state(page, NR_PSEUDO_FS_PAGES);
> +		__inc_zone_page_state(newpage, NR_PSEUDO_FS_PAGES);
> +	}
> +
>  	write_unlock_irq(&mapping->tree_lock);

If unreclaimable pages are not on the LRU then you do not need this.
  
>  	return 0;
> Index: linux-2.6.22/mm/vmscan.c
> ===================================================================
> --- linux-2.6.22.orig/mm/vmscan.c
> +++ linux-2.6.22/mm/vmscan.c

None of the modifications to vmscan.c are needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
