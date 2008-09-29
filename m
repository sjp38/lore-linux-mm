Date: Mon, 29 Sep 2008 20:39:12 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/4] memcg: set page->mapping NULL before uncharge
Message-Id: <20080929203912.41327fd0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080929192240.ddd59d7f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com>
	<20080929192240.ddd59d7f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Sep 2008 19:22:40 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This patch tries to make page->mapping to be NULL before
> mem_cgroup_uncharge_cache_page() is called.
> 
> "page->mapping == NULL" is a good check for "whether the page is still
> radix-tree or not".
> This patch also adds BUG_ON() to mem_cgroup_uncharge_cache_page();
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
Looks good to me.

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

>  mm/filemap.c    |    2 +-
>  mm/memcontrol.c |    1 +
>  mm/migrate.c    |    9 +++++++--
>  3 files changed, 9 insertions(+), 3 deletions(-)
> 
> Index: mmotm-2.6.27-rc7+/mm/filemap.c
> ===================================================================
> --- mmotm-2.6.27-rc7+.orig/mm/filemap.c
> +++ mmotm-2.6.27-rc7+/mm/filemap.c
> @@ -116,12 +116,12 @@ void __remove_from_page_cache(struct pag
>  {
>  	struct address_space *mapping = page->mapping;
>  
> -	mem_cgroup_uncharge_cache_page(page);
>  	radix_tree_delete(&mapping->page_tree, page->index);
>  	page->mapping = NULL;
>  	mapping->nrpages--;
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
>  	BUG_ON(page_mapped(page));
> +	mem_cgroup_uncharge_cache_page(page);
>  
>  	/*
>  	 * Some filesystems seem to re-dirty the page even after
> Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
> +++ mmotm-2.6.27-rc7+/mm/memcontrol.c
> @@ -734,6 +734,7 @@ void mem_cgroup_uncharge_page(struct pag
>  void mem_cgroup_uncharge_cache_page(struct page *page)
>  {
>  	VM_BUG_ON(page_mapped(page));
> +	VM_BUG_ON(page->mapping);
>  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
>  }
>  
> Index: mmotm-2.6.27-rc7+/mm/migrate.c
> ===================================================================
> --- mmotm-2.6.27-rc7+.orig/mm/migrate.c
> +++ mmotm-2.6.27-rc7+/mm/migrate.c
> @@ -330,8 +330,6 @@ static int migrate_page_move_mapping(str
>  	__inc_zone_page_state(newpage, NR_FILE_PAGES);
>  
>  	spin_unlock_irq(&mapping->tree_lock);
> -	if (!PageSwapCache(newpage))
> -		mem_cgroup_uncharge_cache_page(page);
>  
>  	return 0;
>  }
> @@ -341,6 +339,8 @@ static int migrate_page_move_mapping(str
>   */
>  static void migrate_page_copy(struct page *newpage, struct page *page)
>  {
> +	int anon;
> +
>  	copy_highpage(newpage, page);
>  
>  	if (PageError(page))
> @@ -378,8 +378,13 @@ static void migrate_page_copy(struct pag
>  #endif
>  	ClearPagePrivate(page);
>  	set_page_private(page, 0);
> +	/* page->mapping contains a flag for PageAnon() */
> +	anon = PageAnon(page);
>  	page->mapping = NULL;
>  
> +	if (!anon) /* This page was removed from radix-tree. */
> +		mem_cgroup_uncharge_cache_page(page);
> +
>  	/*
>  	 * If any waiters have accumulated on the new page then
>  	 * wake them up.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
