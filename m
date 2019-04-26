Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E031C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:11:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07E7D2084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:11:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07E7D2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99D7A6B0008; Fri, 26 Apr 2019 09:11:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94DB36B000A; Fri, 26 Apr 2019 09:11:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8162F6B000C; Fri, 26 Apr 2019 09:11:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 600866B0008
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:11:38 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e31so2858490qtb.0
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 06:11:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=QvO6jybBiPjVZFCJ1HxGTRMmE8YsY0C+1koHRB/O2AM=;
        b=n2caN63gVj5sUqoLSOCagucy3oflUaUJ/kA1E7x07W2kIkhE5LK97dyOb1HqHRgYU8
         YxxaV2V1cp5ou0R9DByfp30ohcjLKU3qqXKzIIz1tlOsikJcBZmAr0lqVQp8S1raIsxZ
         pbP9Br+y9eauH1eRKzfQ6T0mRlSbL67GXvHjspLVkolA+L+JVtDjzGdhQG7k15SVl4Qq
         opVL1xsE2GoHtA2vGDh+DZ1HU89skpD6d+T5BYz5iB2W4i2x3gBioJ664Df5QEgHvwCv
         G42bdw9fNZz6W0fhdbCwKIFXXUERhbIaLh7s42k/1f2eBRo8aGMJgd9Bo4TM7soZJgwz
         muZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXh65yaPmIpe7EC9VJvaZAarLJpiKlWaZjnF6qzge7bquGZev2p
	lxFG3DHb+G1oDcMGloS3L4mrpkRGQgpFh8GR/gR03YrTiclGB1HXnisi+tVxz4CingKDd8G6YuD
	1ncVffFNiv4rJ9YWy71qyzyH/jVYcKTODpLp3gQs4eFVW4STVsCbk1FGlxyFfF7Qrrw==
X-Received: by 2002:a0c:a286:: with SMTP id g6mr14641905qva.215.1556284298168;
        Fri, 26 Apr 2019 06:11:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1JQ2xU5O/DMOxBTkGcD+d5c5K/l3JzhwAzm6ZVBQm4tz0FA/6BQuc5JwOkML//67t7FDd
X-Received: by 2002:a0c:a286:: with SMTP id g6mr14641845qva.215.1556284297536;
        Fri, 26 Apr 2019 06:11:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556284297; cv=none;
        d=google.com; s=arc-20160816;
        b=sblY2jHOA8ZQ8zpqpW6ah0qkTK2THgVsEU5X7D7Rrqi/MT1KhHbokx9swyDX7MVs6U
         8Ca7flaAIg8WO68ZdnleZCGpqx7Yh61JZv/6LRdK1hpH7lewY8Rf80iJwx4H+IcEX6E4
         UJE4r3ohk1Y1wK68VfRq3FdBbNt6sdCQTeOEEQ4w7M7YBBv9N7x8QGb/zL6UP9pNfrwq
         tM7AAwhntyEjm8t8u0VgIaT9A8xobwyYWEjMYfBRMXlCvmaFotndHi7do0JtgbYqUEEF
         uuxBGLEgjRcy6ewOg9eC2KpvJW8YmPqlN/l1CcbvDcXakiZJZI/0XNZgNLub9ky2p9EU
         2vdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=QvO6jybBiPjVZFCJ1HxGTRMmE8YsY0C+1koHRB/O2AM=;
        b=tZrYKFR3+xZ4ohsgFrPHPjc4YsZ6JtMUHcaxeAdv68m989jh2POCTMgfXWFt6Ouzz7
         hBD56xoX3pBH5DBfvLMjYXUDhifAGOA6m92ug4aTU3XHwRkbTctAnhGZ24jqektpWMs7
         TAL8yb/IbN3qVlLSEYm11swpdHoCByPSllYNSY7vYFk0HJoKer45se5oXdOAR32i9pra
         u7Wvs3khse+4dtXxK+Sv8EWH1SY6Y74Oex7OH0GQvMtS1bOjr/B7J18rSO5f3Qz1YI0W
         C+R3hcoaIrpT3kqoDW+fqB4i5hPXuH74Tsiel2nRABDKn4gkoz24oKIbksaGv745pJZ3
         wUag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r12si4889914qvs.31.2019.04.26.06.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 06:11:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C42F4883B8;
	Fri, 26 Apr 2019 13:11:36 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E1ECE648D6;
	Fri, 26 Apr 2019 13:11:30 +0000 (UTC)
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
Subject: [PATCH v5 1/3] iomap: Fix use-after-free error in page_done callback
Date: Fri, 26 Apr 2019 15:11:25 +0200
Message-Id: <20190426131127.19164-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 26 Apr 2019 13:11:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In iomap_write_end, we are not holding a page reference anymore when
calling the page_done callback, but the callback needs that reference to
access the page.

To fix that, move the put_page call in __generic_write_end into the
callers of __generic_write_end.  Then, in iomap_write_end, put the page
after calling the page_done callback.

Reported-by: Jan Kara <jack@suse.cz>
Fixes: 63899c6f8851 ("iomap: add a page_done callback")
Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/buffer.c |  5 +++--
 fs/iomap.c  | 12 ++++++++++--
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index ce357602f471..6e2c95160ce3 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2104,7 +2104,6 @@ int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
 	}
 
 	unlock_page(page);
-	put_page(page);
 
 	if (old_size < pos)
 		pagecache_isize_extended(inode, old_size, pos);
@@ -2160,7 +2159,9 @@ int generic_write_end(struct file *file, struct address_space *mapping,
 			struct page *page, void *fsdata)
 {
 	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
-	return __generic_write_end(mapping->host, pos, copied, page);
+	copied = __generic_write_end(mapping->host, pos, copied, page);
+	put_page(page);
+	return copied;
 }
 EXPORT_SYMBOL(generic_write_end);
 
diff --git a/fs/iomap.c b/fs/iomap.c
index 97cb9d486a7d..3e4652dac9d9 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -765,6 +765,14 @@ iomap_write_end_inline(struct inode *inode, struct page *page,
 	return copied;
 }
 
+static int
+buffer_write_end(struct address_space *mapping, loff_t pos, loff_t len,
+		unsigned copied, struct page *page)
+{
+	copied = block_write_end(NULL, mapping, pos, len, copied, page, NULL);
+	return __generic_write_end(mapping->host, pos, copied, page);
+}
+
 static int
 iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 		unsigned copied, struct page *page, struct iomap *iomap)
@@ -774,14 +782,14 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 	if (iomap->type == IOMAP_INLINE) {
 		ret = iomap_write_end_inline(inode, page, iomap, pos, copied);
 	} else if (iomap->flags & IOMAP_F_BUFFER_HEAD) {
-		ret = generic_write_end(NULL, inode->i_mapping, pos, len,
-				copied, page, NULL);
+		ret = buffer_write_end(inode->i_mapping, pos, len, copied, page);
 	} else {
 		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
 	}
 
 	if (iomap->page_done)
 		iomap->page_done(inode, pos, copied, page, iomap);
+	put_page(page);
 
 	if (ret < len)
 		iomap_write_failed(inode, pos, len);
-- 
2.20.1

