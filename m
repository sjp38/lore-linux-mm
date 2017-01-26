Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A62336B0276
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 80so305776448pfy.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:47 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id m129si26295026pgm.165.2017.01.26.03.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:46 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 16/37] thp: make thp_get_unmapped_area() respect S_HUGE_MODE
Date: Thu, 26 Jan 2017 14:57:58 +0300
Message-Id: <20170126115819.58875-17-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We want mmap(NULL) to return PMD-aligned address if the inode can have
huge pages in page cache.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 55aee62e8444..2b1d8d13e2c3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -528,10 +528,12 @@ unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
 		unsigned long len, unsigned long pgoff, unsigned long flags)
 {
 	loff_t off = (loff_t)pgoff << PAGE_SHIFT;
+	struct inode *inode = filp->f_mapping->host;
 
 	if (addr)
 		goto out;
-	if (!IS_DAX(filp->f_mapping->host) || !IS_ENABLED(CONFIG_FS_DAX_PMD))
+	if ((inode->i_flags & S_HUGE_MODE) == S_HUGE_NEVER &&
+			(!IS_DAX(inode) || !IS_ENABLED(CONFIG_FS_DAX_PMD)))
 		goto out;
 
 	addr = __thp_get_unmapped_area(filp, len, off, flags, PMD_SIZE);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
