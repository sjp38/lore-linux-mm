Date: Thu, 19 Aug 2004 15:26:52 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: [PATCH] Improve cache_reap hotplug cpu support
Message-ID: <20040819202652.GA11050@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Manfred Spraul <manfred@colorfullife.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I found that there was room for improvement in the hotplug cpu code
in cache_reap.  This applies to the code that moved cache_reap out
of timer context.

The patch applies over 2.6.8.1-mm2.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>


Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2004-08-19 14:34:03.000000000 -0500
+++ linux/mm/slab.c	2004-08-19 15:19:34.000000000 -0500
@@ -613,12 +613,22 @@ static void __devinit start_cpu_timer(in
 	 * init_workqueues() has already run, so keventd will be setup
 	 * at that time.
 	 */
-	if (keventd_up() && reap_work->func == NULL) {
-		INIT_WORK(reap_work, cache_reap, NULL);
+	if (keventd_up() && reap_work->data == NULL) {
+		INIT_WORK(reap_work, cache_reap, reap_work);
 		schedule_delayed_work_on(cpu, reap_work, HZ + 3 * cpu);
 	}
 }
 
+#ifdef CONFIG_HOTPLUG_CPU
+static void stop_cpu_timer(int cpu)
+{
+	struct work_struct *reap_work = &per_cpu(reap_work, cpu);
+
+	/* Null out this otherwise unused pointer for checking in cache_reap */
+	reap_work->data = NULL;
+}
+#endif
+
 static struct array_cache *alloc_arraycache(int cpu, int entries, int batchcount)
 {
 	int memsize = sizeof(void*)*entries+sizeof(struct array_cache);
@@ -670,6 +680,7 @@ static int __devinit cpuup_callback(stru
 		break;
 #ifdef CONFIG_HOTPLUG_CPU
 	case CPU_DEAD:
+		stop_cpu_timer(cpu);
 		/* fall thru */
 	case CPU_UP_CANCELED:
 		down(&cache_chain_sem);
@@ -2731,10 +2742,19 @@ static void drain_array_locked(kmem_cach
  * If we cannot acquire the cache chain semaphore then just give up - we'll
  * try again on the next iteration.
  */
-static void cache_reap(void *unused)
+static void cache_reap(void *work)
 {
 	struct list_head *walk;
 
+#ifdef CONFIG_HOTPLUG_CPU
+	if (unlikely((work==NULL) ||
+			((struct work_struct *)work)->data == NULL)) {
+		/* We've been moved off the original cpu due to HOTPLUG,
+		 * don't resched.
+		 */
+		return;
+	}
+#endif
 	if (down_trylock(&cache_chain_sem)) {
 		/* Give up. Setup the next iteration. */
 		schedule_delayed_work(&__get_cpu_var(reap_work), REAPTIMEOUT_CPUC + smp_processor_id());
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
