Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5F40A6B02FC
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 13:37:12 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c195so260605itb.5
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 10:37:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p197sor16285itp.120.2017.09.07.10.37.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 10:37:11 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v6 07/11] arm64/mm, xpfo: temporarily map dcache regions
Date: Thu,  7 Sep 2017 11:36:05 -0600
Message-Id: <20170907173609.22696-8-tycho@docker.com>
In-Reply-To: <20170907173609.22696-1-tycho@docker.com>
References: <20170907173609.22696-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-arm-kernel@lists.infradead.org, Tycho Andersen <tycho@docker.com>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

If the page is unmapped by XPFO, a data cache flush results in a fatal
page fault, so let's temporarily map the region, flush the cache, and then
unmap it.

v6: actually flush in the face of xpfo, and temporarily map the underlying
    memory so it can be flushed correctly

CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
---
 arch/arm64/mm/flush.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
index 21a8d828cbf4..e335e3fd4fca 100644
--- a/arch/arm64/mm/flush.c
+++ b/arch/arm64/mm/flush.c
@@ -20,6 +20,7 @@
 #include <linux/export.h>
 #include <linux/mm.h>
 #include <linux/pagemap.h>
+#include <linux/xpfo.h>
 
 #include <asm/cacheflush.h>
 #include <asm/cache.h>
@@ -28,9 +29,15 @@
 void sync_icache_aliases(void *kaddr, unsigned long len)
 {
 	unsigned long addr = (unsigned long)kaddr;
+	unsigned long num_pages = XPFO_NUM_PAGES(addr, len);
+	void *mapping[num_pages];
 
 	if (icache_is_aliasing()) {
+		xpfo_temp_map(kaddr, len, mapping,
+			      sizeof(mapping[0]) * num_pages);
 		__clean_dcache_area_pou(kaddr, len);
+		xpfo_temp_unmap(kaddr, len, mapping,
+			        sizeof(mapping[0]) * num_pages);
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
