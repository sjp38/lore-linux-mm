Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id CB1B16B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 10:06:27 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 13 Mar 2012 19:36:23 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2DE67lI4391096
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 19:36:08 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2DJZqZk014901
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 01:05:54 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 13 Mar 2012 19:33:03 +0530
Message-Id: <20120313140303.17134.1401.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH 1/2] x86: Move is_ia32_task to asm/thread_info.h from asm/compat.h
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>

From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

is_ia32_task is useful even in !CONFIG_COMPAT cases. Hence move it
to a more generic file asm/thread_info.h

Also now is_ia32_task returns true if CONFIG_X86_32 is defined.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/x86/include/asm/compat.h      |    9 ---------
 arch/x86/include/asm/thread_info.h |   12 ++++++++++++
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/compat.h b/arch/x86/include/asm/compat.h
index 355edc0..d680579 100644
--- a/arch/x86/include/asm/compat.h
+++ b/arch/x86/include/asm/compat.h
@@ -235,15 +235,6 @@ static inline void __user *arch_compat_alloc_user_space(long len)
 	return (void __user *)round_down(sp - len, 16);
 }
 
-static inline bool is_ia32_task(void)
-{
-#ifdef CONFIG_IA32_EMULATION
-	if (current_thread_info()->status & TS_COMPAT)
-		return true;
-#endif
-	return false;
-}
-
 static inline bool is_x32_task(void)
 {
 #ifdef CONFIG_X86_X32_ABI
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index af1db7e..130fd4e 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -266,6 +266,18 @@ static inline void set_restore_sigmask(void)
 	ti->status |= TS_RESTORE_SIGMASK;
 	set_bit(TIF_SIGPENDING, (unsigned long *)&ti->flags);
 }
+
+static inline bool is_ia32_task(void)
+{
+#ifdef CONFIG_X86_32
+	return true;
+#endif
+#if defined CONFIG_X86_64 && defined CONFIG_IA32_EMULATION
+	if (current_thread_info()->status & TS_COMPAT)
+		return true;
+#endif
+	return false;
+}
 #endif	/* !__ASSEMBLY__ */
 
 #ifndef __ASSEMBLY__


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
