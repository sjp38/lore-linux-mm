Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0CAFC200013
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:57:23 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 20/25] lmb: Add arch function to control coalescing of lmb memory regions
Date: Mon, 10 May 2010 19:38:54 +1000
Message-Id: <1273484339-28911-21-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
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
 <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Some archs such as ARM want to avoid coalescing accross things such
as the lowmem/highmem boundary or similar. This provides the option
to control it via an arch callback for which a weak default is provided
which always allows coalescing.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/lmb.h |    2 ++
 lib/lmb.c           |   19 ++++++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index e575801..404b49c 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -70,6 +70,8 @@ extern void lmb_dump_all(void);
 
 /* Provided by the architecture */
 extern phys_addr_t lmb_nid_range(phys_addr_t start, phys_addr_t end, int *nid);
+extern int lmb_memory_can_coalesce(phys_addr_t addr1, phys_addr_t size1,
+				   phys_addr_t addr2, phys_addr_t size2);
 
 /**
  * lmb_set_current_limit - Set the current allocation limit to allow
diff --git a/lib/lmb.c b/lib/lmb.c
index 2602683..84ac3a9 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -235,6 +235,12 @@ static int lmb_double_array(struct lmb_type *type)
 	return 0;
 }
 
+extern int __weak lmb_memory_can_coalesce(phys_addr_t addr1, phys_addr_t size1,
+					  phys_addr_t addr2, phys_addr_t size2)
+{
+	return 1;
+}
+
 static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long coalesced = 0;
@@ -256,6 +262,10 @@ static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t
 			return 0;
 
 		adjacent = lmb_addrs_adjacent(base, size, rgnbase, rgnsize);
+		/* Check if arch allows coalescing */
+		if (adjacent != 0 && type == &lmb.memory &&
+		    !lmb_memory_can_coalesce(base, size, rgnbase, rgnsize))
+			break;
 		if (adjacent > 0) {
 			type->regions[i].base -= size;
 			type->regions[i].size += size;
@@ -268,7 +278,14 @@ static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t
 		}
 	}
 
-	if ((i < type->cnt - 1) && lmb_regions_adjacent(type, i, i+1)) {
+	/* If we plugged a hole, we may want to also coalesce with the
+	 * next region
+	 */
+	if ((i < type->cnt - 1) && lmb_regions_adjacent(type, i, i+1) &&
+	    ((type != &lmb.memory || lmb_memory_can_coalesce(type->regions[i].base,
+							     type->regions[i].size,
+							     type->regions[i+1].base,
+							     type->regions[i+1].size)))) {
 		lmb_coalesce_regions(type, i, i+1);
 		coalesced++;
 	}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
