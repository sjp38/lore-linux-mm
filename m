Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD0A6B009A
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 15:10:47 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n91Jrrvi032197
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 15:53:53 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n91JuM2S234014
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 15:56:22 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n91JuL0r008467
	for <linux-mm@kvack.org>; Thu, 1 Oct 2009 15:56:22 -0400
Date: Thu, 1 Oct 2009 14:56:20 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH 2/2] powerpc: Make the CMM memory hotplug aware
Message-ID: <20091001195620.GG11830@austin.ibm.com>
References: <20091001195311.GA16667@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091001195311.GA16667@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

The Collaborative Memory Manager (CMM) module allocates individual pages
over time that are not migratable.  On a long running system this can
severely impact the ability to find enough pages to support a hotplug
memory remove operation.

This patch adds a memory isolation notifier and a memory hotplug notifier.
The memory isolation notifier will return the number of pages found in
the range specified.  This is used to determine if all of the pages in
a pageblock are owned by the balloon.  The hotplug notifier will free
pages in the range which is to be removed.  The priority of the hotplug
notifier is low so that it will be called near last, this helps avoids
removing loaned pages in operations that fail due to other handlers.

CMM activity will be halted when hotplug remove operations are active
and resume activity after a delay period to allow the hypervisor time
to adjust.

Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>

---
 arch/powerpc/platforms/pseries/cmm.c |  211 ++++++++++++++++++++++++++++++++++-
 1 file changed, 205 insertions(+), 6 deletions(-)

Index: b/arch/powerpc/platforms/pseries/cmm.c
===================================================================
--- a/arch/powerpc/platforms/pseries/cmm.c
+++ b/arch/powerpc/platforms/pseries/cmm.c
@@ -38,19 +38,28 @@
 #include <asm/mmu.h>
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
+#include <linux/memory.h>
 
 #include "plpar_wrappers.h"
 
 #define CMM_DRIVER_VERSION	"1.0.0"
 #define CMM_DEFAULT_DELAY	1
+#define CMM_HOTPLUG_DELAY	5
 #define CMM_DEBUG			0
 #define CMM_DISABLE		0
 #define CMM_OOM_KB		1024
 #define CMM_MIN_MEM_MB		256
 #define KB2PAGES(_p)		((_p)>>(PAGE_SHIFT-10))
 #define PAGES2KB(_p)		((_p)<<(PAGE_SHIFT-10))
+/*
+ * The priority level tries to ensure that this notifier is called as
+ * late as possible to reduce thrashing in the shared memory pool.
+ */
+#define CMM_MEM_HOTPLUG_PRI	1
+#define CMM_MEM_ISOLATE_PRI	15
 
 static unsigned int delay = CMM_DEFAULT_DELAY;
+static unsigned int hotplug_delay = CMM_HOTPLUG_DELAY;
 static unsigned int oom_kb = CMM_OOM_KB;
 static unsigned int cmm_debug = CMM_DEBUG;
 static unsigned int cmm_disabled = CMM_DISABLE;
@@ -65,6 +74,10 @@ MODULE_VERSION(CMM_DRIVER_VERSION);
 module_param_named(delay, delay, uint, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(delay, "Delay (in seconds) between polls to query hypervisor paging requests. "
 		 "[Default=" __stringify(CMM_DEFAULT_DELAY) "]");
+module_param_named(hotplug_delay, hotplug_delay, uint, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(delay, "Delay (in seconds) after memory hotplug remove "
+		 "before activity resumes. "
+		 "[Default=" __stringify(CMM_HOTPLUG_DELAY) "]");
 module_param_named(oom_kb, oom_kb, uint, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(oom_kb, "Amount of memory in kb to free on OOM. "
 		 "[Default=" __stringify(CMM_OOM_KB) "]");
@@ -88,6 +101,8 @@ struct cmm_page_array {
 static unsigned long loaned_pages;
 static unsigned long loaned_pages_target;
 static unsigned long oom_freed_pages;
+static atomic_t hotplug_active = ATOMIC_INIT(0);
+static atomic_t hotplug_occurred = ATOMIC_INIT(0);
 
 static struct cmm_page_array *cmm_page_list;
 static DEFINE_SPINLOCK(cmm_lock);
@@ -110,6 +125,9 @@ static long cmm_alloc_pages(long nr)
 	cmm_dbg("Begin request for %ld pages\n", nr);
 
 	while (nr) {
+		if (atomic_read(&hotplug_active))
+			break;
+
 		addr = __get_free_page(GFP_NOIO | __GFP_NOWARN |
 				       __GFP_NORETRY | __GFP_NOMEMALLOC);
 		if (!addr)
@@ -119,8 +137,10 @@ static long cmm_alloc_pages(long nr)
 		if (!pa || pa->index >= CMM_NR_PAGES) {
 			/* Need a new page for the page list. */
 			spin_unlock(&cmm_lock);
-			npa = (struct cmm_page_array *)__get_free_page(GFP_NOIO | __GFP_NOWARN |
-								       __GFP_NORETRY | __GFP_NOMEMALLOC);
+			npa = (struct cmm_page_array *)__get_free_page(
+					GFP_NOIO | __GFP_NOWARN |
+					__GFP_NORETRY | __GFP_NOMEMALLOC |
+					__GFP_MOVABLE);
 			if (!npa) {
 				pr_info("%s: Can not allocate new page list\n", __func__);
 				free_page(addr);
@@ -273,9 +293,23 @@ static int cmm_thread(void *dummy)
 	while (1) {
 		timeleft = msleep_interruptible(delay * 1000);
 
-		if (kthread_should_stop() || timeleft) {
-			loaned_pages_target = loaned_pages;
+		if (kthread_should_stop() || timeleft)
 			break;
+
+		if (atomic_read(&hotplug_active)) {
+			cmm_dbg("Hotplug operation in progress, activity "
+					"suspended\n");
+			continue;
+		}
+
+		if (atomic_dec_if_positive(&hotplug_occurred) >= 0) {
+			cmm_dbg("Hotplug operation has occurred, loaning "
+					"activity suspended for %d seconds.\n",
+					hotplug_delay);
+			timeleft = msleep_interruptible(hotplug_delay * 1000);
+			if (kthread_should_stop() || timeleft)
+				break;
+			continue;
 		}
 
 		cmm_get_mpp();
@@ -405,6 +439,163 @@ static struct notifier_block cmm_reboot_
 };
 
 /**
+ * cmm_count_pages - Count the number of pages loaned in a particular range.
+ *
+ * @arg: memory_isolate_notify structure with address range and count
+ *
+ * Return value:
+ *      0 on success
+ **/
+static unsigned long cmm_count_pages(void *arg)
+{
+	struct memory_isolate_notify *marg = arg;
+	struct cmm_page_array *pa;
+	unsigned long idx;
+	unsigned long start;
+	unsigned long end;
+
+	start = marg->start_addr;
+	end = start + ((unsigned long)marg->nr_pages << PAGE_SHIFT);
+
+	spin_lock(&cmm_lock);
+	pa = cmm_page_list;
+	while (pa) {
+		for (idx = 0; idx < pa->index; idx++)
+			if (pa->page[idx] >= start && pa->page[idx] < end)
+				marg->pages_found++;
+		pa = pa->next;
+
+	}
+	spin_unlock(&cmm_lock);
+	return 0;
+}
+
+/**
+ * cmm_memory_isolate_cb - Handle memory isolation notifier calls
+ * @self:	notifier block struct
+ * @action:	action to take
+ * @arg:	struct memory_isolate_notify data for handler
+ *
+ * Return value:
+ *	NOTIFY_OK or notifier error based on subfunction return value
+ **/
+static int cmm_memory_isolate_cb(struct notifier_block *self,
+				 unsigned long action, void *arg)
+{
+	int ret = 0;
+
+	if (action == MEM_ISOLATE_COUNT)
+		ret = cmm_count_pages(arg);
+
+	if (ret)
+		ret = notifier_from_errno(ret);
+	else
+		ret = NOTIFY_OK;
+
+	return ret;
+}
+
+static struct notifier_block cmm_mem_isolate_nb = {
+	.notifier_call = cmm_memory_isolate_cb,
+	.priority = CMM_MEM_ISOLATE_PRI
+};
+
+/**
+ * cmm_mem_going_offline - Unloan pages where memory is to be removed
+ * @arg: memory_notify structure with page range to be offlined
+ *
+ * Return value:
+ *	0 on success
+ **/
+static int cmm_mem_going_offline(void *arg)
+{
+	struct memory_notify *marg = arg;
+	unsigned long start_page = (unsigned long)pfn_to_kaddr(marg->start_pfn);
+	unsigned long end_page = start_page + (marg->nr_pages << PAGE_SHIFT);
+	struct cmm_page_array *pa_curr, *pa_last;
+	unsigned long idx;
+	unsigned long freed = 0;
+
+	cmm_dbg("Memory going offline, searching 0x%lx (%ld pages).\n",
+			start_page, marg->nr_pages);
+	spin_lock(&cmm_lock);
+
+	pa_last = pa_curr = cmm_page_list;
+	while (pa_curr) {
+		for (idx = (pa_curr->index - 1); (idx + 1) > 0; idx--) {
+			if ((pa_curr->page[idx] < start_page) ||
+			    (pa_curr->page[idx] >= end_page))
+				continue;
+
+			plpar_page_set_active(__pa(pa_curr->page[idx]));
+			free_page(pa_curr->page[idx]);
+			freed++;
+			loaned_pages--;
+			totalram_pages++;
+			pa_curr->page[idx] = pa_last->page[--pa_last->index];
+			if (pa_last->index == 0) {
+				if (pa_curr == pa_last)
+					pa_curr = pa_last->next;
+				pa_last = pa_last->next;
+				free_page((unsigned long)cmm_page_list);
+				cmm_page_list = pa_last;
+				continue;
+			}
+		}
+		pa_curr = pa_curr->next;
+	}
+	atomic_set(&hotplug_occurred, 1);
+	spin_unlock(&cmm_lock);
+	cmm_dbg("Released %ld pages in the search range.\n", freed);
+
+	return 0;
+}
+
+/**
+ * cmm_memory_cb - Handle memory hotplug notifier calls
+ * @self:	notifier block struct
+ * @action:	action to take
+ * @arg:	struct memory_notify data for handler
+ *
+ * Return value:
+ *	NOTIFY_OK or notifier error based on subfunction return value
+ *
+ **/
+static int cmm_memory_cb(struct notifier_block *self,
+			unsigned long action, void *arg)
+{
+	int ret = 0;
+
+	switch (action) {
+	case MEM_GOING_OFFLINE:
+		atomic_set(&hotplug_active, 1);
+		ret = cmm_mem_going_offline(arg);
+		break;
+	case MEM_OFFLINE:
+	case MEM_CANCEL_OFFLINE:
+		atomic_set(&hotplug_active, 0);
+		cmm_dbg("Memory offline operation complete.\n");
+		break;
+	case MEM_GOING_ONLINE:
+	case MEM_ONLINE:
+	case MEM_CANCEL_ONLINE:
+		break;
+	}
+
+	if (ret)
+		ret = notifier_from_errno(ret);
+	else
+		ret = NOTIFY_OK;
+
+	return ret;
+}
+
+static struct notifier_block cmm_mem_nb = {
+	.notifier_call = cmm_memory_cb,
+	.priority = CMM_MEM_HOTPLUG_PRI
+};
+
+/**
  * cmm_init - Module initialization
  *
  * Return value:
@@ -426,18 +617,24 @@ static int cmm_init(void)
 	if ((rc = cmm_sysfs_register(&cmm_sysdev)))
 		goto out_reboot_notifier;
 
+	if (register_memory_notifier(&cmm_mem_nb) ||
+	    register_memory_isolate_notifier(&cmm_mem_isolate_nb))
+		goto out_unregister_notifier;
+
 	if (cmm_disabled)
 		return rc;
 
 	cmm_thread_ptr = kthread_run(cmm_thread, NULL, "cmmthread");
 	if (IS_ERR(cmm_thread_ptr)) {
 		rc = PTR_ERR(cmm_thread_ptr);
-		goto out_unregister_sysfs;
+		goto out_unregister_notifier;
 	}
 
 	return rc;
 
-out_unregister_sysfs:
+out_unregister_notifier:
+	unregister_memory_notifier(&cmm_mem_nb);
+	unregister_memory_isolate_notifier(&cmm_mem_isolate_nb);
 	cmm_unregister_sysfs(&cmm_sysdev);
 out_reboot_notifier:
 	unregister_reboot_notifier(&cmm_reboot_nb);
@@ -458,6 +655,8 @@ static void cmm_exit(void)
 		kthread_stop(cmm_thread_ptr);
 	unregister_oom_notifier(&cmm_oom_nb);
 	unregister_reboot_notifier(&cmm_reboot_nb);
+	unregister_memory_notifier(&cmm_mem_nb);
+	unregister_memory_isolate_notifier(&cmm_mem_isolate_nb);
 	cmm_free_pages(loaned_pages);
 	cmm_unregister_sysfs(&cmm_sysdev);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
