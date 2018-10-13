Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E809C6B0003
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 05:55:14 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id j90-v6so10444665wrj.20
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 02:55:14 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.15.4])
        by mx.google.com with ESMTPS id m66-v6si3144592wmm.192.2018.10.13.02.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Oct 2018 02:55:13 -0700 (PDT)
Subject: [PATCH] x86/entry/32: Fix setup of CS high bits
From: Jan Kiszka <jan.kiszka@web.de>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
 <1531906876-13451-11-git-send-email-joro@8bytes.org>
 <97421241-2bc4-c3f1-4128-95b3e8a230d1@siemens.com>
Message-ID: <35a24feb-5970-aa03-acbf-53428a159ace@web.de>
Date: Sat, 13 Oct 2018 11:54:54 +0200
MIME-Version: 1.0
In-Reply-To: <97421241-2bc4-c3f1-4128-95b3e8a230d1@siemens.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>

From: Jan Kiszka <jan.kiszka@siemens.com>

Even if we are not on an entry stack, we have to initialize the CS high
bits because we are unconditionally evaluating them
PARANOID_EXIT_TO_KERNEL_MODE. Failing to do so broke the boot on Galileo
Gen2 and IOT2000 boards.

Fixes: b92a165df17e ("x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack")
Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 arch/x86/entry/entry_32.S | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 2767c625a52c..95c94d48ecd2 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -389,6 +389,12 @@
 	 * that register for the time this macro runs
 	 */
 
+	/*
+	 * Clear unused upper bits of the dword containing the word-sized CS
+	 * slot in pt_regs in case hardware didn't clear it for us.
+	 */
+	andl	$(0x0000ffff), PT_CS(%esp)
+
 	/* Are we on the entry stack? Bail out if not! */
 	movl	PER_CPU_VAR(cpu_entry_area), %ecx
 	addl	$CPU_ENTRY_AREA_entry_stack + SIZEOF_entry_stack, %ecx
@@ -407,12 +413,6 @@
 	/* Load top of task-stack into %edi */
 	movl	TSS_entry2task_stack(%edi), %edi
 
-	/*
-	 * Clear unused upper bits of the dword containing the word-sized CS
-	 * slot in pt_regs in case hardware didn't clear it for us.
-	 */
-	andl	$(0x0000ffff), PT_CS(%esp)
-
 	/* Special case - entry from kernel mode via entry stack */
 #ifdef CONFIG_VM86
 	movl	PT_EFLAGS(%esp), %ecx		# mix EFLAGS and CS
-- 
2.16.4
