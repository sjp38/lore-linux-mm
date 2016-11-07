Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 710846B0253
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 14:08:01 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so66740752wmu.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 11:08:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id nc5si26835617wjb.223.2016.11.07.11.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 11:08:00 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/6] mm: khugepaged: fix radix tree node leak in shmem collapse error path
Date: Mon,  7 Nov 2016 14:07:36 -0500
Message-Id: <20161107190741.3619-2-hannes@cmpxchg.org>
In-Reply-To: <20161107190741.3619-1-hannes@cmpxchg.org>
References: <20161107190741.3619-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The radix tree counts valid entries in each tree node. Entries stored
in the tree cannot be removed by simpling storing NULL in the slot or
the internal counters will be off and the node never gets freed again.

When collapsing a shmem page fails, restore the holes that were filled
with radix_tree_insert() with a proper radix tree deletion.

Fixes: f3f0e1d2150b ("khugepaged: add support of collapse for tmpfs/shmem pages")
Reported-by: Jan Kara <jack@suse.cz>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/khugepaged.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 728d7790dc2d..eac6f0580e26 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1520,7 +1520,8 @@ static void collapse_shmem(struct mm_struct *mm,
 				if (!nr_none)
 					break;
 				/* Put holes back where they were */
-				radix_tree_replace_slot(slot, NULL);
+				radix_tree_delete(&mapping->page_tree,
+						  iter.index);
 				nr_none--;
 				continue;
 			}
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
