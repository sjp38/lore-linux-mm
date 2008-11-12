Date: Wed, 12 Nov 2008 13:17:01 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH 4/6] memcg: swap cgroup for remembering account
Message-Id: <20081112131701.dbb7d003.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20081112122949.d17bbc7f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112122949.d17bbc7f.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

> +/**
> + * lookup_swap_cgroup - lookup mem_cgroup tied to swap entry
> + * @ent: swap entry to be looked up.
> + *
> + * Returns pointer to mem_cgroup at success. NULL at failure.
> + */
> +struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
> +{
> +	int type = swp_type(ent);
> +	unsigned long flags;
> +	unsigned long offset = swp_offset(ent);
> +	unsigned long idx = offset / SC_PER_PAGE;
> +	unsigned long pos = offset & SC_POS_MASK;
> +	struct swap_cgroup_ctrl *ctrl;
> +	struct page *mappage;
> +	struct swap_cgroup *sc;
> +	struct mem_cgroup *ret;
> +
> +	if (!do_swap_account)
> +		return NULL;
> +
> +	ctrl = &swap_cgroup_ctrl[type];
> +
> +	mappage = ctrl->map[idx];
> +
> +	spin_lock_irqsave(&ctrl->lock, flags);
> +	sc = kmap_atomic(mappage, KM_USER0);
> +	sc += pos;
> +	ret = sc->val;
> +	kunmap_atomic(mapppage, KM_USER0);
s/mapppage/mappage

I don't know why I didn't notice this while testing previous version.


Thanks,
Daisuke Nishimura.

> +	spin_unlock_irqrestore(&ctrl->lock, flags);
> +	return ret;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
