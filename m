Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 907346B0315
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:31:43 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u8so75296700pgo.11
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:31:43 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d6si22206829pgc.63.2017.06.06.04.31.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 04:31:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 03/14] x86/boot/efi: Cleanup initialization of GDT entries
Date: Tue,  6 Jun 2017 14:31:22 +0300
Message-Id: <20170606113133.22974-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matt Fleming <matt@codeblueprint.co.uk>

This is preparation for following patches without changing semantics of the
code.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
---
 arch/x86/boot/compressed/eboot.c | 39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/arch/x86/boot/compressed/eboot.c b/arch/x86/boot/compressed/eboot.c
index cbf4b87f55b9..1d5093d1f319 100644
--- a/arch/x86/boot/compressed/eboot.c
+++ b/arch/x86/boot/compressed/eboot.c
@@ -1049,6 +1049,7 @@ struct boot_params *efi_main(struct efi_config *c,
 	/* The first GDT is a dummy and the second is unused. */
 	desc += 2;
 
+	/* __KERNEL_CS */
 	desc->limit0 = 0xffff;
 	desc->base0 = 0x0000;
 	desc->base1 = 0x0000;
@@ -1062,8 +1063,9 @@ struct boot_params *efi_main(struct efi_config *c,
 	desc->d = SEG_OP_SIZE_32BIT;
 	desc->g = SEG_GRANULARITY_4KB;
 	desc->base2 = 0x00;
-
 	desc++;
+
+	/* __KERNEL_DS */
 	desc->limit0 = 0xffff;
 	desc->base0 = 0x0000;
 	desc->base1 = 0x0000;
@@ -1077,24 +1079,25 @@ struct boot_params *efi_main(struct efi_config *c,
 	desc->d = SEG_OP_SIZE_32BIT;
 	desc->g = SEG_GRANULARITY_4KB;
 	desc->base2 = 0x00;
-
-#ifdef CONFIG_X86_64
-	/* Task segment value */
 	desc++;
-	desc->limit0 = 0x0000;
-	desc->base0 = 0x0000;
-	desc->base1 = 0x0000;
-	desc->type = SEG_TYPE_TSS;
-	desc->s = 0;
-	desc->dpl = 0;
-	desc->p = 1;
-	desc->limit = 0x0;
-	desc->avl = 0;
-	desc->l = 0;
-	desc->d = 0;
-	desc->g = SEG_GRANULARITY_4KB;
-	desc->base2 = 0x00;
-#endif /* CONFIG_X86_64 */
+
+	if (IS_ENABLED(CONFIG_X86_64)) {
+		/* Task segment value */
+		desc->limit0 = 0x0000;
+		desc->base0 = 0x0000;
+		desc->base1 = 0x0000;
+		desc->type = SEG_TYPE_TSS;
+		desc->s = 0;
+		desc->dpl = 0;
+		desc->p = 1;
+		desc->limit = 0x0;
+		desc->avl = 0;
+		desc->l = 0;
+		desc->d = 0;
+		desc->g = SEG_GRANULARITY_4KB;
+		desc->base2 = 0x00;
+		desc++;
+	}
 
 	asm volatile("cli");
 	asm volatile ("lgdt %0" : : "m" (*gdt));
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
