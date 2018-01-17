Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6938928029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:24:48 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y13so8199248pfl.16
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:24:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id bd7si4823744plb.637.2018.01.17.12.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:09 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 96/99] dma-debug: Convert to XArray
Date: Wed, 17 Jan 2018 12:22:00 -0800
Message-Id: <20180117202203.19756-97-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This is an unusual way to use the xarray tags.  If any other users
come up, we can add an xas_get_tags() / xas_set_tags() API, but until
then I don't want to encourage this kind of abuse.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 lib/dma-debug.c | 105 +++++++++++++++++++++++++-------------------------------
 1 file changed, 46 insertions(+), 59 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index fb4af570ce04..965b3837d060 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -22,7 +22,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/sched/task.h>
 #include <linux/stacktrace.h>
-#include <linux/radix-tree.h>
 #include <linux/dma-debug.h>
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
@@ -30,6 +29,7 @@
 #include <linux/uaccess.h>
 #include <linux/export.h>
 #include <linux/device.h>
+#include <linux/xarray.h>
 #include <linux/types.h>
 #include <linux/sched.h>
 #include <linux/ctype.h>
@@ -465,9 +465,8 @@ EXPORT_SYMBOL(debug_dma_dump_mappings);
  * At any time debug_dma_assert_idle() can be called to trigger a
  * warning if any cachelines in the given page are in the active set.
  */
-static RADIX_TREE(dma_active_cacheline, GFP_NOWAIT);
-static DEFINE_SPINLOCK(radix_lock);
-#define ACTIVE_CACHELINE_MAX_OVERLAP ((1 << RADIX_TREE_MAX_TAGS) - 1)
+static DEFINE_XARRAY_FLAGS(dma_active_cacheline, XA_FLAGS_LOCK_IRQ);
+#define ACTIVE_CACHELINE_MAX_OVERLAP ((1 << XA_MAX_TAGS) - 1)
 #define CACHELINE_PER_PAGE_SHIFT (PAGE_SHIFT - L1_CACHE_SHIFT)
 #define CACHELINES_PER_PAGE (1 << CACHELINE_PER_PAGE_SHIFT)
 
@@ -477,37 +476,40 @@ static phys_addr_t to_cacheline_number(struct dma_debug_entry *entry)
 		(entry->offset >> L1_CACHE_SHIFT);
 }
 
-static int active_cacheline_read_overlap(phys_addr_t cln)
+static unsigned int active_cacheline_read_overlap(struct xa_state *xas)
 {
-	int overlap = 0, i;
+	unsigned int tags = 0;
+	xa_tag_t tag;
 
-	for (i = RADIX_TREE_MAX_TAGS - 1; i >= 0; i--)
-		if (radix_tree_tag_get(&dma_active_cacheline, cln, i))
-			overlap |= 1 << i;
-	return overlap;
+	for (tag = 0; tag < XA_MAX_TAGS; tag++)
+		if (xas_get_tag(xas, tag))
+			tags |= 1U << tag;
+
+	return tags;
 }
 
-static int active_cacheline_set_overlap(phys_addr_t cln, int overlap)
+static int active_cacheline_set_overlap(struct xa_state *xas, int overlap)
 {
-	int i;
+	xa_tag_t tag;
 
 	if (overlap > ACTIVE_CACHELINE_MAX_OVERLAP || overlap < 0)
 		return overlap;
 
-	for (i = RADIX_TREE_MAX_TAGS - 1; i >= 0; i--)
-		if (overlap & 1 << i)
-			radix_tree_tag_set(&dma_active_cacheline, cln, i);
+	for (tag = 0; tag < XA_MAX_TAGS; tag++) {
+		if (overlap & (1U << tag))
+			xas_set_tag(xas, tag);
 		else
-			radix_tree_tag_clear(&dma_active_cacheline, cln, i);
+			xas_clear_tag(xas, tag);
+	}
 
 	return overlap;
 }
 
-static void active_cacheline_inc_overlap(phys_addr_t cln)
+static void active_cacheline_inc_overlap(struct xa_state *xas)
 {
-	int overlap = active_cacheline_read_overlap(cln);
+	int overlap = active_cacheline_read_overlap(xas);
 
-	overlap = active_cacheline_set_overlap(cln, ++overlap);
+	overlap = active_cacheline_set_overlap(xas, ++overlap);
 
 	/* If we overflowed the overlap counter then we're potentially
 	 * leaking dma-mappings.  Otherwise, if maps and unmaps are
@@ -517,21 +519,22 @@ static void active_cacheline_inc_overlap(phys_addr_t cln)
 	 */
 	WARN_ONCE(overlap > ACTIVE_CACHELINE_MAX_OVERLAP,
 		  "DMA-API: exceeded %d overlapping mappings of cacheline %pa\n",
-		  ACTIVE_CACHELINE_MAX_OVERLAP, &cln);
+		  ACTIVE_CACHELINE_MAX_OVERLAP, &xas->xa_index);
 }
 
-static int active_cacheline_dec_overlap(phys_addr_t cln)
+static int active_cacheline_dec_overlap(struct xa_state *xas)
 {
-	int overlap = active_cacheline_read_overlap(cln);
+	int overlap = active_cacheline_read_overlap(xas);
 
-	return active_cacheline_set_overlap(cln, --overlap);
+	return active_cacheline_set_overlap(xas, --overlap);
 }
 
 static int active_cacheline_insert(struct dma_debug_entry *entry)
 {
 	phys_addr_t cln = to_cacheline_number(entry);
+	XA_STATE(xas, &dma_active_cacheline, cln);
 	unsigned long flags;
-	int rc;
+	struct dma_debug_entry *exists;
 
 	/* If the device is not writing memory then we don't have any
 	 * concerns about the cpu consuming stale data.  This mitigates
@@ -540,32 +543,32 @@ static int active_cacheline_insert(struct dma_debug_entry *entry)
 	if (entry->direction == DMA_TO_DEVICE)
 		return 0;
 
-	spin_lock_irqsave(&radix_lock, flags);
-	rc = radix_tree_insert(&dma_active_cacheline, cln, entry);
-	if (rc == -EEXIST)
-		active_cacheline_inc_overlap(cln);
-	spin_unlock_irqrestore(&radix_lock, flags);
+	xas_lock_irqsave(&xas, flags);
+	exists = xas_create(&xas);
+	if (exists)
+		active_cacheline_inc_overlap(&xas);
+	else
+		xas_store(&xas, entry);
+	xas_unlock_irqrestore(&xas, flags);
 
-	return rc;
+	return xas_error(&xas);
 }
 
 static void active_cacheline_remove(struct dma_debug_entry *entry)
 {
 	phys_addr_t cln = to_cacheline_number(entry);
+	XA_STATE(xas, &dma_active_cacheline, cln);
 	unsigned long flags;
 
 	/* ...mirror the insert case */
 	if (entry->direction == DMA_TO_DEVICE)
 		return;
 
-	spin_lock_irqsave(&radix_lock, flags);
-	/* since we are counting overlaps the final put of the
-	 * cacheline will occur when the overlap count is 0.
-	 * active_cacheline_dec_overlap() returns -1 in that case
-	 */
-	if (active_cacheline_dec_overlap(cln) < 0)
-		radix_tree_delete(&dma_active_cacheline, cln);
-	spin_unlock_irqrestore(&radix_lock, flags);
+	xas_lock_irqsave(&xas, flags);
+	xas_load(&xas);
+	if (active_cacheline_dec_overlap(&xas) < 0)
+		xas_store(&xas, NULL);
+	xas_unlock_irqrestore(&xas, flags);
 }
 
 /**
@@ -578,12 +581,8 @@ static void active_cacheline_remove(struct dma_debug_entry *entry)
  */
 void debug_dma_assert_idle(struct page *page)
 {
-	static struct dma_debug_entry *ents[CACHELINES_PER_PAGE];
-	struct dma_debug_entry *entry = NULL;
-	void **results = (void **) &ents;
-	unsigned int nents, i;
-	unsigned long flags;
-	phys_addr_t cln;
+	struct dma_debug_entry *entry;
+	unsigned long cln;
 
 	if (dma_debug_disabled())
 		return;
@@ -591,21 +590,9 @@ void debug_dma_assert_idle(struct page *page)
 	if (!page)
 		return;
 
-	cln = (phys_addr_t) page_to_pfn(page) << CACHELINE_PER_PAGE_SHIFT;
-	spin_lock_irqsave(&radix_lock, flags);
-	nents = radix_tree_gang_lookup(&dma_active_cacheline, results, cln,
-				       CACHELINES_PER_PAGE);
-	for (i = 0; i < nents; i++) {
-		phys_addr_t ent_cln = to_cacheline_number(ents[i]);
-
-		if (ent_cln == cln) {
-			entry = ents[i];
-			break;
-		} else if (ent_cln >= cln + CACHELINES_PER_PAGE)
-			break;
-	}
-	spin_unlock_irqrestore(&radix_lock, flags);
-
+	cln = page_to_pfn(page) << CACHELINE_PER_PAGE_SHIFT;
+	entry = xa_find(&dma_active_cacheline, &cln,
+			cln + CACHELINES_PER_PAGE - 1, XA_PRESENT);
 	if (!entry)
 		return;
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
