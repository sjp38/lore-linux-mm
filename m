Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2BC6B0254
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:53:56 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so42431866wib.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:53:55 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0091.outbound.protection.outlook.com. [157.56.112.91])
        by mx.google.com with ESMTPS id eu3si54465wib.105.2015.07.24.13.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Jul 2015 13:53:54 -0700 (PDT)
From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: [PATCH] bootmem: avoid freeing to bootmem after bootmem is done
Date: Fri, 24 Jul 2015 16:53:46 -0400
Message-ID: <1437771226-31255-1-git-send-email-cmetcalf@ezchip.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Paul
 McQuade <paulmcquad@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Mel
 Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Chris Metcalf <cmetcalf@ezchip.com>

Bootmem isn't popular any more, but some architectures still use
it, and freeing to bootmem after calling free_all_bootmem_core()
can end up scribbling over random memory.  Instead, make sure the
kernel panics by ensuring the node_bootmem_map field is non-NULL
when are freeing or marking bootmem.

An instance of this bug was just fixed in the tile architecture
("tile: use free_bootmem_late() for initrd") and catching this case
more widely seems like a good thing.

Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>
---
 mm/bootmem.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index a23dd1934654..178748259736 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -236,6 +236,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 	count += pages;
 	while (pages--)
 		__free_pages_bootmem(page++, cur++, 0);
+	bdata->node_bootmem_map = NULL;
 
 	bdebug("nid=%td released=%lx\n", bdata - bootmem_node_data, count);
 
@@ -294,6 +295,8 @@ static void __init __free(bootmem_data_t *bdata,
 		sidx + bdata->node_min_pfn,
 		eidx + bdata->node_min_pfn);
 
+	BUG_ON(bdata->node_bootmem_map == NULL);
+
 	if (bdata->hint_idx > sidx)
 		bdata->hint_idx = sidx;
 
@@ -314,6 +317,8 @@ static int __init __reserve(bootmem_data_t *bdata, unsigned long sidx,
 		eidx + bdata->node_min_pfn,
 		flags);
 
+	BUG_ON(bdata->node_bootmem_map == NULL);
+
 	for (idx = sidx; idx < eidx; idx++)
 		if (test_and_set_bit(idx, bdata->node_bootmem_map)) {
 			if (exclusive) {
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
