Received: from alogconduit1ah.ccr.net (root@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA12423
	for <linux-mm@kvack.org>; Sun, 23 May 1999 15:27:38 -0400
Subject: [PATCH] Support for modules that use swap
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 May 1999 13:47:03 -0500
Message-ID: <m190afsjx4.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The following patch allows shmfs (and possibly ipc/shm.c) to be built
as modules by providing an interface to swap off, that you can add
and remove functions from.

Eric

 
diff -uNrX linux-ignore-files linux-2.3.3.eb3/include/linux/shm.h linux-2.3.3.eb4/include/linux/shm.h
--- linux-2.3.3.eb3/include/linux/shm.h	Tue Feb  9 22:55:51 1999
+++ linux-2.3.3.eb4/include/linux/shm.h	Thu May 20 20:24:17 1999
@@ -72,7 +72,6 @@
 asmlinkage int sys_shmat (int shmid, char *shmaddr, int shmflg, unsigned long *addr);
 asmlinkage int sys_shmdt (char *shmaddr);
 asmlinkage int sys_shmctl (int shmid, int cmd, struct shmid_ds *buf);
-extern void shm_unuse(unsigned long entry, unsigned long page);
 
 #endif /* __KERNEL__ */
 
diff -uNrX linux-ignore-files linux-2.3.3.eb3/include/linux/swap.h linux-2.3.3.eb4/include/linux/swap.h
--- linux-2.3.3.eb3/include/linux/swap.h	Tue May 18 01:09:31 1999
+++ linux-2.3.3.eb4/include/linux/swap.h	Thu May 20 20:24:17 1999
@@ -125,6 +125,20 @@
 asmlinkage int sys_swapoff(const char *);
 asmlinkage int sys_swapon(const char *, int);
 
+
+/* So that external drivers can use swap, swapoff */
+struct swap_unuse {
+	void (*unuse)(unsigned long entry, unsigned long page, void *arg);
+	int (*read_page_tables)(void *arg);
+	void (*swap_page_tables)(void *arg);
+	void *arg;
+	struct swap_unuse *prev;
+	struct swap_unuse *next;
+};
+
+extern void register_swap_unuse_function (struct swap_unuse *swap_unuse);
+extern void unregister_swap_unuse_function (struct swap_unuse *swap_unuse);
+
 /*
  * vm_ops not present page codes for shared memory.
  *
diff -uNrX linux-ignore-files linux-2.3.3.eb3/ipc/shm.c linux-2.3.3.eb4/ipc/shm.c
--- linux-2.3.3.eb3/ipc/shm.c	Sun May 16 22:07:53 1999
+++ linux-2.3.3.eb4/ipc/shm.c	Thu May 20 20:24:17 1999
@@ -41,6 +41,14 @@
 static ulong swap_successes = 0;
 static ulong used_segs = 0;
 
+static void shm_unuse(unsigned long entry, unsigned long page, void *arg);
+static struct swap_unuse shm_swap_unuse = 
+{
+	shm_unuse,
+	NULL,
+	NULL, NULL, NULL
+};
+
 void __init shm_init (void)
 {
 	int id;
@@ -49,6 +57,7 @@
 		shm_segs[id] = (struct shmid_kernel *) IPC_UNUSED;
 	shm_tot = shm_rss = shm_seq = max_shmid = used_segs = 0;
 	init_waitqueue_head(&shm_lock);
+ 	register_swap_unuse_function(&shm_swap_unuse);
 	return;
 }
 
@@ -748,7 +757,7 @@
 /*
  * unuse_shm() search for an eventually swapped out shm page.
  */
-void shm_unuse(unsigned long entry, unsigned long page)
+static void shm_unuse(unsigned long entry, unsigned long page, void *arg)
 {
 	int i, n;
 
diff -uNrX linux-ignore-files linux-2.3.3.eb3/mm/Makefile linux-2.3.3.eb4/mm/Makefile
--- linux-2.3.3.eb3/mm/Makefile	Tue May 12 14:17:54 1998
+++ linux-2.3.3.eb4/mm/Makefile	Thu May 20 20:24:17 1999
@@ -12,4 +12,6 @@
 	    vmalloc.o slab.o \
 	    swap.o vmscan.o page_io.o page_alloc.o swap_state.o swapfile.o
 
+OX_OBJS := swap_syms.o
+
 include $(TOPDIR)/Rules.make
diff -uNrX linux-ignore-files linux-2.3.3.eb3/mm/swap_syms.c linux-2.3.3.eb4/mm/swap_syms.c
--- linux-2.3.3.eb3/mm/swap_syms.c	Wed Dec 31 18:00:00 1969
+++ linux-2.3.3.eb4/mm/swap_syms.c	Thu May 20 20:24:17 1999
@@ -0,0 +1,16 @@
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/swap.h>
+
+/* Explicit swapping */
+EXPORT_SYMBOL(rw_swap_page);
+EXPORT_SYMBOL(rw_swap_page_nocache);
+EXPORT_SYMBOL(rw_swap_page_nolock);
+EXPORT_SYMBOL(swap_free);
+EXPORT_SYMBOL(get_swap_page);
+EXPORT_SYMBOL(si_swapinfo);
+EXPORT_SYMBOL(register_swap_unuse_function);
+EXPORT_SYMBOL(unregister_swap_unuse_function);
+EXPORT_SYMBOL(swapper_inode);
diff -uNrX linux-ignore-files linux-2.3.3.eb3/mm/swapfile.c linux-2.3.3.eb4/mm/swapfile.c
--- linux-2.3.3.eb3/mm/swapfile.c	Tue May 18 01:09:31 1999
+++ linux-2.3.3.eb4/mm/swapfile.c	Thu May 20 21:02:31 1999
@@ -279,19 +279,143 @@
 	return;
 }
 
+
+static void do_unuse_processes(unsigned long entry, unsigned long page, void *arg)
+{
+	struct task_struct *p;
+
+	read_lock(&tasklist_lock);
+	for_each_task(p)
+		unuse_process(p->mm, entry, page);
+	read_unlock(&tasklist_lock);
+}
+
+static struct swap_unuse unuse_processes =
+{
+	do_unuse_processes, 
+	NULL,
+	NULL,
+	NULL,
+	&unuse_processes, 
+	&unuse_processes
+};
+
+/* Don't add or remove unuse functions, or do another swapoff while a swapoff is in progress.
+ * It reduces some theoretical races.
+ */
+static int swap_off_lock = 0;
+static DECLARE_WAIT_QUEUE_HEAD(swap_off_wait);
+
+static void swap_unuse(unsigned long entry, unsigned long page)
+{
+
+	struct swap_unuse *swap_unuse, *next_unuse;
+	next_unuse = unuse_processes.next;
+	do {
+		swap_unuse = next_unuse;
+		next_unuse = next_unuse->next;
+		if (swap_unuse->unuse) {
+			swap_unuse->unuse(entry, page, swap_unuse->arg);
+		}
+	} while(swap_unuse != &unuse_processes);
+	return;
+}
+
+static int read_page_tables(void)
+{
+	struct swap_unuse *swap_unuse, *next_unuse;
+	int error =  0;
+	next_unuse = unuse_processes.next;
+	do {
+		swap_unuse = next_unuse;
+		next_unuse = next_unuse->next;
+		if (swap_unuse->read_page_tables) {
+			error = swap_unuse->read_page_tables(swap_unuse->arg);
+		}
+	} while(!error && (swap_unuse != &unuse_processes));
+	if (!error) {
+		return 0;
+	}
+	swap_unuse = swap_unuse->prev;
+	/* We couldn't swap the page tables so reenable swapping for them */
+	while(swap_unuse != &unuse_processes) {
+		if (swap_unuse->swap_page_tables) {
+			swap_unuse->swap_page_tables(swap_unuse->arg);
+		}
+		swap_unuse = swap_unuse->prev;
+	}
+	return error;
+}
+
+static void swap_page_tables(void)
+{
+	struct swap_unuse *swap_unuse, *next_unuse;
+	next_unuse = unuse_processes.next;
+	do {
+		swap_unuse = next_unuse;
+		next_unuse = next_unuse->next;
+		if (swap_unuse->swap_page_tables) {
+			swap_unuse->swap_page_tables(swap_unuse->arg);
+		}
+	} while(swap_unuse != &unuse_processes);
+	return;
+}
+
+void register_swap_unuse_function (struct swap_unuse *swap_unuse)
+{
+	if (!swap_unuse) {
+		return;
+	}
+	while (swap_off_lock) {
+		sleep_on(&swap_off_wait);
+	}
+	swap_unuse->prev = &unuse_processes;
+	swap_unuse->next = unuse_processes.next;
+	unuse_processes.next->prev = swap_unuse;
+	unuse_processes.next = swap_unuse;
+}
+
+void unregister_swap_unuse_function (struct swap_unuse *swap_unuse)
+{
+	struct swap_unuse *next;
+	if (!swap_unuse) {
+		return;
+	}
+	while (swap_off_lock) {
+		sleep_on(&swap_off_wait);
+	}
+	next = swap_unuse->next;
+	next->prev = swap_unuse->prev;
+	next->prev->next = next;
+
+	swap_unuse->next = swap_unuse->prev = NULL;
+}
+
 /*
- * We completely avoid races by reading each swap page in advance,
- * and then search for the process using it.  All the necessary
+ * We completely avoid races by:
+ * - reading & locking all of the page tables into memory,
+ * - reading each swap page in advance, and then search for page table entry using it.  
+ * - when there are no more page table entries, letting the page tables swap again.
+ *
+ * All the necessary
  * page table adjustments can then be made atomically.
  */
 static int try_to_unuse(unsigned int type)
 {
 	struct swap_info_struct * si = &swap_info[type];
-	struct task_struct *p;
 	struct page *page_map;
 	unsigned long entry, page;
 	int i;
+	int err;
 
+	while(swap_off_lock) {
+		sleep_on(&swap_off_wait);
+	}
+	swap_off_lock = 1;
+	err = read_page_tables();
+	if (err != 0) {
+		return err;
+	}
 	while (1) {
 		/*
 		 * Find a swap page in use and read it in.
@@ -319,11 +443,7 @@
   			return -ENOMEM;
 		}
 		page = page_address(page_map);
-		read_lock(&tasklist_lock);
-		for_each_task(p)
-			unuse_process(p->mm, entry, page);
-		read_unlock(&tasklist_lock);
-		shm_unuse(entry, page);
+		swap_unuse(entry, page);
 		/* Now get rid of the extra reference to the temporary
                    page we've been using. */
 		if (PageSwapCache(page_map))
@@ -341,6 +461,9 @@
 			nr_swap_pages++;
 		}
 	}
+	swap_page_tables();
+	swap_off_lock = 0;
+	wake_up(&swap_off_wait);
 	return 0;
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
