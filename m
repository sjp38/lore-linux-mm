Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4FF48E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 21:39:21 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id p3so2643712plk.9
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 18:39:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z83sor5868780pfd.11.2018.12.13.18.39.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Dec 2018 18:39:20 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, page_isolation: remove drain_all_pages() in set_migratetype_isolate()
Date: Fri, 14 Dec 2018 10:39:12 +0800
Message-Id: <20181214023912.77474-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de, david@redhat.com, Wei Yang <richard.weiyang@gmail.com>

Below is a brief call flow for __offline_pages() and
alloc_contig_range():

  __offline_pages()/alloc_contig_range()
      start_isolate_page_range()
          set_migratetype_isolate()
              drain_all_pages()
      drain_all_pages()

Since set_migratetype_isolate() is only used in
start_isolate_page_range(), which is just used in __offline_pages() and
alloc_contig_range(). And both of them call drain_all_pages() if every
check looks good. This means it is not necessary call drain_all_pages()
in each iteration of set_migratetype_isolate().

By doing so, the logic seems a little bit clearer.
set_migratetype_isolate() handles pages in Buddy, while
drain_all_pages() takes care of pages in pcp.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_isolation.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 43e085608846..f44c0e333bed 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -83,8 +83,6 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
-	if (!ret)
-		drain_all_pages(zone);
 	return ret;
 }
 
-- 
2.15.1
