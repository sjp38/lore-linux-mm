Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FF0AC3A589
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:30:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C810522DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:30:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EYq9cp4l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C810522DA7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C09B36B0010; Tue, 20 Aug 2019 20:30:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B73E76B0266; Tue, 20 Aug 2019 20:30:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BEF86B0269; Tue, 20 Aug 2019 20:30:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id 76A436B0010
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:30:56 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 224F69092
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:30:56 +0000 (UTC)
X-FDA: 75844554912.19.move06_42538bc32f62e
X-HE-Tag: move06_42538bc32f62e
X-Filterd-Recvd-Size: 3271
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:30:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=2gejrSoB2FzOwPwvIl0YMQL5/0v4jqvQgFkwdGSMLdY=; b=EYq9cp4l8H1rBuegeGWSpo3tV/
	b64BCrcV/5dPyOeSAJWKmjxUbIYGlM3/VUrUmNv2AcS7HW4NI30jeKHpIrvz2DbdH48AjTsO9Bch0
	X96PDpCP9O2c97OGZF0tkz3vZsdb7+/vgXSgyCY32JWsOIPikpz9ysGDYhERuourwZJrswEzY4/4s
	0znWy3av/2InYDoHUCu2BfvZR981QSw37FWWDVBJUAZxKPrq+llrq109lbA46BK21cobBmTh4YgeZ
	zRTqHwTik5u0XVUI6hDwDdb65uILwGg2fu1SokY/tbStjIUQVYNZkAmhkJJuO53T5SU6sm0QRPpKw
	kDN3fYlQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0EWQ-0003Hi-EJ; Wed, 21 Aug 2019 00:30:42 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	hch@lst.de,
	linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v2 5/5] xfs: Pass a page to xfs_finish_page_writeback
Date: Tue, 20 Aug 2019 17:30:39 -0700
Message-Id: <20190821003039.12555-6-willy@infradead.org>
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

The only part of the bvec we were accessing was the bv_page, so just
pass that instead of the whole bvec.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/xfs/xfs_aops.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 1a26e9ca626b..edcb4797fcc2 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -58,21 +58,21 @@ xfs_find_daxdev_for_inode(
 static void
 xfs_finish_page_writeback(
 	struct inode		*inode,
-	struct bio_vec	*bvec,
+	struct page		*page,
 	int			error)
 {
-	struct iomap_page	*iop =3D to_iomap_page(bvec->bv_page);
+	struct iomap_page	*iop =3D to_iomap_page(page);
=20
 	if (error) {
-		SetPageError(bvec->bv_page);
+		SetPageError(page);
 		mapping_set_error(inode->i_mapping, -EIO);
 	}
=20
-	ASSERT(iop || i_blocks_per_page(inode, bvec->bv_page) <=3D 1);
+	ASSERT(iop || i_blocks_per_page(inode, page) <=3D 1);
 	ASSERT(!iop || atomic_read(&iop->write_count) > 0);
=20
 	if (!iop || atomic_dec_and_test(&iop->write_count))
-		end_page_writeback(bvec->bv_page);
+		end_page_writeback(page);
 }
=20
 /*
@@ -106,7 +106,7 @@ xfs_destroy_ioend(
=20
 		/* walk each page on bio, ending page IO on them */
 		bio_for_each_segment_all(bvec, bio, iter_all)
-			xfs_finish_page_writeback(inode, bvec, error);
+			xfs_finish_page_writeback(inode, bvec->bv_page, error);
 		bio_put(bio);
 	}
=20
--=20
2.23.0.rc1


