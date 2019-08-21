Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84CC2C3A5A2
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:30:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47D4022DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:30:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Qeclk0a+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47D4022DA7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A856B6B0008; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 945FB6B000D; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 771116B000E; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0239.hostedemail.com [216.40.44.239])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8726B000A
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 07E17181AC9C4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:30:51 +0000 (UTC)
X-FDA: 75844554702.30.wheel60_4190cc0685e2c
X-HE-Tag: wheel60_4190cc0685e2c
X-Filterd-Recvd-Size: 5852
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:30:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=TpSePgz02GkghZM1yEUYwUuZuyuUMUK08NAW5vfqrco=; b=Qeclk0a+RGaahcVQFrt2ipxglv
	ZpcmRN/jKfYeHqp66tjTyxed9nEyeVUF18o17kfrbJCFGfvUNipRUvwahdEkYkA/3QFqFTeowN/1A
	yAgQtuq9Dg/lJ9Qfh5Au7a8W01TjbdGw8c8JkxUFGviWm5RD8Hd9sPiD3sqGn5PSMMtG5a/rjih4a
	/dHUzHlRO6XaoUWEAYkfFGevg1xrBh8T9M81gUexspMuAgv5jztT2ok1e35m08RS+UWZX5p1iT7LK
	1j2XVL7ytbvfhdvEAF5OZu+NAzUuCFD/Hwl+IqBMm1QGMhLHYr/MD9yu2z7ulr5Iv2/MII320+c/p
	4T9dNvng==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0EWQ-0003HR-81; Wed, 21 Aug 2019 00:30:42 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	hch@lst.de,
	linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v2 1/5] fs: Introduce i_blocks_per_page
Date: Tue, 20 Aug 2019 17:30:35 -0700
Message-Id: <20190821003039.12555-2-willy@infradead.org>
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

This helper is useful for both large pages in the page cache and for
supporting block size larger than page size.  Convert some example
users (we have a few different ways of writing this idiom).

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/iomap/buffered-io.c  |  4 ++--
 fs/jfs/jfs_metapage.c   |  2 +-
 fs/xfs/xfs_aops.c       |  8 ++++----
 include/linux/pagemap.h | 13 +++++++++++++
 4 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
index e25901ae3ff4..0e76a4b6d98a 100644
--- a/fs/iomap/buffered-io.c
+++ b/fs/iomap/buffered-io.c
@@ -24,7 +24,7 @@ iomap_page_create(struct inode *inode, struct page *pag=
e)
 {
 	struct iomap_page *iop =3D to_iomap_page(page);
=20
-	if (iop || i_blocksize(inode) =3D=3D PAGE_SIZE)
+	if (iop || i_blocks_per_page(inode, page) <=3D 1)
 		return iop;
=20
 	iop =3D kmalloc(sizeof(*iop), GFP_NOFS | __GFP_NOFAIL);
@@ -128,7 +128,7 @@ iomap_set_range_uptodate(struct page *page, unsigned =
off, unsigned len)
 	bool uptodate =3D true;
=20
 	if (iop) {
-		for (i =3D 0; i < PAGE_SIZE / i_blocksize(inode); i++) {
+		for (i =3D 0; i < i_blocks_per_page(inode, page); i++) {
 			if (i >=3D first && i <=3D last)
 				set_bit(i, iop->uptodate);
 			else if (!test_bit(i, iop->uptodate))
diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
index a2f5338a5ea1..176580f54af9 100644
--- a/fs/jfs/jfs_metapage.c
+++ b/fs/jfs/jfs_metapage.c
@@ -473,7 +473,7 @@ static int metapage_readpage(struct file *fp, struct =
page *page)
 	struct inode *inode =3D page->mapping->host;
 	struct bio *bio =3D NULL;
 	int block_offset;
-	int blocks_per_page =3D PAGE_SIZE >> inode->i_blkbits;
+	int blocks_per_page =3D i_blocks_per_page(inode, page);
 	sector_t page_start;	/* address of page in fs blocks */
 	sector_t pblock;
 	int xlen;
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index f16d5f196c6b..102cfd8a97d6 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -68,7 +68,7 @@ xfs_finish_page_writeback(
 		mapping_set_error(inode->i_mapping, -EIO);
 	}
=20
-	ASSERT(iop || i_blocksize(inode) =3D=3D PAGE_SIZE);
+	ASSERT(iop || i_blocks_per_page(inode, bvec->bv_page) <=3D 1);
 	ASSERT(!iop || atomic_read(&iop->write_count) > 0);
=20
 	if (!iop || atomic_dec_and_test(&iop->write_count))
@@ -839,7 +839,7 @@ xfs_aops_discard_page(
 			page, ip->i_ino, offset);
=20
 	error =3D xfs_bmap_punch_delalloc_range(ip, start_fsb,
-			PAGE_SIZE / i_blocksize(inode));
+			i_blocks_per_page(inode, page));
 	if (error && !XFS_FORCED_SHUTDOWN(mp))
 		xfs_alert(mp, "page discard unable to remove delalloc mapping.");
 out_invalidate:
@@ -877,7 +877,7 @@ xfs_writepage_map(
 	uint64_t		file_offset;	/* file offset of page */
 	int			error =3D 0, count =3D 0, i;
=20
-	ASSERT(iop || i_blocksize(inode) =3D=3D PAGE_SIZE);
+	ASSERT(iop || i_blocks_per_page(inode, page) <=3D 1);
 	ASSERT(!iop || atomic_read(&iop->write_count) =3D=3D 0);
=20
 	/*
@@ -886,7 +886,7 @@ xfs_writepage_map(
 	 * one.
 	 */
 	for (i =3D 0, file_offset =3D page_offset(page);
-	     i < (PAGE_SIZE >> inode->i_blkbits) && file_offset < end_offset;
+	     i < i_blocks_per_page(inode, page) && file_offset < end_offset;
 	     i++, file_offset +=3D len) {
 		if (iop && !test_bit(i, iop->uptodate))
 			continue;
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index cf837d313b96..2728f20fbc49 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -644,4 +644,17 @@ static inline unsigned long dir_pages(struct inode *=
inode)
 			       PAGE_SHIFT;
 }
=20
+/**
+ * i_blocks_per_page - How many blocks fit in this page.
+ * @inode: The inode which contains the blocks.
+ * @page: The (potentially large) page.
+ *
+ * Context: Any context.
+ * Return: The number of filesystem blocks covered by this page.
+ */
+static inline
+unsigned int i_blocks_per_page(struct inode *inode, struct page *page)
+{
+	return page_size(page) >> inode->i_blkbits;
+}
 #endif /* _LINUX_PAGEMAP_H */
--=20
2.23.0.rc1


