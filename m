Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3290B6B0253
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 05:25:43 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so114418398wib.0
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 02:25:42 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id d3si9803596wiy.0.2015.08.09.02.25.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Aug 2015 02:25:41 -0700 (PDT)
Received: by wibhh20 with SMTP id hh20so114417907wib.0
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 02:25:40 -0700 (PDT)
Message-ID: <1439112337.5906.43.camel@gmail.com>
Subject: [hack] sched: create PREEMPT_VOLUNTARY_RT and some RT specific
 resched points
From: Mike Galbraith <umgwanakikbuti@gmail.com>
Date: Sun, 09 Aug 2015 11:25:37 +0200
In-Reply-To: <1438282521.6432.53.camel@gmail.com>
References: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
	 <20150724070420.GF4103@dhcp22.suse.cz>
	 <20150724165627.GA3458@Sligo.logfs.org>
	 <20150727070840.GB11317@dhcp22.suse.cz>
	 <20150727151814.GR9641@Sligo.logfs.org>
	 <20150728133254.GI24972@dhcp22.suse.cz>
	 <20150728170844.GY9641@Sligo.logfs.org>
	 <20150729095439.GD15801@dhcp22.suse.cz>
	 <1438269775.23663.58.camel@gmail.com>
	 <20150730165803.GA17882@Sligo.logfs.org>
	 <1438282521.6432.53.camel@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Cc: Michal Hocko <mhocko@kernel.org>, Spencer Baugh <sbaugh@catern.com>, Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Spencer Baugh <Spencer.baugh@purestorage.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, 2015-07-30 at 20:55 +0200, Mike Galbraith wrote:
> On Thu, 2015-07-30 at 09:58 -0700, JA?rn Engel wrote:
> > On Thu, Jul 30, 2015 at 05:22:55PM +0200, Mike Galbraith wrote:
> > > 
> > > I piddled about with the thought that it might be nice to be able to
> > > sprinkle cond_resched() about to cut rt latencies without wrecking
> > > normal load throughput, cobbled together a cond_resched_rt().
> > > 
> > > On my little box that was a waste of time, as the biggest hits are block
> > > softirq and free_hot_cold_page_list().
> > 
> > Block softirq is one of our problems as well.  It is a bit of a joke
> > that __do_softirq() moves work to ksoftirqd after 2ms, but block softirq
> > can take several 100ms in bad cases.
> > 
> > We could give individual softirqs a time budget.  If they exceed the
> > budget they should complete, but reassert themselves.  Not sure about
> > the rest, but that would be pretty simple to implement for block
> > softirq.
> 
> Yeah, it wants something, not sure what though.  Fix up every spot that
> hinders rt performance, you'll end up with PREEMPT_RT, and generic
> performance falls straight through the floor.  Darn.

So back to that cond_resched_rt() thingy...

The below isn't a cure all, isn't intended to be one, nor will it win
any beauty contests.  Happily, experiments only have produce interesting
results.  This one is simple, works better than I expected it to on my
little desktop box, and hypothetically speaking shouldn't wreck
throughput, so what the heck, let's see if anybody with casual use RT
latency woes wants to play with it...

Warranty: "You get to keep the pieces." 

...after reading the fine print.

Some numbers:

make clean;make -j8;sync;sudo killall cyclictest

master PREEMPT_NONE
cyclictest -Smp99
# /dev/cpu_dma_latency set to 0us
policy: fifo: loadavg: 6.76 7.00 3.95 2/353 15702           

T: 0 ( 3524) P:99 I:1000 C: 576934 Min:      1 Act:    4 Avg:    5 Max:    1650
T: 1 ( 3525) P:99 I:1500 C: 384683 Min:      1 Act:    1 Avg:    5 Max:    1386
T: 2 ( 3526) P:99 I:2000 C: 288512 Min:      1 Act:    1 Avg:    6 Max:    1463
T: 3 ( 3527) P:99 I:2500 C: 230809 Min:      1 Act:    1 Avg:    6 Max:    1459
T: 4 ( 3528) P:99 I:3000 C: 192340 Min:      1 Act:    1 Avg:    6 Max:    1381
T: 5 ( 3529) P:99 I:3500 C: 164863 Min:      1 Act:    1 Avg:    6 Max:    1970
T: 6 ( 3530) P:99 I:4000 C: 144254 Min:      1 Act:    1 Avg:    6 Max:    1389
T: 7 ( 3531) P:99 I:4500 C: 128226 Min:      1 Act:    1 Avg:    6 Max:    1360

master PREEMPT_VOLUNTARY_RT/COND_RESCHED_RT_ALL (PREEMPT_NONE for normal tasks)
cyclictest -Smp99
# /dev/cpu_dma_latency set to 0us
policy: fifo: loadavg: 7.44 7.30 4.07 1/355 15627           

T: 0 ( 3458) P:99 I:1000 C: 578181 Min:      1 Act:    1 Avg:    3 Max:      70
T: 1 ( 3459) P:99 I:1500 C: 385453 Min:      1 Act:    2 Avg:    4 Max:     109
T: 2 ( 3460) P:99 I:2000 C: 289089 Min:      1 Act:    1 Avg:    4 Max:      80
T: 3 ( 3461) P:99 I:2500 C: 231271 Min:      1 Act:    2 Avg:    4 Max:      55
T: 4 ( 3462) P:99 I:3000 C: 192725 Min:      1 Act:    8 Avg:    4 Max:     122
T: 5 ( 3463) P:99 I:3500 C: 165193 Min:      1 Act:    2 Avg:    4 Max:      58
T: 6 ( 3464) P:99 I:4000 C: 144543 Min:      1 Act:    1 Avg:    4 Max:     309
T: 7 ( 3465) P:99 I:4500 C: 128483 Min:      1 Act:    2 Avg:    4 Max:      66

master PREEMPT
cyclictest -Smp99
# /dev/cpu_dma_latency set to 0us
policy: fifo: loadavg: 6.57 7.13 4.07 2/356 15714           

T: 0 ( 3513) P:99 I:1000 C: 585356 Min:      1 Act:    1 Avg:    4 Max:     121
T: 1 ( 3514) P:99 I:1500 C: 390236 Min:      1 Act:    1 Avg:    4 Max:     119
T: 2 ( 3515) P:99 I:2000 C: 292676 Min:      1 Act:    1 Avg:    4 Max:     106
T: 3 ( 3516) P:99 I:2500 C: 234140 Min:      1 Act:    1 Avg:    4 Max:      85
T: 4 ( 3517) P:99 I:3000 C: 195116 Min:      1 Act:    2 Avg:    4 Max:      90
T: 5 ( 3518) P:99 I:3500 C: 167242 Min:      1 Act:    1 Avg:    4 Max:      76
T: 6 ( 3519) P:99 I:4000 C: 146336 Min:      1 Act:    1 Avg:    5 Max:     519
T: 7 ( 3520) P:99 I:4500 C: 130076 Min:      1 Act:    1 Avg:    4 Max:     136

/me adds git pulling repositories to the kbuild load...

master PREEMPT
# /dev/cpu_dma_latency set to 0us
policy: fifo: loadavg: 7.99 9.10 6.75 4/358 676              

T: 0 (15788) P:99 I:1000 C: 605208 Min:      1 Act:    2 Avg:    4 Max:     603
T: 1 (15789) P:99 I:1500 C: 403464 Min:      1 Act:    3 Avg:    4 Max:    1622
T: 2 (15790) P:99 I:2000 C: 302602 Min:      1 Act:    5 Avg:    4 Max:    1205
T: 3 (15791) P:99 I:2500 C: 242081 Min:      1 Act:    4 Avg:    4 Max:    1432
T: 4 (15792) P:99 I:3000 C: 201734 Min:      1 Act:    3 Avg:    5 Max:    1510
T: 5 (15793) P:99 I:3500 C: 172914 Min:      1 Act:    4 Avg:    4 Max:      75
T: 6 (15794) P:99 I:4000 C: 151299 Min:      1 Act:    4 Avg:    5 Max:    1474
T: 7 (15795) P:99 I:4500 C: 134488 Min:      1 Act:    4 Avg:    5 Max:      92

master PREEMPT_VOLUNTARY_RT/COND_RESCHED_RT_ALL
cyclictest -Smp99
# /dev/cpu_dma_latency set to 0us
policy: fifo: loadavg: 9.13 9.56 5.76 2/359 26297             

T: 0 ( 3671) P:99 I:1000 C: 788852 Min:      0 Act:    1 Avg:    3 Max:    1417
T: 1 ( 3672) P:99 I:1500 C: 525895 Min:      0 Act:    1 Avg:    3 Max:    2404
T: 2 ( 3673) P:99 I:2000 C: 394425 Min:      1 Act:    1 Avg:    3 Max:     313
T: 3 ( 3674) P:99 I:2500 C: 315540 Min:      0 Act:    1 Avg:    3 Max:     475
T: 4 ( 3675) P:99 I:3000 C: 262949 Min:      0 Act:    1 Avg:    4 Max:     155
T: 5 ( 3676) P:99 I:3500 C: 225385 Min:      0 Act:    2 Avg:    4 Max:     457
T: 6 ( 3677) P:99 I:4000 C: 197211 Min:      0 Act:    2 Avg:    3 Max:    2408
T: 7 ( 3678) P:99 I:4500 C: 175299 Min:      0 Act:    1 Avg:    4 Max:     767

master PREEMPT_NONE
# /dev/cpu_dma_latency set to 0us
policy: fifo: loadavg: 8.48 9.23 7.03 3/383 6748             

T: 0 (20952) P:99 I:1000 C: 608365 Min:      0 Act:    2 Avg:    6 Max:    2334
T: 1 (20953) P:99 I:1500 C: 405738 Min:      0 Act:    3 Avg:    6 Max:    1850
T: 2 (20954) P:99 I:2000 C: 304308 Min:      0 Act:   13 Avg:    7 Max:    2137
T: 3 (20955) P:99 I:2500 C: 243446 Min:      0 Act:    4 Avg:    6 Max:    2012
T: 4 (20956) P:99 I:3000 C: 202870 Min:      0 Act:    3 Avg:    6 Max:    2918
T: 5 (20957) P:99 I:3500 C: 173890 Min:      0 Act:    3 Avg:    6 Max:    1754
T: 6 (20958) P:99 I:4000 C: 152153 Min:      1 Act:    4 Avg:    7 Max:    1560
T: 7 (20959) P:99 I:4500 C: 135247 Min:      1 Act:    4 Avg:    6 Max:    2058


sched: create PREEMPT_VOLUNTARY_RT and some RT specific resched points

Steal might_resched() voluntary resched points, and apply them to
PREEMPT_NONE kernels only if an RT task is waiting, thus the name.
Add a few RT specific resched points, and get RT tasks to CPU a tad
sooner by breaking out of softirq processing loops.

Bend-spindle-mutilate-by: Mike Galbraith <umgwanakikbuti@gmail.com>
---
 block/blk-iopoll.c      |    4 ++-
 block/blk-softirq.c     |    8 ++++++
 drivers/md/dm-bufio.c   |    8 ++++++
 fs/dcache.c             |    4 ++-
 include/linux/kernel.h  |   22 ++++++++++++++++++-
 include/linux/sched.h   |   55 ++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/Kconfig.preempt  |   47 +++++++++++++++++++++++++++++++++++++++--
 kernel/rcu/tree.c       |    4 +++
 kernel/sched/core.c     |   19 ++++++++++++++++
 kernel/sched/deadline.c |    2 +
 kernel/sched/rt.c       |    2 +
 kernel/sched/sched.h    |   15 +++++++++++++
 kernel/softirq.c        |   38 ++++++++++++++++++++++++++++++++-
 kernel/trace/trace.c    |    2 -
 lib/ioremap.c           |    1 
 mm/memory.c             |   15 ++++++++++++-
 mm/page_alloc.c         |    1 
 mm/vmalloc.c            |    1 
 net/core/dev.c          |    7 ++++++
 19 files changed, 246 insertions(+), 9 deletions(-)

--- a/block/blk-iopoll.c
+++ b/block/blk-iopoll.c
@@ -79,6 +79,7 @@ static void blk_iopoll_softirq(struct so
 	struct list_head *list = this_cpu_ptr(&blk_cpu_iopoll);
 	int rearm = 0, budget = blk_iopoll_budget;
 	unsigned long start_time = jiffies;
+	u64 __maybe_unused timeout = 0;
 
 	local_irq_disable();
 
@@ -89,7 +90,8 @@ static void blk_iopoll_softirq(struct so
 		/*
 		 * If softirq window is exhausted then punt.
 		 */
-		if (budget <= 0 || time_after(jiffies, start_time)) {
+		if (budget <= 0 || time_after(jiffies, start_time) ||
+		    _need_resched_rt_delayed(&timeout, 100)) {
 			rearm = 1;
 			break;
 		}
--- a/block/blk-softirq.c
+++ b/block/blk-softirq.c
@@ -21,6 +21,7 @@ static DEFINE_PER_CPU(struct list_head,
 static void blk_done_softirq(struct softirq_action *h)
 {
 	struct list_head *cpu_list, local_list;
+	u64 __maybe_unused timeout = 0;
 
 	local_irq_disable();
 	cpu_list = this_cpu_ptr(&blk_cpu_done);
@@ -30,6 +31,13 @@ static void blk_done_softirq(struct soft
 	while (!list_empty(&local_list)) {
 		struct request *rq;
 
+		if (_need_resched_rt_delayed(&timeout, 100)) {
+			local_irq_disable();
+			list_splice(&local_list, cpu_list);
+			__raise_softirq_irqoff(BLOCK_SOFTIRQ);
+			local_irq_enable();
+			break;
+		}
 		rq = list_entry(local_list.next, struct request, ipi_list);
 		list_del_init(&rq->ipi_list);
 		rq->q->softirq_done_fn(rq);
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -188,12 +188,18 @@ static void dm_bufio_unlock(struct dm_bu
 /*
  * FIXME Move to sched.h?
  */
-#ifdef CONFIG_PREEMPT_VOLUNTARY
+#if defined(CONFIG_PREEMPT_VOLUNTARY)
 #  define dm_bufio_cond_resched()		\
 do {						\
 	if (unlikely(need_resched()))		\
 		_cond_resched();		\
 } while (0)
+#elif defined(CONFIG_PREEMPT_VOLUNTARY_RT)
+#  define dm_bufio_cond_resched()		\
+do {						\
+	if (unlikely(need_resched()))		\
+		_cond_resched_rt();		\
+} while (0)
 #else
 #  define dm_bufio_cond_resched()                do { } while (0)
 #endif
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -311,7 +311,7 @@ static void dentry_free(struct dentry *d
 		struct external_name *p = external_name(dentry);
 		if (likely(atomic_dec_and_test(&p->u.count))) {
 			call_rcu(&dentry->d_u.d_rcu, __d_free_external);
-			return;
+			goto out;
 		}
 	}
 	/* if dentry was never visible to RCU, immediate free is OK */
@@ -319,6 +319,8 @@ static void dentry_free(struct dentry *d
 		__d_free(&dentry->d_u.d_rcu);
 	else
 		call_rcu(&dentry->d_u.d_rcu, __d_free);
+out:
+	cond_resched_rt();
 }
 
 /**
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -166,11 +166,28 @@ struct completion;
 struct pt_regs;
 struct user;
 
-#ifdef CONFIG_PREEMPT_VOLUNTARY
+/*
+ * PREEMPT_VOLUNTARY receives might_sleep() annotated reschedule points.
+ * PREEMPT_VOLUNTARY_RT receives might_sleep() and might_sleep_rt(), but
+ * both reschedule only when an RT task wants the CPU.
+ * PREEMPT_VOLUNTARY + COND_RESCHED_RT receives normal might_sleep() plus
+ * RT specific might_sleep_rt().
+ */
+#if (defined(CONFIG_PREEMPT_VOLUNTARY) && !defined(CONFIG_COND_RESCHED_RT))
+extern int _cond_resched(void);
+# define might_resched() _cond_resched()
+#elif defined(CONFIG_PREEMPT_VOLUNTARY_RT)
+extern int _cond_resched_rt(void);
+# define might_resched() _cond_resched_rt()
+# define might_resched_rt() _cond_resched_rt()
+#elif defined(CONFIG_COND_RESCHED_RT)
 extern int _cond_resched(void);
+extern int _cond_resched_rt(void);
 # define might_resched() _cond_resched()
+# define might_resched_rt() _cond_resched_rt()
 #else
 # define might_resched() do { } while (0)
+# define might_resched_rt() do { } while (0)
 #endif
 
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
@@ -188,6 +205,8 @@ extern int _cond_resched(void);
  */
 # define might_sleep() \
 	do { __might_sleep(__FILE__, __LINE__, 0); might_resched(); } while (0)
+# define might_sleep_rt() \
+	do { __might_sleep(__FILE__, __LINE__, 0); might_resched_rt(); } while (0)
 # define sched_annotate_sleep()	(current->task_state_change = 0)
 #else
   static inline void ___might_sleep(const char *file, int line,
@@ -195,6 +214,7 @@ extern int _cond_resched(void);
   static inline void __might_sleep(const char *file, int line,
 				   int preempt_offset) { }
 # define might_sleep() do { might_resched(); } while (0)
+# define might_sleep_rt() do { might_resched_rt(); } while (0)
 # define sched_annotate_sleep() do { } while (0)
 #endif
 
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -3014,6 +3014,61 @@ static __always_inline bool need_resched
 	return unlikely(tif_need_resched());
 }
 
+#ifdef CONFIG_COND_RESCHED_RT
+DECLARE_PER_CPU(unsigned int, sched_rt_queued);
+extern int _cond_resched_rt(void);
+extern int _cond_resched_softirq_rt(void);
+
+static inline bool sched_rt_active(void)
+{
+	/* Yes, take a racy oportunistic peek */
+	return raw_cpu_read(sched_rt_queued) != 0;
+}
+
+static inline bool _need_resched_rt(void)
+{
+	return need_resched() && sched_rt_active();
+}
+
+static inline bool _need_resched_rt_delayed(u64 *timeout, unsigned int usecs)
+{
+	if (!*timeout) {
+		*timeout = local_clock() + usecs * 1000UL;
+		return false;
+	}
+	return _need_resched_rt() && local_clock() > *timeout;
+}
+
+#ifdef CONFIG_COND_RESCHED_RT_ALL
+/*
+ * These two are for use in sometimes preemptible context,
+ * therefore require and select CONFIG_PREEMPT_COUNT.
+ */
+static inline bool need_resched_rt(void)
+{
+	return _need_resched_rt() && !in_atomic();
+}
+
+static inline int cond_resched_rt(void)
+{
+	return need_resched_rt() && _cond_resched_rt();
+}
+#else /* !CONFIG_COND_RESCHED_RT_ALL */
+static inline bool need_resched_rt(void) { return false; }
+static inline int cond_resched_rt(void) { return 0; }
+#endif /* CONFIG_COND_RESCHED_RT_ALL */
+#else /* !CONFIG_COND_RESCHED_RT */
+static inline bool sched_rt_active(void) { return false; }
+static inline bool _need_resched_rt(void) { return false; }
+static inline bool _need_resched_rt_delayed(u64 *timeout, unsigned int usecs)
+{
+	return false;
+}
+static inline bool need_resched_rt(void) { return false; }
+static inline int _cond_resched_rt(void) { return 0; }
+static inline int cond_resched_rt(void) { return 0; }
+#endif /* CONFIG_COND_RESCHED_RT */
+
 /*
  * Thread group CPU time accounting.
  */
--- a/kernel/Kconfig.preempt
+++ b/kernel/Kconfig.preempt
@@ -1,4 +1,3 @@
-
 choice
 	prompt "Preemption Model"
 	default PREEMPT_NONE
@@ -16,6 +15,22 @@ config PREEMPT_NONE
 	  raw processing power of the kernel, irrespective of scheduling
 	  latencies.
 
+config PREEMPT_VOLUNTARY_RT
+	bool "Voluntary Kernel Preemption for RT tasks only (Server)"
+	select COND_RESCHED_RT
+	help
+	  This option reduces the RT latency of the kernel by adding more
+	  "explicit preemption points" to the kernel code. These new
+	  preemption points have been selected to reduce the maximum
+	  latency of rescheduling, providing faster application reactions,
+	  at the cost of slightly lower throughput.
+
+	  This allows reaction to realtime events by allowing a
+	  low priority process to voluntarily preempt itself even if it
+	  is in kernel mode executing a system call. This allows
+	  RT applications to run more 'smoothly' even when the system is
+	  under load.
+
 config PREEMPT_VOLUNTARY
 	bool "Voluntary Kernel Preemption (Desktop)"
 	help
@@ -54,5 +69,33 @@ config PREEMPT
 
 endchoice
 
+if PREEMPT_VOLUNTARY || PREEMPT_VOLUNTARY_RT
+
+menu "Voluntary preemption extensions"
+
+config COND_RESCHED_RT
+	bool "Enable RT specific preemption points"
+	default n
+	help
+	  This option further reduces RT scheduling latencies by adding
+	  more "explicit preemption points" for RT tasks only.
+
+
+config COND_RESCHED_RT_ALL
+	bool "Enable PREEMPT_COUNT dependent RT preemption points"
+	depends on COND_RESCHED_RT
+	select PREEMPT_COUNT
+	select DEBUG_ATOMIC_SLEEP
+	help
+	  This option further reduces RT scheduling latency by adding
+	  more "explicit preemption points", in code which may or may
+	  not be called in a preemptible context, thus we must enable
+	  PREEMPT_COUNT to make such contexts visible. Note that this
+	  option adds some overhead to kernel locking primitives.
+
+endmenu
+
+endif
+
 config PREEMPT_COUNT
-       bool
\ No newline at end of file
+       bool
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -2617,6 +2617,7 @@ static void rcu_do_batch(struct rcu_stat
 	unsigned long flags;
 	struct rcu_head *next, *list, **tail;
 	long bl, count, count_lazy;
+	u64 __maybe_unused timeout = 0;
 	int i;
 
 	/* If no callbacks are ready, just return. */
@@ -2648,6 +2649,9 @@ static void rcu_do_batch(struct rcu_stat
 	/* Invoke callbacks. */
 	count = count_lazy = 0;
 	while (list) {
+		/* Budget 100us per flavor and hope for the best */
+		if (_need_resched_rt_delayed(&timeout, 100))
+			break;
 		next = list->next;
 		prefetch(next);
 		debug_rcu_head_unqueue(list);
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4551,6 +4551,25 @@ int __sched __cond_resched_softirq(void)
 }
 EXPORT_SYMBOL(__cond_resched_softirq);
 
+#ifdef CONFIG_COND_RESCHED_RT
+DEFINE_PER_CPU(unsigned int, sched_rt_queued);
+
+int __sched _cond_resched_rt(void)
+{
+	if (!_need_resched_rt() || !should_resched(0))
+		return 0;
+
+	do {
+		preempt_active_enter();
+		__schedule();
+		preempt_active_exit();
+	} while (_need_resched_rt());
+
+	return 1;
+}
+EXPORT_SYMBOL(_cond_resched_rt);
+#endif
+
 /**
  * yield - yield the current processor to other threads.
  *
--- a/kernel/sched/deadline.c
+++ b/kernel/sched/deadline.c
@@ -984,12 +984,14 @@ static void enqueue_task_dl(struct rq *r
 
 	if (!task_current(rq, p) && p->nr_cpus_allowed > 1)
 		enqueue_pushable_dl_task(rq, p);
+	sched_rt_active_inc();
 }
 
 static void __dequeue_task_dl(struct rq *rq, struct task_struct *p, int flags)
 {
 	dequeue_dl_entity(&p->dl);
 	dequeue_pushable_dl_task(rq, p);
+	sched_rt_active_dec();
 }
 
 static void dequeue_task_dl(struct rq *rq, struct task_struct *p, int flags)
--- a/kernel/sched/rt.c
+++ b/kernel/sched/rt.c
@@ -1274,6 +1274,7 @@ enqueue_task_rt(struct rq *rq, struct ta
 
 	if (!task_current(rq, p) && p->nr_cpus_allowed > 1)
 		enqueue_pushable_task(rq, p);
+	sched_rt_active_inc();
 }
 
 static void dequeue_task_rt(struct rq *rq, struct task_struct *p, int flags)
@@ -1284,6 +1285,7 @@ static void dequeue_task_rt(struct rq *r
 	dequeue_rt_entity(rt_se);
 
 	dequeue_pushable_task(rq, p);
+	sched_rt_active_dec();
 }
 
 /*
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -1770,3 +1770,18 @@ static inline u64 irq_time_read(int cpu)
 }
 #endif /* CONFIG_64BIT */
 #endif /* CONFIG_IRQ_TIME_ACCOUNTING */
+
+#ifdef CONFIG_COND_RESCHED_RT
+static inline void sched_rt_active_inc(void)
+{
+	__this_cpu_inc(sched_rt_queued);
+}
+
+static inline void sched_rt_active_dec(void)
+{
+	__this_cpu_dec(sched_rt_queued);
+}
+#else
+static inline void sched_rt_active_inc(void) { }
+static inline void sched_rt_active_dec(void) { }
+#endif
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -280,6 +280,8 @@ asmlinkage __visible void __do_softirq(v
 		}
 		h++;
 		pending >>= softirq_bit;
+		if (need_resched_rt() && current != this_cpu_ksoftirqd())
+			break;
 	}
 
 	rcu_bh_qs();
@@ -299,6 +301,12 @@ asmlinkage __visible void __do_softirq(v
 	__local_bh_enable(SOFTIRQ_OFFSET);
 	WARN_ON_ONCE(in_interrupt());
 	tsk_restore_flags(current, old_flags, PF_MEMALLOC);
+
+	if (need_resched_rt() && current != this_cpu_ksoftirqd()) {
+		local_irq_enable();
+		_cond_resched_rt();
+		local_irq_disable();
+	}
 }
 
 asmlinkage __visible void do_softirq(void)
@@ -340,7 +348,7 @@ void irq_enter(void)
 
 static inline void invoke_softirq(void)
 {
-	if (!force_irqthreads) {
+	if (!force_irqthreads && !sched_rt_active()) {
 #ifdef CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK
 		/*
 		 * We can safely execute softirq on the current stack if
@@ -485,6 +493,7 @@ EXPORT_SYMBOL(__tasklet_hi_schedule_firs
 static void tasklet_action(struct softirq_action *a)
 {
 	struct tasklet_struct *list;
+	u64 __maybe_unused timeout = 0;
 
 	local_irq_disable();
 	list = __this_cpu_read(tasklet_vec.head);
@@ -495,6 +504,19 @@ static void tasklet_action(struct softir
 	while (list) {
 		struct tasklet_struct *t = list;
 
+		if (t &&  _need_resched_rt_delayed(&timeout, 100)) {
+			local_irq_disable();
+			while (list->next)
+				list = list->next;
+			list->next = __this_cpu_read(tasklet_vec.head);
+			__this_cpu_write(tasklet_vec.head, t);
+			if (!__this_cpu_read(tasklet_vec.tail))
+				__this_cpu_write(tasklet_vec.tail, &(list->next));
+			__raise_softirq_irqoff(TASKLET_SOFTIRQ);
+			local_irq_enable();
+			return;
+		}
+
 		list = list->next;
 
 		if (tasklet_trylock(t)) {
@@ -521,6 +543,7 @@ static void tasklet_action(struct softir
 static void tasklet_hi_action(struct softirq_action *a)
 {
 	struct tasklet_struct *list;
+	u64 __maybe_unused timeout = 0;
 
 	local_irq_disable();
 	list = __this_cpu_read(tasklet_hi_vec.head);
@@ -531,6 +554,19 @@ static void tasklet_hi_action(struct sof
 	while (list) {
 		struct tasklet_struct *t = list;
 
+		if (t &&  _need_resched_rt_delayed(&timeout, 100)) {
+			local_irq_disable();
+			while (list->next)
+				list = list->next;
+			list->next = __this_cpu_read(tasklet_hi_vec.head);
+			__this_cpu_write(tasklet_hi_vec.head, t);
+			if (!__this_cpu_read(tasklet_hi_vec.tail))
+				__this_cpu_write(tasklet_hi_vec.tail, &(list->next));
+			__raise_softirq_irqoff(HI_SOFTIRQ);
+			local_irq_enable();
+			return;
+		}
+
 		list = list->next;
 
 		if (tasklet_trylock(t)) {
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2624,7 +2624,7 @@ print_trace_header(struct seq_file *m, s
 		   entries,
 		   total,
 		   buf->cpu,
-#if defined(CONFIG_PREEMPT_NONE)
+#if defined(CONFIG_PREEMPT_NONE) || defined(CONFIG_PREEMPT_VOLUNTARY_RT)
 		   "server",
 #elif defined(CONFIG_PREEMPT_VOLUNTARY)
 		   "desktop",
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -90,6 +90,7 @@ static inline int ioremap_pmd_range(pud_
 
 		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
 			return -ENOMEM;
+		might_sleep_rt();
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1075,7 +1075,7 @@ static unsigned long zap_pte_range(struc
 				struct zap_details *details)
 {
 	struct mm_struct *mm = tlb->mm;
-	int force_flush = 0;
+	int force_flush = 0, resched_rt = 0;
 	int rss[NR_MM_COUNTERS];
 	spinlock_t *ptl;
 	pte_t *start_pte;
@@ -1132,6 +1132,10 @@ static unsigned long zap_pte_range(struc
 				addr += PAGE_SIZE;
 				break;
 			}
+			if (_need_resched_rt()) {
+				resched_rt = 1;
+				break;
+			}
 			continue;
 		}
 		/* If details->check_mapping, we leave swap entries. */
@@ -1178,6 +1182,14 @@ static unsigned long zap_pte_range(struc
 			goto again;
 	}
 
+	if (resched_rt) {
+		resched_rt = 0;
+		might_sleep_rt();
+
+		if (addr != end)
+			goto again;
+	}
+
 	return addr;
 }
 
@@ -1656,6 +1668,7 @@ static inline int remap_pmd_range(struct
 		if (remap_pte_range(mm, pmd, addr, next,
 				pfn + (addr >> PAGE_SHIFT), prot))
 			return -ENOMEM;
+		might_sleep_rt();
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1934,6 +1934,7 @@ void free_hot_cold_page_list(struct list
 	list_for_each_entry_safe(page, next, list, lru) {
 		trace_mm_page_free_batched(page, cold);
 		free_hot_cold_page(page, cold);
+		cond_resched_rt();
 	}
 }
 
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -80,6 +80,7 @@ static void vunmap_pmd_range(pud_t *pud,
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		vunmap_pte_range(pmd, addr, next);
+		might_sleep_rt();
 	} while (pmd++, addr = next, addr != end);
 }
 
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3549,6 +3549,7 @@ int netif_rx_ni(struct sk_buff *skb)
 	if (local_softirq_pending())
 		do_softirq();
 	preempt_enable();
+	cond_resched_rt();
 
 	return err;
 }
@@ -4787,6 +4788,7 @@ static void net_rx_action(struct softirq
 {
 	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	unsigned long time_limit = jiffies + 2;
+	u64 __maybe_unused timeout = 0;
 	int budget = netdev_budget;
 	LIST_HEAD(list);
 	LIST_HEAD(repoll);
@@ -4804,6 +4806,11 @@ static void net_rx_action(struct softirq
 			break;
 		}
 
+		if (unlikely(_need_resched_rt_delayed(&timeout, 100))) {
+			sd->time_squeeze++;
+			break;
+		}
+
 		n = list_first_entry(&list, struct napi_struct, poll_list);
 		budget -= napi_poll(n, &repoll);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
