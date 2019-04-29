Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDAE2C04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 16:32:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D1A120675
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 16:32:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D1A120675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 192016B000A; Mon, 29 Apr 2019 12:32:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 145566B000C; Mon, 29 Apr 2019 12:32:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00A196B000D; Mon, 29 Apr 2019 12:32:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2EE36B000A
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:32:55 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t63so9463855qkh.0
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 09:32:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VMreTKTST33hsgVkWvM5nBdkRLJ3YgBtCHnvJjhLtlA=;
        b=C+TJkCYP1qnh34lHd3McmprNp16qOw4nDlC85dq3drEPkmMcupeCP/5dTf2NgIg+xS
         taiyqtiUaPU6SgUS/KX5o1DB/G9nPRq/KQel+IXzr6n6WRBCp4+8j6HcMDIYDcCj0S3k
         DSsKAh+GOP1vNjScMm7pI7xT6UXEpqT7xQt/BOJdH6lZbFOhA4UhHTVyJvSR0zyg47iW
         tQvNSD9A1qZ8Eb5aGmGNBvWx9/TpBm0ahPs2+Wy/SRgSqbkfzWT9lfF/M4+nnJTj+oF8
         5Dn/sG/xBv7TFjsaNL3KbVI40e+kawAq+wh1ukdVxeRCHToKVJvzee2kf11gHKp5wPXG
         Olkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUGIlTzOP7tUM3D/46zbJl5DyXRTvCNcM43pzTEQxzRcKZp+hgT
	jurcD2xVMGKWYyL4xHJYI0lRY8BQnfdnPPnANIkwYLSY9GRzPIy5Brp2e3keRm/hYPXhIsma9Y7
	16LRKtqXmDhYJvGuAlMY/1rVkpeNpV+Gcby/MIhWXFezlZs11NAcjLB8+X6QABvsraQ==
X-Received: by 2002:ae9:ee1a:: with SMTP id i26mr6634831qkg.13.1556555575576;
        Mon, 29 Apr 2019 09:32:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxidAsCKO8FhRepSR0g9bcoinXgx0K8lNV7xb/PKSxz9l1P7vTWGgz18Xg3uXl62pSnCy/T
X-Received: by 2002:ae9:ee1a:: with SMTP id i26mr6634780qkg.13.1556555574724;
        Mon, 29 Apr 2019 09:32:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556555574; cv=none;
        d=google.com; s=arc-20160816;
        b=AKFk6YVhrcS56iBT3KN/wY/gL1yX6UtWTbwt9z66+HUYeTGRqQiptBfxPacvVqNEDt
         jbeckTzMlMqnQt4H10v9tACdwXKHdaqQs5yZ7wo3AGQWzLoCf+Yleg6nTgOmNw0IM9VI
         3T8ggjkcgzHqRToKUTyoLYVCRjEFxSs7sikB3qe/+I0Et4a7NIxHkPF3xOW80IfpB3WM
         twX/IaA1psvqgw/fsfKGpaFs89Z30IABFqOqMMtfunrIxO0g1Xwjay06yz7fyXeAS8Ui
         F6qOvgfN4F7DaIKNtlG1e9XF1efqSlCy5Af7oTZGCyZWhXaegYX7+iPtJZmx+pyzO7Lk
         9khg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VMreTKTST33hsgVkWvM5nBdkRLJ3YgBtCHnvJjhLtlA=;
        b=D8yyNqRwAWhkXg8dN4v8nJdrkxli6IdEVbQST358752Ttd3hC9S4czCUec0epWkS3e
         awHUnnizjO0S9CtE/nIEVZ9hIANrWT9UfRWvxYb1+2V/vxDOBkOdLpJuzrqoTZORLVPk
         jkLIMJvADueZad0B0AMGK8dOuWOFLGqgQSJtFHDVoPbkHwuzGTbGJ4gev2yg4I+kx/vM
         o4YreXA0iglQS9xeF8GitxZ3B+A+lQBKdwmcOoG8iOxn3EcPput6d8m+I8TPhDSkbP03
         ZICbRot4hj0P8Js3vmVyDAG1lHBY1FSeYzn0dUURhzqTl/UA9oGgedpPl9sBPE5PPfXp
         JxPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h50si3650160qvd.87.2019.04.29.09.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 09:32:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D55B459454;
	Mon, 29 Apr 2019 16:32:53 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4F8DA17A64;
	Mon, 29 Apr 2019 16:32:51 +0000 (UTC)
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
Subject: [PATCH v6 3/4] iomap: Add a page_prepare callback
Date: Mon, 29 Apr 2019 18:32:38 +0200
Message-Id: <20190429163239.4874-3-agruenba@redhat.com>
In-Reply-To: <20190429163239.4874-1-agruenba@redhat.com>
References: <20190429163239.4874-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 29 Apr 2019 16:32:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move the page_done callback into a separate iomap_page_ops structure and
add a page_prepare calback to be called before the next page is written
to.  In gfs2, we'll want to start a transaction in page_prepare and end
it in page_done.  Other filesystems that implement data journaling will
require the same kind of mechanism.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/gfs2/bmap.c        | 22 +++++++++++++++++-----
 fs/iomap.c            | 36 ++++++++++++++++++++++++++----------
 include/linux/iomap.h | 22 +++++++++++++++++-----
 3 files changed, 60 insertions(+), 20 deletions(-)

diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index 5da4ca9041c0..6b980703bae7 100644
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
 
+static const struct iomap_page_ops gfs2_iomap_page_ops = {
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
index b01ed5a28d2c..ee9ce7a06244 100644
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
 
+	if (page_ops && page_ops->page_prepare) {
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
+		goto out_no_page;
+	}
 
 	if (iomap->type == IOMAP_INLINE)
 		iomap_read_inline_data(inode, page, iomap);
@@ -684,15 +693,21 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
 		status = __block_write_begin_int(page, pos, len, NULL, iomap);
 	else
 		status = __iomap_write_begin(inode, pos, len, page, iomap);
-	if (unlikely(status)) {
-		unlock_page(page);
-		put_page(page);
-		page = NULL;
 
-		iomap_write_failed(inode, pos, len);
-	}
+	if (unlikely(status))
+		goto out_unlock;
 
 	*pagep = page;
+	return 0;
+
+out_unlock:
+	unlock_page(page);
+	put_page(page);
+	iomap_write_failed(inode, pos, len);
+
+out_no_page:
+	if (page_ops && page_ops->page_done)
+		page_ops->page_done(inode, pos, 0, NULL, iomap);
 	return status;
 }
 
@@ -766,6 +781,7 @@ static int
 iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 		unsigned copied, struct page *page, struct iomap *iomap)
 {
+	const struct iomap_page_ops *page_ops = iomap->page_ops;
 	int ret;
 
 	if (iomap->type == IOMAP_INLINE) {
@@ -778,8 +794,8 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 	}
 
 	ret = __generic_write_end(inode, pos, ret, page);
-	if (iomap->page_done)
-		iomap->page_done(inode, pos, copied, page, iomap);
+	if (page_ops)
+		page_ops->page_done(inode, pos, copied, page, iomap);
 	put_page(page);
 
 	if (ret < len)
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 0fefb5455bda..2103b94cb1bf 100644
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
@@ -63,12 +65,22 @@ struct iomap {
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
+ * When a filesystem sets page_ops in an iomap mapping it returns, page_prepare
+ * and page_done will be called for each page written to.  This only applies to
+ * buffered writes as unbuffered writes will not typically have pages
+ * associated with them.
+ *
+ * When page_prepare succeeds, page_done will always be called to do any
+ * cleanup work necessary.  In that page_done call, @page will be NULL if the
+ * associated page could not be obtained.
+ */
+struct iomap_page_ops {
+	int (*page_prepare)(struct inode *inode, loff_t pos, unsigned len,
+			struct iomap *iomap);
 	void (*page_done)(struct inode *inode, loff_t pos, unsigned copied,
 			struct page *page, struct iomap *iomap);
 };
-- 
2.20.1

