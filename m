Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id EA8916B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:32:02 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so118558eek.35
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 02:32:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id 5si23047770eei.123.2013.12.12.02.32.01
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 02:32:01 -0800 (PST)
Date: Thu, 12 Dec 2013 11:31:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131212103159.GB2630@dhcp22.suse.cz>
References: <20131203120454.GA12758@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com>
 <20131204111318.GE8410@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com>
 <20131209124840.GC3597@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com>
 <20131210103827.GB20242@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com>
 <20131211095549.GA18741@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed 11-12-13 14:40:24, David Rientjes wrote:
> On Wed, 11 Dec 2013, Michal Hocko wrote:
> 
> > > Triggering a pointless notification with PF_EXITING is rare, yet one 
> > > pointless notification can be avoided with the patch. 
> > 
> > Sigh. Yes it will avoid one particular and rare race. There will still
> > be notifications without oom kills.
> > 
> 
> Would you prefer doing the mem_cgroup_oom_notify() in two places instead:
> 
>  - immediately before doing oom_kill_process() when it's guaranteed that
>    the kernel would have killed something, and
> 
>  - when memory.oom_control == 1 in mem_cgroup_oom_synchronize()?

Yes that would make sense to me. At least the two oom_control paths
would be consistent wrt. notifications. I thought it would be too messy
but it looks quite straightforward:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c72b03bf9679..5cb1deea6aac 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2256,15 +2256,16 @@ bool mem_cgroup_oom_synchronize(bool handle)
 
 	locked = mem_cgroup_oom_trylock(memcg);
 
-	if (locked)
-		mem_cgroup_oom_notify(memcg);
-
 	if (locked && !memcg->oom_kill_disable) {
 		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
+		/* calls mem_cgroup_oom_notify if there is a task to kill */
 		mem_cgroup_out_of_memory(memcg, current->memcg_oom.gfp_mask,
 					 current->memcg_oom.order);
 	} else {
+		if (locked && memcg->oom_kill_disable)
+			mem_cgroup_oom_notify(memcg);
+
 		schedule();
 		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1e4a600a6163..2a7f15900922 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -470,6 +470,9 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		victim = p;
 	}
 
+	if (memcg)
+		mem_cgroup_oom_notify(memcg);
+
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",


The semantic would be as simple as "notification is sent only when
an action is due". It will be still racy as nothing prevents a task
which is not under OOM to exit and release some memory but there is no
sensible way to address that. On the other hand such a semantic would be
sensible for oom_control listeners because they will know that an action
has to be or will be taken (the line was drawn).

Can we agree on this, Johannes? Or you see the line drawn when
mem_cgroup_oom_synchronize has been reached already no matter whether
the action is to be done or not?

Regardless the above. We would still have to cope with PF_EXITING
without TIF_MEMDIE entering OOM which is a separate issue. I think the
easier and cleaner solution would be to bail out early and do not even
charge for PF_EXITING tasks. It will solve the issue mentioned before
and also reduce the exit latency. Besides that I do not think we are
talking about many charges, do we?

> > Anyway.
> > Does the reclaim make any sense for PF_EXITING tasks? Shouldn't we
> > simply bypass charges of these tasks automatically. Those tasks will
> > free some memory anyway so why to trigger reclaim and potentially OOM
> > in the first place? Do we need to go via TIF_MEMDIE loop in the first
> > place?
> > 
> 
> I don't see any reason to make an optimization there since they will get 
> TIF_MEMDIE set if reclaim has failed on one of their charges or if it 
> results in a system oom through the page allocator's oom killer.

This all will happen after MEM_CGROUP_RECLAIM_RETRIES full reclaim
rounds. Is it really worth the addional overhead just to later say "OK
go ahead and skipp charges"?
And for the !oom memcg it might reclaim some pages which could have
stayed on LRUs just to free some memory little bit later and release the
memory pressure.
So I would rather go with
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c72b03bf9679..fee25c5934d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2692,7 +2693,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	 * MEMDIE process.
 	 */
 	if (unlikely(test_thread_flag(TIF_MEMDIE)
-		     || fatal_signal_pending(current)))
+		     || fatal_signal_pending(current))
+		     || current->flags & PF_EXITING)
 		goto bypass;
 
 	if (unlikely(task_in_memcg_oom(current)))

rather than the later checks down the oom_synchronize paths. The comment
already mentions dying process...

> It would be nice to ensure reclaim has had a chance to free memory in
> the presence of any other potential parallel memory freeing.

I am afraid I didn't get what you mean by this. We can only check we are
under OOM or try to reclaim to see if there is something...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
