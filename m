Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA04317
	for <linux-mm@kvack.org>; Thu, 11 Jun 1998 10:20:36 -0400
Subject: Re: patch for 2.1.102 swap code
References: <356478F0.FE1C378F@star.net>
	<199805241728.SAA02816@dax.dcs.ed.ac.uk>
	<m190nq4jan.fsf@flinx.npwt.net>
	<199805262152.WAA02934@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 11 Jun 1998 09:31:22 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Tue, 26 May 1998 22:52:21 +0100
Message-ID: <m167i857t1.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

ST> Hi,
>> Note: there is a problem with swapoff that should at least be considered.
>> If you use have a SYSV shared memory, and don't map it into a process,
>> and that memory get's swapped out, swapoff will not be able to find it.

>> This is a very long standing bug and appears not to be a problem in practice.
>> But it is certainly a potential problem.

ST> Thanks; it's added to my list.

Here is a preliminary patch that should fix the problem.


diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.1.101.x0/include/linux/swap.h linux-2.1.101.x2/include/linux/swap.h
--- linux-2.1.101.x0/include/linux/swap.h	Wed Apr 22 11:08:16 1998
+++ linux-2.1.101.x2/include/linux/swap.h	Wed Jun  3 22:21:51 1998
@@ -75,7 +75,18 @@
 void si_swapinfo(struct sysinfo *);
 unsigned long get_swap_page(void);
 extern void FASTCALL(swap_free(unsigned long));
+  
+  /* So that external drivers can use swap, swapoff */
+struct swap_unuse {
+	int (*func)(unsigned int type, void *arg);
+	void *arg;
+	struct swap_unuse *prev;
+	struct swap_unuse *next;
+};
 
+void register_swap_unuse_function (struct swap_unuse *swap_unuse);
+void unregister_swap_unuse_function (struct swap_unuse *swap_unuse);
+ 
 /*
  * vm_ops not present page codes for shared memory.
  *
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.1.101.x0/ipc/shm.c linux-2.1.101.x2/ipc/shm.c
--- linux-2.1.101.x0/ipc/shm.c	Wed Jun  3 22:54:23 1998
+++ linux-2.1.101.x2/ipc/shm.c	Thu Jun  4 09:23:28 1998
@@ -30,6 +30,8 @@
 static void shm_open (struct vm_area_struct *shmd);
 static void shm_close (struct vm_area_struct *shmd);
 static pte_t shm_swap_in(struct vm_area_struct *, unsigned long, unsigned long);
+static int shm_try_to_unuse_seg(struct shmid_ds *shp, unsigned int type);
+static int shm_try_to_unuse(unsigned int type, void *arg);
 
 static int shm_tot = 0; /* total number of shared memory pages */
 static int shm_rss = 0; /* number of shared memory pages that are in memory */
@@ -45,6 +47,11 @@
 static ulong swap_successes = 0;
 static ulong used_segs = 0;
 
+/* swap off */
+static struct swap_unuse shm_swap_unuse = {
+	shm_try_to_unuse, 0, 0, 0
+};
+
 __initfunc(void shm_init (void))
 {
 	int id;
@@ -53,6 +60,7 @@
 		shm_segs[id] = (struct shmid_ds *) IPC_UNUSED;
 	shm_tot = shm_rss = shm_seq = max_shmid = used_segs = 0;
 	shm_lock = NULL;
+	register_swap_unuse_function(&shm_swap_unuse);
 	return;
 }
 
@@ -830,4 +838,56 @@
 	shm_swp++;
 	shm_rss--;
 	return 1;
+}
+
+/* Swap off support */
+static int shm_try_to_unuse_seg(struct shmid_ds *shp, unsigned int type)
+{
+	unsigned long page = 0;
+	int i, numpages;
+	numpages = shp->shm_npages;
+	for (i = 0; i < numpages; i++) {
+		pte_t pte;
+		if (!page) {
+			page = get_free_page(GFP_KERNEL);
+		}
+		pte = __pte(shp->shm_pages[i]);
+		if (pte_none(pte))
+			continue;
+		if (pte_present(pte))
+			continue;
+		if (!page) 
+			return -1;
+		rw_swap_page_nocache(READ, pte_val(pte), (char *)page);
+		pte = __pte(shp->shm_pages[i]);
+		if (!pte_present(pte)) {
+			swap_free(pte_val(pte));
+			shm_swp--;
+			shm_rss++;
+			pte = pte_mkdirty(mk_pte(page, PAGE_SHARED));
+			shp->shm_pages[i] = pte_val(pte);
+		}
+	}
+	if (page) {
+		free_page(page);
+		page = 0;
+	}
+	return 0;
+}
+
+static int shm_try_to_unuse(unsigned int type, void *arg)
+{
+	int id;
+	struct shmid_ds *ident;
+	for(id = 0; id < SHMMNI; id++) {
+		ident = shm_segs[id];
+		if ((ident != (struct shmid_ds *) IPC_UNUSED) && 
+		    (ident != (struct shmid_ds *) IPC_NOID)) {
+			int result;
+			result = shm_try_to_unuse_seg(ident, type);
+			if (result != 0) 
+				return -1;
+		}
+	}
+	return 0;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.1.101.x0/mm/Makefile linux-2.1.101.x2/mm/Makefile
--- linux-2.1.101.x0/mm/Makefile	Tue May 12 14:17:54 1998
+++ linux-2.1.101.x2/mm/Makefile	Wed Jun  3 22:21:51 1998
@@ -12,4 +12,6 @@
 	    vmalloc.o slab.o \
 	    swap.o vmscan.o page_io.o page_alloc.o swap_state.o swapfile.o
 
+OX_OBJS := swap_syms.o
+
 include $(TOPDIR)/Rules.make
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.1.101.x0/mm/swap_syms.c linux-2.1.101.x2/mm/swap_syms.c
--- linux-2.1.101.x0/mm/swap_syms.c	Wed Dec 31 18:00:00 1969
+++ linux-2.1.101.x2/mm/swap_syms.c	Wed Jun  3 22:21:51 1998
@@ -0,0 +1,15 @@
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/swap.h>
+
+/* Explicit swapping */
+EXPORT_SYMBOL(rw_swap_page);
+EXPORT_SYMBOL(rw_swap_page_nocache);
+EXPORT_SYMBOL(swap_free);
+EXPORT_SYMBOL(get_swap_page);
+EXPORT_SYMBOL(si_swapinfo);
+EXPORT_SYMBOL(register_swap_unuse_function);
+EXPORT_SYMBOL(unregister_swap_unuse_function);
+EXPORT_SYMBOL(swapper_inode);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.1.101.x0/mm/swapfile.c linux-2.1.101.x2/mm/swapfile.c
--- linux-2.1.101.x0/mm/swapfile.c	Tue May 12 14:17:54 1998
+++ linux-2.1.101.x2/mm/swapfile.c	Wed Jun  3 22:21:51 1998
@@ -298,7 +298,7 @@
  * and then search for the process using it.  All the necessary
  * page table adjustments can then be made atomically.
  */
-static int try_to_unuse(unsigned int type)
+static int try_to_unuse_processes(unsigned int type, void *dummy)
 {
 	struct swap_info_struct * si = &swap_info[type];
 	struct task_struct *p;
@@ -345,6 +345,69 @@
 		}
 	}
 	return 0;
+}
+
+struct swap_unuse unuse_processes =
+{
+	try_to_unuse_processes, 
+	NULL,
+	&unuse_processes, 
+	&unuse_processes
+};
+
+/* Don't add or remove unuse functions while a swapoff is in progress.
+ * It reduces some theoretical races.
+ */
+static int swap_unuse_lock = 0;
+static struct wait_queue *swap_unuse_wait = NULL;
+
+static int try_to_unuse(unsigned int type)
+{
+	int error = 0;
+	struct swap_unuse *unuse_func, *next_func;
+	next_func = unuse_processes.next;
+	swap_unuse_lock = 1;
+	do {
+		unuse_func = next_func;
+		next_func = unuse_func->next;
+		error = unuse_func->func(type, unuse_func->arg);
+		if (error) {
+			return error;
+		}
+	} while (unuse_func != &unuse_processes);
+	swap_unuse_lock = 0;
+	wake_up(&swap_unuse_wait);
+	return 0;
+}
+
+void register_swap_unuse_function (struct swap_unuse *swap_unuse)
+{
+	if (!swap_unuse) {
+		return;
+	}
+	while (swap_unuse_lock) {
+		sleep_on(&swap_unuse_wait);
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
+	while (swap_unuse_lock) {
+		sleep_on(&swap_unuse_wait);
+	}
+	next = swap_unuse->next;
+	next->prev = swap_unuse->prev;
+	next->prev->next = next;
+
+	swap_unuse->next = swap_unuse->prev = NULL;
 }
 
 asmlinkage int sys_swapoff(const char * specialfile)
