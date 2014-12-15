Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9ED6B0071
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 00:27:34 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so10970037pdj.14
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:27:34 -0800 (PST)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com. [209.85.220.45])
        by mx.google.com with ESMTPS id kv12si12184420pab.232.2014.12.14.21.27.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Dec 2014 21:27:32 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so10489935pab.18
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:27:31 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH 4/8] iov_iter: add iov_iter_bvec and convert callers
Date: Sun, 14 Dec 2014 21:26:58 -0800
Message-Id: <8cac277c6def1ea561028747f1065c9d0ca4ab77.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/splice.c         |  7 ++-----
 include/linux/uio.h |  2 ++
 mm/iov_iter.c       | 12 ++++++++++++
 mm/page_io.c        | 14 +++++---------
 4 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 75c6058..7c7176f 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1006,11 +1006,8 @@ iter_file_splice_write(struct pipe_inode_info *pipe, struct file *out,
 		}
 
 		/* ... iov_iter */
-		from.type = ITER_BVEC | WRITE;
-		from.bvec = array;
-		from.nr_segs = n;
-		from.count = sd.total_len - left;
-		from.iov_offset = 0;
+		iov_iter_bvec(&from, ITER_BVEC | WRITE, array, n,
+			      sd.total_len - left);
 
 		/* ... and iocb */
 		init_sync_kiocb(&kiocb, out);
diff --git a/include/linux/uio.h b/include/linux/uio.h
index bd8569a..d1a34b4 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -90,6 +90,8 @@ void iov_iter_init(struct iov_iter *i, int direction, const struct iovec *iov,
 			unsigned long nr_segs, size_t count);
 void iov_iter_kvec(struct iov_iter *i, int direction, const struct kvec *iov,
 			unsigned long nr_segs, size_t count);
+void iov_iter_bvec(struct iov_iter *i, int direction, const struct bio_vec *bv,
+		   unsigned long nr_segs, size_t count);
 ssize_t iov_iter_get_pages(struct iov_iter *i, struct page **pages,
 			size_t maxsize, unsigned maxpages, size_t *start);
 ssize_t iov_iter_get_pages_alloc(struct iov_iter *i, struct page ***pages,
diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index a1599ca..c975bc4 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -513,6 +513,18 @@ void iov_iter_kvec(struct iov_iter *i, int direction,
 }
 EXPORT_SYMBOL(iov_iter_kvec);
 
+void iov_iter_bvec(struct iov_iter *i, int direction, const struct bio_vec *bv,
+		   unsigned long nr_segs, size_t count)
+{
+	BUG_ON(!(direction & ITER_BVEC));
+	i->type = direction;
+	i->bvec = bv;
+	i->nr_segs = nr_segs;
+	i->iov_offset = 0;
+	i->count = count;
+}
+EXPORT_SYMBOL(iov_iter_bvec);
+
 unsigned long iov_iter_alignment(const struct iov_iter *i)
 {
 	unsigned long res = 0;
diff --git a/mm/page_io.c b/mm/page_io.c
index c229f88..4741248 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -265,18 +265,14 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		struct file *swap_file = sis->swap_file;
 		struct inode *inode = file_inode(swap_file);
 		struct address_space *mapping = swap_file->f_mapping;
+		struct iov_iter from;
 		struct bio_vec bv = {
 			.bv_page = page,
-			.bv_len  = PAGE_SIZE,
-			.bv_offset = 0
+			.bv_len = PAGE_SIZE,
+			.bv_offset = 0,
 		};
-		struct iov_iter from = {
-			.type = ITER_BVEC | WRITE,
-			.count = PAGE_SIZE,
-			.iov_offset = 0,
-			.nr_segs = 1,
-		};
-		from.bvec = &bv;	/* older gcc versions are broken */
+
+		iov_iter_bvec(&from, ITER_BVEC | WRITE, &bv, 1, PAGE_SIZE);
 
 		init_sync_kiocb(&kiocb, swap_file);
 		kiocb.ki_pos = page_file_offset(page);
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
