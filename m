Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id C2A4F6B00AD
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 07:39:39 -0400 (EDT)
Received: by dakp5 with SMTP id p5so11038954dak.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 04:39:39 -0700 (PDT)
From: Robin Dong <hao.bigrat@gmail.com>
Subject: [PATCH] mm: fix ununiform page status when writing new file with small buffer
Date: Wed,  6 Jun 2012 19:39:30 +0800
Message-Id: <1338982770-2856-1-git-send-email-hao.bigrat@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Robin Dong <sanbai@taobao.com>

From: Robin Dong <sanbai@taobao.com>

When writing a new file with 2048 bytes buffer, such as write(fd, buffer, 2048), it will
call generic_perform_write() twice for every page:

	write_begin
	mark_page_accessed(page) 
	write_end

	write_begin
	mark_page_accessed(page) 
	write_end

The page 1~13th will be added to lru_add_pvecs in write_begin() and will *NOT* be added to
active_list even they have be accessed twice because they are not PageLRU(page).
But when page 14th comes, all pages will be moved from lru_add_pvecs to active_list
(by __lru_cache_add() ) in first write_begin(), now page 14th *is* PageLRU(page) and after
second write_end() it will be in active_list.

In Hadoop environment, we do comes to this situation: after writing a file, we find
out that only 14th, 28th, 42th... page are in active_list and others in inactive_list. Now
kswaped works, shrinks the inactive_list, the file only have 14th, 28th...pages in memory,
the readahead request size will be broken to only 52k (13*4k), system's performance falls
dramatically.

This problem can also replay by below steps (the machine has 8G memory):

	1. dd if=/dev/zero of=/test/file.out bs=1024 count=1048576
	2. cat another 7.5G file to /dev/null
	3. vmtouch -m 1G -v /test/file.out, it will show:

	/test/file.out
	[oooooooooooooooooooOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO] 187847/262144

	the 'o' means same pages are in memory but same are not.


The solution for this problem is simple: the 14th page should be added to lru_add_pvecs
before mark_page_accessed() just as other pages.

Signed-off-by: Robin Dong <sanbai@taobao.com>
---
 mm/swap.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index 4e7e2ec..0874d44 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -399,8 +399,9 @@ void __lru_cache_add(struct page *page, enum lru_list lru)
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs)[lru];
 
 	page_cache_get(page);
-	if (!pagevec_add(pvec, page))
+	if (!pagevec_space(pvec))
 		__pagevec_lru_add(pvec, lru);
+	pagevec_add(pvec, page);
 	put_cpu_var(lru_add_pvecs);
 }
 EXPORT_SYMBOL(__lru_cache_add);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
