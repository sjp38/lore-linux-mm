Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D33586B026F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:54:51 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 127so202688721pfg.5
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:54:51 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m18si13093225pgd.76.2016.12.26.17.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 23/29] x86/espfix: support 5-level paging
Date: Tue, 27 Dec 2016 04:54:07 +0300
Message-Id: <20161227015413.187403-24-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't need extra virtual address space for ESPFIX, so it stays within
one PUD page table for both 4- and 5-level paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/espfix_64.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/espfix_64.c b/arch/x86/kernel/espfix_64.c
index 04f89caef9c4..8e598a1ad986 100644
--- a/arch/x86/kernel/espfix_64.c
+++ b/arch/x86/kernel/espfix_64.c
@@ -50,11 +50,11 @@
 #define ESPFIX_STACKS_PER_PAGE	(PAGE_SIZE/ESPFIX_STACK_SIZE)
 
 /* There is address space for how many espfix pages? */
-#define ESPFIX_PAGE_SPACE	(1UL << (PGDIR_SHIFT-PAGE_SHIFT-16))
+#define ESPFIX_PAGE_SPACE	(1UL << (P4D_SHIFT-PAGE_SHIFT-16))
 
 #define ESPFIX_MAX_CPUS		(ESPFIX_STACKS_PER_PAGE * ESPFIX_PAGE_SPACE)
 #if CONFIG_NR_CPUS > ESPFIX_MAX_CPUS
-# error "Need more than one PGD for the ESPFIX hack"
+# error "Need more virtual address space for the ESPFIX hack"
 #endif
 
 #define PGALLOC_GFP (GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
@@ -121,11 +121,13 @@ static void init_espfix_random(void)
 
 void __init init_espfix_bsp(void)
 {
-	pgd_t *pgd_p;
+	pgd_t *pgd;
+	p4d_t *p4d;
 
 	/* Install the espfix pud into the kernel page directory */
-	pgd_p = &init_level4_pgt[pgd_index(ESPFIX_BASE_ADDR)];
-	pgd_populate(&init_mm, pgd_p, (pud_t *)espfix_pud_page);
+	pgd = &init_level4_pgt[pgd_index(ESPFIX_BASE_ADDR)];
+	p4d = p4d_alloc(&init_mm, pgd, ESPFIX_BASE_ADDR);
+	p4d_populate(&init_mm, p4d, espfix_pud_page);
 
 	/* Randomize the locations */
 	init_espfix_random();
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
