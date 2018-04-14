Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3A166B002B
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:13:31 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 61-v6so7586101plz.20
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:13:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h23-v6si8499162plr.576.2018.04.14.07.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:30 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 51/63] dax: Fix use of zero page
Date: Sat, 14 Apr 2018 07:13:04 -0700
Message-Id: <20180414141316.7167-52-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Use my_zero_pfn instead of ZERO_PAGE, and pass the vaddr to it so it
works on MIPS and s390.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index e014c99b21fd..b0efb0a9604a 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -909,17 +909,9 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 	struct inode *inode = mapping->host;
 	unsigned long vaddr = vmf->address;
 	int ret = VM_FAULT_NOPAGE;
-	struct page *zero_page;
 	void *entry2;
-	pfn_t pfn;
-
-	zero_page = ZERO_PAGE(0);
-	if (unlikely(!zero_page)) {
-		ret = VM_FAULT_OOM;
-		goto out;
-	}
+	pfn_t pfn = pfn_to_pfn_t(my_zero_pfn(vaddr));
 
-	pfn = page_to_pfn_t(zero_page);
 	entry2 = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
 			DAX_ZERO_PAGE, false);
 	if (IS_ERR(entry2)) {
-- 
2.17.0
