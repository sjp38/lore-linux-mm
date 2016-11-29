Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D02A16B027D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x23so426486925pgx.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:57 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 63si59338199pgi.211.2016.11.29.03.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:57 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 11/36] HACK: readahead: alloc huge pages, if allowed
Date: Tue, 29 Nov 2016 14:22:39 +0300
Message-Id: <20161129112304.90056-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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

Having that said, I don't think it should prevent huge page support to
be applied. Future will show if lacking readahead is a big deal with
huge pages in page cache.

Any suggestions are welcome.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/readahead.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index fb4c99f85618..87e38b522645 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -174,6 +174,21 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		if (page_offset > end_index)
 			break;
 
+		if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
+				(!page_idx || !(page_offset % HPAGE_PMD_NR)) &&
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
@@ -189,7 +204,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			SetPageReadahead(page);
 		ret++;
 	}
-
+start_io:
 	/*
 	 * Now start the IO.  We ignore I/O errors - if the page is not
 	 * uptodate then the caller will launch readpage again, and
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
