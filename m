Subject: Re: [PATCH -mm 5/5] swapcgroup (v3): implement force_empty
In-Reply-To: Your message of "Fri, 4 Jul 2008 15:24:23 +0900"
	<20080704152423.f65932b3.nishimura@mxp.nes.nec.co.jp>
References: <20080704152423.f65932b3.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080704065431.A8BDC5A19@siro.lan>
Date: Fri,  4 Jul 2008 15:54:31 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: containers@lists.osdl.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, hugh@veritas.com, m-ikeda@ds.jp.nec.com
List-ID: <linux-mm.kvack.org>

hi,

> +/*
> + * uncharge all the entries that are charged to the group.
> + */
> +void __swap_cgroup_force_empty(struct mem_cgroup *mem)
> +{
> +	struct swap_info_struct *p;
> +	int type;
> +
> +	spin_lock(&swap_lock);
> +	for (type = swap_list.head; type >= 0; type = swap_info[type].next) {
> +		p = swap_info + type;
> +
> +		if ((p->flags & SWP_ACTIVE) == SWP_ACTIVE) {
> +			unsigned int i = 0;
> +
> +			spin_unlock(&swap_lock);

what prevents the device from being swapoff'ed while you drop swap_lock?

YAMAMOTO Takashi

> +			while ((i = find_next_to_unuse(p, i, mem)) != 0) {
> +				spin_lock(&swap_lock);
> +				if (p->swap_map[i] && p->memcg[i] == mem)
> +					swap_cgroup_uncharge(p, i);
> +				spin_unlock(&swap_lock);
> +			}
> +			spin_lock(&swap_lock);
> +		}
> +	}
> +	spin_unlock(&swap_lock);
> +
> +	return;
> +}
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
