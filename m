Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE8E6B0036
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 04:53:41 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so4753853pab.27
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 01:53:41 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id il2si3244312pbc.306.2014.03.28.01.53.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 01:53:40 -0700 (PDT)
Message-ID: <5335387E.2050005@huawei.com>
Date: Fri, 28 Mar 2014 16:53:18 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v3 2/4] kmemleak: allow freeing internal objects after kmemleak
 was disabled
References: <5335384A.2000000@huawei.com>
In-Reply-To: <5335384A.2000000@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Currently if kmemleak is disabled, the kmemleak objects can never be
freed, no matter if it's disabled by a user or due to fatal errors.

Those objects can be a big waste of memory.

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
1200264 1197433  99%    0.30K  46164       26    369312K kmemleak_object

With this patch, after kmemleak was disabled you can reclaim memory with:

	# echo clear > /sys/kernel/debug/kmemleak

Also inform users about this with a printk.

v3: Catalin wasn't suggesting to use "off" handler, but he wants to be
    able to read memory leaks even when kmemleak is explicitly disabled.

v2: use "off" handler instead of "clear" handler to do this, suggested
    by Catalin.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 Documentation/kmemleak.txt | 15 ++++++++++++++-
 mm/kmemleak.c              | 48 ++++++++++++++++++++++++++++++++--------------
 2 files changed, 48 insertions(+), 15 deletions(-)

diff --git a/Documentation/kmemleak.txt b/Documentation/kmemleak.txt
index 6dc8013..a7e6a06 100644
--- a/Documentation/kmemleak.txt
+++ b/Documentation/kmemleak.txt
@@ -51,7 +51,8 @@ Memory scanning parameters can be modified at run-time by writing to the
 		  (default 600, 0 to stop the automatic scanning)
   scan		- trigger a memory scan
   clear		- clear list of current memory leak suspects, done by
-		  marking all current reported unreferenced objects grey
+		  marking all current reported unreferenced objects grey.
+		  Or free all kmemleak objects if kmemleak has been disabled.
   dump=<addr>	- dump information about the object found at <addr>
 
 Kmemleak can also be disabled at boot-time by passing "kmemleak=off" on
@@ -118,6 +119,18 @@ Then as usual to get your report with:
 
   # cat /sys/kernel/debug/kmemleak
 
+Freeing kmemleak internal objects
+---------------------------------
+
+To allow access to previosuly found memory leaks after kmemleak has been
+disabled by the user or due to an fatal error, internal kmemleak objects
+won't be freed when kmemleak is disabled, and those objects may occupy
+a large part of physical memory.
+
+In this situation, you may reclaim memory with:
+
+  # echo clear > /sys/kernel/debug/kmemleak
+
 Kmemleak API
 ------------
 
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index be7ecc0..6631df8 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1600,6 +1600,8 @@ static void kmemleak_clear(void)
 	kmemleak_has_leaks = false;
 }
 
+static void __kmemleak_do_cleanup(void);
+
 /*
  * File write operation to configure kmemleak at run-time. The following
  * commands can be written to the /sys/kernel/debug/kmemleak file:
@@ -1612,7 +1614,8 @@ static void kmemleak_clear(void)
  *		  disable it)
  *   scan	- trigger a memory scan
  *   clear	- mark all current reported unreferenced kmemleak objects as
- *		  grey to ignore printing them
+ *		  grey to ignore printing them, or free all kmemleak objects
+ *		  if kmemleak has been disabled.
  *   dump=...	- dump information about the object found at the given address
  */
 static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
@@ -1622,9 +1625,6 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 	int buf_size;
 	int ret;
 
-	if (!atomic_read(&kmemleak_enabled))
-		return -EBUSY;
-
 	buf_size = min(size, (sizeof(buf) - 1));
 	if (strncpy_from_user(buf, user_buf, buf_size) < 0)
 		return -EFAULT;
@@ -1634,6 +1634,19 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 	if (ret < 0)
 		return ret;
 
+	if (strncmp(buf, "clear", 5) == 0) {
+		if (atomic_read(&kmemleak_enabled))
+			kmemleak_clear();
+		else
+			__kmemleak_do_cleanup();
+		goto out;
+	}
+
+	if (!atomic_read(&kmemleak_enabled)) {
+		ret = -EBUSY;
+		goto out;
+	}
+
 	if (strncmp(buf, "off", 3) == 0)
 		kmemleak_disable();
 	else if (strncmp(buf, "stack=on", 8) == 0)
@@ -1657,8 +1670,6 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 		}
 	} else if (strncmp(buf, "scan", 4) == 0)
 		kmemleak_scan();
-	else if (strncmp(buf, "clear", 5) == 0)
-		kmemleak_clear();
 	else if (strncmp(buf, "dump=", 5) == 0)
 		ret = dump_str_object_info(buf + 5);
 	else
@@ -1683,6 +1694,16 @@ static const struct file_operations kmemleak_fops = {
 	.release	= kmemleak_release,
 };
 
+static void __kmemleak_do_cleanup(void)
+{
+	struct kmemleak_object *object;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(object, &object_list, object_list)
+		delete_object_full(object->pointer);
+	rcu_read_unlock();
+}
+
 /*
  * Stop the memory scanning thread and free the kmemleak internal objects if
  * no previous scan thread (otherwise, kmemleak may still have some useful
@@ -1690,17 +1711,16 @@ static const struct file_operations kmemleak_fops = {
  */
 static void kmemleak_do_cleanup(struct work_struct *work)
 {
-	struct kmemleak_object *object;
-
 	mutex_lock(&scan_mutex);
 	stop_scan_thread();
 
-	if (!kmemleak_has_leaks) {
-		rcu_read_lock();
-		list_for_each_entry_rcu(object, &object_list, object_list)
-			delete_object_full(object->pointer);
-		rcu_read_unlock();
-	}
+	if (!kmemleak_has_leaks)
+		__kmemleak_do_cleanup();
+	else
+		pr_info("Disable kmemleak without freeing internal objects, "
+			"so you may still check information on memory leaks. "
+			"You may reclaim memory by writing \"clear\" to "
+			"/sys/kernel/debug/kmemleak\n");
 	mutex_unlock(&scan_mutex);
 }
 
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
