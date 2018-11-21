Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0606E6B2623
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 09:55:05 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id x13so7029470wro.9
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 06:55:04 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x65si977901wmg.7.2018.11.21.06.55.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 06:55:03 -0800 (PST)
Date: Wed, 21 Nov 2018 15:55:02 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V11 15/19] block: enable multipage bvecs
Message-ID: <20181121145502.GA3241@lst.de>
References: <20181121032327.8434-1-ming.lei@redhat.com> <20181121032327.8434-16-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121032327.8434-16-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 21, 2018 at 11:23:23AM +0800, Ming Lei wrote:
>  	if (bio->bi_vcnt > 0) {
> -		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
> +		struct bio_vec bv;
> +		struct bio_vec *seg = &bio->bi_io_vec[bio->bi_vcnt - 1];
>  
> -		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
> -			bv->bv_len += len;
> +		bvec_last_segment(seg, &bv);
> +
> +		if (page == bv.bv_page && off == bv.bv_offset + bv.bv_len) {

I think this we can simplify the try to merge into bio case a bit,
and also document it better with something like this:

diff --git a/block/bio.c b/block/bio.c
index 854676edc438..cc913281a723 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -822,54 +822,40 @@ EXPORT_SYMBOL(bio_add_pc_page);
  * @page: page to add
  * @len: length of the data to add
  * @off: offset of the data in @page
+ * @same_page: if %true only merge if the new data is in the same physical
+ *		page as the last segment of the bio.
  *
- * Try to add the data at @page + @off to the last page of @bio.  This is a
+ * Try to add the data at @page + @off to the last bvec of @bio.  This is a
  * a useful optimisation for file systems with a block size smaller than the
  * page size.
  *
  * Return %true on success or %false on failure.
  */
 bool __bio_try_merge_page(struct bio *bio, struct page *page,
-		unsigned int len, unsigned int off)
+		unsigned int len, unsigned int off, bool same_page)
 {
 	if (WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED)))
 		return false;
 
 	if (bio->bi_vcnt > 0) {
-		struct bio_vec bv;
-		struct bio_vec *seg = &bio->bi_io_vec[bio->bi_vcnt - 1];
-
-		bvec_last_segment(seg, &bv);
-
-		if (page == bv.bv_page && off == bv.bv_offset + bv.bv_len) {
-			seg->bv_len += len;
-			bio->bi_iter.bi_size += len;
-			return true;
-		}
+		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
+		phys_addr_t vec_addr = page_to_phys(bv->bv_page);
+		phys_addr_t page_addr = page_to_phys(page);
+
+		if (vec_addr + bv->bv_offset + bv->bv_len != page_addr + off)
+			return false;
+		if (same_page &&
+		    (vec_addr & PAGE_SIZE) != (page_addr & PAGE_SIZE))
+			return false;
+
+		bv->bv_len += len;
+		bio->bi_iter.bi_size += len;
+		return true;
 	}
 	return false;
 }
 EXPORT_SYMBOL_GPL(__bio_try_merge_page);
 
-static bool bio_try_merge_segment(struct bio *bio, struct page *page,
-				  unsigned int len, unsigned int off)
-{
-	if (WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED)))
-		return false;
-
-	if (bio->bi_vcnt > 0) {
-		struct bio_vec *seg = &bio->bi_io_vec[bio->bi_vcnt - 1];
-
-		if (page_to_phys(seg->bv_page) + seg->bv_offset + seg->bv_len ==
-		    page_to_phys(page) + off) {
-			seg->bv_len += len;
-			bio->bi_iter.bi_size += len;
-			return true;
-		}
-	}
-	return false;
-}
-
 /**
  * __bio_add_page - add page to a bio in a new segment
  * @bio: destination bio
@@ -910,7 +896,7 @@ EXPORT_SYMBOL_GPL(__bio_add_page);
 int bio_add_page(struct bio *bio, struct page *page,
 		 unsigned int len, unsigned int offset)
 {
-	if (!bio_try_merge_segment(bio, page, len, offset)) {
+	if (!__bio_try_merge_page(bio, page, len, offset, false)) {
 		if (bio_full(bio))
 			return 0;
 		__bio_add_page(bio, page, len, offset);
diff --git a/fs/iomap.c b/fs/iomap.c
index ccc2ba115f4d..d918acb9bfc9 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -313,7 +313,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 	 */
 	sector = iomap_sector(iomap, pos);
 	if (ctx->bio && bio_end_sector(ctx->bio) == sector) {
-		if (__bio_try_merge_page(ctx->bio, page, plen, poff))
+		if (__bio_try_merge_page(ctx->bio, page, plen, poff, true))
 			goto done;
 		is_contig = true;
 	}
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 5c2190216614..b9fd44168f61 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -616,7 +616,7 @@ xfs_add_to_ioend(
 				bdev, sector);
 	}
 
-	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff)) {
+	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff, true)) {
 		if (iop)
 			atomic_inc(&iop->write_count);
 		if (bio_full(wpc->ioend->io_bio))
diff --git a/include/linux/bio.h b/include/linux/bio.h
index e5b975fa0558..f08e6940c1ab 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -442,7 +442,7 @@ extern int bio_add_page(struct bio *, struct page *, unsigned int,unsigned int);
 extern int bio_add_pc_page(struct request_queue *, struct bio *, struct page *,
 			   unsigned int, unsigned int);
 bool __bio_try_merge_page(struct bio *bio, struct page *page,
-		unsigned int len, unsigned int off);
+		unsigned int len, unsigned int off, bool same_page);
 void __bio_add_page(struct bio *bio, struct page *page,
 		unsigned int len, unsigned int off);
 int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter);
