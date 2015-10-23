Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 603706B0257
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 10:12:51 -0400 (EDT)
Received: by obbwb3 with SMTP id wb3so94748315obb.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 07:12:51 -0700 (PDT)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id kz3si12348696oeb.64.2015.10.23.07.12.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 23 Oct 2015 07:12:50 -0700 (PDT)
Date: Fri, 23 Oct 2015 09:12:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Make vmstat deferrable again (was Re: [PATCH] mm,vmscan: Use
 accurate values for zone_reclaimable() checks)
In-Reply-To: <20151023120728.GA462@swordfish>
Message-ID: <alpine.DEB.2.20.1510230910370.12801@east.gentwo.org>
References: <20151021145505.GE8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org> <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org> <20151022140944.GA30579@mtj.duckdns.org>
 <20151022150623.GE26854@dhcp22.suse.cz> <20151022151528.GG30579@mtj.duckdns.org> <alpine.DEB.2.20.1510221031090.24250@east.gentwo.org> <20151023083719.GD2410@dhcp22.suse.cz> <alpine.DEB.2.20.1510230642210.5612@east.gentwo.org>
 <20151023120728.GA462@swordfish>
Content-Type: multipart/mixed; BOUNDARY="8323329-1975020026-1445609567=:12801"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1975020026-1445609567=:12801
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Fri, 23 Oct 2015, Sergey Senozhatsky wrote:

> On (10/23/15 06:43), Christoph Lameter wrote:
> > Is this ok?
>
> kernel/sched/loadavg.c: In function a??calc_load_enter_idlea??:
> kernel/sched/loadavg.c:195:2: error: implicit declaration of function a??quiet_vmstata?? [-Werror=implicit-function-declaration]
>   quiet_vmstat();
>     ^

Oww... Not good to do that in the scheduler. Ok new patch follows that
does the call from tick_nohz_stop_sched_tick. Hopefully that is the right
location to call quiet_vmstat().

> > +		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
> > +			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
>
> shouldn't preemption be disable for smp_processor_id() here?

Preemption is disabled when quiet_vmstat() is called.



Subject: Fix vmstat: make vmstat_updater deferrable again and shut down on idle V2

V1->V2
 - Call vmstat_quiet from tick_nohz_stop_sched_tick() instead.

Currently the vmstat updater is not deferrable as a result of commit
ba4877b9ca51f80b5d30f304a46762f0509e1635. This in turn can cause multiple
interruptions of the applications because the vmstat updater may run at
different times than tick processing. No good.

Make vmstate_update deferrable again and provide a function that
shuts down the vmstat updater when we go idle by folding the differentials.
Shut it down from the load average calculation logic introduced by nohz.

Note that the shepherd thread will continue scanning the differentials
from another processor and will reenable the vmstat workers if it
detects any changes.

Fixes: ba4877b9ca51f80b5d30f304a46762f0509e1635 (do not use deferrable delay)
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c
+++ linux/mm/vmstat.c
@@ -1395,6 +1395,20 @@ static void vmstat_update(struct work_st
 }

 /*
+ * Switch off vmstat processing and then fold all the remaining differentials
+ * until the diffs stay at zero. The function is used by NOHZ and can only be
+ * invoked when tick processing is not active.
+ */
+void quiet_vmstat(void)
+{
+	do {
+		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
+			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
+
+	} while (refresh_cpu_vm_stats());
+}
+
+/*
  * Check if the diffs for a certain cpu indicate that
  * an update is needed.
  */
@@ -1426,7 +1440,7 @@ static bool need_update(int cpu)
  */
 static void vmstat_shepherd(struct work_struct *w);

-static DECLARE_DELAYED_WORK(shepherd, vmstat_shepherd);
+static DECLARE_DEFERRABLE_WORK(shepherd, vmstat_shepherd);

 static void vmstat_shepherd(struct work_struct *w)
 {
Index: linux/include/linux/vmstat.h
===================================================================
--- linux.orig/include/linux/vmstat.h
+++ linux/include/linux/vmstat.h
@@ -211,6 +211,7 @@ extern void __inc_zone_state(struct zone
 extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);

+void quiet_vmstat(void);
 void cpu_vm_stats_fold(int cpu);
 void refresh_zone_stat_thresholds(void);

@@ -272,6 +273,7 @@ static inline void __dec_zone_page_state
 static inline void refresh_cpu_vm_stats(int cpu) { }
 static inline void refresh_zone_stat_thresholds(void) { }
 static inline void cpu_vm_stats_fold(int cpu) { }
+static inline void quiet_vmstat(void) { }

 static inline void drain_zonestat(struct zone *zone,
 			struct per_cpu_pageset *pset) { }
Index: linux/kernel/time/tick-sched.c
===================================================================
--- linux.orig/kernel/time/tick-sched.c
+++ linux/kernel/time/tick-sched.c
@@ -667,6 +667,7 @@ static ktime_t tick_nohz_stop_sched_tick
 	 */
 	if (!ts->tick_stopped) {
 		nohz_balance_enter_idle(cpu);
+		quiet_vmstat();
 		calc_load_enter_idle();

 		ts->last_tick = hrtimer_get_expires(&ts->sched_timer);
--8323329-1975020026-1445609567=:12801--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
