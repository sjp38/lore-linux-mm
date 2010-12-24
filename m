Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 65A206B0088
	for <linux-mm@kvack.org>; Fri, 24 Dec 2010 03:37:50 -0500 (EST)
Date: Fri, 24 Dec 2010 09:37:39 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH] memcg: add valid check at allocating or freeing
 memory
Message-ID: <20101224083739.GF2048@cmpxchg.org>
References: <20101224093131.274c8728.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101224093131.274c8728.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 24, 2010 at 09:31:31AM +0900, Daisuke Nishimura wrote:
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> This patch add checks at allocating or freeing a page whether the page is used
> (iow, charged) from the view point of memcg.
> This check may be usefull in debugging a problem and we did a similar checks
> before the commit 52d4b9ac(memcg: allocate all page_cgroup at boot).
> 
> This patch adds some overheads at allocating or freeing memory, so it's enabled
> only when CONFIG_DEBUG_VM is enabled.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2971,6 +2971,53 @@ int mem_cgroup_shmem_charge_fallback(struct page *page,
>  	return ret;
>  }
>  
> +#ifdef CONFIG_DEBUG_VM
> +static bool
> +__mem_cgroup_bad_page_check(struct page *page, struct page_cgroup **pcp)
> +{
> +	struct page_cgroup *pc;
> +	bool ret = false;
> +
> +	pc = lookup_page_cgroup(page);
> +	if (unlikely(!pc))
> +		goto out;
> +
> +	if (PageCgroupUsed(pc)) {
> +		ret = true;
> +		if (pcp)
> +			*pcp = pc;
> +	}
> +out:
> +	return ret;

I think it is not necessary to have two return values.  Just return
the pc if it's in use:

static struct page_cgroup *lookup_page_cgroup_used(struct page)
{
	struct page_cgroup *pc;

	pc = lookup_page_cgroup(page);
	if (likely(pc) && PageCgroupUsed(pc))
		return pc;
	return NULL;
}

> +bool mem_cgroup_bad_page_check(struct page *page)
> +{
> +	if (mem_cgroup_disabled())
> +		return false;
> +
> +	return __mem_cgroup_bad_page_check(page, NULL);

	return !!lookup_page_cgroup_used(page);

> +void mem_cgroup_print_bad_page(struct page *page)
> +{
> +	struct page_cgroup *pc;
> +
> +	if (__mem_cgroup_bad_page_check(page, &pc))
> +		printk(KERN_ALERT "pc:%p pc->flags:%ld pc->mem_cgroup:%p\n",
> +			pc, pc->flags, pc->mem_cgroup);

	pc = lookup_page_cgroup_used(page);
	if (pc)
		printk()

Other than that, I agree with the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
