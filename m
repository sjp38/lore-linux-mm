Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id A4C3A6B0044
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:45:05 -0400 (EDT)
Received: by mail-yk0-f174.google.com with SMTP id q9so1551443ykb.5
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:45:05 -0700 (PDT)
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com. [15.193.200.69])
        by mx.google.com with ESMTPS id r30si26045889yhm.123.2014.07.15.12.45.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 12:45:05 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 9/11] x86, efi: Cleanup PCD bit manipulation in EFI
Date: Tue, 15 Jul 2014 13:34:42 -0600
Message-Id: <1405452884-25688-10-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, konrad.wilk@oracle.com, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de, Toshi Kani <toshi.kani@hp.com>

This patch cleans up the PCD bit manipulation in EFI virtual mapping,
and uses _PAGE_CACHE_<type> macros, instead.  This keeps the efi code
independent from the PAT slot assignment.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/platform/efi/efi_64.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 290d397..55c6e77 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -202,10 +202,10 @@ void efi_cleanup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 static void __init __map_region(efi_memory_desc_t *md, u64 va)
 {
 	pgd_t *pgd = (pgd_t *)__va(real_mode_header->trampoline_pgd);
-	unsigned long pf = 0;
+	unsigned long pf = _PAGE_CACHE_WB;
 
 	if (!(md->attribute & EFI_MEMORY_WB))
-		pf |= _PAGE_PCD;
+		pf = _PAGE_CACHE_UC_MINUS;
 
 	if (kernel_map_pages_in_pgd(pgd, md->phys_addr, va, md->num_pages, pf))
 		pr_warn("Error mapping PA 0x%llx -> VA 0x%llx!\n",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
