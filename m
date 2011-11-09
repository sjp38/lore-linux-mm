Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 73D046B006E
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 06:37:36 -0500 (EST)
Received: by mail-iy0-f169.google.com with SMTP id e16so2402838iaa.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 03:37:35 -0800 (PST)
Message-ID: <4EBA65FA.1010605@gmail.com>
Date: Wed, 09 Nov 2011 19:37:30 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] mm/memblock.c: eliminate potential memleak in memblock_double_array
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In memblock_double_array, we don't deal with old_array if we use
slab for new_array. So the memory used by old_array may be lost.
Add logic to try to free old_array when using slab for new_array.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/memblock.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 09ff05b..0e4248f 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -250,13 +250,17 @@ static int __init_memblock memblock_double_array(struct memblock_type *type)
 	type->regions = new_array;
 	type->max <<= 1;
 
-	/* If we use SLAB that's it, we are done */
-	if (use_slab)
+	if (use_slab) {
+		if (memblock_is_region_reserved(__pa(old_array), old_size))
+			goto old_memblock;
+		kfree(old_array);
 		return 0;
+	}
 
 	/* Add the new reserved region now. Should not fail ! */
 	BUG_ON(memblock_add_region(&memblock.reserved, addr, new_size));
 
+old_memblock:
 	/* If the array wasn't our static init one, then free it. We only do
 	 * that before SLAB is available as later on, we don't know whether
 	 * to use kfree or free_bootmem_pages(). Shouldn't be a big deal
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
