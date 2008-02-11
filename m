Message-Id: <20080211141814.725663000@bull.net>
References: <20080211141646.948191000@bull.net>
Date: Mon, 11 Feb 2008 15:16:50 +0100
From: Nadia.Derbey@bull.net
Subject: [PATCH 4/8] Recomputing msgmni on memory add / remove
Content-Disposition: inline; filename=ipc_recompute_msgmni_on_memory_hotplug.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, containers@lists.linux-foundation.org, matthltc@us.ibm.com, cmm@us.ibm.com, Nadia Derbey <Nadia.Derbey@bull.net>
List-ID: <linux-mm.kvack.org>

[PATCH 04/08]

This patch introduces the registration of a callback routine that recomputes
msg_ctlmni upon memory add / remove.

A single notifier block is registered in the hotplug memory chain for all the
ipc namespaces.

Since the ipc namespaces are not linked together, they have their own
notification chain: one notifier_block is defined per ipc namespace.

Each time an ipc namespace is created (removed) it registers (unregisters)
its notifier block in (from) the ipcns chain.
The callback routine registered in the memory chain invokes the ipcns
notifier chain with the IPCNS_LOWMEM event.
Each callback routine registered in the ipcns namespace, in turn, recomputes
msgmni for the owning namespace.


Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>

---
 include/linux/ipc_namespace.h |   43 ++++++++++++++++++++++++-
 include/linux/memory.h        |    1 
 ipc/Makefile                  |    3 +
 ipc/ipcns_notifier.c          |   71 ++++++++++++++++++++++++++++++++++++++++++
 ipc/msg.c                     |    2 -
 ipc/namespace.c               |   11 ++++++
 ipc/util.c                    |   33 +++++++++++++++++++
 ipc/util.h                    |    2 +
 8 files changed, 162 insertions(+), 4 deletions(-)

Index: linux-2.6.24-mm1/include/linux/ipc_namespace.h
===================================================================
--- linux-2.6.24-mm1.orig/include/linux/ipc_namespace.h	2008-02-07 15:26:53.000000000 +0100
+++ linux-2.6.24-mm1/include/linux/ipc_namespace.h	2008-02-08 08:29:21.000000000 +0100
@@ -4,6 +4,17 @@
 #include <linux/err.h>
 #include <linux/idr.h>
 #include <linux/rwsem.h>
+#ifdef CONFIG_MEMORY_HOTPLUG
+#include <linux/notifier.h>
+#endif /* CONFIG_MEMORY_HOTPLUG */
+
+/*
+ * ipc namespace events
+ */
+#define IPCNS_MEMCHANGED   0x00000001   /* Notify lowmem size changed */
+
+#define IPCNS_CALLBACK_PRI 0
+
 
 struct ipc_ids {
 	int in_use;
@@ -30,6 +41,10 @@ struct ipc_namespace {
 	size_t		shm_ctlall;
 	int		shm_ctlmni;
 	int		shm_tot;
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+	struct notifier_block ipcns_nb;
+#endif
 };
 
 extern struct ipc_namespace init_ipc_ns;
@@ -37,9 +52,33 @@ extern atomic_t nr_ipc_ns;
 
 #ifdef CONFIG_SYSVIPC
 #define INIT_IPC_NS(ns)		.ns		= &init_ipc_ns,
-#else
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+
+extern int register_ipcns_notifier(struct ipc_namespace *);
+extern int unregister_ipcns_notifier(struct ipc_namespace *);
+extern int ipcns_notify(unsigned long);
+
+#else /* CONFIG_MEMORY_HOTPLUG */
+
+static inline int register_ipcns_notifier(struct ipc_namespace *ipcns)
+{
+	return 0;
+}
+static inline int unregister_ipcns_notifier(struct ipc_namespace *ipcns)
+{
+	return 0;
+}
+static inline int ipcns_notify(unsigned long ev)
+{
+	return 0;
+}
+
+#endif /* CONFIG_MEMORY_HOTPLUG */
+
+#else /* CONFIG_SYSVIPC */
 #define INIT_IPC_NS(ns)
-#endif
+#endif /* CONFIG_SYSVIPC */
 
 #if defined(CONFIG_SYSVIPC) && defined(CONFIG_IPC_NS)
 extern void free_ipc_ns(struct kref *kref);
Index: linux-2.6.24-mm1/include/linux/memory.h
===================================================================
--- linux-2.6.24-mm1.orig/include/linux/memory.h	2008-02-07 17:10:07.000000000 +0100
+++ linux-2.6.24-mm1/include/linux/memory.h	2008-02-08 08:04:36.000000000 +0100
@@ -58,6 +58,7 @@ struct mem_section;
  * order in the callback chain)
  */
 #define SLAB_CALLBACK_PRI       1
+#define IPC_CALLBACK_PRI        10
 
 #ifndef CONFIG_MEMORY_HOTPLUG_SPARSE
 static inline int memory_dev_init(void)
Index: linux-2.6.24-mm1/ipc/ipcns_notifier.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.24-mm1/ipc/ipcns_notifier.c	2008-02-08 13:59:26.000000000 +0100
@@ -0,0 +1,71 @@
+/*
+ * linux/ipc/ipcns_notifier.c
+ * Copyright (C) 2007 BULL SA. Nadia Derbey
+ *
+ * Notification mechanism for ipc namespaces:
+ * The callback routine registered in the memory chain invokes the ipcns
+ * notifier chain with the IPCNS_MEMCHANGED event.
+ * Each callback routine registered in the ipcns namespace recomputes msgmni
+ * for the owning namespace.
+ */
+
+#include <linux/msg.h>
+#include <linux/rcupdate.h>
+#include <linux/notifier.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+
+#include "util.h"
+
+
+
+static BLOCKING_NOTIFIER_HEAD(ipcns_chain);
+
+
+static int ipcns_callback(struct notifier_block *self,
+				unsigned long action, void *arg)
+{
+	struct ipc_namespace *ns;
+
+	switch (action) {
+	case IPCNS_MEMCHANGED:   /* amount of lowmem has changed */
+		/*
+		 * It's time to recompute msgmni
+		 */
+		ns = container_of(self, struct ipc_namespace, ipcns_nb);
+		/*
+		 * No need to get a reference on the ns: the 1st job of
+		 * free_ipc_ns() is to unregister the callback routine.
+		 * blocking_notifier_chain_unregister takes the wr lock to do
+		 * it.
+		 * When this callback routine is called the rd lock is held by
+		 * blocking_notifier_call_chain.
+		 * So the ipc ns cannot be freed while we are here.
+		 */
+		recompute_msgmni(ns);
+		break;
+	default:
+		break;
+	}
+
+	return NOTIFY_OK;
+}
+
+int register_ipcns_notifier(struct ipc_namespace *ns)
+{
+	memset(&ns->ipcns_nb, 0, sizeof(ns->ipcns_nb));
+	ns->ipcns_nb.notifier_call = ipcns_callback;
+	ns->ipcns_nb.priority = IPCNS_CALLBACK_PRI;
+	return blocking_notifier_chain_register(&ipcns_chain, &ns->ipcns_nb);
+}
+
+int unregister_ipcns_notifier(struct ipc_namespace *ns)
+{
+	return blocking_notifier_chain_unregister(&ipcns_chain,
+						&ns->ipcns_nb);
+}
+
+int ipcns_notify(unsigned long val)
+{
+	return blocking_notifier_call_chain(&ipcns_chain, val, NULL);
+}
Index: linux-2.6.24-mm1/ipc/Makefile
===================================================================
--- linux-2.6.24-mm1.orig/ipc/Makefile	2008-02-07 13:41:07.000000000 +0100
+++ linux-2.6.24-mm1/ipc/Makefile	2008-02-08 08:10:13.000000000 +0100
@@ -3,7 +3,8 @@
 #
 
 obj-$(CONFIG_SYSVIPC_COMPAT) += compat.o
-obj-$(CONFIG_SYSVIPC) += util.o msgutil.o msg.o sem.o shm.o
+obj_mem-$(CONFIG_MEMORY_HOTPLUG) += ipcns_notifier.o
+obj-$(CONFIG_SYSVIPC) += util.o msgutil.o msg.o sem.o shm.o $(obj_mem-y)
 obj-$(CONFIG_SYSVIPC_SYSCTL) += ipc_sysctl.o
 obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
Index: linux-2.6.24-mm1/ipc/util.c
===================================================================
--- linux-2.6.24-mm1.orig/ipc/util.c	2008-02-07 15:36:22.000000000 +0100
+++ linux-2.6.24-mm1/ipc/util.c	2008-02-08 08:15:35.000000000 +0100
@@ -33,6 +33,7 @@
 #include <linux/audit.h>
 #include <linux/nsproxy.h>
 #include <linux/rwsem.h>
+#include <linux/memory.h>
 #include <linux/ipc_namespace.h>
 
 #include <asm/unistd.h>
@@ -55,11 +56,41 @@ struct ipc_namespace init_ipc_ns = {
 atomic_t nr_ipc_ns = ATOMIC_INIT(1);
 
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+
+static int ipc_memory_callback(struct notifier_block *self,
+				unsigned long action, void *arg)
+{
+	switch (action) {
+	case MEM_ONLINE:    /* memory successfully brought online */
+	case MEM_OFFLINE:   /* or offline: it's time to recompute msgmni */
+		/*
+		 * This is done by invoking the ipcns notifier chain with the
+		 * IPC_MEMCHANGED event.
+		 */
+		ipcns_notify(IPCNS_MEMCHANGED);
+		break;
+	case MEM_GOING_ONLINE:
+	case MEM_GOING_OFFLINE:
+	case MEM_CANCEL_ONLINE:
+	case MEM_CANCEL_OFFLINE:
+	default:
+		break;
+	}
+
+	return NOTIFY_OK;
+}
+
+#endif /* CONFIG_MEMORY_HOTPLUG */
+
 /**
  *	ipc_init	-	initialise IPC subsystem
  *
  *	The various system5 IPC resources (semaphores, messages and shared
  *	memory) are initialised
+ *	A callback routine is registered into the memory hotplug notifier
+ *	chain: since msgmni scales to lowmem this callback routine will be
+ *	called upon successful memory add / remove to recompute msmgni.
  */
  
 static int __init ipc_init(void)
@@ -67,6 +98,8 @@ static int __init ipc_init(void)
 	sem_init();
 	msg_init();
 	shm_init();
+	hotplug_memory_notifier(ipc_memory_callback, IPC_CALLBACK_PRI);
+	register_ipcns_notifier(&init_ipc_ns);
 	return 0;
 }
 __initcall(ipc_init);
Index: linux-2.6.24-mm1/ipc/namespace.c
===================================================================
--- linux-2.6.24-mm1.orig/ipc/namespace.c	2008-02-07 15:40:19.000000000 +0100
+++ linux-2.6.24-mm1/ipc/namespace.c	2008-02-08 08:18:35.000000000 +0100
@@ -26,6 +26,8 @@ static struct ipc_namespace *clone_ipc_n
 	msg_init_ns(ns);
 	shm_init_ns(ns);
 
+	register_ipcns_notifier(ns);
+
 	kref_init(&ns->kref);
 	return ns;
 }
@@ -81,6 +83,15 @@ void free_ipc_ns(struct kref *kref)
 	struct ipc_namespace *ns;
 
 	ns = container_of(kref, struct ipc_namespace, kref);
+	/*
+	 * Unregistering the hotplug notifier at the beginning guarantees
+	 * that the ipc namespace won't be freed while we are inside the
+	 * callback routine. Since the blocking_notifier_chain_XXX routines
+	 * hold a rw lock on the notifier list, unregister_ipcns_notifier()
+	 * won't take the rw lock before blocking_notifier_call_chain() has
+	 * released the rd lock.
+	 */
+	unregister_ipcns_notifier(ns);
 	sem_exit_ns(ns);
 	msg_exit_ns(ns);
 	shm_exit_ns(ns);
Index: linux-2.6.24-mm1/ipc/msg.c
===================================================================
--- linux-2.6.24-mm1.orig/ipc/msg.c	2008-02-07 15:43:51.000000000 +0100
+++ linux-2.6.24-mm1/ipc/msg.c	2008-02-08 08:19:36.000000000 +0100
@@ -85,7 +85,7 @@ static int sysvipc_msg_proc_show(struct 
  * Also take into account the number of nsproxies created so far.
  * This should be done staying within the (MSGMNI , IPCMNI/nr_ipc_ns) range.
  */
-static void recompute_msgmni(struct ipc_namespace *ns)
+void recompute_msgmni(struct ipc_namespace *ns)
 {
 	struct sysinfo i;
 	unsigned long allowed;
Index: linux-2.6.24-mm1/ipc/util.h
===================================================================
--- linux-2.6.24-mm1.orig/ipc/util.h	2008-02-07 13:41:07.000000000 +0100
+++ linux-2.6.24-mm1/ipc/util.h	2008-02-08 08:21:23.000000000 +0100
@@ -124,6 +124,8 @@ extern void free_msg(struct msg_msg *msg
 extern struct msg_msg *load_msg(const void __user *src, int len);
 extern int store_msg(void __user *dest, struct msg_msg *msg, int len);
 
+extern void recompute_msgmni(struct ipc_namespace *);
+
 static inline int ipc_buildid(int id, int seq)
 {
 	return SEQ_MULTIPLIER * seq + id;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
