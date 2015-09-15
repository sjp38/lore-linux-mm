Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id BC4896B025B
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:08:50 -0400 (EDT)
Received: by lamp12 with SMTP id p12so107182727lam.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:50 -0700 (PDT)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com. [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id pp5si13853013lbb.166.2015.09.15.07.08.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:08:49 -0700 (PDT)
Received: by lagj9 with SMTP id j9so109915739lag.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:49 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 04/10] mm/early_ioremap: Use offset_in_page macro
Date: Tue, 15 Sep 2015 20:07:53 +0600
Message-Id: <1442326073-7328-1-git-send-email-kuleshovmail@gmail.com>
In-Reply-To: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
References: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

The <linux/mm.h> provides offset_in_page() macro. Let's use already
predefined macro instead of (addr & ~PAGE_MASK).

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/early_ioremap.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index 17ae14b..6d5717b 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -126,7 +126,7 @@ __early_ioremap(resource_size_t phys_addr, unsigned long size, pgprot_t prot)
 	/*
 	 * Mappings have to be page-aligned
 	 */
-	offset = phys_addr & ~PAGE_MASK;
+	offset = offset_in_page(phys_addr);
 	phys_addr &= PAGE_MASK;
 	size = PAGE_ALIGN(last_addr + 1) - phys_addr;
 
@@ -189,7 +189,7 @@ void __init early_iounmap(void __iomem *addr, unsigned long size)
 	if (WARN_ON(virt_addr < fix_to_virt(FIX_BTMAP_BEGIN)))
 		return;
 
-	offset = virt_addr & ~PAGE_MASK;
+	offset = offset_in_page(virt_addr);
 	nrpages = PAGE_ALIGN(offset + size) >> PAGE_SHIFT;
 
 	idx = FIX_BTMAP_BEGIN - NR_FIX_BTMAPS*slot;
@@ -234,7 +234,7 @@ void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size)
 	char *p;
 
 	while (size) {
-		slop = src & ~PAGE_MASK;
+		slop = offset_in_page(src);
 		clen = size;
 		if (clen > MAX_MAP_CHUNK - slop)
 			clen = MAX_MAP_CHUNK - slop;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
