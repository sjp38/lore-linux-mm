Date: Fri, 18 Jul 2008 15:22:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmtom] please drop memcg-handle-swap-cache set (memcg handle
 swap cache rework).
Message-Id: <20080718152232.31d36e0b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080718141511.a28d1ba1.nishimura@mxp.nes.nec.co.jp>
References: <20080717124556.3e4b6e20.kamezawa.hiroyu@jp.fujitsu.com>
	<20080718141511.a28d1ba1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jul 2008 14:15:11 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > Concerns:
> >   - shmem.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > 
> 
> I prefer this version, and it looks good to me.
> 
Thanks.


> > +	/* When this is called for removing a page cache in radix-tree,
> > +	   page->mapping must be NULL before here. */
> > +	if (likely(ctype != MEM_CGROUP_CHARGE_TYPE_FORCE))
> > +	    if (PageSwapCache(page) || page_mapped(page)
> > +	        || (page->mapping && !PageAnon(page)))
> >  		goto unlock;
> >  
> 
> I got checkpatch error/warning here.
> 
> I think this should be:
> 
> ===
> 	if (likely(ctype != MEM_CGROUP_CHARGE_TYPE_FORCE))
> 		if (PageSwapCache(page) || page_mapped(page)
> 		    || (page->mapping && !PageAnon(page)))
>  			goto unlock;
> ===
> 
ok, will rewrite.


> >  	mz = page_cgroup_zoneinfo(pc);
> > @@ -729,6 +730,7 @@ void mem_cgroup_uncharge_page(struct pag
> >  void mem_cgroup_uncharge_cache_page(struct page *page)
> >  {
> >  	VM_BUG_ON(page_mapped(page));
> > +	VM_BUG_ON(page->mapping);
> >  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> >  }
> >  
> > Index: mmtom-stamp-2008-07-15-15-39/mm/migrate.c
> > ===================================================================
> > --- mmtom-stamp-2008-07-15-15-39.orig/mm/migrate.c
> > +++ mmtom-stamp-2008-07-15-15-39/mm/migrate.c
> > @@ -358,9 +358,6 @@ static int migrate_page_move_mapping(str
> >  	__inc_zone_page_state(newpage, NR_FILE_PAGES);
> >  
> >  	write_unlock_irq(&mapping->tree_lock);
> > -	if (!PageSwapCache(newpage)) {
> > -		mem_cgroup_uncharge_cache_page(page);
> > -	}
> >  
> >  	return 0;
> >  }
> > @@ -398,12 +395,27 @@ static void migrate_page_copy(struct pag
> >   	}
> >  
> >  #ifdef CONFIG_SWAP
> > -	ClearPageSwapCache(page);
> > +	if (PageSwapCache(page)) {
> > +		/*
> > +		 * SwapCache is removed implicitly. To uncharge SwapCache,
> > +		 * SwapCache flag should be cleared.
> > +		 */
> > +		ClearPageSwapCache(page);
> > +		mem_cgroup_uncharge_page(page);
> > +	}
> >  #endif
> >  	ClearPageActive(page);
> >  	ClearPagePrivate(page);
> >  	set_page_private(page, 0);
> > -	page->mapping = NULL;
> > +
> > +	if (!PageAnon(page)) {
> > +		/*
> > +		 * This page was removed from radix-tree implicitly.
> > +		 */
> > +		page->mapping = NULL;
> > +		mem_cgroup_uncharge_cache_page(page);
> > +	} else
> > +		page->mapping = NULL;
> >  
> 
> page->mapping will be cleared anyway, so I prefer:
> 
> ===
> 	page->mapping = NULL;
> 
> 	if (!PageAnon(page))
> 		/*
> 		 * This page was removed from radix-tree implicitly.
> 		 */
> 		mem_cgroup_uncharge_cache_page(page);
> ===
> 
Ah.., PageAnon(page) check (page->mapping & 0x1) so, we cant do this.

Hmm, like this ?
==
anon = PageAnon(page);
page->mapping = NULL;
if (anon)
	mem_cgroup_....
==


> >  	/*
> >  	 * If any waiters have accumulated on the new page then
> > Index: mmtom-stamp-2008-07-15-15-39/mm/swap_state.c
> > ===================================================================
> > --- mmtom-stamp-2008-07-15-15-39.orig/mm/swap_state.c
> > +++ mmtom-stamp-2008-07-15-15-39/mm/swap_state.c
> > @@ -110,6 +110,7 @@ void __delete_from_swap_cache(struct pag
> >  	total_swapcache_pages--;
> >  	__dec_zone_page_state(page, NR_FILE_PAGES);
> >  	INC_CACHE_INFO(del_total);
> > +	mem_cgroup_uncharge_page(page);
> >  }
> >  
> >  /**
> 
> 
> 	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 

Thank you!.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
