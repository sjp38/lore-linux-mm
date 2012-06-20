Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C0B1D6B006C
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 09:28:06 -0400 (EDT)
Date: Wed, 20 Jun 2012 15:28:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 06/25] memcg: Make it possible to use the stock for
 more than one page.
Message-ID: <20120620132804.GF5541@tiehlicka.suse.cz>
References: <1340015298-14133-1-git-send-email-glommer@parallels.com>
 <1340015298-14133-7-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340015298-14133-7-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>

On Mon 18-06-12 14:27:59, Glauber Costa wrote:
> From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
> 
> Signed-off-by: Suleiman Souhlal <suleiman@google.com>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I am not sure the patch is good to merge on its own without the rest.
One comment bellow.

> ---
>  mm/memcontrol.c |   18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ce15be4..00b9f1e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1998,19 +1998,19 @@ static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
>  static DEFINE_MUTEX(percpu_charge_mutex);
>  
>  /*
> - * Try to consume stocked charge on this cpu. If success, one page is consumed
> - * from local stock and true is returned. If the stock is 0 or charges from a
> - * cgroup which is not current target, returns false. This stock will be
> - * refilled.
> + * Try to consume stocked charge on this cpu. If success, nr_pages pages are
> + * consumed from local stock and true is returned. If the stock is 0 or
> + * charges from a cgroup which is not current target, returns false.
> + * This stock will be refilled.
>   */
> -static bool consume_stock(struct mem_cgroup *memcg)
> +static bool consume_stock(struct mem_cgroup *memcg, int nr_pages)
>  {
>  	struct memcg_stock_pcp *stock;
>  	bool ret = true;

I guess you want:
	if (nr_pages > CHARGE_BATCH)
		return false;

because you don't want to try to use stock for THP pages.

>  
>  	stock = &get_cpu_var(memcg_stock);
> -	if (memcg == stock->cached && stock->nr_pages)
> -		stock->nr_pages--;
> +	if (memcg == stock->cached && stock->nr_pages >= nr_pages)
> +		stock->nr_pages -= nr_pages;
>  	else /* need to call res_counter_charge */
>  		ret = false;
>  	put_cpu_var(memcg_stock);
> @@ -2309,7 +2309,7 @@ again:
>  		VM_BUG_ON(css_is_removed(&memcg->css));
>  		if (mem_cgroup_is_root(memcg))
>  			goto done;
> -		if (nr_pages == 1 && consume_stock(memcg))
> +		if (consume_stock(memcg, nr_pages))
>  			goto done;
>  		css_get(&memcg->css);
>  	} else {
> @@ -2334,7 +2334,7 @@ again:
>  			rcu_read_unlock();
>  			goto done;
>  		}
> -		if (nr_pages == 1 && consume_stock(memcg)) {
> +		if (consume_stock(memcg, nr_pages)) {
>  			/*
>  			 * It seems dagerous to access memcg without css_get().
>  			 * But considering how consume_stok works, it's not
> -- 
> 1.7.10.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
