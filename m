Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 57DD966002F
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 00:19:41 -0400 (EDT)
Subject: [PATCH] memblock: Fix memblock_is_region_reserved() to return a
 boolean
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 04 Aug 2010 14:19:31 +1000
Message-ID: <1280895571.1902.140.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Russell King <linux@arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

All callers expect a boolean result which is true if the region
overlaps a reserved region. However, the implementation actually
returns -1 if there is no overlap, and a region index (0 based)
if there is.

Make it behave as callers (and common sense) expect.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Taking that out of my memblock rework branch as it should go in
now regardless of whether my stuff goes or not (which is still
under discussion, I'm fixing ARM up now).

I'll send this fix to Linus tomorrow along with powerpc.git if there
is no adverse comment.

diff --git a/mm/memblock.c b/mm/memblock.c
index 3024eb3..43840b3 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -504,7 +504,7 @@ int __init memblock_is_reserved(u64 addr)
 
 int memblock_is_region_reserved(u64 base, u64 size)
 {
-	return memblock_overlaps_region(&memblock.reserved, base, size);
+	return memblock_overlaps_region(&memblock.reserved, base, size) >= 0;
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
