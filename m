Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8948E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 15:47:09 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d71so14743699pgc.1
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 12:47:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t62sor28038256pfa.72.2018.12.18.12.47.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 12:47:07 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v2] mm, page_isolation: remove drain_all_pages() in set_migratetype_isolate()
Date: Wed, 19 Dec 2018 04:46:56 +0800
Message-Id: <20181218204656.4297-1-richard.weiyang@gmail.com>
In-Reply-To: <20181214023912.77474-1-richard.weiyang@gmail.com>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
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

Current logic is: isolate and drain pcp list for each pageblock and
drain pcp list again. This is not necessary and we could just drain pcp
list once after isolate this whole range.

The reason is start_isolate_page_range() will set the migrate type of
a range to MIGRATE_ISOLATE. After doing so, this range will never be
allocated from Buddy, neither to a real user nor to pcp list.

Since drain_all_pages() is zone based, by reduce times of
drain_all_pages() also reduce some contention on this particular zone.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---
v2: adjust changelog with MIGRATE_ISOLATE effects for the isolated range
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
