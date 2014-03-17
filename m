Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 350CA6B004D
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 00:09:06 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so5179223pad.21
        for <linux-mm@kvack.org>; Sun, 16 Mar 2014 21:09:05 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id uc9si3601466pac.7.2014.03.16.21.09.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Mar 2014 21:09:05 -0700 (PDT)
Message-ID: <5326750E.1000004@huawei.com>
Date: Mon, 17 Mar 2014 12:07:42 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v2 1/3] kmemleak: allow freeing internal objects after kmemleak
 was disabled
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Currently if kmemleak is disabled, the kmemleak objects can never be freed,
no matter if it's disabled by a user or due to fatal errors.

Those objects can be a big waste of memory.

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
1200264 1197433  99%    0.30K  46164       26    369312K kmemleak_object

With this patch, internal objects will be freed immediately if kmemleak is
disabled explicitly by a user. If it's disabled due to a kmemleak error,
The user will be informed, and then he/she can reclaim memory with:

	# echo off > /sys/kernel/debug/kmemleak

v2: use "off" handler instead of "clear" handler to do this, suggested
    by Catalin.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 Documentation/kmemleak.txt | 14 +++++++++++++-
 mm/kmemleak.c              | 21 ++++++++++++++++-----
 2 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/Documentation/kmemleak.txt b/Documentation/kmemleak.txt
index 6dc8013..00aa013 100644
--- a/Documentation/kmemleak.txt
+++ b/Documentation/kmemleak.txt
@@ -42,7 +42,8 @@ objects to be reported as orphan.
 Memory scanning parameters can be modified at run-time by writing to the
 /sys/kernel/debug/kmemleak file. The following parameters are supported:
 
-  off		- disable kmemleak (irreversible)
+  off		- disable kmemleak, or free all kmemleak objects if kmemleak
+		  has been disabled due to fatal errors. (irreversible).
   stack=on	- enable the task stacks scanning (default)
   stack=off	- disable the tasks stacks scanning
   scan=on	- start the automatic memory scanning thread (default)
@@ -118,6 +119,17 @@ Then as usual to get your report with:
 
   # cat /sys/kernel/debug/kmemleak
 
+Freeing kmemleak internal objects
+---------------------------------
+
+To allow access to previously found memory leaks even when an error fatal
+to kmemleak happens, internal kmemleak objects won't be freed in this case.
+Those objects may occupy a large part of physical memory.
+
+You can reclaim memory from those objects with:
+
+  # echo off > /sys/kernel/debug/kmemleak
+
 Kmemleak API
 ------------
 
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 31f01c5..7fc030e 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1616,9 +1616,6 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 	int buf_size;
 	int ret;
 
-	if (!atomic_read(&kmemleak_enabled))
-		return -EBUSY;
-
 	buf_size = min(size, (sizeof(buf) - 1));
 	if (strncpy_from_user(buf, user_buf, buf_size) < 0)
 		return -EFAULT;
@@ -1628,9 +1625,18 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 	if (ret < 0)
 		return ret;
 
-	if (strncmp(buf, "off", 3) == 0)
+	if (strncmp(buf, "off", 3) == 0) {
+		stop_scan_thread();
 		kmemleak_disable();
-	else if (strncmp(buf, "stack=on", 8) == 0)
+		goto out;
+	}
+
+	if (!atomic_read(&kmemleak_enabled)) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	if (strncmp(buf, "stack=on", 8) == 0)
 		kmemleak_stack_scan = 1;
 	else if (strncmp(buf, "stack=off", 9) == 0)
 		kmemleak_stack_scan = 0;
@@ -1695,6 +1701,11 @@ static void kmemleak_do_cleanup(struct work_struct *work)
 		list_for_each_entry_rcu(object, &object_list, object_list)
 			delete_object_full(object->pointer);
 		rcu_read_unlock();
+	} else {
+		pr_info("Disable kmemleak without freeing internal objects, "
+			"so you may still check information on memory leak. "
+			"You may reclaim memory by writing \"off\" to "
+			"/sys/kernel/debug/kmemleak\n");
 	}
 	mutex_unlock(&scan_mutex);
 }
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
