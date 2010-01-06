Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1746E6B010E
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 20:37:33 -0500 (EST)
Date: Tue, 5 Jan 2010 17:37:08 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LFD.2.00.1001051718100.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com> <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
 <20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Wed, 6 Jan 2010, KAMEZAWA Hiroyuki wrote:
>
> I think this is the 1st reason but haven't rewrote rwsem itself and tested,
> sorry.

Here's a totally untested patch! It may or may not work. It builds for me, 
but that may be some cosmic accident. I _think_ I got the callee-clobbered 
register set right, but somebody should check the comment in the new 
rwsem_64.S, and double-check that the code actually matches what I tried 
to do.

I had to change the inline asm to get the register sizes right too, so for 
all I know this screws up x86-32 too.

In other words: UNTESTED! It may molest your pets and drink all your beer. 
You have been warned.

(Is a 16-bit rwsem count even enough for x86-64? Possibly not. That's a 
separate issue entirely, though).

		Linus

---
 arch/x86/Kconfig.cpu         |    2 +-
 arch/x86/include/asm/rwsem.h |   18 +++++-----
 arch/x86/lib/Makefile        |    1 +
 arch/x86/lib/rwsem_64.S      |   81 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 92 insertions(+), 10 deletions(-)

diff --git a/arch/x86/Kconfig.cpu b/arch/x86/Kconfig.cpu
index f20ddf8..a198293 100644
--- a/arch/x86/Kconfig.cpu
+++ b/arch/x86/Kconfig.cpu
@@ -319,7 +319,7 @@ config X86_L1_CACHE_SHIFT
 
 config X86_XADD
 	def_bool y
-	depends on X86_32 && !M386
+	depends on X86_64 || !M386
 
 config X86_PPRO_FENCE
 	bool "PentiumPro memory ordering errata workaround"
diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
index ca7517d..625baca 100644
--- a/arch/x86/include/asm/rwsem.h
+++ b/arch/x86/include/asm/rwsem.h
@@ -65,7 +65,7 @@ extern asmregparm struct rw_semaphore *
 #define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
 
 struct rw_semaphore {
-	signed long		count;
+	__s32			count;
 	spinlock_t		wait_lock;
 	struct list_head	wait_list;
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
@@ -105,7 +105,7 @@ do {								\
 static inline void __down_read(struct rw_semaphore *sem)
 {
 	asm volatile("# beginning down_read\n\t"
-		     LOCK_PREFIX "  incl      (%%eax)\n\t"
+		     LOCK_PREFIX "  incl      (%1)\n\t"
 		     /* adds 0x00000001, returns the old value */
 		     "  jns        1f\n"
 		     "  call call_rwsem_down_read_failed\n"
@@ -147,7 +147,7 @@ static inline void __down_write_nested(struct rw_semaphore *sem, int subclass)
 
 	tmp = RWSEM_ACTIVE_WRITE_BIAS;
 	asm volatile("# beginning down_write\n\t"
-		     LOCK_PREFIX "  xadd      %%edx,(%%eax)\n\t"
+		     LOCK_PREFIX "  xaddl     %%edx,(%2)\n\t"
 		     /* subtract 0x0000ffff, returns the old value */
 		     "  testl     %%edx,%%edx\n\t"
 		     /* was the count 0 before? */
@@ -170,9 +170,9 @@ static inline void __down_write(struct rw_semaphore *sem)
  */
 static inline int __down_write_trylock(struct rw_semaphore *sem)
 {
-	signed long ret = cmpxchg(&sem->count,
-				  RWSEM_UNLOCKED_VALUE,
-				  RWSEM_ACTIVE_WRITE_BIAS);
+	__s32 ret = cmpxchg(&sem->count,
+			    RWSEM_UNLOCKED_VALUE,
+			    RWSEM_ACTIVE_WRITE_BIAS);
 	if (ret == RWSEM_UNLOCKED_VALUE)
 		return 1;
 	return 0;
@@ -185,7 +185,7 @@ static inline void __up_read(struct rw_semaphore *sem)
 {
 	__s32 tmp = -RWSEM_ACTIVE_READ_BIAS;
 	asm volatile("# beginning __up_read\n\t"
-		     LOCK_PREFIX "  xadd      %%edx,(%%eax)\n\t"
+		     LOCK_PREFIX "  xaddl     %%edx,(%2)\n\t"
 		     /* subtracts 1, returns the old value */
 		     "  jns        1f\n\t"
 		     "  call call_rwsem_wake\n"
@@ -203,7 +203,7 @@ static inline void __up_write(struct rw_semaphore *sem)
 {
 	asm volatile("# beginning __up_write\n\t"
 		     "  movl      %2,%%edx\n\t"
-		     LOCK_PREFIX "  xaddl     %%edx,(%%eax)\n\t"
+		     LOCK_PREFIX "  xaddl     %%edx,(%1)\n\t"
 		     /* tries to transition
 			0xffff0001 -> 0x00000000 */
 		     "  jz       1f\n"
@@ -221,7 +221,7 @@ static inline void __up_write(struct rw_semaphore *sem)
 static inline void __downgrade_write(struct rw_semaphore *sem)
 {
 	asm volatile("# beginning __downgrade_write\n\t"
-		     LOCK_PREFIX "  addl      %2,(%%eax)\n\t"
+		     LOCK_PREFIX "  addl      %2,(%1)\n\t"
 		     /* transitions 0xZZZZ0001 -> 0xYYYY0001 */
 		     "  jns       1f\n\t"
 		     "  call call_rwsem_downgrade_wake\n"
diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
index cffd754..c802451 100644
--- a/arch/x86/lib/Makefile
+++ b/arch/x86/lib/Makefile
@@ -39,4 +39,5 @@ else
         lib-y += thunk_64.o clear_page_64.o copy_page_64.o
         lib-y += memmove_64.o memset_64.o
         lib-y += copy_user_64.o rwlock_64.o copy_user_nocache_64.o
+	lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem_64.o
 endif
diff --git a/arch/x86/lib/rwsem_64.S b/arch/x86/lib/rwsem_64.S
new file mode 100644
index 0000000..15acecf
--- /dev/null
+++ b/arch/x86/lib/rwsem_64.S
@@ -0,0 +1,81 @@
+/*
+ * x86-64 rwsem wrappers
+ *
+ * This interfaces the inline asm code to the slow-path
+ * C routines. We need to save the call-clobbered regs
+ * that the asm does not mark as clobbered, and move the
+ * argument from %rax to %rdi.
+ *
+ * NOTE! We don't need to save %rax, because the functions
+ * will always return the semaphore pointer in %rax (which
+ * is also the input argument to these helpers)
+ *
+ * The following can clobber %rdx because the asm clobbers it:
+ *   call_rwsem_down_write_failed
+ *   call_rwsem_wake
+ * but %rdi, %rsi, %rcx, %r8-r11 always need saving.
+ */
+
+#include <linux/linkage.h>
+#include <asm/rwlock.h>
+#include <asm/alternative-asm.h>
+#include <asm/frame.h>
+#include <asm/dwarf2.h>
+
+#define save_common_regs \
+	pushq %rdi; \
+	pushq %rsi; \
+	pushq %rcx; \
+	pushq %r8; \
+	pushq %r9; \
+	pushq %r10; \
+	pushq %r11
+
+#define restore_common_regs \
+	popq %r11; \
+	popq %r10; \
+	popq %r9; \
+	popq %r8; \
+	popq %rcx; \
+	popq %rsi; \
+	popq %rdi
+
+/* Fix up special calling conventions */
+ENTRY(call_rwsem_down_read_failed)
+	save_common_regs
+	pushq %rdx
+	movq %rax,%rdi
+	call rwsem_down_read_failed
+	popq %rdx
+	restore_common_regs
+	ret
+	ENDPROC(call_rwsem_down_read_failed)
+
+ENTRY(call_rwsem_down_write_failed)
+	save_common_regs
+	movq %rax,%rdi
+	call rwsem_down_write_failed
+	restore_common_regs
+	ret
+	ENDPROC(call_rwsem_down_write_failed)
+
+ENTRY(call_rwsem_wake)
+	decw %dx    /* do nothing if still outstanding active readers */
+	jnz 1f
+	save_common_regs
+	movq %rax,%rdi
+	call rwsem_wake
+	restore_common_regs
+1:	ret
+	ENDPROC(call_rwsem_wake)
+
+/* Fix up special calling conventions */
+ENTRY(call_rwsem_downgrade_wake)
+	save_common_regs
+	pushq %rdx
+	movq %rax,%rdi
+	call rwsem_downgrade_wake
+	popq %rdx
+	restore_common_regs
+	ret
+	ENDPROC(call_rwsem_downgrade_wake)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
