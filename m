Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id E77326B0087
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 02:00:05 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6632354pbb.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 23:00:05 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v5 4/6] memory: memory notifier error injection module
Date: Sat, 30 Jun 2012 14:59:28 +0900
Message-Id: <1341035970-20490-5-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1341035970-20490-1-git-send-email-akinobu.mita@gmail.com>
References: <1341035970-20490-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Greg KH <greg@kroah.com>, linux-mm@kvack.org

This provides the ability to inject artifical errors to memory hotplug
notifier chain callbacks.  It is controlled through debugfs interface
under /sys/kernel/debug/notifier-error-inject/memory

If the notifier call chain should be failed with some events notified,
write the error code to "actions/<notifier event>/error".

Example: Inject memory hotplug offline error (-12 == -ENOMEM)

	# cd /sys/kernel/debug/notifier-error-inject/memory
	# echo -12 > actions/MEM_GOING_OFFLINE/error
	# echo offline > /sys/devices/system/memory/memoryXXX/state
	bash: echo: write error: Cannot allocate memory

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Greg KH <greg@kroah.com>
Cc: linux-mm@kvack.org
---
No changes since v4

 lib/Kconfig.debug                  |   23 +++++++++++++++++
 lib/Makefile                       |    1 +
 lib/memory-notifier-error-inject.c |   48 ++++++++++++++++++++++++++++++++++++
 3 files changed, 72 insertions(+)
 create mode 100644 lib/memory-notifier-error-inject.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 246cea6..7cceddc 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1143,6 +1143,29 @@ config PM_NOTIFIER_ERROR_INJECT
 
 	  If unsure, say N.
 
+config MEMORY_NOTIFIER_ERROR_INJECT
+	tristate "Memory hotplug notifier error injection module"
+	depends on MEMORY_HOTPLUG_SPARSE && NOTIFIER_ERROR_INJECTION
+	help
+	  This option provides the ability to inject artifical errors to
+	  memory hotplug notifier chain callbacks.  It is controlled through
+	  debugfs interface under /sys/kernel/debug/notifier-error-inject/memory
+
+	  If the notifier call chain should be failed with some events
+	  notified, write the error code to "actions/<notifier event>/error".
+
+	  Example: Inject memory hotplug offline error (-12 == -ENOMEM)
+
+	  # cd /sys/kernel/debug/notifier-error-inject/memory
+	  # echo -12 > actions/MEM_GOING_OFFLINE/error
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
index 230a949..a867aa5 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -93,6 +93,7 @@ obj-$(CONFIG_FAULT_INJECTION) += fault-inject.o
 obj-$(CONFIG_NOTIFIER_ERROR_INJECTION) += notifier-error-inject.o
 obj-$(CONFIG_CPU_NOTIFIER_ERROR_INJECT) += cpu-notifier-error-inject.o
 obj-$(CONFIG_PM_NOTIFIER_ERROR_INJECT) += pm-notifier-error-inject.o
+obj-$(CONFIG_MEMORY_NOTIFIER_ERROR_INJECT) += memory-notifier-error-inject.o
 
 lib-$(CONFIG_GENERIC_BUG) += bug.o
 
diff --git a/lib/memory-notifier-error-inject.c b/lib/memory-notifier-error-inject.c
new file mode 100644
index 0000000..e6239bf
--- /dev/null
+++ b/lib/memory-notifier-error-inject.c
@@ -0,0 +1,48 @@
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/memory.h>
+
+#include "notifier-error-inject.h"
+
+static int priority;
+module_param(priority, int, 0);
+MODULE_PARM_DESC(priority, "specify memory notifier priority");
+
+static struct notifier_err_inject memory_notifier_err_inject = {
+	.actions = {
+		{ NOTIFIER_ERR_INJECT_ACTION(MEM_GOING_ONLINE) },
+		{ NOTIFIER_ERR_INJECT_ACTION(MEM_GOING_OFFLINE) },
+		{}
+	}
+};
+
+static struct dentry *dir;
+
+static int err_inject_init(void)
+{
+	int err;
+
+	dir = notifier_err_inject_init("memory", notifier_err_inject_dir,
+					&memory_notifier_err_inject, priority);
+	if (IS_ERR(dir))
+		return PTR_ERR(dir);
+
+	err = register_memory_notifier(&memory_notifier_err_inject.nb);
+	if (err)
+		debugfs_remove_recursive(dir);
+
+	return err;
+}
+
+static void err_inject_exit(void)
+{
+	unregister_memory_notifier(&memory_notifier_err_inject.nb);
+	debugfs_remove_recursive(dir);
+}
+
+module_init(err_inject_init);
+module_exit(err_inject_exit);
+
+MODULE_DESCRIPTION("memory notifier error injection module");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Akinobu Mita <akinobu.mita@gmail.com>");
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
