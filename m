Message-ID: <4181EFBD.6000007@yahoo.com.au>
Date: Fri, 29 Oct 2004 17:22:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 5/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au> <4181EF54.6080308@yahoo.com.au> <4181EF69.4070201@yahoo.com.au> <4181EF80.3030709@yahoo.com.au> <4181EF96.2030602@yahoo.com.au>
In-Reply-To: <4181EF96.2030602@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------040907020104050604040508"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040907020104050604040508
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

5/7

--------------040907020104050604040508
Content-Type: text/x-patch;
 name="i386-cmpxchg.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="i386-cmpxchg.patch"



i386 patch to add cmpxchg functions from Christoph Lameter. Fixes
from Nick Piggin


---

 linux-2.6-npiggin/arch/i386/Kconfig            |    5 +
 linux-2.6-npiggin/arch/i386/kernel/cpu/intel.c |   60 ++++++++++++++++++++
 linux-2.6-npiggin/include/asm-i386/system.h    |   72 ++++++++++++++++++++++---
 3 files changed, 131 insertions(+), 6 deletions(-)

diff -puN arch/i386/Kconfig~i386-cmpxchg arch/i386/Kconfig
--- linux-2.6/arch/i386/Kconfig~i386-cmpxchg	2004-10-29 16:28:14.000000000 +1000
+++ linux-2.6-npiggin/arch/i386/Kconfig	2004-10-29 16:28:14.000000000 +1000
@@ -351,6 +351,11 @@ config X86_CMPXCHG
 	depends on !M386
 	default y
 
+config X86_CMPXCHG8B
+	bool
+	depends on !M386 && !M486
+	default y
+
 config X86_XADD
 	bool
 	depends on !M386
diff -puN arch/i386/kernel/cpu/intel.c~i386-cmpxchg arch/i386/kernel/cpu/intel.c
--- linux-2.6/arch/i386/kernel/cpu/intel.c~i386-cmpxchg	2004-10-29 16:28:14.000000000 +1000
+++ linux-2.6-npiggin/arch/i386/kernel/cpu/intel.c	2004-10-29 16:28:14.000000000 +1000
@@ -287,5 +287,65 @@ __init int intel_cpu_init(void)
 	return 0;
 }
 
+#ifndef CONFIG_X86_CMPXCHG
+unsigned long cmpxchg_386(volatile void *ptr, unsigned long old,
+				      unsigned long new, int size)
+{
+	unsigned long prev;
+	unsigned long flags;
+	/*
+	 * Check if the kernel was compiled for an old cpu but the
+	 * currently running cpu can do cmpxchg after all
+	 * All CPUs except 386 support CMPXCHG
+	 */
+	if (cpu_data->x86 > 3) return __cmpxchg(ptr, old, new, size);
+
+	/* Poor man's cmpxchg for 386. Unsuitable for SMP */
+	local_irq_save(flags);
+	switch (size) {
+	case 1:
+		prev = * (u8 *)ptr;
+		if (prev == old) *(u8 *)ptr = new;
+		break;
+	case 2:
+		prev = * (u16 *)ptr;
+		if (prev == old) *(u16 *)ptr = new;
+	case 4:
+		prev = *(u32 *)ptr;
+		if (prev == old) *(u32 *)ptr = new;
+		break;
+	}
+	local_irq_restore(flags);
+	return prev;
+}
+
+EXPORT_SYMBOL(cmpxchg_386);
+#endif
+
+#ifndef CONFIG_X86_CMPXCHG8B
+unsigned long long cmpxchg8b_486(unsigned long long *ptr,
+	       unsigned long long old, unsigned long long newv)
+{
+	unsigned long long prev;
+	unsigned long flags;
+
+	/*
+	 * Check if the kernel was compiled for an old cpu but
+	 * we are running really on a cpu capable of cmpxchg8b
+	 */
+
+	if (cpu_has(cpu_data, X86_FEATURE_CX8)) return __cmpxchg8b(ptr, old newv);
+
+	/* Poor mans cmpxchg8b for 386 and 486. Not suitable for SMP */
+	local_irq_save(flags);
+	prev = *ptr;
+	if (prev == old) *ptr = newv;
+	local_irq_restore(flags);
+	return prev;
+}
+
+EXPORT_SYMBOL(cmpxchg8b_486);
+#endif
+
 // arch_initcall(intel_cpu_init);
 
diff -puN include/asm-i386/system.h~i386-cmpxchg include/asm-i386/system.h
--- linux-2.6/include/asm-i386/system.h~i386-cmpxchg	2004-10-29 16:28:14.000000000 +1000
+++ linux-2.6-npiggin/include/asm-i386/system.h	2004-10-29 16:28:14.000000000 +1000
@@ -149,6 +149,9 @@ struct __xchg_dummy { unsigned long a[10
 #define __xg(x) ((struct __xchg_dummy *)(x))
 
 
+#define ll_low(x)	*(((unsigned int*)&(x))+0)
+#define ll_high(x)	*(((unsigned int*)&(x))+1)
+
 /*
  * The semantics of XCHGCMP8B are a bit strange, this is why
  * there is a loop and the loading of %%eax and %%edx has to
@@ -184,8 +187,6 @@ static inline void __set_64bit_constant 
 {
 	__set_64bit(ptr,(unsigned int)(value), (unsigned int)((value)>>32ULL));
 }
-#define ll_low(x)	*(((unsigned int*)&(x))+0)
-#define ll_high(x)	*(((unsigned int*)&(x))+1)
 
 static inline void __set_64bit_var (unsigned long long *ptr,
 			 unsigned long long value)
@@ -203,6 +204,26 @@ static inline void __set_64bit_var (unsi
  __set_64bit(ptr, (unsigned int)(value), (unsigned int)((value)>>32ULL) ) : \
  __set_64bit(ptr, ll_low(value), ll_high(value)) )
 
+static inline unsigned long long __get_64bit(unsigned long long * ptr)
+{
+	unsigned long long ret;
+	__asm__ __volatile__ (
+		"\n1:\t"
+		"movl (%1), %%eax\n\t"
+		"movl 4(%1), %%edx\n\t"
+		"movl %%eax, %%ebx\n\t"
+		"movl %%edx, %%ecx\n\t"
+		LOCK_PREFIX "cmpxchg8b (%1)\n\t"
+		"jnz 1b"
+		:	"=A"(ret)
+		:	"D"(ptr)
+		:	"ebx", "ecx", "memory");
+	return ret;
+}
+
+#define get_64bit(ptr) __get_64bit(ptr)
+
+
 /*
  * Note: no "lock" prefix even on SMP: xchg always implies lock anyway
  * Note 2: xchg has side effect, so that attribute volatile is necessary,
@@ -240,7 +261,24 @@ static inline unsigned long __xchg(unsig
  */
 
 #ifdef CONFIG_X86_CMPXCHG
+
 #define __HAVE_ARCH_CMPXCHG 1
+#define cmpxchg(ptr,o,n)\
+	((__typeof__(*(ptr)))__cmpxchg((ptr),(unsigned long)(o),\
+					(unsigned long)(n),sizeof(*(ptr))))
+
+#else
+
+/*
+ * Building a kernel capable running on 80386. It may be necessary to
+ * simulate the cmpxchg on the 80386 CPU.
+ */
+
+extern unsigned long cmpxchg_386(void *, unsigned long, unsigned long);
+
+#define cmpxchg(ptr,o,n)\
+	((__typeof__(*(ptr)))cmpxchg_386((ptr),(unsigned long)(o),\
+					(unsigned long)(n),sizeof(*(ptr))))
 #endif
 
 static inline unsigned long __cmpxchg(volatile void *ptr, unsigned long old,
@@ -270,10 +308,32 @@ static inline unsigned long __cmpxchg(vo
 	return old;
 }
 
-#define cmpxchg(ptr,o,n)\
-	((__typeof__(*(ptr)))__cmpxchg((ptr),(unsigned long)(o),\
-					(unsigned long)(n),sizeof(*(ptr))))
-    
+static inline unsigned long long __cmpxchg8b(volatile unsigned long long *ptr,
+		unsigned long long old, unsigned long long newv)
+{
+	unsigned long long prev;
+	__asm__ __volatile__(
+	LOCK_PREFIX "cmpxchg8b (%4)"
+		: "=A" (prev)
+		: "0" (old), "c" ((unsigned long)(newv >> 32)),
+		  "b" ((unsigned long)(newv & 0xffffffffULL)), "D" (ptr)
+		: "memory");
+	return prev;
+}
+
+#ifdef CONFIG_X86_CMPXCHG8B
+#define cmpxchg8b __cmpxchg8b
+#else
+/*
+ * Building a kernel capable of running on 80486 and 80386. Both
+ * do not support cmpxchg8b. Call a function that emulates the
+ * instruction if necessary.
+ */
+extern unsigned long long cmpxchg_486(unsigned long long *,
+		unsigned long long, unsigned long long);
+#define cmpxchg8b cmpxchg8b_486
+#endif
+   
 #ifdef __KERNEL__
 struct alt_instr { 
 	__u8 *instr; 		/* original instruction */

_

--------------040907020104050604040508--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
