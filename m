Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB526B0055
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 03:35:01 -0400 (EDT)
Message-ID: <4A39EE89.8030009@kernel.org>
Date: Thu, 18 Jun 2009 16:36:41 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: [PATCH 5/9 UPDATED] percpu: clean up percpu variable definitions
References: <1245210060-24344-1-git-send-email-tj@kernel.org> <1245210060-24344-6-git-send-email-tj@kernel.org>
In-Reply-To: <1245210060-24344-6-git-send-email-tj@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@elte.hu, kyle@mcmartin.ca, cl@linux-foundation.org, Jesper.Nilsson@axis.com, benh@kernel.crashing.org, paulmck@linux.vnet.ibm.com
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Jens Axboe <jens.axboe@oracle.com>, Dave Jones <davej@redhat.com>, Jeremy Fitzhardinge <jeremy@xensource.com>, linux-mm <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizf@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>
List-ID: <linux-mm.kvack.org>

Percpu variable definition is about to be updated such that no static
declaration is allowed.  Update percpu variable definitions
accordingly.

* as,cfq: rename ioc_count uniquely

* cpufreq: rename cpu_dbs_info uniquely

* xen: move nesting_count out of xen_evtchn_do_upcall() and rename it

* mm: move ratelimits out of balance_dirty_pages_ratelimited_nr() and
  rename it

* ipv4,6: rename cookie_scratch uniquely

* x86 pref_counter: rename prev_left to pmc_prev_left, irq_entry to
  pmc_irq_entry and nmi_entry to pmc_nmi_entry

* perf_counter: rename disable_count to perf_disable_count

* ftrace: rename test_event_disable to ftrace_test_event_disable

* kmemleak: rename test_pointer to kmemleak_test_pointer

[ Impact: percpu usage cleanups, no duplicate static percpu var names ]

Signed-off-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Jens Axboe <jens.axboe@oracle.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Jeremy Fitzhardinge <jeremy@xensource.com>
Cc: linux-mm <linux-mm@kvack.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Steven Rostedt <srostedt@redhat.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
---
Updates for newly added percpu variables in perf_counter, kmemleak and
ftrace added.  Note that these changes were accidentally put in the
next patch in the original posting.  The end result remains the same.

 arch/x86/kernel/cpu/perf_counter.c     |   14 +++++++-------
 block/as-iosched.c                     |   10 +++++-----
 block/cfq-iosched.c                    |   10 +++++-----
 drivers/cpufreq/cpufreq_conservative.c |   12 ++++++------
 drivers/cpufreq/cpufreq_ondemand.c     |   15 ++++++++-------
 drivers/xen/events.c                   |    9 +++++----
 kernel/perf_counter.c                  |    6 +++---
 kernel/trace/trace_events.c            |    6 +++---
 mm/kmemleak-test.c                     |    6 +++---
 mm/page-writeback.c                    |    5 +++--
 net/ipv4/syncookies.c                  |    5 +++--
 net/ipv6/syncookies.c                  |    5 +++--
 12 files changed, 54 insertions(+), 49 deletions(-)

Index: work/block/as-iosched.c
===================================================================
--- work.orig/block/as-iosched.c
+++ work/block/as-iosched.c
@@ -146,7 +146,7 @@ enum arq_state {
 #define RQ_STATE(rq)	((enum arq_state)(rq)->elevator_private2)
 #define RQ_SET_STATE(rq, state)	((rq)->elevator_private2 = (void *) state)
 
-static DEFINE_PER_CPU(unsigned long, ioc_count);
+static DEFINE_PER_CPU(unsigned long, as_ioc_count);
 static struct completion *ioc_gone;
 static DEFINE_SPINLOCK(ioc_gone_lock);
 
@@ -161,7 +161,7 @@ static void as_antic_stop(struct as_data
 static void free_as_io_context(struct as_io_context *aic)
 {
 	kfree(aic);
-	elv_ioc_count_dec(ioc_count);
+	elv_ioc_count_dec(as_ioc_count);
 	if (ioc_gone) {
 		/*
 		 * AS scheduler is exiting, grab exit lock and check
@@ -169,7 +169,7 @@ static void free_as_io_context(struct as
 		 * complete ioc_gone and set it back to NULL.
 		 */
 		spin_lock(&ioc_gone_lock);
-		if (ioc_gone && !elv_ioc_count_read(ioc_count)) {
+		if (ioc_gone && !elv_ioc_count_read(as_ioc_count)) {
 			complete(ioc_gone);
 			ioc_gone = NULL;
 		}
@@ -211,7 +211,7 @@ static struct as_io_context *alloc_as_io
 		ret->seek_total = 0;
 		ret->seek_samples = 0;
 		ret->seek_mean = 0;
-		elv_ioc_count_inc(ioc_count);
+		elv_ioc_count_inc(as_ioc_count);
 	}
 
 	return ret;
@@ -1507,7 +1507,7 @@ static void __exit as_exit(void)
 	ioc_gone = &all_gone;
 	/* ioc_gone's update must be visible before reading ioc_count */
 	smp_wmb();
-	if (elv_ioc_count_read(ioc_count))
+	if (elv_ioc_count_read(as_ioc_count))
 		wait_for_completion(&all_gone);
 	synchronize_rcu();
 }
Index: work/block/cfq-iosched.c
===================================================================
--- work.orig/block/cfq-iosched.c
+++ work/block/cfq-iosched.c
@@ -48,7 +48,7 @@ static int cfq_slice_idle = HZ / 125;
 static struct kmem_cache *cfq_pool;
 static struct kmem_cache *cfq_ioc_pool;
 
-static DEFINE_PER_CPU(unsigned long, ioc_count);
+static DEFINE_PER_CPU(unsigned long, cfq_ioc_count);
 static struct completion *ioc_gone;
 static DEFINE_SPINLOCK(ioc_gone_lock);
 
@@ -1422,7 +1422,7 @@ static void cfq_cic_free_rcu(struct rcu_
 	cic = container_of(head, struct cfq_io_context, rcu_head);
 
 	kmem_cache_free(cfq_ioc_pool, cic);
-	elv_ioc_count_dec(ioc_count);
+	elv_ioc_count_dec(cfq_ioc_count);
 
 	if (ioc_gone) {
 		/*
@@ -1431,7 +1431,7 @@ static void cfq_cic_free_rcu(struct rcu_
 		 * complete ioc_gone and set it back to NULL
 		 */
 		spin_lock(&ioc_gone_lock);
-		if (ioc_gone && !elv_ioc_count_read(ioc_count)) {
+		if (ioc_gone && !elv_ioc_count_read(cfq_ioc_count)) {
 			complete(ioc_gone);
 			ioc_gone = NULL;
 		}
@@ -1557,7 +1557,7 @@ cfq_alloc_io_context(struct cfq_data *cf
 		INIT_HLIST_NODE(&cic->cic_list);
 		cic->dtor = cfq_free_io_context;
 		cic->exit = cfq_exit_io_context;
-		elv_ioc_count_inc(ioc_count);
+		elv_ioc_count_inc(cfq_ioc_count);
 	}
 
 	return cic;
@@ -2658,7 +2658,7 @@ static void __exit cfq_exit(void)
 	 * this also protects us from entering cfq_slab_kill() with
 	 * pending RCU callbacks
 	 */
-	if (elv_ioc_count_read(ioc_count))
+	if (elv_ioc_count_read(cfq_ioc_count))
 		wait_for_completion(&all_gone);
 	cfq_slab_kill();
 }
Index: work/drivers/cpufreq/cpufreq_conservative.c
===================================================================
--- work.orig/drivers/cpufreq/cpufreq_conservative.c
+++ work/drivers/cpufreq/cpufreq_conservative.c
@@ -80,7 +80,7 @@ struct cpu_dbs_info_s {
 	int cpu;
 	unsigned int enable:1;
 };
-static DEFINE_PER_CPU(struct cpu_dbs_info_s, cpu_dbs_info);
+static DEFINE_PER_CPU(struct cpu_dbs_info_s, cs_cpu_dbs_info);
 
 static unsigned int dbs_enable;	/* number of CPUs using this policy */
 
@@ -153,7 +153,7 @@ dbs_cpufreq_notifier(struct notifier_blo
 		     void *data)
 {
 	struct cpufreq_freqs *freq = data;
-	struct cpu_dbs_info_s *this_dbs_info = &per_cpu(cpu_dbs_info,
+	struct cpu_dbs_info_s *this_dbs_info = &per_cpu(cs_cpu_dbs_info,
 							freq->cpu);
 
 	struct cpufreq_policy *policy;
@@ -326,7 +326,7 @@ static ssize_t store_ignore_nice_load(st
 	/* we need to re-evaluate prev_cpu_idle */
 	for_each_online_cpu(j) {
 		struct cpu_dbs_info_s *dbs_info;
-		dbs_info = &per_cpu(cpu_dbs_info, j);
+		dbs_info = &per_cpu(cs_cpu_dbs_info, j);
 		dbs_info->prev_cpu_idle = get_cpu_idle_time(j,
 						&dbs_info->prev_cpu_wall);
 		if (dbs_tuners_ins.ignore_nice)
@@ -416,7 +416,7 @@ static void dbs_check_cpu(struct cpu_dbs
 		cputime64_t cur_wall_time, cur_idle_time;
 		unsigned int idle_time, wall_time;
 
-		j_dbs_info = &per_cpu(cpu_dbs_info, j);
+		j_dbs_info = &per_cpu(cs_cpu_dbs_info, j);
 
 		cur_idle_time = get_cpu_idle_time(j, &cur_wall_time);
 
@@ -556,7 +556,7 @@ static int cpufreq_governor_dbs(struct c
 	unsigned int j;
 	int rc;
 
-	this_dbs_info = &per_cpu(cpu_dbs_info, cpu);
+	this_dbs_info = &per_cpu(cs_cpu_dbs_info, cpu);
 
 	switch (event) {
 	case CPUFREQ_GOV_START:
@@ -576,7 +576,7 @@ static int cpufreq_governor_dbs(struct c
 
 		for_each_cpu(j, policy->cpus) {
 			struct cpu_dbs_info_s *j_dbs_info;
-			j_dbs_info = &per_cpu(cpu_dbs_info, j);
+			j_dbs_info = &per_cpu(cs_cpu_dbs_info, j);
 			j_dbs_info->cur_policy = policy;
 
 			j_dbs_info->prev_cpu_idle = get_cpu_idle_time(j,
Index: work/drivers/cpufreq/cpufreq_ondemand.c
===================================================================
--- work.orig/drivers/cpufreq/cpufreq_ondemand.c
+++ work/drivers/cpufreq/cpufreq_ondemand.c
@@ -87,7 +87,7 @@ struct cpu_dbs_info_s {
 	unsigned int enable:1,
 		sample_type:1;
 };
-static DEFINE_PER_CPU(struct cpu_dbs_info_s, cpu_dbs_info);
+static DEFINE_PER_CPU(struct cpu_dbs_info_s, od_cpu_dbs_info);
 
 static unsigned int dbs_enable;	/* number of CPUs using this policy */
 
@@ -165,7 +165,8 @@ static unsigned int powersave_bias_targe
 	unsigned int freq_hi, freq_lo;
 	unsigned int index = 0;
 	unsigned int jiffies_total, jiffies_hi, jiffies_lo;
-	struct cpu_dbs_info_s *dbs_info = &per_cpu(cpu_dbs_info, policy->cpu);
+	struct cpu_dbs_info_s *dbs_info = &per_cpu(od_cpu_dbs_info,
+						   policy->cpu);
 
 	if (!dbs_info->freq_table) {
 		dbs_info->freq_lo = 0;
@@ -210,7 +211,7 @@ static void ondemand_powersave_bias_init
 {
 	int i;
 	for_each_online_cpu(i) {
-		struct cpu_dbs_info_s *dbs_info = &per_cpu(cpu_dbs_info, i);
+		struct cpu_dbs_info_s *dbs_info = &per_cpu(od_cpu_dbs_info, i);
 		dbs_info->freq_table = cpufreq_frequency_get_table(i);
 		dbs_info->freq_lo = 0;
 	}
@@ -325,7 +326,7 @@ static ssize_t store_ignore_nice_load(st
 	/* we need to re-evaluate prev_cpu_idle */
 	for_each_online_cpu(j) {
 		struct cpu_dbs_info_s *dbs_info;
-		dbs_info = &per_cpu(cpu_dbs_info, j);
+		dbs_info = &per_cpu(od_cpu_dbs_info, j);
 		dbs_info->prev_cpu_idle = get_cpu_idle_time(j,
 						&dbs_info->prev_cpu_wall);
 		if (dbs_tuners_ins.ignore_nice)
@@ -419,7 +420,7 @@ static void dbs_check_cpu(struct cpu_dbs
 		unsigned int load, load_freq;
 		int freq_avg;
 
-		j_dbs_info = &per_cpu(cpu_dbs_info, j);
+		j_dbs_info = &per_cpu(od_cpu_dbs_info, j);
 
 		cur_idle_time = get_cpu_idle_time(j, &cur_wall_time);
 
@@ -576,7 +577,7 @@ static int cpufreq_governor_dbs(struct c
 	unsigned int j;
 	int rc;
 
-	this_dbs_info = &per_cpu(cpu_dbs_info, cpu);
+	this_dbs_info = &per_cpu(od_cpu_dbs_info, cpu);
 
 	switch (event) {
 	case CPUFREQ_GOV_START:
@@ -598,7 +599,7 @@ static int cpufreq_governor_dbs(struct c
 
 		for_each_cpu(j, policy->cpus) {
 			struct cpu_dbs_info_s *j_dbs_info;
-			j_dbs_info = &per_cpu(cpu_dbs_info, j);
+			j_dbs_info = &per_cpu(od_cpu_dbs_info, j);
 			j_dbs_info->cur_policy = policy;
 
 			j_dbs_info->prev_cpu_idle = get_cpu_idle_time(j,
Index: work/drivers/xen/events.c
===================================================================
--- work.orig/drivers/xen/events.c
+++ work/drivers/xen/events.c
@@ -602,6 +602,8 @@ irqreturn_t xen_debug_interrupt(int irq,
 	return IRQ_HANDLED;
 }
 
+static DEFINE_PER_CPU(unsigned, xed_nesting_count);
+
 /*
  * Search the CPUs pending events bitmasks.  For each one found, map
  * the event number to an irq, and feed it into do_IRQ() for
@@ -617,7 +619,6 @@ void xen_evtchn_do_upcall(struct pt_regs
 	struct pt_regs *old_regs = set_irq_regs(regs);
 	struct shared_info *s = HYPERVISOR_shared_info;
 	struct vcpu_info *vcpu_info = __get_cpu_var(xen_vcpu);
-	static DEFINE_PER_CPU(unsigned, nesting_count);
  	unsigned count;
 
 	exit_idle();
@@ -628,7 +629,7 @@ void xen_evtchn_do_upcall(struct pt_regs
 
 		vcpu_info->evtchn_upcall_pending = 0;
 
-		if (__get_cpu_var(nesting_count)++)
+		if (__get_cpu_var(xed_nesting_count)++)
 			goto out;
 
 #ifndef CONFIG_X86 /* No need for a barrier -- XCHG is a barrier on x86. */
@@ -653,8 +654,8 @@ void xen_evtchn_do_upcall(struct pt_regs
 
 		BUG_ON(!irqs_disabled());
 
-		count = __get_cpu_var(nesting_count);
-		__get_cpu_var(nesting_count) = 0;
+		count = __get_cpu_var(xed_nesting_count);
+		__get_cpu_var(xed_nesting_count) = 0;
 	} while(count != 1);
 
 out:
Index: work/mm/page-writeback.c
===================================================================
--- work.orig/mm/page-writeback.c
+++ work/mm/page-writeback.c
@@ -606,6 +606,8 @@ void set_page_dirty_balance(struct page
 	}
 }
 
+static DEFINE_PER_CPU(unsigned long, bdp_ratelimits) = 0;
+
 /**
  * balance_dirty_pages_ratelimited_nr - balance dirty memory state
  * @mapping: address_space which was dirtied
@@ -623,7 +625,6 @@ void set_page_dirty_balance(struct page
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 					unsigned long nr_pages_dirtied)
 {
-	static DEFINE_PER_CPU(unsigned long, ratelimits) = 0;
 	unsigned long ratelimit;
 	unsigned long *p;
 
@@ -636,7 +637,7 @@ void balance_dirty_pages_ratelimited_nr(
 	 * tasks in balance_dirty_pages(). Period.
 	 */
 	preempt_disable();
-	p =  &__get_cpu_var(ratelimits);
+	p =  &__get_cpu_var(bdp_ratelimits);
 	*p += nr_pages_dirtied;
 	if (unlikely(*p >= ratelimit)) {
 		*p = 0;
Index: work/net/ipv4/syncookies.c
===================================================================
--- work.orig/net/ipv4/syncookies.c
+++ work/net/ipv4/syncookies.c
@@ -37,12 +37,13 @@ __initcall(init_syncookies);
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
-static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS], cookie_scratch);
+static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
+		      ipv4_cookie_scratch);
 
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
 {
-	__u32 *tmp = __get_cpu_var(cookie_scratch);
+	__u32 *tmp = __get_cpu_var(ipv4_cookie_scratch);
 
 	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
 	tmp[0] = (__force u32)saddr;
Index: work/net/ipv6/syncookies.c
===================================================================
--- work.orig/net/ipv6/syncookies.c
+++ work/net/ipv6/syncookies.c
@@ -74,12 +74,13 @@ static inline struct sock *get_cookie_so
 	return child;
 }
 
-static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS], cookie_scratch);
+static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
+		      ipv6_cookie_scratch);
 
 static u32 cookie_hash(struct in6_addr *saddr, struct in6_addr *daddr,
 		       __be16 sport, __be16 dport, u32 count, int c)
 {
-	__u32 *tmp = __get_cpu_var(cookie_scratch);
+	__u32 *tmp = __get_cpu_var(ipv6_cookie_scratch);
 
 	/*
 	 * we have 320 bits of information to hash, copy in the remaining
Index: work/arch/x86/kernel/cpu/perf_counter.c
===================================================================
--- work.orig/arch/x86/kernel/cpu/perf_counter.c
+++ work/arch/x86/kernel/cpu/perf_counter.c
@@ -861,7 +861,7 @@ amd_pmu_disable_counter(struct hw_perf_c
 	x86_pmu_disable_counter(hwc, idx);
 }
 
-static DEFINE_PER_CPU(u64, prev_left[X86_PMC_IDX_MAX]);
+static DEFINE_PER_CPU(u64, pmc_prev_left[X86_PMC_IDX_MAX]);
 
 /*
  * Set the next IRQ period, based on the hwc->period_left value.
@@ -900,7 +900,7 @@ x86_perf_counter_set_period(struct perf_
 	if (left > x86_pmu.max_period)
 		left = x86_pmu.max_period;
 
-	per_cpu(prev_left[idx], smp_processor_id()) = left;
+	per_cpu(pmc_prev_left[idx], smp_processor_id()) = left;
 
 	/*
 	 * The hw counter starts counting from this counter offset,
@@ -1088,7 +1088,7 @@ void perf_counter_print_debug(void)
 		rdmsrl(x86_pmu.eventsel + idx, pmc_ctrl);
 		rdmsrl(x86_pmu.perfctr  + idx, pmc_count);
 
-		prev_left = per_cpu(prev_left[idx], cpu);
+		prev_left = per_cpu(pmc_prev_left[idx], cpu);
 
 		pr_info("CPU#%d:   gen-PMC%d ctrl:  %016llx\n",
 			cpu, idx, pmc_ctrl);
@@ -1560,8 +1560,8 @@ void callchain_store(struct perf_callcha
 		entry->ip[entry->nr++] = ip;
 }
 
-static DEFINE_PER_CPU(struct perf_callchain_entry, irq_entry);
-static DEFINE_PER_CPU(struct perf_callchain_entry, nmi_entry);
+static DEFINE_PER_CPU(struct perf_callchain_entry, pmc_irq_entry);
+static DEFINE_PER_CPU(struct perf_callchain_entry, pmc_nmi_entry);
 
 
 static void
@@ -1696,9 +1696,9 @@ struct perf_callchain_entry *perf_callch
 	struct perf_callchain_entry *entry;
 
 	if (in_nmi())
-		entry = &__get_cpu_var(nmi_entry);
+		entry = &__get_cpu_var(pmc_nmi_entry);
 	else
-		entry = &__get_cpu_var(irq_entry);
+		entry = &__get_cpu_var(pmc_irq_entry);
 
 	entry->nr = 0;
 	entry->hv = 0;
Index: work/kernel/perf_counter.c
===================================================================
--- work.orig/kernel/perf_counter.c
+++ work/kernel/perf_counter.c
@@ -98,16 +98,16 @@ hw_perf_group_sched_in(struct perf_count
 
 void __weak perf_counter_print_debug(void)	{ }
 
-static DEFINE_PER_CPU(int, disable_count);
+static DEFINE_PER_CPU(int, perf_disable_count);
 
 void __perf_disable(void)
 {
-	__get_cpu_var(disable_count)++;
+	__get_cpu_var(perf_disable_count)++;
 }
 
 bool __perf_enable(void)
 {
-	return !--__get_cpu_var(disable_count);
+	return !--__get_cpu_var(perf_disable_count);
 }
 
 void perf_disable(void)
Index: work/kernel/trace/trace_events.c
===================================================================
--- work.orig/kernel/trace/trace_events.c
+++ work/kernel/trace/trace_events.c
@@ -1318,7 +1318,7 @@ static __init void event_trace_self_test
 
 #ifdef CONFIG_FUNCTION_TRACER
 
-static DEFINE_PER_CPU(atomic_t, test_event_disable);
+static DEFINE_PER_CPU(atomic_t, ftrace_test_event_disable);
 
 static void
 function_test_events_call(unsigned long ip, unsigned long parent_ip)
@@ -1334,7 +1334,7 @@ function_test_events_call(unsigned long
 	pc = preempt_count();
 	resched = ftrace_preempt_disable();
 	cpu = raw_smp_processor_id();
-	disabled = atomic_inc_return(&per_cpu(test_event_disable, cpu));
+	disabled = atomic_inc_return(&per_cpu(ftrace_test_event_disable, cpu));
 
 	if (disabled != 1)
 		goto out;
@@ -1352,7 +1352,7 @@ function_test_events_call(unsigned long
 	trace_nowake_buffer_unlock_commit(event, flags, pc);
 
  out:
-	atomic_dec(&per_cpu(test_event_disable, cpu));
+	atomic_dec(&per_cpu(ftrace_test_event_disable, cpu));
 	ftrace_preempt_enable(resched);
 }
 
Index: work/mm/kmemleak-test.c
===================================================================
--- work.orig/mm/kmemleak-test.c
+++ work/mm/kmemleak-test.c
@@ -36,7 +36,7 @@ struct test_node {
 };
 
 static LIST_HEAD(test_list);
-static DEFINE_PER_CPU(void *, test_pointer);
+static DEFINE_PER_CPU(void *, kmemleak_test_pointer);
 
 /*
  * Some very simple testing. This function needs to be extended for
@@ -86,9 +86,9 @@ static int __init kmemleak_test_init(voi
 	}
 
 	for_each_possible_cpu(i) {
-		per_cpu(test_pointer, i) = kmalloc(129, GFP_KERNEL);
+		per_cpu(kmemleak_test_pointer, i) = kmalloc(129, GFP_KERNEL);
 		pr_info("kmemleak: kmalloc(129) = %p\n",
-			per_cpu(test_pointer, i));
+			per_cpu(kmemleak_test_pointer, i));
 	}
 
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
