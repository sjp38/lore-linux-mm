Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 95FF36B0085
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 10:03:30 -0500 (EST)
Received: by mail-iw0-f169.google.com with SMTP id 38so3377619iwn.14
        for <linux-mm@kvack.org>; Sun, 28 Nov 2010 07:03:29 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 2/3] move ClearPageReclaim
Date: Mon, 29 Nov 2010 00:02:56 +0900
Message-Id: <c3b1c78f0e2eba5dfebda7c363c4274e649ab36a.1290956059.git.minchan.kim@gmail.com>
In-Reply-To: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
In-Reply-To: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

fe3cba17 added ClearPageReclaim into clear_page_dirty_for_io for
preventing fast reclaiming readahead marker page.

In this series, PG_reclaim is used by invalidated page, too.
If VM find the page is invalidated and it's dirty, it sets PG_reclaim
to reclaim asap. Then, when the dirty page will be writeback,
clear_page_dirty_for_io will clear PG_reclaim unconditionally.
It disturbs this serie's goal.

I think it's okay to clear PG_readahead when the page is dirty, not
writeback time. So this patch moves ClearPageReadahead.
This patch needs Wu's opinion.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Mel Gorman <mel@csn.ul.ie>
---
 fs/buffer.c         |    1 +
 mm/page-writeback.c |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 20a41c6..b920086 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -717,6 +717,7 @@ int __set_page_dirty_buffers(struct page *page)
 	int newly_dirty;
 	struct address_space *mapping = page_mapping(page);
 
+	ClearPageReclaim(page);
 	if (unlikely(!mapping))
 		return !TestSetPageDirty(page);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index fc93802..962b0d8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1146,6 +1146,7 @@ EXPORT_SYMBOL(write_one_page);
  */
 int __set_page_dirty_no_writeback(struct page *page)
 {
+	ClearPageReclaim(page);
 	if (!PageDirty(page))
 		return !TestSetPageDirty(page);
 	return 0;
@@ -1196,6 +1197,7 @@ EXPORT_SYMBOL(account_page_writeback);
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
+	ClearPageReclaim(page);
 	if (!TestSetPageDirty(page)) {
 		struct address_space *mapping = page_mapping(page);
 		struct address_space *mapping2;
@@ -1258,6 +1260,8 @@ int set_page_dirty(struct page *page)
 #endif
 		return (*spd)(page);
 	}
+
+	ClearPageReclaim(page);
 	if (!PageDirty(page)) {
 		if (!TestSetPageDirty(page))
 			return 1;
@@ -1280,6 +1284,7 @@ int set_page_dirty_lock(struct page *page)
 {
 	int ret;
 
+	ClearPageReclaim(page);
 	lock_page_nosync(page);
 	ret = set_page_dirty(page);
 	unlock_page(page);
@@ -1307,7 +1312,6 @@ int clear_page_dirty_for_io(struct page *page)
 
 	BUG_ON(!PageLocked(page));
 
-	ClearPageReclaim(page);
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		/*
 		 * Yes, Virginia, this is indeed insane.
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
