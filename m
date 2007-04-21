Subject: Re: [PATCH 10/10] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1177157708.2934.100.camel@lappy>
References: <20070420155154.898600123@chello.nl>
	 <20070420155503.608300342@chello.nl>
	 <20070421025532.916b1e2e.akpm@linux-foundation.org>
	 <1177156902.2934.96.camel@lappy>  <1177157708.2934.100.camel@lappy>
Content-Type: text/plain
Date: Sat, 21 Apr 2007 21:50:29 +0200
Message-Id: <1177185029.7316.34.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Sat, 2007-04-21 at 14:15 +0200, Peter Zijlstra wrote:
> > > > +/*
> > > > + * maximal error of a stat counter.
> > > > + */
> > > > +static inline unsigned long bdi_stat_delta(void)
> > > > +{
> > > > +#ifdef CONFIG_SMP
> > > > +	return NR_CPUS * FBC_BATCH;
> > > 
> > > This is enormously wrong for CONFIG_NR_CPUS=1024 on a 2-way.
> 
> Right, I knew about that but, uhm.
> 
> I wanted to make that num_online_cpus(), and install a hotplug notifier
> to fold the percpu delta back into the total on cpu offline.
> 
> But I have to look into doing that hotplug notifier stuff.

Something like this should do I think, I just looked at other hotplug
code and imitated the pattern.

I assumed CONFIG_HOTPLUG_CPU requires CONFIG_SMP, I didn't actually try
that one :-)

---

In order to estimate the per stat counter error more accurately, using
num_online_cpus() instead of NR_CPUS, install a cpu hotplug notifier
(when cpu hotplug is enabled) that flushes whatever percpu delta was
present into the total on cpu unplug.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/backing-dev.h    |    6 ++++-
 include/linux/percpu_counter.h |    1 
 lib/percpu_counter.c           |   11 +++++++++
 mm/backing-dev.c               |   47 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 64 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h	2007-04-21 21:32:49.000000000 +0200
+++ linux-2.6/include/linux/backing-dev.h	2007-04-21 21:33:28.000000000 +0200
@@ -51,6 +51,10 @@ struct backing_dev_info {
 	spinlock_t lock;	/* protect the cycle count */
 	unsigned long cycles;	/* writeout cycles */
 	int dirty_exceeded;
+
+#ifdef CONFIG_HOTPLUG_CPU
+	struct notifier_block hotplug_nb;
+#endif
 };
 
 void bdi_init(struct backing_dev_info *bdi);
@@ -137,7 +141,7 @@ static inline s64 bdi_stat_sum(struct ba
 static inline unsigned long bdi_stat_delta(void)
 {
 #ifdef CONFIG_SMP
-	return NR_CPUS * FBC_BATCH;
+	return num_online_cpus() * FBC_BATCH;
 #else
 	return 1UL;
 #endif
Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h	2007-04-21 21:32:49.000000000 +0200
+++ linux-2.6/include/linux/percpu_counter.h	2007-04-21 21:33:17.000000000 +0200
@@ -38,6 +38,7 @@ static inline void percpu_counter_destro
 void percpu_counter_mod(struct percpu_counter *fbc, s32 amount);
 void percpu_counter_mod64(struct percpu_counter *fbc, s64 amount);
 s64 percpu_counter_sum(struct percpu_counter *fbc);
+void percpu_counter_fold(struct percpu_counter *fbx, int cpu);
 
 static inline s64 percpu_counter_read(struct percpu_counter *fbc)
 {
Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2007-04-21 21:32:49.000000000 +0200
+++ linux-2.6/lib/percpu_counter.c	2007-04-21 21:33:17.000000000 +0200
@@ -72,3 +72,14 @@ s64 percpu_counter_sum(struct percpu_cou
 	return ret < 0 ? 0 : ret;
 }
 EXPORT_SYMBOL(percpu_counter_sum);
+
+void percpu_counter_fold(struct percpu_counter *fbc, int cpu)
+{
+	s32 *pcount = per_cpu_ptr(fbc->counters, cpu);
+	if (*pcount) {
+		spin_lock(&fbc->lock);
+		fbc->count += *pcount;
+		*pcount = 0;
+		spin_unlock(&fbc->lock);
+	}
+}
Index: linux-2.6/mm/backing-dev.c
===================================================================
--- linux-2.6.orig/mm/backing-dev.c	2007-04-21 21:32:49.000000000 +0200
+++ linux-2.6/mm/backing-dev.c	2007-04-21 21:34:47.000000000 +0200
@@ -4,6 +4,49 @@
 #include <linux/fs.h>
 #include <linux/sched.h>
 #include <linux/module.h>
+#include <linux/cpu.h>
+
+#ifdef CONFIG_HOTPLUG_CPU
+static int bdi_stat_fold(struct notifier_block *nb,
+		unsigned long action, void *hcpu)
+{
+	struct backing_dev_info *bdi =
+		container_of(nb, struct backing_dev_info, hotplug_nb);
+	unsigned long flags;
+	int cpu = (unsigned long)hcpu;
+	int i;
+
+	if (action == CPU_DEAD) {
+		local_irq_save(flags);
+		for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
+			percpu_counter_fold(&bdi->bdi_stat[i], cpu);
+		local_irq_restore(flags);
+	}
+	return NOTIFY_OK;
+}
+
+static void bdi_init_hotplug(struct backing_dev_info *bdi)
+{
+	bdi->hotplug_nb = (struct notifier_block){
+		.notifier_call = bdi_stat_fold,
+		.priority = 0,
+	};
+	register_hotcpu_notifier(&bdi->hotplug_nb);
+}
+
+static void bdi_destroy_hotplug(struct backing_dev_info *bdi)
+{
+	unregister_hotcpu_notifier(&bdi->hotplug_nb);
+}
+#else
+static void bdi_init_hotplug(struct backing_dev_info *bdi)
+{
+}
+
+static void bdi_destroy_hotplug(struct backing_dev_info *bdi)
+{
+}
+#endif
 
 void bdi_init(struct backing_dev_info *bdi)
 {
@@ -17,6 +60,8 @@ void bdi_init(struct backing_dev_info *b
 	bdi->dirty_exceeded = 0;
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_init(&bdi->bdi_stat[i], 0);
+
+	bdi_init_hotplug(bdi);
 }
 EXPORT_SYMBOL(bdi_init);
 
@@ -27,6 +72,8 @@ void bdi_destroy(struct backing_dev_info
 	if (!(bdi_cap_writeback_dirty(bdi) || bdi_cap_account_dirty(bdi)))
 		return;
 
+	bdi_destroy_hotplug(bdi);
+
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_destroy(&bdi->bdi_stat[i]);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
