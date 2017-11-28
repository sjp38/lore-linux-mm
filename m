Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C96336B02A7
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:50:18 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 62so1839026plc.6
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:50:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor429997plr.63.2017.11.27.23.50.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:50:17 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 17/18] lib/vchecker_test: introduce a sample for vchecker test
Date: Tue, 28 Nov 2017 16:48:52 +0900
Message-Id: <1511855333-3570-18-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

It's not easy to understand what can be done by the vchecker.
This sample could explain it and help to understand the vchecker.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 lib/Kconfig.kasan   |   9 ++++
 lib/Makefile        |   1 +
 lib/vchecker_test.c | 117 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 127 insertions(+)
 create mode 100644 lib/vchecker_test.c

diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 4b8e748..9983ec8 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -65,4 +65,13 @@ config VCHECKER
 	depends on KASAN && DEBUG_FS
 	select KALLSYMS
 
+config TEST_VCHECKER
+	tristate "Module for testing vchecker"
+	depends on m && KASAN
+	help
+	  This is a test module doing memory over-write. If vchecker is
+	  properly set up to check that over-write, memory over-written
+	  problem would be detected. See the help text in the
+	  lib/vchecker_test.c for vchecker sample run.
+
 endif
diff --git a/lib/Makefile b/lib/Makefile
index d11c48e..cc1f5ec 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -244,6 +244,7 @@ clean-files	+= oid_registry_data.c
 
 obj-$(CONFIG_UCS2_STRING) += ucs2_string.o
 obj-$(CONFIG_UBSAN) += ubsan.o
+obj-$(CONFIG_TEST_VCHECKER) += vchecker_test.o
 
 UBSAN_SANITIZE_ubsan.o := n
 
diff --git a/lib/vchecker_test.c b/lib/vchecker_test.c
new file mode 100644
index 0000000..fcb4b7f
--- /dev/null
+++ b/lib/vchecker_test.c
@@ -0,0 +1,117 @@
+#include <linux/kernel.h>
+#include <linux/printk.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/workqueue.h>
+
+/*
+ * How to use this sample for vchecker sample-run
+ *
+ * 1. Insert this module
+ * 2. Do following command on debugfs directory
+ *    # cd /sys/kernel/debug/vchecker
+ *    # echo 0 0xffff 7 > vchecker_test/value # offset 0, mask 0xffff, value 7
+ *    # echo 1 > vchecker_test/enable
+ *    # echo workfn_kmalloc_obj > kmalloc-8/alloc_filter
+ *    # echo "0 8" > kmalloc-8/callstack
+ *    # echo on > kmalloc-8/callstack
+ *    # echo 1 > kmalloc-8/enable
+ * 3. Check the error report due to invalid written value
+ */
+
+struct object {
+	volatile unsigned long v[1];
+};
+
+static struct kmem_cache *s;
+static void *old_obj;
+static struct delayed_work dwork_old_obj;
+static struct delayed_work dwork_new_obj;
+static struct delayed_work dwork_kmalloc_obj;
+
+static void workfn_old_obj(struct work_struct *work)
+{
+	struct object *obj = old_obj;
+	struct delayed_work *dwork = (struct delayed_work *)work;
+
+	obj->v[0] = 7;
+
+	mod_delayed_work(system_wq, dwork, HZ * 5);
+}
+
+static void workfn_new_obj(struct work_struct *work)
+{
+	struct object *obj;
+	struct delayed_work *dwork = (struct delayed_work *)work;
+
+	obj = kmem_cache_alloc(s, GFP_KERNEL);
+
+	obj->v[0] = 7;
+	/*
+	 * Need one more access to detect wrong value since there is
+	 * no proper infrastructure yet and the feature is just emulated.
+	 */
+	obj->v[0] = 0;
+
+	kmem_cache_free(s, obj);
+	mod_delayed_work(system_wq, dwork, HZ * 5);
+}
+
+static void workfn_kmalloc_obj(struct work_struct *work)
+{
+	struct object *obj;
+	struct delayed_work *dwork = (struct delayed_work *)work;
+
+	obj = kmalloc(sizeof(*obj), GFP_KERNEL);
+
+	obj->v[0] = 7;
+	/*
+	 * Need one more access to detect wrong value since there is
+	 * no proper infrastructure yet and the feature is just emulated.
+	 */
+	obj->v[0] = 0;
+
+	kfree(obj);
+	mod_delayed_work(system_wq, dwork, HZ * 5);
+}
+
+static int __init vchecker_test_init(void)
+{
+	s = kmem_cache_create("vchecker_test",
+			sizeof(struct object), 0, SLAB_NOLEAKTRACE, NULL);
+	if (!s)
+		return 1;
+
+	old_obj = kmem_cache_alloc(s, GFP_KERNEL);
+	if (!old_obj) {
+		kmem_cache_destroy(s);
+		return 1;
+	}
+
+	INIT_DELAYED_WORK(&dwork_old_obj, workfn_old_obj);
+	INIT_DELAYED_WORK(&dwork_new_obj, workfn_new_obj);
+	INIT_DELAYED_WORK(&dwork_kmalloc_obj, workfn_kmalloc_obj);
+
+	mod_delayed_work(system_wq, &dwork_old_obj, HZ * 5);
+	mod_delayed_work(system_wq, &dwork_new_obj, HZ * 5);
+	mod_delayed_work(system_wq, &dwork_kmalloc_obj, HZ * 5);
+
+	return 0;
+}
+
+static void __exit vchecker_test_fini(void)
+{
+	cancel_delayed_work_sync(&dwork_old_obj);
+	cancel_delayed_work_sync(&dwork_new_obj);
+	cancel_delayed_work_sync(&dwork_kmalloc_obj);
+
+	kmem_cache_free(s, old_obj);
+	kmem_cache_destroy(s);
+}
+
+
+module_init(vchecker_test_init);
+module_exit(vchecker_test_fini)
+
+MODULE_LICENSE("GPL");
+
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
