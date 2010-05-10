Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 378D9200013
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:57:34 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 17/25] lmb: split lmb_find_base() out of __lmb_alloc_base()
Date: Mon, 10 May 2010 19:38:51 +1000
Message-Id: <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-8-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-9-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-10-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-11-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

This will be used by the array resize code and might prove useful
to some arch code as well at which point it can be made non-static.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |   43 +++++++++++++++++++++++++++----------------
 1 files changed, 27 insertions(+), 16 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index 141d4ab..95ef5b6 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -366,20 +366,7 @@ phys_addr_t __init lmb_alloc(phys_addr_t size, phys_addr_t align)
 	return lmb_alloc_base(size, align, LMB_ALLOC_ACCESSIBLE);
 }
 
-phys_addr_t __init lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
-{
-	phys_addr_t alloc;
-
-	alloc = __lmb_alloc_base(size, align, max_addr);
-
-	if (alloc == 0)
-		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
-		      (unsigned long long) size, (unsigned long long) max_addr);
-
-	return alloc;
-}
-
-phys_addr_t __init __lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
+static phys_addr_t __init lmb_find_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
 	long i;
 	phys_addr_t base = 0;
@@ -405,13 +392,37 @@ phys_addr_t __init __lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_ad
 			continue;
 		base = min(lmbbase + lmbsize, max_addr);
 		res_base = lmb_find_region(lmbbase, base, size, align);		
-		if (res_base != LMB_ERROR &&
-		    lmb_add_region(&lmb.reserved, res_base, size) >= 0)
+		if (res_base != LMB_ERROR)
 			return res_base;
 	}
 	return 0;
 }
 
+phys_addr_t __init __lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
+{
+	phys_addr_t found = lmb_find_base(size, align, max_addr);
+
+	if (found != LMB_ERROR &&
+	    lmb_add_region(&lmb.reserved, found, size) >= 0)
+		return found;
+
+	return 0;
+}
+
+phys_addr_t __init lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
+{
+	phys_addr_t alloc;
+
+	alloc = __lmb_alloc_base(size, align, max_addr);
+
+	if (alloc == 0)
+		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
+		      (unsigned long long) size, (unsigned long long) max_addr);
+
+	return alloc;
+}
+
+
 /* You must call lmb_analyze() before this. */
 phys_addr_t __init lmb_phys_mem_size(void)
 {
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
