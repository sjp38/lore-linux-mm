Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 231C36B033E
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:11:57 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so56952425wmu.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 11:11:57 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f184si4044003wme.33.2016.11.17.11.11.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 11:11:56 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/9] mm: khugepaged: fix radix tree node leak in shmem collapse error path
Date: Thu, 17 Nov 2016 14:11:31 -0500
Message-Id: <20161117191138.22769-3-hannes@cmpxchg.org>
In-Reply-To: <20161117191138.22769-1-hannes@cmpxchg.org>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The radix tree counts valid entries in each tree node. Entries stored
in the tree cannot be removed by simpling storing NULL in the slot or
the internal counters will be off and the node never gets freed again.

When collapsing a shmem page fails, restore the holes that were filled
with radix_tree_insert() with a proper radix tree deletion.

Fixes: f3f0e1d2150b ("khugepaged: add support of collapse for tmpfs/shmem pages")
Reported-by: Jan Kara <jack@suse.cz>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/khugepaged.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index bdfdab40a813..d553c294de40 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1523,9 +1523,11 @@ static void collapse_shmem(struct mm_struct *mm,
 			if (!page || iter.index < page->index) {
 				if (!nr_none)
 					break;
-				/* Put holes back where they were */
-				radix_tree_replace_slot(slot, NULL);
 				nr_none--;
+				/* Put holes back where they were */
+				radix_tree_delete(&mapping->page_tree,
+						  iter.index);
+				slot = radix_tree_iter_next(&iter);
 				continue;
 			}
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
