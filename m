Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EEC466B0082
	for <linux-mm@kvack.org>; Sun, 17 Jul 2011 21:14:38 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id 4so4580658pzk.14
        for <linux-mm@kvack.org>; Sun, 17 Jul 2011 18:14:37 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v2 4/5] memory: memory notifier error injection
Date: Mon, 18 Jul 2011 10:16:05 +0900
Message-Id: <1310951766-3840-5-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1310951766-3840-1-git-send-email-akinobu.mita@gmail.com>
References: <1310951766-3840-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, linux-mm@kvack.org

This provides the ability to inject artifical errors to memory hotplug
notifier chain callbacks.  It is controlled through debugfs interface
under /sys/kernel/debug/memory-notifier-error-inject/

Each of the files in the directory represents an event which can be
failed and contains the error code.  If the notifier call chain should
be failed with some events notified, write the error code to the files.

Example: Inject memory hotplug offline error (-12 == -ENOMEM)

	# cd /sys/kernel/debug/memory-notifier-error-inject
	# echo -12 > MEM_GOING_OFFLINE
	# echo offline > /sys/devices/system/memory/memoryXXX/state
	bash: echo: write error: Cannot allocate memory

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: linux-mm@kvack.org
---
* v2
- improve Kconfig help text

 drivers/base/memory.c |   29 +++++++++++++++++++++++++++++
 lib/Kconfig.debug     |   15 +++++++++++++++
 2 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 9f9b235..5b7430f 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -89,6 +89,35 @@ void unregister_memory_isolate_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL(unregister_memory_isolate_notifier);
 
+#ifdef CONFIG_MEMORY_NOTIFIER_ERROR_INJECTION
+
+static struct err_inject_notifier_block err_inject_memory_notifier = {
+	.actions = {
+		{ ERR_INJECT_NOTIFIER_ACTION(MEM_GOING_ONLINE) },
+		{ ERR_INJECT_NOTIFIER_ACTION(MEM_GOING_OFFLINE) },
+		{}
+	}
+};
+
+static int __init err_inject_memory_notifier_init(void)
+{
+	int err;
+
+	err = err_inject_notifier_block_init(&err_inject_memory_notifier,
+				"memory-notifier-error-inject", -1);
+	if (err)
+		return err;
+
+	err = register_memory_notifier(&err_inject_memory_notifier.nb);
+	if (err)
+		err_inject_notifier_block_cleanup(&err_inject_memory_notifier);
+
+	return err;
+}
+late_initcall(err_inject_memory_notifier_init);
+
+#endif /* CONFIG_MEMORY_NOTIFIER_ERROR_INJECTION */
+
 /*
  * register_memory - Setup a sysfs device for a memory block
  */
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index e5671ba..8f5c380 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1065,6 +1065,21 @@ config PM_NOTIFIER_ERROR_INJECTION
 	  # echo mem > /sys/power/state
 	  bash: echo: write error: Cannot allocate memory
 
+config MEMORY_NOTIFIER_ERROR_INJECTION
+	bool "Memory hotplug notifier error injection"
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
 config CPU_NOTIFIER_ERROR_INJECT
 	tristate "CPU notifier error injection module"
 	depends on HOTPLUG_CPU && DEBUG_KERNEL
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
