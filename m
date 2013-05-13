Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 72C076B0033
	for <linux-mm@kvack.org>; Sun, 12 May 2013 22:11:00 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 2/4] mm: introduce __swapcache_free
Date: Mon, 13 May 2013 11:10:46 +0900
Message-Id: <1368411048-3753-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1368411048-3753-1-git-send-email-minchan@kernel.org>
References: <1368411048-3753-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

The __swapcache_free is almost same with swapcache_free
but only difference is that caller should pass stable swap_info_struct.

This function will be used by next patchsets.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/swapfile.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 2966978..33ebdd5 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -634,20 +634,26 @@ void swap_free(swp_entry_t entry)
 	}
 }
 
+
+void __swapcache_free(struct swap_info_struct *p,
+			swp_entry_t entry, struct page *page)
+{
+	unsigned char count;
+	count = swap_entry_free(p, entry, SWAP_HAS_CACHE);
+	mem_cgroup_uncharge_swapcache(page, entry, count != 0);
+}
+
 /*
  * Called after dropping swapcache to decrease refcnt to swap entries.
  */
 void swapcache_free(swp_entry_t entry, struct page *page)
 {
 	struct swap_info_struct *p;
-	unsigned char count;
 
 	p = swap_info_get(entry);
 	if (p) {
 		spin_lock(&p->lock);
-		count = swap_entry_free(p, entry, SWAP_HAS_CACHE);
-		if (page)
-			mem_cgroup_uncharge_swapcache(page, entry, count != 0);
+		__swapcache_free(p, entry, page);
 		spin_unlock(&p->lock);
 	}
 }
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
