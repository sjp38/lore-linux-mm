Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D885C6B003A
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 20:12:35 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so8099028pdi.14
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:12:35 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so7958417pbc.26
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:12:33 -0700 (PDT)
Date: Mon, 14 Oct 2013 17:12:28 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCH 04/12] mm, thp, tmpfs: split huge page when moving from page
 cache to swap
Message-ID: <20131015001228.GE3432@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

in shmem_writepage, we have to split the huge page when moving pages
from page cache to swap because we don't support huge page in swap
yet.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 8fe17dd..68a0e1d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -898,6 +898,13 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	swp_entry_t swap;
 	pgoff_t index;
 
+	/* TODO: we have to break the huge page at this point,
+	 * since we have no idea how to recover a huge page from
+	 * swap.
+	 */
+	if (PageTransCompound(page))
+		split_huge_page(compound_trans_head(page));
+
 	BUG_ON(!PageLocked(page));
 	mapping = page->mapping;
 	index = page->index;
@@ -946,7 +953,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 			if (shmem_falloc)
 				goto redirty;
 		}
-		clear_highpage(page);
+		clear_pagecache_page(page);
 		flush_dcache_page(page);
 		SetPageUptodate(page);
 	}
-- 
1.8.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
