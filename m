Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id CFC5D6B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 04:42:16 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id un15so205566pbc.18
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 01:42:16 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id i8si2192746pav.248.2014.01.17.01.42.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 01:42:15 -0800 (PST)
Message-ID: <52D8FA72.8080100@huawei.com>
Date: Fri, 17 Jan 2014 17:40:02 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/kmemleak: add support for re-enable kmemleak at runtime
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: catalin.marinas@arm.com, rob@landley.net, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>

Now disabling kmemleak is an irreversible operation, but sometimes
we may need to re-enable kmemleak at runtime. So add a knob to enable
kmemleak at runtime:
echo on > /sys/kernel/debug/kmemleak

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 Documentation/kmemleak.txt |    3 ++-
 mm/kmemleak.c              |   37 +++++++++++++++++++++++++++++++++----
 2 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/Documentation/kmemleak.txt b/Documentation/kmemleak.txt
index b6e3973..8ec56ad 100644
--- a/Documentation/kmemleak.txt
+++ b/Documentation/kmemleak.txt
@@ -44,7 +44,8 @@ objects to be reported as orphan.
 Memory scanning parameters can be modified at run-time by writing to the
 /sys/kernel/debug/kmemleak file. The following parameters are supported:
 
-  off		- disable kmemleak (irreversible)
+  off		- disable kmemleak
+  on		- enable kmemleak
   stack=on	- enable the task stacks scanning (default)
   stack=off	- disable the tasks stacks scanning
   scan=on	- start the automatic memory scanning thread (default)
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 31f01c5..02f292c 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -260,6 +260,7 @@ static struct early_log
 static int crt_early_log __initdata;
 
 static void kmemleak_disable(void);
+static void kmemleak_enable(void);
 
 /*
  * Print a warning and dump the stack trace.
@@ -1616,9 +1617,6 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 	int buf_size;
 	int ret;
 
-	if (!atomic_read(&kmemleak_enabled))
-		return -EBUSY;
-
 	buf_size = min(size, (sizeof(buf) - 1));
 	if (strncpy_from_user(buf, user_buf, buf_size) < 0)
 		return -EFAULT;
@@ -1628,6 +1626,19 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 	if (ret < 0)
 		return ret;
 
+	if (strncmp(buf, "on", 2) == 0) {
+		if (atomic_read(&kmemleak_enabled))
+			ret = -EBUSY;
+		else
+			kmemleak_enable();
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
@@ -1703,7 +1714,7 @@ static DECLARE_WORK(cleanup_work, kmemleak_do_cleanup);
 
 /*
  * Disable kmemleak. No memory allocation/freeing will be traced once this
- * function is called. Disabling kmemleak is an irreversible operation.
+ * function is called.
  */
 static void kmemleak_disable(void)
 {
@@ -1721,6 +1732,24 @@ static void kmemleak_disable(void)
 	pr_info("Kernel memory leak detector disabled\n");
 }
 
+static void kmemleak_enable(void)
+{
+	struct kmemleak_object *object;
+
+	/* free the kmemleak internal objects the previous thread scanned */
+	rcu_read_lock();
+	list_for_each_entry_rcu(object, &object_list, object_list)
+		delete_object_full(object->pointer);
+	rcu_read_unlock();
+
+	atomic_set(&kmemleak_enabled, 1);
+	atomic_set(&kmemleak_error, 0);
+
+	start_scan_thread();
+
+	pr_info("Kernel memory leak detector enabled\n");
+}
+
 /*
  * Allow boot-time kmemleak disabling (enabled by default).
  */
-- 
1.7.7


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
