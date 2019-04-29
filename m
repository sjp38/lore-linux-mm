Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66810C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 16:33:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15E1520675
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 16:32:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15E1520675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 980DB6B000D; Mon, 29 Apr 2019 12:32:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 936FE6B000E; Mon, 29 Apr 2019 12:32:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ACEB6B0010; Mon, 29 Apr 2019 12:32:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2496B000D
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:32:59 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k8so9407710qkj.20
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 09:32:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Cn1DePKLmV5y3t5+SaCnxtJvgiy5550Pyj5j1sjrJLE=;
        b=oIdatnsTNIfKZJzt2XyVSbrX3Mq+eB4eKkjirjy+8D/Gvvl+YSkZHTOvLbSDmhgIx5
         MAkQ8NZTz9Cz0vjJUsk8uhutklHhWlxO2SU0xNa3uwB0eAjsJV0yCGi7ywl4YJVw8jmH
         aWMflIXLG/KAolGfXxc0bngH2h4o4W1MKTeOhdIYTkOAfxLim8qzwh5mFipNwR6KjMMn
         V/Wn45UQ/7XoVHIyPPpO7rlNH10LXqduUXUQD+dkHikRxCeo4WUb1KkzmNaTK2ugg5Mx
         nitOLKJZaDMdD0MqPrjWbXtHOT6ZuCd9MzFgIld4N92dBD5gmt8EbJ3AKnSmP6VGYXj2
         JpEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWvWdBXGxnn3ifuVQdZUx8sLzUr8A1eq9nfJbDDLByR7L77njvO
	Zq0kx/Lzi6o7kTo546YlR1LCIwOx0TuYljzHhg8NTHikTeYrSXwf0HWRyZ+KlM8ZoL7N7zTOmGx
	+6/6mu9szP2cUKJkKJIoLUzhKxMesn4lfEKgBt/dElNw+b8Nl0fc7Qz6XuebFOxJ+Rg==
X-Received: by 2002:ac8:30cb:: with SMTP id w11mr40672140qta.210.1556555579041;
        Mon, 29 Apr 2019 09:32:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydHNZE6Tyfe3JR1k6YbGYsIFUE2cdexDRIJtQa/WeuTXnM310uDMKCTFP1TlZCK8oOIIiC
X-Received: by 2002:ac8:30cb:: with SMTP id w11mr40672044qta.210.1556555577665;
        Mon, 29 Apr 2019 09:32:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556555577; cv=none;
        d=google.com; s=arc-20160816;
        b=BXG/+m3pAwpMgv96uSUDIxhGHpI9CsQR5FawHMJENz8aRsvCg6MfpsQ6ap0cb5bt0q
         7XOrtE87ZsB20IBXGyBKmjNNtJ4+pcVC2UzKzcTV/EDzLhn8NDRHwkBTFjyIg1Is1tbo
         6DkhqHxY5obNRBIgULGhz6HAfdwppjtZ3ViKqR/uQlo16kMBRQm4BJcN0A+9BqnPfzDQ
         TOV87I9RYbpZOXRrzKcgLF7LijuBi1hid1GN1f6erWeHldHB3xq+g9hDnVV3zWKNxKW2
         AU7ylIOQJTnQnSrSFzc5Ihv7eMugFMB3zlpyK5ZFsvdL0MUynuvx4xvfydUCtNYX/5p6
         qygQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Cn1DePKLmV5y3t5+SaCnxtJvgiy5550Pyj5j1sjrJLE=;
        b=nKtk9/NFTvj6JPIYUVup8GYQGbRYyTtelas3+9vnQd8cq0/Wetar5NCK8Empn/pRVy
         8ofsnFz0pYSi0vnVSfor+odDZmXkG452hmm35lH6ZO15STyLfROwyCaVLVdKTXTG4yxZ
         +YDfWDcZ+pe2hGiwsbxoClt7F7JyAB9g5t8psPjmXDAKiiFkwGiLs7g69eJF25vpe0ym
         XtPIMWcinar8cd0LwD1HlOViugcCYHZ5T6SQ7jlKNMChLWyNat+wGgM1qMbn4ZJDOoHI
         v+fZh32ska+Psrz2uG19D3TTPifvDi1+6gZmKc8R0Q7I8osD8CphU+LucnHvn73TfVWg
         a6IA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d21si31098qkb.125.2019.04.29.09.32.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 09:32:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C721B3087924;
	Mon, 29 Apr 2019 16:32:56 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3B11557980;
	Mon, 29 Apr 2019 16:32:54 +0000 (UTC)
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
Subject: [PATCH v6 4/4] gfs2: Fix iomap write page reclaim deadlock
Date: Mon, 29 Apr 2019 18:32:39 +0200
Message-Id: <20190429163239.4874-4-agruenba@redhat.com>
In-Reply-To: <20190429163239.4874-1-agruenba@redhat.com>
References: <20190429163239.4874-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 29 Apr 2019 16:32:56 +0000 (UTC)
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

