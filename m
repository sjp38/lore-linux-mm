Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id C594F6B0068
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 08:48:53 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 6/6] x86: switch the 64bit uncached page clear to SSE/AVX v2
Date: Fri, 20 Jul 2012 15:50:22 +0300
Message-Id: <1342788622-10290-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

With multiple threads vector stores are more efficient, so use them.
This will cause the page clear to run non preemptable and add some
overhead. However on 32bit it was already non preempable (due to
kmap_atomic) and there is an preemption opportunity every 4K unit.

On a NPB (Nasa Parallel Benchmark) 128GB run on a Westmere this improves
the performance regression of enabling transparent huge pages
by ~2% (2.81% to 0.81%), near the runtime variability now.
On a system with AVX support more is expected.

TBD more tests on other workloads

Signed-off-by: Andi Kleen <ak@linux.intel.com>
[kirill.shutemov@linux.intel.com: Properly save/restore arguments]
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/lib/clear_page_nocache_64.S |   91 ++++++++++++++++++++++++++++-----
 1 files changed, 77 insertions(+), 14 deletions(-)

diff --git a/arch/x86/lib/clear_page_nocache_64.S b/arch/x86/lib/clear_page_nocache_64.S
index ee16d15..c092919 100644
--- a/arch/x86/lib/clear_page_nocache_64.S
+++ b/arch/x86/lib/clear_page_nocache_64.S
@@ -1,29 +1,92 @@
+/*
+ * Clear pages with cache bypass.
+ * 
+ * Copyright (C) 2011, 2012 Intel Corporation
+ * Author: Andi Kleen
+ *
+ * This software may be redistributed and/or modified under the terms of
+ * the GNU General Public License ("GPL") version 2 only as published by the
+ * Free Software Foundation.
+ */
+
 #include <linux/linkage.h>
+#include <asm/alternative-asm.h>
+#include <asm/cpufeature.h>
 #include <asm/dwarf2.h>
 
+#define SSE_UNROLL 128
+
 /*
  * Zero a page avoiding the caches
  * rdi	page
  */
 ENTRY(clear_page_nocache)
 	CFI_STARTPROC
-	xorl   %eax,%eax
-	movl   $4096/64,%ecx
+	push   %rdi
+	call   kernel_fpu_begin
+	pop    %rdi
+	sub    $16,%rsp
+	CFI_ADJUST_CFA_OFFSET 16
+	movdqu %xmm0,(%rsp)
+	xorpd  %xmm0,%xmm0
+	movl   $4096/SSE_UNROLL,%ecx
 	.p2align 4
 .Lloop:
 	decl	%ecx
-#define PUT(x) movnti %rax,x*8(%rdi)
-	movnti %rax,(%rdi)
-	PUT(1)
-	PUT(2)
-	PUT(3)
-	PUT(4)
-	PUT(5)
-	PUT(6)
-	PUT(7)
-	leaq	64(%rdi),%rdi
+	.set x,0
+	.rept SSE_UNROLL/16
+	movntdq %xmm0,x(%rdi)
+	.set x,x+16
+	.endr
+	leaq	SSE_UNROLL(%rdi),%rdi
 	jnz	.Lloop
-	nop
-	ret
+	movdqu (%rsp),%xmm0
+	addq   $16,%rsp
+	CFI_ADJUST_CFA_OFFSET -16
+	jmp   kernel_fpu_end
 	CFI_ENDPROC
 ENDPROC(clear_page_nocache)
+
+#ifdef CONFIG_AS_AVX
+
+	.section .altinstr_replacement,"ax"
+1:	.byte 0xeb					/* jmp <disp8> */
+	.byte (clear_page_nocache_avx - clear_page_nocache) - (2f - 1b)
+	/* offset */
+2:
+	.previous
+	.section .altinstructions,"a"
+	altinstruction_entry clear_page_nocache,1b,X86_FEATURE_AVX,\
+	                     16, 2b-1b
+	.previous
+
+#define AVX_UNROLL 256 /* TUNE ME */
+
+ENTRY(clear_page_nocache_avx)
+	CFI_STARTPROC
+	push   %rdi
+	call   kernel_fpu_begin
+	pop    %rdi
+	sub    $32,%rsp
+	CFI_ADJUST_CFA_OFFSET 32
+	vmovdqu %ymm0,(%rsp)
+	vxorpd  %ymm0,%ymm0,%ymm0
+	movl   $4096/AVX_UNROLL,%ecx
+	.p2align 4
+.Lloop_avx:
+	decl	%ecx
+	.set x,0
+	.rept AVX_UNROLL/32
+	vmovntdq %ymm0,x(%rdi)
+	.set x,x+32
+	.endr
+	leaq	AVX_UNROLL(%rdi),%rdi
+	jnz	.Lloop_avx
+	vmovdqu (%rsp),%ymm0
+	addq   $32,%rsp
+	CFI_ADJUST_CFA_OFFSET -32
+	jmp   kernel_fpu_end
+	CFI_ENDPROC
+ENDPROC(clear_page_nocache_avx)
+
+#endif
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
