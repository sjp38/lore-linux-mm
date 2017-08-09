Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 91B456B03AB
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 16:09:03 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k62so7133189oia.6
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:09:03 -0700 (PDT)
Received: from mail-it0-x236.google.com (mail-it0-x236.google.com. [2607:f8b0:4001:c0b::236])
        by mx.google.com with ESMTPS id h3si3873441oia.98.2017.08.09.13.09.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 13:09:02 -0700 (PDT)
Received: by mail-it0-x236.google.com with SMTP id 77so3383525itj.1
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:09:02 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v5 07/10] arm64/mm: Don't flush the data cache if the page is unmapped by XPFO
Date: Wed,  9 Aug 2017 14:07:52 -0600
Message-Id: <20170809200755.11234-8-tycho@docker.com>
In-Reply-To: <20170809200755.11234-1-tycho@docker.com>
References: <20170809200755.11234-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

From: Juerg Haefliger <juerg.haefliger@hpe.com>

If the page is unmapped by XPFO, a data cache flush results in a fatal
page fault. So don't flush in that case.

Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Tested-by: Tycho Andersen <tycho@docker.com>
---
 arch/arm64/mm/flush.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
index 21a8d828cbf4..e17a063b2df2 100644
--- a/arch/arm64/mm/flush.c
+++ b/arch/arm64/mm/flush.c
@@ -20,6 +20,7 @@
 #include <linux/export.h>
 #include <linux/mm.h>
 #include <linux/pagemap.h>
+#include <linux/xpfo.h>
 
 #include <asm/cacheflush.h>
 #include <asm/cache.h>
@@ -30,7 +31,9 @@ void sync_icache_aliases(void *kaddr, unsigned long len)
 	unsigned long addr = (unsigned long)kaddr;
 
 	if (icache_is_aliasing()) {
-		__clean_dcache_area_pou(kaddr, len);
+		/* Don't flush if the page is unmapped by XPFO */
+		if (!xpfo_page_is_unmapped(virt_to_page(kaddr)))
+			__clean_dcache_area_pou(kaddr, len);
 		__flush_icache_all();
 	} else {
 		flush_icache_range(addr, addr + len);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
