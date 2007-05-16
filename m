Date: Wed, 16 May 2007 16:28:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-Id: <20070516162829.23f9b1c4.akpm@linux-foundation.org>
In-Reply-To: <20070512110624.9ac3aa44.akpm@linux-foundation.org>
References: <20070511131541.992688403@chello.nl>
	<20070511132321.895740140@chello.nl>
	<20070511093108.495feb70.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705111006470.32716@schroedinger.engr.sgi.com>
	<20070511110522.ed459635.akpm@linux-foundation.org>
	<p73odkpeusf.fsf@bingen.suse.de>
	<20070512110624.9ac3aa44.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, 12 May 2007 11:06:24 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On 12 May 2007 20:55:28 +0200 Andi Kleen <andi@firstfloor.org> wrote:
> 
> > Andrew Morton <akpm@linux-foundation.org> writes:
> > 
> > > On Fri, 11 May 2007 10:07:17 -0700 (PDT)
> > > Christoph Lameter <clameter@sgi.com> wrote:
> > > 
> > > > On Fri, 11 May 2007, Andrew Morton wrote:
> > > > 
> > > > > yipes.  percpu_counter_sum() is expensive.
> > > > 
> > > > Capable of triggering NMI watchdog on 4096+ processors?
> > > 
> > > Well.  That would be a millisecond per cpu which sounds improbable.  And
> > > we'd need to be calling it under local_irq_save() which we presently don't.
> > > And nobody has reported any problems against the existing callsites.
> > > 
> > > But it's no speed demon, that's for sure.
> > 
> > There is one possible optimization for this I did some time ago. You don't really
> > need to sum all over the possible map, but only all CPUs that were ever 
> > online. But this only helps on systems where the possible map is bigger
> > than online map in the common case. But that shouldn't be the case anymore on x86
> > -- it just used to be. If it's true on some other architectures it might
> > be still worth it.
> > 
> 
> hm, yeah.
> 
> We could put a cpumask in percpu_counter, initialise it to
> cpu_possible_map.  Then, those callsites which have hotplug notifiers can
> call into new percpu_counter functions which clear and set bits in that
> cpumask and which drain percpu_counter.counts[cpu] into
> percpu_counter.count.
> 
> And percpu_counter_sum() gets taught to do for_each_cpu_mask(fbc->cpumask).

Like this:


From: Andrew Morton <akpm@linux-foundation.org>

per-cpu counters presently must iterate over all possible CPUs in the
exhaustive percpu_counter_sum().

But it can be much better to only iterate over the presently-online CPUs.  To
do this, we must arrange for an offlined CPU's count to be spilled into the
counter's central count.

We can do this for all percpu_counters in the machine by linking them into a
single global list and walking that list at CPU_DEAD time.

(I hope.  Might have race windows in which the percpu_counter_sum() count is
inaccurate?)


Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/percpu_counter.h |   18 ++------
 lib/percpu_counter.c           |   66 +++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+), 12 deletions(-)

diff -puN lib/percpu_counter.c~percpu_counters-use-cpu-notifiers lib/percpu_counter.c
--- a/lib/percpu_counter.c~percpu_counters-use-cpu-notifiers
+++ a/lib/percpu_counter.c
@@ -3,8 +3,17 @@
  */
 
 #include <linux/percpu_counter.h>
+#include <linux/notifier.h>
+#include <linux/mutex.h>
+#include <linux/init.h>
+#include <linux/cpu.h>
 #include <linux/module.h>
 
+#ifdef CONFIG_HOTPLUG_CPU
+static LIST_HEAD(percpu_counters);
+static DEFINE_MUTEX(percpu_counters_lock);
+#endif
+
 void percpu_counter_mod(struct percpu_counter *fbc, s32 amount)
 {
 	long count;
@@ -44,3 +53,60 @@ s64 percpu_counter_sum(struct percpu_cou
 	return ret < 0 ? 0 : ret;
 }
 EXPORT_SYMBOL(percpu_counter_sum);
+
+void percpu_counter_init(struct percpu_counter *fbc, s64 amount)
+{
+	spin_lock_init(&fbc->lock);
+	fbc->count = amount;
+	fbc->counters = alloc_percpu(s32);
+#ifdef CONFIG_HOTPLUG_CPU
+	mutex_lock(&percpu_counters_lock);
+	list_add(&fbc->list, &percpu_counters);
+	mutex_unlock(&percpu_counters_lock);
+#endif
+}
+EXPORT_SYMBOL(percpu_counter_init);
+
+void percpu_counter_destroy(struct percpu_counter *fbc)
+{
+	free_percpu(fbc->counters);
+#ifdef CONFIG_HOTPLUG_CPU
+	mutex_lock(&percpu_counters_lock);
+	list_del(&fbc->list);
+	mutex_unlock(&percpu_counters_lock);
+#endif
+}
+EXPORT_SYMBOL(percpu_counter_destroy);
+
+#ifdef CONFIG_HOTPLUG_CPU
+static int __cpuinit percpu_counter_hotcpu_callback(struct notifier_block *nb,
+					unsigned long action, void *hcpu)
+{
+	unsigned int cpu;
+	struct percpu_counter *fbc;
+
+	if (action != CPU_DEAD)
+		return NOTIFY_OK;
+
+	cpu = (unsigned long)hcpu;
+	mutex_lock(&percpu_counters_lock);
+	list_for_each_entry(fbc, &percpu_counters, list) {
+		s32 *pcount;
+
+		spin_lock(&fbc->lock);
+		pcount = per_cpu_ptr(fbc->counters, cpu);
+		fbc->count += *pcount;
+		*pcount = 0;
+		spin_unlock(&fbc->lock);
+	}
+	mutex_unlock(&percpu_counters_lock);
+	return NOTIFY_OK;
+}
+
+static int __init percpu_counter_startup(void)
+{
+	hotcpu_notifier(percpu_counter_hotcpu_callback, 0);
+	return 0;
+}
+module_init(percpu_counter_startup);
+#endif
diff -puN include/linux/percpu.h~percpu_counters-use-cpu-notifiers include/linux/percpu.h
diff -puN include/linux/percpu_counter.h~percpu_counters-use-cpu-notifiers include/linux/percpu_counter.h
--- a/include/linux/percpu_counter.h~percpu_counters-use-cpu-notifiers
+++ a/include/linux/percpu_counter.h
@@ -8,6 +8,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/smp.h>
+#include <linux/list.h>
 #include <linux/threads.h>
 #include <linux/percpu.h>
 #include <linux/types.h>
@@ -17,6 +18,9 @@
 struct percpu_counter {
 	spinlock_t lock;
 	s64 count;
+#ifdef CONFIG_HOTPLUG_CPU
+	struct list_head list;	/* All percpu_counters are on a list */
+#endif
 	s32 *counters;
 };
 
@@ -26,18 +30,8 @@ struct percpu_counter {
 #define FBC_BATCH	(NR_CPUS*4)
 #endif
 
-static inline void percpu_counter_init(struct percpu_counter *fbc, s64 amount)
-{
-	spin_lock_init(&fbc->lock);
-	fbc->count = amount;
-	fbc->counters = alloc_percpu(s32);
-}
-
-static inline void percpu_counter_destroy(struct percpu_counter *fbc)
-{
-	free_percpu(fbc->counters);
-}
-
+void percpu_counter_init(struct percpu_counter *fbc, s64 amount);
+void percpu_counter_destroy(struct percpu_counter *fbc);
 void percpu_counter_mod(struct percpu_counter *fbc, s32 amount);
 s64 percpu_counter_sum(struct percpu_counter *fbc);
 
_

and then this:


From: Andrew Morton <akpm@linux-foundation.org>

Now that we have implemented hotunplug-time counter spilling,
percpu_counter_sum() only needs to look at online CPus.


Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 lib/percpu_counter.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN lib/percpu_counter.c~percpu_counters-use-for_each_online_cpu lib/percpu_counter.c
--- a/lib/percpu_counter.c~percpu_counters-use-for_each_online_cpu
+++ a/lib/percpu_counter.c
@@ -45,7 +45,7 @@ s64 percpu_counter_sum(struct percpu_cou
 
 	spin_lock(&fbc->lock);
 	ret = fbc->count;
-	for_each_possible_cpu(cpu) {
+	for_each_online_cpu(cpu) {
 		s32 *pcount = per_cpu_ptr(fbc->counters, cpu);
 		ret += *pcount;
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
