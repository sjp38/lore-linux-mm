Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1F7A16B003D
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 23:00:57 -0400 (EDT)
Message-ID: <49CAFA83.1000005@tensilica.com>
Date: Wed, 25 Mar 2009 20:46:11 -0700
From: Piet Delaney <piet.delaney@tensilica.com>
MIME-Version: 1.0
Subject: [PATCH} - There appears  to be a minor race condition in sched.c
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, Johannes Weiner <jw@emlix.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Ingo, Peter:

There appears to be a minor race condition in sched.c where
you can get a division by zero. I suspect that it only shows
up when the kernel is compiled without optimization and the code
loads rq->nr_running from memory twice.

It's part of our SMP stabilization changes that I just posted to:

     git://git.kernel.org/pub/scm/linux/kernel/git/piet/xtensa-2.6.27-smp.git

I mentioned it to Johannes the other day and he suggested passing it on to you ASAP.

-------------------------------- Begin kernel/sched.c --------------------------------
index 9a1ddb8..607ee38 100644
@@ -1388,9 +1388,11 @@ static int task_hot(struct task_struct *p, u64 now, struct sched_domain *sd);
  static unsigned long cpu_avg_load_per_task(int cpu)
  {
         struct rq *rq = cpu_rq(cpu);
+       unsigned long nr_running = rq->nr_running;

-       if (rq->nr_running)
-               rq->avg_load_per_task = rq->load.weight / rq->nr_running;
+        /* Local copy of nr_running used to avoid a possible div by zero */
+       if (nr_running)
+               rq->avg_load_per_task = rq->load.weight / nr_running;

         return rq->avg_load_per_task;
  }
-------------------------------- End kernel/sched.c --------------------------------

-piet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
