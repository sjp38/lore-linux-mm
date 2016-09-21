Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3726B025E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 00:20:59 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y10so76319797qty.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 21:20:59 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id c186si24058934qkf.208.2016.09.20.21.20.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 21:20:59 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping page
 unaligned ranges
Message-ID: <57E20A69.5010206@zoho.com>
Date: Wed, 21 Sep 2016 12:19:53 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

From: zijun_hu <zijun_hu@htc.com>

endless loop maybe happen if either of parameter addr and end is not
page aligned for kernel API function ioremap_page_range()

in order to fix this issue and alert improper range parameters to user
WARN_ON() checkup and rounding down range lower boundary are performed
firstly, loop end condition within ioremap_pte_range() is optimized due
to lack of relevant macro pte_addr_end()

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 lib/ioremap.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 86c8911..911bdca 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
 		BUG_ON(!pte_none(*pte));
 		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
 		pfn++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (pte++, addr += PAGE_SIZE, addr < end && addr >= PAGE_SIZE);
 	return 0;
 }
 
@@ -129,7 +129,9 @@ int ioremap_page_range(unsigned long addr,
 	int err;
 
 	BUG_ON(addr >= end);
+	WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
 
+	addr = round_down(addr, PAGE_SIZE);
 	start = addr;
 	phys_addr -= addr;
 	pgd = pgd_offset_k(addr);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
