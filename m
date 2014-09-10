Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA016B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 05:51:24 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id y10so3848690wgg.6
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 02:51:24 -0700 (PDT)
Received: from mail-we0-x233.google.com (mail-we0-x233.google.com [2a00:1450:400c:c03::233])
        by mx.google.com with ESMTPS id f18si1622159wiw.99.2014.09.10.02.51.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 02:51:22 -0700 (PDT)
Received: by mail-we0-f179.google.com with SMTP id u56so4242414wes.10
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 02:51:22 -0700 (PDT)
Date: Wed, 10 Sep 2014 11:51:15 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 0/2] fuse: fix regression in fuse_get_user_pages()
Message-ID: <20140910095115.GA7441@tucsk.piliscsaba.szeredi.hu>
References: <20140903100826.23218.95122.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140903100826.23218.95122.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <MPatlasov@parallels.com>
Cc: viro@zeniv.linux.org.uk, fuse-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, werner.baumann@onlinehome.de

On Wed, Sep 03, 2014 at 02:10:23PM +0400, Maxim Patlasov wrote:
> Hi,
> 
> The patchset fixes a regression introduced by the following commits:
> 
> c7f3888ad7f0 ("switch iov_iter_get_pages() to passing maximal number of pages")
> c9c37e2e6378 ("fuse: switch to iov_iter_get_pages()")
> 

Hmm, instead of reverting to passing maxbytes *instead* of maxpages, I think the
right fix is to *add* the maxbytes argument.

Just maxbytes alone doesn't have enough information in it.  E.g. 4096 contiguous
bytes could occupy 1 or 2 pages, depending on the starting offset.

So how about the following (untested) patch?

Thanks,
Miklos

diff --git a/fs/direct-io.c b/fs/direct-io.c
index c3116404ab49..e181b6b2e297 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -158,7 +158,7 @@ static inline int dio_refill_pages(struct dio *dio, struct dio_submit *sdio)
 {
 	ssize_t ret;
 
-	ret = iov_iter_get_pages(sdio->iter, dio->pages, DIO_PAGES,
+	ret = iov_iter_get_pages(sdio->iter, dio->pages, LONG_MAX, DIO_PAGES,
 				&sdio->from);
 
 	if (ret < 0 && sdio->blocks_available && (dio->rw & WRITE)) {
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 912061ac4baf..caa8d95b24e8 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1305,6 +1305,7 @@ static int fuse_get_user_pages(struct fuse_req *req, struct iov_iter *ii,
 		size_t start;
 		ssize_t ret = iov_iter_get_pages(ii,
 					&req->pages[req->num_pages],
+					*nbytesp - nbytes,
 					req->max_pages - req->num_pages,
 					&start);
 		if (ret < 0)
diff --git a/include/linux/uio.h b/include/linux/uio.h
index 48d64e6ab292..290fbf0b6b8a 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -84,7 +84,7 @@ unsigned long iov_iter_alignment(const struct iov_iter *i);
 void iov_iter_init(struct iov_iter *i, int direction, const struct iovec *iov,
 			unsigned long nr_segs, size_t count);
 ssize_t iov_iter_get_pages(struct iov_iter *i, struct page **pages,
-			unsigned maxpages, size_t *start);
+			size_t maxsize, unsigned maxpages, size_t *start);
 ssize_t iov_iter_get_pages_alloc(struct iov_iter *i, struct page ***pages,
 			size_t maxsize, size_t *start);
 int iov_iter_npages(const struct iov_iter *i, int maxpages);
diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index ab88dc0ea1d3..9a09f2034fcc 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -310,7 +310,7 @@ void iov_iter_init(struct iov_iter *i, int direction,
 EXPORT_SYMBOL(iov_iter_init);
 
 static ssize_t get_pages_iovec(struct iov_iter *i,
-		   struct page **pages, unsigned maxpages,
+		   struct page **pages, size_t maxsize, unsigned maxpages,
 		   size_t *start)
 {
 	size_t offset = i->iov_offset;
@@ -323,6 +323,8 @@ static ssize_t get_pages_iovec(struct iov_iter *i,
 	len = iov->iov_len - offset;
 	if (len > i->count)
 		len = i->count;
+	if (len > maxsize)
+		len = maxsize;
 	addr = (unsigned long)iov->iov_base + offset;
 	len += *start = addr & (PAGE_SIZE - 1);
 	if (len > maxpages * PAGE_SIZE)
@@ -588,13 +590,15 @@ static unsigned long alignment_bvec(const struct iov_iter *i)
 }
 
 static ssize_t get_pages_bvec(struct iov_iter *i,
-		   struct page **pages, unsigned maxpages,
+		   struct page **pages, size_t maxsize, unsigned maxpages,
 		   size_t *start)
 {
 	const struct bio_vec *bvec = i->bvec;
 	size_t len = bvec->bv_len - i->iov_offset;
 	if (len > i->count)
 		len = i->count;
+	if (len > maxsize)
+		len = maxsize;
 	/* can't be more than PAGE_SIZE */
 	*start = bvec->bv_offset + i->iov_offset;
 
@@ -711,13 +715,13 @@ unsigned long iov_iter_alignment(const struct iov_iter *i)
 EXPORT_SYMBOL(iov_iter_alignment);
 
 ssize_t iov_iter_get_pages(struct iov_iter *i,
-		   struct page **pages, unsigned maxpages,
+		   struct page **pages, size_t maxsize, unsigned maxpages,
 		   size_t *start)
 {
 	if (i->type & ITER_BVEC)
-		return get_pages_bvec(i, pages, maxpages, start);
+		return get_pages_bvec(i, pages, maxsize, maxpages, start);
 	else
-		return get_pages_iovec(i, pages, maxpages, start);
+		return get_pages_iovec(i, pages, maxsize, maxpages, start);
 }
 EXPORT_SYMBOL(iov_iter_get_pages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
