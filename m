Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 588136B0071
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:49:22 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id u14so5339616lbd.12
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:49:21 -0800 (PST)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [2a02:6b8:0:1402::10])
        by mx.google.com with ESMTPS id la5si2254992lac.64.2015.01.15.10.49.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 10:49:18 -0800 (PST)
Subject: [PATCH 4/6] percpu_ratelimit: high-performance ratelimiting counter
From: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 15 Jan 2015 21:49:15 +0300
Message-ID: <20150115184915.10450.1814.stgit@buzz>
In-Reply-To: <20150115180242.10450.92.stgit@buzz>
References: <20150115180242.10450.92.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: Roman Gushchin <klamm@yandex-team.ru>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, koct9i@gmail.com

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Parameters:
period   - interval between refills (100ms should be fine)
quota    - events refill per period
deadline - interval to utilize unused past quota (1s by default)
latency  - maximum injected delay (10s by default)

Quota sums into 'budget' and spreads across cpus.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/percpu_ratelimit.h |   45 ++++++++++
 lib/Makefile                     |    1 
 lib/percpu_ratelimit.c           |  168 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 214 insertions(+)
 create mode 100644 include/linux/percpu_ratelimit.h
 create mode 100644 lib/percpu_ratelimit.c

diff --git a/include/linux/percpu_ratelimit.h b/include/linux/percpu_ratelimit.h
new file mode 100644
index 0000000..42c45d4
--- /dev/null
+++ b/include/linux/percpu_ratelimit.h
@@ -0,0 +1,45 @@
+#ifndef _LINUX_PERCPU_RATELIMIT_H
+#define _LINUX_PERCPU_RATELIMIT_H
+
+#include <linux/hrtimer.h>
+
+struct percpu_ratelimit {
+	struct hrtimer  timer;
+	ktime_t		target;		/* time of next refill */
+	ktime_t		deadline;	/* interval to utilize past budget */
+	ktime_t		latency;	/* maximum injected delay */
+	ktime_t		period;		/* interval between refills */
+	u64		quota;		/* events refill per period */
+	u64		budget;		/* amount of available events */
+	u64		total;		/* consumed and pre-charged events */
+	raw_spinlock_t	lock;		/* protect the state */
+	u32		cpu_batch;	/* events in per-cpu precharge */
+	u32 __percpu	*cpu_budget;	/* per-cpu precharge */
+};
+
+static inline bool percpu_ratelimit_blocked(struct percpu_ratelimit *rl)
+{
+       return hrtimer_active(&rl->timer);
+}
+
+static inline ktime_t percpu_ratelimit_target(struct percpu_ratelimit *rl)
+{
+	return rl->target;
+}
+
+static inline int percpu_ratelimit_wait(struct percpu_ratelimit *rl)
+{
+	ktime_t target = rl->target;
+
+	return schedule_hrtimeout_range(&target, ktime_to_ns(rl->period),
+					HRTIMER_MODE_ABS);
+}
+
+int percpu_ratelimit_init(struct percpu_ratelimit *rl, gfp_t gfp);
+void percpu_ratelimit_destroy(struct percpu_ratelimit *rl);
+void percpu_ratelimit_setup(struct percpu_ratelimit *rl, u64 quota, u64 period);
+u64 percpu_ratelimit_quota(struct percpu_ratelimit *rl, u64 period);
+bool percpu_ratelimit_charge(struct percpu_ratelimit *rl, u64 events);
+u64 percpu_ratelimit_sum(struct percpu_ratelimit *rl);
+
+#endif /* _LINUX_PERCPU_RATELIMIT_H */
diff --git a/lib/Makefile b/lib/Makefile
index 3c3b30b..b20ab47 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -21,6 +21,7 @@ lib-$(CONFIG_SMP) += cpumask.o
 
 lib-y	+= kobject.o klist.o
 obj-y	+= lockref.o
+obj-y   += percpu_ratelimit.o
 
 obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 bust_spinlocks.o hexdump.o kasprintf.o bitmap.o scatterlist.o \
diff --git a/lib/percpu_ratelimit.c b/lib/percpu_ratelimit.c
new file mode 100644
index 0000000..8254683
--- /dev/null
+++ b/lib/percpu_ratelimit.c
@@ -0,0 +1,168 @@
+#include <linux/percpu_ratelimit.h>
+
+static void __percpu_ratelimit_setup(struct percpu_ratelimit *rl,
+				     u64 period, u64 quota)
+{
+	rl->period = ns_to_ktime(period);
+	rl->quota = quota;
+	rl->total += quota - rl->budget;
+	rl->budget = quota;
+	if (do_div(quota, num_possible_cpus() * 2))
+		quota++;
+	rl->cpu_batch = min_t(u64, UINT_MAX, quota);
+	rl->target = ktime_get();
+}
+
+static enum hrtimer_restart ratelimit_unblock(struct hrtimer *t)
+{
+	struct percpu_ratelimit *rl = container_of(t, struct percpu_ratelimit, timer);
+	enum hrtimer_restart ret = HRTIMER_NORESTART;
+	ktime_t now = t->base->get_time();
+
+	raw_spin_lock(&rl->lock);
+	if (ktime_after(rl->target, now)) {
+		hrtimer_set_expires_range(t, rl->target, rl->period);
+		ret = HRTIMER_RESTART;
+	}
+	raw_spin_unlock(&rl->lock);
+
+	return ret;
+}
+
+int percpu_ratelimit_init(struct percpu_ratelimit *rl, gfp_t gfp)
+{
+	memset(rl, 0, sizeof(*rl));
+	rl->cpu_budget = alloc_percpu_gfp(typeof(*rl->cpu_budget), gfp);
+	if (!rl->cpu_budget)
+		return -ENOMEM;
+	raw_spin_lock_init(&rl->lock);
+	hrtimer_init(&rl->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
+	rl->timer.function = ratelimit_unblock;
+	rl->deadline = ns_to_ktime(NSEC_PER_SEC);
+	rl->latency  = ns_to_ktime(NSEC_PER_SEC * 10);
+	__percpu_ratelimit_setup(rl, NSEC_PER_SEC, ULLONG_MAX);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(percpu_ratelimit_init);
+
+void percpu_ratelimit_destroy(struct percpu_ratelimit *rl)
+{
+	free_percpu(rl->cpu_budget);
+	hrtimer_cancel(&rl->timer);
+}
+EXPORT_SYMBOL_GPL(percpu_ratelimit_destroy);
+
+static void percpu_ratelimit_drain(void *info)
+{
+	struct percpu_ratelimit *rl = info;
+
+	__this_cpu_write(*rl->cpu_budget, 0);
+}
+
+void percpu_ratelimit_setup(struct percpu_ratelimit *rl, u64 quota, u64 period)
+{
+	unsigned long flags;
+
+	if (!quota || !period) {
+		quota = ULLONG_MAX;
+		period = NSEC_PER_SEC;
+	} else if (period > NSEC_PER_SEC / 10) {
+		u64 quant = div_u64(quota * NSEC_PER_SEC / 10, period);
+
+		if (quant > 20) {
+			quota = quant;
+			period = NSEC_PER_SEC / 10;
+		}
+	}
+
+	raw_spin_lock_irqsave(&rl->lock, flags);
+	__percpu_ratelimit_setup(rl, period, quota);
+	raw_spin_unlock_irqrestore(&rl->lock, flags);
+	on_each_cpu(percpu_ratelimit_drain, rl, 1);
+	hrtimer_cancel(&rl->timer);
+}
+EXPORT_SYMBOL_GPL(percpu_ratelimit_setup);
+
+u64 percpu_ratelimit_quota(struct percpu_ratelimit *rl, u64 period)
+{
+	unsigned long flags;
+	u64 quota;
+
+	raw_spin_lock_irqsave(&rl->lock, flags);
+	if (rl->quota == ULLONG_MAX)
+		quota = 0;
+	else
+		quota = div64_u64(rl->quota * period, ktime_to_ns(rl->period));
+	raw_spin_unlock_irqrestore(&rl->lock, flags);
+
+	return quota;
+}
+EXPORT_SYMBOL_GPL(percpu_ratelimit_quota);
+
+/*
+ * Charges events, returns true if ratelimit is blocked and caller should sleep.
+ */
+bool percpu_ratelimit_charge(struct percpu_ratelimit *rl, u64 events)
+{
+	unsigned long flags;
+	u64 budget, delta;
+	ktime_t now, deadline;
+
+	preempt_disable();
+	budget = __this_cpu_read(*rl->cpu_budget);
+	if (likely(budget >= events)) {
+		__this_cpu_sub(*rl->cpu_budget, events);
+	} else {
+		now = ktime_get();
+		raw_spin_lock_irqsave(&rl->lock, flags);
+		deadline = ktime_sub(now, rl->deadline);
+		if (ktime_after(deadline, rl->target))
+			rl->target = deadline;
+		budget += rl->budget;
+		if (budget >= events + rl->cpu_batch) {
+			budget -= events;
+		} else {
+			delta = events + rl->cpu_batch - budget;
+			if (do_div(delta, rl->quota))
+				delta++;
+			rl->target = ktime_add_ns(rl->target,
+					ktime_to_ns(rl->period) * delta);
+			deadline = ktime_add(now, rl->latency);
+			if (ktime_after(rl->target, deadline))
+				rl->target = deadline;
+			delta *= rl->quota;
+			rl->total += delta;
+			budget += delta - events;
+		}
+		rl->budget = budget - rl->cpu_batch;
+		__this_cpu_write(*rl->cpu_budget, rl->cpu_batch);
+		if (!hrtimer_active(&rl->timer) && ktime_after(rl->target, now))
+			hrtimer_start_range_ns(&rl->timer, rl->target,
+					ktime_to_ns(rl->period),
+					HRTIMER_MODE_ABS);
+		raw_spin_unlock_irqrestore(&rl->lock, flags);
+	}
+	preempt_enable();
+
+	return percpu_ratelimit_blocked(rl);
+}
+EXPORT_SYMBOL_GPL(percpu_ratelimit_charge);
+
+/*
+ * Returns count of consumed events.
+ */
+u64 percpu_ratelimit_sum(struct percpu_ratelimit *rl)
+{
+	unsigned long flags;
+	int cpu;
+	s64 ret;
+
+	raw_spin_lock_irqsave(&rl->lock, flags);
+	ret = rl->total - rl->budget;
+	for_each_online_cpu(cpu)
+		ret -= per_cpu(*rl->cpu_budget, cpu);
+	raw_spin_unlock_irqrestore(&rl->lock, flags);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(percpu_ratelimit_sum);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
