Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5DF6B02A3
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:41:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i26-v6so1708031edr.4
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 02:41:39 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id f15-v6si2973927ede.13.2018.07.18.02.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 02:41:38 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 27/39] x86/mm/pti: Make pti_clone_kernel_text() compile on 32 bit
Date: Wed, 18 Jul 2018 11:41:04 +0200
Message-Id: <1531906876-13451-28-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The pti_clone_kernel_text() function references
__end_rodata_hpage_align, which is only present on x86-64.
This makes sense as the end of the rodata section is not
huge-page aligned on 32 bit.

Nevertheless we need a symbol for the function that points
at the right address for both 32 and 64 bit. Introduce
__end_rodata_aligned for that purpose and use it in
pti_clone_kernel_text().

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/sections.h |  1 +
 arch/x86/kernel/vmlinux.lds.S   | 17 ++++++++++-------
 arch/x86/mm/pti.c               |  2 +-
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/sections.h b/arch/x86/include/asm/sections.h
index 5c019d2..4a911a3 100644
--- a/arch/x86/include/asm/sections.h
+++ b/arch/x86/include/asm/sections.h
@@ -7,6 +7,7 @@
 
 extern char __brk_base[], __brk_limit[];
 extern struct exception_table_entry __stop___ex_table[];
+extern char __end_rodata_aligned[];
 
 #if defined(CONFIG_X86_64)
 extern char __end_rodata_hpage_align[];
diff --git a/arch/x86/kernel/vmlinux.lds.S b/arch/x86/kernel/vmlinux.lds.S
index 5e1458f..8bde0a4 100644
--- a/arch/x86/kernel/vmlinux.lds.S
+++ b/arch/x86/kernel/vmlinux.lds.S
@@ -55,19 +55,22 @@ jiffies_64 = jiffies;
  * so we can enable protection checks as well as retain 2MB large page
  * mappings for kernel text.
  */
-#define X64_ALIGN_RODATA_BEGIN	. = ALIGN(HPAGE_SIZE);
+#define X86_ALIGN_RODATA_BEGIN	. = ALIGN(HPAGE_SIZE);
 
-#define X64_ALIGN_RODATA_END					\
+#define X86_ALIGN_RODATA_END					\
 		. = ALIGN(HPAGE_SIZE);				\
-		__end_rodata_hpage_align = .;
+		__end_rodata_hpage_align = .;			\
+		__end_rodata_aligned = .;
 
 #define ALIGN_ENTRY_TEXT_BEGIN	. = ALIGN(PMD_SIZE);
 #define ALIGN_ENTRY_TEXT_END	. = ALIGN(PMD_SIZE);
 
 #else
 
-#define X64_ALIGN_RODATA_BEGIN
-#define X64_ALIGN_RODATA_END
+#define X86_ALIGN_RODATA_BEGIN
+#define X86_ALIGN_RODATA_END					\
+		. = ALIGN(PAGE_SIZE);				\
+		__end_rodata_aligned = .;
 
 #define ALIGN_ENTRY_TEXT_BEGIN
 #define ALIGN_ENTRY_TEXT_END
@@ -141,9 +144,9 @@ SECTIONS
 
 	/* .text should occupy whole number of pages */
 	. = ALIGN(PAGE_SIZE);
-	X64_ALIGN_RODATA_BEGIN
+	X86_ALIGN_RODATA_BEGIN
 	RO_DATA(PAGE_SIZE)
-	X64_ALIGN_RODATA_END
+	X86_ALIGN_RODATA_END
 
 	/* Data */
 	.data : AT(ADDR(.data) - LOAD_OFFSET) {
diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 2eadab0..4f6e933 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -470,7 +470,7 @@ void pti_clone_kernel_text(void)
 	 * clone the areas past rodata, they might contain secrets.
 	 */
 	unsigned long start = PFN_ALIGN(_text);
-	unsigned long end = (unsigned long)__end_rodata_hpage_align;
+	unsigned long end = (unsigned long)__end_rodata_aligned;
 
 	if (!pti_kernel_image_global_ok())
 		return;
-- 
2.7.4
