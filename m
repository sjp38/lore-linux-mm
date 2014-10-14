Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA3B6B006C
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 16:16:55 -0400 (EDT)
Received: by mail-oi0-f51.google.com with SMTP id h136so17754300oig.24
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 13:16:55 -0700 (PDT)
Received: from mail-oi0-x249.google.com (mail-oi0-x249.google.com [2607:f8b0:4003:c06::249])
        by mx.google.com with ESMTPS id oz16si19965110oeb.36.2014.10.14.13.16.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Oct 2014 13:16:54 -0700 (PDT)
Received: by mail-oi0-f73.google.com with SMTP id u20so3306494oif.4
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 13:16:54 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH 2/2] mm: verify compound order when freeing a page
Date: Tue, 14 Oct 2014 13:16:40 -0700
Message-Id: <1413317800-25450-2-git-send-email-yuzhao@google.com>
In-Reply-To: <1413317800-25450-1-git-send-email-yuzhao@google.com>
References: <1413317800-25450-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

This allows us to easily catch the bug fixed in previous patch.

Here we also verify whether a page is tail page or not -- tail
pages are supposed to be freed along with their head, not by
themselves.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 736d8e1..2bcc770 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -750,6 +750,9 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	int i;
 	int bad = 0;
 
+	VM_BUG_ON(PageTail(page));
+	VM_BUG_ON(PageHead(page) && compound_order(page) != order);
+
 	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
 
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
