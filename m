Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 71865200013
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:57:30 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 13/25] lmb: Add debug markers at the end of the array
Date: Mon, 10 May 2010 19:38:47 +1000
Message-Id: <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
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
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Since we allocate one more than needed, why not do a bit of sanity checking
here to ensure we don't walk past the end of the array ?

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index 27dbb9c..6765a3a 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -13,6 +13,7 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/bitops.h>
+#include <linux/poison.h>
 #include <linux/lmb.h>
 
 struct lmb lmb;
@@ -112,6 +113,10 @@ void __init lmb_init(void)
 	lmb.reserved.regions	= lmb_reserved_init_regions;
 	lmb.reserved.max	= INIT_LMB_REGIONS;
 
+	/* Write a marker in the unused last array entry */
+	lmb.memory.regions[INIT_LMB_REGIONS].base = (phys_addr_t)RED_INACTIVE;
+	lmb.reserved.regions[INIT_LMB_REGIONS].base = (phys_addr_t)RED_INACTIVE;
+
 	/* Create a dummy zero size LMB which will get coalesced away later.
 	 * This simplifies the lmb_add() code below...
 	 */
@@ -131,6 +136,12 @@ void __init lmb_analyze(void)
 {
 	int i;
 
+	/* Check marker in the unused last array entry */
+	WARN_ON(lmb_memory_init_regions[INIT_LMB_REGIONS].base
+		!= (phys_addr_t)RED_INACTIVE);
+	WARN_ON(lmb_reserved_init_regions[INIT_LMB_REGIONS].base
+		!= (phys_addr_t)RED_INACTIVE);
+
 	lmb.memory_size = 0;
 
 	for (i = 0; i < lmb.memory.cnt; i++)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
