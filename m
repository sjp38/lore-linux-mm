Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E54666B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 00:38:09 -0400 (EDT)
Date: Thu, 9 Jun 2011 13:34:23 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH] memcg: fix wrong decision of noswap with
 softlimit.
Message-Id: <20110609133423.3223aaff.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110609095445.5f98b752.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110609095445.5f98b752.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Thu, 9 Jun 2011 09:54:45 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> I wonder this should go stable...
hmm, IMHO, it's not necessary just because there have been no bug reports
about this bug.

> ==
> From e2565de1c764057b75b4d9a1674d163b6c873cdd Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 9 Jun 2011 09:54:32 +0900
> Subject: [PATCH 2/2] Fix softlimit wrong check of noswap
> 
> Now, hierarchical reclaim doesn't make swap if memory's limit is
> equal to mem+swap limit. Because if reclaim does swap-out,
> it still hits mem+swap limit and there will be no progress.
> WHEN HITTING HARD LIMIT.
> 
> When it comes to softlimit, it works for kswapd. noswap is nonsense.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

If we implement "softlimit for memsw" in future, we might change the check again,
but it's another story.

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3baddcb..06825be 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1663,7 +1663,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
>  
>  	/* If memsw_is_minimum==1, swap-out is of-no-use. */
> -	if (root_mem->memsw_is_minimum)
> +	if (!check_soft && root_mem->memsw_is_minimum)
>  		noswap = true;
>  
>  	while (1) {
> -- 
> 1.7.4.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
