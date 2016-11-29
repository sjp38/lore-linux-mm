Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 382946B0270
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:41 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so424900449pgd.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:41 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q71si59468288pfj.175.2016.11.29.03.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 24/36] ext4: make ext4_mpage_readpages() hugepage-aware
Date: Tue, 29 Nov 2016 14:22:52 +0300
Message-Id: <20161129112304.90056-25-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As BIO_MAX_PAGES is smaller (on x86) than HPAGE_PMD_NR, we cannot use
the optimization ext4_mpage_readpages() provides.

So, for huge pages, we fallback directly to block_read_full_page().

This should be re-visited once we get multipage bvec upstream.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/readpage.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index a81b829d56de..b865df0c0973 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -134,7 +134,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 				goto next_page;
 		}
 
-		if (page_has_buffers(page))
+		if (page_has_buffers(page) || PageTransHuge(page))
 			goto confused;
 
 		block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
