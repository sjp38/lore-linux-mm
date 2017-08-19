Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4706B04BB
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 20:28:38 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q6so88248374pgs.7
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 17:28:38 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j12si1033740pgf.729.2017.08.18.17.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 17:28:36 -0700 (PDT)
From: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
Subject: [PATCH v8 02/28] x86/boot: Relocate definition of the initial state of CR0
Date: Fri, 18 Aug 2017 17:27:43 -0700
Message-Id: <20170819002809.111312-3-ricardo.neri-calderon@linux.intel.com>
In-Reply-To: <20170819002809.111312-1-ricardo.neri-calderon@linux.intel.com>
References: <20170819002809.111312-1-ricardo.neri-calderon@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Liang Z Li <liang.z.li@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>, Huang Rui <ray.huang@amd.com>, Jiri Slaby <jslaby@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Vlastimil Babka <vbabka@suse.cz>, Chen Yucong <slaoub@gmail.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Shuah Khan <shuah@kernel.org>, linux-kernel@vger.kernel.org, x86@kernel.org, ricardo.neri@intel.com, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org

Both head_32.S and head_64.S utilize the same value to initialize the
control register CR0. Also, other parts of the kernel might want to access
to this initial definition (e.g., emulation code for User-Mode Instruction
Prevention uses this state to provide a sane dummy value for CR0 when
emulating the smsw instruction). Thus, relocate this definition to a
header file from which it can be conveniently accessed.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Suggested-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
---
 arch/x86/include/uapi/asm/processor-flags.h | 6 ++++++
 arch/x86/kernel/head_32.S                   | 3 ---
 arch/x86/kernel/head_64.S                   | 3 ---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/uapi/asm/processor-flags.h b/arch/x86/include/uapi/asm/processor-flags.h
index 185f3d10c194..aae1f2aa7563 100644
--- a/arch/x86/include/uapi/asm/processor-flags.h
+++ b/arch/x86/include/uapi/asm/processor-flags.h
@@ -151,5 +151,11 @@
 #define CX86_ARR_BASE	0xc4
 #define CX86_RCR_BASE	0xdc
 
+/*
+ * Initial state of CR0 for head_32/64.S
+ */
+#define CR0_STATE	(X86_CR0_PE | X86_CR0_MP | X86_CR0_ET | \
+			 X86_CR0_NE | X86_CR0_WP | X86_CR0_AM | \
+			 X86_CR0_PG)
 
 #endif /* _UAPI_ASM_X86_PROCESSOR_FLAGS_H */
diff --git a/arch/x86/kernel/head_32.S b/arch/x86/kernel/head_32.S
index 0332664eb158..f64059835863 100644
--- a/arch/x86/kernel/head_32.S
+++ b/arch/x86/kernel/head_32.S
@@ -213,9 +213,6 @@ ENTRY(startup_32_smp)
 #endif
 
 .Ldefault_entry:
-#define CR0_STATE	(X86_CR0_PE | X86_CR0_MP | X86_CR0_ET | \
-			 X86_CR0_NE | X86_CR0_WP | X86_CR0_AM | \
-			 X86_CR0_PG)
 	movl $(CR0_STATE & ~X86_CR0_PG),%eax
 	movl %eax,%cr0
 
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 513cbb012ecc..5e1bfdd86b5b 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -149,9 +149,6 @@ ENTRY(secondary_startup_64)
 1:	wrmsr				/* Make changes effective */
 
 	/* Setup cr0 */
-#define CR0_STATE	(X86_CR0_PE | X86_CR0_MP | X86_CR0_ET | \
-			 X86_CR0_NE | X86_CR0_WP | X86_CR0_AM | \
-			 X86_CR0_PG)
 	movl	$CR0_STATE, %eax
 	/* Make changes effective */
 	movq	%rax, %cr0
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
