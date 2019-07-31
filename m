Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50DBBC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:17:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1668F206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:17:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="P0rJHAe2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1668F206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8AFA8E0009; Wed, 31 Jul 2019 13:17:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A147D8E0001; Wed, 31 Jul 2019 13:17:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B5638E0009; Wed, 31 Jul 2019 13:17:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52CEE8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:17:41 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so43637627pfj.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:17:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HV9OHEipfxCPgutiQGXqeRhXySlsjKTgVgxjP7nxxBU=;
        b=iXgGkMhC3OEY2Mi/7wbRj7xJmlqCqkHZhJ4iNUnJF55NKSKyNUg1A9Kx6hR/4aQBTs
         e/TdvZZ0uPBA/m+Hqk54jFGc7bl8ARJkr6nSk84pRwq93wJ+NcFGQMI6Plp1YgSVDUcu
         KY0NEctOch2lECVDGeO2pRN5TUcOsR9PPuRLFzeyq8IQMA/vKeqUGCE4uXNIm2GJLOan
         DNREq6Bs64CJaqiCt0r++TjGN2Jn/hvkWETxDBLYCVVofr9d4r0E42stiXc2Zi5uzFbL
         xvJGRbJzcsGInNFUvi3j6AGZeTVsb3asJfJwb5Ne+3Hl6JAvKav9D0vK7hdC8i5Z1HRg
         LB8A==
X-Gm-Message-State: APjAAAVbDNHr7U7TxvF0aIspV2jIQvx7ghp8UC1NAgdPxwP2txzCMNhy
	EybX5go2c5L7/S10VYpBRBLa/MMxNALFxec2lSjd0a3gd+ycysC2llu41RFu/OfrWLm6g42tBFB
	CwZTPXN4iww020UpqjSm5ZX+jLLmiM3k43R23qKo4l9U0xhXN9MlJU49bmrseJwOh3Q==
X-Received: by 2002:a17:902:5985:: with SMTP id p5mr25130445pli.177.1564593460943;
        Wed, 31 Jul 2019 10:17:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHDLeK4+wV4yOCDTlTl55H8QxZfqcOLYFo84Po7TX7/7lbFiuRnr1/RFesRk5HCPzRoPWo
X-Received: by 2002:a17:902:5985:: with SMTP id p5mr25130379pli.177.1564593460006;
        Wed, 31 Jul 2019 10:17:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564593460; cv=none;
        d=google.com; s=arc-20160816;
        b=N/PqB+x8aKMIWj+MBdCXC2gF9sX6vGFXYG39/weBcoNnteyFiYeqrhE+kFK62wWNqf
         cGou8D6Yau+PZtMv75Wj67lGDxY0Tb156gsIvX1hWBBw6rKd9jBJtctbWQJ7KvR7Rmi+
         iO00iUz63LYNoxLXcPBsVfUQqbcMYT1x9s+hyhn9iq9pxzouEecLZocQxz3WGqXchLin
         bGRwaZQfGNzXikir8uGHct7hJhjPKea12dkS1ot+WDAzbLaexwO7TeBGzoEN/QXu+nSL
         yNRod+AL5UTV4FbwiJ3bNbSesLOsEzNDGcQyRYdb8h31pZxB/W9oWuyhL460Gi3nHT8N
         AtAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=HV9OHEipfxCPgutiQGXqeRhXySlsjKTgVgxjP7nxxBU=;
        b=yV8Dx2Ff6h23o+5EuiwgjuUvzPeVm2MiuXRqzkUNksOODa5qTSj7dArrZ0K5do/pt5
         cY/ttUFdKFqQhq2TA8lw6VIpT8dhOjq5rSMJ4TKxM0wDS6LA+zLYivvg3vh82WPj6bTg
         4g6fgJZsZE3SJ2ssE1VS+XP560PGA6jtPl5mvY5fJ72NQn7rJYQxdTcbYs1C48E4IFu9
         eTgDeDVaBTcXYvSprjjUeYs3ru6tEACxBucB79vFLkY8ZRw8bs+2KCZvtJFEV6TLFhpW
         7M9lu1RmHYo4Bb8pH7sEzDG+M2LRsfkOYUjglgyGfZdM9LCBhE550YKNt69a17s5gBmi
         odmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=P0rJHAe2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s9si29115625plr.146.2019.07.31.10.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 10:17:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=P0rJHAe2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=HV9OHEipfxCPgutiQGXqeRhXySlsjKTgVgxjP7nxxBU=; b=P0rJHAe2ztcyEKOVHrZ1l4pFJ3
	mEzC80jwBqdblXcD0Vkz2OWUd2FntcuKByR2b+2SengM4mEEM85AZc/w83DoO+PVSCi53R4FCES0T
	fp5qVSMyZrkkY9IlLeapeoz9/sCFnrvS/Y7pM7IY+t/asRTihuD5iz6GqlTBjaIreECilnj50m7Rb
	9Y/kg8tKY9CvoVRfvtS+En6Ewn+mdphPcaqI/P1zS7BkFNaLcS2mdUWcDsQaGecEsdsuwA1TAHF+a
	+9y5GCC0A+IX3MQQZaoxthYtRihLqyIhIIWOYEyWJBOvjOQpJZcHUMC/CtOFpuV4qRmju87sgaZhg
	n3QDaLew==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hssEN-0005dN-6i; Wed, 31 Jul 2019 17:17:39 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	hch@lst.de,
	linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH 2/2] xfs: Support large pages
Date: Wed, 31 Jul 2019 10:17:34 -0700
Message-Id: <20190731171734.21601-3-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731171734.21601-1-willy@infradead.org>
References: <20190731171734.21601-1-willy@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Mostly this is just checking the page size of each page instead of
assuming PAGE_SIZE.  Clean up the logic in writepage a little.

Based on a patch from Christoph Hellwig.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/xfs/xfs_aops.c | 37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index f16d5f196c6b..4952cd7d8c6c 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -58,21 +58,22 @@ xfs_find_daxdev_for_inode(
 static void
 xfs_finish_page_writeback(
 	struct inode		*inode,
-	struct bio_vec	*bvec,
+	struct bio_vec		*bvec,
 	int			error)
 {
-	struct iomap_page	*iop = to_iomap_page(bvec->bv_page);
+	struct page		*page = bvec->bv_page;
+	struct iomap_page	*iop = to_iomap_page(page);
 
 	if (error) {
-		SetPageError(bvec->bv_page);
+		SetPageError(page);
 		mapping_set_error(inode->i_mapping, -EIO);
 	}
 
-	ASSERT(iop || i_blocksize(inode) == PAGE_SIZE);
+	ASSERT(iop || i_blocksize(inode) == page_size(page));
 	ASSERT(!iop || atomic_read(&iop->write_count) > 0);
 
 	if (!iop || atomic_dec_and_test(&iop->write_count))
-		end_page_writeback(bvec->bv_page);
+		end_page_writeback(page);
 }
 
 /*
@@ -765,7 +766,7 @@ xfs_add_to_ioend(
 	struct xfs_mount	*mp = ip->i_mount;
 	struct block_device	*bdev = xfs_find_bdev_for_inode(inode);
 	unsigned		len = i_blocksize(inode);
-	unsigned		poff = offset & (PAGE_SIZE - 1);
+	unsigned		poff = offset & (page_size(page) - 1);
 	bool			merged, same_page = false;
 	sector_t		sector;
 
@@ -839,11 +840,11 @@ xfs_aops_discard_page(
 			page, ip->i_ino, offset);
 
 	error = xfs_bmap_punch_delalloc_range(ip, start_fsb,
-			PAGE_SIZE / i_blocksize(inode));
+			page_size(page) / i_blocksize(inode));
 	if (error && !XFS_FORCED_SHUTDOWN(mp))
 		xfs_alert(mp, "page discard unable to remove delalloc mapping.");
 out_invalidate:
-	xfs_vm_invalidatepage(page, 0, PAGE_SIZE);
+	xfs_vm_invalidatepage(page, 0, page_size(page));
 }
 
 /*
@@ -877,7 +878,7 @@ xfs_writepage_map(
 	uint64_t		file_offset;	/* file offset of page */
 	int			error = 0, count = 0, i;
 
-	ASSERT(iop || i_blocksize(inode) == PAGE_SIZE);
+	ASSERT(iop || i_blocksize(inode) == page_size(page));
 	ASSERT(!iop || atomic_read(&iop->write_count) == 0);
 
 	/*
@@ -886,7 +887,8 @@ xfs_writepage_map(
 	 * one.
 	 */
 	for (i = 0, file_offset = page_offset(page);
-	     i < (PAGE_SIZE >> inode->i_blkbits) && file_offset < end_offset;
+	     i < (page_size(page) >> inode->i_blkbits) &&
+						file_offset < end_offset;
 	     i++, file_offset += len) {
 		if (iop && !test_bit(i, iop->uptodate))
 			continue;
@@ -984,8 +986,7 @@ xfs_do_writepage(
 	struct xfs_writepage_ctx *wpc = data;
 	struct inode		*inode = page->mapping->host;
 	loff_t			offset;
-	uint64_t              end_offset;
-	pgoff_t                 end_index;
+	uint64_t		end_offset;
 
 	trace_xfs_writepage(inode, page, 0, 0);
 
@@ -1024,10 +1025,9 @@ xfs_do_writepage(
 	 * ---------------------------------^------------------|
 	 */
 	offset = i_size_read(inode);
-	end_index = offset >> PAGE_SHIFT;
-	if (page->index < end_index)
-		end_offset = (xfs_off_t)(page->index + 1) << PAGE_SHIFT;
-	else {
+	end_offset = (xfs_off_t)(page->index + compound_nr(page)) << PAGE_SHIFT;
+
+	if (end_offset > offset) {
 		/*
 		 * Check whether the page to write out is beyond or straddles
 		 * i_size or not.
@@ -1039,7 +1039,8 @@ xfs_do_writepage(
 		 * |				    |      Straddles     |
 		 * ---------------------------------^-----------|--------|
 		 */
-		unsigned offset_into_page = offset & (PAGE_SIZE - 1);
+		unsigned offset_into_page = offset & (page_size(page) - 1);
+		pgoff_t end_index = offset >> PAGE_SHIFT;
 
 		/*
 		 * Skip the page if it is fully outside i_size, e.g. due to a
@@ -1070,7 +1071,7 @@ xfs_do_writepage(
 		 * memory is zeroed when mapped, and writes to that region are
 		 * not written out to the file."
 		 */
-		zero_user_segment(page, offset_into_page, PAGE_SIZE);
+		zero_user_segment(page, offset_into_page, page_size(page));
 
 		/* Adjust the end_offset to the end of file */
 		end_offset = offset;
-- 
2.20.1

