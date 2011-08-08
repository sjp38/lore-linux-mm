Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 76D946B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 17:47:10 -0400 (EDT)
Date: Mon, 8 Aug 2011 23:47:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] memcg: get rid of percpu_charge_mutex lock
Message-ID: <20110808214704.GA4396@tiehlicka.suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
 <a9244082ba28c4c2e4a6997311d5493bdaa117e9.1311338634.git.mhocko@suse.cz>
 <20110808184738.GA7749@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110808184738.GA7749@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon 08-08-11 20:47:38, Johannes Weiner wrote:
[...]
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2071,7 +2071,6 @@ struct memcg_stock_pcp {
> >  #define FLUSHING_CACHED_CHARGE	(0)
> >  };
> >  static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
> > -static DEFINE_MUTEX(percpu_charge_mutex);
> >  
> >  /*
> >   * Try to consume stocked charge on this cpu. If success, one page is consumed
> > @@ -2178,7 +2177,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> >  
> >  	for_each_online_cpu(cpu) {
> >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > -		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > +		if (mem_cgroup_same_or_subtree(root_mem, stock->cached) &&
> > +				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> >  			flush_work(&stock->work);
> >  	}
> >  out:
> 
> This hunk triggers a crash for me, as the draining is already done and
> stock->cached reset to NULL when dereferenced here.  Oops is attached.

Thanks for catching this. We are racing synchronous drain from
force_empty and async drain from reclaim, I guess. Sync. checked
whether it should wait for the work and the cache got drained and
set to NULL. 
First of all we must not dereference the cached mem without
FLUSHING_CACHED_CHARGE bit test. We have to be sure that there is some
draining on that cache. stock->cached is set to NULL before we clear the
bit (I guess we need to add a barrier into drain_local_stock). So we should
see mem either as NULL or still valid (I have to think some more about
"still valid" part - maybe we will need rcu_read_lock).

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f4ec4e7..626c916 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2197,8 +2197,10 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
 
 	for_each_online_cpu(cpu) {
 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
-		if (mem_cgroup_same_or_subtree(root_mem, stock->cached) &&
-				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
+		struct mem_cgroup *mem = stock->cached;
+		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags) &&
+				 mem && mem_cgroup_same_or_subtree(root_mem, mem)
+				)
 			flush_work(&stock->work);
 	}
 out:

> 
> We have this loop in drain_all_stock():
> 
> 	for_each_online_cpu(cpu) {
> 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> 		struct mem_cgroup *mem;
> 
> 		mem = stock->cached;
> 		if (!mem || !stock->nr_pages)
> 			continue;
> 		if (!mem_cgroup_same_or_subtree(root_mem, mem))
> 			continue;
> 		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
> 			if (cpu == curcpu)
> 				drain_local_stock(&stock->work);
> 			else
> 				schedule_work_on(cpu, &stock->work);
> 		}
> 	}
> 
> The only thing that stabilizes stock->cached is the knowledge that
> there are still pages accounted to the memcg.

Yes you are right we have to set FLUSHING_CACHED_CHARGE before nr_pages
check (and do the appropriate cleanup on the continue paths). This looks
quite ugly, though.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f4ec4e7..eca46141 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2179,17 +2179,23 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
 		struct mem_cgroup *mem;
 
+		/* Try to lock the cache */
+		if(test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
+			continue;
+
 		mem = stock->cached;
 		if (!mem || !stock->nr_pages)
-			continue;
+			goto unlock_cache;
 		if (!mem_cgroup_same_or_subtree(root_mem, mem))
-			continue;
-		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
-			if (cpu == curcpu)
-				drain_local_stock(&stock->work);
-			else
-				schedule_work_on(cpu, &stock->work);
-		}
+			goto unlock_cache;
+
+		if (cpu == curcpu)
+			drain_local_stock(&stock->work);
+		else
+			schedule_work_on(cpu, &stock->work);
+		continue;
+unlock_cache:
+		clear_bit(FLUSHING_CACHED_CHARGE, &stock->flags);

                ^^^^^
		need a barrier?
 	}
 
 	if (!sync)
 
> Without the mutex serializing this code, can't there be a concurrent
> execution that leads to stock->cached being drained, becoming empty
> and freed by someone else between the stock->nr_pages check and the
> ancestor check, resulting in use after free?
> 
> What makes stock->cached safe to dereference?

We are using FLUSHING_CACHED_CHARGE as a lock for local draining. I
guess it should be sufficient.

mutex which was used previously caused that async draining was exclusive
so a root_mem that has potentially many relevant caches has to back off
because other mem wants to clear the cache on the same CPU.

I will think about this tomorrow (with fresh eyes). I think we should be
able to be without mutex.

Anyway thanks for the really good report!

> 
> [ 2313.442944] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> [ 2313.443935] IP: [<ffffffff81083b70>] css_is_ancestor+0x20/0x70
> [ 2313.443935] PGD 4ae7a067 PUD 4adc4067 PMD 0
> [ 2313.443935] Oops: 0000 [#1] PREEMPT SMP
> [ 2313.443935] CPU 0
> [ 2313.443935] Pid: 19677, comm: rmdir Tainted: G        W   3.0.0-mm1-00188-gf38d32b #35 ECS MCP61M-M3/MCP61M-M3
> [ 2313.443935] RIP: 0010:[<ffffffff81083b70>]  [<ffffffff81083b70>] css_is_ancestor+0x20/0x70
> [ 2313.443935] RSP: 0018:ffff880077b09c88  EFLAGS: 00010202
> [ 2313.443935] RAX: ffff8800781bb310 RBX: 0000000000000000 RCX: 000000000000003e
> [ 2313.443935] RDX: 0000000000000000 RSI: ffff8800779f7c00 RDI: 0000000000000000
> [ 2313.443935] RBP: ffff880077b09c98 R08: ffffffff818a4e88 R09: 0000000000000000
> [ 2313.443935] R10: 0000000000000000 R11: dead000000100100 R12: ffff8800779f7c00
> [ 2313.443935] R13: ffff8800779f7c00 R14: 0000000000000000 R15: ffff88007bc0eb80
> [ 2313.443935] FS:  00007f5d689ec720(0000) GS:ffff88007bc00000(0000) knlGS:0000000000000000
> [ 2313.443935] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 2313.443935] CR2: 0000000000000018 CR3: 000000004ad57000 CR4: 00000000000006f0
> [ 2313.443935] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 2313.443935] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 2313.443935] Process rmdir (pid: 19677, threadinfo ffff880077b08000, task ffff8800781bb310)
> [ 2313.443935] Stack:
> [ 2313.443935]  ffffffff818a4e88 000000000000eb80 ffff880077b09ca8 ffffffff810feba3
> [ 2313.443935]  ffff880077b09d08 ffffffff810feccf ffff880077b09cf8 0000000000000001
> [ 2313.443935]  ffff88007bd0eb80 0000000000000001 ffff880077af2000 0000000000000000
> [ 2313.443935] Call Trace:
> [ 2313.443935]  [<ffffffff810feba3>] mem_cgroup_same_or_subtree+0x33/0x40
> [ 2313.443935]  [<ffffffff810feccf>] drain_all_stock+0x11f/0x170
> [ 2313.443935]  [<ffffffff81103211>] mem_cgroup_force_empty+0x231/0x6d0
> [ 2313.443935]  [<ffffffff81111872>] ? path_put+0x22/0x30
> [ 2313.443935]  [<ffffffff8111c925>] ? __d_lookup+0xb5/0x170
> [ 2313.443935]  [<ffffffff811036c4>] mem_cgroup_pre_destroy+0x14/0x20
> [ 2313.443935]  [<ffffffff81080559>] cgroup_rmdir+0xb9/0x500
> [ 2313.443935]  [<ffffffff81063990>] ? abort_exclusive_wait+0xb0/0xb0
> [ 2313.443935]  [<ffffffff81114d26>] vfs_rmdir+0x86/0xe0
> [ 2313.443935]  [<ffffffff811233d3>] ? mnt_want_write+0x43/0x80
> [ 2313.443935]  [<ffffffff81114e7b>] do_rmdir+0xfb/0x110
> [ 2313.443935]  [<ffffffff81114ea6>] sys_rmdir+0x16/0x20
> [ 2313.443935]  [<ffffffff8154d76b>] system_call_fastpath+0x16/0x1b
> [ 2313.443935] Code: b7 42 0a 5d c3 66 0f 1f 44 00 00 55 48 89 e5 48 83 ec 10 48 89 5d f0 4c 89 65 f8 66 66 66 66 90 48 89 fb 49 89 f4 e8 10 85 00 00
> [ 2313.443935]  8b 43 18 49 8b 54 24 18 48 85 d2 74 05 48 85 c0 75 15 31 db
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
