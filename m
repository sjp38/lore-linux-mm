Date: Fri, 18 Jul 2008 17:26:54 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [mmtom] please drop memcg-handle-swap-cache set (memcg handle
 swap cache rework).
Message-Id: <20080718172654.109018db.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080718152232.31d36e0b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080717124556.3e4b6e20.kamezawa.hiroyu@jp.fujitsu.com>
	<20080718141511.a28d1ba1.nishimura@mxp.nes.nec.co.jp>
	<20080718152232.31d36e0b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> > > @@ -398,12 +395,27 @@ static void migrate_page_copy(struct pag
> > >   	}
> > >  
> > >  #ifdef CONFIG_SWAP
> > > -	ClearPageSwapCache(page);
> > > +	if (PageSwapCache(page)) {
> > > +		/*
> > > +		 * SwapCache is removed implicitly. To uncharge SwapCache,
> > > +		 * SwapCache flag should be cleared.
> > > +		 */
> > > +		ClearPageSwapCache(page);
> > > +		mem_cgroup_uncharge_page(page);
> > > +	}
> > >  #endif
> > >  	ClearPageActive(page);
> > >  	ClearPagePrivate(page);
> > >  	set_page_private(page, 0);
> > > -	page->mapping = NULL;
> > > +
> > > +	if (!PageAnon(page)) {
> > > +		/*
> > > +		 * This page was removed from radix-tree implicitly.
> > > +		 */
> > > +		page->mapping = NULL;
> > > +		mem_cgroup_uncharge_cache_page(page);
> > > +	} else
> > > +		page->mapping = NULL;
> > >  
> > 
> > page->mapping will be cleared anyway, so I prefer:
> > 
> > ===
> > 	page->mapping = NULL;
> > 
> > 	if (!PageAnon(page))
> > 		/*
> > 		 * This page was removed from radix-tree implicitly.
> > 		 */
> > 		mem_cgroup_uncharge_cache_page(page);
> > ===
> > 
> Ah.., PageAnon(page) check (page->mapping & 0x1) so, we cant do this.
> 
Ooops! Sorry for saying stupid thing.

> Hmm, like this ?
> ==
> anon = PageAnon(page);
> page->mapping = NULL;
> if (anon)
> 	mem_cgroup_....
> ==
> 
Looks good.
But I don't have any objection to your original code.
I just thought 2 lines of "page->mapping = NULL" was verbose.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
