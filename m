Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B248F6B026E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:41:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y17-v6so1681018eds.22
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 02:41:25 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id z22-v6si3650099edi.394.2018.07.18.02.41.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 02:41:24 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 05/39] x86/entry/32: Unshare NMI return path
Date: Wed, 18 Jul 2018 11:40:42 +0200
Message-Id: <1531906876-13451-6-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

NMI will no longer use most of the shared return path,
because NMI needs special handling when the CR3 switches for
PTI are added. This patch prepares for that.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index ef7d653..4364131 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -1017,7 +1017,7 @@ ENTRY(nmi)
 
 	/* Not on SYSENTER stack. */
 	call	do_nmi
-	jmp	.Lrestore_all_notrace
+	jmp	.Lnmi_return
 
 .Lnmi_from_sysenter_stack:
 	/*
@@ -1028,7 +1028,11 @@ ENTRY(nmi)
 	movl	PER_CPU_VAR(cpu_current_top_of_stack), %esp
 	call	do_nmi
 	movl	%ebx, %esp
-	jmp	.Lrestore_all_notrace
+
+.Lnmi_return:
+	CHECK_AND_APPLY_ESPFIX
+	RESTORE_REGS 4
+	jmp	.Lirq_return
 
 #ifdef CONFIG_X86_ESPFIX32
 .Lnmi_espfix_stack:
-- 
2.7.4
