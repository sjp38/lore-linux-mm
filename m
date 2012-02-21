Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 55EA86B004D
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 03:58:33 -0500 (EST)
Received: by dadv6 with SMTP id v6so8152938dad.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 00:58:32 -0800 (PST)
From: Geunsik Lim <geunsik.lim@gmail.com>
Subject: [PATCH, v2] Fix potentially derefencing uninitialized 'r'.
Date: Tue, 21 Feb 2012 17:58:23 +0900
Message-Id: <1329814703-14398-1-git-send-email-geunsik.lim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@linux.intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

From: Geunsik Lim <geunsik.lim@samsung.com>

v2: reorganize the code with better way to avoid compilation warning
via the comment of Andrew Morton.

v1: struct memblock_region 'r' will not be initialized potentially
because of while() condition in __next_mem_pfn_range()function.
Solve the compilation warning related problem by initializing
r data structure.

Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
---
 mm/memblock.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 77b5f22..b8c40c5 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -673,14 +673,18 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 	struct memblock_type *type = &memblock.memory;
 	struct memblock_region *r;
 
-	while (++*idx < type->cnt) {
+	do {
 		r = &type->regions[*idx];
 
+	   if (++*idx < type->cnt) {
 		if (PFN_UP(r->base) >= PFN_DOWN(r->base + r->size))
 			continue;
 		if (nid == MAX_NUMNODES || nid == r->nid)
 			break;
-	}
+	   } else
+		break;
+	} while (1);
+
 	if (*idx >= type->cnt) {
 		*idx = -1;
 		return;
-- 
1.7.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
