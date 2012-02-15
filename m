Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id CBDDE6B0092
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:57:24 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903161bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:57:24 -0800 (PST)
Subject: [PATCH RFC 04/15] mm: unify inactive_list_is_low()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:21 +0400
Message-ID: <20120215225721.22050.47829.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Unify memcg and non-memcg logic, always use exact counters from struct book.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   30 ++++++++----------------------
 1 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eddf617..61ffc8a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1815,6 +1815,7 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz,
 {
 	unsigned long active, inactive;
 	unsigned int ratio;
+	struct book *book;
 
 	/*
 	 * If we don't have swap space, anonymous page deactivation
@@ -1828,17 +1829,9 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz,
 	else
 		ratio = mem_cgroup_inactive_ratio(sc->target_mem_cgroup);
 
-	if (scanning_global_lru(mz)) {
-		active = zone_page_state(mz->zone, NR_ACTIVE_ANON);
-		inactive = zone_page_state(mz->zone, NR_INACTIVE_ANON);
-	} else {
-		active = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
-				zone_to_nid(mz->zone), zone_idx(mz->zone),
-				BIT(LRU_ACTIVE_ANON));
-		inactive = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
-				zone_to_nid(mz->zone), zone_idx(mz->zone),
-				BIT(LRU_INACTIVE_ANON));
-	}
+	book = mem_cgroup_zone_book(mz->zone, mz->mem_cgroup);
+	active = book->pages_count[NR_ACTIVE_ANON];
+	inactive = book->pages_count[NR_INACTIVE_ANON];
 
 	return inactive * ratio < active;
 }
@@ -1867,18 +1860,11 @@ static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz,
 static int inactive_file_is_low(struct mem_cgroup_zone *mz)
 {
 	unsigned long active, inactive;
+	struct book *book;
 
-	if (scanning_global_lru(mz)) {
-		active = zone_page_state(mz->zone, NR_ACTIVE_FILE);
-		inactive = zone_page_state(mz->zone, NR_INACTIVE_FILE);
-	} else {
-		active = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
-				zone_to_nid(mz->zone), zone_idx(mz->zone),
-				BIT(LRU_ACTIVE_FILE));
-		inactive = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
-				zone_to_nid(mz->zone), zone_idx(mz->zone),
-				BIT(LRU_INACTIVE_FILE));
-	}
+	book = mem_cgroup_zone_book(mz->zone, mz->mem_cgroup);
+	active = book->pages_count[NR_ACTIVE_FILE];
+	inactive = book->pages_count[NR_INACTIVE_FILE];
 
 	return inactive < active;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
