Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 865036B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 18:16:21 -0400 (EDT)
Date: Fri, 26 Jun 2009 01:18:16 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: kmemleak suggestion (long message)
Message-ID: <20090625221816.GA3480@localdomain.by>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.

Currently kmemleak prints info about all objects. I guess sometimes kmemleak gives you more than you actually need.
syslog:
...
kmemleak: unreferenced object 0xf702fad0 (size 152):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e4b91>] kmem_cache_alloc+0x111/0x1c0
kmemleak:     [<c123b0c4>] idr_pre_get+0x64/0x90
kmemleak:     [<c123b115>] ida_pre_get+0x25/0xe0
kmemleak:     [<c10edf3f>] set_anon_super+0x2f/0xf0
kmemleak:     [<c10eea50>] sget+0x2d0/0x390
kmemleak:     [<c10ef0f1>] get_sb_single+0x41/0xd0
kmemleak:     [<c114a3f8>] sysfs_get_sb+0x28/0x40
kmemleak:     [<c10eeea1>] vfs_kern_mount+0x71/0x150
kmemleak:     [<c10eefa1>] kern_mount_data+0x21/0x40
kmemleak:     [<c15cb2f5>] sysfs_init+0x67/0xcc
kmemleak:     [<c15ca0f0>] mnt_init+0x9d/0x182
kmemleak:     [<c15c9ca6>] vfs_caches_init+0x10d/0x130
kmemleak:     [<c15aca26>] start_kernel+0x2f4/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
kmemleak: unreferenced object 0xf702fa20 (size 152):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e4b91>] kmem_cache_alloc+0x111/0x1c0
kmemleak:     [<c123b0c4>] idr_pre_get+0x64/0x90
kmemleak:     [<c123b115>] ida_pre_get+0x25/0xe0
kmemleak:     [<c10edf3f>] set_anon_super+0x2f/0xf0
kmemleak:     [<c10eea50>] sget+0x2d0/0x390
kmemleak:     [<c10ef0f1>] get_sb_single+0x41/0xd0
kmemleak:     [<c114a3f8>] sysfs_get_sb+0x28/0x40
kmemleak:     [<c10eeea1>] vfs_kern_mount+0x71/0x150
kmemleak:     [<c10eefa1>] kern_mount_data+0x21/0x40
kmemleak:     [<c15cb2f5>] sysfs_init+0x67/0xcc
kmemleak:     [<c15ca0f0>] mnt_init+0x9d/0x182
kmemleak:     [<c15c9ca6>] vfs_caches_init+0x10d/0x130
kmemleak:     [<c15aca26>] start_kernel+0x2f4/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
...
kmemleak: unreferenced object 0xf7028140 (size 1024):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e584d>] __kmalloc+0x16d/0x210
kmemleak:     [<c10e5bcd>] alloc_arraycache+0x2d/0x70
kmemleak:     [<c10e5e46>] do_tune_cpucache+0x236/0x3e0
kmemleak:     [<c10e6192>] enable_cpucache+0x42/0x110
kmemleak:     [<c13ec2a3>] setup_cpu_cache+0x183/0x2a0
kmemleak:     [<c10e65f5>] kmem_cache_create+0x395/0x5a0
kmemleak:     [<c15cf0d1>] radix_tree_init+0x33/0x87
kmemleak:     [<c15aca2b>] start_kernel+0x2f9/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
kmemleak: unreferenced object 0xf70057b0 (size 128):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e584d>] __kmalloc+0x16d/0x210
kmemleak:     [<c113b729>] __proc_create+0x99/0x120
kmemleak:     [<c113c143>] proc_symlink+0x33/0xb0
kmemleak:     [<c15cac41>] proc_root_init+0x60/0xbe
kmemleak:     [<c15aca3a>] start_kernel+0x308/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
....
kmemleak: unreferenced object 0xf702fce0 (size 152):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e4b91>] kmem_cache_alloc+0x111/0x1c0
kmemleak:     [<c123b0c4>] idr_pre_get+0x64/0x90
kmemleak:     [<c123b115>] ida_pre_get+0x25/0xe0
kmemleak:     [<c113bcaf>] proc_register+0x2f/0x1e0
kmemleak:     [<c113c17e>] proc_symlink+0x6e/0xb0
kmemleak:     [<c15cac41>] proc_root_init+0x60/0xbe
kmemleak:     [<c15aca3a>] start_kernel+0x308/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
....x10

Suppose, I'm monitoring application which never calls "[<c123b0c4>] idr_pre_get" or 
"[<c12cf49b>] tty_ldisc_try_get". It would be nice to "temporarily turn-off unimportant" output. 
I suggest to give ability to "blacklist" function(s). I did it via printed by kmemleak function address %p 
(like [<c10e963b>]) since it's impossible to assume what objects will be reported in next YYY seconds 
("unreferenced object 0xf702fce0"). (It's possible to "blacklist" according to function name 
(like idr_pre_get) but I think %p is quite enough).

For example, to avoid some notifications I just copy-paste address from printed stack:
echo "block=c123b0c4" > /sys/kernel/debug/kmemleak

//debug output
kmemleak: Added to blacklist: <c123b0c4>

syslog:
kmemleak: unreferenced object 0xf7049a10 (size 1024):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e584d>] __kmalloc+0x16d/0x210
kmemleak:     [<c10e5bcd>] alloc_arraycache+0x2d/0x70
kmemleak:     [<c10e5e46>] do_tune_cpucache+0x236/0x3e0
kmemleak:     [<c10e6192>] enable_cpucache+0x42/0x110
kmemleak:     [<c13ec2a3>] setup_cpu_cache+0x183/0x2a0
kmemleak:     [<c10e65f5>] kmem_cache_create+0x395/0x5a0
kmemleak:     [<c15c2a6b>] signals_init+0x34/0x4c
kmemleak:     [<c15aca30>] start_kernel+0x2fe/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
kmemleak: unreferenced object 0xf70495f8 (size 1024):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e584d>] __kmalloc+0x16d/0x210
kmemleak:     [<c10e5bcd>] alloc_arraycache+0x2d/0x70
kmemleak:     [<c10e5e46>] do_tune_cpucache+0x236/0x3e0
kmemleak:     [<c10e6192>] enable_cpucache+0x42/0x110
kmemleak:     [<c13ec2a3>] setup_cpu_cache+0x183/0x2a0
kmemleak:     [<c10e65f5>] kmem_cache_create+0x395/0x5a0
kmemleak:     [<c15cabc9>] proc_init_inodecache+0x31/0x49
kmemleak:     [<c15cabf7>] proc_root_init+0x16/0xbe
kmemleak:     [<c15aca3a>] start_kernel+0x308/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
kmemleak: unreferenced object 0xf70057b0 (size 128):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e584d>] __kmalloc+0x16d/0x210
kmemleak:     [<c113b729>] __proc_create+0x99/0x120
kmemleak:     [<c113c143>] proc_symlink+0x33/0xb0
kmemleak:     [<c15cac41>] proc_root_init+0x60/0xbe
kmemleak:     [<c15aca3a>] start_kernel+0x308/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
...
//Debug output showing that we have blocked objects.
kmemleak: Function blacklisted <c123b0c4>
kmemleak: Function blacklisted <c123b0c4>
kmemleak: Function blacklisted <c123b0c4>
kmemleak: Function blacklisted <c123b0c4>
kmemleak: Function blacklisted <c123b0c4>
kmemleak: Function blacklisted <c123b0c4>
kmemleak: Function blacklisted <c123b0c4>
kmemleak: Function blacklisted <c123b0c4>
kmemleak: Function blacklisted <c123b0c4>
kmemleak: Function blacklisted <c123b0c4>
kmemleak: Function blacklisted <c123b0c4>
...
kmemleak: unreferenced object 0xf7005680 (size 128):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e584d>] __kmalloc+0x16d/0x210
kmemleak:     [<c113b729>] __proc_create+0x99/0x120
kmemleak:     [<c113c143>] proc_symlink+0x33/0xb0
kmemleak:     [<c15cb03a>] proc_net_init+0x22/0x3f
kmemleak:     [<c15cac46>] proc_root_init+0x65/0xbe
kmemleak:     [<c15aca3a>] start_kernel+0x308/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff

To unblock:
echo "unblock=c123b0c4" > /sys/kernel/debug/kmemleak

//Debug output
kmemleak: Removed from blacklist <c123b0c4>

syslog:
...
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e4b91>] kmem_cache_alloc+0x111/0x1c0
kmemleak:     [<c123b0c4>] idr_pre_get+0x64/0x90
kmemleak:     [<c123b115>] ida_pre_get+0x25/0xe0
kmemleak:     [<c113bcaf>] proc_register+0x2f/0x1e0
kmemleak:     [<c113c17e>] proc_symlink+0x6e/0xb0
kmemleak:     [<c15cac41>] proc_root_init+0x60/0xbe
kmemleak:     [<c15aca3a>] start_kernel+0x308/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
kmemleak: unreferenced object 0xf7037810 (size 152):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e4b91>] kmem_cache_alloc+0x111/0x1c0
kmemleak:     [<c123b0c4>] idr_pre_get+0x64/0x90
kmemleak:     [<c123b115>] ida_pre_get+0x25/0xe0
kmemleak:     [<c113bcaf>] proc_register+0x2f/0x1e0
kmemleak:     [<c113c17e>] proc_symlink+0x6e/0xb0
kmemleak:     [<c15cac41>] proc_root_init+0x60/0xbe
kmemleak:     [<c15aca3a>] start_kernel+0x308/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
kmemleak: unreferenced object 0xf7037760 (size 152):
kmemleak:   comm "swapper", pid 0, jiffies 4294877296
kmemleak:   backtrace:
kmemleak:     [<c10e963b>] kmemleak_alloc+0x11b/0x2b0
kmemleak:     [<c10e4b91>] kmem_cache_alloc+0x111/0x1c0
kmemleak:     [<c123b0c4>] idr_pre_get+0x64/0x90
kmemleak:     [<c123b115>] ida_pre_get+0x25/0xe0
kmemleak:     [<c113bcaf>] proc_register+0x2f/0x1e0
kmemleak:     [<c113c17e>] proc_symlink+0x6e/0xb0
kmemleak:     [<c15cac41>] proc_root_init+0x60/0xbe
kmemleak:     [<c15aca3a>] start_kernel+0x308/0x343
kmemleak:     [<c15ac088>] __init_begin+0x88/0xa1
kmemleak:     [<ffffffff>] 0xffffffff
...

As you can see, I'm not blocking monitoring of any object. I just suppress output of objects with "unwanted" 
addresses in stack.

Other useful feature (to my mind) - block according to pid. (Or block "if pid != <the_one_I_want>").

"block=XXXX"/"unblock=XXXX" is _very_ general. I should use block-address/block-function/filter-by-address, etc.
Here is code I wrote today (it's just a concept. Not 'beta' or something like this.).
It's against kmemleak.c without CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE support.

If you like the basic idea - I'll continue my work.
Any comments are highly appreciable.

---
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index c96f2c8..7a20898 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -153,6 +153,14 @@ struct kmemleak_object {
 	char comm[TASK_COMM_LEN];	/* executable name */
 };
 
+/*
+ * Structure holding the data for each unwanted address (blacklisted function).
+ */
+struct kmemleak_function {
+	unsigned int pointer;
+	struct list_head function_list;
+};
+
 /* flag representing the memory block allocation status */
 #define OBJECT_ALLOCATED	(1 << 0)
 /* flag set after the first reporting of an unreference object */
@@ -164,10 +172,14 @@ struct kmemleak_object {
 static LIST_HEAD(object_list);
 /* the list of gray-colored objects (see color_gray comment below) */
 static LIST_HEAD(gray_list);
+/* the list of blacklisted functions */
+static LIST_HEAD(function_list);
 /* prio search tree for object boundaries */
 static struct prio_tree_root object_tree_root;
 /* rw_lock protecting the access to object_list and prio_tree_root */
 static DEFINE_RWLOCK(kmemleak_lock);
+/* spinlock protecting the access to function_list*/
+static DEFINE_RWLOCK(function_list_lock);
 
 /* allocation caches for kmemleak internal data */
 static struct kmem_cache *object_cache;
@@ -258,6 +270,102 @@ static void kmemleak_disable(void);
 	kmemleak_disable();		\
 } while (0)
 
+
+static int lookup_function(unsigned long pointer) {
+	struct kmemleak_function *function;
+	unsigned long flags;
+
+	/*Find out if given address (pointer) is in blacklist.
+	 *
+	 */
+	read_lock_irqsave(&function_list_lock, flags);
+	list_for_each_entry(function, &function_list, function_list) {
+		if( function->pointer == pointer) {
+			pr_info("Function already blacklisted <%p>\n", (void*)pointer);
+			return 1;
+		}
+	}
+	read_unlock_irqrestore(&function_list_lock, flags);
+	
+	return 0;
+}
+
+
+static void create_function(unsigned long pointer) {
+	unsigned long flags;
+	struct kmemleak_function *function;
+
+	/*prevent multi-blacklisted*/
+	if( lookup_function(pointer) )
+		return;
+
+	/*Is it ok? Should I allocate in cache (like objects)?*/
+	function = kmalloc(sizeof(struct kmemleak_function), GFP_KERNEL & GFP_KMEMLEAK_MASK);
+	if( !function ) {
+		kmemleak_warn("Cannot allocate a kmemleak_function structure\n");
+		return;
+	}
+
+	function->pointer = pointer;
+	INIT_LIST_HEAD(&function->function_list);
+	
+	write_lock_irqsave(&function_list_lock, flags);
+	list_add(&function->function_list, &function_list);
+	write_unlock_irqrestore(&function_list_lock, flags);
+
+	pr_info("Added to blacklist: <%p>\n", (void*)pointer);
+}
+
+
+static void delete_function(unsigned long pointer) {
+	unsigned long flags;
+	struct kmemleak_function *function;
+
+	write_lock_irqsave(&function_list_lock, flags);
+
+	list_for_each_entry(function, &function_list, function_list) {
+		if( function->pointer == pointer ) {
+			list_del(&function->function_list);
+			/*Again. Is it ok?*/
+			kfree(function);
+			write_unlock_irqrestore(&function_list_lock, flags);
+
+			pr_info("Removed from blacklist <%p>\n", (void*)pointer);
+			return;
+		}
+	}
+	
+	write_unlock_irqrestore(&function_list_lock, flags);
+}
+
+
+static int match_function(const unsigned long *trace , int trace_len) {
+	int i;
+	unsigned long flags;
+	struct kmemleak_function *function;
+	
+	read_lock_irqsave(&function_list_lock, flags);
+	/*Most objects usually have more than 10 pointers in stack.
+	 *I don't think that blacklisted count normally will be more that 10 functions.
+	 *So it's better to inner-loop on blacklist.
+	 */
+	list_for_each_entry(function, &function_list, function_list) {
+		for(i = 0; i < trace_len; i++) {
+			if( function->pointer == trace[i]) {
+				read_unlock_irqrestore(&function_list_lock, flags);
+				pr_info("Function blacklisted <%p>\n", (void*)trace[i]);
+				return 1;
+			}
+		}
+	}
+
+	read_unlock_irqrestore(&function_list_lock, flags);
+
+	return 0;
+}
+
+
+
 /*
  * Object colors, encoded with count and min_count:
  * - white - orphan object, not enough references to it (count < min_count)
@@ -321,6 +429,15 @@ static void print_unreferenced(struct seq_file *seq,
 			       struct kmemleak_object *object)
 {
 	int i;
+	void *ptr;
+ 
+	/*The basic idea is to stop printing object's stack with blacklisted
+	 *function(s). As soon as we whitelist (unblock) function, we'll get this info
+	 *again.
+	 */
+	if( match_function(object->trace, object->trace_len) )
+		return;
+
 
 	print_helper(seq, "unreferenced object 0x%08lx (size %zu):\n",
 		     object->pointer, object->size);
@@ -329,7 +446,7 @@ static void print_unreferenced(struct seq_file *seq,
 	print_helper(seq, "  backtrace:\n");
 
 	for (i = 0; i < object->trace_len; i++) {
-		void *ptr = (void *)object->trace[i];
+		ptr = (void *)object->trace[i];
 		print_helper(seq, "    [<%p>] %pS\n", ptr, ptr);
 	}
 }
@@ -1303,6 +1420,33 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 		start_scan_thread();
 	else if (strncmp(buf, "scan=off", 8) == 0)
 		stop_scan_thread();
+	else if (strncmp(buf, "block=", 6) == 0) {
+		unsigned long pointer;
+		int err;
+		
+		/*or we can force user to pass xADDRESS (base = 0).
+		 *basically, address will be given as simple copy-paste
+		 *from print_XXX stack <%p> (I think so).
+		 */
+		err = strict_strtoul(buf + 6, 16, &pointer);
+		if (err < 0)
+			return err;
+
+		create_function(pointer);
+	}
+	else if (strncmp(buf, "unblock=", 8) ==0 ) {
+		unsigned long pointer;
+		int err;
+
+		/*
+		 *Read comment for block=XXX.
+		 */
+		err = strict_strtoul(buf + 8, 16, &pointer);
+		if (err < 0)
+			return err;
+
+		delete_function(pointer);
+	}
 	else if (strncmp(buf, "scan=", 5) == 0) {
 		unsigned long secs;
 		int err;
@@ -1338,8 +1482,11 @@ static const struct file_operations kmemleak_fops = {
  */
 static int kmemleak_cleanup_thread(void *arg)
 {
+	unsigned long flags;
 	struct kmemleak_object *object;
+	struct kmemleak_function *function;
 
+	
 	mutex_lock(&kmemleak_mutex);
 	stop_scan_thread();
 	mutex_unlock(&kmemleak_mutex);
@@ -1349,6 +1496,15 @@ static int kmemleak_cleanup_thread(void *arg)
 	list_for_each_entry_rcu(object, &object_list, object_list)
 		delete_object(object->pointer);
 	rcu_read_unlock();
+
+	write_lock_irqsave(&function_list_lock, flags);
+	list_for_each_entry(function, &function_list, function_list) {
+		list_del(&function->function_list);
+		kfree(function);
+	}
+	
+	write_unlock_irqrestore(&function_list_lock, flags);
+
 	mutex_unlock(&scan_mutex);
 
 	return 0;


Thanks,
	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
