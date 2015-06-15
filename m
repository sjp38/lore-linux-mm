Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 606916B006C
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 03:51:08 -0400 (EDT)
Received: by labko7 with SMTP id ko7so52302153lab.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:07 -0700 (PDT)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com. [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id mk5si9854750lbc.47.2015.06.15.00.51.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 00:51:06 -0700 (PDT)
Received: by lbbti3 with SMTP id ti3so10735776lbb.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:05 -0700 (PDT)
Subject: [PATCH RFC v0 1/6] pagevec: segmented page vectors
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Mon, 15 Jun 2015 10:51:01 +0300
Message-ID: <20150615075101.18112.67630.stgit@zurg>
In-Reply-To: <20150615073926.18112.59207.stgit@zurg>
References: <20150615073926.18112.59207.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This patch adds helpers for linking several page vectors into
segmented chain and macro for iterating over this chain.

For linking it uses space formerly used for field 'cold' which
is now stored as a lower bit in pointer to the next segment.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/linux/pagevec.h |   48 ++++++++++++++++++++++++++++++++++++++++++++---
 mm/swap.c               |   44 +++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 87 insertions(+), 5 deletions(-)

diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index b45d391..de3ea58 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -16,7 +16,7 @@ struct address_space;
 
 struct pagevec {
 	unsigned long nr;
-	unsigned long cold;
+	unsigned long _next;
 	struct page *pages[PAGEVEC_SIZE];
 };
 
@@ -32,11 +32,23 @@ unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, int tag,
 		unsigned nr_pages);
+struct pagevec *pagevec_extend(struct pagevec *pvec, gfp_t gfpmask);
+void pagevec_shrink(struct pagevec *pvec);
 
-static inline void pagevec_init(struct pagevec *pvec, int cold)
+static inline bool pagevec_cold(struct pagevec *pvec)
+{
+	return pvec->_next & 1;
+}
+
+static inline struct pagevec *pagevec_next(struct pagevec *pvec)
+{
+	return (struct pagevec *)(pvec->_next & ~1ul);
+}
+
+static inline void pagevec_init(struct pagevec *pvec, bool cold)
 {
 	pvec->nr = 0;
-	pvec->cold = cold;
+	pvec->_next = cold;
 }
 
 static inline void pagevec_reinit(struct pagevec *pvec)
@@ -69,4 +81,34 @@ static inline void pagevec_release(struct pagevec *pvec)
 		__pagevec_release(pvec);
 }
 
+/**
+ * pagevec_for_each_page - iterate over all pages in single page vector *
+ * @pv		pointer to page vector
+ * @i		int variable used as index
+ * @page	pointer to struct page
+ */
+#define pagevec_for_each_page(pv, i, page) \
+	for (i = 0; (i < (pv)->nr) && (page = (pv)->pages[i], true); i++)
+
+/**
+ * pagevec_for_each_vec - iterate over all segments in page vector
+ * @pv		pointer to head page vector
+ * @v		pointer for current page vector segment
+ */
+#define pagevec_for_each_vec(pv, v) \
+	for (v = (pv); v; v = pagevec_next(v))
+
+/**
+ * pagevec_for_each_vec_and_page - iterate over all pages in segmented vector
+ * @pv		pointer to head page vector
+ * @v		pointer for current page vector segment
+ * @i		int variable used index in current segment
+ * @page	pointer to struct page
+ *
+ * Warning: this is double loop, "break" does not work.
+ */
+#define pagevec_for_each_vec_and_page(pv, v, i, page) \
+	pagevec_for_each_vec(pv, v) \
+		pagevec_for_each_page(v, i, page)
+
 #endif /* _LINUX_PAGEVEC_H */
diff --git a/mm/swap.c b/mm/swap.c
index a7251a8..3ec0eb5 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -32,6 +32,7 @@
 #include <linux/gfp.h>
 #include <linux/uio.h>
 #include <linux/hugetlb.h>
+#include <linux/slab.h>
 
 #include "internal.h"
 
@@ -440,7 +441,7 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 	}
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	release_pages(pvec->pages, pagevec_count(pvec), pagevec_cold(pvec));
 	pagevec_reinit(pvec);
 }
 
@@ -982,7 +983,7 @@ EXPORT_SYMBOL(release_pages);
 void __pagevec_release(struct pagevec *pvec)
 {
 	lru_add_drain();
-	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
+	release_pages(pvec->pages, pagevec_count(pvec), pagevec_cold(pvec));
 	pagevec_reinit(pvec);
 }
 EXPORT_SYMBOL(__pagevec_release);
@@ -1137,6 +1138,45 @@ unsigned pagevec_lookup_tag(struct pagevec *pvec, struct address_space *mapping,
 }
 EXPORT_SYMBOL(pagevec_lookup_tag);
 
+/**
+ * pagevec_extend - allocate, initialize and link next page vector
+ * @pvec:	page vector for extending
+ * @gfpmask:
+ *
+ * Returns pointer to new page vector or NULL if allocation failed.
+ */
+struct pagevec *pagevec_extend(struct pagevec *pvec, gfp_t gfpmask)
+{
+	struct pagevec *next;
+
+	next = kmalloc(sizeof(struct pagevec), gfpmask);
+	if (next) {
+		bool cold = pagevec_cold(pvec);
+		pagevec_init(next, cold);
+		pvec->_next = (unsigned long)next + cold;
+	}
+	return next;
+}
+
+/**
+ * pagevec_shrink - free all following page vectors segments
+ * @pvec:	head page vector
+ *
+ * Head vector and pages are not freed.
+ */
+void pagevec_shrink(struct pagevec *head)
+{
+	struct pagevec *pvec, *next;
+
+	pvec = pagevec_next(head);
+	head->_next &= 1ul;
+	while (pvec) {
+		next = pagevec_next(pvec);
+		kfree(pvec);
+		pvec = next;
+	}
+}
+
 /*
  * Perform any setup for the swap system
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
