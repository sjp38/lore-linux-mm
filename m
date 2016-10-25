Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3B76B0268
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:16 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id r13so547975pag.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:16 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m8si17919501pfa.203.2016.10.24.17.14.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 15/43] filemap: allocate huge page in pagecache_get_page(), if allowed
Date: Tue, 25 Oct 2016 03:13:14 +0300
Message-Id: <20161025001342.76126-16-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Write path allocate pages using pagecache_get_page(). We should be able
to allocate huge pages there, if it's allowed. As usually, fallback to
small pages, if failed.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index ca4536f2035e..954720092cf8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1352,13 +1352,16 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 
 no_page:
 	if (!page && (fgp_flags & FGP_CREAT)) {
+		pgoff_t hoffset;
 		int err;
 		if ((fgp_flags & FGP_WRITE) && mapping_cap_account_dirty(mapping))
 			gfp_mask |= __GFP_WRITE;
 		if (fgp_flags & FGP_NOFS)
 			gfp_mask &= ~__GFP_FS;
 
-		page = __page_cache_alloc(gfp_mask);
+		page = page_cache_alloc_huge(mapping, offset, gfp_mask);
+no_huge:	if (!page)
+			page = __page_cache_alloc(gfp_mask);
 		if (!page)
 			return NULL;
 
@@ -1369,14 +1372,25 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		if (fgp_flags & FGP_ACCESSED)
 			__SetPageReferenced(page);
 
-		err = add_to_page_cache_lru(page, mapping, offset,
+		if (PageTransHuge(page))
+			hoffset = round_down(offset, HPAGE_PMD_NR);
+		else
+			hoffset = offset;
+
+		err = add_to_page_cache_lru(page, mapping, hoffset,
 				gfp_mask & GFP_RECLAIM_MASK);
 		if (unlikely(err)) {
+			if (PageTransHuge(page)) {
+				put_page(page);
+				page = NULL;
+				goto no_huge;
+			}
 			put_page(page);
 			page = NULL;
 			if (err == -EEXIST)
 				goto repeat;
 		}
+		page += offset - hoffset;
 	}
 
 	return page;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
