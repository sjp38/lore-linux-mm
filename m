Date: Tue, 9 Sep 2008 16:56:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/14]  memcg: lockless page cgroup
Message-Id: <20080909165608.878d7182.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080909144007.48e6633a.nishimura@mxp.nes.nec.co.jp>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203551.598a263c.kamezawa.hiroyu@jp.fujitsu.com>
	<20080909144007.48e6633a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Sep 2008 14:40:07 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > +	/* Double counting race condition ? */
> > +	VM_BUG_ON(page_get_page_cgroup(page));
> > +
> >  	page_assign_page_cgroup(page, pc);
> >  
> >  	mz = page_cgroup_zoneinfo(pc);
> 
> I got this VM_BUG_ON at swapoff.
> 
> Trying to shmem_unuse_inode a page which has been moved
> to swapcache by shmem_writepage causes this BUG, because
> the page has not been uncharged(with all the patches applied).
> 
> I made a patch which changes shmem_unuse_inode to charge with
> GFP_NOWAIT first and shrink usage on failure, as shmem_getpage does.
> 
> But I don't stick to my patch if you handle this case :)
> 
Thank you for testing and sorry for no progress in these days.

I'm sorry to say that I'll have to postpone this to remove
page->page_cgroup pointer. I need some more performance-improvement
effort to remove page->page_cgroup pointer without significant overhead.

So please be patient for a while.


Sorry,
-Kame


> 
> Thanks,
> Daisuke Nishimura.
> 
> ====
> Change shmem_unuse_inode to charge with GFP_NOWAIT first and
> shrink usage on failure, as shmem_getpage does.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> ---
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 72b5f03..d37cd51 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -922,15 +922,10 @@ found:
>  	error = 1;
>  	if (!inode)
>  		goto out;
> -	/* Precharge page using GFP_KERNEL while we can wait */
> -	error = mem_cgroup_cache_charge(page, current->mm, GFP_KERNEL);
> -	if (error)
> -		goto out;
> +retry:
>  	error = radix_tree_preload(GFP_KERNEL);
> -	if (error) {
> -		mem_cgroup_uncharge_cache_page(page);
> +	if (error)
>  		goto out;
> -	}
>  	error = 1;
>  
>  	spin_lock(&info->lock);
> @@ -938,9 +933,17 @@ found:
>  	if (ptr && ptr->val == entry.val) {
>  		error = add_to_page_cache_locked(page, inode->i_mapping,
>  						idx, GFP_NOWAIT);
> -		/* does mem_cgroup_uncharge_cache_page on error */
> -	} else	/* we must compensate for our precharge above */
> -		mem_cgroup_uncharge_cache_page(page);
> +		if (error == -ENOMEM) {
> +			if (ptr)
> +				shmem_swp_unmap(ptr);
> +			spin_unlock(&info->lock);
> +			radix_tree_preload_end();
> +			error = mem_cgroup_shrink_usage(current->mm, GFP_KERNEL);
> +			if (error)
> +				goto out;
> +			goto retry;
> +		}
> +	}
>  
>  	if (error == -EEXIST) {
>  		struct page *filepage = find_get_page(inode->i_mapping, idx);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
