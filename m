Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 43601600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 13:49:03 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B0D1682C5C9
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 14:36:21 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ot3FUqmk5BLc for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 14:36:17 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3126382C615
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 14:36:14 -0400 (EDT)
Message-Id: <20091001174121.651756642@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:44 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 11/19] RCU: Use this_cpu operations
Content-Disposition: inline; filename=this_cpu_rcu
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

RCU does not do dynamic allocations but it increments per cpu variables
a lot. These instructions results in a move to a register and then back
to memory. This patch will make it use the inc/dec instructions on x86
that do not need a register.

Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 kernel/rcutorture.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/kernel/rcutorture.c
===================================================================
--- linux-2.6.orig/kernel/rcutorture.c	2009-09-28 10:08:10.000000000 -0500
+++ linux-2.6/kernel/rcutorture.c	2009-09-29 09:02:00.000000000 -0500
@@ -731,13 +731,13 @@ static void rcu_torture_timer(unsigned l
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
@@ -786,13 +786,13 @@ rcu_torture_reader(void *arg)
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

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
