Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29F36C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 16:32:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4BEF20675
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 16:32:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4BEF20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CE3F6B0003; Mon, 29 Apr 2019 12:32:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0800A6B0005; Mon, 29 Apr 2019 12:32:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAFB16B0007; Mon, 29 Apr 2019 12:32:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBE206B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:32:48 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u65so9387524qkd.17
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 09:32:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=MB8wp8of2OYZa15Lmvh7DUDyr38wa320YQjPc02TbLM=;
        b=OFFeO2KVgymKkLNTWvq9+X/hZyvwGLXzM2Pha7TESTQ2+s9NTgy7/k6mNbTMhsQ87c
         dU3Llf6o2JXZCbXeMePDK+A/yn0wHOT8RtBRjKxSauv/itswjbgdBaWbzAm7BrifCsJc
         O36pxV7wAdQIdTxAzCeEAOWt2EYKgEirGNpnY1vUuyM9qg9ehUpro3HuExFH/5YxL12M
         udYwQIL4//ZpeNLxPAYviHTUIPEXXEeZPnU3WWr8Fvl5ELMq0WdjC2kjWwQ1mMF+oQyp
         bJnfpBBY5+QvL48MeB7aG8JCQd06Wysd5aU0hqilAlPEwWJNxAzAn7N6S2K9oHRBtkgo
         uBoQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV15cAkePXBoEwwt3/oEBn3wxWIBWP8saCSFcgUcUUSST1K71aH
	yOua57urkI99bBh6aSK4UBWY+SUbEMrL3V+eUfxZBGlXXGsAOJR8HDT7hMAKl6A95jEh7f1/hTu
	CsJ08goE3d8DU8MwoH7PoBBuOrtjP0M7xPz5GnbSzZxsJepteAsRJHUJt/duR+84DXg==
X-Received: by 2002:ac8:1673:: with SMTP id x48mr9002670qtk.353.1556555568567;
        Mon, 29 Apr 2019 09:32:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAl4kPmfxJIDn1Jl17HVmPzagu37tsLNcSTMwXry7zIEVhtqM5VO6SoHRLw649Ju4AZRfm
X-Received: by 2002:ac8:1673:: with SMTP id x48mr9002613qtk.353.1556555567699;
        Mon, 29 Apr 2019 09:32:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556555567; cv=none;
        d=google.com; s=arc-20160816;
        b=ge9jZO+SybfB3NiN8uFvD7iyi9NSbh9/USPRgbAGQzkDd/bd84cBfyWkPl0DLaIgXs
         7nLnltRzDDoUppJ+zklLAHi1EqpuCb00FDaMrii8fKt1q7d7RYuzZlNEtHQaZs9clD6/
         kerQTzLCxjI5heHxVFcniq0JenKH+0802pwTRlr0Kmj2XrphQTv0xPiba0BeeRa2IiUl
         X1ONbbaEe/7xgMQHqj1YSXmA3qAxsdWMew/9pfqvpfk3iakFvQDboNSbjVu5UsxwiRRo
         Tkxrh85P7EMf3l5Mb617CqPsL0pSG42J24KFhbQ9TJclVBQiskM3hdYyfsLnYAcBbAOS
         N3QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=MB8wp8of2OYZa15Lmvh7DUDyr38wa320YQjPc02TbLM=;
        b=Cb9CHcVJsefYEaAl3rlGKy8kwS/SIttPP0C9Zq+s4mGH9+PywZlXNYA6JhUpTwoyHv
         GHY4K/AZhuQbpR0mTfyua1tOvvvYmGzA2RvnShtGmZdtRmS0NslYs0iWJ0bqqUQ9JGbF
         k1irb9b9WioNTtrtnO+N2wDoUc0eFlqYmU8+2RLvc0Hyemmg6p5d1fT2jFvAhEw9BOQ0
         ZoCMW82GR8OxpmVwr2DSyOCtNIS1JnJnIfco57hv9moUi8Y92SzhlVNVZBO6Tg+LNTWl
         PZy/KtLIu4H2auCekldEd2JoM85hf5sv8NO6WG2src4JLVoxmZqVE6ObmlJZDP0qvW0O
         ohcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s187si767293qkh.257.2019.04.29.09.32.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 09:32:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B32A5308FB9D;
	Mon, 29 Apr 2019 16:32:46 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DFEC0190D7;
	Mon, 29 Apr 2019 16:32:41 +0000 (UTC)
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
Subject: [PATCH v6 1/4] iomap: Clean up __generic_write_end calling
Date: Mon, 29 Apr 2019 18:32:36 +0200
Message-Id: <20190429163239.4874-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 29 Apr 2019 16:32:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Christoph Hellwig <hch@lst.de>

Move the call to __generic_write_end into iomap_write_end instead of
duplicating it in each of the three branches.  This requires open coding
the generic_write_end for the buffer_head case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/iomap.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index 97cb9d486a7d..2344c662e6fc 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -738,13 +738,11 @@ __iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 	 * uptodate page as a zero-length write, and force the caller to redo
 	 * the whole thing.
 	 */
-	if (unlikely(copied < len && !PageUptodate(page))) {
-		copied = 0;
-	} else {
-		iomap_set_range_uptodate(page, offset_in_page(pos), len);
-		iomap_set_page_dirty(page);
-	}
-	return __generic_write_end(inode, pos, copied, page);
+	if (unlikely(copied < len && !PageUptodate(page)))
+		return 0;
+	iomap_set_range_uptodate(page, offset_in_page(pos), len);
+	iomap_set_page_dirty(page);
+	return copied;
 }
 
 static int
@@ -761,7 +759,6 @@ iomap_write_end_inline(struct inode *inode, struct page *page,
 	kunmap_atomic(addr);
 
 	mark_inode_dirty(inode);
-	__generic_write_end(inode, pos, copied, page);
 	return copied;
 }
 
@@ -774,12 +771,13 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 	if (iomap->type == IOMAP_INLINE) {
 		ret = iomap_write_end_inline(inode, page, iomap, pos, copied);
 	} else if (iomap->flags & IOMAP_F_BUFFER_HEAD) {
-		ret = generic_write_end(NULL, inode->i_mapping, pos, len,
-				copied, page, NULL);
+		ret = block_write_end(NULL, inode->i_mapping, pos, len, copied,
+				page, NULL);
 	} else {
 		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
 	}
 
+	ret = __generic_write_end(inode, pos, ret, page);
 	if (iomap->page_done)
 		iomap->page_done(inode, pos, copied, page, iomap);
 
-- 
2.20.1

