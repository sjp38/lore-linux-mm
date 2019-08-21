Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B444C3A589
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:57:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D01D722D6D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:57:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DRGFlgiH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D01D722D6D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53AA36B0273; Tue, 20 Aug 2019 20:57:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EBA36B0274; Tue, 20 Aug 2019 20:57:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DA3B6B0275; Tue, 20 Aug 2019 20:57:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id 13F426B0273
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:57:27 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id ABA725000
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:57:26 +0000 (UTC)
X-FDA: 75844621692.05.fork37_6b7f14ce3561
X-HE-Tag: fork37_6b7f14ce3561
X-Filterd-Recvd-Size: 14866
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:57:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=VubzEEUj6VYBObAiwOAsmKQEuJ/slbYDRs2+fJVjwho=; b=DRGFlgiHjdRYh8rC3ZKLZ4WN9s
	GjM/0cUMsWTQS/ygLk3QV3x0P848DRNld6ozts+2lLr+qODUtWQJqt41V6B/LaxLczHivN//ZUaF6
	I1a2kB2H2YD7pJ/rvDsXJEgJZOZzFlOwJC8besxe073mj0R/CUSjvNgMKkSQNNP8fBsyNWPlixjx4
	OYlSLoypq1LoQLL61cItdGaBxEfLPdZ8EckRIZ75GocBpYbOHfpTpcouIjlLvuU7NoMXG+lWOtAyp
	OLTLcN7KUJQhdq5mGo/NNSOjeUBDeN9fW+Z721DOzw2flr43eJNP+XTh8tkj8j6InJ9AITkEXuECa
	x1B3HlAw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0EWQ-0003Ha-Bb; Wed, 21 Aug 2019 00:30:42 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	hch@lst.de,
	linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v2 3/5] iomap: Support large pages
Date: Tue, 20 Aug 2019 17:30:37 -0700
Message-Id: <20190821003039.12555-4-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190821003039.12555-1-willy@infradead.org>
References: <20190821003039.12555-1-willy@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Change iomap_page from a statically sized uptodate bitmap to a dynamicall=
y
allocated uptodate bitmap, allowing an arbitrarily large page.

The only remaining places where iomap assumes an order-0 page are for
files with inline data, where there's no sense in allocating a larger
page.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/iomap/buffered-io.c | 119 ++++++++++++++++++++++++++---------------
 include/linux/iomap.h  |   2 +-
 include/linux/mm.h     |   2 +
 3 files changed, 80 insertions(+), 43 deletions(-)

diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
index 0e76a4b6d98a..15d844a88439 100644
--- a/fs/iomap/buffered-io.c
+++ b/fs/iomap/buffered-io.c
@@ -23,14 +23,14 @@ static struct iomap_page *
 iomap_page_create(struct inode *inode, struct page *page)
 {
 	struct iomap_page *iop =3D to_iomap_page(page);
+	unsigned int n;
=20
 	if (iop || i_blocks_per_page(inode, page) <=3D 1)
 		return iop;
=20
-	iop =3D kmalloc(sizeof(*iop), GFP_NOFS | __GFP_NOFAIL);
-	atomic_set(&iop->read_count, 0);
-	atomic_set(&iop->write_count, 0);
-	bitmap_zero(iop->uptodate, PAGE_SIZE / SECTOR_SIZE);
+	n =3D BITS_TO_LONGS(i_blocks_per_page(inode, page));
+	iop =3D kmalloc(struct_size(iop, uptodate, n),
+			GFP_NOFS | __GFP_NOFAIL | __GFP_ZERO);
=20
 	/*
 	 * migrate_page_move_mapping() assumes that pages with private data hav=
e
@@ -61,15 +61,16 @@ iomap_page_release(struct page *page)
  * Calculate the range inside the page that we actually need to read.
  */
 static void
-iomap_adjust_read_range(struct inode *inode, struct iomap_page *iop,
+iomap_adjust_read_range(struct inode *inode, struct page *page,
 		loff_t *pos, loff_t length, unsigned *offp, unsigned *lenp)
 {
+	struct iomap_page *iop =3D to_iomap_page(page);
 	loff_t orig_pos =3D *pos;
 	loff_t isize =3D i_size_read(inode);
 	unsigned block_bits =3D inode->i_blkbits;
 	unsigned block_size =3D (1 << block_bits);
-	unsigned poff =3D offset_in_page(*pos);
-	unsigned plen =3D min_t(loff_t, PAGE_SIZE - poff, length);
+	unsigned poff =3D offset_in_this_page(page, *pos);
+	unsigned plen =3D min_t(loff_t, page_size(page) - poff, length);
 	unsigned first =3D poff >> block_bits;
 	unsigned last =3D (poff + plen - 1) >> block_bits;
=20
@@ -107,7 +108,8 @@ iomap_adjust_read_range(struct inode *inode, struct i=
omap_page *iop,
 	 * page cache for blocks that are entirely outside of i_size.
 	 */
 	if (orig_pos <=3D isize && orig_pos + length > isize) {
-		unsigned end =3D offset_in_page(isize - 1) >> block_bits;
+		unsigned end =3D offset_in_this_page(page, isize - 1) >>
+				block_bits;
=20
 		if (first <=3D end && last > end)
 			plen -=3D (last - end) * block_size;
@@ -121,19 +123,16 @@ static void
 iomap_set_range_uptodate(struct page *page, unsigned off, unsigned len)
 {
 	struct iomap_page *iop =3D to_iomap_page(page);
-	struct inode *inode =3D page->mapping->host;
-	unsigned first =3D off >> inode->i_blkbits;
-	unsigned last =3D (off + len - 1) >> inode->i_blkbits;
-	unsigned int i;
 	bool uptodate =3D true;
=20
 	if (iop) {
-		for (i =3D 0; i < i_blocks_per_page(inode, page); i++) {
-			if (i >=3D first && i <=3D last)
-				set_bit(i, iop->uptodate);
-			else if (!test_bit(i, iop->uptodate))
-				uptodate =3D false;
-		}
+		struct inode *inode =3D page->mapping->host;
+		unsigned first =3D off >> inode->i_blkbits;
+		unsigned count =3D len >> inode->i_blkbits;
+
+		bitmap_set(iop->uptodate, first, count);
+		if (!bitmap_full(iop->uptodate, i_blocks_per_page(inode, page)))
+			uptodate =3D false;
 	}
=20
 	if (uptodate && !PageError(page))
@@ -194,6 +193,7 @@ iomap_read_inline_data(struct inode *inode, struct pa=
ge *page,
 		return;
=20
 	BUG_ON(page->index);
+	BUG_ON(PageCompound(page));
 	BUG_ON(size > PAGE_SIZE - offset_in_page(iomap->inline_data));
=20
 	addr =3D kmap_atomic(page);
@@ -203,6 +203,16 @@ iomap_read_inline_data(struct inode *inode, struct p=
age *page,
 	SetPageUptodate(page);
 }
=20
+/*
+ * Estimate the number of vectors we need based on the current page size=
;
+ * if we're wrong we'll end up doing an overly large allocation or needi=
ng
+ * to do a second allocation, neither of which is a big deal.
+ */
+static unsigned int iomap_nr_vecs(struct page *page, loff_t length)
+{
+	return (length + page_size(page) - 1) >> page_shift(page);
+}
+
 static loff_t
 iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, voi=
d *data,
 		struct iomap *iomap)
@@ -222,7 +232,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos,=
 loff_t length, void *data,
 	}
=20
 	/* zero post-eof blocks as the page may be mapped */
-	iomap_adjust_read_range(inode, iop, &pos, length, &poff, &plen);
+	iomap_adjust_read_range(inode, page, &pos, length, &poff, &plen);
 	if (plen =3D=3D 0)
 		goto done;
=20
@@ -258,7 +268,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos,=
 loff_t length, void *data,
=20
 	if (!ctx->bio || !is_contig || bio_full(ctx->bio, plen)) {
 		gfp_t gfp =3D mapping_gfp_constraint(page->mapping, GFP_KERNEL);
-		int nr_vecs =3D (length + PAGE_SIZE - 1) >> PAGE_SHIFT;
+		int nr_vecs =3D iomap_nr_vecs(page, length);
=20
 		if (ctx->bio)
 			submit_bio(ctx->bio);
@@ -293,9 +303,9 @@ iomap_readpage(struct page *page, const struct iomap_=
ops *ops)
 	unsigned poff;
 	loff_t ret;
=20
-	for (poff =3D 0; poff < PAGE_SIZE; poff +=3D ret) {
-		ret =3D iomap_apply(inode, page_offset(page) + poff,
-				PAGE_SIZE - poff, 0, ops, &ctx,
+	for (poff =3D 0; poff < page_size(page); poff +=3D ret) {
+		ret =3D iomap_apply(inode, file_offset_of_page(page) + poff,
+				page_size(page) - poff, 0, ops, &ctx,
 				iomap_readpage_actor);
 		if (ret <=3D 0) {
 			WARN_ON_ONCE(ret =3D=3D 0);
@@ -328,7 +338,7 @@ iomap_next_page(struct inode *inode, struct list_head=
 *pages, loff_t pos,
 	while (!list_empty(pages)) {
 		struct page *page =3D lru_to_page(pages);
=20
-		if (page_offset(page) >=3D (u64)pos + length)
+		if (file_offset_of_page(page) >=3D (u64)pos + length)
 			break;
=20
 		list_del(&page->lru);
@@ -342,7 +352,7 @@ iomap_next_page(struct inode *inode, struct list_head=
 *pages, loff_t pos,
 		 * readpages call itself as every page gets checked again once
 		 * actually needed.
 		 */
-		*done +=3D PAGE_SIZE;
+		*done +=3D page_size(page);
 		put_page(page);
 	}
=20
@@ -355,9 +365,14 @@ iomap_readpages_actor(struct inode *inode, loff_t po=
s, loff_t length,
 {
 	struct iomap_readpage_ctx *ctx =3D data;
 	loff_t done, ret;
+	size_t left =3D 0;
+
+	if (ctx->cur_page)
+		left =3D page_size(ctx->cur_page) -
+					offset_in_this_page(ctx->cur_page, pos);
=20
 	for (done =3D 0; done < length; done +=3D ret) {
-		if (ctx->cur_page && offset_in_page(pos + done) =3D=3D 0) {
+		if (ctx->cur_page && left =3D=3D 0) {
 			if (!ctx->cur_page_in_bio)
 				unlock_page(ctx->cur_page);
 			put_page(ctx->cur_page);
@@ -369,14 +384,27 @@ iomap_readpages_actor(struct inode *inode, loff_t p=
os, loff_t length,
 			if (!ctx->cur_page)
 				break;
 			ctx->cur_page_in_bio =3D false;
+			left =3D page_size(ctx->cur_page);
 		}
 		ret =3D iomap_readpage_actor(inode, pos + done, length - done,
 				ctx, iomap);
+		left -=3D ret;
 	}
=20
 	return done;
 }
=20
+/* move to fs.h? */
+static inline struct page *readahead_first_page(struct list_head *head)
+{
+	return list_entry(head->prev, struct page, lru);
+}
+
+static inline struct page *readahead_last_page(struct list_head *head)
+{
+	return list_entry(head->next, struct page, lru);
+}
+
 int
 iomap_readpages(struct address_space *mapping, struct list_head *pages,
 		unsigned nr_pages, const struct iomap_ops *ops)
@@ -385,9 +413,10 @@ iomap_readpages(struct address_space *mapping, struc=
t list_head *pages,
 		.pages		=3D pages,
 		.is_readahead	=3D true,
 	};
-	loff_t pos =3D page_offset(list_entry(pages->prev, struct page, lru));
-	loff_t last =3D page_offset(list_entry(pages->next, struct page, lru));
-	loff_t length =3D last - pos + PAGE_SIZE, ret =3D 0;
+	loff_t pos =3D file_offset_of_page(readahead_first_page(pages));
+	loff_t end =3D file_offset_of_next_page(readahead_last_page(pages));
+	loff_t length =3D end - pos;
+	loff_t ret =3D 0;
=20
 	while (length > 0) {
 		ret =3D iomap_apply(mapping->host, pos, length, 0, ops,
@@ -410,7 +439,7 @@ iomap_readpages(struct address_space *mapping, struct=
 list_head *pages,
 	}
=20
 	/*
-	 * Check that we didn't lose a page due to the arcance calling
+	 * Check that we didn't lose a page due to the arcane calling
 	 * conventions..
 	 */
 	WARN_ON_ONCE(!ret && !list_empty(ctx.pages));
@@ -435,7 +464,7 @@ iomap_is_partially_uptodate(struct page *page, unsign=
ed long from,
 	unsigned i;
=20
 	/* Limit range to one page */
-	len =3D min_t(unsigned, PAGE_SIZE - from, count);
+	len =3D min_t(unsigned, page_size(page) - from, count);
=20
 	/* First and last blocks in range within page */
 	first =3D from >> inode->i_blkbits;
@@ -474,7 +503,7 @@ iomap_invalidatepage(struct page *page, unsigned int =
offset, unsigned int len)
 	 * If we are invalidating the entire page, clear the dirty state from i=
t
 	 * and release it to avoid unnecessary buildup of the LRU.
 	 */
-	if (offset =3D=3D 0 && len =3D=3D PAGE_SIZE) {
+	if (offset =3D=3D 0 && len =3D=3D page_size(page)) {
 		WARN_ON_ONCE(PageWriteback(page));
 		cancel_dirty_page(page);
 		iomap_page_release(page);
@@ -550,18 +579,20 @@ static int
 __iomap_write_begin(struct inode *inode, loff_t pos, unsigned len,
 		struct page *page, struct iomap *iomap)
 {
-	struct iomap_page *iop =3D iomap_page_create(inode, page);
 	loff_t block_size =3D i_blocksize(inode);
 	loff_t block_start =3D pos & ~(block_size - 1);
 	loff_t block_end =3D (pos + len + block_size - 1) & ~(block_size - 1);
-	unsigned from =3D offset_in_page(pos), to =3D from + len, poff, plen;
+	unsigned from =3D offset_in_this_page(page, pos);
+	unsigned to =3D from + len;
+	unsigned poff, plen;
 	int status =3D 0;
=20
 	if (PageUptodate(page))
 		return 0;
+	iomap_page_create(inode, page);
=20
 	do {
-		iomap_adjust_read_range(inode, iop, &block_start,
+		iomap_adjust_read_range(inode, page, &block_start,
 				block_end - block_start, &poff, &plen);
 		if (plen =3D=3D 0)
 			break;
@@ -673,7 +704,7 @@ __iomap_write_end(struct inode *inode, loff_t pos, un=
signed len,
 	 */
 	if (unlikely(copied < len && !PageUptodate(page)))
 		return 0;
-	iomap_set_range_uptodate(page, offset_in_page(pos), len);
+	iomap_set_range_uptodate(page, offset_in_this_page(page, pos), len);
 	iomap_set_page_dirty(page);
 	return copied;
 }
@@ -685,6 +716,7 @@ iomap_write_end_inline(struct inode *inode, struct pa=
ge *page,
 	void *addr;
=20
 	WARN_ON_ONCE(!PageUptodate(page));
+	BUG_ON(PageCompound(page));
 	BUG_ON(pos + copied > PAGE_SIZE - offset_in_page(iomap->inline_data));
=20
 	addr =3D kmap_atomic(page);
@@ -749,6 +781,10 @@ iomap_write_actor(struct inode *inode, loff_t pos, l=
off_t length, void *data,
 		unsigned long bytes;	/* Bytes to write to page */
 		size_t copied;		/* Bytes copied from user */
=20
+		/*
+		 * XXX: We don't know what size page we'll find in the
+		 * page cache, so only copy up to a regular page boundary.
+		 */
 		offset =3D offset_in_page(pos);
 		bytes =3D min_t(unsigned long, PAGE_SIZE - offset,
 						iov_iter_count(i));
@@ -1041,19 +1077,18 @@ vm_fault_t iomap_page_mkwrite(struct vm_fault *vm=
f, const struct iomap_ops *ops)
 	lock_page(page);
 	size =3D i_size_read(inode);
 	if ((page->mapping !=3D inode->i_mapping) ||
-	    (page_offset(page) > size)) {
+	    (file_offset_of_page(page) > size)) {
 		/* We overload EFAULT to mean page got truncated */
 		ret =3D -EFAULT;
 		goto out_unlock;
 	}
=20
-	/* page is wholly or partially inside EOF */
-	if (((page->index + 1) << PAGE_SHIFT) > size)
-		length =3D offset_in_page(size);
+	offset =3D file_offset_of_page(page);
+	if (size - offset < page_size(page))
+		length =3D offset_in_this_page(page, size);
 	else
-		length =3D PAGE_SIZE;
+		length =3D page_size(page);
=20
-	offset =3D page_offset(page);
 	while (length > 0) {
 		ret =3D iomap_apply(inode, offset, length,
 				IOMAP_WRITE | IOMAP_FAULT, ops, page,
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index bc499ceae392..86be24a8259b 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -139,7 +139,7 @@ loff_t iomap_apply(struct inode *inode, loff_t pos, l=
off_t length,
 struct iomap_page {
 	atomic_t		read_count;
 	atomic_t		write_count;
-	DECLARE_BITMAP(uptodate, PAGE_SIZE / 512);
+	unsigned long		uptodate[];
 };
=20
 static inline struct iomap_page *to_iomap_page(struct page *page)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 726d7f046b49..6892cd712428 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1414,6 +1414,8 @@ static inline void clear_page_pfmemalloc(struct pag=
e *page)
 extern void pagefault_out_of_memory(void);
=20
 #define offset_in_page(p)	((unsigned long)(p) & ~PAGE_MASK)
+#define offset_in_this_page(page, p)	\
+	((unsigned long)(p) & (page_size(page) - 1))
=20
 /*
  * Flags passed to show_mem() and show_free_areas() to suppress output i=
n
--=20
2.23.0.rc1


