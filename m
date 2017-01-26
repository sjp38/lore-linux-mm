Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E54596B027D
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:51 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d123so54352161pfd.0
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:51 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u5si26287445pgi.223.2017.01.26.03.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 24/37] ext4: make ext4_mpage_readpages() hugepage-aware
Date: Thu, 26 Jan 2017 14:58:06 +0300
Message-Id: <20170126115819.58875-25-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
