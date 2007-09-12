Message-ID: <46E74321.70203@google.com>
Date: Tue, 11 Sep 2007 18:38:41 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [PATCH 2/6] cpuset write pdflush nodemask
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
In-Reply-To: <46E741B1.4030100@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

If we want to support nodeset specific writeout then we need a way
to communicate the set of nodes that an operation should affect.

So add a nodemask_t parameter to the pdflush functions and also
store the nodemask in the pdflush control structure.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Ethan Solomita <solo@google.com>

---

Patch against 2.6.23-rc4-mm1

diff -uprN -X 0/Documentation/dontdiff 1/fs/buffer.c 2/fs/buffer.c
--- 1/fs/buffer.c	2007-09-11 14:36:24.000000000 -0700
+++ 2/fs/buffer.c	2007-09-11 14:39:22.000000000 -0700
@@ -372,7 +372,7 @@ static void free_more_memory(void)
 	struct zone **zones;
 	pg_data_t *pgdat;
 
-	wakeup_pdflush(1024);
+	wakeup_pdflush(1024, NULL);
 	yield();
 
 	for_each_online_pgdat(pgdat) {
diff -uprN -X 0/Documentation/dontdiff 1/fs/super.c 2/fs/super.c
--- 1/fs/super.c	2007-09-11 14:36:05.000000000 -0700
+++ 2/fs/super.c	2007-09-11 14:39:22.000000000 -0700
@@ -616,7 +616,7 @@ int do_remount_sb(struct super_block *sb
 	return 0;
 }
 
-static void do_emergency_remount(unsigned long foo)
+static void do_emergency_remount(unsigned long foo, nodemask_t *bar)
 {
 	struct super_block *sb;
 
@@ -644,7 +644,7 @@ static void do_emergency_remount(unsigne
 
 void emergency_remount(void)
 {
-	pdflush_operation(do_emergency_remount, 0);
+	pdflush_operation(do_emergency_remount, 0, NULL);
 }
 
 /*
diff -uprN -X 0/Documentation/dontdiff 1/fs/sync.c 2/fs/sync.c
--- 1/fs/sync.c	2007-09-11 14:36:05.000000000 -0700
+++ 2/fs/sync.c	2007-09-11 14:39:22.000000000 -0700
@@ -21,9 +21,9 @@
  * sync everything.  Start out by waking pdflush, because that writes back
  * all queues in parallel.
  */
-static void do_sync(unsigned long wait)
+static void do_sync(unsigned long wait, nodemask_t *unused)
 {
-	wakeup_pdflush(0);
+	wakeup_pdflush(0, NULL);
 	sync_inodes(0);		/* All mappings, inodes and their blockdevs */
 	DQUOT_SYNC(NULL);
 	sync_supers();		/* Write the superblocks */
@@ -38,13 +38,13 @@ static void do_sync(unsigned long wait)
 
 asmlinkage long sys_sync(void)
 {
-	do_sync(1);
+	do_sync(1, NULL);
 	return 0;
 }
 
 void emergency_sync(void)
 {
-	pdflush_operation(do_sync, 0);
+	pdflush_operation(do_sync, 0, NULL);
 }
 
 /*
diff -uprN -X 0/Documentation/dontdiff 1/include/linux/writeback.h 2/include/linux/writeback.h
--- 1/include/linux/writeback.h	2007-09-11 14:37:46.000000000 -0700
+++ 2/include/linux/writeback.h	2007-09-11 14:39:22.000000000 -0700
@@ -91,7 +91,7 @@ static inline void inode_sync_wait(struc
 /*
  * mm/page-writeback.c
  */
-int wakeup_pdflush(long nr_pages);
+int wakeup_pdflush(long nr_pages, nodemask_t *nodes);
 void laptop_io_completion(void);
 void laptop_sync_completion(void);
 void throttle_vm_writeout(gfp_t gfp_mask);
@@ -122,7 +122,8 @@ balance_dirty_pages_ratelimited(struct a
 typedef int (*writepage_t)(struct page *page, struct writeback_control *wbc,
 				void *data);
 
-int pdflush_operation(void (*fn)(unsigned long), unsigned long arg0);
+int pdflush_operation(void (*fn)(unsigned long, nodemask_t *nodes),
+			unsigned long arg0, nodemask_t *nodes);
 int generic_writepages(struct address_space *mapping,
 		       struct writeback_control *wbc);
 int write_cache_pages(struct address_space *mapping,
diff -uprN -X 0/Documentation/dontdiff 1/mm/page-writeback.c 2/mm/page-writeback.c
--- 1/mm/page-writeback.c	2007-09-11 14:36:24.000000000 -0700
+++ 2/mm/page-writeback.c	2007-09-11 14:39:22.000000000 -0700
@@ -101,7 +101,7 @@ EXPORT_SYMBOL(laptop_mode);
 /* End of sysctl-exported parameters */
 
 
-static void background_writeout(unsigned long _min_pages);
+static void background_writeout(unsigned long _min_pages, nodemask_t *nodes);
 
 /*
  * Work out the current dirty-memory clamping and background writeout
@@ -272,7 +272,7 @@ static void balance_dirty_pages(struct a
 	 */
 	if ((laptop_mode && pages_written) ||
 	     (!laptop_mode && (nr_reclaimable > background_thresh)))
-		pdflush_operation(background_writeout, 0);
+		pdflush_operation(background_writeout, 0, NULL);
 }
 
 void set_page_dirty_balance(struct page *page)
@@ -362,7 +362,7 @@ void throttle_vm_writeout(gfp_t gfp_mask
  * writeback at least _min_pages, and keep writing until the amount of dirty
  * memory is less than the background threshold, or until we're all clean.
  */
-static void background_writeout(unsigned long _min_pages)
+static void background_writeout(unsigned long _min_pages, nodemask_t *unused)
 {
 	long min_pages = _min_pages;
 	struct writeback_control wbc = {
@@ -402,12 +402,12 @@ static void background_writeout(unsigned
  * the whole world.  Returns 0 if a pdflush thread was dispatched.  Returns
  * -1 if all pdflush threads were busy.
  */
-int wakeup_pdflush(long nr_pages)
+int wakeup_pdflush(long nr_pages, nodemask_t *nodes)
 {
 	if (nr_pages == 0)
 		nr_pages = global_page_state(NR_FILE_DIRTY) +
 				global_page_state(NR_UNSTABLE_NFS);
-	return pdflush_operation(background_writeout, nr_pages);
+	return pdflush_operation(background_writeout, nr_pages, nodes);
 }
 
 static void wb_timer_fn(unsigned long unused);
@@ -431,7 +431,7 @@ static DEFINE_TIMER(laptop_mode_wb_timer
  * older_than_this takes precedence over nr_to_write.  So we'll only write back
  * all dirty pages if they are all attached to "old" mappings.
  */
-static void wb_kupdate(unsigned long arg)
+static void wb_kupdate(unsigned long arg, nodemask_t *unused)
 {
 	unsigned long oldest_jif;
 	unsigned long start_jif;
@@ -489,18 +489,18 @@ int dirty_writeback_centisecs_handler(ct
 
 static void wb_timer_fn(unsigned long unused)
 {
-	if (pdflush_operation(wb_kupdate, 0) < 0)
+	if (pdflush_operation(wb_kupdate, 0, NULL) < 0)
 		mod_timer(&wb_timer, jiffies + HZ); /* delay 1 second */
 }
 
-static void laptop_flush(unsigned long unused)
+static void laptop_flush(unsigned long unused, nodemask_t *unused2)
 {
 	sys_sync();
 }
 
 static void laptop_timer_fn(unsigned long unused)
 {
-	pdflush_operation(laptop_flush, 0);
+	pdflush_operation(laptop_flush, 0, NULL);
 }
 
 /*
diff -uprN -X 0/Documentation/dontdiff 1/mm/pdflush.c 2/mm/pdflush.c
--- 1/mm/pdflush.c	2007-09-11 14:36:06.000000000 -0700
+++ 2/mm/pdflush.c	2007-09-11 14:39:22.000000000 -0700
@@ -83,10 +83,12 @@ static unsigned long last_empty_jifs;
  */
 struct pdflush_work {
 	struct task_struct *who;	/* The thread */
-	void (*fn)(unsigned long);	/* A callback function */
+	void (*fn)(unsigned long, nodemask_t *); /* A callback function */
 	unsigned long arg0;		/* An argument to the callback */
 	struct list_head list;		/* On pdflush_list, when idle */
 	unsigned long when_i_went_to_sleep;
+	int have_nodes;			/* Nodes were specified */
+	nodemask_t nodes;		/* Nodes of interest */
 };
 
 static int __pdflush(struct pdflush_work *my_work)
@@ -124,7 +126,8 @@ static int __pdflush(struct pdflush_work
 		}
 		spin_unlock_irq(&pdflush_lock);
 
-		(*my_work->fn)(my_work->arg0);
+		(*my_work->fn)(my_work->arg0,
+			my_work->have_nodes ? &my_work->nodes : NULL);
 
 		/*
 		 * Thread creation: For how long have there been zero
@@ -198,7 +201,8 @@ static int pdflush(void *dummy)
  * Returns zero if it indeed managed to find a worker thread, and passed your
  * payload to it.
  */
-int pdflush_operation(void (*fn)(unsigned long), unsigned long arg0)
+int pdflush_operation(void (*fn)(unsigned long, nodemask_t *),
+			unsigned long arg0, nodemask_t *nodes)
 {
 	unsigned long flags;
 	int ret = 0;
@@ -218,6 +222,11 @@ int pdflush_operation(void (*fn)(unsigne
 			last_empty_jifs = jiffies;
 		pdf->fn = fn;
 		pdf->arg0 = arg0;
+		if (nodes) {
+			pdf->nodes = *nodes;
+			pdf->have_nodes = 1;
+		} else
+			pdf->have_nodes = 0;
 		wake_up_process(pdf->who);
 		spin_unlock_irqrestore(&pdflush_lock, flags);
 	}
diff -uprN -X 0/Documentation/dontdiff 1/mm/vmscan.c 2/mm/vmscan.c
--- 1/mm/vmscan.c	2007-09-11 14:36:06.000000000 -0700
+++ 2/mm/vmscan.c	2007-09-11 14:41:41.000000000 -0700
@@ -1301,7 +1301,7 @@ unsigned long do_try_to_free_pages(struc
 		 */
 		if (total_scanned > sc->swap_cluster_max +
 					sc->swap_cluster_max / 2) {
-			wakeup_pdflush(laptop_mode ? 0 : total_scanned);
+			wakeup_pdflush(laptop_mode ? 0 : total_scanned, NULL);
 			sc->may_writepage = 1;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
