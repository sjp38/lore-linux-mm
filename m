Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2836B0096
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 19:17:30 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id oB30HQgl017076
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 16:17:26 -0800
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by kpbe13.cbf.corp.google.com with ESMTP id oB30HPSX021152
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 16:17:25 -0800
Received: by pxi7 with SMTP id 7so2289948pxi.22
        for <linux-mm@kvack.org>; Thu, 02 Dec 2010 16:17:25 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 6/6] x86 rwsem: more precise rwsem_is_contended() implementation
Date: Thu,  2 Dec 2010 16:16:52 -0800
Message-Id: <1291335412-16231-7-git-send-email-walken@google.com>
In-Reply-To: <1291335412-16231-1-git-send-email-walken@google.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

We would like rwsem_is_contended() to return true only once a contending
writer has had a chance to insert itself onto the rwsem wait queue.
To that end, we need to differenciate between active and queued writers.

A new property is introduced: RWSEM_ACTIVE_WRITE_BIAS is set to be
'more negative' than RWSEM_WAITING_BIAS. RWSEM_WAITING_MASK designates
a bit in the rwsem count that will be set only when RWSEM_WAITING_BIAS
is in effect.

The basic properties that have been true so far also still hold:
- RWSEM_ACTIVE_READ_BIAS  & RWSEM_ACTIVE_MASK == 1
- RWSEM_ACTIVE_WRITE_BIAS & RWSEM_ACTIVE_MASK == 1
- RWSEM_WAITING_BIAS      & RWSEM_ACTIVE_MASK == 0
- RWSEM_ACTIVE_WRITE_BIAS < 0 and RWSEM_WAITING_BIAS < 0

In addition, the rwsem count will be < RWSEM_WAITING_BIAS only if there
are any active writers (though we don't make use of this property so far).

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/include/asm/rwsem.h |   32 +++++++++++++++++++-------------
 arch/x86/lib/rwsem_64.S      |    4 ++--
 arch/x86/lib/semaphore_32.S  |    4 ++--
 3 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
index a35521e..1ce7759 100644
--- a/arch/x86/include/asm/rwsem.h
+++ b/arch/x86/include/asm/rwsem.h
@@ -16,11 +16,10 @@
  * if there are writers (and maybe) readers waiting (in which case it goes to
  * sleep).
  *
- * The value of WAITING_BIAS supports up to 32766 waiting processes. This can
- * be extended to 65534 by manually checking the whole MSW rather than relying
- * on the S flag.
+ * The WRITE_BIAS value supports up to 32767 processes simultaneously
+ * trying to acquire a write lock.
  *
- * The value of ACTIVE_BIAS supports up to 65535 active processes.
+ * The value of ACTIVE_MASK supports up to 32767 active processes.
  *
  * This should be totally fair - if anything is waiting, a process that wants a
  * lock will go to the back of the queue. When the currently active lock is
@@ -62,17 +61,23 @@ extern asmregparm struct rw_semaphore *
  * for 64 bits.
  */
 
+
 #ifdef CONFIG_X86_64
-# define RWSEM_ACTIVE_MASK		0xffffffffL
+# define RWSEM_UNLOCKED_VALUE		0x0000000000000000L
+# define RWSEM_ACTIVE_MASK		0x000000007fffffffL
+# define RWSEM_ACTIVE_READ_BIAS		0x0000000000000001L
+# define RWSEM_ACTIVE_WRITE_BIAS	0xffffffff00000001L
+# define RWSEM_WAITING_BIAS		0xffffffff80000000L
+# define RWSEM_WAITING_MASK		0x0000000080000000L
 #else
-# define RWSEM_ACTIVE_MASK		0x0000ffffL
+# define RWSEM_UNLOCKED_VALUE		0x00000000L
+# define RWSEM_ACTIVE_MASK		0x00007fffL
+# define RWSEM_ACTIVE_READ_BIAS		0x00000001L
+# define RWSEM_ACTIVE_WRITE_BIAS	0xffff0001L
+# define RWSEM_WAITING_BIAS		0xffff8000L
+# define RWSEM_WAITING_MASK		0x00008000L
 #endif
 
-#define RWSEM_UNLOCKED_VALUE		0x00000000L
-#define RWSEM_ACTIVE_BIAS		0x00000001L
-#define RWSEM_WAITING_BIAS		(-RWSEM_ACTIVE_MASK-1)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
 
 typedef signed long rwsem_count_t;
 
@@ -240,7 +245,8 @@ static inline void __downgrade_write(struct rw_semaphore *sem)
 		     "1:\n\t"
 		     "# ending __downgrade_write\n"
 		     : "+m" (sem->count)
-		     : "a" (sem), "er" (-RWSEM_WAITING_BIAS)
+		     : "a" (sem),
+		       "er" (RWSEM_ACTIVE_READ_BIAS - RWSEM_ACTIVE_WRITE_BIAS)
 		     : "memory", "cc");
 }
 
@@ -277,7 +283,7 @@ static inline int rwsem_is_locked(struct rw_semaphore *sem)
 
 static inline int rwsem_is_contended(struct rw_semaphore *sem)
 {
-	return (sem->count < 0);
+	return (sem->count & RWSEM_WAITING_MASK) != 0;
 }
 
 #endif /* __KERNEL__ */
diff --git a/arch/x86/lib/rwsem_64.S b/arch/x86/lib/rwsem_64.S
index 41fcf00..35b797e 100644
--- a/arch/x86/lib/rwsem_64.S
+++ b/arch/x86/lib/rwsem_64.S
@@ -60,8 +60,8 @@ ENTRY(call_rwsem_down_write_failed)
 	ENDPROC(call_rwsem_down_write_failed)
 
 ENTRY(call_rwsem_wake)
-	decl %edx	/* do nothing if still outstanding active readers */
-	jnz 1f
+	cmpl $0x80000001, %edx
+	jne 1f	/* do nothing unless there are waiters and no active threads */
 	save_common_regs
 	movq %rax,%rdi
 	call rwsem_wake
diff --git a/arch/x86/lib/semaphore_32.S b/arch/x86/lib/semaphore_32.S
index 648fe47..256fa7d 100644
--- a/arch/x86/lib/semaphore_32.S
+++ b/arch/x86/lib/semaphore_32.S
@@ -103,8 +103,8 @@ ENTRY(call_rwsem_down_write_failed)
 
 ENTRY(call_rwsem_wake)
 	CFI_STARTPROC
-	decw %dx    /* do nothing if still outstanding active readers */
-	jnz 1f
+	cmpw $0x8001, %dx
+	jne 1f	/* do nothing unless there are waiters and no active threads */
 	push %ecx
 	CFI_ADJUST_CFA_OFFSET 4
 	CFI_REL_OFFSET ecx,0
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
