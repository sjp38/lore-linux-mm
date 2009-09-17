Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9220F6B005A
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 00:14:27 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H4ERGk019618
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 13:14:27 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA15145DE4E
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 13:14:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B4A2345DE4D
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 13:14:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A524E08002
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 13:14:26 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 516371DB8038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 13:14:26 +0900 (JST)
Date: Thu, 17 Sep 2009 13:12:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/8] memcg: introduce mem_cgroup_cancel_charge()
Message-Id: <20090917131206.86213fa7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090917112400.2d90c60d.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917112400.2d90c60d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 11:24:00 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> There are some places calling both res_counter_uncharge() and css_put()
> to cancel the charge and the refcnt we have got by mem_cgroup_tyr_charge().
> 
> This patch introduces mem_cgroup_cancel_charge() and call it in those places.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/memcontrol.c |   35 ++++++++++++++---------------------
>  1 files changed, 14 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e2b98a6..00f3f97 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1370,6 +1370,17 @@ nomem:
>  	return -ENOMEM;
>  }
>  
> +/* A helper function to cancel the charge and refcnt by try_charge */
> +static inline void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
> +{
> +	if (!mem_cgroup_is_root(mem)) {
> +		res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
> +		if (do_swap_account)
> +			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> +	}
> +	css_put(&mem->css);
> +}
> +
>  /*
>   * A helper function to get mem_cgroup from ID. must be called under
>   * rcu_read_lock(). The caller must check css_is_removed() or some if
> @@ -1436,13 +1447,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  	lock_page_cgroup(pc);
>  	if (unlikely(PageCgroupUsed(pc))) {
>  		unlock_page_cgroup(pc);
> -		if (!mem_cgroup_is_root(mem)) {
> -			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
> -			if (do_swap_account)
> -				res_counter_uncharge(&mem->memsw, PAGE_SIZE,
> -							NULL);
> -		}
> -		css_put(&mem->css);
> +		mem_cgroup_cancel_charge(mem);
>  		return;
>  	}
>  
> @@ -1606,14 +1611,7 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
>  cancel:
>  	put_page(page);
>  uncharge:
> -	/* drop extra refcnt by try_charge() */
> -	css_put(&parent->css);
> -	/* uncharge if move fails */
> -	if (!mem_cgroup_is_root(parent)) {
> -		res_counter_uncharge(&parent->res, PAGE_SIZE, NULL);
> -		if (do_swap_account)
> -			res_counter_uncharge(&parent->memsw, PAGE_SIZE, NULL);
> -	}
> +	mem_cgroup_cancel_charge(parent);
>  	return ret;
>  }
>  
> @@ -1830,12 +1828,7 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
>  		return;
>  	if (!mem)
>  		return;
> -	if (!mem_cgroup_is_root(mem)) {
> -		res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
> -		if (do_swap_account)
> -			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> -	}
> -	css_put(&mem->css);
> +	mem_cgroup_cancel_charge(mem);
>  }
>  
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
