Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BEBF6B0343
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:59:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c23so316666500pfj.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 08:59:14 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0105.outbound.protection.outlook.com. [104.47.2.105])
        by mx.google.com with ESMTPS id n8si21652251pgd.294.2017.03.21.08.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 08:59:12 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCH] x86/mm: set x32 syscall bit in SET_PERSONALITY()
Date: Tue, 21 Mar 2017 18:55:25 +0300
Message-ID: <20170321155525.12220-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

After my changes to mmap(), its code now relies on the bitness of
performing syscall. According to that, it chooses the base of allocation:
mmap_base for 64-bit mmap() and mmap_compat_base for 32-bit syscall.
It was done by:
  commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
32-bit mmap()").

The code afterwards relies on in_compat_syscall() returning true for
32-bit syscalls. It's usually so while we're in context of application
that does 32-bit syscalls. But during exec() it is not valid for x32 ELF.
The reason is that the application hasn't yet done any syscall, so x32
bit has not being set.
For i386 ELFs it works as SET_PERSONALITY() sets TS_COMPAT flag.

I suggest to set x32 bit before first return to userspace, during
setting personality at exec(). This way we can rely on
in_compat_syscall() during exec().

Fixes: commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
32-bit mmap()")
Cc: 0x7f454c46@gmail.com
Cc: linux-mm@kvack.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: x86@kernel.org
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Reported-by: Adam Borowski <kilobyte@angband.pl>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/kernel/process_64.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index d6b784a5520d..88d99d35a699 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -520,7 +520,12 @@ void set_personality_ia32(bool x32)
 			current->mm->context.ia32_compat = TIF_X32;
 		current->personality &= ~READ_IMPLIES_EXEC;
 		/* in_compat_syscall() uses the presence of the x32
-		   syscall bit flag to determine compat status */
+		   syscall bit flag to determine compat status.
+		   On the bitness of syscall relies x86 mmap() code,
+		   so set x32 syscall bit right here to make
+		   in_compat_syscall() work during exec().
+		 */
+		task_pt_regs(current)->orig_ax |= __X32_SYSCALL_BIT;
 		current->thread.status &= ~TS_COMPAT;
 	} else {
 		set_thread_flag(TIF_IA32);
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
