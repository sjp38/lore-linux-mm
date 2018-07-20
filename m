Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 183C36B000C
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:22:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w10-v6so4902009eds.7
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 09:22:42 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 5-v6si1931338edo.397.2018.07.20.09.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 09:22:40 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 2/3] x86/entry/32: Check for VM86 mode in slow-path check
Date: Fri, 20 Jul 2018 18:22:23 +0200
Message-Id: <1532103744-31902-3-git-send-email-joro@8bytes.org>
In-Reply-To: <1532103744-31902-1-git-send-email-joro@8bytes.org>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The SWITCH_TO_KERNEL_STACK macro only checks for CPL == 0 to
go down the slow and paranoid entry path. The problem is
that this check also returns true when coming from VM86
mode. This is not a problem by itself, as the paranoid path
handles VM86 stack-frames just fine, but it is not necessary
as the normal code path handles VM86 mode as well (and
faster).

Extend the check to include VM86 mode. This also makes an
optimization of the paranoid path possible.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 010cdb4..2767c62 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -414,8 +414,16 @@
 	andl	$(0x0000ffff), PT_CS(%esp)
 
 	/* Special case - entry from kernel mode via entry stack */
-	testl	$SEGMENT_RPL_MASK, PT_CS(%esp)
-	jz	.Lentry_from_kernel_\@
+#ifdef CONFIG_VM86
+	movl	PT_EFLAGS(%esp), %ecx		# mix EFLAGS and CS
+	movb	PT_CS(%esp), %cl
+	andl	$(X86_EFLAGS_VM | SEGMENT_RPL_MASK), %ecx
+#else
+	movl	PT_CS(%esp), %ecx
+	andl	$SEGMENT_RPL_MASK, %ecx
+#endif
+	cmpl	$USER_RPL, %ecx
+	jb	.Lentry_from_kernel_\@
 
 	/* Bytes to copy */
 	movl	$PTREGS_SIZE, %ecx
-- 
2.7.4
