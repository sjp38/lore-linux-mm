Message-Id: <20080211141815.219468000@bull.net>
References: <20080211141646.948191000@bull.net>
Date: Mon, 11 Feb 2008 15:16:51 +0100
From: Nadia.Derbey@bull.net
Subject: [PATCH 5/8] Invoke the ipcns notifier chain as a work item
Content-Disposition: inline; filename=ipc_ipcns_notification_workqueue.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, containers@lists.linux-foundation.org, matthltc@us.ibm.com, cmm@us.ibm.com, Nadia Derbey <Nadia.Derbey@bull.net>
List-ID: <linux-mm.kvack.org>

[PATCH 05/08]

This patch makes the memory hotplug chain's mutex held for a shorter time:
when memory is offlined or onlined a work item is added to the global
workqueue.
When the work item is run, it notifies the ipcns notifier chain with the
IPCNS_MEMCHANGED event.

Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>

---
 ipc/util.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

Index: linux-2.6.24-mm1/ipc/util.c
===================================================================
--- linux-2.6.24-mm1.orig/ipc/util.c	2008-02-08 08:15:35.000000000 +0100
+++ linux-2.6.24-mm1/ipc/util.c	2008-02-08 14:14:03.000000000 +0100
@@ -58,6 +58,14 @@ atomic_t nr_ipc_ns = ATOMIC_INIT(1);
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 
+static void ipc_memory_notifier(struct work_struct *work)
+{
+	ipcns_notify(IPCNS_MEMCHANGED);
+}
+
+static DECLARE_WORK(ipc_memory_wq, ipc_memory_notifier);
+
+
 static int ipc_memory_callback(struct notifier_block *self,
 				unsigned long action, void *arg)
 {
@@ -67,8 +75,13 @@ static int ipc_memory_callback(struct no
 		/*
 		 * This is done by invoking the ipcns notifier chain with the
 		 * IPC_MEMCHANGED event.
+		 * In order not to keep the lock on the hotplug memory chain
+		 * for too long, queue a work item that will, when waken up,
+		 * activate the ipcns notification chain.
+		 * No need to keep several ipc work items on the queue.
 		 */
-		ipcns_notify(IPCNS_MEMCHANGED);
+		if (!work_pending(&ipc_memory_wq))
+			schedule_work(&ipc_memory_wq);
 		break;
 	case MEM_GOING_ONLINE:
 	case MEM_GOING_OFFLINE:

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
