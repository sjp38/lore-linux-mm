Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECC206B79AD
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 06:24:39 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e68so60775plb.3
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 03:24:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u9si92152pge.48.2018.12.06.03.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 03:24:37 -0800 (PST)
Date: Thu, 6 Dec 2018 12:24:33 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Number of arguments in vmalloc.c
Message-ID: <20181206112433.GB13675@hirez.programming.kicks-ass.net>
References: <20181128140136.GG10377@bombadil.infradead.org>
 <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
 <20181203161352.GP10377@bombadil.infradead.org>
 <4F09425C-C9AB-452F-899C-3CF3D4B737E1@gmail.com>
 <20181203224920.GQ10377@bombadil.infradead.org>
 <C377D9EF-A0F4-4142-8145-6942DC29A353@gmail.com>
 <EB579DAE-B25F-4869-8529-8586DF4AECFF@gmail.com>
 <20181206102559.GG13538@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181206102559.GG13538@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>

On Thu, Dec 06, 2018 at 11:25:59AM +0100, Peter Zijlstra wrote:
> On Thu, Dec 06, 2018 at 12:28:26AM -0800, Nadav Amit wrote:
> > [ +Peter ]
> > 
> > So I dug some more (I’m still not done), and found various trivial things
> > (e.g., storing zero extending u32 immediate is shorter for registers,
> > inlining already takes place).
> > 
> > *But* there is one thing that may require some attention - patch
> > b59167ac7bafd ("x86/percpu: Fix this_cpu_read()”) set ordering constraints
> > on the VM_ARGS() evaluation. And this patch also imposes, it appears,
> > (unnecessary) constraints on other pieces of code.
> > 
> > These constraints are due to the addition of the volatile keyword for
> > this_cpu_read() by the patch. This affects at least 68 functions in my
> > kernel build, some of which are hot (I think), e.g., finish_task_switch(),
> > smp_x86_platform_ipi() and select_idle_sibling().
> > 
> > Peter, perhaps the solution was too big of a hammer? Is it possible instead
> > to create a separate "this_cpu_read_once()” with the volatile keyword? Such
> > a function can be used for native_sched_clock() and other seqlocks, etc.
> 
> No. like the commit writes this_cpu_read() _must_ imply READ_ONCE(). If
> you want something else, use something else, there's plenty other
> options available.

The thing is, the this_cpu_*() things are defined IRQ-safe, this means
the values are subject to change from IRQs, and thus must be reloaded.

Also (the generic form):

  local_irq_save()
  __this_cpu_read()
  local_irq_restore()

would not be allowed to be munged like that.

Which raises the point that percpu_from_op() and the other also need
that volatile.

__this_cpu_*() OTOH assumes external preempt/IRQ disabling and could
thus be allowed to move crud about.

Which would suggest the following

---
 arch/x86/include/asm/percpu.h | 224 +++++++++++++++++++++---------------------
 1 file changed, 112 insertions(+), 112 deletions(-)

diff --git a/arch/x86/include/asm/percpu.h b/arch/x86/include/asm/percpu.h
index 1a19d11cfbbd..f75ccccd71aa 100644
--- a/arch/x86/include/asm/percpu.h
+++ b/arch/x86/include/asm/percpu.h
@@ -87,7 +87,7 @@
  * don't give an lvalue though). */
 extern void __bad_percpu_size(void);
 
-#define percpu_to_op(op, var, val)			\
+#define percpu_to_op(qual, op, var, val)		\
 do {							\
 	typedef typeof(var) pto_T__;			\
 	if (0) {					\
@@ -97,22 +97,22 @@ do {							\
 	}						\
 	switch (sizeof(var)) {				\
 	case 1:						\
-		asm(op "b %1,"__percpu_arg(0)		\
+		asm qual (op "b %1,"__percpu_arg(0)	\
 		    : "+m" (var)			\
 		    : "qi" ((pto_T__)(val)));		\
 		break;					\
 	case 2:						\
-		asm(op "w %1,"__percpu_arg(0)		\
+		asm qual (op "w %1,"__percpu_arg(0)	\
 		    : "+m" (var)			\
 		    : "ri" ((pto_T__)(val)));		\
 		break;					\
 	case 4:						\
-		asm(op "l %1,"__percpu_arg(0)		\
+		asm qual (op "l %1,"__percpu_arg(0)	\
 		    : "+m" (var)			\
 		    : "ri" ((pto_T__)(val)));		\
 		break;					\
 	case 8:						\
-		asm(op "q %1,"__percpu_arg(0)		\
+		asm qual (op "q %1,"__percpu_arg(0)	\
 		    : "+m" (var)			\
 		    : "re" ((pto_T__)(val)));		\
 		break;					\
@@ -124,7 +124,7 @@ do {							\
  * Generate a percpu add to memory instruction and optimize code
  * if one is added or subtracted.
  */
-#define percpu_add_op(var, val)						\
+#define percpu_add_op(qual, var, val)					\
 do {									\
 	typedef typeof(var) pao_T__;					\
 	const int pao_ID__ = (__builtin_constant_p(val) &&		\
@@ -138,41 +138,41 @@ do {									\
 	switch (sizeof(var)) {						\
 	case 1:								\
 		if (pao_ID__ == 1)					\
-			asm("incb "__percpu_arg(0) : "+m" (var));	\
+			asm qual ("incb "__percpu_arg(0) : "+m" (var));	\
 		else if (pao_ID__ == -1)				\
-			asm("decb "__percpu_arg(0) : "+m" (var));	\
+			asm qual ("decb "__percpu_arg(0) : "+m" (var));	\
 		else							\
-			asm("addb %1, "__percpu_arg(0)			\
+			asm qual ("addb %1, "__percpu_arg(0)		\
 			    : "+m" (var)				\
 			    : "qi" ((pao_T__)(val)));			\
 		break;							\
 	case 2:								\
 		if (pao_ID__ == 1)					\
-			asm("incw "__percpu_arg(0) : "+m" (var));	\
+			asm qual ("incw "__percpu_arg(0) : "+m" (var));	\
 		else if (pao_ID__ == -1)				\
-			asm("decw "__percpu_arg(0) : "+m" (var));	\
+			asm qual ("decw "__percpu_arg(0) : "+m" (var));	\
 		else							\
-			asm("addw %1, "__percpu_arg(0)			\
+			asm qual ("addw %1, "__percpu_arg(0)		\
 			    : "+m" (var)				\
 			    : "ri" ((pao_T__)(val)));			\
 		break;							\
 	case 4:								\
 		if (pao_ID__ == 1)					\
-			asm("incl "__percpu_arg(0) : "+m" (var));	\
+			asm qual ("incl "__percpu_arg(0) : "+m" (var));	\
 		else if (pao_ID__ == -1)				\
-			asm("decl "__percpu_arg(0) : "+m" (var));	\
+			asm qual ("decl "__percpu_arg(0) : "+m" (var));	\
 		else							\
-			asm("addl %1, "__percpu_arg(0)			\
+			asm qual ("addl %1, "__percpu_arg(0)		\
 			    : "+m" (var)				\
 			    : "ri" ((pao_T__)(val)));			\
 		break;							\
 	case 8:								\
 		if (pao_ID__ == 1)					\
-			asm("incq "__percpu_arg(0) : "+m" (var));	\
+			asm qual ("incq "__percpu_arg(0) : "+m" (var));	\
 		else if (pao_ID__ == -1)				\
-			asm("decq "__percpu_arg(0) : "+m" (var));	\
+			asm qual ("decq "__percpu_arg(0) : "+m" (var));	\
 		else							\
-			asm("addq %1, "__percpu_arg(0)			\
+			asm qual ("addq %1, "__percpu_arg(0)		\
 			    : "+m" (var)				\
 			    : "re" ((pao_T__)(val)));			\
 		break;							\
@@ -180,27 +180,27 @@ do {									\
 	}								\
 } while (0)
 
-#define percpu_from_op(op, var)				\
+#define percpu_from_op(qual, op, var)			\
 ({							\
 	typeof(var) pfo_ret__;				\
 	switch (sizeof(var)) {				\
 	case 1:						\
-		asm volatile(op "b "__percpu_arg(1)",%0"\
+		asm qual (op "b "__percpu_arg(1)",%0"	\
 		    : "=q" (pfo_ret__)			\
 		    : "m" (var));			\
 		break;					\
 	case 2:						\
-		asm volatile(op "w "__percpu_arg(1)",%0"\
+		asm qual (op "w "__percpu_arg(1)",%0"	\
 		    : "=r" (pfo_ret__)			\
 		    : "m" (var));			\
 		break;					\
 	case 4:						\
-		asm volatile(op "l "__percpu_arg(1)",%0"\
+		asm qual (op "l "__percpu_arg(1)",%0"	\
 		    : "=r" (pfo_ret__)			\
 		    : "m" (var));			\
 		break;					\
 	case 8:						\
-		asm volatile(op "q "__percpu_arg(1)",%0"\
+		asm qual (op "q "__percpu_arg(1)",%0"	\
 		    : "=r" (pfo_ret__)			\
 		    : "m" (var));			\
 		break;					\
@@ -238,23 +238,23 @@ do {									\
 	pfo_ret__;					\
 })
 
-#define percpu_unary_op(op, var)			\
+#define percpu_unary_op(qual, op, var)			\
 ({							\
 	switch (sizeof(var)) {				\
 	case 1:						\
-		asm(op "b "__percpu_arg(0)		\
+		asm qual (op "b "__percpu_arg(0)	\
 		    : "+m" (var));			\
 		break;					\
 	case 2:						\
-		asm(op "w "__percpu_arg(0)		\
+		asm qual (op "w "__percpu_arg(0)	\
 		    : "+m" (var));			\
 		break;					\
 	case 4:						\
-		asm(op "l "__percpu_arg(0)		\
+		asm qual (op "l "__percpu_arg(0)	\
 		    : "+m" (var));			\
 		break;					\
 	case 8:						\
-		asm(op "q "__percpu_arg(0)		\
+		asm qual (op "q "__percpu_arg(0)	\
 		    : "+m" (var));			\
 		break;					\
 	default: __bad_percpu_size();			\
@@ -264,27 +264,27 @@ do {									\
 /*
  * Add return operation
  */
-#define percpu_add_return_op(var, val)					\
+#define percpu_add_return_op(qual, var, val)				\
 ({									\
 	typeof(var) paro_ret__ = val;					\
 	switch (sizeof(var)) {						\
 	case 1:								\
-		asm("xaddb %0, "__percpu_arg(1)				\
+		asm qual ("xaddb %0, "__percpu_arg(1)			\
 			    : "+q" (paro_ret__), "+m" (var)		\
 			    : : "memory");				\
 		break;							\
 	case 2:								\
-		asm("xaddw %0, "__percpu_arg(1)				\
+		asm qual ("xaddw %0, "__percpu_arg(1)			\
 			    : "+r" (paro_ret__), "+m" (var)		\
 			    : : "memory");				\
 		break;							\
 	case 4:								\
-		asm("xaddl %0, "__percpu_arg(1)				\
+		asm qual ("xaddl %0, "__percpu_arg(1)			\
 			    : "+r" (paro_ret__), "+m" (var)		\
 			    : : "memory");				\
 		break;							\
 	case 8:								\
-		asm("xaddq %0, "__percpu_arg(1)				\
+		asm qual ("xaddq %0, "__percpu_arg(1)			\
 			    : "+re" (paro_ret__), "+m" (var)		\
 			    : : "memory");				\
 		break;							\
@@ -299,13 +299,13 @@ do {									\
  * expensive due to the implied lock prefix.  The processor cannot prefetch
  * cachelines if xchg is used.
  */
-#define percpu_xchg_op(var, nval)					\
+#define percpu_xchg_op(qual, var, nval)					\
 ({									\
 	typeof(var) pxo_ret__;						\
 	typeof(var) pxo_new__ = (nval);					\
 	switch (sizeof(var)) {						\
 	case 1:								\
-		asm("\n\tmov "__percpu_arg(1)",%%al"			\
+		asm qual ("\n\tmov "__percpu_arg(1)",%%al"		\
 		    "\n1:\tcmpxchgb %2, "__percpu_arg(1)		\
 		    "\n\tjnz 1b"					\
 			    : "=&a" (pxo_ret__), "+m" (var)		\
@@ -313,7 +313,7 @@ do {									\
 			    : "memory");				\
 		break;							\
 	case 2:								\
-		asm("\n\tmov "__percpu_arg(1)",%%ax"			\
+		asm qual ("\n\tmov "__percpu_arg(1)",%%ax"		\
 		    "\n1:\tcmpxchgw %2, "__percpu_arg(1)		\
 		    "\n\tjnz 1b"					\
 			    : "=&a" (pxo_ret__), "+m" (var)		\
@@ -321,7 +321,7 @@ do {									\
 			    : "memory");				\
 		break;							\
 	case 4:								\
-		asm("\n\tmov "__percpu_arg(1)",%%eax"			\
+		asm qual ("\n\tmov "__percpu_arg(1)",%%eax"		\
 		    "\n1:\tcmpxchgl %2, "__percpu_arg(1)		\
 		    "\n\tjnz 1b"					\
 			    : "=&a" (pxo_ret__), "+m" (var)		\
@@ -329,7 +329,7 @@ do {									\
 			    : "memory");				\
 		break;							\
 	case 8:								\
-		asm("\n\tmov "__percpu_arg(1)",%%rax"			\
+		asm qual ("\n\tmov "__percpu_arg(1)",%%rax"		\
 		    "\n1:\tcmpxchgq %2, "__percpu_arg(1)		\
 		    "\n\tjnz 1b"					\
 			    : "=&a" (pxo_ret__), "+m" (var)		\
@@ -345,32 +345,32 @@ do {									\
  * cmpxchg has no such implied lock semantics as a result it is much
  * more efficient for cpu local operations.
  */
-#define percpu_cmpxchg_op(var, oval, nval)				\
+#define percpu_cmpxchg_op(qual, var, oval, nval)			\
 ({									\
 	typeof(var) pco_ret__;						\
 	typeof(var) pco_old__ = (oval);					\
 	typeof(var) pco_new__ = (nval);					\
 	switch (sizeof(var)) {						\
 	case 1:								\
-		asm("cmpxchgb %2, "__percpu_arg(1)			\
+		asm qual ("cmpxchgb %2, "__percpu_arg(1)		\
 			    : "=a" (pco_ret__), "+m" (var)		\
 			    : "q" (pco_new__), "0" (pco_old__)		\
 			    : "memory");				\
 		break;							\
 	case 2:								\
-		asm("cmpxchgw %2, "__percpu_arg(1)			\
+		asm qual ("cmpxchgw %2, "__percpu_arg(1)		\
 			    : "=a" (pco_ret__), "+m" (var)		\
 			    : "r" (pco_new__), "0" (pco_old__)		\
 			    : "memory");				\
 		break;							\
 	case 4:								\
-		asm("cmpxchgl %2, "__percpu_arg(1)			\
+		asm qual ("cmpxchgl %2, "__percpu_arg(1)		\
 			    : "=a" (pco_ret__), "+m" (var)		\
 			    : "r" (pco_new__), "0" (pco_old__)		\
 			    : "memory");				\
 		break;							\
 	case 8:								\
-		asm("cmpxchgq %2, "__percpu_arg(1)			\
+		asm qual ("cmpxchgq %2, "__percpu_arg(1)		\
 			    : "=a" (pco_ret__), "+m" (var)		\
 			    : "r" (pco_new__), "0" (pco_old__)		\
 			    : "memory");				\
@@ -391,58 +391,58 @@ do {									\
  */
 #define this_cpu_read_stable(var)	percpu_stable_op("mov", var)
 
-#define raw_cpu_read_1(pcp)		percpu_from_op("mov", pcp)
-#define raw_cpu_read_2(pcp)		percpu_from_op("mov", pcp)
-#define raw_cpu_read_4(pcp)		percpu_from_op("mov", pcp)
-
-#define raw_cpu_write_1(pcp, val)	percpu_to_op("mov", (pcp), val)
-#define raw_cpu_write_2(pcp, val)	percpu_to_op("mov", (pcp), val)
-#define raw_cpu_write_4(pcp, val)	percpu_to_op("mov", (pcp), val)
-#define raw_cpu_add_1(pcp, val)		percpu_add_op((pcp), val)
-#define raw_cpu_add_2(pcp, val)		percpu_add_op((pcp), val)
-#define raw_cpu_add_4(pcp, val)		percpu_add_op((pcp), val)
-#define raw_cpu_and_1(pcp, val)		percpu_to_op("and", (pcp), val)
-#define raw_cpu_and_2(pcp, val)		percpu_to_op("and", (pcp), val)
-#define raw_cpu_and_4(pcp, val)		percpu_to_op("and", (pcp), val)
-#define raw_cpu_or_1(pcp, val)		percpu_to_op("or", (pcp), val)
-#define raw_cpu_or_2(pcp, val)		percpu_to_op("or", (pcp), val)
-#define raw_cpu_or_4(pcp, val)		percpu_to_op("or", (pcp), val)
-#define raw_cpu_xchg_1(pcp, val)	percpu_xchg_op(pcp, val)
-#define raw_cpu_xchg_2(pcp, val)	percpu_xchg_op(pcp, val)
-#define raw_cpu_xchg_4(pcp, val)	percpu_xchg_op(pcp, val)
-
-#define this_cpu_read_1(pcp)		percpu_from_op("mov", pcp)
-#define this_cpu_read_2(pcp)		percpu_from_op("mov", pcp)
-#define this_cpu_read_4(pcp)		percpu_from_op("mov", pcp)
-#define this_cpu_write_1(pcp, val)	percpu_to_op("mov", (pcp), val)
-#define this_cpu_write_2(pcp, val)	percpu_to_op("mov", (pcp), val)
-#define this_cpu_write_4(pcp, val)	percpu_to_op("mov", (pcp), val)
-#define this_cpu_add_1(pcp, val)	percpu_add_op((pcp), val)
-#define this_cpu_add_2(pcp, val)	percpu_add_op((pcp), val)
-#define this_cpu_add_4(pcp, val)	percpu_add_op((pcp), val)
-#define this_cpu_and_1(pcp, val)	percpu_to_op("and", (pcp), val)
-#define this_cpu_and_2(pcp, val)	percpu_to_op("and", (pcp), val)
-#define this_cpu_and_4(pcp, val)	percpu_to_op("and", (pcp), val)
-#define this_cpu_or_1(pcp, val)		percpu_to_op("or", (pcp), val)
-#define this_cpu_or_2(pcp, val)		percpu_to_op("or", (pcp), val)
-#define this_cpu_or_4(pcp, val)		percpu_to_op("or", (pcp), val)
-#define this_cpu_xchg_1(pcp, nval)	percpu_xchg_op(pcp, nval)
-#define this_cpu_xchg_2(pcp, nval)	percpu_xchg_op(pcp, nval)
-#define this_cpu_xchg_4(pcp, nval)	percpu_xchg_op(pcp, nval)
-
-#define raw_cpu_add_return_1(pcp, val)		percpu_add_return_op(pcp, val)
-#define raw_cpu_add_return_2(pcp, val)		percpu_add_return_op(pcp, val)
-#define raw_cpu_add_return_4(pcp, val)		percpu_add_return_op(pcp, val)
-#define raw_cpu_cmpxchg_1(pcp, oval, nval)	percpu_cmpxchg_op(pcp, oval, nval)
-#define raw_cpu_cmpxchg_2(pcp, oval, nval)	percpu_cmpxchg_op(pcp, oval, nval)
-#define raw_cpu_cmpxchg_4(pcp, oval, nval)	percpu_cmpxchg_op(pcp, oval, nval)
-
-#define this_cpu_add_return_1(pcp, val)		percpu_add_return_op(pcp, val)
-#define this_cpu_add_return_2(pcp, val)		percpu_add_return_op(pcp, val)
-#define this_cpu_add_return_4(pcp, val)		percpu_add_return_op(pcp, val)
-#define this_cpu_cmpxchg_1(pcp, oval, nval)	percpu_cmpxchg_op(pcp, oval, nval)
-#define this_cpu_cmpxchg_2(pcp, oval, nval)	percpu_cmpxchg_op(pcp, oval, nval)
-#define this_cpu_cmpxchg_4(pcp, oval, nval)	percpu_cmpxchg_op(pcp, oval, nval)
+#define raw_cpu_read_1(pcp)		percpu_from_op(, "mov", pcp)
+#define raw_cpu_read_2(pcp)		percpu_from_op(, "mov", pcp)
+#define raw_cpu_read_4(pcp)		percpu_from_op(, "mov", pcp)
+
+#define raw_cpu_write_1(pcp, val)	percpu_to_op(, "mov", (pcp), val)
+#define raw_cpu_write_2(pcp, val)	percpu_to_op(, "mov", (pcp), val)
+#define raw_cpu_write_4(pcp, val)	percpu_to_op(, "mov", (pcp), val)
+#define raw_cpu_add_1(pcp, val)		percpu_add_op(, (pcp), val)
+#define raw_cpu_add_2(pcp, val)		percpu_add_op(, (pcp), val)
+#define raw_cpu_add_4(pcp, val)		percpu_add_op(, (pcp), val)
+#define raw_cpu_and_1(pcp, val)		percpu_to_op(, "and", (pcp), val)
+#define raw_cpu_and_2(pcp, val)		percpu_to_op(, "and", (pcp), val)
+#define raw_cpu_and_4(pcp, val)		percpu_to_op(, "and", (pcp), val)
+#define raw_cpu_or_1(pcp, val)		percpu_to_op(, "or", (pcp), val)
+#define raw_cpu_or_2(pcp, val)		percpu_to_op(, "or", (pcp), val)
+#define raw_cpu_or_4(pcp, val)		percpu_to_op(, "or", (pcp), val)
+#define raw_cpu_xchg_1(pcp, val)	percpu_xchg_op(, pcp, val)
+#define raw_cpu_xchg_2(pcp, val)	percpu_xchg_op(, pcp, val)
+#define raw_cpu_xchg_4(pcp, val)	percpu_xchg_op(, pcp, val)
+
+#define this_cpu_read_1(pcp)		percpu_from_op(volatile, "mov", pcp)
+#define this_cpu_read_2(pcp)		percpu_from_op(volatile, "mov", pcp)
+#define this_cpu_read_4(pcp)		percpu_from_op(volatile, "mov", pcp)
+#define this_cpu_write_1(pcp, val)	percpu_to_op(volatile, "mov", (pcp), val)
+#define this_cpu_write_2(pcp, val)	percpu_to_op(volatile, "mov", (pcp), val)
+#define this_cpu_write_4(pcp, val)	percpu_to_op(volatile, "mov", (pcp), val)
+#define this_cpu_add_1(pcp, val)	percpu_add_op(volatile, (pcp), val)
+#define this_cpu_add_2(pcp, val)	percpu_add_op(volatile, (pcp), val)
+#define this_cpu_add_4(pcp, val)	percpu_add_op(volatile, (pcp), val)
+#define this_cpu_and_1(pcp, val)	percpu_to_op(volatile, "and", (pcp), val)
+#define this_cpu_and_2(pcp, val)	percpu_to_op(volatile, "and", (pcp), val)
+#define this_cpu_and_4(pcp, val)	percpu_to_op(volatile, "and", (pcp), val)
+#define this_cpu_or_1(pcp, val)		percpu_to_op(volatile, "or", (pcp), val)
+#define this_cpu_or_2(pcp, val)		percpu_to_op(volatile, "or", (pcp), val)
+#define this_cpu_or_4(pcp, val)		percpu_to_op(volatile, "or", (pcp), val)
+#define this_cpu_xchg_1(pcp, nval)	percpu_xchg_op(volatile, pcp, nval)
+#define this_cpu_xchg_2(pcp, nval)	percpu_xchg_op(volatile, pcp, nval)
+#define this_cpu_xchg_4(pcp, nval)	percpu_xchg_op(volatile, pcp, nval)
+
+#define raw_cpu_add_return_1(pcp, val)		percpu_add_return_op(, pcp, val)
+#define raw_cpu_add_return_2(pcp, val)		percpu_add_return_op(, pcp, val)
+#define raw_cpu_add_return_4(pcp, val)		percpu_add_return_op(, pcp, val)
+#define raw_cpu_cmpxchg_1(pcp, oval, nval)	percpu_cmpxchg_op(, pcp, oval, nval)
+#define raw_cpu_cmpxchg_2(pcp, oval, nval)	percpu_cmpxchg_op(, pcp, oval, nval)
+#define raw_cpu_cmpxchg_4(pcp, oval, nval)	percpu_cmpxchg_op(, pcp, oval, nval)
+
+#define this_cpu_add_return_1(pcp, val)		percpu_add_return_op(volatile, pcp, val)
+#define this_cpu_add_return_2(pcp, val)		percpu_add_return_op(volatile, pcp, val)
+#define this_cpu_add_return_4(pcp, val)		percpu_add_return_op(volatile, pcp, val)
+#define this_cpu_cmpxchg_1(pcp, oval, nval)	percpu_cmpxchg_op(volatile, pcp, oval, nval)
+#define this_cpu_cmpxchg_2(pcp, oval, nval)	percpu_cmpxchg_op(volatile, pcp, oval, nval)
+#define this_cpu_cmpxchg_4(pcp, oval, nval)	percpu_cmpxchg_op(volatile, pcp, oval, nval)
 
 #ifdef CONFIG_X86_CMPXCHG64
 #define percpu_cmpxchg8b_double(pcp1, pcp2, o1, o2, n1, n2)		\
@@ -466,23 +466,23 @@ do {									\
  * 32 bit must fall back to generic operations.
  */
 #ifdef CONFIG_X86_64
-#define raw_cpu_read_8(pcp)			percpu_from_op("mov", pcp)
-#define raw_cpu_write_8(pcp, val)		percpu_to_op("mov", (pcp), val)
-#define raw_cpu_add_8(pcp, val)			percpu_add_op((pcp), val)
-#define raw_cpu_and_8(pcp, val)			percpu_to_op("and", (pcp), val)
-#define raw_cpu_or_8(pcp, val)			percpu_to_op("or", (pcp), val)
-#define raw_cpu_add_return_8(pcp, val)		percpu_add_return_op(pcp, val)
-#define raw_cpu_xchg_8(pcp, nval)		percpu_xchg_op(pcp, nval)
-#define raw_cpu_cmpxchg_8(pcp, oval, nval)	percpu_cmpxchg_op(pcp, oval, nval)
-
-#define this_cpu_read_8(pcp)			percpu_from_op("mov", pcp)
-#define this_cpu_write_8(pcp, val)		percpu_to_op("mov", (pcp), val)
-#define this_cpu_add_8(pcp, val)		percpu_add_op((pcp), val)
-#define this_cpu_and_8(pcp, val)		percpu_to_op("and", (pcp), val)
-#define this_cpu_or_8(pcp, val)			percpu_to_op("or", (pcp), val)
-#define this_cpu_add_return_8(pcp, val)		percpu_add_return_op(pcp, val)
-#define this_cpu_xchg_8(pcp, nval)		percpu_xchg_op(pcp, nval)
-#define this_cpu_cmpxchg_8(pcp, oval, nval)	percpu_cmpxchg_op(pcp, oval, nval)
+#define raw_cpu_read_8(pcp)			percpu_from_op(, "mov", pcp)
+#define raw_cpu_write_8(pcp, val)		percpu_to_op(, "mov", (pcp), val)
+#define raw_cpu_add_8(pcp, val)			percpu_add_op(, (pcp), val)
+#define raw_cpu_and_8(pcp, val)			percpu_to_op(, "and", (pcp), val)
+#define raw_cpu_or_8(pcp, val)			percpu_to_op(, "or", (pcp), val)
+#define raw_cpu_add_return_8(pcp, val)		percpu_add_return_op(, pcp, val)
+#define raw_cpu_xchg_8(pcp, nval)		percpu_xchg_op(, pcp, nval)
+#define raw_cpu_cmpxchg_8(pcp, oval, nval)	percpu_cmpxchg_op(, pcp, oval, nval)
+
+#define this_cpu_read_8(pcp)			percpu_from_op(volatile, "mov", pcp)
+#define this_cpu_write_8(pcp, val)		percpu_to_op(volatile, "mov", (pcp), val)
+#define this_cpu_add_8(pcp, val)		percpu_add_op(volatile, (pcp), val)
+#define this_cpu_and_8(pcp, val)		percpu_to_op(volatile, "and", (pcp), val)
+#define this_cpu_or_8(pcp, val)			percpu_to_op(volatile, "or", (pcp), val)
+#define this_cpu_add_return_8(pcp, val)		percpu_add_return_op(volatile, pcp, val)
+#define this_cpu_xchg_8(pcp, nval)		percpu_xchg_op(volatile, pcp, nval)
+#define this_cpu_cmpxchg_8(pcp, oval, nval)	percpu_cmpxchg_op(volatile, pcp, oval, nval)
 
 /*
  * Pretty complex macro to generate cmpxchg16 instruction.  The instruction
