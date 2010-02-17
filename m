Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5226B0078
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 01:53:00 -0500 (EST)
Date: Wed, 17 Feb 2010 15:50:15 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: handle panic_on_oom=always case
Message-Id: <20100217155015.5debdcda.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100217150445.1a40201d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100217150445.1a40201d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, npiggin@suse.de, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010 15:04:45 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> tested on mmotm-Feb11.
> 
> Balbir-san, Nishimura-san, I want review from both of you.
> 
I've read only part of the original patch set yet, but I agree to the direction
of making memcg's oom panic the system on panic_on_oom==2, not panic on panic_on_oom==1.

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

> ==
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, if panic_on_oom=2, the whole system panics even if the oom happend
> in some special situation (as cpuset, mempolicy....).
> Then, panic_on_oom=2 means painc_on_oom_always.
> 
> Now, memcg doesn't check panic_on_oom flag. This patch adds a check.
> 
> Maybe someone doubts how it's useful. kdump+panic_on_oom=2 is the
> last tool to investigate what happens in oom-ed system. If a task is killed,
> the sysytem recovers and used memory were freed, there will be few hint
> to know what happnes. In mission critical system, oom should never happen.
> Then, investigation after OOM is very important.
> Then, panic_on_oom=2+kdump is useful to avoid next OOM by knowing
> precise information via snapshot.
> 
> TODO:
>  - For memcg, it's for isolate system's memory usage, oom-notiifer and
>    freeze_at_oom (or rest_at_oom) should be implemented. Then, management
>    daemon can do similar jobs (as kdump) in safer way or taking snapshot
>    per cgroup.
> 
> CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> CC: David Rientjes <rientjes@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |    2 ++
>  Documentation/sysctl/vm.txt      |    5 ++++-
>  mm/oom_kill.c                    |    2 ++
>  3 files changed, 8 insertions(+), 1 deletion(-)
> 
> Index: mmotm-2.6.33-Feb11/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-2.6.33-Feb11.orig/Documentation/cgroups/memory.txt
> +++ mmotm-2.6.33-Feb11/Documentation/cgroups/memory.txt
> @@ -182,6 +182,8 @@ list.
>  NOTE: Reclaim does not work for the root cgroup, since we cannot set any
>  limits on the root cgroup.
>  
> +Note2: When panic_on_oom is set to "2", the whole system will panic.
> +
>  2. Locking
>  
>  The memory controller uses the following hierarchy
> Index: mmotm-2.6.33-Feb11/Documentation/sysctl/vm.txt
> ===================================================================
> --- mmotm-2.6.33-Feb11.orig/Documentation/sysctl/vm.txt
> +++ mmotm-2.6.33-Feb11/Documentation/sysctl/vm.txt
> @@ -573,11 +573,14 @@ Because other nodes' memory may be free.
>  may be not fatal yet.
>  
>  If this is set to 2, the kernel panics compulsorily even on the
> -above-mentioned.
> +above-mentioned. Even oom happens under memoyr cgroup, the whole
> +system panics.
>  
>  The default value is 0.
>  1 and 2 are for failover of clustering. Please select either
>  according to your policy of failover.
> +2 seems too strong but panic_on_oom=2+kdump gives you very strong
> +tool to investigate a system which should never cause OOM.
>  
>  =============================================================
>  
> Index: mmotm-2.6.33-Feb11/mm/oom_kill.c
> ===================================================================
> --- mmotm-2.6.33-Feb11.orig/mm/oom_kill.c
> +++ mmotm-2.6.33-Feb11/mm/oom_kill.c
> @@ -471,6 +471,8 @@ void mem_cgroup_out_of_memory(struct mem
>  	unsigned long points = 0;
>  	struct task_struct *p;
>  
> +	if (sysctl_panic_on_oom == 2)
> +		panic("out of memory(memcg). panic_on_oom is selected.\n");
>  	read_lock(&tasklist_lock);
>  retry:
>  	p = select_bad_process(&points, mem);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
