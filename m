Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18C946B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 07:43:01 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id g10so65208424wrg.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 04:43:01 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e27sor77643wra.15.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 04:42:59 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] x86, kasan: add KASAN checks to atomic operations
Date: Mon,  6 Mar 2017 13:42:54 +0100
Message-Id: <20170306124254.77615-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com
Cc: peterz@infradead.org, mingo@redhat.com, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

KASAN uses compiler instrumentation to intercept all memory accesses.
But it does not see memory accesses done in assembly code.
One notable user of assembly code is atomic operations. Frequently,
for example, an atomic reference decrement is the last access to an
object and a good candidate for a racy use-after-free.

Add manual KASAN checks to atomic operations.
Note: we need checks only before asm blocks and don't need them
in atomic functions composed of other atomic functions
(e.g. load-cmpxchg loops).

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

---
Within a day it has found its first bug:

==================================================================
BUG: KASAN: use-after-free in atomic_dec_and_test
arch/x86/include/asm/atomic.h:123 [inline] at addr ffff880079c30158
BUG: KASAN: use-after-free in put_task_struct
include/linux/sched/task.h:93 [inline] at addr ffff880079c30158
BUG: KASAN: use-after-free in put_ctx+0xcf/0x110
kernel/events/core.c:1131 at addr ffff880079c30158
Write of size 4 by task syz-executor6/25698
CPU: 2 PID: 25698 Comm: syz-executor6 Not tainted 4.10.0+ #302
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x2fb/0x3fd lib/dump_stack.c:52
 kasan_object_err+0x1c/0x90 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:208 [inline]
 kasan_report_error mm/kasan/report.c:292 [inline]
 kasan_report.part.2+0x1b0/0x460 mm/kasan/report.c:314
 kasan_report+0x21/0x30 mm/kasan/report.c:301
 check_memory_region_inline mm/kasan/kasan.c:326 [inline]
 check_memory_region+0x139/0x190 mm/kasan/kasan.c:333
 kasan_check_write+0x14/0x20 mm/kasan/kasan.c:344
 atomic_dec_and_test arch/x86/include/asm/atomic.h:123 [inline]
 put_task_struct include/linux/sched/task.h:93 [inline]
 put_ctx+0xcf/0x110 kernel/events/core.c:1131
 perf_event_release_kernel+0x3ad/0xc90 kernel/events/core.c:4322
 perf_release+0x37/0x50 kernel/events/core.c:4338
 __fput+0x332/0x800 fs/file_table.c:209
 ____fput+0x15/0x20 fs/file_table.c:245
 task_work_run+0x197/0x260 kernel/task_work.c:116
 exit_task_work include/linux/task_work.h:21 [inline]
 do_exit+0xb38/0x29c0 kernel/exit.c:880
 do_group_exit+0x149/0x420 kernel/exit.c:984
 get_signal+0x7e0/0x1820 kernel/signal.c:2318
 do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:808
 exit_to_usermode_loop+0x200/0x2a0 arch/x86/entry/common.c:157
 syscall_return_slowpath arch/x86/entry/common.c:191 [inline]
 do_syscall_64+0x6fc/0x930 arch/x86/entry/common.c:286
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x4458d9
RSP: 002b:00007f3f07187cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffe00 RBX: 00000000007080c8 RCX: 00000000004458d9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000007080c8
RBP: 00000000007080a8 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000000 R14: 00007f3f071889c0 R15: 00007f3f07188700
Object at ffff880079c30140, in cache task_struct size: 5376
Allocated:
PID = 25681
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:616
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:555
 kmem_cache_alloc_node+0x122/0x6f0 mm/slab.c:3662
 alloc_task_struct_node kernel/fork.c:153 [inline]
 dup_task_struct kernel/fork.c:495 [inline]
 copy_process.part.38+0x19c8/0x4aa0 kernel/fork.c:1560
 copy_process kernel/fork.c:1531 [inline]
 _do_fork+0x200/0x1010 kernel/fork.c:1994
 SYSC_clone kernel/fork.c:2104 [inline]
 SyS_clone+0x37/0x50 kernel/fork.c:2098
 do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:281
 return_from_SYSCALL_64+0x0/0x7a
Freed:
PID = 25681
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:589
 __cache_free mm/slab.c:3514 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3774
 free_task_struct kernel/fork.c:158 [inline]
 free_task+0x151/0x1d0 kernel/fork.c:370
 copy_process.part.38+0x18e5/0x4aa0 kernel/fork.c:1931
 copy_process kernel/fork.c:1531 [inline]
 _do_fork+0x200/0x1010 kernel/fork.c:1994
 SYSC_clone kernel/fork.c:2104 [inline]
 SyS_clone+0x37/0x50 kernel/fork.c:2098
 do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:281
 return_from_SYSCALL_64+0x0/0x7a
---
 arch/x86/include/asm/atomic.h      | 11 +++++++++++
 arch/x86/include/asm/atomic64_64.h | 10 ++++++++++
 arch/x86/include/asm/cmpxchg.h     |  4 ++++
 3 files changed, 25 insertions(+)

diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
index 14635c5ea025..64f0a7fb9b2f 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -2,6 +2,7 @@
 #define _ASM_X86_ATOMIC_H
 
 #include <linux/compiler.h>
+#include <linux/kasan-checks.h>
 #include <linux/types.h>
 #include <asm/alternative.h>
 #include <asm/cmpxchg.h>
@@ -47,6 +48,7 @@ static __always_inline void atomic_set(atomic_t *v, int i)
  */
 static __always_inline void atomic_add(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	asm volatile(LOCK_PREFIX "addl %1,%0"
 		     : "+m" (v->counter)
 		     : "ir" (i));
@@ -61,6 +63,7 @@ static __always_inline void atomic_add(int i, atomic_t *v)
  */
 static __always_inline void atomic_sub(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	asm volatile(LOCK_PREFIX "subl %1,%0"
 		     : "+m" (v->counter)
 		     : "ir" (i));
@@ -77,6 +80,7 @@ static __always_inline void atomic_sub(int i, atomic_t *v)
  */
 static __always_inline bool atomic_sub_and_test(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	GEN_BINARY_RMWcc(LOCK_PREFIX "subl", v->counter, "er", i, "%0", e);
 }
 
@@ -88,6 +92,7 @@ static __always_inline bool atomic_sub_and_test(int i, atomic_t *v)
  */
 static __always_inline void atomic_inc(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	asm volatile(LOCK_PREFIX "incl %0"
 		     : "+m" (v->counter));
 }
@@ -100,6 +105,7 @@ static __always_inline void atomic_inc(atomic_t *v)
  */
 static __always_inline void atomic_dec(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	asm volatile(LOCK_PREFIX "decl %0"
 		     : "+m" (v->counter));
 }
@@ -114,6 +120,7 @@ static __always_inline void atomic_dec(atomic_t *v)
  */
 static __always_inline bool atomic_dec_and_test(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	GEN_UNARY_RMWcc(LOCK_PREFIX "decl", v->counter, "%0", e);
 }
 
@@ -127,6 +134,7 @@ static __always_inline bool atomic_dec_and_test(atomic_t *v)
  */
 static __always_inline bool atomic_inc_and_test(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	GEN_UNARY_RMWcc(LOCK_PREFIX "incl", v->counter, "%0", e);
 }
 
@@ -141,6 +149,7 @@ static __always_inline bool atomic_inc_and_test(atomic_t *v)
  */
 static __always_inline bool atomic_add_negative(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	GEN_BINARY_RMWcc(LOCK_PREFIX "addl", v->counter, "er", i, "%0", s);
 }
 
@@ -194,6 +203,7 @@ static inline int atomic_xchg(atomic_t *v, int new)
 #define ATOMIC_OP(op)							\
 static inline void atomic_##op(int i, atomic_t *v)			\
 {									\
+	kasan_check_write(v, sizeof(*v));				\
 	asm volatile(LOCK_PREFIX #op"l %1,%0"				\
 			: "+m" (v->counter)				\
 			: "ir" (i)					\
@@ -258,6 +268,7 @@ static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
  */
 static __always_inline short int atomic_inc_short(short int *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	asm(LOCK_PREFIX "addw $1, %0" : "+m" (*v));
 	return *v;
 }
diff --git a/arch/x86/include/asm/atomic64_64.h b/arch/x86/include/asm/atomic64_64.h
index 89ed2f6ae2f7..13fe8ff5a126 100644
--- a/arch/x86/include/asm/atomic64_64.h
+++ b/arch/x86/include/asm/atomic64_64.h
@@ -2,6 +2,7 @@
 #define _ASM_X86_ATOMIC64_64_H
 
 #include <linux/types.h>
+#include <linux/kasan-checks.h>
 #include <asm/alternative.h>
 #include <asm/cmpxchg.h>
 
@@ -42,6 +43,7 @@ static inline void atomic64_set(atomic64_t *v, long i)
  */
 static __always_inline void atomic64_add(long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	asm volatile(LOCK_PREFIX "addq %1,%0"
 		     : "=m" (v->counter)
 		     : "er" (i), "m" (v->counter));
@@ -56,6 +58,7 @@ static __always_inline void atomic64_add(long i, atomic64_t *v)
  */
 static inline void atomic64_sub(long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	asm volatile(LOCK_PREFIX "subq %1,%0"
 		     : "=m" (v->counter)
 		     : "er" (i), "m" (v->counter));
@@ -72,6 +75,7 @@ static inline void atomic64_sub(long i, atomic64_t *v)
  */
 static inline bool atomic64_sub_and_test(long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	GEN_BINARY_RMWcc(LOCK_PREFIX "subq", v->counter, "er", i, "%0", e);
 }
 
@@ -83,6 +87,7 @@ static inline bool atomic64_sub_and_test(long i, atomic64_t *v)
  */
 static __always_inline void atomic64_inc(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	asm volatile(LOCK_PREFIX "incq %0"
 		     : "=m" (v->counter)
 		     : "m" (v->counter));
@@ -96,6 +101,7 @@ static __always_inline void atomic64_inc(atomic64_t *v)
  */
 static __always_inline void atomic64_dec(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	asm volatile(LOCK_PREFIX "decq %0"
 		     : "=m" (v->counter)
 		     : "m" (v->counter));
@@ -111,6 +117,7 @@ static __always_inline void atomic64_dec(atomic64_t *v)
  */
 static inline bool atomic64_dec_and_test(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	GEN_UNARY_RMWcc(LOCK_PREFIX "decq", v->counter, "%0", e);
 }
 
@@ -124,6 +131,7 @@ static inline bool atomic64_dec_and_test(atomic64_t *v)
  */
 static inline bool atomic64_inc_and_test(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	GEN_UNARY_RMWcc(LOCK_PREFIX "incq", v->counter, "%0", e);
 }
 
@@ -138,6 +146,7 @@ static inline bool atomic64_inc_and_test(atomic64_t *v)
  */
 static inline bool atomic64_add_negative(long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	GEN_BINARY_RMWcc(LOCK_PREFIX "addq", v->counter, "er", i, "%0", s);
 }
 
@@ -233,6 +242,7 @@ static inline long atomic64_dec_if_positive(atomic64_t *v)
 #define ATOMIC64_OP(op)							\
 static inline void atomic64_##op(long i, atomic64_t *v)			\
 {									\
+	kasan_check_write(v, sizeof(*v));				\
 	asm volatile(LOCK_PREFIX #op"q %1,%0"				\
 			: "+m" (v->counter)				\
 			: "er" (i)					\
diff --git a/arch/x86/include/asm/cmpxchg.h b/arch/x86/include/asm/cmpxchg.h
index 97848cdfcb1a..a10e7fb09210 100644
--- a/arch/x86/include/asm/cmpxchg.h
+++ b/arch/x86/include/asm/cmpxchg.h
@@ -2,6 +2,7 @@
 #define ASM_X86_CMPXCHG_H
 
 #include <linux/compiler.h>
+#include <linux/kasan-checks.h>
 #include <asm/cpufeatures.h>
 #include <asm/alternative.h> /* Provides LOCK_PREFIX */
 
@@ -41,6 +42,7 @@ extern void __add_wrong_size(void)
 #define __xchg_op(ptr, arg, op, lock)					\
 	({								\
 	        __typeof__ (*(ptr)) __ret = (arg);			\
+		kasan_check_write((void *)(ptr), sizeof(*(ptr)));	\
 		switch (sizeof(*(ptr))) {				\
 		case __X86_CASE_B:					\
 			asm volatile (lock #op "b %b0, %1\n"		\
@@ -86,6 +88,7 @@ extern void __add_wrong_size(void)
 	__typeof__(*(ptr)) __ret;					\
 	__typeof__(*(ptr)) __old = (old);				\
 	__typeof__(*(ptr)) __new = (new);				\
+	kasan_check_write((void *)(ptr), sizeof(*(ptr)));		\
 	switch (size) {							\
 	case __X86_CASE_B:						\
 	{								\
@@ -171,6 +174,7 @@ extern void __add_wrong_size(void)
 	BUILD_BUG_ON(sizeof(*(p2)) != sizeof(long));			\
 	VM_BUG_ON((unsigned long)(p1) % (2 * sizeof(long)));		\
 	VM_BUG_ON((unsigned long)((p1) + 1) != (unsigned long)(p2));	\
+	kasan_check_write((void *)(p1), 2 * sizeof(*(p1)));		\
 	asm volatile(pfx "cmpxchg%c4b %2; sete %0"			\
 		     : "=a" (__ret), "+d" (__old2),			\
 		       "+m" (*(p1)), "+m" (*(p2))			\
-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
