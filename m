Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 242E26B009E
	for <linux-mm@kvack.org>; Sat, 25 Dec 2010 18:06:26 -0500 (EST)
Date: Sun, 26 Dec 2010 00:06:17 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH] memcg: add valid check at allocating or freeing
 memory
Message-ID: <20101225230617.GH2048@cmpxchg.org>
References: <20101224093131.274c8728.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101224093131.274c8728.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Daisuke-san,

two other things:

On Fri, Dec 24, 2010 at 09:31:31AM +0900, Daisuke Nishimura wrote:
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -146,6 +146,8 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>  
> +bool mem_cgroup_bad_page_check(struct page *page);
> +void mem_cgroup_print_bad_page(struct page *page);

Can you put those under CONFIG_DEBUG_VM and the dummies below under
!CONFIG_CGROUP_MEM_RES_CTLR || !CONFIG_DEBUG_VM?

The most likely configuration on distro kernels is memcg enabled and
VM debugging disabled.  It would be good to save the unneeded function
calls in the allocator hotpath for the common case.

Also:

> @@ -336,6 +338,16 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
>  	return 0;
>  }
>  
> +static inline bool
> +mem_cgroup_bad_page_check(struct page *page)
> +{
> +	return false;
> +}
> +
> +static void

That needs an `inline' as well.

Thanks!

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
