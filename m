Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C57E66B026A
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:36:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p64so437469501pfb.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:36:34 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id cc15si36082537pac.249.2016.07.25.17.36.20
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 17:36:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 17/33] HACK: readahead: alloc huge pages, if allowed
Date: Tue, 26 Jul 2016 03:35:19 +0300
Message-Id: <1469493335-3622-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Most page cache allocation happens via readahead (sync or async), so if
we want to have significant number of huge pages in page cache we need
to find a ways to allocate them from readahead.

Unfortunately, huge pages doesn't fit into current readahead design:
128 max readahead window, assumption on page size, PageReadahead() to
track hit/miss.

I haven't found a ways to get it right yet.

This patch just allocates huge page if allowed, but doesn't really
provide any readahead if huge page is allocated. We read out 2M a time
and I would expect spikes in latancy without readahead.

Therefore HACK.

Any suggestions are welcome.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/readahead.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 65ec288dc057..3d7742a687f2 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -173,6 +173,20 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		if (page_offset > end_index)
 			break;
 
+		if ((!page_idx || page_offset % HPAGE_PMD_NR == 0) &&
+				page_cache_allow_huge(mapping, page_offset)) {
+			page = __page_cache_alloc_order(gfp_mask | __GFP_COMP,
+					HPAGE_PMD_ORDER);
+			if (page) {
+				prep_transhuge_page(page);
+				page->index = round_down(page_offset,
+						HPAGE_PMD_NR);
+				list_add(&page->lru, &page_pool);
+				ret++;
+				goto start_io;
+			}
+		}
+
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
 		rcu_read_unlock();
@@ -188,7 +202,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			SetPageReadahead(page);
 		ret++;
 	}
-
+start_io:
 	/*
 	 * Now start the IO.  We ignore I/O errors - if the page is not
 	 * uptodate then the caller will launch readpage again, and
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
