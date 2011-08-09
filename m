Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 485736B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:06:39 -0400 (EDT)
Date: Tue, 9 Aug 2011 14:06:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Revert "memcg: get rid of percpu_charge_mutex lock"
Message-ID: <20110809120634.GH7463@tiehlicka.suse.cz>
References: <20110809114524.GF7463@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809114524.GF7463@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, LKML <linux-kernel@vger.kernel.org>

[Sorry for reposting but I have just realized that I forgot to add
mailing lists into CC.]

On Tue 09-08-11 13:45:24, Michal Hocko wrote:
> Linus, could you please apply the following revert? It fixes a crash in
> 3.0 kernel. I will push it to stable once it gets to your tree.
> The original report can be found at https://lkml.org/lkml/2011/8/8/331
> 
> Thanks
> ---
> From 34302b9a2d3628f699996c937158b0decf1dbef7 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Tue, 9 Aug 2011 11:56:26 +0200
> Subject: [PATCH] Revert "memcg: get rid of percpu_charge_mutex lock"
> 
> This reverts commit 8521fc50d433507a7cdc96bec280f9e5888a54cc.
> 
> The patch incorrectly assumes that using atomic FLUSHING_CACHED_CHARGE
> bit operations is sufficient but that is not true. Johannes Weiner has
> reported a crash during parallel memory cgroup removal:
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> IP: [<ffffffff81083b70>] css_is_ancestor+0x20/0x70
> PGD 4ae7a067 PUD 4adc4067 PMD 0
> Oops: 0000 [#1] PREEMPT SMP
> CPU 0
> Pid: 19677, comm: rmdir Tainted: G        W   3.0.0-mm1-00188-gf38d32b #35 ECS MCP61M-M3/MCP61M-M3
> RIP: 0010:[<ffffffff81083b70>]  [<ffffffff81083b70>] css_is_ancestor+0x20/0x70
> RSP: 0018:ffff880077b09c88  EFLAGS: 00010202
> RAX: ffff8800781bb310 RBX: 0000000000000000 RCX: 000000000000003e
> RDX: 0000000000000000 RSI: ffff8800779f7c00 RDI: 0000000000000000
> RBP: ffff880077b09c98 R08: ffffffff818a4e88 R09: 0000000000000000
> R10: 0000000000000000 R11: dead000000100100 R12: ffff8800779f7c00
> R13: ffff8800779f7c00 R14: 0000000000000000 R15: ffff88007bc0eb80
> FS:  00007f5d689ec720(0000) GS:ffff88007bc00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000018 CR3: 000000004ad57000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process rmdir (pid: 19677, threadinfo ffff880077b08000, task ffff8800781bb310)
> Stack:
>  ffffffff818a4e88 000000000000eb80 ffff880077b09ca8 ffffffff810feba3
>  ffff880077b09d08 ffffffff810feccf ffff880077b09cf8 0000000000000001
>  ffff88007bd0eb80 0000000000000001 ffff880077af2000 0000000000000000
> Call Trace:
>  [<ffffffff810feba3>] mem_cgroup_same_or_subtree+0x33/0x40
>  [<ffffffff810feccf>] drain_all_stock+0x11f/0x170
>  [<ffffffff81103211>] mem_cgroup_force_empty+0x231/0x6d0
>  [<ffffffff81111872>] ? path_put+0x22/0x30
>  [<ffffffff8111c925>] ? __d_lookup+0xb5/0x170
>  [<ffffffff811036c4>] mem_cgroup_pre_destroy+0x14/0x20
>  [<ffffffff81080559>] cgroup_rmdir+0xb9/0x500
>  [<ffffffff81063990>] ? abort_exclusive_wait+0xb0/0xb0
>  [<ffffffff81114d26>] vfs_rmdir+0x86/0xe0
>  [<ffffffff811233d3>] ? mnt_want_write+0x43/0x80
>  [<ffffffff81114e7b>] do_rmdir+0xfb/0x110
>  [<ffffffff81114ea6>] sys_rmdir+0x16/0x20
>  [<ffffffff8154d76b>] system_call_fastpath+0x16/0x1b
> Code: b7 42 0a 5d c3 66 0f 1f 44 00 00 55 48 89 e5 48 83 ec 10 48 89 5d f0 4c 89 65 f8 66 66 66 66 90 48 89 fb 49 89 f4 e8 10 85 00 00
>  8b 43 18 49 8b 54 24 18 48 85 d2 74 05 48 85 c0 75 15 31 db
> 
> We are crashing because we try to dereference cached memcg when we are
> checking whether we should wait for draining on the cache. The cache is
> already cleaned up, though.
> There is also a theoretical chance that the cached memcg gets freed
> between we test for the FLUSHING_CACHED_CHARGE and dereference it in
> mem_cgroup_same_or_subtree:
>         CPU0                    CPU1                         CPU2
> mem=stock->cached
> stock->cached=NULL
>                               clear_bit
>                                                         test_and_set_bit
> test_bit()                    ...
> <preempted>             mem_cgroup_destroy
> use after free
> 
> The percpu_charge_mutex protected from this race because sync draining
> is exclusive.
> 
> It is safer to revert now and come up with a more parallel
> implementation later.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Reported-by: Johannes Weiner <jweiner@redhat.com>
> ---
>  mm/memcontrol.c |   12 ++++++++++--
>  1 files changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f4ec4e7..930de94 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2091,6 +2091,7 @@ struct memcg_stock_pcp {
>  #define FLUSHING_CACHED_CHARGE	(0)
>  };
>  static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
> +static DEFINE_MUTEX(percpu_charge_mutex);
>  
>  /*
>   * Try to consume stocked charge on this cpu. If success, one page is consumed
> @@ -2197,8 +2198,7 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
>  
>  	for_each_online_cpu(cpu) {
>  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> -		if (mem_cgroup_same_or_subtree(root_mem, stock->cached) &&
> -				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> +		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
>  			flush_work(&stock->work);
>  	}
>  out:
> @@ -2213,14 +2213,22 @@ out:
>   */
>  static void drain_all_stock_async(struct mem_cgroup *root_mem)
>  {
> +	/*
> +	 * If someone calls draining, avoid adding more kworker runs.
> +	 */
> +	if (!mutex_trylock(&percpu_charge_mutex))
> +		return;
>  	drain_all_stock(root_mem, false);
> +	mutex_unlock(&percpu_charge_mutex);
>  }
>  
>  /* This is a synchronous drain interface. */
>  static void drain_all_stock_sync(struct mem_cgroup *root_mem)
>  {
>  	/* called when force_empty is called */
> +	mutex_lock(&percpu_charge_mutex);
>  	drain_all_stock(root_mem, true);
> +	mutex_unlock(&percpu_charge_mutex);
>  }
>  
>  /*
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
