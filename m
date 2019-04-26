Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF0BEC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:11:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 697C92077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:11:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 697C92077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B0666B000A; Fri, 26 Apr 2019 09:11:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15DF56B000C; Fri, 26 Apr 2019 09:11:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 025FE6B000D; Fri, 26 Apr 2019 09:11:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D99846B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:11:41 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k68so2655931qkd.21
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 06:11:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZBsc3JvTFM/Wu94X9TXfrbjvcLLo3kHBRtLId2sjpu8=;
        b=FZOAlUG3RhnCjkTmKQ6x1cVEY5ECILHrFa7uWqji+jH4oYVSQYMjtsQ8QsdH+kcErv
         0ywIf65DykXIZdmCWW17Mrwd40HqxKNwPgu2EqT0Wgflpl9e5phIDnWB/aKZwoFiNv9v
         /5F35wOr9i9EeombTFdbOlM2G/kV36u35vhuZS/IX6Y8j3c92OwDOwXcor9z92G/SiYL
         aMm/o1UoD/4Aim4uDEtS2mTgzsolZ4zWMJ6oCqu2u73/YvTIl1fhJ8NOZooisyipwKbm
         ROxtCJMVtRgi3u6vGyQ3czBTRl4fqDBTaVkiEIjrb8TJUjRuJwR6LYBrRdIRVZxe5v4O
         cFRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVRikHzE5/hQgQMGqIJ+zmtfl+/Gu9vt08qn5TNltKO9bAiIvkM
	M8xbOKvJDYUJ+12mcGVmfmMn1UOKImEowgabirTFDx+vy1MxdRmt65AxIVkyALal+Rln9L6SSdN
	yU/oNDzKrGXQ5VzCCDe4qnlXkXXFrYcRopm0rmk3v8KDOQ8f9IohvcgATp/1otO+fzA==
X-Received: by 2002:a0c:9568:: with SMTP id m37mr5326295qvm.154.1556284301610;
        Fri, 26 Apr 2019 06:11:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoGBn0fzmgk+VsZ7oW0rw8mmDBqevtrUEl77MaJMUPa67eeLvTKbBSbsJh3y6VkbeyRZNp
X-Received: by 2002:a0c:9568:: with SMTP id m37mr5326216qvm.154.1556284300726;
        Fri, 26 Apr 2019 06:11:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556284300; cv=none;
        d=google.com; s=arc-20160816;
        b=L8gcWkFmwSU6hlnLiNYzHkWigarSjczDg21iUpAN1se4jwQXQZJy4kKwvWI4hECkOM
         LSDgoPpxkolF5Xjp3dmpvcVXcmfoCZdhEtv9yPPfZuwjnlEvKSRPlPiF5ZWJyS7U61de
         FF1SsDPIOjpzGTgiUhXfCeolkMkY5nf9kUOLa1V1gU44X4ex00rPIHHgEtjeT2yZcrWk
         HmisPi7ZO2rjy8s9a3um/7baqMjhB4f4ZxiyLaj0n/RF/Jawf53lLco1vd6vfJmXOjyw
         0LrEINsmor6flOJE10cL+WZE6/zOaxCf9zeKiKO0xCkDFbwLzOmIMf3ilp2aJ1q+QyG+
         dCaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZBsc3JvTFM/Wu94X9TXfrbjvcLLo3kHBRtLId2sjpu8=;
        b=hCU7lEL0Vr4+cQigc3eyjD4CknEwIlF969keki6Y5Y9E2taR2l0KFxEDeQBO0IUc0L
         E7nIqh/8iF3jdMQeez50bf1YyCQgHdAFFDYhqrNBDCAwV0/E7BkLCWMGqGTwKdlH8xF1
         pQ0wjSsAbUSRCn8iSEcccQcOt/5uaxTUobwFdv5CtjxuXDIxKYwEgGqFiNEq8SPsOU0Q
         tCXPvF+EMZs9mt5Ru41kvzuG3QQVK/DFVfxoqgmFib1pO1kTAFHMIStowHdWzpcScuZo
         c3evFLb2D7cd18m62K8KIVFLI7jh4u1JovcVDwLf8QQSRG20Bs9NN2HxBQqPK9eXCn3i
         p2Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 34si955037qtv.59.2019.04.26.06.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 06:11:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B75FA30ADBDF;
	Fri, 26 Apr 2019 13:11:39 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 28D3A66066;
	Fri, 26 Apr 2019 13:11:36 +0000 (UTC)
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
Subject: [PATCH v5 2/3] iomap: Add a page_prepare callback
Date: Fri, 26 Apr 2019 15:11:26 +0200
Message-Id: <20190426131127.19164-2-agruenba@redhat.com>
In-Reply-To: <20190426131127.19164-1-agruenba@redhat.com>
References: <20190426131127.19164-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Fri, 26 Apr 2019 13:11:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move the page_done callback into a separate iomap_page_ops structure and
add a page_prepare calback to be called before the next page is written
to.  In gfs2, we'll want to start a transaction in page_prepare and end
it in page_done; other filesystems that implement data journaling will
require the same kind of mechanism.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/gfs2/bmap.c        | 22 +++++++++++++++++-----
 fs/iomap.c            | 22 ++++++++++++++++++----
 include/linux/iomap.h | 18 +++++++++++++-----
 3 files changed, 48 insertions(+), 14 deletions(-)

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
index 3e4652dac9d9..ba2d44b33ed1 100644
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
@@ -777,6 +790,7 @@ static int
 iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 		unsigned copied, struct page *page, struct iomap *iomap)
 {
+	const struct iomap_page_ops *page_ops = iomap->page_ops;
 	int ret;
 
 	if (iomap->type == IOMAP_INLINE) {
@@ -787,8 +801,8 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
 	}
 
-	if (iomap->page_done)
-		iomap->page_done(inode, pos, copied, page, iomap);
+	if (page_ops)
+		page_ops->page_done(inode, pos, copied, page, iomap);
 	put_page(page);
 
 	if (ret < len)
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

