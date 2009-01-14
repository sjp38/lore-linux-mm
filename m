Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C2B9A6B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 08:43:10 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0EDh83G013310
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Jan 2009 22:43:08 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DBF52AEA8E
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 22:43:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B451C45DD74
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 22:43:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DD5021DB8045
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 22:43:06 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CC8F1DB8041
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 22:43:06 +0900 (JST)
Message-ID: <7602a77a9fc6b1e8757468048fde749a.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
    <20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
Date: Wed, 14 Jan 2009 22:43:05 +0900 (JST)
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
 obsolete
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura さんは書きました：
> This is a new one. Please review.
>
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>
> mem_cgroup_get ensures that the memcg that has been got can be accessed
> even after the directory has been removed, but it doesn't ensure that
> parents
> of it can be accessed: parents might have been freed already by rmdir.
>
> This causes a bug in case of use_hierarchy==1, because
> res_counter_uncharge
> climb up the tree.
>
> Check if the memcg is obsolete, and don't call res_counter_uncharge when
> obsole.
>
Hmm, did you see panic ?
To handle the problem "parent may be obsolete",

call mem_cgroup_get(parent) at create()
call mem_cgroup_put(parent) at freeing memcg.
     (regardless of use_hierarchy.)

is clearer way to go, I think.

I wonder whether there is  mis-accounting problem or not..

So, adding css_tryget() around problematic code can be a fix.
--
  mem = swap_cgroup_record();
  if (css_tryget(&mem->css)) {
      res_counter_uncharge(&mem->memsw, PAZE_SIZE);
      css_put(&mem->css)
  }
--
I like css_tryget() rather than mem_cgroup_obsolete().
To be honest, I'd like to remove memcg special stuff when I can.

Thanks,
-Kame

> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fb62b43..4ee95a8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1182,7 +1182,8 @@ int mem_cgroup_cache_charge(struct page *page,
> struct mm_struct *mm,
>  		/* avoid double counting */
>  		mem = swap_cgroup_record(ent, NULL);
>  		if (mem) {
> -			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> +			if (!mem_cgroup_is_obsolete(mem))
> +				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
>  			mem_cgroup_put(mem);
>  		}
>  	}
> @@ -1252,7 +1253,8 @@ void mem_cgroup_commit_charge_swapin(struct page
> *page, struct mem_cgroup *ptr)
>  		struct mem_cgroup *memcg;
>  		memcg = swap_cgroup_record(ent, NULL);
>  		if (memcg) {
> -			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> +			if (!mem_cgroup_is_obsolete(memcg))
> +				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
>  			mem_cgroup_put(memcg);
>  		}
>
> @@ -1397,7 +1399,8 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
>
>  	memcg = swap_cgroup_record(ent, NULL);
>  	if (memcg) {
> -		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> +		if (!mem_cgroup_is_obsolete(memcg))
> +			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
>  		mem_cgroup_put(memcg);
>  	}
>  }
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
