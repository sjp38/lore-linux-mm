Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 10BF66B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 07:09:40 -0500 (EST)
Date: Fri, 14 Jan 2011 13:09:31 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] [BUGFIX] dont set USED bit on tail pages
Message-ID: <20110114120931.GP23189@cmpxchg.org>
References: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110114190909.d396cdf4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110114190909.d396cdf4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 14, 2011 at 07:09:09PM +0900, KAMEZAWA Hiroyuki wrote:
> --- mmotm-0107.orig/mm/memcontrol.c
> +++ mmotm-0107/mm/memcontrol.c

> @@ -2154,6 +2139,23 @@ static void __mem_cgroup_commit_charge(s
>  	 */
>  	memcg_check_events(mem, pc->page);
>  }
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +/*
> + * Because tail pages are not mared as "used", set it. We're under

marked

> + * compund_lock and don't need to take care of races.
> + * Statistics are updated properly at charging. We just mark Used bits.
> + */
> +void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
> +{
> +	struct page_cgroup *hpc = lookup_page_cgroup(head);
> +	struct page_cgroup *tpc = lookup_page_cgroup(tail);

I have trouble reading the code fluently with those names as they are
just very similar random letter sequences.  Could you rename them so
that they're better to discriminate?  headpc and tailpc perhaps?

> +	tpc->mem_cgroup = hpc->mem_cgroup;
> +	smp_wmb(); /* see __commit_charge() */
> +	SetPageCgroupUsed(tpc);
> +	VM_BUG_ON(PageCgroupCache(hpc));

Right now, this would be a bug due to other circumstances, but this
function does not require the page to be anon to function correctly,
does it?  I don't think we should encode a made up dependency here.

> @@ -2602,8 +2603,7 @@ __mem_cgroup_uncharge_common(struct page
>  		break;
>  	}
>  
> -	for (i = 0; i < count; i++)
> -		mem_cgroup_charge_statistics(mem, file, -1);
> +	mem_cgroup_charge_statistics(mem, file, -count);

Pass PageCgroupCache(pc) instead, ditch the `file' variable?

>  	ClearPageCgroupUsed(pc);
>  	/*
> Index: mmotm-0107/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-0107.orig/include/linux/memcontrol.h
> +++ mmotm-0107/include/linux/memcontrol.h
> @@ -146,6 +146,10 @@ unsigned long mem_cgroup_soft_limit_recl
>  						gfp_t gfp_mask);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
> +#endif
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct mem_cgroup;
>  
> Index: mmotm-0107/mm/huge_memory.c
> ===================================================================
> --- mmotm-0107.orig/mm/huge_memory.c
> +++ mmotm-0107/mm/huge_memory.c
> @@ -1203,6 +1203,8 @@ static void __split_huge_page_refcount(s
>  		BUG_ON(!PageDirty(page_tail));
>  		BUG_ON(!PageSwapBacked(page_tail));
>  
> +		mem_cgroup_split_huge_fixup(page, page_tail);

You need to provide a dummy for non-memcg configurations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
