Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6D16B0006
	for <linux-mm@kvack.org>; Sat, 20 Oct 2018 19:53:00 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d63-v6so27478044pld.18
        for <linux-mm@kvack.org>; Sat, 20 Oct 2018 16:53:00 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-oln040092070081.outbound.protection.outlook.com. [40.92.70.81])
        by mx.google.com with ESMTPS id q10-v6si31463843pli.202.2018.10.20.16.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 20 Oct 2018 16:52:58 -0700 (PDT)
From: Shayan Doust <shayan.doust@outlook.com>
Subject: [PATCH 06/10] x86/entry/32: Clear the CS high bits
Date: Sat, 20 Oct 2018 23:52:54 +0000
Message-ID: <AM2PR08MB01951A14AFA4335905FA464287FA0@AM2PR08MB0195.eurprd08.prod.outlook.com>
References: <20181020235230.37324-1-shayan.doust@outlook.com>
In-Reply-To: <20181020235230.37324-1-shayan.doust@outlook.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hello@shayandoust.me" <hello@shayandoust.me>
Cc: Jan Kiszka <jan.kiszka@siemens.com>, Borislav Petkov <bp@suse.de>, "H.
 Peter Anvin" <hpa@zytor.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy
 Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, David
 Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@kernel.org>, Jiri Kosina <jkosina@suse.cz>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, "aliguori@amazon.com" <aliguori@amazon.com>, "daniel.gruss@iaik.tugraz.at" <daniel.gruss@iaik.tugraz.at>, "hughd@google.com" <hughd@google.com>, "keescook@google.com" <keescook@google.com>, linux-mm <linux-mm@kvack.org>, x86-ml <x86@kernel.org>

From: Jan Kiszka <jan.kiszka@siemens.com>

Even if not on an entry stack, the CS's high bits must be
initialized because they are unconditionally evaluated in
PARANOID_EXIT_TO_KERNEL_MODE.

Failing to do so broke the boot on Galileo Gen2 and IOT2000 boards.

 [ bp: Make the commit message tone passive and impartial. ]

Fixes: b92a165df17e ("x86/entry/32: Handle Entry from Kernel-Mode on Entry-=
Stack")
Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Joerg Roedel <jroedel@suse.de>
Acked-by: Joerg Roedel <jroedel@suse.de>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: Andrea Arcangeli <aarcange@redhat.com>
CC: Andy Lutomirski <luto@kernel.org>
CC: Boris Ostrovsky <boris.ostrovsky@oracle.com>
CC: Brian Gerst <brgerst@gmail.com>
CC: Dave Hansen <dave.hansen@intel.com>
CC: David Laight <David.Laight@aculab.com>
CC: Denys Vlasenko <dvlasenk@redhat.com>
CC: Eduardo Valentin <eduval@amazon.com>
CC: Greg KH <gregkh@linuxfoundation.org>
CC: Ingo Molnar <mingo@kernel.org>
CC: Jiri Kosina <jkosina@suse.cz>
CC: Josh Poimboeuf <jpoimboe@redhat.com>
CC: Juergen Gross <jgross@suse.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Will Deacon <will.deacon@arm.com>
CC: aliguori@amazon.com
CC: daniel.gruss@iaik.tugraz.at
CC: hughd@google.com
CC: keescook@google.com
CC: linux-mm <linux-mm@kvack.org>
CC: x86-ml <x86@kernel.org>
Link: http://lkml.kernel.org/r/f271c747-1714-5a5b-a71f-ae189a093b8d@siemens=
.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/entry/entry_32.S | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 2767c625a52c..fbbf1ba57ec6 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -389,6 +389,13 @@
 	 * that register for the time this macro runs
 	 */
=20
+	/*
+	 * The high bits of the CS dword (__csh) are used for
+	 * CS_FROM_ENTRY_STACK and CS_FROM_USER_CR3. Clear them in case
+	 * hardware didn't do this for us.
+	 */
+	andl	$(0x0000ffff), PT_CS(%esp)
+
 	/* Are we on the entry stack? Bail out if not! */
 	movl	PER_CPU_VAR(cpu_entry_area), %ecx
 	addl	$CPU_ENTRY_AREA_entry_stack + SIZEOF_entry_stack, %ecx
@@ -407,12 +414,6 @@
 	/* Load top of task-stack into %edi */
 	movl	TSS_entry2task_stack(%edi), %edi
=20
-	/*
-	 * Clear unused upper bits of the dword containing the word-sized CS
-	 * slot in pt_regs in case hardware didn't clear it for us.
-	 */
-	andl	$(0x0000ffff), PT_CS(%esp)
-
 	/* Special case - entry from kernel mode via entry stack */
 #ifdef CONFIG_VM86
 	movl	PT_EFLAGS(%esp), %ecx		# mix EFLAGS and CS
--=20
2.17.1
