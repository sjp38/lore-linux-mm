Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DAFB6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 08:17:40 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m188so56590490pgm.2
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 05:17:40 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g9si1589093pli.273.2017.06.28.05.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 05:17:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 6/5] x86/KASLR: Fix detection 32/64 bit bootloaders for 5-level paging
Date: Wed, 28 Jun 2017 15:17:30 +0300
Message-Id: <20170628121730.43079-1-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170622122608.80435-1-kirill.shutemov@linux.intel.com>
References: <20170622122608.80435-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kees Cook <keescook@chromium.org>

KASLR uses hack to detect whether we booted via startup_32() or
startup_64(): it checks what is loaded into cr3 and compares it to
_pgtables. _pgtables is the array of page tables where early code
allocates page table from.

KASLR expects cr3 to point to _pgtables if we booted via startup_32(), but
that's not true if we booted with 5-level paging enabled. In this case top
level page table is allocated separately and only the first p4d page table
is allocated from the array.

Let's modify the check to cover both 4- and 5-level paging cases.

The patch also renames 'level4p' to 'top_level_pgt' as it now can hold
page table for 4th or 5th level, depending on configuration.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Kees Cook <keescook@chromium.org>
---
 arch/x86/boot/compressed/pagetable.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
index 8e69df96492e..da4cf44d4aac 100644
--- a/arch/x86/boot/compressed/pagetable.c
+++ b/arch/x86/boot/compressed/pagetable.c
@@ -63,7 +63,7 @@ static void *alloc_pgt_page(void *context)
 static struct alloc_pgt_data pgt_data;
 
 /* The top level page table entry pointer. */
-static unsigned long level4p;
+static unsigned long top_level_pgt;
 
 /*
  * Mapping information structure passed to kernel_ident_mapping_init().
@@ -91,9 +91,15 @@ void initialize_identity_maps(void)
 	 * If we came here via startup_32(), cr3 will be _pgtable already
 	 * and we must append to the existing area instead of entirely
 	 * overwriting it.
+	 *
+	 * With 5-level paging, we use _pgtable allocate p4d page table,
+	 * top-level page table is allocated separately.
+	 *
+	 * p4d_offset(top_level_pgt, 0) would cover both 4- and 5-level
+	 * cases. On 4-level paging it's equal to top_level_pgt.
 	 */
-	level4p = read_cr3_pa();
-	if (level4p == (unsigned long)_pgtable) {
+	top_level_pgt = read_cr3_pa();
+	if (p4d_offset((pgd_t *)top_level_pgt, 0) == (p4d_t *)_pgtable) {
 		debug_putstr("booted via startup_32()\n");
 		pgt_data.pgt_buf = _pgtable + BOOT_INIT_PGT_SIZE;
 		pgt_data.pgt_buf_size = BOOT_PGT_SIZE - BOOT_INIT_PGT_SIZE;
@@ -103,7 +109,7 @@ void initialize_identity_maps(void)
 		pgt_data.pgt_buf = _pgtable;
 		pgt_data.pgt_buf_size = BOOT_PGT_SIZE;
 		memset(pgt_data.pgt_buf, 0, pgt_data.pgt_buf_size);
-		level4p = (unsigned long)alloc_pgt_page(&pgt_data);
+		top_level_pgt = (unsigned long)alloc_pgt_page(&pgt_data);
 	}
 }
 
@@ -123,7 +129,7 @@ void add_identity_map(unsigned long start, unsigned long size)
 		return;
 
 	/* Build the mapping. */
-	kernel_ident_mapping_init(&mapping_info, (pgd_t *)level4p,
+	kernel_ident_mapping_init(&mapping_info, (pgd_t *)top_level_pgt,
 				  start, end);
 }
 
@@ -134,5 +140,5 @@ void add_identity_map(unsigned long start, unsigned long size)
  */
 void finalize_identity_maps(void)
 {
-	write_cr3(level4p);
+	write_cr3(top_level_pgt);
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
