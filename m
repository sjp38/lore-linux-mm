Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EC731600800
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:37 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765BWEQ000487
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:11:32 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FZdb659630
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FYS9021205
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 35/43] memblock: Make memblock_alloc_try_nid() fallback to MEMBLOCK_ALLOC_ANYWHERE
Date: Fri,  6 Aug 2010 15:15:16 +1000
Message-Id: <1281071724-28740-36-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

memblock_alloc_nid() used to fallback to allocating anywhere by using
memblock_alloc() as a fallback.

However, some of my previous patches limit memblock_alloc() to the region
covered by MEMBLOCK_ALLOC_ACCESSIBLE which is not quite what we want
for memblock_alloc_try_nid().

So we fix it by explicitely using MEMBLOCK_ALLOC_ANYWHERE.

Not that so far only sparc uses memblock_alloc_nid() and it hasn't been updated
to clamp the accessible zone yet. Thus the temporary "breakage" should have
no effect.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 mm/memblock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 1802d97..9de5fcd 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -546,7 +546,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 
 	if (res)
 		return res;
-	return memblock_alloc(size, align);
+	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ANYWHERE);
 }
 
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
