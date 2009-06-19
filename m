Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 91B0B6B005A
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 05:52:06 -0400 (EDT)
Subject: Re: [PATCH] kmemleak: use pr_fmt
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <1245341337.29927.8.camel@Joe-Laptop.home>
References: <1245341337.29927.8.camel@Joe-Laptop.home>
Content-Type: text/plain
Date: Fri, 19 Jun 2009 10:53:40 +0100
Message-Id: <1245405220.12653.25.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-06-18 at 09:08 -0700, Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>

Thanks for the patch. It missed one pr_info case (actually invoked via
the pr_helper macro).

> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index ec759b6..83ab216 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -61,6 +61,8 @@
>   * structure.
>   */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> + 
   ^ - empty space at the end of the line (git told me about it)

Below is a slightly updated patch (I can push it to Linus if you want):


kmemleak: use pr_fmt

From: Joe Perches <joe@perches.com>

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/kmemleak.c |   52 ++++++++++++++++++++++++----------------------------
 1 files changed, 24 insertions(+), 28 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index ec759b6..c96f2c8 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -61,6 +61,8 @@
  * structure.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
@@ -311,7 +313,7 @@ static int unreferenced_object(struct kmemleak_object *object)
 
 static void print_referenced(struct kmemleak_object *object)
 {
-	pr_info("kmemleak: referenced object 0x%08lx (size %zu)\n",
+	pr_info("referenced object 0x%08lx (size %zu)\n",
 		object->pointer, object->size);
 }
 
@@ -320,7 +322,7 @@ static void print_unreferenced(struct seq_file *seq,
 {
 	int i;
 
-	print_helper(seq, "kmemleak: unreferenced object 0x%08lx (size %zu):\n",
+	print_helper(seq, "unreferenced object 0x%08lx (size %zu):\n",
 		     object->pointer, object->size);
 	print_helper(seq, "  comm \"%s\", pid %d, jiffies %lu\n",
 		     object->comm, object->pid, object->jiffies);
@@ -344,7 +346,7 @@ static void dump_object_info(struct kmemleak_object *object)
 	trace.nr_entries = object->trace_len;
 	trace.entries = object->trace;
 
-	pr_notice("kmemleak: Object 0x%08lx (size %zu):\n",
+	pr_notice("Object 0x%08lx (size %zu):\n",
 		  object->tree_node.start, object->size);
 	pr_notice("  comm \"%s\", pid %d, jiffies %lu\n",
 		  object->comm, object->pid, object->jiffies);
@@ -372,7 +374,7 @@ static struct kmemleak_object *lookup_object(unsigned long ptr, int alias)
 		object = prio_tree_entry(node, struct kmemleak_object,
 					 tree_node);
 		if (!alias && object->pointer != ptr) {
-			kmemleak_warn("kmemleak: Found object by alias");
+			kmemleak_warn("Found object by alias");
 			object = NULL;
 		}
 	} else
@@ -467,8 +469,7 @@ static void create_object(unsigned long ptr, size_t size, int min_count,
 
 	object = kmem_cache_alloc(object_cache, gfp & GFP_KMEMLEAK_MASK);
 	if (!object) {
-		kmemleak_stop("kmemleak: Cannot allocate a kmemleak_object "
-			      "structure\n");
+		kmemleak_stop("Cannot allocate a kmemleak_object structure\n");
 		return;
 	}
 
@@ -527,8 +528,8 @@ static void create_object(unsigned long ptr, size_t size, int min_count,
 	if (node != &object->tree_node) {
 		unsigned long flags;
 
-		kmemleak_stop("kmemleak: Cannot insert 0x%lx into the object "
-			      "search tree (already existing)\n", ptr);
+		kmemleak_stop("Cannot insert 0x%lx into the object search tree "
+			      "(already existing)\n", ptr);
 		object = lookup_object(ptr, 1);
 		spin_lock_irqsave(&object->lock, flags);
 		dump_object_info(object);
@@ -553,7 +554,7 @@ static void delete_object(unsigned long ptr)
 	write_lock_irqsave(&kmemleak_lock, flags);
 	object = lookup_object(ptr, 0);
 	if (!object) {
-		kmemleak_warn("kmemleak: Freeing unknown object at 0x%08lx\n",
+		kmemleak_warn("Freeing unknown object at 0x%08lx\n",
 			      ptr);
 		write_unlock_irqrestore(&kmemleak_lock, flags);
 		return;
@@ -588,8 +589,7 @@ static void make_gray_object(unsigned long ptr)
 
 	object = find_and_get_object(ptr, 0);
 	if (!object) {
-		kmemleak_warn("kmemleak: Graying unknown object at 0x%08lx\n",
-			      ptr);
+		kmemleak_warn("Graying unknown object at 0x%08lx\n", ptr);
 		return;
 	}
 
@@ -610,8 +610,7 @@ static void make_black_object(unsigned long ptr)
 
 	object = find_and_get_object(ptr, 0);
 	if (!object) {
-		kmemleak_warn("kmemleak: Blacking unknown object at 0x%08lx\n",
-			      ptr);
+		kmemleak_warn("Blacking unknown object at 0x%08lx\n", ptr);
 		return;
 	}
 
@@ -634,21 +633,20 @@ static void add_scan_area(unsigned long ptr, unsigned long offset,
 
 	object = find_and_get_object(ptr, 0);
 	if (!object) {
-		kmemleak_warn("kmemleak: Adding scan area to unknown "
-			      "object at 0x%08lx\n", ptr);
+		kmemleak_warn("Adding scan area to unknown object at 0x%08lx\n",
+			      ptr);
 		return;
 	}
 
 	area = kmem_cache_alloc(scan_area_cache, gfp & GFP_KMEMLEAK_MASK);
 	if (!area) {
-		kmemleak_warn("kmemleak: Cannot allocate a scan area\n");
+		kmemleak_warn("Cannot allocate a scan area\n");
 		goto out;
 	}
 
 	spin_lock_irqsave(&object->lock, flags);
 	if (offset + length > object->size) {
-		kmemleak_warn("kmemleak: Scan area larger than object "
-			      "0x%08lx\n", ptr);
+		kmemleak_warn("Scan area larger than object 0x%08lx\n", ptr);
 		dump_object_info(object);
 		kmem_cache_free(scan_area_cache, area);
 		goto out_unlock;
@@ -677,8 +675,7 @@ static void object_no_scan(unsigned long ptr)
 
 	object = find_and_get_object(ptr, 0);
 	if (!object) {
-		kmemleak_warn("kmemleak: Not scanning unknown object at "
-			      "0x%08lx\n", ptr);
+		kmemleak_warn("Not scanning unknown object at 0x%08lx\n", ptr);
 		return;
 	}
 
@@ -699,7 +696,7 @@ static void log_early(int op_type, const void *ptr, size_t size,
 	struct early_log *log;
 
 	if (crt_early_log >= ARRAY_SIZE(early_log)) {
-		kmemleak_stop("kmemleak: Early log buffer exceeded\n");
+		kmemleak_stop("Early log buffer exceeded\n");
 		return;
 	}
 
@@ -966,7 +963,7 @@ static void kmemleak_scan(void)
 		 * 1 reference to any object at this point.
 		 */
 		if (atomic_read(&object->use_count) > 1) {
-			pr_debug("kmemleak: object->use_count = %d\n",
+			pr_debug("object->use_count = %d\n",
 				 atomic_read(&object->use_count));
 			dump_object_info(object);
 		}
@@ -1062,7 +1059,7 @@ static int kmemleak_scan_thread(void *arg)
 {
 	static int first_run = 1;
 
-	pr_info("kmemleak: Automatic memory scanning thread started\n");
+	pr_info("Automatic memory scanning thread started\n");
 
 	/*
 	 * Wait before the first scan to allow the system to fully initialize.
@@ -1108,7 +1105,7 @@ static int kmemleak_scan_thread(void *arg)
 			timeout = schedule_timeout_interruptible(timeout);
 	}
 
-	pr_info("kmemleak: Automatic memory scanning thread ended\n");
+	pr_info("Automatic memory scanning thread ended\n");
 
 	return 0;
 }
@@ -1123,7 +1120,7 @@ void start_scan_thread(void)
 		return;
 	scan_thread = kthread_run(kmemleak_scan_thread, NULL, "kmemleak");
 	if (IS_ERR(scan_thread)) {
-		pr_warning("kmemleak: Failed to create the scan thread\n");
+		pr_warning("Failed to create the scan thread\n");
 		scan_thread = NULL;
 	}
 }
@@ -1367,7 +1364,7 @@ static void kmemleak_cleanup(void)
 	cleanup_thread = kthread_run(kmemleak_cleanup_thread, NULL,
 				     "kmemleak-clean");
 	if (IS_ERR(cleanup_thread))
-		pr_warning("kmemleak: Failed to create the clean-up thread\n");
+		pr_warning("Failed to create the clean-up thread\n");
 }
 
 /*
@@ -1488,8 +1485,7 @@ static int __init kmemleak_late_init(void)
 	dentry = debugfs_create_file("kmemleak", S_IRUGO, NULL, NULL,
 				     &kmemleak_fops);
 	if (!dentry)
-		pr_warning("kmemleak: Failed to create the debugfs kmemleak "
-			   "file\n");
+		pr_warning("Failed to create the debugfs kmemleak file\n");
 	mutex_lock(&kmemleak_mutex);
 	start_scan_thread();
 	mutex_unlock(&kmemleak_mutex);


-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
