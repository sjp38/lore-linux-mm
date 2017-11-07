Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0C0280245
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 05:38:13 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i196so16372804pgd.2
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 02:38:13 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n24si954478pfa.108.2017.11.07.02.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 02:38:11 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] x86/mm: Fix ELF_ET_DYN_BASE for 5-level paging
Date: Tue,  7 Nov 2017 13:38:04 +0300
Message-Id: <20171107103804.47341-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Nicholas Piggin <npiggin@gmail.com>

On machines with 5-level paging we don't want to allocate mapping above
47-bit unless user explicitly asked for it. See b569bab78d8d ("x86/mm:
Prepare to expose larger address space to userspace") for details.

c715b72c1ba4 ("mm: revert x86_64 and arm64 ELF_ET_DYN_BASE base
changes") broke the behaviour. After the commit elf binary and heap got
mapped above 47-bits.

Let's fix this.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: c715b72c1ba4 ("mm: revert x86_64 and arm64 ELF_ET_DYN_BASE base changes")
Cc: Kees Cook <keescook@chromium.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Nicholas Piggin <npiggin@gmail.com>
---
 arch/x86/include/asm/elf.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index c1a125e47ff3..3a091cea36c5 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -253,7 +253,7 @@ extern int force_personality32;
  * space open for things that want to use the area for 32-bit pointers.
  */
 #define ELF_ET_DYN_BASE		(mmap_is_ia32() ? 0x000400000UL : \
-						  (TASK_SIZE / 3 * 2))
+						  (DEFAULT_MAP_WINDOW / 3 * 2))
 
 /* This yields a mask that user programs can use to figure out what
    instruction set this CPU supports.  This could be done in user space,
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
