Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2FC36B033C
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:11:54 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g23so57384796wme.4
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 11:11:54 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d7si4144445wjf.81.2016.11.17.11.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 11:11:53 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/9] mm: khugepaged: close use-after-free race during shmem collapsing
Date: Thu, 17 Nov 2016 14:11:30 -0500
Message-Id: <20161117191138.22769-2-hannes@cmpxchg.org>
In-Reply-To: <20161117191138.22769-1-hannes@cmpxchg.org>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

When a radix tree iteration drops the tree lock, another thread might
swoop in and free the node holding the current slot. The iteration
needs to do another tree lookup from the current index to continue.

[kirill.shutemov@linux.intel.com: re-lookup for replacement]
Fixes: f3f0e1d2150b ("khugepaged: add support of collapse for tmpfs/shmem pages")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/khugepaged.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 728d7790dc2d..bdfdab40a813 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1401,6 +1401,9 @@ static void collapse_shmem(struct mm_struct *mm,
 
 		spin_lock_irq(&mapping->tree_lock);
 
+		slot = radix_tree_lookup_slot(&mapping->page_tree, index);
+		VM_BUG_ON_PAGE(page != radix_tree_deref_slot_protected(slot,
+					&mapping->tree_lock), page);
 		VM_BUG_ON_PAGE(page_mapped(page), page);
 
 		/*
@@ -1424,6 +1427,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		radix_tree_replace_slot(slot,
 				new_page + (index % HPAGE_PMD_NR));
 
+		slot = radix_tree_iter_next(&iter);
 		index++;
 		continue;
 out_lru:
@@ -1535,6 +1539,7 @@ static void collapse_shmem(struct mm_struct *mm,
 			putback_lru_page(page);
 			unlock_page(page);
 			spin_lock_irq(&mapping->tree_lock);
+			slot = radix_tree_iter_next(&iter);
 		}
 		VM_BUG_ON(nr_none);
 		spin_unlock_irq(&mapping->tree_lock);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
