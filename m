Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.6/8.13.6) with ESMTP id k43Eus4X137354
	for <linux-mm@kvack.org>; Wed, 3 May 2006 14:56:54 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k43Ew6H6113070
	for <linux-mm@kvack.org>; Wed, 3 May 2006 16:58:06 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k43EurpP017930
	for <linux-mm@kvack.org>; Wed, 3 May 2006 16:56:53 +0200
Received: from localhost (dyn-9-152-216-91.boeblingen.de.ibm.com [9.152.216.91])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.12.11) with ESMTP id k43EurRp017925
	for <linux-mm@kvack.org>; Wed, 3 May 2006 16:56:53 +0200
Date: Wed, 3 May 2006 16:57:03 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch] out of memory notifier.
Message-ID: <20060503145702.GA17348@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[patch] out of memory notifier.

Add a notifer chain to the out of memory killer. If one of the registered
callbacks could release some memory, do not kill the process but return
and retry the allocation that forced the oom killer to run.

The purpose of the notifier is to add a safety net in the presence of
memory ballooners. If the resource manager inflated the balloon to a size
where memory allocations can not be satisfied anymore, it is better to
deflate the balloon a bit instead of killing processes.

The implementation for the s390 ballooner is included.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/mm/cmm.c   |   51 +++++++++++++++++++++++++++++++++++++++++++--------
 include/linux/swap.h |    4 ++++
 mm/oom_kill.c        |   21 +++++++++++++++++++++
 3 files changed, 68 insertions(+), 8 deletions(-)

diff -urpN linux-2.6/arch/s390/mm/cmm.c linux-2.6-oom/arch/s390/mm/cmm.c
--- linux-2.6/arch/s390/mm/cmm.c	2006-05-03 15:48:51.000000000 +0200
+++ linux-2.6-oom/arch/s390/mm/cmm.c	2006-05-03 16:43:23.000000000 +0200
@@ -16,6 +16,7 @@
 #include <linux/sched.h>
 #include <linux/sysctl.h>
 #include <linux/ctype.h>
+#include <linux/swap.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -44,6 +45,7 @@ static long cmm_timeout_seconds = 0;
 
 static struct cmm_page_array *cmm_page_list = NULL;
 static struct cmm_page_array *cmm_timed_page_list = NULL;
+static DEFINE_SPINLOCK(cmm_lock);
 
 static unsigned long cmm_thread_active = 0;
 static struct work_struct cmm_thread_starter;
@@ -72,40 +74,50 @@ cmm_strtoul(const char *cp, char **endp)
 static long
 cmm_alloc_pages(long pages, long *counter, struct cmm_page_array **list)
 {
-	struct cmm_page_array *pa;
+	struct cmm_page_array *pa, *npa;
 	unsigned long page;
 
-	pa = *list;
 	while (pages) {
 		page = __get_free_page(GFP_NOIO);
 		if (!page)
 			break;
+		spin_lock(&cmm_lock);
+		pa = *list;
 		if (!pa || pa->index >= CMM_NR_PAGES) {
 			/* Need a new page for the page list. */
-			pa = (struct cmm_page_array *)
+			spin_unlock(&cmm_lock);
+			npa = (struct cmm_page_array *)
 				__get_free_page(GFP_NOIO);
-			if (!pa) {
+			if (!npa) {
 				free_page(page);
 				break;
 			}
-			pa->next = *list;
-			pa->index = 0;
-			*list = pa;
+			spin_lock(&cmm_lock);
+			pa = *list;
+			if (!pa || pa->index >= CMM_NR_PAGES) {
+				npa->next = pa;
+				npa->index = 0;
+				pa = npa;
+				*list = pa;
+			} else
+				free_page((unsigned long) npa);
 		}
 		diag10(page);
 		pa->pages[pa->index++] = page;
 		(*counter)++;
+		spin_unlock(&cmm_lock);
 		pages--;
 	}
 	return pages;
 }
 
-static void
+static long
 cmm_free_pages(long pages, long *counter, struct cmm_page_array **list)
 {
 	struct cmm_page_array *pa;
 	unsigned long page;
 
+	spin_lock(&cmm_lock);
 	pa = *list;
 	while (pages) {
 		if (!pa || pa->index <= 0)
@@ -120,8 +132,29 @@ cmm_free_pages(long pages, long *counter
 		(*counter)--;
 		pages--;
 	}
+	spin_unlock(&cmm_lock);
+	return pages;
 }
 
+static int cmm_oom_notify(struct notifier_block *self,
+			  unsigned long dummy, void *parm)
+{
+	unsigned long *freed = parm;
+	long pages = 256;
+
+	pages = cmm_free_pages(pages, &cmm_timed_pages, &cmm_timed_page_list);
+	if (pages > 0)
+		pages = cmm_free_pages(pages, &cmm_pages, &cmm_page_list);
+	cmm_pages_target = cmm_pages;
+	cmm_timed_pages_target = cmm_timed_pages;
+	*freed += 256 - pages;
+	return NOTIFY_OK;
+}
+
+static struct notifier_block cmm_oom_nb = {
+	.notifier_call = cmm_oom_notify
+};
+
 static int
 cmm_thread(void *dummy)
 {
@@ -419,6 +452,7 @@ cmm_init (void)
 #ifdef CONFIG_CMM_IUCV
 	smsg_register_callback(SMSG_PREFIX, cmm_smsg_target);
 #endif
+	register_oom_notifier(&cmm_oom_nb);
 	INIT_WORK(&cmm_thread_starter, (void *) cmm_start_thread, NULL);
 	init_waitqueue_head(&cmm_thread_wait);
 	init_timer(&cmm_timer);
@@ -428,6 +462,7 @@ cmm_init (void)
 static void
 cmm_exit(void)
 {
+	unregister_oom_notifier(&cmm_oom_nb);
 	cmm_free_pages(cmm_pages, &cmm_pages, &cmm_page_list);
 	cmm_free_pages(cmm_timed_pages, &cmm_timed_pages, &cmm_timed_page_list);
 #ifdef CONFIG_CMM_PROC
diff -urpN linux-2.6/include/linux/swap.h linux-2.6-oom/include/linux/swap.h
--- linux-2.6/include/linux/swap.h	2006-05-03 15:49:15.000000000 +0200
+++ linux-2.6-oom/include/linux/swap.h	2006-05-03 15:51:01.000000000 +0200
@@ -7,6 +7,7 @@
 #include <linux/mmzone.h>
 #include <linux/list.h>
 #include <linux/sched.h>
+#include <linux/notifier.h>
 
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -157,6 +158,9 @@ struct swap_list_t {
 
 /* linux/mm/oom_kill.c */
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
+extern int register_oom_notifier(struct notifier_block *nb);
+extern int unregister_oom_notifier(struct notifier_block *nb);
+
 
 /* linux/mm/memory.c */
 extern void swapin_readahead(swp_entry_t, unsigned long, struct vm_area_struct *);
diff -urpN linux-2.6/mm/oom_kill.c linux-2.6-oom/mm/oom_kill.c
--- linux-2.6/mm/oom_kill.c	2006-05-03 15:49:15.000000000 +0200
+++ linux-2.6-oom/mm/oom_kill.c	2006-05-03 15:51:01.000000000 +0200
@@ -21,6 +21,7 @@
 #include <linux/timex.h>
 #include <linux/jiffies.h>
 #include <linux/cpuset.h>
+#include <linux/module.h>
 
 int sysctl_panic_on_oom;
 /* #define DEBUG */
@@ -306,6 +307,20 @@ static int oom_kill_process(struct task_
 	return oom_kill_task(p, message);
 }
 
+static struct notifier_block *oom_notify_list = 0;
+
+int register_oom_notifier(struct notifier_block *nb)
+{
+	return notifier_chain_register(&oom_notify_list, nb);
+}
+EXPORT_SYMBOL_GPL(register_oom_notifier);
+
+int unregister_oom_notifier(struct notifier_block *nb)
+{
+	return notifier_chain_unregister(&oom_notify_list, nb);
+}
+EXPORT_SYMBOL_GPL(unregister_oom_notifier);
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  *
@@ -318,6 +333,12 @@ void out_of_memory(struct zonelist *zone
 {
 	task_t *p;
 	unsigned long points = 0;
+	unsigned long freed = 0;
+
+	notifier_call_chain(&oom_notify_list, 0, &freed);
+	if (freed > 0)
+		/* Got some memory back in the last second. */
+		return;
 
 	if (printk_ratelimit()) {
 		printk("oom-killer: gfp_mask=0x%x, order=%d\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
