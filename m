Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CEE1C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:26:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78E6520644
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:26:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78E6520644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C60306B000D; Thu, 25 Apr 2019 11:26:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEAAB6B000E; Thu, 25 Apr 2019 11:26:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB1386B0010; Thu, 25 Apr 2019 11:26:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 855CC6B000D
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:26:40 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t67so182578qkd.15
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:26:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=V8NpsDeHPvVHBQaWoJj6jW9z8yujAEEJRGB7vPrtR4c=;
        b=GisyLseELbBqCvRHrh213zX0yvbRIh1Gyn5+TSiPQ6rMtigeCRK4ZedT0uUoO8oqf4
         94RHfdg+rYwF1B7PBOhS7fdifW2IZUSlzOAcpUzHg/liza8gMyW4m0u5djp5inah1H2s
         p2GxHvaiWWOSoMU1PGqsbb0xYYHV1mhY1g87V/9by8MJwPw4d5hMIzFZ+kTf4DGFu9zY
         ahw3tOaVZiB62jvkMOUbcu2le8ccL5y1k/JAP5FC5oEPyxKXxzfWjSL6cwYU2wkfC/7c
         K/AelE/PyaNPbh9G7CxcElh1CJgDMMi3gZUzJMDq0kK9zjZVswzDNnvH+Xrukm7Bk3xV
         ZbGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXTxykoNP3Mc6EiuMcOstU8ST7tAEG1qzErwJgwuo9JAaVCQRK+
	4jueUFi3ZB4KmSac/9wLxRLxiSrdp65gJhijN9MBkL+SCqt+yGSBqlEwNVfzStdFLEaMjRcTAfA
	WLhfaApNy4HI+3dGJQgQjtauB9PyVERValc0gR1GqqUc98bWznruSqor/t5KszkhBKg==
X-Received: by 2002:a0c:e5d0:: with SMTP id u16mr3243761qvm.48.1556206000268;
        Thu, 25 Apr 2019 08:26:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNj1MMP1PlZFWALYlSCWEKvPSCUWT8X9qS+i3l2tVpXRc/1KxDEOED5zcRUqK2/9jKpG+X
X-Received: by 2002:a0c:e5d0:: with SMTP id u16mr3243713qvm.48.1556205999642;
        Thu, 25 Apr 2019 08:26:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556205999; cv=none;
        d=google.com; s=arc-20160816;
        b=u0zl2lsGFkFQwYIuxGIvy6896PSwWfu3o6xYZFrg4AMRQMa3kDImXxpJmDMSpQOsZu
         Ao+c2I4mYWp7y0AEn+MzbJbj0OPp06dSew6Ov/qd8W75o3TrsClsxtoMOEnLMzYyouXy
         OrF/mItby0qEn43s3f2h2CTu3pKDvg14qsBarpOnXtJcu1C4fmzv1vrbBmVU5l3jFyYQ
         lysqbC+uXI9RQLB9CKYhE/ttd57P4o4tS+eALLqfoht3p075wdqpSqxpnXiWsqq4Ym0g
         VXUR1jpeRfX1vVTorMsHWDDQruz2rfBrzZRwwmHr8YZ/36esigCHHjlYBv++VLfiSVGT
         c3Uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=V8NpsDeHPvVHBQaWoJj6jW9z8yujAEEJRGB7vPrtR4c=;
        b=BoPetP6nT0JtZNBza9eK1Icb6acbGiVEabrPw8+BZwehjqXMrtnpufLEcH0L6OTrjo
         24taqxJ9FofAa7Ye+yZ3Vt0HEs6sI5n2IYckIP3r7d6BS46ZDjYqfk6q7QGyKskfKoFZ
         8yoYBDwfKivYqmFl6+mHhudJ0BR636JvoG7/r66wdpNV38FCKZZJiQFbIdikK+LzhSmA
         0IkoB9x93sTsK9S5UAF6wubTzIB7DMH3dJHg6GAC8uTuahI6q+9U/dGETE1K4cv1M6vD
         JwiHgNEuhq4o9klGjL2xSSWa6+CED4sNomF8BOCoTs92VVWnKUWDXCoFASQnEiO5nCQX
         XZrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n4si653195qkg.43.2019.04.25.08.26.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 08:26:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C371FC04BE09;
	Thu, 25 Apr 2019 15:26:38 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 428E261B9B;
	Thu, 25 Apr 2019 15:26:33 +0000 (UTC)
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
Subject: [PATCH v2 1/2] iomap: Add a page_prepare callback
Date: Thu, 25 Apr 2019 17:26:30 +0200
Message-Id: <20190425152631.633-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 25 Apr 2019 15:26:38 +0000 (UTC)
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
 fs/iomap.c            | 21 +++++++++++++++++----
 include/linux/iomap.h | 18 +++++++++++++-----
 2 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index 97cb9d486a7d..967c985c5310 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -674,9 +674,17 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
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
@@ -684,12 +692,16 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
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
@@ -769,6 +781,7 @@ static int
 iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 		unsigned copied, struct page *page, struct iomap *iomap)
 {
+	const struct iomap_page_ops *page_ops = iomap->page_ops;
 	int ret;
 
 	if (iomap->type == IOMAP_INLINE) {
@@ -780,8 +793,8 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
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

