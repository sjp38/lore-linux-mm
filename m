Date: Wed, 15 Oct 2008 17:16:55 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/5] memcg: migration account fix
Message-Id: <20081015171655.1e19ebeb.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081010180335.c9cf53c4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081010175936.f3b1f4e0.kamezawa.hiroyu@jp.fujitsu.com>
	<20081010180335.c9cf53c4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> @@ -795,43 +767,67 @@ int mem_cgroup_prepare_migration(struct 
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		css_get(&mem->css);
> -		if (PageCgroupCache(pc)) {
> -			if (page_is_file_cache(page))
> -				ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> -			else
> -				ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> -		}
>  	}
>  	unlock_page_cgroup(pc);
> +
>  	if (mem) {
> -		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
> -			ctype, mem);
> +		ret = mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem);
>  		css_put(&mem->css);
> +		*ptr = mem;
>  	}
>  	return ret;
>  }
>  
"*ptr = mem" should be outside of if(mem).
Otherwise, ptr would be kept unset when !PageCgroupUsed.
(unmap_and_move, caller of prepare_migration, doesn't initilize it.)

And,

>  /* remove redundant charge if migration failed*/
> -void mem_cgroup_end_migration(struct page *newpage)
> +void mem_cgroup_end_migration(struct mem_cgroup *mem,
> +		struct page *oldpage, struct page *newpage)
>  {
> +	struct page *target, *unused;
> +	struct page_cgroup *pc;
> +	enum charge_type ctype;
> +
mem_cgroup_end_migration should handle "mem == NULL" case
(just return would be enough).

> +	/* at migration success, oldpage->mapping is NULL. */
> +	if (oldpage->mapping) {
> +		target = oldpage;
> +		unused = NULL;
> +	} else {
> +		target = newpage;
> +		unused = oldpage;
> +	}
> +
> +	if (PageAnon(target))
> +		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> +	else if (page_is_file_cache(target))
> +		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> +	else
> +		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> +
> +	/* unused page is not on radix-tree now. */
> +	if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)
> +		__mem_cgroup_uncharge_common(unused, ctype);
> +
> +	pc = lookup_page_cgroup(target);
>  	/*
> -	 * At success, page->mapping is not NULL.
> -	 * special rollback care is necessary when
> -	 * 1. at migration failure. (newpage->mapping is cleared in this case)
> -	 * 2. the newpage was moved but not remapped again because the task
> -	 *    exits and the newpage is obsolete. In this case, the new page
> -	 *    may be a swapcache. So, we just call mem_cgroup_uncharge_page()
> -	 *    always for avoiding mess. The  page_cgroup will be removed if
> -	 *    unnecessary. File cache pages is still on radix-tree. Don't
> -	 *    care it.
> +	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
> +	 * So, double-counting is effectively avoided.
>  	 */
> -	if (!newpage->mapping)
> -		__mem_cgroup_uncharge_common(newpage,
> -				MEM_CGROUP_CHARGE_TYPE_FORCE);
> -	else if (PageAnon(newpage))
> -		mem_cgroup_uncharge_page(newpage);
> +	__mem_cgroup_commit_charge(mem, pc, ctype);
> +
> +	/*
> +	 * Both of oldpage and newpage are still under lock_page().
> +	 * Then, we don't have to care about race in radix-tree.
> +	 * But we have to be careful that this page is unmapped or not.
> +	 *
> +	 * There is a case for !page_mapped(). At the start of
> +	 * migration, oldpage was mapped. But now, it's zapped.
> +	 * But we know *target* page is not freed/reused under us.
> +	 * mem_cgroup_uncharge_page() does all necessary checks.
> +	 */
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> +		mem_cgroup_uncharge_page(target);
>  }
>  
> +
>  /*
>   * A call to try to shrink memory usage under specified resource controller.
>   * This is typically used for page reclaiming for shmem for reducing side
> 

BTW, I'm now testing v7 patches with some fixes I've reported,
and it has worked well so far(for several hours) in my test.
(testing page migration and rmdir(force_empty) under swap in/out activity)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
