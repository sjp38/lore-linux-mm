Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 37F0C6B006E
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 00:27:30 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so10943480pdi.16
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:27:30 -0800 (PST)
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com. [209.85.192.171])
        by mx.google.com with ESMTPS id bd3si12209430pbb.188.2014.12.14.21.27.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Dec 2014 21:27:28 -0800 (PST)
Received: by mail-pd0-f171.google.com with SMTP id y13so10943430pdi.16
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:27:27 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Date: Sun, 14 Dec 2014 21:26:56 -0800
Message-Id: <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

The generic write code locks i_mutex for a direct_IO. Swap-over-NFS
doesn't grab the mutex because nfs_direct_IO doesn't expect i_mutex to
be held, but most direct_IO implementations do.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 mm/page_io.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_io.c b/mm/page_io.c
index 955db8b..1630ac0 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -263,6 +263,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	if (sis->flags & SWP_FILE) {
 		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
+		struct inode *inode = file_inode(swap_file);
 		struct address_space *mapping = swap_file->f_mapping;
 		struct bio_vec bv = {
 			.bv_page = page,
@@ -283,9 +284,11 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 
 		set_page_writeback(page);
 		unlock_page(page);
+		mutex_lock(&inode->i_mutex);
 		ret = mapping->a_ops->direct_IO(ITER_BVEC | WRITE,
 						&kiocb, &from,
 						kiocb.ki_pos);
+		mutex_unlock(&inode->i_mutex);
 		if (ret == PAGE_SIZE) {
 			count_vm_event(PSWPOUT);
 			ret = 0;
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
