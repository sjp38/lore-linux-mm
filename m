Date: Tue, 10 Oct 2000 01:35:58 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010013558.A784@nightmaster.csn.tu-chemnitz.de>
References: <20001009210503.C19583@athlon.random> <Pine.LNX.4.21.0010091606420.1562-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010091606420.1562-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 09, 2000 at 04:07:32PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2000 at 04:07:32PM -0300, Rik van Riel wrote:
> > If the oom killer kills a thing like init by mistake
> That only happens in the "random" OOM killer 2.2 has ...

[OOM killer war]

Hi there,

before you argue endlessly about the "Right OOM Killer (TM)", I
did a small patch to allow replacing the OOM killer at runtime.

You can even use modules, if you are careful (see khttpd on how
to do this without refcouting).

So now you can stop arguing about the one and only OOM killer,
implement it, provide it as module and get back to the important
stuff ;-)

PS: Patch is against test9 with Rik's latest vmpatch applied.

Thanks for listening

Ingo Oeser

diff -Naur linux-2.4.0-test9-vmpatch/include/linux/swap.h linux-2.4.0-test9-vmpatch-ioe/include/linux/swap.h
--- linux-2.4.0-test9-vmpatch/include/linux/swap.h	Sun Oct  8 00:49:17 2000
+++ linux-2.4.0-test9-vmpatch-ioe/include/linux/swap.h	Tue Oct 10 00:50:17 2000
@@ -129,6 +129,9 @@
 /* linux/mm/oom_kill.c */
 extern int out_of_memory(void);
 extern void oom_kill(void);
+void install_oom_killer(void (*new_oom_kill)(void));
+void reset_default_oom_killer(void);
+
 
 /*
  * Make these inline later once they are working properly.
diff -Naur linux-2.4.0-test9-vmpatch/mm/Makefile linux-2.4.0-test9-vmpatch-ioe/mm/Makefile
--- linux-2.4.0-test9-vmpatch/mm/Makefile	Sun Oct  8 00:49:17 2000
+++ linux-2.4.0-test9-vmpatch-ioe/mm/Makefile	Tue Oct 10 00:10:07 2000
@@ -10,7 +10,8 @@
 O_TARGET := mm.o
 O_OBJS	 := memory.o mmap.o filemap.o mprotect.o mlock.o mremap.o \
 	    vmalloc.o slab.o bootmem.o swap.o vmscan.o page_io.o \
-	    page_alloc.o swap_state.o swapfile.o numa.o oom_kill.o
+	    page_alloc.o swap_state.o swapfile.o numa.o
+OX_OBJS  := oom_kill.o
 
 ifeq ($(CONFIG_HIGHMEM),y)
 O_OBJS += highmem.o
diff -Naur linux-2.4.0-test9-vmpatch/mm/oom_kill.c linux-2.4.0-test9-vmpatch-ioe/mm/oom_kill.c
--- linux-2.4.0-test9-vmpatch/mm/oom_kill.c	Sun Oct  8 00:49:17 2000
+++ linux-2.4.0-test9-vmpatch-ioe/mm/oom_kill.c	Tue Oct 10 00:35:32 2000
@@ -13,6 +13,8 @@
  *  machine) this file will double as a 'coding guide' and a signpost
  *  for newbie kernel hackers. It features several pointers to major
  *  kernel subsystems and hints as to where to find out what things do.
+ *
+ *  Added oom_killer API for special needs - Ingo Oeser
  */
 
 #include <linux/mm.h>
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
@@ -207,4 +211,26 @@
 
 	/* Else... */
 	return 1;
+}
+
+/* Protects oom_killer against resetting during its execution */
+static rwlock_t oom_kill_lock;
+
+static void (*oom_killer)(void)=oom_kill_rik;
+
+void oom_kill(void) {
+	read_lock(&oom_kill_lock);
+	oom_killer();
+	read_unlock(&oom_kill_lock);
+}
+
+void install_oom_killer(void (*new_oom_kill)(void)) {
+	if (!new_oom_kill) return;
+	write_lock(&oom_kill_lock);
+	oom_killer=new_oom_kill;
+	write_unlock(&oom_kill_lock);
+}
+
+void reset_default_oom_killer(void) {
+	install_oom_killer(&oom_kill_rik);
 }

-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
