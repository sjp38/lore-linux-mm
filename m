Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F39328D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 08:31:38 -0500 (EST)
Received: by iwc10 with SMTP id 10so3866254iwc.14
        for <linux-mm@kvack.org>; Sun, 06 Feb 2011 05:31:37 -0800 (PST)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] memblock: Fix error path in memblock_add_region()
Date: Sun,  6 Feb 2011 22:31:15 +0900
Message-Id: <1296999075-8022-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Yinghai Lu <yinghai@kernel.org>

@type->regions should be restored if memblock_double_array() fails.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Yinghai Lu <yinghai@kernel.org>
---
 mm/memblock.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index bdba245d8afd..49284f9f99a6 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -379,6 +379,10 @@ static long __init_memblock memblock_add_region(struct memblock_type *type, phys
 	 */
 	if (type->cnt == type->max && memblock_double_array(type)) {
 		type->cnt--;
+		for (++i; i < type->cnt; i++) {
+			type->regions[i].base = type->regions[i+1].base;
+			type->regions[i].size = type->regions[i+1].size;
+		}
 		return -1;
 	}
 
-- 
1.7.3.4.600.g982838b0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
