Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF1D8C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:11:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FEDE2077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:11:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FEDE2077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 223CC6B000C; Fri, 26 Apr 2019 09:11:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D4186B000D; Fri, 26 Apr 2019 09:11:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C3796B000E; Fri, 26 Apr 2019 09:11:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0F7A6B000C
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:11:44 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k8so2658823qkj.20
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 06:11:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Cn1DePKLmV5y3t5+SaCnxtJvgiy5550Pyj5j1sjrJLE=;
        b=OA7F3FreQ8PkT1KccUNDDAJaNuU1T6zXuRtnCGciwatk9UKjCPQoEHYbFub4teeBZs
         MKGzM2OjMrjbv/vEBaLgzGkN/O3grCvHNSvEwpishzf4a2Z8yWSDHXqRfd/2Y97b1Gzr
         6ba0ZgJcGG1vgUKVQNwi4IygcOAH+BzpLhlbmvtl5zqrAKc6T9RRob0zoNbWLRfETCEp
         3LPTJbigMXAcokhvWzSiECJclPrIAVLCHF9ZSygw2FMA7ghubB/jCSBfsqVLd6R6mOxh
         2LmwGTJpeVdqakALoHdAkZDRjFQd4nkdlkhdjMpaOoKB0Wu8hrOxyG8HKEIZyAtQ6Vaf
         flvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVRQhDEOw6UlZPtLXRuHxO+Ousxi3YQcm+4MrfrDD5ATBr6URQL
	fSLBKen+w8jLtvDO/adBFjGE7xUU/EOblPtEN2ynfNyW6056K2t63wfLAfDYIYiIQu0gMkOJwTI
	HURdq44uQR2dM4A9+WtEpqDPKFdmvYR+PGZoaCt4dvQ0/rOGxvN5sCZWFhxQBeUibJQ==
X-Received: by 2002:ac8:34ac:: with SMTP id w41mr24353025qtb.186.1556284304634;
        Fri, 26 Apr 2019 06:11:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+/sDQmIN/MOgIQoSiirJcFhfh1GbmJiBTEqTXZYIzMFZbmzE1lVPBPseepxlRLsgYBUFz
X-Received: by 2002:ac8:34ac:: with SMTP id w41mr24352928qtb.186.1556284303515;
        Fri, 26 Apr 2019 06:11:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556284303; cv=none;
        d=google.com; s=arc-20160816;
        b=uuDz8l6G3/uMasos3ZvglHbr3lJiVGyr3jEsRtWcgGDagItWdjOXfSQShCmUwZfAWc
         0s3DF7QjkHJuOKZXU1p1jkzAqjmwXjIAoh1BW6w3etVSV0wB4PkRmeRdb+6Ny5fpD19V
         JE0Zw9n+lP+DtA6k4LM/77xXoDwZsW0T6jCTOzTvzb/1+64J19iskOQjMZ/1LyAVMJZ6
         mlr/72k69qgquEFYaAQ0t70Zk0gqtAvCWXGQzXSKBUkZj80J+68po/glHVaEOPar7R3A
         W4b82ysJbOb7FHQJ9FEwZFPbCH9Cj6Q7GYW5aykKOlfwY5kdJvYi2L8p6xCWoKkFNB6t
         kEGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Cn1DePKLmV5y3t5+SaCnxtJvgiy5550Pyj5j1sjrJLE=;
        b=J8V3r+dQ6JKCf+5GCESZo3yYs87DZzV02kgoeh+eJcU0wUSz0FQS0AmGWaA+Zzrbk1
         FHtedjh0XNF1s4WX/3vpXnqoOhvizBR/SwtlyzQtvF1WOm1aRchLpQ3Dd/rFM81GvzO+
         6LdTy+vas/breQ+SIj+btQatyHxEasQbYRRdpok2xixAzcdPTxcpL0mS5MewdxTNtE5+
         QZHFHJgBS0F/uQO+VN795q79/bUMjJBVeazZHzj6Kjklw9N5ISr1R8whOUgCcBEMmUNC
         Yu4VNPBf4ThGbbppdt64yaiEmvW3izsKaZdQLP+qlZ8Nvj7fsVuQThLmhXpWbKcnfGcU
         +/pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d8si1002366qti.118.2019.04.26.06.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 06:11:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A16F130ABF2A;
	Fri, 26 Apr 2019 13:11:42 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1D9C36607E;
	Fri, 26 Apr 2019 13:11:39 +0000 (UTC)
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
Subject: [PATCH v5 3/3] gfs2: Fix iomap write page reclaim deadlock
Date: Fri, 26 Apr 2019 15:11:27 +0200
Message-Id: <20190426131127.19164-3-agruenba@redhat.com>
In-Reply-To: <20190426131127.19164-1-agruenba@redhat.com>
References: <20190426131127.19164-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 26 Apr 2019 13:11:42 +0000 (UTC)
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
 fs/gfs2/aops.c | 14 ++++++---
 fs/gfs2/bmap.c | 83 +++++++++++++++++++++++++-------------------------
 2 files changed, 52 insertions(+), 45 deletions(-)

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
index 6b980703bae7..27c82f4aaf32 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -994,7 +994,9 @@ static void gfs2_write_unlock(struct inode *inode)
 static int gfs2_iomap_page_prepare(struct inode *inode, loff_t pos,
 				   unsigned len, struct iomap *iomap)
 {
-	return 0;
+	struct gfs2_sbd *sdp = GFS2_SB(inode);
+
+	return gfs2_trans_begin(sdp, RES_DINODE + (len >> inode->i_blkbits), 0);
 }
 
 static void gfs2_iomap_page_done(struct inode *inode, loff_t pos,
@@ -1002,9 +1004,11 @@ static void gfs2_iomap_page_done(struct inode *inode, loff_t pos,
 				 struct iomap *iomap)
 {
 	struct gfs2_inode *ip = GFS2_I(inode);
+	struct gfs2_sbd *sdp = GFS2_SB(inode);
 
-	if (page)
+	if (page && !gfs2_is_stuffed(ip))
 		gfs2_page_add_databufs(ip, page, offset_in_page(pos), copied);
+	gfs2_trans_end(sdp);
 }
 
 static const struct iomap_page_ops gfs2_iomap_page_ops = {
@@ -1064,31 +1068,45 @@ static int gfs2_iomap_begin_write(struct inode *inode, loff_t pos,
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
+
+	if (gfs2_is_stuffed(ip) || gfs2_is_jdata(ip))
 		iomap->page_ops = &gfs2_iomap_page_ops;
 	return 0;
 
@@ -1128,10 +1146,6 @@ static int gfs2_iomap_begin(struct inode *inode, loff_t pos, loff_t length,
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
@@ -1142,27 +1156,16 @@ static int gfs2_iomap_end(struct inode *inode, loff_t pos, loff_t length,
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
@@ -1182,8 +1185,6 @@ static int gfs2_iomap_end(struct inode *inode, loff_t pos, loff_t length,
 	gfs2_write_unlock(inode);
 
 out:
-	if (dibh)
-		brelse(dibh);
 	return 0;
 }
 
-- 
2.20.1

