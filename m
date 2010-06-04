Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CA6DD6B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 21:24:17 -0400 (EDT)
Date: Fri, 4 Jun 2010 10:08:11 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH] memcg fix wake up in oom wait queue
Message-Id: <20100604100811.31c45828.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100603172353.b5375879.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100603172353.b5375879.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010 17:23:53 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Very sorry that my test wasn't enough and delayed.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> OOM-waitqueue should be waken up when oom_disable is canceled.
> This is a fix for
>  memcg-oom-kill-disable-and-oom-status.patch
> 
> How to test:
>  Create a cgroup A...
>  1. set memory.limit and memory.memsw.limit to be small value
>  2. echo 1 > /cgroup/A/memory.oom_control, this disables oom-kill.
>  3. run a program which must cause OOM.
> 
> A program executed in 3 will sleep by oom_waiqueue in memcg.
> Then, how to wake it up is problem.
> 
>  1. echo 0 > /cgroup/A/memory.oom_control (enable OOM-killer)
>  2. echo big mem > /cgroup/A/memory.memsw.limit_in_bytes(allow more swap)
> etc..
> 
> Without the patch, a task in slept can not be waken up.
> 

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> Index: mmotm-2.6.34-May21/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.34-May21.orig/mm/memcontrol.c
> +++ mmotm-2.6.34-May21/mm/memcontrol.c
> @@ -1413,7 +1413,7 @@ static void memcg_wakeup_oom(struct mem_
>  
>  static void memcg_oom_recover(struct mem_cgroup *mem)
>  {
> -	if (mem->oom_kill_disable && atomic_read(&mem->oom_lock))
> +	if (atomic_read(&mem->oom_lock))
>  		memcg_wakeup_oom(mem);
>  }
>  
> @@ -3830,6 +3830,8 @@ static int mem_cgroup_oom_control_write(
>  		return -EINVAL;
>  	}
>  	mem->oom_kill_disable = val;
> +	if (!val)
> +		memcg_oom_recover(mem);
>  	cgroup_unlock();
>  	return 0;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
