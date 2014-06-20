Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 39F2E6B0036
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 02:48:00 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so2654252pdb.21
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 23:47:59 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ns7si8490088pbb.248.2014.06.19.23.47.58
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 23:47:59 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFCv2 1/3] mm: Don't hide spin_lock in swap_info_get internal
Date: Fri, 20 Jun 2014 15:48:30 +0900
Message-Id: <1403246912-18237-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1403246912-18237-1-git-send-email-minchan@kernel.org>
References: <1403246912-18237-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

Now, swap_info_get hides lock holding by doing it internally
but releasing the lock so caller should release the lock.
Normally, it's not a good pattern and I need to handle lock
from caller in next patchset.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/swapfile.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8798b2e0ac59..ec2ce926ea5f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -740,7 +740,6 @@ static struct swap_info_struct *swap_info_get(swp_entry_t entry)
 		goto bad_offset;
 	if (!p->swap_map[offset])
 		goto bad_free;
-	spin_lock(&p->lock);
 	return p;
 
 bad_free:
@@ -835,6 +834,7 @@ void swap_free(swp_entry_t entry)
 
 	p = swap_info_get(entry);
 	if (p) {
+		spin_lock(&p->lock);
 		swap_entry_free(p, entry, 1);
 		spin_unlock(&p->lock);
 	}
@@ -849,6 +849,7 @@ void swapcache_free(swp_entry_t entry)
 
 	p = swap_info_get(entry);
 	if (p) {
+		spin_lock(&p->lock);
 		swap_entry_free(p, entry, SWAP_HAS_CACHE);
 		spin_unlock(&p->lock);
 	}
@@ -868,6 +869,7 @@ int page_swapcount(struct page *page)
 	entry.val = page_private(page);
 	p = swap_info_get(entry);
 	if (p) {
+		spin_lock(&p->lock);
 		count = swap_count(p->swap_map[swp_offset(entry)]);
 		spin_unlock(&p->lock);
 	}
@@ -950,6 +952,7 @@ int free_swap_and_cache(swp_entry_t entry)
 
 	p = swap_info_get(entry);
 	if (p) {
+		spin_lock(&p->lock);
 		if (swap_entry_free(p, entry, 1) == SWAP_HAS_CACHE) {
 			page = find_get_page(swap_address_space(entry),
 						entry.val);
@@ -2763,6 +2766,7 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 		goto outer;
 	}
 
+	spin_lock(&si->lock);
 	offset = swp_offset(entry);
 	count = si->swap_map[offset] & ~SWAP_HAS_CACHE;
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
