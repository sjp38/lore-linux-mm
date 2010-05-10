Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3226B024A
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:40:11 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 12/25] lmb: Move lmb arrays to static storage in lmb.c and make their size a variable
Date: Mon, 10 May 2010 19:38:46 +1000
Message-Id: <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
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
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

This is in preparation for having resizable arrays.

Note that we still allocate one more than needed, this is unchanged from
the previous implementation.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/lmb.h |    7 ++++---
 lib/lmb.c           |   10 +++++++++-
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index 27c2386..e575801 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -18,7 +18,7 @@
 
 #include <asm/lmb.h>
 
-#define MAX_LMB_REGIONS 128
+#define INIT_LMB_REGIONS 128
 
 struct lmb_region {
 	phys_addr_t base;
@@ -26,8 +26,9 @@ struct lmb_region {
 };
 
 struct lmb_type {
-	unsigned long cnt;
-	struct lmb_region regions[MAX_LMB_REGIONS+1];
+	unsigned long cnt;	/* number of regions */
+	unsigned long max;	/* size of the allocated array */
+	struct lmb_region *regions;
 };
 
 struct lmb {
diff --git a/lib/lmb.c b/lib/lmb.c
index 41cee3b..27dbb9c 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -18,6 +18,8 @@
 struct lmb lmb;
 
 static int lmb_debug;
+static struct lmb_region lmb_memory_init_regions[INIT_LMB_REGIONS + 1];
+static struct lmb_region lmb_reserved_init_regions[INIT_LMB_REGIONS + 1];
 
 static int __init early_lmb(char *p)
 {
@@ -104,6 +106,12 @@ static void lmb_coalesce_regions(struct lmb_type *type,
 
 void __init lmb_init(void)
 {
+	/* Hookup the initial arrays */
+	lmb.memory.regions	= lmb_memory_init_regions;
+	lmb.memory.max		= INIT_LMB_REGIONS;
+	lmb.reserved.regions	= lmb_reserved_init_regions;
+	lmb.reserved.max	= INIT_LMB_REGIONS;
+
 	/* Create a dummy zero size LMB which will get coalesced away later.
 	 * This simplifies the lmb_add() code below...
 	 */
@@ -169,7 +177,7 @@ static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t
 
 	if (coalesced)
 		return coalesced;
-	if (type->cnt >= MAX_LMB_REGIONS)
+	if (type->cnt >= type->max)
 		return -1;
 
 	/* Couldn't coalesce the LMB, so add it to the sorted table. */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
