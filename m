Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 6BECA6B0068
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 03:14:20 -0500 (EST)
Received: by vbbfa15 with SMTP id fa15so1866150vbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 00:14:19 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 1/3] /dev/low_mem_notify
Date: Tue, 17 Jan 2012 17:13:56 +0900
Message-Id: <1326788038-29141-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1326788038-29141-1-git-send-email-minchan@kernel.org>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

This patch makes new device file "/dev/low_mem_notify".
If application polls it, it can receive event when system
memory pressure happens.

This patch is based on KOSAKI and Marcelo's long time ago work.
http://lwn.net/Articles/268732/

Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/char/mem.c             |    7 ++++
 include/linux/low_mem_notify.h |    6 ++++
 mm/Kconfig                     |    7 ++++
 mm/Makefile                    |    1 +
 mm/low_mem_notify.c            |   61 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 82 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/low_mem_notify.h
 create mode 100644 mm/low_mem_notify.c

diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index d6e9d08..72bc12b 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -35,6 +35,10 @@
 # include <linux/efi.h>
 #endif
 
+#ifdef CONFIG_LOW_MEM_NOTIFY
+extern struct file_operations low_mem_notify_fops;
+#endif
+
 static inline unsigned long size_inside_page(unsigned long start,
 					     unsigned long size)
 {
@@ -867,6 +871,9 @@ static const struct memdev {
 #ifdef CONFIG_CRASH_DUMP
 	[12] = { "oldmem", 0, &oldmem_fops, NULL },
 #endif
+#ifdef CONFIG_LOW_MEM_NOTIFY
+	[13] = { "low_mem_notify",0666, &low_mem_notify_fops, NULL},
+#endif
 };
 
 static int memory_open(struct inode *inode, struct file *filp)
diff --git a/include/linux/low_mem_notify.h b/include/linux/low_mem_notify.h
new file mode 100644
index 0000000..bc0fc89
--- /dev/null
+++ b/include/linux/low_mem_notify.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_LOW_MEM_NOTIFY_H
+#define _LINUX_LOW_MEM_NOTIFY_H
+
+void low_memory_pressure(void);
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index e338407..a2f48c6 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -379,3 +379,10 @@ config CLEANCACHE
 	  in a negligible performance hit.
 
 	  If unsure, say Y to enable cleancache
+
+config LOW_MEM_NOTIFY
+	bool "Enable low memory notification"
+	default n
+	help
+	  If system suffer from low memory, kernel can notify it to user through
+	  /dev/low_mem_notify.
diff --git a/mm/Makefile b/mm/Makefile
index 50ec00e..7856357 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -51,3 +51,4 @@ obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
+obj-$(CONFIG_LOW_MEM_NOTIFY) += low_mem_notify.o
diff --git a/mm/low_mem_notify.c b/mm/low_mem_notify.c
new file mode 100644
index 0000000..7432307
--- /dev/null
+++ b/mm/low_mem_notify.c
@@ -0,0 +1,61 @@
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/wait.h>
+#include <linux/poll.h>
+#include <linux/slab.h>
+
+static DECLARE_WAIT_QUEUE_HEAD(low_mem_wait);
+static atomic_t nr_low_mem = ATOMIC_INIT(0);
+
+struct low_mem_notify_file_info {
+        unsigned long last_proc_notify;
+};
+
+void low_memory_pressure(void)
+{
+       	atomic_inc(&nr_low_mem);
+       	wake_up(&low_mem_wait);
+}
+
+static int low_mem_notify_open(struct inode *inode, struct file *file)
+{
+        struct low_mem_notify_file_info *info;
+        int err = 0;
+
+        info = kmalloc(sizeof(*info), GFP_KERNEL);
+        if (!info) {
+                err = -ENOMEM;
+                goto out;
+        }
+
+        file->private_data = info;
+out:
+        return err;
+}
+
+static int low_mem_notify_release(struct inode *inode, struct file *file)
+{
+        kfree(file->private_data);
+        return 0;
+}
+
+static unsigned int low_mem_notify_poll(struct file *file, poll_table *wait)
+{
+        unsigned int ret = 0;
+
+        poll_wait(file, &low_mem_wait, wait);
+
+        if (atomic_read(&nr_low_mem) != 0) {
+                ret = POLLIN;
+                atomic_set(&nr_low_mem, 0);
+        }
+
+        return ret;
+}
+
+struct file_operations low_mem_notify_fops = {
+        .open = low_mem_notify_open,
+        .release = low_mem_notify_release,
+        .poll = low_mem_notify_poll,
+};
+EXPORT_SYMBOL(low_mem_notify_fops);
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
