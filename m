Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2590E6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 15:34:49 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 44-v6so17697085wrt.9
        for <linux-mm@kvack.org>; Thu, 31 May 2018 12:34:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9-v6sor1014426wrp.71.2018.05.31.12.34.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 12:34:47 -0700 (PDT)
From: Ivan Kalvachev <ikalvachev@gmail.com>
Subject: [PATCH] mm: fix kswap excessive pressure after wrong condition transfer
Date: Thu, 31 May 2018 22:34:20 +0300
Message-Id: <20180531193420.26087-1-ikalvachev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ivan Kalvachev <ikalvachev@gmail.com>

Fixes commit 69d763fc6d3aee787a3e8c8c35092b4f4960fa5d
(mm: pin address_space before dereferencing it while isolating an LRU page)

working code:

    mapping = page_mapping(page);
    if (mapping && !mapping->a_ops->migratepage)
        return ret;

buggy code:

    if (!trylock_page(page))
        return ret;

    mapping = page_mapping(page);
    migrate_dirty = mapping && mapping->a_ops->migratepage;
    unlock_page(page);
    if (!migrate_dirty)
        return ret;

The problem is that !(a && b) = (!a || !b) while the old code was (a && !b).
The commit message of the buggy commit explains the need for locking/unlocking
around the check but does not give any reason for the change of the condition.
It seems to be an unintended change.

The result of that change is noticeable under swap pressure.
Big memory consumers like browsers would have a lot of pages swapped out,
even pages that are been used actively, causing the process to repeatedly
block for second or longer. At the same time there would be gigabytes of
unused free memory (sometimes half of the total RAM).
The buffers/cache would also be at minimum size.

Fixes: 69d763fc6d3a ("mm: pin address_space before dereferencing it while isolating an LRU page")
Signed-off-by: Ivan Kalvachev <ikalvachev@gmail.com>
---
 mm/vmscan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9b697323a88c..83df26078d13 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1418,9 +1418,9 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 				return ret;
 
 			mapping = page_mapping(page);
-			migrate_dirty = mapping && mapping->a_ops->migratepage;
+			migrate_dirty = mapping && !mapping->a_ops->migratepage;
 			unlock_page(page);
-			if (!migrate_dirty)
+			if (migrate_dirty)
 				return ret;
 		}
 	}
-- 
2.17.1
