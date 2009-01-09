Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8556E6B0044
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 00:16:46 -0500 (EST)
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n095FPTf005490
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 16:15:25 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n095FM6k090594
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 16:15:23 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n095FMVS029378
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 16:15:22 +1100
Date: Fri, 9 Jan 2009 10:45:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/4] memcg: fix error path of
	mem_cgroup_move_parent
Message-ID: <20090109051522.GC9737@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp> <20090108191445.cd860c37.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090108191445.cd860c37.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-08 19:14:45]:

> There is a bug in error path of mem_cgroup_move_parent.
> 
> Extra refcnt got from try_charge should be dropped, and usages incremented
> by try_charge should be decremented in both error paths:
> 
>     A: failure at get_page_unless_zero
>     B: failure at isolate_lru_page
> 
> This bug makes this parent directory unremovable.
> 
> In case of A, rmdir doesn't return, because res.usage doesn't go
> down to 0 at mem_cgroup_force_empty even after all the pc in
> lru are removed.
> In case of B, rmdir fails and returns -EBUSY, because it has
> extra ref counts even after res.usage goes down to 0.
> 
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   23 +++++++++++++++--------
>  1 files changed, 15 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 62e69d8..288e22c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -983,14 +983,15 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
>  	if (pc->mem_cgroup != from)
>  		goto out;
> 
> -	css_put(&from->css);
>  	res_counter_uncharge(&from->res, PAGE_SIZE);
>  	mem_cgroup_charge_statistics(from, pc, false);
>  	if (do_swap_account)
>  		res_counter_uncharge(&from->memsw, PAGE_SIZE);
> +	css_put(&from->css);
> +
> +	css_get(&to->css);
>  	pc->mem_cgroup = to;
>  	mem_cgroup_charge_statistics(to, pc, true);
> -	css_get(&to->css);
>  	ret = 0;
>  out:
>  	unlock_page_cgroup(pc);
> @@ -1023,8 +1024,10 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
>  	if (ret || !parent)
>  		return ret;
> 
> -	if (!get_page_unless_zero(page))
> -		return -EBUSY;
> +	if (!get_page_unless_zero(page)) {
> +		ret = -EBUSY;
> +		goto uncharge;
> +	}
> 
>  	ret = isolate_lru_page(page);
> 
> @@ -1033,19 +1036,23 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
> 
>  	ret = mem_cgroup_move_account(pc, child, parent);
> 
> -	/* drop extra refcnt by try_charge() (move_account increment one) */
> -	css_put(&parent->css);
>  	putback_lru_page(page);
>  	if (!ret) {
>  		put_page(page);
> +		/* drop extra refcnt by try_charge() */
> +		css_put(&parent->css);
>  		return 0;
>  	}
> -	/* uncharge if move fails */
> +
>  cancel:
> +	put_page(page);
> +uncharge:
> +	/* drop extra refcnt by try_charge() */
> +	css_put(&parent->css);
> +	/* uncharge if move fails */
>  	res_counter_uncharge(&parent->res, PAGE_SIZE);
>  	if (do_swap_account)
>  		res_counter_uncharge(&parent->memsw, PAGE_SIZE);
> -	put_page(page);
>  	return ret;
>  }
> 
>

Looks good to me, just out of curiousity how did you catch this error?
Through review or testing? 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
