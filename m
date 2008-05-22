Subject: Re: [PATCH 4/4] swapcgroup: modify vm_swap_full for cgroup
In-Reply-To: Your message of "Thu, 22 May 2008 15:22:24 +0900"
	<48351120.6000800@mxp.nes.nec.co.jp>
References: <48351120.6000800@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080522064507.AB6A35A0A@siro.lan>
Date: Thu, 22 May 2008 15:45:07 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: containers@lists.osdl.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, riel@redhat.com, balbir@linux.vnet.ibm.com, kosaki.motohiro@jp.fujitsu.com, hugh@veritas.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> @@ -1892,3 +1892,36 @@ int valid_swaphandles(swp_entry_t entry, unsigned long *offset)
>  	*offset = ++toff;
>  	return nr_pages? ++nr_pages: 0;
>  }
> +
> +#ifdef CONFIG_CGROUP_SWAP_RES_CTLR
> +int swap_cgroup_vm_swap_full(struct page *page)
> +{
> +	int ret;
> +	struct swap_info_struct *p;
> +	struct mem_cgroup *mem;
> +	u64 usage;
> +	u64 limit;
> +	swp_entry_t entry;
> +
> +	VM_BUG_ON(!PageLocked(page));
> +	VM_BUG_ON(!PageSwapCache(page));
> +
> +	ret = 0;
> +	entry.val = page_private(page);
> +	p = swap_info_get(entry);
> +	if (!p)
> +		goto out;
> +
> +	mem = p->memcg[swp_offset(entry)];
> +	usage = swap_cgroup_read_usage(mem) / PAGE_SIZE;
> +	limit = swap_cgroup_read_limit(mem) / PAGE_SIZE;
> +	limit = (limit < total_swap_pages) ? limit : total_swap_pages;
> +
> +	ret = usage * 2 > limit;
> +
> +	spin_unlock(&swap_lock);
> +
> +out:
> +	return ret;
> +}
> +#endif

shouldn't it check the global usage (nr_swap_pages) as well?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
