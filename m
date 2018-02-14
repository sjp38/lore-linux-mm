Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D64836B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:25:50 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id h10so2188308pgf.3
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:25:50 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y26si327504pfm.63.2018.02.14.10.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 10:25:49 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/9] x86/mm: Initialize pgdir_shift and ptrs_per_p4d at boot-time
Date: Wed, 14 Feb 2018 21:25:35 +0300
Message-Id: <20180214182542.69302-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
References: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Switching between paging modes requires folding p4d page table level.
It means we need to adjust pgdir_shift and ptrs_per_p4d during early
boot according to paging mode.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/kaslr.c | 6 ++++--
 arch/x86/kernel/head64.c         | 6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/arch/x86/boot/compressed/kaslr.c b/arch/x86/boot/compressed/kaslr.c
index d02a838c0ce4..66e42a098d70 100644
--- a/arch/x86/boot/compressed/kaslr.c
+++ b/arch/x86/boot/compressed/kaslr.c
@@ -48,8 +48,8 @@
 
 #ifdef CONFIG_X86_5LEVEL
 unsigned int pgtable_l5_enabled __ro_after_init;
-unsigned int pgdir_shift __ro_after_init = 48;
-unsigned int ptrs_per_p4d __ro_after_init = 512;
+unsigned int pgdir_shift __ro_after_init = 39;
+unsigned int ptrs_per_p4d __ro_after_init = 1;
 #endif
 
 extern unsigned long get_cmd_line_ptr(void);
@@ -732,6 +732,8 @@ void choose_random_location(unsigned long input,
 #ifdef CONFIG_X86_5LEVEL
 	if (__read_cr4() & X86_CR4_LA57) {
 		pgtable_l5_enabled = 1;
+		pgdir_shift = 48;
+		ptrs_per_p4d = 512;
 	}
 #endif
 
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index ffb31c50d515..8a0a485524da 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -42,9 +42,9 @@ pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 #ifdef CONFIG_X86_5LEVEL
 unsigned int pgtable_l5_enabled __ro_after_init;
 EXPORT_SYMBOL(pgtable_l5_enabled);
-unsigned int pgdir_shift __ro_after_init = 48;
+unsigned int pgdir_shift __ro_after_init = 39;
 EXPORT_SYMBOL(pgdir_shift);
-unsigned int ptrs_per_p4d __ro_after_init = 512;
+unsigned int ptrs_per_p4d __ro_after_init = 1;
 EXPORT_SYMBOL(ptrs_per_p4d);
 #endif
 
@@ -79,6 +79,8 @@ static void __head check_la57_support(unsigned long physaddr)
 		return;
 
 	*fixup_int(&pgtable_l5_enabled, physaddr) = 1;
+	*fixup_int(&pgdir_shift, physaddr) = 48;
+	*fixup_int(&ptrs_per_p4d, physaddr) = 512;
 }
 #else
 static void __head check_la57_support(unsigned long physaddr) {}
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
