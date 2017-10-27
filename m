Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF34B6B0253
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 16:27:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e64so5641599pfk.0
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 13:27:30 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f79si5904189pfh.296.2017.10.27.13.27.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 13:27:29 -0700 (PDT)
From: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
Subject: [PATCH v10 02/18] x86/boot: Relocate definition of the initial state of CR0
Date: Fri, 27 Oct 2017 13:25:29 -0700
Message-Id: <1509135945-13762-3-git-send-email-ricardo.neri-calderon@linux.intel.com>
In-Reply-To: <1509135945-13762-1-git-send-email-ricardo.neri-calderon@linux.intel.com>
References: <1509135945-13762-1-git-send-email-ricardo.neri-calderon@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Masami Hiramatsu <mhiramat@kernel.org>, Huang Rui <ray.huang@amd.com>, Jiri Slaby <jslaby@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Vlastimil Babka <vbabka@suse.cz>, Chen Yucong <slaoub@gmail.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Shuah Khan <shuah@kernel.org>, linux-kernel@vger.kernel.org, x86@kernel.org, ricardo.neri@intel.com, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org

Both head_32.S and head_64.S utilize the same value to initialize the
control register CR0. Also, other parts of the kernel might want to access
this initial definition (e.g., emulation code for User-Mode Instruction
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
Reviewed-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
---
 arch/x86/include/uapi/asm/processor-flags.h | 3 +++
 arch/x86/kernel/head_32.S                   | 3 ---
 arch/x86/kernel/head_64.S                   | 3 ---
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/uapi/asm/processor-flags.h b/arch/x86/include/uapi/asm/processor-flags.h
index 185f3d1..39946d0 100644
--- a/arch/x86/include/uapi/asm/processor-flags.h
+++ b/arch/x86/include/uapi/asm/processor-flags.h
@@ -151,5 +151,8 @@
 #define CX86_ARR_BASE	0xc4
 #define CX86_RCR_BASE	0xdc
 
+#define CR0_STATE	(X86_CR0_PE | X86_CR0_MP | X86_CR0_ET | \
+			 X86_CR0_NE | X86_CR0_WP | X86_CR0_AM | \
+			 X86_CR0_PG)
 
 #endif /* _UAPI_ASM_X86_PROCESSOR_FLAGS_H */
diff --git a/arch/x86/kernel/head_32.S b/arch/x86/kernel/head_32.S
index 9ed3074..c3cfc65 100644
--- a/arch/x86/kernel/head_32.S
+++ b/arch/x86/kernel/head_32.S
@@ -211,9 +211,6 @@ ENTRY(startup_32_smp)
 #endif
 
 .Ldefault_entry:
-#define CR0_STATE	(X86_CR0_PE | X86_CR0_MP | X86_CR0_ET | \
-			 X86_CR0_NE | X86_CR0_WP | X86_CR0_AM | \
-			 X86_CR0_PG)
 	movl $(CR0_STATE & ~X86_CR0_PG),%eax
 	movl %eax,%cr0
 
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 99b1262..701f3d9 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -153,9 +153,6 @@ ENTRY(secondary_startup_64)
 1:	wrmsr				/* Make changes effective */
 
 	/* Setup cr0 */
-#define CR0_STATE	(X86_CR0_PE | X86_CR0_MP | X86_CR0_ET | \
-			 X86_CR0_NE | X86_CR0_WP | X86_CR0_AM | \
-			 X86_CR0_PG)
 	movl	$CR0_STATE, %eax
 	/* Make changes effective */
 	movq	%rax, %cr0
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
