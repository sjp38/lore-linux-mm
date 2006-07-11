Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.6/8.13.6) with ESMTP id k6BELdYi073980
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 11 Jul 2006 14:21:40 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6BEOV18103918
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 11 Jul 2006 16:24:32 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6BELb9i019988
	for <linux-mm@kvack.org>; Tue, 11 Jul 2006 16:21:37 +0200
Subject: Re: [patch] out of memory notifier - 2nd try.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <20060711041209.1c9cee49.akpm@osdl.org>
References: <20060711105148.GA28648@skybase>
	 <20060711041209.1c9cee49.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 11 Jul 2006 16:21:38 +0200
Message-Id: <1152627698.18034.22.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-07-11 at 04:12 -0700, Andrew Morton wrote: 
> I have some negative feedback! ;)

Issues are fixes, new patch attached.

--
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.

--
From: Martin Schwidefsky <schwidefsky@de.ibm.com>

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
 arch/s390/mm/cmm.c   |  157 +++++++++++++++++++++++++++++++--------------------
 include/linux/swap.h |    4 +
 mm/oom_kill.c        |   21 ++++++
 3 files changed, 121 insertions(+), 61 deletions(-)

diff -urpN linux-2.6/arch/s390/mm/cmm.c linux-2.6-oom/arch/s390/mm/cmm.c
--- linux-2.6/arch/s390/mm/cmm.c	2006-07-11 12:53:21.000000000 +0200
+++ linux-2.6-oom/arch/s390/mm/cmm.c	2006-07-11 16:04:47.000000000 +0200
@@ -15,6 +15,7 @@
 #include <linux/sched.h>
 #include <linux/sysctl.h>
 #include <linux/ctype.h>
+#include <linux/swap.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -34,17 +35,18 @@ struct cmm_page_array {
 	unsigned long pages[CMM_NR_PAGES];
 };
 
-static long cmm_pages = 0;
-static long cmm_timed_pages = 0;
-static volatile long cmm_pages_target = 0;
-static volatile long cmm_timed_pages_target = 0;
-static long cmm_timeout_pages = 0;
-static long cmm_timeout_seconds = 0;
+static long cmm_pages;
+static long cmm_timed_pages;
+static volatile long cmm_pages_target;
+static volatile long cmm_timed_pages_target;
+static long cmm_timeout_pages;
+static long cmm_timeout_seconds;
+
+static struct cmm_page_array *cmm_page_list;
+static struct cmm_page_array *cmm_timed_page_list;
+static DEFINE_SPINLOCK(cmm_lock);
 
-static struct cmm_page_array *cmm_page_list = NULL;
-static struct cmm_page_array *cmm_timed_page_list = NULL;
-
-static unsigned long cmm_thread_active = 0;
+static unsigned long cmm_thread_active;
 static struct work_struct cmm_thread_starter;
 static wait_queue_head_t cmm_thread_wait;
 static struct timer_list cmm_timer;
@@ -69,58 +71,89 @@ cmm_strtoul(const char *cp, char **endp)
 }
 
 static long
-cmm_alloc_pages(long pages, long *counter, struct cmm_page_array **list)
+cmm_alloc_pages(long nr, long *counter, struct cmm_page_array **list)
 {
-	struct cmm_page_array *pa;
-	unsigned long page;
+	struct cmm_page_array *pa, *npa;
+	unsigned long addr;
 
-	pa = *list;
-	while (pages) {
-		page = __get_free_page(GFP_NOIO);
-		if (!page)
+	while (nr) {
+		addr = __get_free_page(GFP_NOIO);
+		if (!addr)
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
-				free_page(page);
+			if (!npa) {
+				free_page(addr);
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
-		diag10(page);
-		pa->pages[pa->index++] = page;
+		diag10(addr);
+		pa->pages[pa->index++] = addr;
 		(*counter)++;
-		pages--;
+		spin_unlock(&cmm_lock);
+		nr--;
 	}
-	return pages;
+	return nr;
 }
 
-static void
-cmm_free_pages(long pages, long *counter, struct cmm_page_array **list)
+static long
+cmm_free_pages(long nr, long *counter, struct cmm_page_array **list)
 {
 	struct cmm_page_array *pa;
-	unsigned long page;
+	unsigned long addr;
 
+	spin_lock(&cmm_lock);
 	pa = *list;
-	while (pages) {
+	while (nr) {
 		if (!pa || pa->index <= 0)
 			break;
-		page = pa->pages[--pa->index];
+		addr = pa->pages[--pa->index];
 		if (pa->index == 0) {
 			pa = pa->next;
 			free_page((unsigned long) *list);
 			*list = pa;
 		}
-		free_page(page);
+		free_page(addr);
 		(*counter)--;
-		pages--;
+		nr--;
 	}
+	spin_unlock(&cmm_lock);
+	return nr;
 }
 
+static int cmm_oom_notify(struct notifier_block *self,
+			  unsigned long dummy, void *parm)
+{
+	unsigned long *freed = parm;
+	long nr = 256;
+
+	nr = cmm_free_pages(nr, &cmm_timed_pages, &cmm_timed_page_list);
+	if (nr > 0)
+		nr = cmm_free_pages(nr, &cmm_pages, &cmm_page_list);
+	cmm_pages_target = cmm_pages;
+	cmm_timed_pages_target = cmm_timed_pages;
+	*freed += 256 - nr;
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
@@ -193,21 +226,21 @@ cmm_set_timer(void)
 static void
 cmm_timer_fn(unsigned long ignored)
 {
-	long pages;
+	long nr;
 
-	pages = cmm_timed_pages_target - cmm_timeout_pages;
-	if (pages < 0)
+	nr = cmm_timed_pages_target - cmm_timeout_pages;
+	if (nr < 0)
 		cmm_timed_pages_target = 0;
 	else
-		cmm_timed_pages_target = pages;
+		cmm_timed_pages_target = nr;
 	cmm_kick_thread();
 	cmm_set_timer();
 }
 
 void
-cmm_set_pages(long pages)
+cmm_set_pages(long nr)
 {
-	cmm_pages_target = pages;
+	cmm_pages_target = nr;
 	cmm_kick_thread();
 }
 
@@ -218,9 +251,9 @@ cmm_get_pages(void)
 }
 
 void
-cmm_add_timed_pages(long pages)
+cmm_add_timed_pages(long nr)
 {
-	cmm_timed_pages_target += pages;
+	cmm_timed_pages_target += nr;
 	cmm_kick_thread();
 }
 
@@ -231,9 +264,9 @@ cmm_get_timed_pages(void)
 }
 
 void
-cmm_set_timeout(long pages, long seconds)
+cmm_set_timeout(long nr, long seconds)
 {
-	cmm_timeout_pages = pages;
+	cmm_timeout_pages = nr;
 	cmm_timeout_seconds = seconds;
 	cmm_set_timer();
 }
@@ -261,7 +294,7 @@ cmm_pages_handler(ctl_table *ctl, int wr
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char buf[16], *p;
-	long pages;
+	long nr;
 	int len;
 
 	if (!*lenp || (*ppos && !write)) {
@@ -276,17 +309,17 @@ cmm_pages_handler(ctl_table *ctl, int wr
 			return -EFAULT;
 		buf[sizeof(buf) - 1] = '\0';
 		cmm_skip_blanks(buf, &p);
-		pages = cmm_strtoul(p, &p);
+		nr = cmm_strtoul(p, &p);
 		if (ctl == &cmm_table[0])
-			cmm_set_pages(pages);
+			cmm_set_pages(nr);
 		else
-			cmm_add_timed_pages(pages);
+			cmm_add_timed_pages(nr);
 	} else {
 		if (ctl == &cmm_table[0])
-			pages = cmm_get_pages();
+			nr = cmm_get_pages();
 		else
-			pages = cmm_get_timed_pages();
-		len = sprintf(buf, "%ld\n", pages);
+			nr = cmm_get_timed_pages();
+		len = sprintf(buf, "%ld\n", nr);
 		if (len > *lenp)
 			len = *lenp;
 		if (copy_to_user(buffer, buf, len))
@@ -302,7 +335,7 @@ cmm_timeout_handler(ctl_table *ctl, int 
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char buf[64], *p;
-	long pages, seconds;
+	long nr, seconds;
 	int len;
 
 	if (!*lenp || (*ppos && !write)) {
@@ -317,10 +350,10 @@ cmm_timeout_handler(ctl_table *ctl, int 
 			return -EFAULT;
 		buf[sizeof(buf) - 1] = '\0';
 		cmm_skip_blanks(buf, &p);
-		pages = cmm_strtoul(p, &p);
+		nr = cmm_strtoul(p, &p);
 		cmm_skip_blanks(p, &p);
 		seconds = cmm_strtoul(p, &p);
-		cmm_set_timeout(pages, seconds);
+		cmm_set_timeout(nr, seconds);
 	} else {
 		len = sprintf(buf, "%ld %ld\n",
 			      cmm_timeout_pages, cmm_timeout_seconds);
@@ -373,7 +406,7 @@ static struct ctl_table cmm_dir_table[] 
 static void
 cmm_smsg_target(char *from, char *msg)
 {
-	long pages, seconds;
+	long nr, seconds;
 
 	if (strlen(sender) > 0 && strcmp(from, sender) != 0)
 		return;
@@ -382,27 +415,27 @@ cmm_smsg_target(char *from, char *msg)
 	if (strncmp(msg, "SHRINK", 6) == 0) {
 		if (!cmm_skip_blanks(msg + 6, &msg))
 			return;
-		pages = cmm_strtoul(msg, &msg);
+		nr = cmm_strtoul(msg, &msg);
 		cmm_skip_blanks(msg, &msg);
 		if (*msg == '\0')
-			cmm_set_pages(pages);
+			cmm_set_pages(nr);
 	} else if (strncmp(msg, "RELEASE", 7) == 0) {
 		if (!cmm_skip_blanks(msg + 7, &msg))
 			return;
-		pages = cmm_strtoul(msg, &msg);
+		nr = cmm_strtoul(msg, &msg);
 		cmm_skip_blanks(msg, &msg);
 		if (*msg == '\0')
-			cmm_add_timed_pages(pages);
+			cmm_add_timed_pages(nr);
 	} else if (strncmp(msg, "REUSE", 5) == 0) {
 		if (!cmm_skip_blanks(msg + 5, &msg))
 			return;
-		pages = cmm_strtoul(msg, &msg);
+		nr = cmm_strtoul(msg, &msg);
 		if (!cmm_skip_blanks(msg, &msg))
 			return;
 		seconds = cmm_strtoul(msg, &msg);
 		cmm_skip_blanks(msg, &msg);
 		if (*msg == '\0')
-			cmm_set_timeout(pages, seconds);
+			cmm_set_timeout(nr, seconds);
 	}
 }
 #endif
@@ -418,6 +451,7 @@ cmm_init (void)
 #ifdef CONFIG_CMM_IUCV
 	smsg_register_callback(SMSG_PREFIX, cmm_smsg_target);
 #endif
+	register_oom_notifier(&cmm_oom_nb);
 	INIT_WORK(&cmm_thread_starter, (void *) cmm_start_thread, NULL);
 	init_waitqueue_head(&cmm_thread_wait);
 	init_timer(&cmm_timer);
@@ -427,6 +461,7 @@ cmm_init (void)
 static void
 cmm_exit(void)
 {
+	unregister_oom_notifier(&cmm_oom_nb);
 	cmm_free_pages(cmm_pages, &cmm_pages, &cmm_page_list);
 	cmm_free_pages(cmm_timed_pages, &cmm_timed_pages, &cmm_timed_page_list);
 #ifdef CONFIG_CMM_PROC
diff -urpN linux-2.6/include/linux/swap.h linux-2.6-oom/include/linux/swap.h
--- linux-2.6/include/linux/swap.h	2006-07-11 12:53:21.000000000 +0200
+++ linux-2.6-oom/include/linux/swap.h	2006-07-11 16:04:20.000000000 +0200
@@ -6,6 +6,7 @@
 #include <linux/mmzone.h>
 #include <linux/list.h>
 #include <linux/sched.h>
+#include <linux/notifier.h>
 
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -156,6 +157,9 @@ struct swap_list_t {
 
 /* linux/mm/oom_kill.c */
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
+extern int register_oom_notifier(struct notifier_block *nb);
+extern int unregister_oom_notifier(struct notifier_block *nb);
+
 
 /* linux/mm/memory.c */
 extern void swapin_readahead(swp_entry_t, unsigned long, struct vm_area_struct *);
diff -urpN linux-2.6/mm/oom_kill.c linux-2.6-oom/mm/oom_kill.c
--- linux-2.6/mm/oom_kill.c	2006-07-11 12:53:21.000000000 +0200
+++ linux-2.6-oom/mm/oom_kill.c	2006-07-11 16:07:33.000000000 +0200
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
 
+static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
+
+int register_oom_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&oom_notify_list, nb);
+}
+EXPORT_SYMBOL_GPL(register_oom_notifier);
+
+int unregister_oom_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&oom_notify_list, nb);
+}
+EXPORT_SYMBOL_GPL(unregister_oom_notifier);
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  *
@@ -318,6 +333,12 @@ void out_of_memory(struct zonelist *zone
 {
 	struct task_struct *p;
 	unsigned long points = 0;
+	unsigned long freed = 0;
+
+	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
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
