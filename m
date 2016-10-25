Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3416B0262
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e6so131293848pfk.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:09 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p187si17912762pfg.145.2016.10.24.17.14.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 12/43] truncate: make sure invalidate_mapping_pages() can discard huge pages
Date: Tue, 25 Oct 2016 03:13:11 +0300
Message-Id: <20161025001342.76126-13-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

invalidate_inode_page() has expectation about page_count() of the page
-- if it's not 2 (one to caller, one to radix-tree), it will not be
dropped. That condition almost never met for THPs -- tail pages are
pinned to the pagevec.

Let's drop them, before calling invalidate_inode_page().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/truncate.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/truncate.c b/mm/truncate.c
index a01cce450a26..393bf9447231 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -504,10 +504,22 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 				/* 'end' is in the middle of THP */
 				if (index ==  round_down(end, HPAGE_PMD_NR))
 					continue;
+				/*
+				 * invalidate_inode_page() expects
+				 * page_count(page) == 2 to drop page from page
+				 * cache -- drop tail pages references.
+				 */
+				get_page(page);
+				pagevec_remove_exceptionals(&pvec);
+				pagevec_release(&pvec);
 			}
 
 			ret = invalidate_inode_page(page);
 			unlock_page(page);
+
+			if (PageTransHuge(page))
+				put_page(page);
+
 			/*
 			 * Invalidation is a hint that the page is no longer
 			 * of interest and try to speed up its reclaim.
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
