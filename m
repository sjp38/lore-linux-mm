Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C75B882F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 02:28:42 -0400 (EDT)
Received: by pasz6 with SMTP id z6so20608783pas.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 23:28:42 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id fb1si50297088pbb.106.2015.10.18.23.28.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Oct 2015 23:28:41 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 5/5] mm: mark stable page dirty in KSM
Date: Mon, 19 Oct 2015 15:31:47 +0900
Message-Id: <1445236307-895-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1445236307-895-1-git-send-email-minchan@kernel.org>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

Stable page could be shared by several processes and last process
could own the page among them after CoW or zapping for every process
except last process happens. Then, page table entry of the page
in last process can have no dirty bit and PG_dirty flag in page->flags.
In this case, MADV_FREE could discard the page wrongly.
For preventing it, we mark stable page dirty.

Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/ksm.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/ksm.c b/mm/ksm.c
index 8f0faf809bf5..659e2b5119c0 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1050,6 +1050,18 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 			 */
 			set_page_stable_node(page, NULL);
 			mark_page_accessed(page);
+			/*
+			 * Stable page could be shared by several processes
+			 * and last process could own the page among them after
+			 * CoW or zapping for every process except last process
+			 * happens. Then, page table entry of the page
+			 * in last process can have no dirty bit.
+			 * In this case, MADV_FREE could discard the page
+			 * wrongly.
+			 * For preventing it, we mark stable page dirty.
+			 */
+			if (!PageDirty(page))
+				SetPageDirty(page);
 			err = 0;
 		} else if (pages_identical(page, kpage))
 			err = replace_page(vma, page, kpage, orig_pte);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
