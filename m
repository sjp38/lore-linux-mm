Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05BCE28026B
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:56:42 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu14so17663474pad.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:56:41 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id bx7si3466408pac.110.2016.09.15.04.56.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:56:41 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 16/41] filemap: allocate huge page in pagecache_get_page(), if allowed
Date: Thu, 15 Sep 2016 14:54:58 +0300
Message-Id: <20160915115523.29737-17-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
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
index b77bcf6843ee..05b42d3e5ed8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1310,13 +1310,16 @@ repeat:
 
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
 
@@ -1327,14 +1330,25 @@ no_page:
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
