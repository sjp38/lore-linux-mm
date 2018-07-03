Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7CB6B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:58:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id s15-v6so1192725wrn.16
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:58:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b73-v6si1229952wme.127.2018.07.03.08.58.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 08:58:54 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w63FtRFL102848
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 11:58:53 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k09dh8nft-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Jul 2018 11:58:53 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 3 Jul 2018 11:58:52 -0400
Date: Tue, 3 Jul 2018 09:01:01 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Reply-To: paulmck@linux.vnet.ibm.com
References: <20180627072207.GB32348@dhcp22.suse.cz>
 <20180627143125.GW3593@linux.vnet.ibm.com>
 <20180628113942.GD32348@dhcp22.suse.cz>
 <20180628213105.GP3593@linux.vnet.ibm.com>
 <20180629090419.GD13860@dhcp22.suse.cz>
 <20180629125218.GX3593@linux.vnet.ibm.com>
 <20180629132638.GD5963@dhcp22.suse.cz>
 <20180630170522.GZ3593@linux.vnet.ibm.com>
 <20180702213714.GA7604@linux.vnet.ibm.com>
 <20180703072413.GD16767@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703072413.GD16767@dhcp22.suse.cz>
Message-Id: <20180703160101.GC3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, Jul 03, 2018 at 09:24:13AM +0200, Michal Hocko wrote:
> On Mon 02-07-18 14:37:14, Paul E. McKenney wrote:
> [...]
> > commit d2b8d16b97ac2859919713b2d98b8a3ad22943a2
> > Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Date:   Mon Jul 2 14:30:37 2018 -0700
> > 
> >     rcu: Remove OOM code
> >     
> >     There is reason to believe that RCU's OOM code isn't really helping
> >     that much, given that the best it can hope to do is accelerate invoking
> >     callbacks by a few seconds, and even then only if some CPUs have no
> >     non-lazy callbacks, a condition that has been observed to be rare.
> >     This commit therefore removes RCU's OOM code.  If this causes problems,
> >     it can easily be reinserted.
> >     
> >     Reported-by: Michal Hocko <mhocko@kernel.org>
> >     Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> >     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> I would also note that waiting in the notifier might be a problem on its
> own because we are holding the oom_lock and the system cannot trigger
> the OOM killer while we are holding it and waiting for oom_callback_wq
> event. I am not familiar with the code to tell whether this can deadlock
> but from a quick glance I _suspect_ that we might depend on __rcu_reclaim
> and basically an arbitrary callback so no good.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks!

Like this?

							Thanx, Paul

------------------------------------------------------------------------

commit d3cf56333af5e65054f533f6f271a7bd36b868f4
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Mon Jul 2 14:30:37 2018 -0700

    rcu: Remove OOM code
    
    There is reason to believe that RCU's OOM code isn't really helping
    that much, given that the best it can hope to do is accelerate invoking
    callbacks by a few seconds, and even then only if some CPUs have no
    non-lazy callbacks, a condition that has been observed to be rare.
    In addition, it can block on the oom_callback_wq wait queue, which could
    delay more urgent and productive OOM actions.  This commit therefore
    removes RCU's OOM code.  If this causes problems, this commit can easily
    be reverted.
    
    Reported-by: Michal Hocko <mhocko@kernel.org>
    Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Acked-by: Michal Hocko <mhocko@suse.com>

diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
index 3f3796b10c71..3d7ce73e7309 100644
--- a/kernel/rcu/tree_plugin.h
+++ b/kernel/rcu/tree_plugin.h
@@ -1722,87 +1722,6 @@ static void rcu_idle_count_callbacks_posted(void)
 	__this_cpu_add(rcu_dynticks.nonlazy_posted, 1);
 }
 
-/*
- * Data for flushing lazy RCU callbacks at OOM time.
- */
-static atomic_t oom_callback_count;
-static DECLARE_WAIT_QUEUE_HEAD(oom_callback_wq);
-
-/*
- * RCU OOM callback -- decrement the outstanding count and deliver the
- * wake-up if we are the last one.
- */
-static void rcu_oom_callback(struct rcu_head *rhp)
-{
-	if (atomic_dec_and_test(&oom_callback_count))
-		wake_up(&oom_callback_wq);
-}
-
-/*
- * Post an rcu_oom_notify callback on the current CPU if it has at
- * least one lazy callback.  This will unnecessarily post callbacks
- * to CPUs that already have a non-lazy callback at the end of their
- * callback list, but this is an infrequent operation, so accept some
- * extra overhead to keep things simple.
- */
-static void rcu_oom_notify_cpu(void *unused)
-{
-	struct rcu_state *rsp;
-	struct rcu_data *rdp;
-
-	for_each_rcu_flavor(rsp) {
-		rdp = raw_cpu_ptr(rsp->rda);
-		if (rcu_segcblist_n_lazy_cbs(&rdp->cblist)) {
-			atomic_inc(&oom_callback_count);
-			rsp->call(&rdp->oom_head, rcu_oom_callback);
-		}
-	}
-}
-
-/*
- * If low on memory, ensure that each CPU has a non-lazy callback.
- * This will wake up CPUs that have only lazy callbacks, in turn
- * ensuring that they free up the corresponding memory in a timely manner.
- * Because an uncertain amount of memory will be freed in some uncertain
- * timeframe, we do not claim to have freed anything.
- */
-static int rcu_oom_notify(struct notifier_block *self,
-			  unsigned long notused, void *nfreed)
-{
-	int cpu;
-
-	/* Wait for callbacks from earlier instance to complete. */
-	wait_event(oom_callback_wq, atomic_read(&oom_callback_count) == 0);
-	smp_mb(); /* Ensure callback reuse happens after callback invocation. */
-
-	/*
-	 * Prevent premature wakeup: ensure that all increments happen
-	 * before there is a chance of the counter reaching zero.
-	 */
-	atomic_set(&oom_callback_count, 1);
-
-	for_each_online_cpu(cpu) {
-		smp_call_function_single(cpu, rcu_oom_notify_cpu, NULL, 1);
-		cond_resched_tasks_rcu_qs();
-	}
-
-	/* Unconditionally decrement: no need to wake ourselves up. */
-	atomic_dec(&oom_callback_count);
-
-	return NOTIFY_OK;
-}
-
-static struct notifier_block rcu_oom_nb = {
-	.notifier_call = rcu_oom_notify
-};
-
-static int __init rcu_register_oom_notifier(void)
-{
-	register_oom_notifier(&rcu_oom_nb);
-	return 0;
-}
-early_initcall(rcu_register_oom_notifier);
-
 #endif /* #else #if !defined(CONFIG_RCU_FAST_NO_HZ) */
 
 #ifdef CONFIG_RCU_FAST_NO_HZ
