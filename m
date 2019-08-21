Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7172FC3A589
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:30:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3323A22DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:30:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="E8OZSh34"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3323A22DA7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8360E6B000A; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E6466B0008; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 611EF6B000D; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3386B0008
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CADCB181AC9BF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:30:50 +0000 (UTC)
X-FDA: 75844554660.07.ship03_4189c4ac0ca11
X-HE-Tag: ship03_4189c4ac0ca11
X-Filterd-Recvd-Size: 4387
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:30:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=iwYJY7S8Qb3H1qd117LIhrHhXdjR6K0E8vfO12YRxHU=; b=E8OZSh34g8xMpPIQPPbI3RZ0Kk
	hWiv0hKFRqYz71lulS4vK7X2SzdOejeqNSjZFjiwdzctHwxmYxjt2rbXqtSfGLXY/R8RMIb38nENR
	SVDccHI0NjXZ52zIbgPv/PhQCqPyRhEfg1HN1AKyv9E2Yo8awIGe7MoLeE6HEkoc4U56uU4Q6W5NK
	2ThzHhoP/rlPJo6FnTIQiuLSBncuS5r+p844p8Y5L4uIVvTNo2z3KKWRCTW1xPGqfQfm0sf6kSJD1
	YXjBJBI4EZPMSD1H7X/10qWG308clwCMzszz8CcP/eG//fYHoALpRCXVg+F3qBCimu7scohi0Esh5
	AvILxmEQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0EWQ-0003He-Cw; Wed, 21 Aug 2019 00:30:42 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	hch@lst.de,
	linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v2 4/5] xfs: Support large pages
Date: Tue, 20 Aug 2019 17:30:38 -0700
Message-Id: <20190821003039.12555-5-willy@infradead.org>
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

Mostly this is just checking the page size of each page instead of
assuming PAGE_SIZE.  Clean up the logic in writepage a little.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/xfs/xfs_aops.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 102cfd8a97d6..1a26e9ca626b 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -765,7 +765,7 @@ xfs_add_to_ioend(
 	struct xfs_mount	*mp =3D ip->i_mount;
 	struct block_device	*bdev =3D xfs_find_bdev_for_inode(inode);
 	unsigned		len =3D i_blocksize(inode);
-	unsigned		poff =3D offset & (PAGE_SIZE - 1);
+	unsigned		poff =3D offset & (page_size(page) - 1);
 	bool			merged, same_page =3D false;
 	sector_t		sector;
=20
@@ -843,7 +843,7 @@ xfs_aops_discard_page(
 	if (error && !XFS_FORCED_SHUTDOWN(mp))
 		xfs_alert(mp, "page discard unable to remove delalloc mapping.");
 out_invalidate:
-	xfs_vm_invalidatepage(page, 0, PAGE_SIZE);
+	xfs_vm_invalidatepage(page, 0, page_size(page));
 }
=20
 /*
@@ -984,8 +984,7 @@ xfs_do_writepage(
 	struct xfs_writepage_ctx *wpc =3D data;
 	struct inode		*inode =3D page->mapping->host;
 	loff_t			offset;
-	uint64_t              end_offset;
-	pgoff_t                 end_index;
+	uint64_t		end_offset;
=20
 	trace_xfs_writepage(inode, page, 0, 0);
=20
@@ -1024,10 +1023,9 @@ xfs_do_writepage(
 	 * ---------------------------------^------------------|
 	 */
 	offset =3D i_size_read(inode);
-	end_index =3D offset >> PAGE_SHIFT;
-	if (page->index < end_index)
-		end_offset =3D (xfs_off_t)(page->index + 1) << PAGE_SHIFT;
-	else {
+	end_offset =3D file_offset_of_next_page(page);
+
+	if (end_offset > offset) {
 		/*
 		 * Check whether the page to write out is beyond or straddles
 		 * i_size or not.
@@ -1039,7 +1037,8 @@ xfs_do_writepage(
 		 * |				    |      Straddles     |
 		 * ---------------------------------^-----------|--------|
 		 */
-		unsigned offset_into_page =3D offset & (PAGE_SIZE - 1);
+		unsigned offset_into_page =3D offset_in_this_page(page, offset);
+		pgoff_t end_index =3D offset >> PAGE_SHIFT;
=20
 		/*
 		 * Skip the page if it is fully outside i_size, e.g. due to a
@@ -1070,7 +1069,7 @@ xfs_do_writepage(
 		 * memory is zeroed when mapped, and writes to that region are
 		 * not written out to the file."
 		 */
-		zero_user_segment(page, offset_into_page, PAGE_SIZE);
+		zero_user_segment(page, offset_into_page, page_size(page));
=20
 		/* Adjust the end_offset to the end of file */
 		end_offset =3D offset;
--=20
2.23.0.rc1


