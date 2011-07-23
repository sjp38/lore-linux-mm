Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA9C6B004A
	for <linux-mm@kvack.org>; Sat, 23 Jul 2011 04:49:35 -0400 (EDT)
Received: by pzk33 with SMTP id 33so5217086pzk.36
        for <linux-mm@kvack.org>; Sat, 23 Jul 2011 01:49:32 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 1/6] fault-injection: notifier error injection
Date: Sat, 23 Jul 2011 17:50:55 +0900
Message-Id: <1311411060-30124-2-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1311411060-30124-1-git-send-email-akinobu.mita@gmail.com>
References: <1311411060-30124-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-pm@lists.linux-foundation.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org

The notifier error injection provides the ability to inject artifical
errors to specified notifier chain callbacks.  It is useful to test the
error handling of notifier call chain failures.

This adds common basic functions to define which type of events can be
fail and to initialize the debugfs interface to control what error code
should be returned and which event should be failed.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@lists.linux-foundation.org
Cc: Greg KH <greg@kroah.com>
Cc: linux-mm@kvack.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@lists.ozlabs.org
---
* v3
- export err_inject_notifier_block_{init,cleanup} for modules

 include/linux/notifier.h |   25 ++++++++++++++
 kernel/notifier.c        |   83 ++++++++++++++++++++++++++++++++++++++++++++++
 lib/Kconfig.debug        |   11 ++++++
 3 files changed, 119 insertions(+), 0 deletions(-)

diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index c0688b0..51882d6 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -278,5 +278,30 @@ extern struct blocking_notifier_head reboot_notifier_list;
 #define VT_UPDATE		0x0004 /* A bigger update occurred */
 #define VT_PREWRITE		0x0005 /* A char is about to be written to the console */
 
+#ifdef CONFIG_NOTIFIER_ERROR_INJECTION
+
+struct err_inject_notifier_action {
+	unsigned long val;
+	int error;
+	const char *name;
+};
+
+#define ERR_INJECT_NOTIFIER_ACTION(action)	\
+	.name = #action, .val = (action),
+
+struct err_inject_notifier_block {
+	struct notifier_block nb;
+	struct dentry *dir;
+	struct err_inject_notifier_action actions[];
+	/* The last slot must be terminated with zero sentinel */
+};
+
+extern int err_inject_notifier_block_init(struct err_inject_notifier_block *enb,
+				const char *name, int priority);
+extern void err_inject_notifier_block_cleanup(
+				struct err_inject_notifier_block *enb);
+
+#endif /* CONFIG_NOTIFIER_ERROR_INJECTION */
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_NOTIFIER_H */
diff --git a/kernel/notifier.c b/kernel/notifier.c
index 2488ba7..8dcb2cc 100644
--- a/kernel/notifier.c
+++ b/kernel/notifier.c
@@ -5,6 +5,7 @@
 #include <linux/rcupdate.h>
 #include <linux/vmalloc.h>
 #include <linux/reboot.h>
+#include <linux/debugfs.h>
 
 /*
  *	Notifier list for kernel code which wants to be called
@@ -584,3 +585,85 @@ int unregister_die_notifier(struct notifier_block *nb)
 	return atomic_notifier_chain_unregister(&die_chain, nb);
 }
 EXPORT_SYMBOL_GPL(unregister_die_notifier);
+
+#ifdef CONFIG_NOTIFIER_ERROR_INJECTION
+
+static int debugfs_errno_set(void *data, u64 val)
+{
+	*(int *)data = clamp_t(int, val, -MAX_ERRNO, 0);
+	return 0;
+}
+
+static int debugfs_errno_get(void *data, u64 *val)
+{
+	*val = *(int *)data;
+	return 0;
+}
+
+DEFINE_SIMPLE_ATTRIBUTE(fops_errno, debugfs_errno_get, debugfs_errno_set,
+			"%lld\n");
+
+static struct dentry *debugfs_create_errno(const char *name, mode_t mode,
+				struct dentry *parent, int *value)
+{
+	return debugfs_create_file(name, mode, parent, value, &fops_errno);
+}
+
+static int err_inject_notifier_callback(struct notifier_block *nb,
+				unsigned long val, void *p)
+{
+	int err = 0;
+	struct err_inject_notifier_block *enb =
+		container_of(nb, struct err_inject_notifier_block, nb);
+	struct err_inject_notifier_action *action;
+
+	for (action = enb->actions; action->name; action++) {
+		if (action->val == val) {
+			err = action->error;
+			break;
+		}
+	}
+	if (err) {
+		printk(KERN_INFO "Injecting error (%d) to %s\n",
+			err, action->name);
+	}
+
+	return notifier_from_errno(err);
+}
+
+int err_inject_notifier_block_init(struct err_inject_notifier_block *enb,
+				const char *name, int priority)
+{
+	struct err_inject_notifier_action *action;
+	mode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
+
+	enb->nb.notifier_call = err_inject_notifier_callback;
+	enb->nb.priority = priority;
+
+	enb->dir = debugfs_create_dir(name, NULL);
+	if (!enb->dir)
+		return -ENOMEM;
+
+	for (action = enb->actions; action->name; action++) {
+		/*
+		 * Create debugfs r/w file containing action->error. If
+		 * notifier call chain is called with action->val, it will
+		 * fail with the error code
+		 */
+		if (!debugfs_create_errno(action->name, mode, enb->dir,
+					&action->error)) {
+			debugfs_remove_recursive(enb->dir);
+			return -ENOMEM;
+		}
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(err_inject_notifier_block_init);
+
+void err_inject_notifier_block_cleanup(struct err_inject_notifier_block *enb)
+{
+	debugfs_remove_recursive(enb->dir);
+}
+EXPORT_SYMBOL_GPL(err_inject_notifier_block_cleanup);
+
+#endif /* CONFIG_NOTIFIER_ERROR_INJECTION */
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index c0cb9c4..2a62c5a 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1021,6 +1021,17 @@ config LKDTM
 	Documentation on how to use the module can be found in
 	Documentation/fault-injection/provoke-crashes.txt
 
+config NOTIFIER_ERROR_INJECTION
+	bool "Notifier error injection"
+	depends on DEBUG_KERNEL
+	select DEBUG_FS
+	help
+	  This option provides the ability to inject artifical errors to
+	  specified notifier chain callbacks. It is useful to test the error
+	  handling of notifier call chain failures.
+
+	  Say N if unsure.
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
