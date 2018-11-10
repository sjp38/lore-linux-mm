Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE0FB6B0782
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 03:51:04 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id p29so2794759ote.3
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 00:51:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f94sor5218209otb.3.2018.11.10.00.51.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Nov 2018 00:51:03 -0800 (PST)
From: john.hubbard@gmail.com
Subject: [PATCH v2 5/6] mm: introduce zone_gup_lock, for dma-pinned pages
Date: Sat, 10 Nov 2018 00:50:40 -0800
Message-Id: <20181110085041.10071-6-jhubbard@nvidia.com>
In-Reply-To: <20181110085041.10071-1-jhubbard@nvidia.com>
References: <20181110085041.10071-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>

From: John Hubbard <jhubbard@nvidia.com>

The page->dma_pinned_flags and _count fields require
lock protection. A lock at approximately the granularity
of the zone_lru_lock is called for, but adding to the
locking contention of zone_lru_lock is undesirable,
because that is a pre-existing hot spot. Fortunately,
these new dma_pinned_* fields can use an independent
lock, so this patch creates an entirely new lock, right
next to the zone_lru_lock.

Why "zone_gup_lock"?

Most of the naming refers to "DMA-pinned pages", but
"zone DMA lock" has other meanings already, so this is
called zone_gup_lock instead. The "dma pinning" is a result
of get_user_pages (gup) being called, so the name still
helps explain its use.

Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mmzone.h | 6 ++++++
 mm/page_alloc.c        | 1 +
 2 files changed, 7 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 847705a6d0ec..125a6f34f6ba 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -660,6 +660,7 @@ typedef struct pglist_data {
 	enum zone_type kswapd_classzone_idx;
 
 	int kswapd_failures;		/* Number of 'reclaimed == 0' runs */
+	spinlock_t pinned_dma_lock;
 
 #ifdef CONFIG_COMPACTION
 	int kcompactd_max_order;
@@ -729,6 +730,11 @@ static inline spinlock_t *zone_lru_lock(struct zone *zone)
 	return &zone->zone_pgdat->lru_lock;
 }
 
+static inline spinlock_t *zone_gup_lock(struct zone *zone)
+{
+	return &zone->zone_pgdat->pinned_dma_lock;
+}
+
 static inline struct lruvec *node_lruvec(struct pglist_data *pgdat)
 {
 	return &pgdat->lruvec;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a919ba5cb3c8..7cc0d9bdba17 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6305,6 +6305,7 @@ static void __meminit pgdat_init_internals(struct pglist_data *pgdat)
 
 	pgdat_page_ext_init(pgdat);
 	spin_lock_init(&pgdat->lru_lock);
+	spin_lock_init(&pgdat->pinned_dma_lock);
 	lruvec_init(node_lruvec(pgdat));
 }
 
-- 
2.19.1
