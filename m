Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id C260F6B0254
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:36:41 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so144487873wic.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:36:41 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0081.outbound.protection.outlook.com. [157.55.234.81])
        by mx.google.com with ESMTPS id bm9si14613470wib.28.2015.07.27.08.36.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Jul 2015 08:36:39 -0700 (PDT)
From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: [PATCH v2] bootmem: avoid freeing to bootmem after bootmem is done
Date: Mon, 27 Jul 2015 11:36:06 -0400
Message-ID: <1438011366-11474-1-git-send-email-cmetcalf@ezchip.com>
In-Reply-To: <20150727105951.GO2561@suse.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Paul
 McQuade <paulmcquad@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Mel
 Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Chris Metcalf <cmetcalf@ezchip.com>

Bootmem isn't popular any more, but some architectures still use it,
and freeing to bootmem after calling free_all_bootmem_core() can end
up scribbling over random memory.  Instead, make sure the kernel
generates a warning in this case by ensuring the node_bootmem_map
field is non-NULL when are freeing or marking bootmem.

An instance of this bug was just fixed in the tile architecture
("tile: use free_bootmem_late() for initrd") and catching this case
more widely seems like a good thing.

Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>
---
v2: use WARN_ON() instead of BUG_ON() [Mel Gorman]

 mm/bootmem.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index a23dd1934654..3b6380784c28 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -236,6 +236,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 	count += pages;
 	while (pages--)
 		__free_pages_bootmem(page++, cur++, 0);
+	bdata->node_bootmem_map = NULL;
 
 	bdebug("nid=%td released=%lx\n", bdata - bootmem_node_data, count);
 
@@ -294,6 +295,9 @@ static void __init __free(bootmem_data_t *bdata,
 		sidx + bdata->node_min_pfn,
 		eidx + bdata->node_min_pfn);
 
+	if (WARN_ON(bdata->node_bootmem_map == NULL))
+		return;
+
 	if (bdata->hint_idx > sidx)
 		bdata->hint_idx = sidx;
 
@@ -314,6 +318,9 @@ static int __init __reserve(bootmem_data_t *bdata, unsigned long sidx,
 		eidx + bdata->node_min_pfn,
 		flags);
 
+	if (WARN_ON(bdata->node_bootmem_map == NULL))
+		return 0;
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
