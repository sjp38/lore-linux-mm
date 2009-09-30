Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1CCEF6B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 22:20:17 -0400 (EDT)
Date: Wed, 30 Sep 2009 11:21:49 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 10/10] memcg: add commentary
Message-Id: <20090930112149.87bc16fe.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090925173018.2435084f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090925173018.2435084f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

A few trivial comments and a question.

> @@ -1144,6 +1172,13 @@ static int mem_cgroup_count_children(str
>   	mem_cgroup_walk_tree(mem, &num, mem_cgroup_count_children_cb);
>  	return num;
>  }
> +
> +/**
> + * mem_cgroup_oon_called - check oom-kill is called recentlry under memcg
s/oon/oom/

> + * @mem: mem_cgroup to be checked.
> + *
> + * Returns true if oom-kill was invoked in this memcg recently.
> + */
>  bool mem_cgroup_oom_called(struct task_struct *task)
>  {
>  	bool ret = false;



> @@ -1314,6 +1349,16 @@ static int mem_cgroup_hierarchical_recla
>  	return total;
>  }
>  
> +/*
> + * This function is called by kswapd before entering per-zone memory reclaim.
> + * This selects a victim mem_cgroup from soft-limit tree and memory will be
> + * reclaimed from that.
> + *
> + * Soft-limit tree is sorted by the extent how many mem_cgroup's memoyr usage
> + * excess the soft limit and a memory cgroup which has the largest excess
> + * s selected as a victim. This Soft-limit tree is maintained perzone and
"is selected"
 ^

> + * we never select a memcg which has no memory usage on this zone.
> + */
I'm sorry if I misunderstand about softlimit implementation, what prevents
a memcg which has no memory usage on this zone from being selected ?
IIUC, mz->usage_in_excess has a value calculated from res_counter_soft_limit_excess(),
which doesn't take account of zone but only calculates "usage - soft_limit".

>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask, int nid,
>  						int zid)



> @@ -1757,6 +1819,11 @@ __mem_cgroup_commit_charge_swapin(struct
>  		return;
>  	cgroup_exclude_rmdir(&ptr->css);
>  	pc = lookup_page_cgroup(page);
> +	/*
> + 	 * We may overwrite pc->memcgoup in commit_charge(). But SwapCache
should be "pc->mem_cgroup".

> + 	 * can be on LRU before we reach here. Remove it from LRU for avoiding
> + 	 * confliction.
> + 	 */
>  	mem_cgroup_lru_del_before_commit_swapcache(page);
>  	__mem_cgroup_commit_charge(ptr, pc, ctype);
>  	mem_cgroup_lru_add_after_commit_swapcache(page);
> 



Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
