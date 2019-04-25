Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 169E7C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:26:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F35520644
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:26:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F35520644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 694F36B000E; Thu, 25 Apr 2019 11:26:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61CC16B0010; Thu, 25 Apr 2019 11:26:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E56B6B0266; Thu, 25 Apr 2019 11:26:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 265D06B000E
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:26:46 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o16so48463qtp.18
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:26:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1eLtoO5jECxXZIf0RJD13h2qj+eELGXBHn/k+qMAvyc=;
        b=W9UFpBiWv7kfpczi/Juft/JIn9siofGpLb+XGYktzLiJ2qsGUMTPfP10ryAAtCPzJ0
         zJbkXZBplk1w9A07N7Td6EHWhlqykXzR15ic0nV5W0ir2pTl9NWYmZHAzKdzKOdeEOZd
         jwgJWCloDqkH48d7DZjWSltqryAJeB3B8kviK/9B9TLKEQgnDES3oLgNveKZtu/KbgdF
         NhJP/I2zJe3EtWz05j9BQzflft3dB+oMIDr0E1ozQXfqSq3c1lszoL9piH5sBocVn55f
         ie0E4LFkXrv8KYcoD9h8n04fFoMe5nhD85BPWv9Q85e+GuojItXw8L4SNc7PCqRV5KHE
         /lNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWCoAPw+iRUuJZujSaoy/MSJyj+FZrUilY5/UJbjwyIoNtY9WUp
	as8bskg5zzTEmhNnDOUlsEdQh6qWueZXeEk3Koj+81Ku30tgMJdBIlTNJZqauW/TlMrLpK5ZHET
	9aNTMFvYkR4+Ue83/oUJ/VhmyRQMwdxX2zRm89IYqyEF/36gxjuGaVtU7+NP4XhqqEA==
X-Received: by 2002:ac8:524d:: with SMTP id y13mr27324501qtn.99.1556206005837;
        Thu, 25 Apr 2019 08:26:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLyOSE9j2CWYkf2z/xCKOyUz+fvi8E6/kHkMmMT0j4hmX6TUKEvKcrI9Fgk9uE6glV05zy
X-Received: by 2002:ac8:524d:: with SMTP id y13mr27324432qtn.99.1556206004879;
        Thu, 25 Apr 2019 08:26:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556206004; cv=none;
        d=google.com; s=arc-20160816;
        b=Q+Z3ENdxVOi6qqk8QpMmHOQlGbuGpevdusq8zEEeHi8rKyP+QFLT7eqVNzrICPQ1/G
         u1cN0ODQYXBjYOxlVCiPZ/GnmQtNOypJZyCEtPuklAnk33F7FP0qR/7Wl/og/vJyQmRa
         Fvi9oJmCBcWQjXIAxgB2CJgM2WbhtK5RCRAQJb8Ij+2oa9ok93cqHrl/IPobTRmxrcc9
         mmV99TnH/gHP4Av6DHhRTOcFOGdXCBXoLCr+nWxTQbKFwqgcQsbhQPjgMos2gAGaPiDp
         xxUuaSyl8Sbo0OPVTOamP+MFzFisPbgQ8knGaIk+wiwP1akLXNu+PUr0CkcqGKXLESYO
         4xKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1eLtoO5jECxXZIf0RJD13h2qj+eELGXBHn/k+qMAvyc=;
        b=zgmYHBqHxbpVhsVMsNcIgYh65rdSRC2Jc04wR6b5hkPmIwlVd2UxRaS8Cy6SOVarq3
         gSjR3Z+FvRZSc8+AVASaBCCcr3vzEbyonMmZl8qEaHnQWSMH6PI5O6ZUSbO1HNp6Y4dD
         v5xvTHYgpj+YwdbgMa8avPI4ugA2xa5S20+hGGdOU+MAQbu5kICUVCk2tU6UV93UR4HJ
         mB2MtNVQVsCvR7XDbiRZuxG/lgfy1RrtpUR+EC62RdPtC9hg4x9otNQidXEzsuoX42rF
         XqAIVqmWZwU++e0uK0E7LDcpBAdMhSvtTCY2Yp7+Zw8W1/ml3cy8usKHQBC7N+cO/sFJ
         E2Ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w1si7644879qvi.135.2019.04.25.08.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 08:26:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 18558C05B1CB;
	Thu, 25 Apr 2019 15:26:44 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 28D4161D26;
	Thu, 25 Apr 2019 15:26:38 +0000 (UTC)
From: Andreas Gruenbacher <agruenba@redhat.com>
To: cluster-devel@redhat.com,
	Christoph Hellwig <hch@lst.de>
Cc: Bob Peterson <rpeterso@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	=?UTF-8?q?Edwin=20T=C3=B6r=C3=B6k?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v2 2/2] gfs2: Fix iomap write page reclaim deadlock
Date: Thu, 25 Apr 2019 17:26:31 +0200
Message-Id: <20190425152631.633-2-agruenba@redhat.com>
In-Reply-To: <20190425152631.633-1-agruenba@redhat.com>
References: <20190425152631.633-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 25 Apr 2019 15:26:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit 64bc06bb32ee ("gfs2: iomap buffered write support"), gfs2 is doing
buffered writes by starting a transaction in iomap_begin, writing a range of
pages, and ending that transaction in iomap_end.  This approach suffers from
two problems:

  (1) Any allocations necessary for the write are done in iomap_begin, so when
  the data aren't journaled, there is no need for keeping the transaction open
  until iomap_end.

  (2) Transactions keep the gfs2 log flush lock held.  When
  iomap_file_buffered_write calls balance_dirty_pages, this can end up calling
  gfs2_write_inode, which will try to flush the log.  This requires taking the
  log flush lock which is already held, resulting in a deadlock.

Fix both of these issues by not keeping transactions open from iomap_begin to
iomap_end.  Instead, start a small transaction in page_prepare and end it in
page_done when necessary.

Reported-by: Edwin Török <edvin.torok@citrix.com>
Fixes: 64bc06bb32ee ("gfs2: iomap buffered write support")
Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Signed-off-by: Bob Peterson <rpeterso@redhat.com>
---
 fs/gfs2/aops.c |  14 +++++--
 fs/gfs2/bmap.c | 101 ++++++++++++++++++++++++++++---------------------
 fs/iomap.c     |   1 +
 3 files changed, 68 insertions(+), 48 deletions(-)

diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 05dd78f4b2b3..6210d4429d84 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -649,7 +649,7 @@ static int gfs2_readpages(struct file *file, struct address_space *mapping,
  */
 void adjust_fs_space(struct inode *inode)
 {
-	struct gfs2_sbd *sdp = inode->i_sb->s_fs_info;
+	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	struct gfs2_inode *m_ip = GFS2_I(sdp->sd_statfs_inode);
 	struct gfs2_inode *l_ip = GFS2_I(sdp->sd_sc_inode);
 	struct gfs2_statfs_change_host *m_sc = &sdp->sd_statfs_master;
@@ -657,10 +657,13 @@ void adjust_fs_space(struct inode *inode)
 	struct buffer_head *m_bh, *l_bh;
 	u64 fs_total, new_free;
 
+	if (gfs2_trans_begin(sdp, 2 * RES_STATFS, 0) != 0)
+		return;
+
 	/* Total up the file system space, according to the latest rindex. */
 	fs_total = gfs2_ri_total(sdp);
 	if (gfs2_meta_inode_buffer(m_ip, &m_bh) != 0)
-		return;
+		goto out;
 
 	spin_lock(&sdp->sd_statfs_spin);
 	gfs2_statfs_change_in(m_sc, m_bh->b_data +
@@ -675,11 +678,14 @@ void adjust_fs_space(struct inode *inode)
 	gfs2_statfs_change(sdp, new_free, new_free, 0);
 
 	if (gfs2_meta_inode_buffer(l_ip, &l_bh) != 0)
-		goto out;
+		goto out2;
 	update_statfs(sdp, m_bh, l_bh);
 	brelse(l_bh);
-out:
+out2:
 	brelse(m_bh);
+out:
+	sdp->sd_rindex_uptodate = 0;
+	gfs2_trans_end(sdp);
 }
 
 /**
diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index 5da4ca9041c0..2fae3f4f5db6 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -991,15 +991,31 @@ static void gfs2_write_unlock(struct inode *inode)
 	gfs2_glock_dq_uninit(&ip->i_gh);
 }
 
-static void gfs2_iomap_journaled_page_done(struct inode *inode, loff_t pos,
-				unsigned copied, struct page *page,
-				struct iomap *iomap)
+static int gfs2_iomap_page_prepare(struct inode *inode, loff_t pos,
+				   unsigned len, struct iomap *iomap)
+{
+	struct gfs2_sbd *sdp = GFS2_SB(inode);
+
+	return gfs2_trans_begin(sdp, RES_DINODE + (len >> inode->i_blkbits), 0);
+}
+
+static void gfs2_iomap_page_done(struct inode *inode, loff_t pos,
+				 unsigned copied, struct page *page,
+				 struct iomap *iomap)
 {
 	struct gfs2_inode *ip = GFS2_I(inode);
+	struct gfs2_sbd *sdp = GFS2_SB(inode);
 
-	gfs2_page_add_databufs(ip, page, offset_in_page(pos), copied);
+	if (page && !gfs2_is_stuffed(ip))
+		gfs2_page_add_databufs(ip, page, offset_in_page(pos), copied);
+	gfs2_trans_end(sdp);
 }
 
+const struct iomap_page_ops gfs2_iomap_page_ops = {
+	.page_prepare = gfs2_iomap_page_prepare,
+	.page_done = gfs2_iomap_page_done,
+};
+
 static int gfs2_iomap_begin_write(struct inode *inode, loff_t pos,
 				  loff_t length, unsigned flags,
 				  struct iomap *iomap,
@@ -1052,32 +1068,46 @@ static int gfs2_iomap_begin_write(struct inode *inode, loff_t pos,
 	if (alloc_required)
 		rblocks += gfs2_rg_blocks(ip, data_blocks + ind_blocks);
 
-	ret = gfs2_trans_begin(sdp, rblocks, iomap->length >> inode->i_blkbits);
-	if (ret)
-		goto out_trans_fail;
+	if (unstuff || iomap->type == IOMAP_HOLE) {
+		struct gfs2_trans *tr;
 
-	if (unstuff) {
-		ret = gfs2_unstuff_dinode(ip, NULL);
-		if (ret)
-			goto out_trans_end;
-		release_metapath(mp);
-		ret = gfs2_iomap_get(inode, iomap->offset, iomap->length,
-				     flags, iomap, mp);
+		ret = gfs2_trans_begin(sdp, rblocks,
+				       iomap->length >> inode->i_blkbits);
 		if (ret)
-			goto out_trans_end;
-	}
+			goto out_trans_fail;
 
-	if (iomap->type == IOMAP_HOLE) {
-		ret = gfs2_iomap_alloc(inode, iomap, flags, mp);
-		if (ret) {
-			gfs2_trans_end(sdp);
-			gfs2_inplace_release(ip);
-			punch_hole(ip, iomap->offset, iomap->length);
-			goto out_qunlock;
+		if (unstuff) {
+			ret = gfs2_unstuff_dinode(ip, NULL);
+			if (ret)
+				goto out_trans_end;
+			release_metapath(mp);
+			ret = gfs2_iomap_get(inode, iomap->offset,
+					     iomap->length, flags, iomap, mp);
+			if (ret)
+				goto out_trans_end;
 		}
+
+		if (iomap->type == IOMAP_HOLE) {
+			ret = gfs2_iomap_alloc(inode, iomap, flags, mp);
+			if (ret) {
+				gfs2_trans_end(sdp);
+				gfs2_inplace_release(ip);
+				punch_hole(ip, iomap->offset, iomap->length);
+				goto out_qunlock;
+			}
+		}
+
+		tr = current->journal_info;
+		if (tr->tr_num_buf_new)
+			__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
+		else
+			gfs2_trans_add_meta(ip->i_gl, mp->mp_bh[0]);
+
+		gfs2_trans_end(sdp);
 	}
-	if (!gfs2_is_stuffed(ip) && gfs2_is_jdata(ip))
-		iomap->page_done = gfs2_iomap_journaled_page_done;
+
+	if (gfs2_is_stuffed(ip) || gfs2_is_jdata(ip))
+		iomap->page_ops = &gfs2_iomap_page_ops;
 	return 0;
 
 out_trans_end:
@@ -1116,10 +1146,6 @@ static int gfs2_iomap_begin(struct inode *inode, loff_t pos, loff_t length,
 		    iomap->type != IOMAP_MAPPED)
 			ret = -ENOTBLK;
 	}
-	if (!ret) {
-		get_bh(mp.mp_bh[0]);
-		iomap->private = mp.mp_bh[0];
-	}
 	release_metapath(&mp);
 	trace_gfs2_iomap_end(ip, iomap, ret);
 	return ret;
@@ -1130,27 +1156,16 @@ static int gfs2_iomap_end(struct inode *inode, loff_t pos, loff_t length,
 {
 	struct gfs2_inode *ip = GFS2_I(inode);
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
-	struct gfs2_trans *tr = current->journal_info;
-	struct buffer_head *dibh = iomap->private;
 
 	if ((flags & (IOMAP_WRITE | IOMAP_DIRECT)) != IOMAP_WRITE)
 		goto out;
 
-	if (iomap->type != IOMAP_INLINE) {
+	if (!gfs2_is_stuffed(ip))
 		gfs2_ordered_add_inode(ip);
 
-		if (tr->tr_num_buf_new)
-			__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
-		else
-			gfs2_trans_add_meta(ip->i_gl, dibh);
-	}
-
-	if (inode == sdp->sd_rindex) {
+	if (inode == sdp->sd_rindex)
 		adjust_fs_space(inode);
-		sdp->sd_rindex_uptodate = 0;
-	}
 
-	gfs2_trans_end(sdp);
 	gfs2_inplace_release(ip);
 
 	if (length != written && (iomap->flags & IOMAP_F_NEW)) {
@@ -1170,8 +1185,6 @@ static int gfs2_iomap_end(struct inode *inode, loff_t pos, loff_t length,
 	gfs2_write_unlock(inode);
 
 out:
-	if (dibh)
-		brelse(dibh);
 	return 0;
 }
 
diff --git a/fs/iomap.c b/fs/iomap.c
index 967c985c5310..667a822ecb7d 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -665,6 +665,7 @@ static int
 iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
 		struct page **pagep, struct iomap *iomap)
 {
+	const struct iomap_page_ops *page_ops = iomap->page_ops;
 	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *page;
 	int status = 0;
-- 
2.20.1

