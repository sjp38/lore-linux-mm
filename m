Message-ID: <393DFB23.64FD2E3D@mandrakesoft.com>
Date: Wed, 07 Jun 2000 03:34:59 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: PATCH 2.4.0.1.ac10: a KISS memory pressure callback
Content-Type: multipart/mixed;
 boundary="------------E7214397E2575411AFA345EC"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------E7214397E2575411AFA345EC
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Cheesy maybe, effective probably.
-- 
Jeff Garzik              | Liberty is always dangerous, but
Building 1024            | it is the safest thing we have.
MandrakeSoft, Inc.       |      -- Harry Emerson Fosdick
--------------E7214397E2575411AFA345EC
Content-Type: text/plain; charset=us-ascii;
 name="freemem.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="freemem.patch"

Index: mm/vmscan.c
===================================================================
RCS file: /g/cvslan/linux_2_3/mm/vmscan.c,v
retrieving revision 1.1.1.40
diff -u -r1.1.1.40 vmscan.c
--- mm/vmscan.c	2000/06/05 03:14:23	1.1.1.40
+++ mm/vmscan.c	2000/06/07 07:32:47
@@ -428,6 +428,31 @@
 }
 
 /*
+ * The freemem notifier list holds a list of functions
+ * that are to be called when trying to free pages.
+ *
+ * Call them...  We don't use notifier_call_chain
+ * because the return code from a freemem notifier
+ * is treated as a shrink_*_memory-style return value.
+ */
+extern struct notifier_block *freemem_notifier_list;
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
+
+/*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
  * without holding the kernel lock etc.
@@ -476,6 +501,13 @@
 				if (!--count)
 					goto done;
 			}
+		}
+
+		/* call everybody who registered a mem pressure notifier */
+		count -= shrink_misc_memory(priority, gfp_mask);
+		if (count <= 0) {
+			ret = 1;
+			goto done;
 		}
 
 		/*
Index: kernel/ksyms.c
===================================================================
RCS file: /g/cvslan/linux_2_3/kernel/ksyms.c,v
retrieving revision 1.1.1.62
diff -u -r1.1.1.62 ksyms.c
--- kernel/ksyms.c	2000/05/29 23:48:48	1.1.1.62
+++ kernel/ksyms.c	2000/06/07 07:32:53
@@ -448,6 +448,8 @@
 EXPORT_SYMBOL(machine_power_off);
 EXPORT_SYMBOL(register_reboot_notifier);
 EXPORT_SYMBOL(unregister_reboot_notifier);
+EXPORT_SYMBOL(register_freemem_notifier);
+EXPORT_SYMBOL(unregister_freemem_notifier);
 EXPORT_SYMBOL(_ctype);
 EXPORT_SYMBOL(secure_tcp_sequence_number);
 EXPORT_SYMBOL(get_random_bytes);
Index: kernel/sys.c
===================================================================
RCS file: /g/cvslan/linux_2_3/kernel/sys.c,v
retrieving revision 1.1.1.19
diff -u -r1.1.1.19 sys.c
--- kernel/sys.c	2000/05/31 13:07:05	1.1.1.19
+++ kernel/sys.c	2000/06/07 07:32:53
@@ -47,15 +47,51 @@
  */
 
 static struct notifier_block *reboot_notifier_list = NULL;
+struct notifier_block *freemem_notifier_list = NULL;
+static spinlock_t notifier_lock = SPIN_LOCK_UNLOCKED;
 
 int register_reboot_notifier(struct notifier_block * nb)
 {
-	return notifier_chain_register(&reboot_notifier_list, nb);
+	int i;
+
+	spin_lock(&notifier_lock);
+	i = notifier_chain_register(&reboot_notifier_list, nb);
+	spin_unlock(&notifier_lock);
+
+	return i;
 }
 
 int unregister_reboot_notifier(struct notifier_block * nb)
+{
+	int i;
+
+	spin_lock(&notifier_lock);
+	i = notifier_chain_unregister(&reboot_notifier_list, nb);
+	spin_unlock(&notifier_lock);
+
+	return i;
+}
+
+int register_freemem_notifier(struct notifier_block * nb)
 {
-	return notifier_chain_unregister(&reboot_notifier_list, nb);
+	int i;
+
+	spin_lock(&notifier_lock);
+	i = notifier_chain_register(&freemem_notifier_list, nb);
+	spin_unlock(&notifier_lock);
+
+	return i;
+}
+
+int unregister_freemem_notifier(struct notifier_block * nb)
+{
+	int i;
+
+	spin_lock(&notifier_lock);
+	i = notifier_chain_unregister(&freemem_notifier_list, nb);
+	spin_unlock(&notifier_lock);
+
+	return i;
 }
 
 asmlinkage long sys_ni_syscall(void)

--------------E7214397E2575411AFA345EC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
