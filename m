Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 364926B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 10:46:31 -0400 (EDT)
Date: Wed, 1 Jun 2011 09:46:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
In-Reply-To: <alpine.DEB.2.00.1106010910430.22901@router.home>
Message-ID: <alpine.DEB.2.00.1106010945010.22901@router.home>
References: <20110516202605.274023469@linux.com>  <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com>  <alpine.DEB.2.00.1105261315350.26578@router.home>  <4DDE9C01.2090104@zytor.com>  <alpine.DEB.2.00.1105261615130.591@router.home>
 <1306445159.2543.25.camel@edumazet-laptop> <alpine.DEB.2.00.1105311012420.18755@router.home> <4DE50632.90906@zytor.com> <alpine.DEB.2.00.1105311058030.19928@router.home> <4DE576EA.6070906@zytor.com> <alpine.DEB.2.00.1105311846230.31190@router.home>
 <4DE57FBB.8040408@zytor.com> <alpine.DEB.2.00.1106010910430.22901@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

Ok newest rev. Fixed the 32 bit issues.


Subject: x86: Add support for cmpxchg_double

A simple implementation that only supports the word size and does not
have a fallback mode (would require a spinlock).

Add 32 and 64 bit support for cmpxchg_double. cmpxchg double uses
the cmpxchg8b or cmpxchg16b instruction on x86 processors to compare
and swap 2 machine words. This allows lockless algorithms to move more
context information through critical sections.

Set a flag CONFIG_CMPXCHG_DOUBLE to signal that support for double word
cmpxchg detection has been build into the kernel. Note that each subsystem
using cmpxchg_double has to implement a fall back mechanism as long as
we offer support for processors that do not implement cmpxchg_double.
Also various non x86 architectures do not support double cmpxchg and will
require the fallback code.

Cc: tj@kernel.org
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 arch/x86/Kconfig.cpu              |   10 +++++++
 arch/x86/include/asm/cmpxchg_32.h |   48 ++++++++++++++++++++++++++++++++++++++
 arch/x86/include/asm/cmpxchg_64.h |   45 +++++++++++++++++++++++++++++++++++
 arch/x86/include/asm/cpufeature.h |    2 +
 4 files changed, 105 insertions(+)

Index: linux-2.6/arch/x86/include/asm/cmpxchg_64.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/cmpxchg_64.h	2011-06-01 09:23:08.822443732 -0500
+++ linux-2.6/arch/x86/include/asm/cmpxchg_64.h	2011-06-01 09:25:40.832442760 -0500
@@ -151,4 +151,49 @@ extern void __cmpxchg_wrong_size(void);
 	cmpxchg_local((ptr), (o), (n));					\
 })

+#define cmpxchg16b(ptr, o1, o2, n1, n2)				\
+({								\
+	char __ret;						\
+	__typeof__(o2) __junk;					\
+	__typeof__(*(ptr)) __old1 = (o1);			\
+	__typeof__(o2) __old2 = (o2);				\
+	__typeof__(*(ptr)) __new1 = (n1);			\
+	__typeof__(o2) __new2 = (n2);				\
+	asm volatile(LOCK_PREFIX "cmpxchg16b %2;setz %1"	\
+		       : "=d"(__junk), "=a"(__ret), "+m" (*ptr)	\
+		       : "b"(__new1), "c"(__new2),		\
+		         "a"(__old1), "d"(__old2));		\
+	__ret; })
+
+
+#define cmpxchg16b_local(ptr, o1, o2, n1, n2)			\
+({								\
+	char __ret;						\
+	__typeof__(o2) __junk;					\
+	__typeof__(*(ptr)) __old1 = (o1);			\
+	__typeof__(o2) __old2 = (o2);				\
+	__typeof__(*(ptr)) __new1 = (n1);			\
+	__typeof__(o2) __new2 = (n2);				\
+	asm volatile("cmpxchg16b %2;setz %1"			\
+		       : "=d"(__junk), "=a"(__ret), "+m" (*ptr)	\
+		       : "b"(__new1), "c"(__new2),		\
+ 		         "a"(__old1), "d"(__old2));		\
+	__ret; })
+
+#define cmpxchg_double(ptr, o1, o2, n1, n2)				\
+({									\
+	BUILD_BUG_ON(sizeof(*(ptr)) != 8);				\
+	VM_BUG_ON((unsigned long)(ptr) % 16);				\
+	cmpxchg16b((ptr), (o1), (o2), (n1), (n2));			\
+})
+
+#define cmpxchg_double_local(ptr, o1, o2, n1, n2)			\
+({									\
+	BUILD_BUG_ON(sizeof(*(ptr)) != 8);				\
+	VM_BUG_ON((unsigned long)(ptr) % 16);				\
+	cmpxchg16b_local((ptr), (o1), (o2), (n1), (n2));		\
+})
+
+#define system_has_cmpxchg_double() cpu_has_cx16
+
 #endif /* _ASM_X86_CMPXCHG_64_H */
Index: linux-2.6/arch/x86/include/asm/cmpxchg_32.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/cmpxchg_32.h	2011-06-01 09:23:08.842443735 -0500
+++ linux-2.6/arch/x86/include/asm/cmpxchg_32.h	2011-06-01 09:32:53.072439992 -0500
@@ -280,4 +280,52 @@ static inline unsigned long cmpxchg_386(

 #endif

+#define cmpxchg8b(ptr, o1, o2, n1, n2)				\
+({								\
+	char __ret;						\
+	__typeof__(o2) __dummy;					\
+	__typeof__(*(ptr)) __old1 = (o1);			\
+	__typeof__(o2) __old2 = (o2);				\
+	__typeof__(*(ptr)) __new1 = (n1);			\
+	__typeof__(o2) __new2 = (n2);				\
+	asm volatile(LOCK_PREFIX "cmpxchg8b %2; setz %1"	\
+		       : "=d"(__dummy), "=a" (__ret), "+m" (*ptr)\
+		       : "a" (__old1), "d"(__old2),		\
+		         "b" (__new1), "c" (__new2)		\
+		       : "memory");				\
+	__ret; })
+
+
+#define cmpxchg8b_local(ptr, o1, o2, n1, n2)			\
+({								\
+	char __ret;						\
+	__typeof__(o2) __dummy;					\
+	__typeof__(*(ptr)) __old1 = (o1);			\
+	__typeof__(o2) __old2 = (o2);				\
+	__typeof__(*(ptr)) __new1 = (n1);			\
+	__typeof__(o2) __new2 = (n2);				\
+	asm volatile("cmpxchg8b %2; setz %1"			\
+		       : "=d"(__dummy), "=a"(__ret), "m+" (*ptr)\
+		       : "a" (__old), "d"(__old2),		\
+		         "b" (__new1), "c" (__new2),		\
+		       : "memory");				\
+	__ret; })
+
+
+#define cmpxchg_double(ptr, o1, o2, n1, n2)				\
+({									\
+	BUILD_BUG_ON(sizeof(*(ptr)) != 4);				\
+	VM_BUG_ON((unsigned long)(ptr) % 8);				\
+	cmpxchg8b((ptr), (o1), (o2), (n1), (n2));			\
+})
+
+#define cmpxchg_double_local(ptr, o1, o2, n1, n2)			\
+({									\
+       BUILD_BUG_ON(sizeof(*(ptr)) != 4);				\
+       VM_BUG_ON((unsigned long)(ptr) % 8);				\
+       cmpxchg16b_local((ptr), (o1), (o2), (n1), (n2));			\
+})
+
+#define system_has_cmpxchg_double() cpu_has_cx8
+
 #endif /* _ASM_X86_CMPXCHG_32_H */
Index: linux-2.6/arch/x86/Kconfig.cpu
===================================================================
--- linux-2.6.orig/arch/x86/Kconfig.cpu	2011-06-01 09:23:08.862443735 -0500
+++ linux-2.6/arch/x86/Kconfig.cpu	2011-06-01 09:25:40.842442760 -0500
@@ -312,6 +312,16 @@ config X86_CMPXCHG
 config CMPXCHG_LOCAL
 	def_bool X86_64 || (X86_32 && !M386)

+#
+# CMPXCHG_DOUBLE needs to be set to enable the kernel to use cmpxchg16/8b
+# for cmpxchg_double if it find processor flags that indicate that the
+# capabilities are available. CMPXCHG_DOUBLE only compiles in
+# detection support. It needs to be set if there is a chance that processor
+# supports these instructions.
+#
+config CMPXCHG_DOUBLE
+	def_bool GENERIC_CPU || X86_GENERIC || !M386
+
 config X86_L1_CACHE_SHIFT
 	int
 	default "7" if MPENTIUM4 || MPSC
Index: linux-2.6/arch/x86/include/asm/cpufeature.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/cpufeature.h	2011-06-01 09:23:08.832443731 -0500
+++ linux-2.6/arch/x86/include/asm/cpufeature.h	2011-06-01 09:38:25.012437868 -0500
@@ -288,6 +288,8 @@ extern const char * const x86_power_flag
 #define cpu_has_hypervisor	boot_cpu_has(X86_FEATURE_HYPERVISOR)
 #define cpu_has_pclmulqdq	boot_cpu_has(X86_FEATURE_PCLMULQDQ)
 #define cpu_has_perfctr_core	boot_cpu_has(X86_FEATURE_PERFCTR_CORE)
+#define cpu_has_cx8		boot_cpu_has(X86_FEATURE_CX8)
+#define cpu_has_cx16		boot_cpu_has(X86_FEATURE_CX16)

 #if defined(CONFIG_X86_INVLPG) || defined(CONFIG_X86_64)
 # define cpu_has_invlpg		1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
