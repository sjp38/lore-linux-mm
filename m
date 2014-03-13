Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 35BAC6B0031
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 02:48:00 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so680777pab.10
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 23:47:59 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id zt8si1258743pbc.45.2014.03.12.23.47.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 23:47:59 -0700 (PDT)
Message-ID: <53215492.40701@huawei.com>
Date: Thu, 13 Mar 2014 14:47:46 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] kmemleak: allow freeing internal objects after disabling
 kmemleak
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Currently if you disable kmemleak without stopping kmemleak scan
thread, the kmemleak objects can never be freed. It's about 370MB
on my system.

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
1200264 1197433  99%    0.30K  46164	   26    369312K kmemleak_object

With this patch, it's allowed to free those objects by extending the
"clear" command.

	# echo off > kmemleak
	# echo clear > kmemleak

Also inform users if kmemleak is disabled but internal objects are
not freed.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 Documentation/kmemleak.txt | 20 +++++++++++++++++++-
 mm/kmemleak.c              | 44 +++++++++++++++++++++++++++++++-------------
 2 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/Documentation/kmemleak.txt b/Documentation/kmemleak.txt
index 6dc8013..f2b21bb 100644
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
@@ -118,6 +119,23 @@ Then as usual to get your report with:
 
   # cat /sys/kernel/debug/kmemleak
 
+Freeing kmemleak internal objects
+---------------------------------
+
+To allow access to previosuly found memory leaks even when an error fatal
+to kmemleak happens, internal kmemleak objects won't be freed when kmemleak
+is disabled, and those objects may occupy a large part of physical
+memory.
+
+If you want to make sure they're freed before disabling kmemleak:
+
+  # echo scan=off > /sys/kernel/debug/kmemleak
+  # echo off > /sys/kernel/debug/kmemleak
+
+If kmemleak has been disabled, you can reclaim memory with:
+
+  # echo clear > /sys/kernel/debug/kmemleak
+
 Kmemleak API
 ------------
 
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 31f01c5..c7d4b94 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1594,6 +1594,8 @@ static void kmemleak_clear(void)
 	rcu_read_unlock();
 }
 
+static void __kmemleak_do_cleanup(void);
+
 /*
  * File write operation to configure kmemleak at run-time. The following
  * commands can be written to the /sys/kernel/debug/kmemleak file:
@@ -1606,7 +1608,8 @@ static void kmemleak_clear(void)
  *		  disable it)
  *   scan	- trigger a memory scan
  *   clear	- mark all current reported unreferenced kmemleak objects as
- *		  grey to ignore printing them
+ *		  grey to ignore printing them, or free all kmemleak objects
+ *		  if kmemleak has been disabled.
  *   dump=...	- dump information about the object found at the given address
  */
 static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
@@ -1616,9 +1619,6 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 	int buf_size;
 	int ret;
 
-	if (!atomic_read(&kmemleak_enabled))
-		return -EBUSY;
-
 	buf_size = min(size, (sizeof(buf) - 1));
 	if (strncpy_from_user(buf, user_buf, buf_size) < 0)
 		return -EFAULT;
@@ -1628,6 +1628,19 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
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
@@ -1651,8 +1664,6 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 		}
 	} else if (strncmp(buf, "scan", 4) == 0)
 		kmemleak_scan();
-	else if (strncmp(buf, "clear", 5) == 0)
-		kmemleak_clear();
 	else if (strncmp(buf, "dump=", 5) == 0)
 		ret = dump_str_object_info(buf + 5);
 	else
@@ -1677,6 +1688,16 @@ static const struct file_operations kmemleak_fops = {
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
@@ -1684,18 +1705,15 @@ static const struct file_operations kmemleak_fops = {
  */
 static void kmemleak_do_cleanup(struct work_struct *work)
 {
-	struct kmemleak_object *object;
 	bool cleanup = scan_thread == NULL;
 
 	mutex_lock(&scan_mutex);
 	stop_scan_thread();
 
-	if (cleanup) {
-		rcu_read_lock();
-		list_for_each_entry_rcu(object, &object_list, object_list)
-			delete_object_full(object->pointer);
-		rcu_read_unlock();
-	}
+	if (cleanup)
+		__kmemleak_do_cleanup();
+	else
+		pr_info("You may free internal objects by \"echo clear > kmemleak\"\n");
 	mutex_unlock(&scan_mutex);
 }
 
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
