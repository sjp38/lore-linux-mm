Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 484996B004F
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 03:47:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n847lELW006243
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Sep 2009 16:47:14 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B26845DE60
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 16:47:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 61E8245DE4D
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 16:47:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A3481DB803E
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 16:47:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B0E12E18007
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 16:47:12 +0900 (JST)
Date: Fri, 4 Sep 2009 16:45:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm][BUGFIX][PATCH] memcg: fix softlimit css refcnt
 handling.
Message-Id: <20090904164517.fb2bf3c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090904163758.a5604fee.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902134114.b6f1a04d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902182923.c6d98fd6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090903141727.ccde7e91.nishimura@mxp.nes.nec.co.jp>
	<20090904131835.ac2b8cc8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904141157.4640ec1e.nishimura@mxp.nes.nec.co.jp>
	<20090904142143.15ffcb53.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904142654.08dd159f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904154050.25873aa5.nishimura@mxp.nes.nec.co.jp>
	<20090904163758.a5604fee.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Sep 2009 16:37:58 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> ==
> SoftLimit tree 'find next one' loop uses next_mz to remember
> next one to be visited if reclaimd==0.
> But css'refcnt handling for next_mz is not enough and it makes
> css->refcnt leak.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
maybe this patch can be applied after
memory-controller-soft-limit-reclaim-on-contention-v9-fix.patch

Thanks,
-Kmae



> 
> ---
>  mm/memcontrol.c |   11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> Index: mmotm-2.6.31-Aug27/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.31-Aug27.orig/mm/memcontrol.c
> +++ mmotm-2.6.31-Aug27/mm/memcontrol.c
> @@ -2261,6 +2261,8 @@ unsigned long mem_cgroup_soft_limit_recl
>  		if (!reclaimed) {
>  			do {
>  				/*
> +				 * Loop until we find yet another one.
> +				 *
>  				 * By the time we get the soft_limit lock
>  				 * again, someone might have aded the
>  				 * group back on the RB tree. Iterate to
> @@ -2271,7 +2273,12 @@ unsigned long mem_cgroup_soft_limit_recl
>  				 */
>  				next_mz =
>  				__mem_cgroup_largest_soft_limit_node(mctz);
> -			} while (next_mz == mz);
> +				if (next_mz == mz) {
> +					css_put(&next_mz->mem->css);
> +					next_mz = NULL;
> +				} else /* next_mz == NULL or other memcg */
> +					break;
> +			} while (1);
>  		}
>  		mz->usage_in_excess =
>  			res_counter_soft_limit_excess(&mz->mem->res);
> @@ -2299,6 +2306,8 @@ unsigned long mem_cgroup_soft_limit_recl
>  			loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
>  			break;
>  	} while (!nr_reclaimed);
> +	if (next_mz)
> +		css_put(&next_mz->mem->css);
>  	return nr_reclaimed;
>  }
>  
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
