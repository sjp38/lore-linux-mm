Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8EAFF6B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 22:31:58 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0D3VthC009793
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Jan 2010 12:31:55 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F16AE45DE7A
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 12:31:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C6A7B45DE79
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 12:31:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 998D91DB8037
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 12:31:54 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 28D46E18002
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 12:31:54 +0900 (JST)
Date: Wed, 13 Jan 2010 12:27:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: ensure list is empty at rmdir
Message-Id: <20100113122754.d390d0a2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100113103006.8cf3b23c.nishimura@mxp.nes.nec.co.jp>
References: <20100112140836.45e7fabb.nishimura@mxp.nes.nec.co.jp>
	<20100113103006.8cf3b23c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, stable <stable@kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 2010 10:30:06 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> This patch tries to fix this bug by ensuring not only the usage is zero but also
> all of the LRUs are empty. mem_cgroup_force_empty_list() checks the list is empty
> or not, so we can make use of it.
>

Hmm, too short ? ;) fix me if following is wrong.

 Logical Background.
 
 The problem here is pages on LRU may contain pointer to stale memcg. To make
 res->usage to be 0, all pages on memcg must be uncharged. Uncharge page_cgroup
 contains pointer to memcg withou PCG_USED bit. (This asynchronous LRU work is
 for improving performance.) If PCG_USED bit is not set, page_cgroup will never
 be added to memcg's LRU. So, about pages not on LRU, they never access stale
 pointer. Then, what we have to take care of is page_cgroup _on_ LRU list.
 
 Before this patch, mem->res.usage is checked after lru_add_drain(). But this
 doesn't guarantee memcg's LRU is really empty (considering races with other cpus.)
 In usual workload, in most case, current logic works without bug. (Considering
 how rmdir->force_empty() works..). But in some heavy workload case, pages remain
 on LRU can cause invalid access to freed memcg. This patch fixes rmdir->force_empty
 to visit all all LRUs before exiting this force_empty loop and guarantee there
 are no pages on memcg's LRU.


Thanks,
-Kame

 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: stable@kernel.org
> ---
> This patch is based on 2.6.33-rc3, and can be applied to older versions too.
> 
>  mm/memcontrol.c |   11 ++++-------
>  1 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 488b644..954032b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2586,7 +2586,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *mem, bool free_all)
>  	if (free_all)
>  		goto try_to_free;
>  move_account:
> -	while (mem->res.usage > 0) {
> +	do {
>  		ret = -EBUSY;
>  		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
>  			goto out;
> @@ -2614,8 +2614,8 @@ move_account:
>  		if (ret == -ENOMEM)
>  			goto try_to_free;
>  		cond_resched();
> -	}
> -	ret = 0;
> +	/* "ret" should also be checked to ensure all lists are empty. */
> +	} while (mem->res.usage > 0 || ret);
>  out:
>  	css_put(&mem->css);
>  	return ret;
> @@ -2648,10 +2648,7 @@ try_to_free:
>  	}
>  	lru_add_drain();
>  	/* try move_account...there may be some *locked* pages. */
> -	if (mem->res.usage)
> -		goto move_account;
> -	ret = 0;
> -	goto out;
> +	goto move_account;
>  }
>  
>  int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
