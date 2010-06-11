Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 007916B0071
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 00:56:44 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5B4ucA2010157
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Jun 2010 13:56:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F039445DE55
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 13:56:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B8E2645DE53
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 13:56:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 38B541DB805B
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 13:56:37 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D00881DB805F
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 13:56:36 +0900 (JST)
Date: Fri, 11 Jun 2010 13:52:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg remove css_get/put per pages v2
Message-Id: <20100611135202.c0bc30c3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100611133744.e5f14e3d.nishimura@mxp.nes.nec.co.jp>
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<20100609155940.dd121130.kamezawa.hiroyu@jp.fujitsu.com>
	<20100611133744.e5f14e3d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jun 2010 13:37:44 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > @@ -2432,15 +2463,18 @@ mem_cgroup_uncharge_swapcache(struct pag
> >  	if (!swapout) /* this was a swap cache but the swap is unused ! */
> >  		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
> >  
> > -	memcg = __mem_cgroup_uncharge_common(page, ctype);
> > +	memcg = try_get_mem_cgroup_from_page(page);
> > +	if (!memcg)
> > +		return;
> > +
> > +	__mem_cgroup_uncharge_common(page, ctype);
> >  
> >  	/* record memcg information */
> > -	if (do_swap_account && swapout && memcg) {
> > +	if (do_swap_account && swapout) {
> >  		swap_cgroup_record(ent, css_id(&memcg->css));
> >  		mem_cgroup_get(memcg);
> >  	}
> > -	if (swapout && memcg)
> > -		css_put(&memcg->css);
> > +	css_put(&memcg->css);
> >  }
> >  #endif
> >  
> hmm, this change seems to cause a problem.
> I can see under flow of mem->memsw and "swap" field in memory.stat. 
> 
> I think doing swap_cgroup_record() against mem_cgroup which is not returned
> by __mem_cgroup_uncharge_common() is a bad behavior.
> 
> How about doing like this ? We can safely access mem_cgroup while it has
> memory.usage, iow, before we call res_counter_uncharge().
> After this change, it seems to work well.
> 

Thank you!. seems to work. I'll merge your change.
Can I add your Signed-off-by ?

Thanks,
-Kame

> ---
>  mm/memcontrol.c |   22 +++++++++-------------
>  1 files changed, 9 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6e7c1c9..2fae26f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2362,10 +2362,6 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  		break;
>  	}
>  
> -	if (!mem_cgroup_is_root(mem))
> -		__do_uncharge(mem, ctype);
> -	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> -		mem_cgroup_swap_statistics(mem, true);
>  	mem_cgroup_charge_statistics(mem, pc, false);
>  
>  	ClearPageCgroupUsed(pc);
> @@ -2379,6 +2375,12 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	unlock_page_cgroup(pc);
>  
>  	memcg_check_events(mem, page);
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
> +		mem_cgroup_swap_statistics(mem, true);
> +		mem_cgroup_get(mem);
> +	}
> +	if (!mem_cgroup_is_root(mem))
> +		__do_uncharge(mem, ctype);
>  
>  	return mem;
>  
> @@ -2463,18 +2465,12 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>  	if (!swapout) /* this was a swap cache but the swap is unused ! */
>  		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
>  
> -	memcg = try_get_mem_cgroup_from_page(page);
> -	if (!memcg)
> -		return;
> -
> -	__mem_cgroup_uncharge_common(page, ctype);
> +	memcg = __mem_cgroup_uncharge_common(page, ctype);
>  
>  	/* record memcg information */
> -	if (do_swap_account && swapout) {
> +	if (do_swap_account && swapout && memcg)
> +		/* We've already done mem_cgroup_get() in uncharge_common(). */
>  		swap_cgroup_record(ent, css_id(&memcg->css));
> -		mem_cgroup_get(memcg);
> -	}
> -	css_put(&memcg->css);
>  }
>  #endif
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
