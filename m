Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id E2BC06B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 12:17:32 -0400 (EDT)
Date: Tue, 13 Mar 2012 09:16:55 -0700
From: tip-bot for Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Message-ID: <tip-ef334a20d84f52407a8a2afd02ddeaecbef0ad3d@git.kernel.org>
Reply-To: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com,
        andi@firstfloor.org, torvalds@linux-foundation.org,
        peterz@infradead.org, hch@infradead.org, ananth@in.ibm.com,
        masami.hiramatsu.pt@hitachi.com, acme@infradead.org,
        rostedt@goodmis.org, jkenisto@linux.vnet.ibm.com,
        srikar@linux.vnet.ibm.com, tglx@linutronix.de, oleg@redhat.com,
        linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <20120313140303.17134.1401.sendpatchset@srdronam.in.ibm.com>
References: <20120313140303.17134.1401.sendpatchset@srdronam.in.ibm.com>
Subject: [tip:perf/uprobes] x86: Move is_ia32_task to asm/thread_info.
 h from asm/compat.h
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mingo@redhat.com, torvalds@linux-foundation.org, peterz@infradead.org, rostedt@goodmis.org, jkenisto@linux.vnet.ibm.com, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, hpa@zytor.com, linux-kernel@vger.kernel.org, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com, mingo@elte.hu

Commit-ID:  ef334a20d84f52407a8a2afd02ddeaecbef0ad3d
Gitweb:     http://git.kernel.org/tip/ef334a20d84f52407a8a2afd02ddeaecbef0ad3d
Author:     Srikar Dronamraju <srikar@linux.vnet.ibm.com>
AuthorDate: Tue, 13 Mar 2012 19:33:03 +0530
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Tue, 13 Mar 2012 16:31:09 +0100

x86: Move is_ia32_task to asm/thread_info.h from asm/compat.h

is_ia32_task() is useful even in !CONFIG_COMPAT cases - utrace will
use it for example. Hence move it to a more generic file: asm/thread_info.h

Also now is_ia32_task() returns true if CONFIG_X86_32 is defined.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Acked-by: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Jim Keniston <jkenisto@linux.vnet.ibm.com>
Cc: Linux-mm <linux-mm@kvack.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Link: http://lkml.kernel.org/r/20120313140303.17134.1401.sendpatchset@srdronam.in.ibm.com
[ Performed minor cleanup ]
Signed-off-by: Ingo Molnar <mingo@elte.hu>
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
index af1db7e..ad6df8c 100644
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
+#ifdef CONFIG_IA32_EMULATION
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
