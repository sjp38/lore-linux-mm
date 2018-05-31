Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B70EF6B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 23:23:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w7-v6so12026340pfd.9
        for <linux-mm@kvack.org>; Wed, 30 May 2018 20:23:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b29-v6sor12957856pfh.75.2018.05.30.20.23.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 20:23:26 -0700 (PDT)
Date: Wed, 30 May 2018 20:23:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix the NULL mapping case in __isolate_lru_page()
Message-ID: <alpine.LSU.2.11.1805302014001.12558@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, "Huang, Ying" <ying.huang@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

George Boole would have noticed a slight error in 4.16 commit 69d763fc6d3a
("mm: pin address_space before dereferencing it while isolating an LRU page").
Fix it, to match both the comment above it, and the original behaviour.

Although anonymous pages are not marked PageDirty at first, we have an
old habit of calling SetPageDirty when a page is removed from swap cache:
so there's a category of ex-swap pages that are easily migratable, but
were inadvertently excluded from compaction's async migration in 4.16.

Fixes: 69d763fc6d3a ("mm: pin address_space before dereferencing it while isolating an LRU page")
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 4.17-rc7/mm/vmscan.c	2018-04-26 10:48:36.027288294 -0700
+++ linux/mm/vmscan.c	2018-05-30 20:08:39.184634029 -0700
@@ -1418,7 +1418,7 @@ int __isolate_lru_page(struct page *page
 				return ret;
 
 			mapping = page_mapping(page);
-			migrate_dirty = mapping && mapping->a_ops->migratepage;
+			migrate_dirty = !mapping || mapping->a_ops->migratepage;
 			unlock_page(page);
 			if (!migrate_dirty)
 				return ret;
