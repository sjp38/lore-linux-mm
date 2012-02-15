Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C1BE16B00F0
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:57:50 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903449bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:57:50 -0800 (PST)
Subject: [PATCH RFC 11/15] mm: handle book relock in memory controller
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:47 +0400
Message-ID: <20120215225747.22050.21367.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Carefully relock book lru lock at page memory cgroup change.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/memcontrol.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 84e04ae..90e21d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2535,7 +2535,6 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
 					enum charge_type ctype)
 {
 	struct page_cgroup *pc = lookup_page_cgroup(page);
-	struct zone *zone = page_zone(page);
 	struct book *book;
 	unsigned long flags;
 	bool removed = false;
@@ -2545,20 +2544,19 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
 	 * is already on LRU. It means the page may on some other page_cgroup's
 	 * LRU. Take care of it.
 	 */
-	spin_lock_irqsave(&zone->lru_lock, flags);
+	book = lock_page_book(page, &flags);
 	if (PageLRU(page)) {
-		book = page_book(page);
 		del_page_from_lru_list(book, page, page_lru(page));
 		ClearPageLRU(page);
 		removed = true;
 	}
 	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
 	if (removed) {
-		book = page_book(page);
+		book = __relock_page_book(book, page);
 		add_page_to_lru_list(book, page, page_lru(page));
 		SetPageLRU(page);
 	}
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
+	unlock_book(book, &flags);
 	return;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
