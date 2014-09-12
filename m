Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 099956B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 16:17:31 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id p10so1307531wes.2
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 13:17:31 -0700 (PDT)
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
        by mx.google.com with ESMTPS id lj9si4618180wic.105.2014.09.12.13.17.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 13:17:28 -0700 (PDT)
Received: by mail-wg0-f42.google.com with SMTP id x12so1215770wgg.25
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 13:17:28 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] mm: export symbol dependencies of is_zero_pfn()
Date: Fri, 12 Sep 2014 22:17:23 +0200
Message-Id: <1410553043-575-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, pbonzini@redhat.com, christoffer.dall@linaro.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, ralf@linux-mips.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, akpm@linux-foundation.org
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>

In order to make the static inline function is_zero_pfn() callable by
modules, export its symbol dependencies 'zero_pfn' and (for s390 and
mips) 'zero_page_mask'.

We need this for KVM, as CONFIG_KVM is a tristate for all supported
architectures except ARM and arm64, and testing a pfn whether it refers
to the zero page is required to correctly distinguish the zero page
from other special RAM ranges that may also have the PG_reserved bit
set, but need to be treated as MMIO memory.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/mips/mm/init.c | 1 +
 arch/s390/mm/init.c | 1 +
 mm/memory.c         | 2 ++
 3 files changed, 4 insertions(+)

diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 571aab064936..f42e35e42790 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -53,6 +53,7 @@
  */
 unsigned long empty_zero_page, zero_page_mask;
 EXPORT_SYMBOL_GPL(empty_zero_page);
+EXPORT_SYMBOL(zero_page_mask);
 
 /*
  * Not static inline because used by IP27 special magic initialization code
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 0c1073ed1e84..c7235e01fd67 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -43,6 +43,7 @@ pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((__aligned__(PAGE_SIZE)));
 
 unsigned long empty_zero_page, zero_page_mask;
 EXPORT_SYMBOL(empty_zero_page);
+EXPORT_SYMBOL(zero_page_mask);
 
 static void __init setup_zero_pages(void)
 {
diff --git a/mm/memory.c b/mm/memory.c
index adeac306610f..d17f1bcd2a91 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -118,6 +118,8 @@ __setup("norandmaps", disable_randmaps);
 unsigned long zero_pfn __read_mostly;
 unsigned long highest_memmap_pfn __read_mostly;
 
+EXPORT_SYMBOL(zero_pfn);
+
 /*
  * CONFIG_MMU architectures set up ZERO_PAGE in their paging_init()
  */
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
