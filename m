Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 941586B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 02:38:45 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s4so19356418pgr.3
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 23:38:45 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id f14si8333294pgr.380.2017.06.25.23.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Jun 2017 23:38:44 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id f127so14168531pgc.2
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 23:38:44 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH] mm/gup: Make __gup_device_* require THP
Date: Mon, 26 Jun 2017 16:38:33 +1000
Message-Id: <20170626063833.11094-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Oliver O'Halloran <oohall@gmail.com>

These functions are the only bits of generic code that use
{pud,pmd}_pfn() without checking for CONFIG_TRANSPARENT_HUGEPAGE.
This works fine on x86, the only arch with devmap support, since the
*_pfn() functions are always defined there, but this isn't true for
every architecture.

Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
 mm/gup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index d9e6fddcc51f..04cf79291321 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1287,7 +1287,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 }
 #endif /* __HAVE_ARCH_PTE_SPECIAL */
 
-#ifdef __HAVE_ARCH_PTE_DEVMAP
+#if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
