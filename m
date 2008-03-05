Date: Wed, 5 Mar 2008 16:03:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC/PATCH] cgroup swap subsystem
Message-Id: <20080305160327.d7dc4bdf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47CE36A9.3060204@mxp.nes.nec.co.jp>
References: <47CE36A9.3060204@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: containers@lists.osdl.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Wed, 05 Mar 2008 14:59:05 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> +int swap_cgroup_charge(struct page *page,
> +			struct swap_info_struct *si,
> +			unsigned long offset)
> +{
> +	int ret;
> +	struct page_cgroup *pc;
> +	struct mm_struct *mm;
> +	struct swap_cgroup *swap;
> +
> +	BUG_ON(!page);
> +
> +	/*
> +	 * Pages to be swapped out should have been charged by memory cgroup,
> +	 * but very rarely, pc would be NULL (pc is not reliable without lock,
> +	 * so I should fix here).
> +	 * In such cases, we charge the init_mm now.
> +	 */
> +	pc = page_get_page_cgroup(page);
> +	if (WARN_ON(!pc))
> +		mm = &init_mm;
> +	else
> +		mm = pc->pc_mm;
> +	BUG_ON(!mm);
> +
> +	rcu_read_lock();
> +	swap = rcu_dereference(mm->swap_cgroup);
> +	rcu_read_unlock();
> +	BUG_ON(!swap);
> +
> +	ret = res_counter_charge(&swap->res, PAGE_SIZE);
> +	if (!ret) {
> +		css_get(&swap->css);
> +		si->swap_cgroup[offset] = swap;
> +	}
> +
I think it's better to reclaim swap_entry used for SwapCache but not in Harddisk
before failure.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
