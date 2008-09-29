Date: Mon, 29 Sep 2008 20:19:06 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 3/4] memcg: avoid account not-on-LRU pages
Message-Id: <20080929201906.896b9f3d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080929192339.327ca142.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com>
	<20080929192339.327ca142.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Sep 2008 19:23:39 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> There are not-on-LRU pages which can be mapped and they are not worth to
> be accounted. (becasue we can't shrink them and need dirty codes to handle
> specical case) We'd like to make use of usual objrmap/radix-tree's protcol
> and don't want to account out-of-vm's control pages.
> 
> When special_mapping_fault() is called, page->mapping is tend to be NULL 
> and it's charged as Anonymous page.
> insert_page() also handles some special pages from drivers.
> 
> This patch is for avoiding to account special pages.
> 
> Changlog: v5 -> v6
>   - modified Documentation.
>   - fixed to charge only when a page is newly allocated.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  Documentation/controllers/memory.txt |   24 ++++++++++++++++--------
>  mm/memory.c                          |   29 +++++++++++++----------------
>  mm/rmap.c                            |    4 ++--
>  3 files changed, 31 insertions(+), 26 deletions(-)
> 
> Index: mmotm-2.6.27-rc7+/mm/memory.c
> ===================================================================
> --- mmotm-2.6.27-rc7+.orig/mm/memory.c
> +++ mmotm-2.6.27-rc7+/mm/memory.c
> @@ -1323,18 +1323,14 @@ static int insert_page(struct vm_area_st
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  
> -	retval = mem_cgroup_charge(page, mm, GFP_KERNEL);
> -	if (retval)
> -		goto out;
> -
>  	retval = -EINVAL;
>  	if (PageAnon(page))
> -		goto out_uncharge;
> +		goto out;
>  	retval = -ENOMEM;
>  	flush_dcache_page(page);
>  	pte = get_locked_pte(mm, addr, &ptl);
>  	if (!pte)
> -		goto out_uncharge;
> +		goto out;
>  	retval = -EBUSY;
>  	if (!pte_none(*pte))
>  		goto out_unlock;
> @@ -1350,8 +1346,6 @@ static int insert_page(struct vm_area_st
>  	return retval;
>  out_unlock:
>  	pte_unmap_unlock(pte, ptl);
> -out_uncharge:
> -	mem_cgroup_uncharge_page(page);
>  out:
>  	return retval;
>  }
> @@ -2463,6 +2457,7 @@ static int __do_fault(struct mm_struct *
>  	struct page *page;
>  	pte_t entry;
>  	int anon = 0;
> +	int charged = 0;
>  	struct page *dirty_page = NULL;
>  	struct vm_fault vmf;
>  	int ret;
> @@ -2503,6 +2498,12 @@ static int __do_fault(struct mm_struct *
>  				ret = VM_FAULT_OOM;
>  				goto out;
>  			}
> +			if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
> +				ret = VM_FAULT_OOM;
> +				page_cache_release(page);
> +				goto out;
> +			}
> +			charged = 1;
>  			/*
>  			 * Don't let another task, with possibly unlocked vma,
>  			 * keep the mlocked page.
> @@ -2543,11 +2544,6 @@ static int __do_fault(struct mm_struct *
>  
>  	}
>  
> -	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
> -		ret = VM_FAULT_OOM;
> -		goto out;
> -	}
> -
>  	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
>  
>  	/*
> @@ -2585,10 +2581,11 @@ static int __do_fault(struct mm_struct *
>  		/* no need to invalidate: a not-present page won't be cached */
>  		update_mmu_cache(vma, address, entry);
>  	} else {
> -		mem_cgroup_uncharge_page(page);
> -		if (anon)
> +		if (charged)
> +			mem_cgroup_uncharge_page(page);
> +		if (anon) {
>  			page_cache_release(page);
> -		else
> +		} else
>  			anon = 1; /* no anon but release faulted_page */
>  	}
>

checkpatch reports a warning here.

I think it should be like

@@ -2585,7 +2581,8 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		/* no need to invalidate: a not-present page won't be cached */
 		update_mmu_cache(vma, address, entry);
 	} else {
-		mem_cgroup_uncharge_page(page);
+		if (charged)
+			mem_cgroup_uncharge_page(page);
 		if (anon)
 			page_cache_release(page);
 		else


Thanks,
Daisuke Nishimura.

> Index: mmotm-2.6.27-rc7+/mm/rmap.c
> ===================================================================
> --- mmotm-2.6.27-rc7+.orig/mm/rmap.c
> +++ mmotm-2.6.27-rc7+/mm/rmap.c
> @@ -725,8 +725,8 @@ void page_remove_rmap(struct page *page,
>  			page_clear_dirty(page);
>  			set_page_dirty(page);
>  		}
> -
> -		mem_cgroup_uncharge_page(page);
> +		if (PageAnon(page))
> +			mem_cgroup_uncharge_page(page);
>  		__dec_zone_page_state(page,
>  			PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
>  		/*
> Index: mmotm-2.6.27-rc7+/Documentation/controllers/memory.txt
> ===================================================================
> --- mmotm-2.6.27-rc7+.orig/Documentation/controllers/memory.txt
> +++ mmotm-2.6.27-rc7+/Documentation/controllers/memory.txt
> @@ -112,14 +112,22 @@ the per cgroup LRU.
>  
>  2.2.1 Accounting details
>  
> -All mapped pages (RSS) and unmapped user pages (Page Cache) are accounted.
> -RSS pages are accounted at the time of page_add_*_rmap() unless they've already
> -been accounted for earlier. A file page will be accounted for as Page Cache;
> -it's mapped into the page tables of a process, duplicate accounting is carefully
> -avoided. Page Cache pages are accounted at the time of add_to_page_cache().
> -The corresponding routines that remove a page from the page tables or removes
> -a page from Page Cache is used to decrement the accounting counters of the
> -cgroup.
> +All mapped anon pages (RSS) and cache pages (Page Cache) are accounted.
> +(some pages which never be reclaimable and will not be on global LRU
> + are not accounted. we just accounts pages under usual vm management.)
> +
> +RSS pages are accounted at page_fault unless they've already been accounted
> +for earlier. A file page will be accounted for as Page Cache when it's
> +inserted into inode (radix-tree). While it's mapped into the page tables of
> +processes, duplicate accounting is carefully avoided.
> +
> +A RSS page is unaccounted when it's fully unmapped. A PageCache page is
> +unaccounted when it's removed from radix-tree.
> +
> +At page migration, accounting information is kept.
> +
> +Note: we just account pages-on-lru because our purpose is to control amount
> +of used pages. not-on-lru pages are tend to be out-of-control from vm view.
>  
>  2.3 Shared Page Accounting
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
