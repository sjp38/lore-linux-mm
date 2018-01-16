Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id D80F46B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:28:27 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id v26so1254195uaj.19
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:28:27 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id i5si1312103edc.211.2018.01.16.08.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 08:39:23 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 15/16] x86/entry/32: Switch between kernel and user cr3 on entry/exit
Date: Tue, 16 Jan 2018 17:36:58 +0100
Message-Id: <1516120619-1159-16-git-send-email-joro@8bytes.org>
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Add the cr3 switches between the kernel and the user
page-table when PTI is enabled.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 14018eeb11c3..6a1d9f1e1f89 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -221,6 +221,25 @@
 	POP_GS_EX
 .endm
 
+#define PTI_SWITCH_MASK         (1 << PAGE_SHIFT)
+
+.macro SWITCH_TO_KERNEL_CR3
+        ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
+        movl    %cr3, %edi
+        andl    $(~PTI_SWITCH_MASK), %edi
+        movl    %edi, %cr3
+.Lend_\@:
+.endm
+
+.macro SWITCH_TO_USER_CR3
+        ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
+        mov     %cr3, %edi
+        /* Flip the PGD to the user version */
+        orl     $(PTI_SWITCH_MASK), %edi
+        mov     %edi, %cr3
+.Lend_\@:
+.endm
+
 /*
  * Switch from the entry-trampline stack to the kernel stack of the
  * running task.
@@ -240,6 +259,7 @@
 	.endif
 
 	pushl %edi
+	SWITCH_TO_KERNEL_CR3
 	movl  %esp, %edi
 
 	/*
@@ -309,9 +329,12 @@
 	.endif
 
 	pushl 4(%edi)   /* fs */
+	pushl  (%edi)   /* edi */
+
+	SWITCH_TO_USER_CR3
 	
 	/* Restore user %edi and user %fs */
-	movl (%edi), %edi
+	popl %edi
 	popl %fs
 
 .Lend_\@:
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
