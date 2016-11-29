Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90BA0280253
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:27 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y71so421376235pgd.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:27 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q71si59468288pfj.175.2016.11.29.03.23.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:26 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 09/36] filemap: allocate huge page in pagecache_get_page(), if allowed
Date: Tue, 29 Nov 2016 14:22:37 +0300
Message-Id: <20161129112304.90056-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Write path allocate pages using pagecache_get_page(). We should be able
to allocate huge pages there, if it's allowed. As usually, fallback to
small pages, if failed.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 6a2f9ea521fb..ec976ddcb88a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1237,13 +1237,16 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 
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
 
@@ -1254,9 +1257,19 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
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
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
