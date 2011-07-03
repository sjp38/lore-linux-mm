Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 95BF36B00EA
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 10:15:07 -0400 (EDT)
Received: by pvc12 with SMTP id 12so5026175pvc.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 07:15:04 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 6/7] memory: memory notifier error injection
Date: Sun,  3 Jul 2011 23:16:20 +0900
Message-Id: <1309702581-16863-7-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1309702581-16863-1-git-send-email-akinobu.mita@gmail.com>
References: <1309702581-16863-1-git-send-email-akinobu.mita@gmail.com>
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

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: linux-mm@kvack.org
---
 drivers/base/memory.c |   29 +++++++++++++++++++++++++++++
 lib/Kconfig.debug     |    8 ++++++++
 2 files changed, 37 insertions(+), 0 deletions(-)

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
index 3ffb38b..52f0b0e 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1051,6 +1051,14 @@ config PM_NOTIFIER_ERROR_INJECTION
 	  PM notifier chain callbacks.  It is controlled through debugfs
 	  interface under /sys/kernel/debug/pm-notifier-error-inject/
 
+config MEMORY_NOTIFIER_ERROR_INJECTION
+	bool "Memory hotplug notifier error injection"
+	depends on MEMORY_HOTPLUG_SPARSE && NOTIFIER_ERROR_INJECTION
+	help
+	  This option provides the ability to inject artifical errors to
+	  memory hotplug notifier chain callbacks.  It is controlled through
+	  debugfs interface under /sys/kernel/debug/memory-notifier-error-inject/
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
