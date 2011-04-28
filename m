Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 22D2D6B0022
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:23:17 -0400 (EDT)
Date: Thu, 28 Apr 2011 22:23:01 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110428222301.0b745a0a@neptune.home>
In-Reply-To: <alpine.LFD.2.02.1104282044120.3005@ionos>
References: <20110426112756.GF4308@linux.vnet.ibm.com>
	<20110426183859.6ff6279b@neptune.home>
	<20110426190918.01660ccf@neptune.home>
	<BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
	<alpine.LFD.2.02.1104262314110.3323@ionos>
	<20110427081501.5ba28155@pluto.restena.lu>
	<20110427204139.1b0ea23b@neptune.home>
	<alpine.LFD.2.02.1104272351290.3323@ionos>
	<alpine.LFD.2.02.1104281051090.19095@ionos>
	<BANLkTinB5S7q88dch78i-h28jDHx5dvfQw@mail.gmail.com>
	<20110428102609.GJ2135@linux.vnet.ibm.com>
	<1303997401.7819.5.camel@marge.simson.net>
	<BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com>
	<alpine.LFD.2.02.1104282044120.3005@ionos>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/tLAgSp4G09kmuF7p.zJ/tEu"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: sedat.dilek@gmail.com, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

--MP_/tLAgSp4G09kmuF7p.zJ/tEu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thu, 28 April 2011 Thomas Gleixner <tglx@linutronix.de> wrote:
> On Thu, 28 Apr 2011, Sedat Dilek wrote:
> > On Thu, Apr 28, 2011 at 3:30 PM, Mike Galbraith <efault@gmx.de> wrote:
> > rt_rq[0]:
> >   .rt_nr_running                 : 0
> >   .rt_throttled                  : 0
> 
> >   .rt_time                       : 888.893877
> 
> >   .rt_time                       : 950.005460
> 
> So rt_time is constantly accumulated, but never decreased. The
> decrease happens in the timer callback. Looks like the timer is not
> running for whatever reason.
> 
> Can you add the following patch as well ?
> 
> Thanks,
> 
> 	tglx
> 
> --- linux-2.6.orig/kernel/sched.c
> +++ linux-2.6/kernel/sched.c
> @@ -172,7 +172,7 @@ static enum hrtimer_restart sched_rt_per
>  		idle = do_sched_rt_period_timer(rt_b, overrun);
>  	}
>  
> -	return idle ? HRTIMER_NORESTART : HRTIMER_RESTART;
> +	return HRTIMER_RESTART;

This doesn't help here.
Be it applied on top of the others, full diff attached
or applied alone (with throttling printk).

Could it be that NO_HZ=y has some importance in this matter?


Extended throttling printk (Linus asked what exact values were looking
like):
[  401.000119] sched: RT throttling activated 950012539 > 950000000


Equivalent to what Sedat sees (/proc/sched_debug):
rt_rq[0]:
  .rt_nr_running                 : 2
  .rt_throttled                  : 1
  .rt_time                       : 950.012539
  .rt_runtime                    : 950.000000


/proc/$(pidof rcu_kthread)/sched captured at regular intervals:
Thu Apr 28 21:33:41 CEST 2011
rcu_kthread (6, #threads: 1)
---------------------------------------------------------
se.exec_start                      :             0.000000
se.vruntime                        :             0.000703
se.sum_exec_runtime                :           903.067982
nr_switches                        :                23752
nr_voluntary_switches              :                23751
nr_involuntary_switches            :                    1
se.load.weight                     :                 1024
policy                             :                    1
prio                               :                   98
clock-delta                        :                  912
Thu Apr 28 21:34:11 CEST 2011
rcu_kthread (6, #threads: 1)
---------------------------------------------------------
se.exec_start                      :             0.000000
se.vruntime                        :             0.000703
se.sum_exec_runtime                :           974.899495
nr_switches                        :                25721
nr_voluntary_switches              :                25720
nr_involuntary_switches            :                    1
se.load.weight                     :                 1024
policy                             :                    1
prio                               :                   98
clock-delta                        :                 1098
Thu Apr 28 21:34:41 CEST 2011
rcu_kthread (6, #threads: 1)
---------------------------------------------------------
se.exec_start                      :             0.000000
se.vruntime                        :             0.000703
se.sum_exec_runtime                :           974.899495
nr_switches                        :                25721
nr_voluntary_switches              :                25720
nr_involuntary_switches            :                    1
se.load.weight                     :                 1024
policy                             :                    1
prio                               :                   98
clock-delta                        :                 1126
Thu Apr 28 21:35:11 CEST 2011
rcu_kthread (6, #threads: 1)



>  }
>  
>  static

--MP_/tLAgSp4G09kmuF7p.zJ/tEu
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=sched_rt.diff

diff --git a/kernel/sched.c b/kernel/sched.c
index 312f8b9..aad1b88 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -172,7 +172,7 @@ static enum hrtimer_restart sched_rt_period_timer(struct hrtimer *timer)
 		idle = do_sched_rt_period_timer(rt_b, overrun);
 	}
 
-	return idle ? HRTIMER_NORESTART : HRTIMER_RESTART;
+	return /* idle ? HRTIMER_NORESTART : */ HRTIMER_RESTART;
 }
 
 static
@@ -460,7 +460,7 @@ struct rq {
 	u64 nohz_stamp;
 	unsigned char nohz_balance_kick;
 #endif
-	unsigned int skip_clock_update;
+	int skip_clock_update;
 
 	/* capture load from *all* tasks on this cpu: */
 	struct load_weight load;
@@ -642,8 +642,8 @@ static void update_rq_clock(struct rq *rq)
 {
 	s64 delta;
 
-	if (rq->skip_clock_update)
-		return;
+/*	if (rq->skip_clock_update > 0)
+		return; */
 
 	delta = sched_clock_cpu(cpu_of(rq)) - rq->clock;
 	rq->clock += delta;
@@ -4035,7 +4035,7 @@ static inline void schedule_debug(struct task_struct *prev)
 
 static void put_prev_task(struct rq *rq, struct task_struct *prev)
 {
-	if (prev->se.on_rq)
+	if (prev->se.on_rq || rq->skip_clock_update < 0)
 		update_rq_clock(rq);
 	prev->sched_class->put_prev_task(rq, prev);
 }
diff --git a/kernel/sched_rt.c b/kernel/sched_rt.c
index e7cebdc..2feae93 100644
--- a/kernel/sched_rt.c
+++ b/kernel/sched_rt.c
@@ -572,8 +572,15 @@ static int do_sched_rt_period_timer(struct rt_bandwidth *rt_b, int overrun)
 				enqueue = 1;
 		}
 
-		if (enqueue)
+		if (enqueue) {
+			/*
+			 * Tag a forced clock update if we're coming out of idle
+			 * so rq->clock_task will be updated when we schedule().
+			 */
+			if (rq->curr == rq->idle)
+				rq->skip_clock_update = -1;
 			sched_rt_rq_enqueue(rt_rq);
+		}
 		raw_spin_unlock(&rq->lock);
 	}
 
@@ -608,6 +615,7 @@ static int sched_rt_runtime_exceeded(struct rt_rq *rt_rq)
 		return 0;
 
 	if (rt_rq->rt_time > runtime) {
+		printk_once(KERN_WARNING "sched: RT throttling activated %llu > %llu\n", rt_rq->rt_time, runtime);
 		rt_rq->rt_throttled = 1;
 		if (rt_rq_throttled(rt_rq)) {
 			sched_rt_rq_dequeue(rt_rq);

--MP_/tLAgSp4G09kmuF7p.zJ/tEu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
