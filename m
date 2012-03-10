Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id A7A4D6B00E8
	for <linux-mm@kvack.org>; Sat, 10 Mar 2012 12:48:47 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Sat, 10 Mar 2012 17:46:23 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2AHgxpo3121278
	for <linux-mm@kvack.org>; Sun, 11 Mar 2012 04:42:59 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2AHmg2Q009037
	for <linux-mm@kvack.org>; Sun, 11 Mar 2012 04:48:43 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Sat, 10 Mar 2012 23:16:00 +0530
Message-Id: <20120310174600.19949.43260.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120310174501.19949.50137.sendpatchset@srdronam.in.ibm.com>
References: <20120310174501.19949.50137.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH 5/7] x86/trivial: fix 'old_rsp' undefined build failure when including asm/compat.h
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>

From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Including asm/compat.h in arch/x86/kernel/signal.c and compiling on a i386
machine results in old_rsp undefined build errors.

old_rsp is defined under CONFIG_X86_64. Hence add a i386 specific
arch_compat_alloc_user_space that doesnt depend on old_rsp. Will be further
cleaned up when is_ia32_compat_task is introduced.

This is pure cleanup, no functional change intended.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/x86/include/asm/compat.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/compat.h b/arch/x86/include/asm/compat.h
index 355edc0..ba9e9dc 100644
--- a/arch/x86/include/asm/compat.h
+++ b/arch/x86/include/asm/compat.h
@@ -221,6 +221,7 @@ static inline compat_uptr_t ptr_to_compat(void __user *uptr)
 	return (u32)(unsigned long)uptr;
 }
 
+#ifdef CONFIG_x86_64
 static inline void __user *arch_compat_alloc_user_space(long len)
 {
 	compat_uptr_t sp;
@@ -234,6 +235,15 @@ static inline void __user *arch_compat_alloc_user_space(long len)
 
 	return (void __user *)round_down(sp - len, 16);
 }
+#else
+
+static inline void __user *arch_compat_alloc_user_space(long len)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+		return (void __user *)regs->sp - len;
+}
+
+#endif
 
 static inline bool is_ia32_task(void)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
