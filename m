Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C695AC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 16:09:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09D9F20651
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 16:09:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09D9F20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F5DE6B0003; Thu, 25 Apr 2019 12:09:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07F9A6B0005; Thu, 25 Apr 2019 12:09:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E89696B0006; Thu, 25 Apr 2019 12:09:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF49F6B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:09:25 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id t18so204464qtr.8
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 09:09:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=kOxnVwUn3IXOr62LcEwoXG3HKdaAVpYT02c8a6b1mRY=;
        b=oWB8AkKjfg9+iqosJyC7xx/ZVZ3DbI9LmafFer1Od31PkU+/lqb+NbJ6eF8DTM5vwj
         Q/7/LFsRT+98ewdLqU4trASgSB39384GIFdLkFMJneZPZ0O5zSxLzwX7fh9ZTqBBtTLW
         fHjqoADxO7pyBu3kSJADjHL0I/VQyxO0H/VID1DYk7oSopQdHSeM2lwrJZYzn47iNGHL
         vCnwWKMF3XYj1NfJm1UUWM5oGHlbal1Ll/DzHlJ6aTKlyDg3Kc6xIgvn788j8dKeL9Xl
         afnFh9CPOBDarFpiNP/Aqj+lkH6yaj9POevjU9IdnQ5LqCb5Jp1nC4xAuBnQU+hH8WF8
         FIWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWpB1U1Vr/DSmL6/s0HpImIuJkcR5pxteK3N0V3QpQK7p/7NE8F
	rvxibNKVKHliag4ba6Lt++Xm29AXJR6dVDe9KqLDOC23HPypYcRR4eLQpjvdbWFCdGgLI2qCbkA
	ijy6YczTJp60V1CD2CzD4ACi1vfga72/vX8/m2bEuq7SvI6H3hRhFbEBUJ2XpMe7pfw==
X-Received: by 2002:ae9:ee0c:: with SMTP id i12mr15894878qkg.46.1556208565389;
        Thu, 25 Apr 2019 09:09:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDAoWchgoWOEpf8Brrcx7ojdgv1+YKIogZUsgGVtRalvx154jwm4jeA6grF26/+3KY5AES
X-Received: by 2002:ae9:ee0c:: with SMTP id i12mr15894788qkg.46.1556208564371;
        Thu, 25 Apr 2019 09:09:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556208564; cv=none;
        d=google.com; s=arc-20160816;
        b=lO5cT9pfobexHWRJRO7Zw8J8wyIyH/QHzesHlsZDjpc237D/t9t3Z1cxkwU6jtrEBV
         ZspcFHZ/PqT2miYGtjXZpT0osm72Xlna1bI+tFIFB54eX+bE/eupJOFJvF4cJQOkB78/
         a8T8zqf2R6V8M5VA7aOezp74h+YQe5HsjqGOhAQKFgqrKXU8O2VI+5USLpqWLkx0zyHV
         yvu6C/5rXU0899Cz8iAnJzkK3v3hZaHTOfSu3eWCYirhdQSONvkSmJ+0L2jBacXLck6M
         8o0UeerIDnkXfKy9kRPfqlqL+DH2a2HcRC7hMHp7wJ5U4RXUwPyu7rcnjFRECH5tFMuY
         Eaig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=kOxnVwUn3IXOr62LcEwoXG3HKdaAVpYT02c8a6b1mRY=;
        b=ArbvJ+IMJzf86XeQpIoLsVPUx0cEQj8Fj2TmmgY6ijPai6OtkkB5bEeViTHo7JHPBO
         Um2uB+vlux5EshCxxh2prE9h1Wz4evJNliojarWLMSNHDRXIBpNBbQU8cFsDbxgKGJyO
         RExMi3JpbACA1m275a9ke5VAuqfQCculuzeqZQAI8sqnLeuzHEalLBeVqONnU1NxizH3
         gBAoDe6NeDx06ZuMpLqYG6FHSCOkb7nfkPiXW5rY/H9bgyug07acV5l2xUx6OEovqGvM
         8/AqAPbEnSSetkYUZ0PZzIBC+labsgjRmOjLg3ItlLyTgUcCXEhLHunVrqRBWYzzx/3w
         cQfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i8si15270234qkg.40.2019.04.25.09.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 09:09:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7C53A285B1;
	Thu, 25 Apr 2019 16:09:23 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5FAD5600C7;
	Thu, 25 Apr 2019 16:09:15 +0000 (UTC)
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
Subject: [PATCH v3 1/2] iomap: Add a page_prepare callback
Date: Thu, 25 Apr 2019 18:09:12 +0200
Message-Id: <20190425160913.1878-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 25 Apr 2019 16:09:23 +0000 (UTC)
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
 fs/iomap.c            | 22 ++++++++++++++++++----
 include/linux/iomap.h | 18 +++++++++++++-----
 2 files changed, 31 insertions(+), 9 deletions(-)

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

