Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 55D806B0071
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 22:18:51 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so2354349pdj.28
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 19:18:51 -0800 (PST)
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com. [209.85.220.51])
        by mx.google.com with ESMTPS id c5si16593873pdn.70.2014.12.19.19.18.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 19:18:50 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so2378476pad.10
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 19:18:49 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v2 4/5] swapfile: use ->read_iter and ->write_iter
Date: Fri, 19 Dec 2014 19:18:28 -0800
Message-Id: <d8819b57849221b3db7c479f070067808912f0d5.1419044605.git.osandov@osandov.com>
In-Reply-To: <cover.1419044605.git.osandov@osandov.com>
References: <cover.1419044605.git.osandov@osandov.com>
In-Reply-To: <cover.1419044605.git.osandov@osandov.com>
References: <cover.1419044605.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>, Mel Gorman <mgorman@suse.de>

Using ->direct_IO and ->readpage for the generic swap file
infrastructure requires all sorts of nasty workarounds. ->readpage
implementations don't play nicely with swap cache pages, and ->direct_IO
implementations have different locking conventions for every filesystem.
Instead, use ->read_iter/->write_iter with an ITER_BVEC and let the
filesystem take care of it. This will also allow us to easily transition
to kernel AIO if that gets merged in the future.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 mm/page_io.c  | 30 +++++++++++++++++++++++-------
 mm/swapfile.c | 11 ++++++++++-
 2 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 532a39b..61165b0 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -263,7 +263,6 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	if (sis->flags & SWP_FILE) {
 		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
-		struct address_space *mapping = swap_file->f_mapping;
 		struct iov_iter from;
 		struct bio_vec bv = {
 			.bv_page = page,
@@ -279,9 +278,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 
 		set_page_writeback(page);
 		unlock_page(page);
-		ret = mapping->a_ops->direct_IO(ITER_BVEC | WRITE,
-						&kiocb, &from,
-						kiocb.ki_pos);
+		ret = swap_file->f_op->write_iter(&kiocb, &from);
 		if (ret == PAGE_SIZE) {
 			count_vm_event(PSWPOUT);
 			ret = 0;
@@ -344,12 +341,31 @@ int swap_readpage(struct page *page)
 	}
 
 	if (sis->flags & SWP_FILE) {
+		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
-		struct address_space *mapping = swap_file->f_mapping;
+		struct iov_iter to;
+		struct bio_vec bv = {
+			.bv_page = page,
+			.bv_len = PAGE_SIZE,
+			.bv_offset = 0,
+		};
+
+		iov_iter_bvec(&to, ITER_BVEC | READ, &bv, 1, PAGE_SIZE);
+
+		init_sync_kiocb(&kiocb, swap_file);
+		kiocb.ki_pos = page_file_offset(page);
+		kiocb.ki_nbytes = PAGE_SIZE;
 
-		ret = mapping->a_ops->readpage(swap_file, page);
-		if (!ret)
+		ret = swap_file->f_op->read_iter(&kiocb, &to);
+		if (ret == PAGE_SIZE) {
+			SetPageUptodate(page);
 			count_vm_event(PSWPIN);
+			ret = 0;
+		} else {
+			ClearPageUptodate(page);
+			SetPageError(page);
+		}
+		unlock_page(page);
 		return ret;
 	}
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 63f55cc..4e14122 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2379,7 +2379,16 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		name = NULL;
 		goto bad_swap;
 	}
-	swap_file = file_open_name(name, O_RDWR|O_LARGEFILE, 0);
+	swap_file = file_open_name(name, O_RDWR | O_LARGEFILE | O_DIRECT, 0);
+	if (swap_file == ERR_PTR(-EINVAL)) {
+		/*
+		 * XXX: there are several filesystems that implement ->bmap but
+		 * not ->direct_IO. It's unlikely that anyone is using a
+		 * swapfile on, e.g., the MINIX fs, but this kludge will keep us
+		 * from getting a complaint from the one person who does.
+		 */
+		swap_file = file_open_name(name, O_RDWR | O_LARGEFILE, 0);
+	}
 	if (IS_ERR(swap_file)) {
 		error = PTR_ERR(swap_file);
 		swap_file = NULL;
-- 
2.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
