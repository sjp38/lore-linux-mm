Message-ID: <393E22FC.2EDB1124@mandrakesoft.com>
Date: Wed, 07 Jun 2000 06:25:00 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: PATCH 2.4.0.1.ac10: a KISS memory pressure callback (rev 2)
References: <393DFB23.64FD2E3D@mandrakesoft.com> <oupln0hkgag.fsf@pigdrop.muc.suse.de>
Content-Type: multipart/mixed;
 boundary="------------5F5A7D832FC6C8D2BEB8F280"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------5F5A7D832FC6C8D2BEB8F280
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Attached is a patch against 2.4.0-test1-ac10 which adds a VM pressure
callback list, and cleans up the notifier chain code in the process. 
Since the callback occurs in do_try_to_free_pages, it is rather low
level, giving other kernel code flexibility when it comes to freeing
memory.  Kernel code wishing to handle memory pressure should call
register_freemem_notifier.  Thanks for the suggestions Andi.  Goodnight
all.  :)

-- 
Jeff Garzik              | Liberty is always dangerous, but
Building 1024            | it is the safest thing we have.
MandrakeSoft, Inc.       |      -- Harry Emerson Fosdick
--------------5F5A7D832FC6C8D2BEB8F280
Content-Type: text/plain; charset=us-ascii;
 name="vm-pressure-2.4.0.1.ac10.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-pressure-2.4.0.1.ac10.patch"

diff -ur vanilla/linux-2.4.0-test1-ac10/mm/vmscan.c linux_2_3/mm/vmscan.c
--- vanilla/linux-2.4.0-test1-ac10/mm/vmscan.c	Tue Jun  6 14:44:31 2000
+++ linux_2_3/mm/vmscan.c	Wed Jun  7 06:14:32 2000
@@ -23,6 +23,9 @@
 
 #include <asm/pgalloc.h>
 
+/* list of funcs to call when memory pressure occurs */
+extern struct notifier_block *freemem_notifier_list;
+
 /*
  * The swap-out functions return 1 if they successfully
  * threw something out, and we got a free page. It returns
@@ -428,6 +431,29 @@
 }
 
 /*
+ * The freemem notifier list holds a list of functions
+ * that are to be called when trying to free pages.
+ *
+ * Call them...  We don't use notifier_call_chain
+ * because the return code from a freemem notifier
+ * is treated as a shrink_*_memory-style return value.
+ */
+static int shrink_misc_memory (int priority, unsigned int gfp_mask)
+{
+	int count = 0;
+	struct notifier_block *nb = freemem_notifier_list;
+
+	while (nb) {
+		count += nb->notifier_call(nb,
+			(unsigned long) priority,
+			(void *)(unsigned long) gfp_mask);
+		nb = nb->next;
+	}
+
+	return count;
+}
+
+/*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
  * without holding the kernel lock etc.
@@ -475,6 +501,20 @@
 				ret = 1;
 				if (!--count)
 					goto done;
+			}
+		}
+
+		/*
+		 * Call everybody who registered a mem pressure notifier.
+		 *
+		 * If freemem_notifier_list will usually be non-NULL
+		 * during normal system operation, remove the non-NULL test.
+		 */
+		if (freemem_notifier_list != NULL) {
+			count -= shrink_misc_memory(priority, gfp_mask);
+			if (count <= 0) {
+				ret = 1;
+				goto done;
 			}
 		}
 
diff -ur vanilla/linux-2.4.0-test1-ac10/include/linux/mm.h linux_2_3/include/linux/mm.h
--- vanilla/linux-2.4.0-test1-ac10/include/linux/mm.h	Tue Jun  6 14:44:30 2000
+++ linux_2_3/include/linux/mm.h	Wed Jun  7 06:14:31 2000
@@ -10,6 +10,7 @@
 #include <linux/string.h>
 #include <linux/list.h>
 #include <linux/mmzone.h>
+#include <linux/notifier.h>
 
 extern unsigned long max_mapnr;
 extern unsigned long num_physpages;
@@ -415,6 +416,9 @@
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
 extern int ptrace_readdata(struct task_struct *tsk, unsigned long src, char *dst, int len);
 extern int ptrace_writedata(struct task_struct *tsk, char * src, unsigned long dst, int len);
+
+extern int register_freemem_notifier(struct notifier_block *);
+extern int unregister_freemem_notifier(struct notifier_block *);
 
 extern int pgt_cache_water[2];
 extern int check_pgt_cache(void);
diff -ur vanilla/linux-2.4.0-test1-ac10/include/linux/notifier.h linux_2_3/include/linux/notifier.h
--- vanilla/linux-2.4.0-test1-ac10/include/linux/notifier.h	Thu Mar 30 10:03:49 2000
+++ linux_2_3/include/linux/notifier.h	Wed Jun  7 06:14:32 2000
@@ -21,62 +21,15 @@
 
 #ifdef __KERNEL__
 
+extern int notifier_chain_register(struct notifier_block **list, struct notifier_block *n);
+extern int notifier_chain_unregister(struct notifier_block **nl, struct notifier_block *n);
+extern int notifier_call_chain(struct notifier_block **n, unsigned long val, void *v);
+
 #define NOTIFY_DONE		0x0000		/* Don't care */
 #define NOTIFY_OK		0x0001		/* Suits me */
 #define NOTIFY_STOP_MASK	0x8000		/* Don't call further */
 #define NOTIFY_BAD		(NOTIFY_STOP_MASK|0x0002)	/* Bad/Veto action	*/
 
-extern __inline__ int notifier_chain_register(struct notifier_block **list, struct notifier_block *n)
-{
-	while(*list)
-	{
-		if(n->priority > (*list)->priority)
-			break;
-		list= &((*list)->next);
-	}
-	n->next = *list;
-	*list=n;
-	return 0;
-}
-
-/*
- *	Warning to any non GPL module writers out there.. these functions are
- *	GPL'd
- */
- 
-extern __inline__ int notifier_chain_unregister(struct notifier_block **nl, struct notifier_block *n)
-{
-	while((*nl)!=NULL)
-	{
-		if((*nl)==n)
-		{
-			*nl=n->next;
-			return 0;
-		}
-		nl=&((*nl)->next);
-	}
-	return -ENOENT;
-}
-
-/*
- *	This is one of these things that is generally shorter inline
- */
- 
-extern __inline__ int notifier_call_chain(struct notifier_block **n, unsigned long val, void *v)
-{
-	int ret=NOTIFY_DONE;
-	struct notifier_block *nb = *n;
-	while(nb)
-	{
-		ret=nb->notifier_call(nb,val,v);
-		if(ret&NOTIFY_STOP_MASK)
-			return ret;
-		nb=nb->next;
-	}
-	return ret;
-}
-
-
 /*
  *	Declared notifiers so far. I can imagine quite a few more chains
  *	over time (eg laptop power reset chains, reboot chain (to clean 
@@ -105,11 +58,5 @@
 #define SYS_HALT	0x0002	/* Notify of system halt */
 #define SYS_POWER_OFF	0x0003	/* Notify of system power off */
 
-/*
- *	Publically visible notifier objects
- */
- 
-extern struct notifier_block *boot_notifier_list;
- 
-#endif
-#endif
+#endif /* __KERNEL__ */
+#endif /* _LINUX_NOTIFIER_H */
diff -ur vanilla/linux-2.4.0-test1-ac10/kernel/Makefile linux_2_3/kernel/Makefile
--- vanilla/linux-2.4.0-test1-ac10/kernel/Makefile	Wed Mar 22 12:39:11 2000
+++ linux_2_3/kernel/Makefile	Wed Jun  7 06:14:32 2000
@@ -8,11 +8,11 @@
 # Note 2! The CFLAGS definitions are now in the main makefile...
 
 O_TARGET := kernel.o
-O_OBJS    = sched.o dma.o fork.o exec_domain.o panic.o printk.o sys.o \
+O_OBJS    = sched.o dma.o fork.o exec_domain.o panic.o printk.o \
 	    module.o exit.o itimer.o info.o time.o softirq.o resource.o \
 	    sysctl.o acct.o capability.o ptrace.o timer.o
 
-OX_OBJS  += signal.o
+OX_OBJS  += signal.o sys.o
 
 ifeq ($(CONFIG_UID16),y)
 O_OBJS += uid16.o
diff -ur vanilla/linux-2.4.0-test1-ac10/kernel/ksyms.c linux_2_3/kernel/ksyms.c
--- vanilla/linux-2.4.0-test1-ac10/kernel/ksyms.c	Tue Jun  6 14:44:31 2000
+++ linux_2_3/kernel/ksyms.c	Wed Jun  7 06:14:32 2000
@@ -129,7 +129,6 @@
 
 /* filesystem internal functions */
 EXPORT_SYMBOL(def_blk_fops);
-EXPORT_SYMBOL(in_group_p);
 EXPORT_SYMBOL(update_atime);
 EXPORT_SYMBOL(get_super);
 EXPORT_SYMBOL(get_empty_super);
@@ -446,8 +445,6 @@
 EXPORT_SYMBOL(machine_restart);
 EXPORT_SYMBOL(machine_halt);
 EXPORT_SYMBOL(machine_power_off);
-EXPORT_SYMBOL(register_reboot_notifier);
-EXPORT_SYMBOL(unregister_reboot_notifier);
 EXPORT_SYMBOL(_ctype);
 EXPORT_SYMBOL(secure_tcp_sequence_number);
 EXPORT_SYMBOL(get_random_bytes);
diff -ur vanilla/linux-2.4.0-test1-ac10/kernel/sys.c linux_2_3/kernel/sys.c
--- vanilla/linux-2.4.0-test1-ac10/kernel/sys.c	Tue Jun  6 14:44:31 2000
+++ linux_2_3/kernel/sys.c	Wed Jun  7 06:14:32 2000
@@ -4,6 +4,7 @@
  *  Copyright (C) 1991, 1992  Linus Torvalds
  */
 
+#include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/utsname.h>
 #include <linux/mman.h>
@@ -47,17 +48,160 @@
  */
 
 static struct notifier_block *reboot_notifier_list = NULL;
+struct notifier_block *freemem_notifier_list = NULL;
+static spinlock_t notifier_lock = SPIN_LOCK_UNLOCKED;
 
+/**
+ *	notifier_chain_register	- Add notifier to a notifier chain
+ *	@list: Pointer to root list pointer
+ *	@n: New entry in notifier chain
+ *
+ *	Adds a notifier to a notifier chain.
+ *
+ *	Currently always returns zero.
+ */
+ 
+int notifier_chain_register(struct notifier_block **list, struct notifier_block *n)
+{
+	spin_lock(&notifier_lock);
+	while(*list)
+	{
+		if(n->priority > (*list)->priority)
+			break;
+		list= &((*list)->next);
+	}
+	n->next = *list;
+	*list=n;
+	spin_unlock(&notifier_lock);
+	return 0;
+}
+
+/**
+ *	notifier_chain_unregister - Remove notifier from a notifier chain
+ *	@nl: Pointer to root list pointer
+ *	@n: New entry in notifier chain
+ *
+ *	Removes a notifier from a notifier chain.
+ *
+ *	Returns zero on success, or %-ENOENT on failure.
+ */
+ 
+int notifier_chain_unregister(struct notifier_block **nl, struct notifier_block *n)
+{
+	spin_lock(&notifier_lock);
+	while((*nl)!=NULL)
+	{
+		if((*nl)==n)
+		{
+			*nl=n->next;
+			spin_unlock(&notifier_lock);
+			return 0;
+		}
+		nl=&((*nl)->next);
+	}
+	spin_unlock(&notifier_lock);
+	return -ENOENT;
+}
+
+/**
+ *	notifier_call_chain - Call functions in a notifier chain
+ *	@n: Pointer to root pointer of notifier chain
+ *	@val: Value passed unmodified to notifier function
+ *	@v: Pointer passed unmodified to notifier function
+ *
+ *	Calls each function in a notifier chain in turn.
+ *
+ *	If the return value of the notifier can be and'd
+ *	with %NOTIFY_STOP_MASK, then notifier_call_chain
+ *	will return immediately, with the return value of
+ *	the notifier function which halted execution.
+ *	Otherwise, the return value is the return value
+ *	of the last notifier function called.
+ */
+ 
+int notifier_call_chain(struct notifier_block **n, unsigned long val, void *v)
+{
+	int ret=NOTIFY_DONE;
+	struct notifier_block *nb = *n;
+
+	spin_lock(&notifier_lock);
+	while(nb)
+	{
+		ret=nb->notifier_call(nb,val,v);
+		if(ret&NOTIFY_STOP_MASK)
+		{
+			spin_unlock(&notifier_lock);
+			return ret;
+		}
+		nb=nb->next;
+	}
+	spin_unlock(&notifier_lock);
+	return ret;
+}
+
+/**
+ *	register_reboot_notifier - Register function to be called at reboot time
+ *	@nb: Info about notifier function to be called
+ *
+ *	Registers a function with the list of functions
+ *	to be called at reboot time.
+ *
+ *	Currently always returns zero, as notifier_chain_register
+ *	always returns zero.
+ */
+ 
 int register_reboot_notifier(struct notifier_block * nb)
 {
 	return notifier_chain_register(&reboot_notifier_list, nb);
 }
 
+/**
+ *	unregister_reboot_notifier - Unregister previously registered reboot notifier
+ *	@nb: Hook to be unregistered
+ *
+ *	Unregisters a previously registered reboot
+ *	notifier function.
+ *
+ *	Returns zero on success, or %-ENOENT on failure.
+ */
+ 
 int unregister_reboot_notifier(struct notifier_block * nb)
 {
 	return notifier_chain_unregister(&reboot_notifier_list, nb);
 }
 
+/**
+ *	register_freemem_notifier - Register function to be called at memory pressure time
+ *	@nb: Info about notifier function to be called
+ *
+ *	Registers a function with the list of functions
+ *	to be called whenever the system attempts to
+ *	free some pages, prior to swapping out pages.
+ *
+ *	Currently always returns zero, as notifier_chain_register
+ *	always returns zero.
+ */
+ 
+int register_freemem_notifier(struct notifier_block * nb)
+{
+	return notifier_chain_register(&freemem_notifier_list, nb);
+}
+
+/**
+ *	unregister_freemem_notifier - Unregister previously registered mem pressure notifier
+ *	@nb: Hook to be unregistered
+ *
+ *	Unregisters a previously registered mem pressure
+ *	notifier function.
+ *
+ *	Returns zero on success, or %-ENOENT on failure.
+ */
+ 
+int unregister_freemem_notifier(struct notifier_block * nb)
+{
+	return notifier_chain_unregister(&freemem_notifier_list, nb);
+}
+
 asmlinkage long sys_ni_syscall(void)
 {
 	return -ENOSYS;
@@ -1102,3 +1246,12 @@
 	return error;
 }
 
+EXPORT_SYMBOL(notifier_chain_register);
+EXPORT_SYMBOL(notifier_chain_unregister);
+EXPORT_SYMBOL(notifier_call_chain);
+EXPORT_SYMBOL(register_reboot_notifier);
+EXPORT_SYMBOL(unregister_reboot_notifier);
+EXPORT_SYMBOL(register_freemem_notifier);
+EXPORT_SYMBOL(unregister_freemem_notifier);
+EXPORT_SYMBOL(in_group_p);
+EXPORT_SYMBOL(in_egroup_p);

--------------5F5A7D832FC6C8D2BEB8F280--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
