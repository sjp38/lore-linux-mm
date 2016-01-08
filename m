Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id C206F828E9
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:51 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 65so15917253pff.2
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:51 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id v23si7928826pfi.58.2016.01.08.15.15.51
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:51 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 11/13] x86/mm: Build arch/x86/mm/tlb.c even on !SMP
Date: Fri,  8 Jan 2016 15:15:29 -0800
Message-Id: <a6eab8f94f1c6e0134246e4a21aa8af1cb7155fd.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

Currently all of the functions that live in tlb.c are inlined on
!SMP builds.  One can debate whether this is a good idea (in many
respects the code in tlb.c is better than the inlined UP code).

Regardless, I want to add code that needs to be built on UP and SMP
kernels and relates to tlb flushing, so arrange for tlb.c to be
compiled unconditionally.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/mm/Makefile | 3 +--
 arch/x86/mm/tlb.c    | 4 ++++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 65c47fda26fc..1ae7c141f778 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -1,5 +1,5 @@
 obj-y	:=  init.o init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o \
-	    pat.o pgtable.o physaddr.o gup.o setup_nx.o
+	    pat.o pgtable.o physaddr.o gup.o setup_nx.o tlb.o
 
 # Make sure __phys_addr has no stackprotector
 nostackp := $(call cc-option, -fno-stack-protector)
@@ -9,7 +9,6 @@ CFLAGS_setup_nx.o		:= $(nostackp)
 CFLAGS_fault.o := -I$(src)/../include/asm/trace
 
 obj-$(CONFIG_X86_PAT)		+= pat_rbtree.o
-obj-$(CONFIG_SMP)		+= tlb.o
 
 obj-$(CONFIG_X86_32)		+= pgtable_32.o iomap_32.o
 
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index b208a33571b0..87fcc7a62e71 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -28,6 +28,8 @@
  *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
  */
 
+#ifdef CONFIG_SMP
+
 struct flush_tlb_info {
 	struct mm_struct *flush_mm;
 	unsigned long flush_start;
@@ -352,3 +354,5 @@ static int __init create_tlb_single_page_flush_ceiling(void)
 	return 0;
 }
 late_initcall(create_tlb_single_page_flush_ceiling);
+
+#endif /* CONFIG_SMP */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
