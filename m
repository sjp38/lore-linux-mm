Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAB76B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 07:15:19 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id an2so25985270wjc.3
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 04:15:19 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id y67si14104925wmc.61.2017.01.23.04.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 04:15:18 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: track-active-portions-of-a-section-at-boot-fix fix
Date: Mon, 23 Jan 2017 13:14:39 +0100
Message-Id: <20170123121509.3143377-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A bugfix introduced a new warning as it marked a function as __init
that is called by both __init and non-__init functions:

WARNING: vmlinux.o(.text.unlikely+0x1b26): Section mismatch in reference from the function section_deactivate() to the function .init.text:section_active_mask()
WARNING: vmlinux.o(.meminit.text+0x1ce0): Section mismatch in reference from the function sparse_add_section() to the function .init.text:section_active_mask()

This removes the annotation again.

Fixes: mmotm ("mm-track-active-portions-of-a-section-at-boot-fix")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/sparse.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 3e4458c8e0e9..4267d09b656b 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -189,8 +189,8 @@ static int __init section_active_index(phys_addr_t phys)
 	return (phys & ~(PA_SECTION_MASK)) / SECTION_ACTIVE_SIZE;
 }
 
-static unsigned long __init section_active_mask(unsigned long pfn,
-						unsigned long nr_pages)
+static unsigned long section_active_mask(unsigned long pfn,
+					 unsigned long nr_pages)
 {
 	int idx_start, idx_size;
 	phys_addr_t start, size;
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
