Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id E446F8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:20:28 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id k22-v6so5469732ljk.12
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:20:28 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id y7-v6si654518ljj.102.2019.01.14.08.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 08:20:26 -0800 (PST)
Subject: [PATCH] mm: Remove 7th argument of isolate_lru_pages()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 14 Jan 2019 19:20:24 +0300
Message-ID: <154748280735.29962.15867846875217618569.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, ktkhai@virtuozzo.com, linux-mm@kvack.org

We may simply check for sc->may_unmap in isolate_lru_pages()
instead of doing that in both of its callers.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a714c4f800e9..8202f8eb602d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1663,7 +1663,7 @@ static __always_inline void update_lru_sizes(struct lruvec *lruvec,
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct lruvec *lruvec, struct list_head *dst,
 		unsigned long *nr_scanned, struct scan_control *sc,
-		isolate_mode_t mode, enum lru_list lru)
+		enum lru_list lru)
 {
 	struct list_head *src = &lruvec->lists[lru];
 	unsigned long nr_taken = 0;
@@ -1672,6 +1672,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long skipped = 0;
 	unsigned long scan, total_scan, nr_pages;
 	LIST_HEAD(pages_skipped);
+	isolate_mode_t mode = (sc->may_unmap ? 0 : ISOLATE_UNMAPPED);
 
 	scan = 0;
 	for (total_scan = 0;
@@ -1910,7 +1911,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
 	struct reclaim_stat stat = {};
-	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
@@ -1931,13 +1931,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	lru_add_drain();
 
-	if (!sc->may_unmap)
-		isolate_mode |= ISOLATE_UNMAPPED;
-
 	spin_lock_irq(&pgdat->lru_lock);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
-				     &nr_scanned, sc, isolate_mode, lru);
+				     &nr_scanned, sc, lru);
 
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
@@ -2094,19 +2091,15 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	unsigned nr_deactivate, nr_activate;
 	unsigned nr_rotated = 0;
-	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 
 	lru_add_drain();
 
-	if (!sc->may_unmap)
-		isolate_mode |= ISOLATE_UNMAPPED;
-
 	spin_lock_irq(&pgdat->lru_lock);
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
-				     &nr_scanned, sc, isolate_mode, lru);
+				     &nr_scanned, sc, lru);
 
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
