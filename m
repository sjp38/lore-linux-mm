Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1EF76B029C
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:37:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b79so2517247pfk.9
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:37:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k23si5946pli.801.2017.11.01.08.37.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 08:37:04 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 15/18] ext4: Simplify error handling in ext4_dax_huge_fault()
Date: Wed,  1 Nov 2017 16:36:44 +0100
Message-Id: <20171101153648.30166-16-jack@suse.cz>
In-Reply-To: <20171101153648.30166-1-jack@suse.cz>
References: <20171101153648.30166-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>

If transaction starting fails, just bail out of the function immediately
instead of checking for that condition throughout the function.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/file.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 3cec0b95672f..208adfc3e673 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -302,16 +302,17 @@ static int ext4_dax_huge_fault(struct vm_fault *vmf,
 		down_read(&EXT4_I(inode)->i_mmap_sem);
 		handle = ext4_journal_start_sb(sb, EXT4_HT_WRITE_PAGE,
 					       EXT4_DATA_TRANS_BLOCKS(sb));
+		if (IS_ERR(handle)) {
+			up_read(&EXT4_I(inode)->i_mmap_sem);
+			sb_end_pagefault(sb);
+			return VM_FAULT_SIGBUS;
+		}
 	} else {
 		down_read(&EXT4_I(inode)->i_mmap_sem);
 	}
-	if (!IS_ERR(handle))
-		result = dax_iomap_fault(vmf, pe_size, NULL, &ext4_iomap_ops);
-	else
-		result = VM_FAULT_SIGBUS;
+	result = dax_iomap_fault(vmf, pe_size, NULL, &ext4_iomap_ops);
 	if (write) {
-		if (!IS_ERR(handle))
-			ext4_journal_stop(handle);
+		ext4_journal_stop(handle);
 		up_read(&EXT4_I(inode)->i_mmap_sem);
 		sb_end_pagefault(sb);
 	} else {
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
