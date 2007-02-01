Date: Thu, 1 Feb 2007 15:15:23 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Use parameter passed to cache_reap to determine pointer to
 work structure
Message-ID: <Pine.LNX.4.64.0702011512250.7969@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Use the pointer passed to cache_reap to determine the work
pointer and consolidate exit paths.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: current/mm/slab.c
===================================================================
--- current.orig/mm/slab.c	2007-02-01 15:02:54.000000000 -0800
+++ current/mm/slab.c	2007-02-01 15:11:52.000000000 -0800
@@ -4045,18 +4045,17 @@ void drain_array(struct kmem_cache *cach
  * If we cannot acquire the cache chain mutex then just give up - we'll try
  * again on the next iteration.
  */
-static void cache_reap(struct work_struct *unused)
+static void cache_reap(struct work_struct *w)
 {
 	struct kmem_cache *searchp;
 	struct kmem_list3 *l3;
 	int node = numa_node_id();
+	struct delayed_work *work =
+		container_of(w, struct delayed_work, work);
 
-	if (!mutex_trylock(&cache_chain_mutex)) {
+	if (!mutex_trylock(&cache_chain_mutex))
 		/* Give up. Setup the next iteration. */
-		schedule_delayed_work(&__get_cpu_var(reap_work),
-				      round_jiffies_relative(REAPTIMEOUT_CPUC));
-		return;
-	}
+		goto out;
 
 	list_for_each_entry(searchp, &cache_chain, next) {
 		check_irq_on();
@@ -4099,9 +4098,9 @@ next:
 	mutex_unlock(&cache_chain_mutex);
 	next_reap_node();
 	refresh_cpu_vm_stats(smp_processor_id());
+out:
 	/* Set up the next iteration */
-	schedule_delayed_work(&__get_cpu_var(reap_work),
-		round_jiffies_relative(REAPTIMEOUT_CPUC));
+	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_CPUC));
 }
 
 #ifdef CONFIG_PROC_FS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
