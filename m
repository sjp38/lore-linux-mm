Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3346B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 15:32:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f4so3938089wmh.7
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 12:32:02 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id 203si1471706wmc.73.2017.09.15.12.32.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 12:32:01 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: meminit: mark init_reserved_page as __meminit
Date: Fri, 15 Sep 2017 21:31:30 +0200
Message-Id: <20170915193149.901180-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The function is called from __meminit context and calls other
__meminit functions but isn't it self mark as such today:

WARNING: vmlinux.o(.text.unlikely+0x4516): Section mismatch in reference from the function init_reserved_page() to the function .meminit.text:early_pfn_to_nid()
The function init_reserved_page() references
the function __meminit early_pfn_to_nid().
This is often because init_reserved_page lacks a __meminit
annotation or the annotation of early_pfn_to_nid is wrong.

On most compilers, we don't notice this because the function
gets inlined all the time. Adding __meminit here fixes the
harmless warning for the old versions and is generally the
correct annotation.

Fixes: 7e18adb4f80b ("mm: meminit: initialise remaining struct pages in parallel with kswapd")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a123dee01872..ff45b8ebace3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1190,7 +1190,7 @@ static void __meminit __init_single_pfn(unsigned long pfn, unsigned long zone,
 }
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-static void init_reserved_page(unsigned long pfn)
+static void __meminit init_reserved_page(unsigned long pfn)
 {
 	pg_data_t *pgdat;
 	int nid, zid;
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
