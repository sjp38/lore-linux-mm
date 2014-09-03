Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id ABDB86B0038
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 06:11:09 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id c11so9176025lbj.4
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 03:11:08 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 1si8482956lbl.18.2014.09.03.03.11.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Sep 2014 03:11:08 -0700 (PDT)
Subject: [PATCH 1/2] vfs: switch iov_iter_get_pages() to passing maximal size
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Wed, 03 Sep 2014 14:11:04 +0400
Message-ID: <20140903101030.23218.27114.stgit@localhost.localdomain>
In-Reply-To: <20140903100826.23218.95122.stgit@localhost.localdomain>
References: <20140903100826.23218.95122.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk
Cc: miklos@szeredi.hu, fuse-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, werner.baumann@onlinehome.de

The patch reverts the commit c7f3888ad7f0 ("switch iov_iter_get_pages() to
passing maximal number of pages") because FUSE do need maxsize argument that
existed before that commit.

Signed-off-by: Maxim Patlasov <mpatlasov@parallels.com>
---
 fs/direct-io.c      |    2 +-
 fs/fuse/file.c      |    4 ++--
 include/linux/uio.h |    2 +-
 mm/iov_iter.c       |   17 +++++++++--------
 4 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index c311640..17e39b0 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -158,7 +158,7 @@ static inline int dio_refill_pages(struct dio *dio, struct dio_submit *sdio)
 {
 	ssize_t ret;
 
-	ret = iov_iter_get_pages(sdio->iter, dio->pages, DIO_PAGES,
+	ret = iov_iter_get_pages(sdio->iter, dio->pages, DIO_PAGES * PAGE_SIZE,
 				&sdio->from);
 
 	if (ret < 0 && sdio->blocks_available && (dio->rw & WRITE)) {
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 912061a..40ac262 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1303,10 +1303,10 @@ static int fuse_get_user_pages(struct fuse_req *req, struct iov_iter *ii,
 	while (nbytes < *nbytesp && req->num_pages < req->max_pages) {
 		unsigned npages;
 		size_t start;
+		unsigned n = req->max_pages - req->num_pages;
 		ssize_t ret = iov_iter_get_pages(ii,
 					&req->pages[req->num_pages],
-					req->max_pages - req->num_pages,
-					&start);
+					n * PAGE_SIZE, &start);
 		if (ret < 0)
 			return ret;
 
diff --git a/include/linux/uio.h b/include/linux/uio.h
index 48d64e6..09a7cff 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -84,7 +84,7 @@ unsigned long iov_iter_alignment(const struct iov_iter *i);
 void iov_iter_init(struct iov_iter *i, int direction, const struct iovec *iov,
 			unsigned long nr_segs, size_t count);
 ssize_t iov_iter_get_pages(struct iov_iter *i, struct page **pages,
-			unsigned maxpages, size_t *start);
+			size_t maxsize, size_t *start);
 ssize_t iov_iter_get_pages_alloc(struct iov_iter *i, struct page ***pages,
 			size_t maxsize, size_t *start);
 int iov_iter_npages(const struct iov_iter *i, int maxpages);
diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index ab88dc0..7b5dbd1 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -310,7 +310,7 @@ void iov_iter_init(struct iov_iter *i, int direction,
 EXPORT_SYMBOL(iov_iter_init);
 
 static ssize_t get_pages_iovec(struct iov_iter *i,
-		   struct page **pages, unsigned maxpages,
+		   struct page **pages, size_t maxsize,
 		   size_t *start)
 {
 	size_t offset = i->iov_offset;
@@ -323,10 +323,10 @@ static ssize_t get_pages_iovec(struct iov_iter *i,
 	len = iov->iov_len - offset;
 	if (len > i->count)
 		len = i->count;
+	if (len > maxsize)
+		len = maxsize;
 	addr = (unsigned long)iov->iov_base + offset;
 	len += *start = addr & (PAGE_SIZE - 1);
-	if (len > maxpages * PAGE_SIZE)
-		len = maxpages * PAGE_SIZE;
 	addr &= ~(PAGE_SIZE - 1);
 	n = (len + PAGE_SIZE - 1) / PAGE_SIZE;
 	res = get_user_pages_fast(addr, n, (i->type & WRITE) != WRITE, pages);
@@ -588,14 +588,15 @@ static unsigned long alignment_bvec(const struct iov_iter *i)
 }
 
 static ssize_t get_pages_bvec(struct iov_iter *i,
-		   struct page **pages, unsigned maxpages,
+		   struct page **pages, size_t maxsize,
 		   size_t *start)
 {
 	const struct bio_vec *bvec = i->bvec;
 	size_t len = bvec->bv_len - i->iov_offset;
 	if (len > i->count)
 		len = i->count;
-	/* can't be more than PAGE_SIZE */
+	if (len > maxsize)
+		len = maxsize;
 	*start = bvec->bv_offset + i->iov_offset;
 
 	get_page(*pages = bvec->bv_page);
@@ -711,13 +712,13 @@ unsigned long iov_iter_alignment(const struct iov_iter *i)
 EXPORT_SYMBOL(iov_iter_alignment);
 
 ssize_t iov_iter_get_pages(struct iov_iter *i,
-		   struct page **pages, unsigned maxpages,
+		   struct page **pages, size_t maxsize,
 		   size_t *start)
 {
 	if (i->type & ITER_BVEC)
-		return get_pages_bvec(i, pages, maxpages, start);
+		return get_pages_bvec(i, pages, maxsize, start);
 	else
-		return get_pages_iovec(i, pages, maxpages, start);
+		return get_pages_iovec(i, pages, maxsize, start);
 }
 EXPORT_SYMBOL(iov_iter_get_pages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
