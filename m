Date: Tue, 10 Oct 2000 17:07:08 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: [PATCH] OOM killer API (was: [PATCH] VM fix for 2.4.0-test9 & OOM handler)
Message-ID: <20001010170708.C784@nightmaster.csn.tu-chemnitz.de>
References: <20001009210503.C19583@athlon.random> <Pine.LNX.4.21.0010091606420.1562-100000@duckman.distro.conectiva> <20001010013558.A784@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001010013558.A784@nightmaster.csn.tu-chemnitz.de>; from ingo.oeser@informatik.tu-chemnitz.de on Tue, Oct 10, 2000 at 01:35:58AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

[OOM killer war]

Hi there,

before you argue endlessly about the "Right OOM Killer (TM)", I
did a small patch to allow replacing the OOM killer at runtime.

You can even use modules, if you are careful (see khttpd on how
to do this without refcouting).

So now you can stop arguing about the one and only OOM killer,
implement it, provide it as module and get back to the important
stuff ;-)

PS: Patch is against test10-pre1.

Thanks for listening

Ingo Oeser

--- linux-2.4.0-test10-pre1/mm/oom_kill.c	Tue Oct 10 16:31:08 2000
+++ linux-2.4.0-test10-pre1-ioe/mm/oom_kill.c	Tue Oct 10 16:59:27 2000
@@ -13,6 +13,8 @@
  *  machine) this file will double as a 'coding guide' and a signpost
  *  for newbie kernel hackers. It features several pointers to major
  *  kernel subsystems and hints as to where to find out what things do.
+ *
+ *  Added oom_killer API for special needs - Ingo Oeser
  */
 
 #include <linux/mm.h>
@@ -136,7 +138,7 @@
 }
 
 /**
- * oom_kill - kill the "best" process when we run out of memory
+ * oom_kill_rik - kill the "best" process when we run out of memory
  *
  * If we run out of memory, we have the choice between either
  * killing a random task (bad), letting the system crash (worse)
@@ -147,7 +149,9 @@
  * CAP_SYS_RAW_IO set, send SIGTERM instead (but it's unlikely that
  * we select a process with CAP_SYS_RAW_IO set).
  */
-void oom_kill(void)
+
+
+static void oom_kill_rik(void)
 {
 
 	struct task_struct *p = select_bad_process();
@@ -207,4 +211,63 @@
 
 	/* Else... */
 	return 1;
+}
+
+/* Protects oom_killer against resetting during its execution */
+static rwlock_t oom_kill_lock = RW_LOCK_UNLOCKED;
+
+static oom_killer_t oom_killer = oom_kill_rik;
+
+/** 
+ * oom_kill - the oom_kill wrapper for installable OOM killers
+ *
+ * Wraper around the OOM killers, that can be installed via
+ * install_oom_killer and reset_default_oom_killer.
+ *
+ * This gets called from kswapd() in linux/mm/vmscan.c when we 
+ * really run out of memory.
+ */
+void oom_kill(void) {
+	read_lock(&oom_kill_lock);
+	oom_killer();
+	read_unlock(&oom_kill_lock);
+}
+
+/**
+ * install_oom_killer - install alternate OOM killer
+ * @new_oom_kill: the alternate OOM killer provided by the caller
+ *
+ * Since the default OOM killer (oom_kill_rik) is not suitable 
+ * for everyone, we provide an interface to install custom OOM killers.
+ * 
+ * You can take the most appropriate action for your application if the
+ * kernel goes OOM.
+ *
+ * Providing an NULL argument just returns the current OOM killer.
+ *
+ * Returns: The OOM killer, which has been installed so far.
+ * 
+ * NOTE: We don't do refcounting on OOM killers, so be careful with 
+ * 	modules
+ */
+oom_killer_t install_oom_killer(oom_killer_t new_oom_kill) {
+	oom_killer_t tmp;
+	write_lock(&oom_kill_lock);
+	tmp=oom_killer;
+	if (new_oom_kill) 
+		oom_killer=new_oom_kill;
+	write_unlock(&oom_kill_lock);
+	return tmp;
+}
+
+/**
+ * reset_default_oom_killer - reset back to default OOM killer
+ *
+ * If you are going to unload the module which provided 
+ * your OOM killer, you can install the default one by this.
+ *
+ * Returns: The OOM killer, which has been installed so far.
+ */
+oom_killer_t reset_default_oom_killer(void) {
+	return install_oom_killer(&oom_kill_rik);
 }
--- linux-2.4.0-test10-pre1/include/linux/swap.h	Tue Oct 10 16:31:08 2000
+++ linux-2.4.0-test10-pre1-ioe/include/linux/swap.h	Tue Oct 10 16:44:22 2000
@@ -127,8 +127,14 @@
 #define read_swap_cache(entry) read_swap_cache_async(entry, 1);
 
 /* linux/mm/oom_kill.c */
+typedef void (*oom_killer_t)(void);
+
 extern int out_of_memory(void);
 extern void oom_kill(void);
+
+oom_killer_t install_oom_killer(oom_killer_t new_oom_kill);
+oom_killer_t reset_default_oom_killer(void);
+
 
 /*
  * Make these inline later once they are working properly.
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
