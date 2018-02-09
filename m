Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2C1B6B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 04:27:20 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 17so988499wma.1
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 01:27:20 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id o1si1542637edd.346.2018.02.09.01.25.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 01:25:57 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 05/31] x86/entry/32: Unshare NMI return path
Date: Fri,  9 Feb 2018 10:25:14 +0100
Message-Id: <1518168340-9392-6-git-send-email-joro@8bytes.org>
In-Reply-To: <1518168340-9392-1-git-send-email-joro@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

NMI will no longer use most of the shared return path,
because NMI needs special handling when the CR3 switches for
PTI are added. This patch prepares for that.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 0289bde..00ae759 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -1007,7 +1007,7 @@ ENTRY(nmi)
 
 	/* Not on SYSENTER stack. */
 	call	do_nmi
-	jmp	.Lrestore_all_notrace
+	jmp	.Lnmi_return
 
 .Lnmi_from_sysenter_stack:
 	/*
@@ -1018,7 +1018,11 @@ ENTRY(nmi)
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
