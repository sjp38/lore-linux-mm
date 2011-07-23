Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5B86B007E
	for <linux-mm@kvack.org>; Sat, 23 Jul 2011 04:49:39 -0400 (EDT)
Received: by mail-pz0-f49.google.com with SMTP id 33so5217086pzk.36
        for <linux-mm@kvack.org>; Sat, 23 Jul 2011 01:49:38 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 4/6] memory: memory notifier error injection module
Date: Sat, 23 Jul 2011 17:50:58 +0900
Message-Id: <1311411060-30124-5-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1311411060-30124-1-git-send-email-akinobu.mita@gmail.com>
References: <1311411060-30124-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Greg KH <greg@kroah.com>, linux-mm@kvack.org

This provides the ability to inject artifical errors to memory hotplug
notifier chain callbacks.  It is controlled through debugfs interface
under /sys/kernel/debug/memory-notifier-error-inject/

Each of the files in the directory represents an event which can be failed
and contains the error code.  If the notifier call chain should be failed
with some events notified, write the error code to the files.

Example: Inject memory hotplug offline error (-12 == -ENOMEM)

	# cd /sys/kernel/debug/memory-notifier-error-inject
	# echo -12 > MEM_GOING_OFFLINE
	# echo offline > /sys/devices/system/memory/memoryXXX/state
	bash: echo: write error: Cannot allocate memory

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Greg KH <greg@kroah.com>
Cc: linux-mm@kvack.org
---
* v3
- rewrite to be kernel modules instead of initializing at late_initcall()s
- notifier priority can be specified as a module parameter

 lib/Kconfig.debug                  |   20 ++++++++++++++++
 lib/Makefile                       |    1 +
 lib/memory-notifier-error-inject.c |   45 ++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 0 deletions(-)
 create mode 100644 lib/memory-notifier-error-inject.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 69ecd50..a2b0856 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1079,6 +1079,26 @@ config PM_NOTIFIER_ERROR_INJECT
 
 	  If unsure, say N.
 
+config MEMORY_NOTIFIER_ERROR_INJECT
+	tristate "Memory hotplug notifier error injection module"
+	depends on MEMORY_HOTPLUG_SPARSE && NOTIFIER_ERROR_INJECTION
+	help
+	  This option provides the ability to inject artifical errors to
+	  memory hotplug notifier chain callbacks.  It is controlled through
+	  debugfs interface.
+
+	  Example: Inject memory hotplug offline error (-12 == -ENOMEM)
+
+	  # cd /sys/kernel/debug/memory-notifier-error-inject
+	  # echo -12 > MEM_GOING_OFFLINE
+	  # echo offline > /sys/devices/system/memory/memoryXXX/state
+	  bash: echo: write error: Cannot allocate memory
+
+	  To compile this code as a module, choose M here: the module will
+	  be called memory-notifier-error-inject.
+
+	  If unsure, say N.
+
 config FAULT_INJECTION
 	bool "Fault-injection framework"
 	depends on DEBUG_KERNEL
diff --git a/lib/Makefile b/lib/Makefile
index 4dca6c0..f28914b 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -91,6 +91,7 @@ obj-$(CONFIG_IOMMU_HELPER) += iommu-helper.o
 obj-$(CONFIG_FAULT_INJECTION) += fault-inject.o
 obj-$(CONFIG_CPU_NOTIFIER_ERROR_INJECT) += cpu-notifier-error-inject.o
 obj-$(CONFIG_PM_NOTIFIER_ERROR_INJECT) += pm-notifier-error-inject.o
+obj-$(CONFIG_MEMORY_NOTIFIER_ERROR_INJECT) += memory-notifier-error-inject.o
 
 lib-$(CONFIG_GENERIC_BUG) += bug.o
 
diff --git a/lib/memory-notifier-error-inject.c b/lib/memory-notifier-error-inject.c
new file mode 100644
index 0000000..76f0b94
--- /dev/null
+++ b/lib/memory-notifier-error-inject.c
@@ -0,0 +1,45 @@
+#include <linux/kernel.h>
+#include <linux/memory.h>
+#include <linux/module.h>
+#include <linux/notifier.h>
+
+static int priority;
+module_param(priority, int, 0);
+MODULE_PARM_DESC(priority, "specify memory notifier priority");
+
+static struct err_inject_notifier_block err_inject_memory_notifier = {
+	.actions = {
+		{ ERR_INJECT_NOTIFIER_ACTION(MEM_GOING_ONLINE) },
+		{ ERR_INJECT_NOTIFIER_ACTION(MEM_GOING_OFFLINE) },
+		{}
+	}
+};
+
+static int err_inject_init(void)
+{
+	int err;
+
+	err = err_inject_notifier_block_init(&err_inject_memory_notifier,
+				"memory-notifier-error-inject", priority);
+	if (err)
+		return err;
+
+	err = register_memory_notifier(&err_inject_memory_notifier.nb);
+	if (err)
+		err_inject_notifier_block_cleanup(&err_inject_memory_notifier);
+
+	return err;
+}
+
+static void err_inject_exit(void)
+{
+	unregister_memory_notifier(&err_inject_memory_notifier.nb);
+	err_inject_notifier_block_cleanup(&err_inject_memory_notifier);
+}
+
+module_init(err_inject_init);
+module_exit(err_inject_exit);
+
+MODULE_DESCRIPTION("memory notifier error injection module");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Akinobu Mita <akinobu.mita@gmail.com>");
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
