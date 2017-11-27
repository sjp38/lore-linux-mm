Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAE166B025E
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:35:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id k84so18100903pfj.18
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:35:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q25si4141527pge.487.2017.11.27.14.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 14:35:46 -0800 (PST)
Message-Id: <20171127223405.381212307@infradead.org>
Date: Mon, 27 Nov 2017 23:31:15 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 5/5] x86/mm/kaiser: Disable the SYSCALL-64 trampoline along with KAISER
References: <20171127223110.479550152@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-kaiser-disable-syscall-trampoline.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

If we don't use KAISER we don't need the trampoline, use the old entry
code.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/kernel/cpu/common.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1442,7 +1442,10 @@ void syscall_init(void)
 		(entry_SYSCALL_64_trampoline - _entry_trampoline);
 
 	wrmsr(MSR_STAR, 0, (__USER32_CS << 16) | __KERNEL_CS);
-	wrmsrl(MSR_LSTAR, SYSCALL64_entry_trampoline);
+	if (kaiser_enabled)
+		wrmsrl(MSR_LSTAR, SYSCALL64_entry_trampoline);
+	else
+		wrmsrl(MSR_LSTAR, (unsigned long)entry_SYSCALL_64);
 
 #ifdef CONFIG_IA32_EMULATION
 	wrmsrl(MSR_CSTAR, (unsigned long)entry_SYSCALL_compat);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
