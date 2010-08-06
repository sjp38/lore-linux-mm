Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 913356B02A5
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:33 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FNps029457
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:23 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FUD51703996
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:30 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FU1Q026859
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:30 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 01/43] memblock: Fix memblock_is_region_reserved() to return a boolean
Date: Fri,  6 Aug 2010 15:14:42 +1000
Message-Id: <1281071724-28740-2-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

All callers expect a boolean result which is true if the region
overlaps a reserved region. However, the implementation actually
returns -1 if there is no overlap, and a region index (0 based)
if there is.

Make it behave as callers (and common sense) expect.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 mm/memblock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
