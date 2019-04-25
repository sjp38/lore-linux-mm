Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E53E8C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:35:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D47A220685
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:35:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D47A220685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0354C6B0003; Thu, 25 Apr 2019 15:35:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F282A6B0005; Thu, 25 Apr 2019 15:35:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3B576B0006; Thu, 25 Apr 2019 15:35:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C37606B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:35:47 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id i124so843397qkf.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:35:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=XjZxVnTvKHgAcOp0hpy7ikW8MjvNV39uxt972bUzcuw=;
        b=rqUT1dqZnq+pS2/r5QDRrg8ITsUe+8rWShazwMcIVrasiaxQTEL5iynHjO49ZBnMJX
         KNhT6+z3RGZXBKxt8ducI3JPFyyNsXDz3IW87YIqXWVBEXroaicbQdbmfMa4bOKJwvog
         UO0r1xnkPoeLibi4Yg/7gniv71qj+5WdRD8De5PZsVxCEvQloZ/9rYXLN38fRXizxjo8
         v5bykTtDp1CHmwFAID6X65z97Bw/xd8qMi8ctbCtt3uFoW7Oqs6LWlb7bRG51h16e8q5
         3fchAcfQ859TIs5/u3M/NbCforHI48K6wVBKq7BYVMv+jF4gF1FWQJRdDlsydzqMSZgT
         vHLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVAGDc97j3/deX6Y52+7VhAMujXsW23pupIA8lfVqMN6AsLbB8F
	XZ7+P5MakvrJTnTFIIyrq3M5dLZOyzxYGPULTr7oe1J0RZj++o9+gh5kWbkMOZp1We9A3SsqI1L
	zvXaoyjsbV1nlLPmUOkrJcBd4AV0bulSpgtSYDYzPDbf/9R1rNbaolXv0pq2qsNIXjA==
X-Received: by 2002:ae9:c005:: with SMTP id u5mr20690566qkk.179.1556220947499;
        Thu, 25 Apr 2019 12:35:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygQtUa5CAL52LzWzl5s7uHyfXDzLjSZDAdS4X8qBYKkwDk+o1ajV7KrWIYK4pps1Aq7e35
X-Received: by 2002:ae9:c005:: with SMTP id u5mr20690493qkk.179.1556220946455;
        Thu, 25 Apr 2019 12:35:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556220946; cv=none;
        d=google.com; s=arc-20160816;
        b=ReM7HSLBxTv8KM3xOcNkCdWUTzxl/4zeXLu3ijVTnk9mED8aL0kyq4vRYmagaDNRDE
         9SIRl7WZoEZZfs4igMbKjiJtPypP+lBHr5m73469kRKhJhmPFH966FQMI1bD4CnxQZrt
         9zdgkN+fFqcVzSs3pAgN65GylCX9PEqejg6362PDeBnBkDGTjscrgybpg0cmR3U9yze/
         Lqovlu6L0hOfoYMZ0gl5tO2YBa8DM70Rtyk7810H1/jASWaPBqervGAdX99wJ6VdmLo+
         CHbAY3ab+Q0cXrmn9+L67s1QD4s43SxhFP1eW3VTSQWBmKCLa5gEbNYyhEwQamPphSWa
         xT2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=XjZxVnTvKHgAcOp0hpy7ikW8MjvNV39uxt972bUzcuw=;
        b=H35zZfb9JubR97ALAh+TzEFdRsop3pfJMp/Z0hvSfNJdr/JU791pDB/Kwn2/10+U00
         mUOx4N0sYT/qFdCmWhnEn2Nc8Xr9zPBoXmCuHqQuyB9H3yxD57NI1P9j0/OtvplnBsph
         Y9LcsgDVJ7jVRAgJ4ls4FdNnfbFJF76fZ44yE9XqHNNCjbpWPerezdz8jbuT73uyU3Am
         dng2q1s1Hnlx+VTdIDtxExumFzELaLlc3oOYsuGVVcKyxG1995KPrQXxrVR2uvIj/knd
         tj5vKyaU1X2d69zTiRerKujyUI1UHL5xeMu7bnNW1SNfCogpjTgY5ujBdyMQ8tTPFceG
         5H8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w20si2229414qtw.318.2019.04.25.12.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 12:35:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 86C4D2CE902;
	Thu, 25 Apr 2019 19:35:45 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0447A1001E94;
	Thu, 25 Apr 2019 19:35:40 +0000 (UTC)
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
Subject: [PATCH v4 1/2] iomap: Add a page_prepare callback
Date: Thu, 25 Apr 2019 21:35:37 +0200
Message-Id: <20190425193538.5416-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 25 Apr 2019 19:35:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move the page_done callback into a separate iomap_page_ops structure and
add a page_prepare calback to be called before a page is written to.  In
gfs2, we'll want to start a transaction in page_prepare and end it in
page_done, and other filesystems that implement data journaling will
require the same kind of mechanism.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/gfs2/bmap.c        | 22 +++++++++++++++++-----
 fs/iomap.c            | 22 ++++++++++++++++++----
 include/linux/iomap.h | 18 +++++++++++++-----
 3 files changed, 48 insertions(+), 14 deletions(-)

diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index 5da4ca9041c0..281d739da652 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -991,15 +991,27 @@ static void gfs2_write_unlock(struct inode *inode)
 	gfs2_glock_dq_uninit(&ip->i_gh);
 }
 
-static void gfs2_iomap_journaled_page_done(struct inode *inode, loff_t pos,
-				unsigned copied, struct page *page,
-				struct iomap *iomap)
+static int gfs2_iomap_page_prepare(struct inode *inode, loff_t pos,
+				   unsigned len, struct iomap *iomap)
+{
+	return 0;
+}
+
+static void gfs2_iomap_page_done(struct inode *inode, loff_t pos,
+				 unsigned copied, struct page *page,
+				 struct iomap *iomap)
 {
 	struct gfs2_inode *ip = GFS2_I(inode);
 
-	gfs2_page_add_databufs(ip, page, offset_in_page(pos), copied);
+	if (page)
+		gfs2_page_add_databufs(ip, page, offset_in_page(pos), copied);
 }
 
+const struct iomap_page_ops gfs2_iomap_page_ops = {
+	.page_prepare = gfs2_iomap_page_prepare,
+	.page_done = gfs2_iomap_page_done,
+};
+
 static int gfs2_iomap_begin_write(struct inode *inode, loff_t pos,
 				  loff_t length, unsigned flags,
 				  struct iomap *iomap,
@@ -1077,7 +1089,7 @@ static int gfs2_iomap_begin_write(struct inode *inode, loff_t pos,
 		}
 	}
 	if (!gfs2_is_stuffed(ip) && gfs2_is_jdata(ip))
-		iomap->page_done = gfs2_iomap_journaled_page_done;
+		iomap->page_ops = &gfs2_iomap_page_ops;
 	return 0;
 
 out_trans_end:
diff --git a/fs/iomap.c b/fs/iomap.c
index 97cb9d486a7d..667a822ecb7d 100644
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
@@ -674,9 +675,17 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
 	if (fatal_signal_pending(current))
 		return -EINTR;
 
+	if (page_ops) {
+		status = page_ops->page_prepare(inode, pos, len, iomap);
+		if (status)
+			return status;
+	}
+
 	page = grab_cache_page_write_begin(inode->i_mapping, index, flags);
-	if (!page)
-		return -ENOMEM;
+	if (!page) {
+		status = -ENOMEM;
+		goto no_page;
+	}
 
 	if (iomap->type == IOMAP_INLINE)
 		iomap_read_inline_data(inode, page, iomap);
@@ -684,12 +693,16 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
 		status = __block_write_begin_int(page, pos, len, NULL, iomap);
 	else
 		status = __iomap_write_begin(inode, pos, len, page, iomap);
+
 	if (unlikely(status)) {
 		unlock_page(page);
 		put_page(page);
 		page = NULL;
 
 		iomap_write_failed(inode, pos, len);
+no_page:
+		if (page_ops)
+			page_ops->page_done(inode, pos, 0, NULL, iomap);
 	}
 
 	*pagep = page;
@@ -769,6 +782,7 @@ static int
 iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 		unsigned copied, struct page *page, struct iomap *iomap)
 {
+	const struct iomap_page_ops *page_ops = iomap->page_ops;
 	int ret;
 
 	if (iomap->type == IOMAP_INLINE) {
@@ -780,8 +794,8 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
 	}
 
-	if (iomap->page_done)
-		iomap->page_done(inode, pos, copied, page, iomap);
+	if (page_ops)
+		page_ops->page_done(inode, pos, copied, page, iomap);
 
 	if (ret < len)
 		iomap_write_failed(inode, pos, len);
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 0fefb5455bda..fd65f27d300e 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -53,6 +53,8 @@ struct vm_fault;
  */
 #define IOMAP_NULL_ADDR -1ULL	/* addr is not valid */
 
+struct iomap_page_ops;
+
 struct iomap {
 	u64			addr; /* disk offset of mapping, bytes */
 	loff_t			offset;	/* file offset of mapping, bytes */
@@ -63,12 +65,18 @@ struct iomap {
 	struct dax_device	*dax_dev; /* dax_dev for dax operations */
 	void			*inline_data;
 	void			*private; /* filesystem private */
+	const struct iomap_page_ops *page_ops;
+};
 
-	/*
-	 * Called when finished processing a page in the mapping returned in
-	 * this iomap.  At least for now this is only supported in the buffered
-	 * write path.
-	 */
+/*
+ * Called before / after processing a page in the mapping returned in this
+ * iomap.  At least for now, this is only supported in the buffered write path.
+ * When page_prepare returns 0, page_done is called as well
+ * (possibly with page == NULL).
+ */
+struct iomap_page_ops {
+	int (*page_prepare)(struct inode *inode, loff_t pos, unsigned len,
+			struct iomap *iomap);
 	void (*page_done)(struct inode *inode, loff_t pos, unsigned copied,
 			struct page *page, struct iomap *iomap);
 };
-- 
2.20.1

