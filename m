Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 945FC6B0083
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 17:18:14 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D3E2D82C53D
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 17:35:01 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id g-nJo3Vg1yb5 for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 17:35:01 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 724E282C540
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 17:34:55 -0400 (EDT)
Message-Id: <20090617203445.115875575@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:49 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 12/19] RCU: Use this_cpu operations
Content-Disposition: inline; filename=this_cpu_rcu
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

RCU does not do dynamic allocations but it increments per cpu variables
a lot. These instructions results in a move to a register and then back
to memory. This patch will make it use the inc/dec instructions on x86
that do not need a register.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 kernel/rcupreempt.c |    4 ++--
 kernel/rcutorture.c |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

Index: linux-2.6/kernel/rcutorture.c
===================================================================
--- linux-2.6.orig/kernel/rcutorture.c	2009-06-04 14:26:42.000000000 -0500
+++ linux-2.6/kernel/rcutorture.c	2009-06-04 14:38:05.000000000 -0500
@@ -709,13 +709,13 @@ static void rcu_torture_timer(unsigned l
 		/* Should not happen, but... */
 		pipe_count = RCU_TORTURE_PIPE_LEN;
 	}
-	++__get_cpu_var(rcu_torture_count)[pipe_count];
+	__this_cpu_inc(per_cpu_var(rcu_torture_count)[pipe_count]);
 	completed = cur_ops->completed() - completed;
 	if (completed > RCU_TORTURE_PIPE_LEN) {
 		/* Should not happen, but... */
 		completed = RCU_TORTURE_PIPE_LEN;
 	}
-	++__get_cpu_var(rcu_torture_batch)[completed];
+	__this_cpu_inc(per_cpu_var(rcu_torture_batch)[completed]);
 	preempt_enable();
 	cur_ops->readunlock(idx);
 }
@@ -764,13 +764,13 @@ rcu_torture_reader(void *arg)
 			/* Should not happen, but... */
 			pipe_count = RCU_TORTURE_PIPE_LEN;
 		}
-		++__get_cpu_var(rcu_torture_count)[pipe_count];
+		__this_cpu_inc(per_cpu_var(rcu_torture_count)[pipe_count]);
 		completed = cur_ops->completed() - completed;
 		if (completed > RCU_TORTURE_PIPE_LEN) {
 			/* Should not happen, but... */
 			completed = RCU_TORTURE_PIPE_LEN;
 		}
-		++__get_cpu_var(rcu_torture_batch)[completed];
+		__this_cpu_inc(per_cpu_var(rcu_torture_batch)[completed]);
 		preempt_enable();
 		cur_ops->readunlock(idx);
 		schedule();
Index: linux-2.6/kernel/rcupreempt.c
===================================================================
--- linux-2.6.orig/kernel/rcupreempt.c	2009-06-04 14:28:53.000000000 -0500
+++ linux-2.6/kernel/rcupreempt.c	2009-06-04 14:39:35.000000000 -0500
@@ -173,7 +173,7 @@ void rcu_enter_nohz(void)
 	static DEFINE_RATELIMIT_STATE(rs, 10 * HZ, 1);
 
 	smp_mb(); /* CPUs seeing ++ must see prior RCU read-side crit sects */
-	__get_cpu_var(rcu_dyntick_sched).dynticks++;
+	__this_cpu_inc(per_cpu_var(rcu_dyntick_sched).dynticks);
 	WARN_ON_RATELIMIT(__get_cpu_var(rcu_dyntick_sched).dynticks & 0x1, &rs);
 }
 
@@ -181,7 +181,7 @@ void rcu_exit_nohz(void)
 {
 	static DEFINE_RATELIMIT_STATE(rs, 10 * HZ, 1);
 
-	__get_cpu_var(rcu_dyntick_sched).dynticks++;
+	__this_cpu_inc(per_cpu_var(rcu_dyntick_sched).dynticks);
 	smp_mb(); /* CPUs seeing ++ must see later RCU read-side crit sects */
 	WARN_ON_RATELIMIT(!(__get_cpu_var(rcu_dyntick_sched).dynticks & 0x1),
 				&rs);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
