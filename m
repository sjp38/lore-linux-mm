Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E382C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 22:09:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 486262075E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 22:09:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 486262075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3CBF6B0005; Mon, 29 Apr 2019 18:09:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC4106B0007; Mon, 29 Apr 2019 18:09:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB2746B0008; Mon, 29 Apr 2019 18:09:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id BDD8C6B0005
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 18:09:47 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o34so11657569qte.5
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:09:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+NMe/1QosNo0ZlIV/VjhqfQJiDc8qYgxFPf9mMzErkU=;
        b=bkfIlI7JT0PJjNP2tUedxml/5sZ211+fAKBXvMhGr0UhAt91adkjkZvIQBk3pVuHwh
         Lf+oNLXyhGEcD5BXuZfHISEBDe+3Xj3sANfw+MoUPzGNMDOF4MH9NAB8NLUfugXohkta
         yGksTXTLW8BwrQvIAIIUbm/0ctwIqI+X3t3gxPB8o5/zSpbxsHoWF4SrRLGKfQjrg2zw
         nfc4iySotA3AyHjMnqaYzY1BF5b2EyPdRh+MI8jfwRMqr+eWB4ol8cCQ+doIn/x4aFEw
         xU6xNQ+B4TUd76a41uIFLgOAgONFlKG587fI5fLA54g38ThPZvD9LZ2XWWLaMlQ0xBZt
         cWuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXyKZigXN8IUVwB8Kzj13UBOUs41ox3FPj03VGLVUGZb4FhLg6F
	kTChD18kEIFZWyWFeV3aDMcP4S52KytvjospGIbiIttAMMc+qmRSa0QXC1u0T4eDikxwQ/8GBFG
	R2pmdzmiHVdrAYYtdfKu1M5CLbZi5FyvP6LODKBHT8rcWhxFQdMvY+ch/wJNlnFD3uw==
X-Received: by 2002:a37:78f:: with SMTP id 137mr10439163qkh.66.1556575787529;
        Mon, 29 Apr 2019 15:09:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyypN6QC67w/WMZrLajSCmpvz6Xy0WINqoTb3KdsRwnB7tFbKod/Vo18OjDY/gsZeKyB9+M
X-Received: by 2002:a37:78f:: with SMTP id 137mr10439120qkh.66.1556575786873;
        Mon, 29 Apr 2019 15:09:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556575786; cv=none;
        d=google.com; s=arc-20160816;
        b=tlcxoYx0cwMvgv/s/kg90X+Jy+i+4fDyHIA1krME8S6rxKVdgQJQG1tQZjjtjZuE1B
         lDGCjiZW/2EabGWaB4/MdngQl9WX97tue1u5lntOoacAaj4URpdVhFE92dzSoT9DNwAq
         b8vsCcDaXmUQo20cwnsHYdKBLCee4qamiOYufOYyz6PPQV8Y6pwOJ+1aUQiBkf3fs41g
         99cPRenDd49srpKgg0hwoRkS6G+zR9d9PVqiRaELgX6XLZfZyzDJDHSY0Rbyw/VR1Ntd
         zGuYFkjkodbhai82QG5rfE3Bdm3h6Y0RtDRGjszrPDxC5j06DbmR374dmGK0cHMOtgp/
         knLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+NMe/1QosNo0ZlIV/VjhqfQJiDc8qYgxFPf9mMzErkU=;
        b=axQg4oaleyMKQvM2XPkFGVYlh3HPCqRgh+7rHqOQdytRXaeF131+4jXOsbS9zy/iO+
         VFHK8shPX6MQL31iTsMYK6VbypVaycIa/XUf1lnpFz8ZKu4ypCRtZDYkQHs0YmX5eOKo
         LNiZXAOc5Zqt5yvcBiddbHEyTLuAepKrnaprCrsoKcP1/gF+zykFSNFFPI0AQqxt+nG4
         kLoKQrjzHmf6D7LZdDJkFNssGyaQIw6rdO2hNrG1UboZVQt9MknXBugCGoBG5n6dU2qu
         Hno2kJgauP8Ps2cmKcipOp6XLjrmVVmCzrELIujNlxDUPOd1P00w4KU30AVbdvwyT1Lx
         nl/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y4si2641966qve.195.2019.04.29.15.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 15:09:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 00F4E307EA82;
	Mon, 29 Apr 2019 22:09:46 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3E9BC57AA;
	Mon, 29 Apr 2019 22:09:43 +0000 (UTC)
From: Andreas Gruenbacher <agruenba@redhat.com>
To: cluster-devel@redhat.com,
	"Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	=?UTF-8?q?Edwin=20T=C3=B6r=C3=B6k?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v7 1/5] iomap: Clean up __generic_write_end calling
Date: Tue, 30 Apr 2019 00:09:30 +0200
Message-Id: <20190429220934.10415-2-agruenba@redhat.com>
In-Reply-To: <20190429220934.10415-1-agruenba@redhat.com>
References: <20190429220934.10415-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 29 Apr 2019 22:09:46 +0000 (UTC)
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
Reviewed-by: Jan Kara <jack@suse.cz>
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

