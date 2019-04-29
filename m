Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8DA8C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 16:32:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B374820675
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 16:32:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B374820675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FF1F6B0007; Mon, 29 Apr 2019 12:32:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AE6C6B0008; Mon, 29 Apr 2019 12:32:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4774E6B000A; Mon, 29 Apr 2019 12:32:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 213956B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:32:53 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id r13so9365931qke.22
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 09:32:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=P96q6ty/O2QML/E66Bqt9ZOvxzjhotk8fjwe1hzcff0=;
        b=dorjYZi89QcbldEpojL3clzxYr7tQv+IELbUbih3sXpCb/1T9T2JBQXe4cjPe0QR5Q
         OEc9pIzJcq5P2/akPJsPXih6KhnH+GykmkM3jeZNUq9gJHuQ3wQOd89dbIgzAx4XkgzM
         m3XgBDZP3V2Kxyor6NJs/kEKRasIG+0PDjjpCG379RmTtgJsNoUtOxijwQsIkiZWesxc
         6cRHdyfnNz/Hlc7css0UIGJUDZWgghm/eshIGkdUfdCnHiu0YTFvuGJnXsxBSDASR8mF
         JBBkl5akq2EleN+QR/xdHumDrR1mPu/zczv1qX1+2EKb566hka5FaDCWntH3CKv9BX0T
         ovsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWaHDnHs9PXhtnMaEigv5oP54wMMFhfOO4CFoMN3PKVwF9Oe8Yh
	OMrFvLvZjh9OtK86QH9R3EKLE45ALqMSj+boolBYYVRTt1B1//zNuyL1LLsqW5INJxALtw15vmI
	WlnFPn64Abju9hs6rm1ccM3leB5DRYaP0Q28xYRm6SZv1Dsbbll1+AxhjFZMA8UTGAg==
X-Received: by 2002:a37:9c55:: with SMTP id f82mr18321269qke.101.1556555572905;
        Mon, 29 Apr 2019 09:32:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHeHRIY85s8uMG8E3Iu7M3D2zSondf9VLN0GOkpvVgAajA2oZoJInAFVWOcE0iXtM3/c2L
X-Received: by 2002:a37:9c55:: with SMTP id f82mr18321209qke.101.1556555572041;
        Mon, 29 Apr 2019 09:32:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556555572; cv=none;
        d=google.com; s=arc-20160816;
        b=0TBfvhbXhlW360YsJbqCbh+asSDTzTyO7KEzniv9DJJgmXj2112v2xfUmksHuZzneZ
         ECnndw/U9xccJNVXfMTF5dUY7F2uIYdIhsPEncbrM3KVwFdWZHHKHIN7as6FmBuYmt74
         usUeOr8rda1dGo+Jg0ujzqV3ObOKfGEX7GbFJy5IW8nGQib1peclE1lbxgOVn2oVMAkt
         78bPsi667ivePIkx7Ph+8xFwaHFbrIRu+HJymaZzJSA1Or1d0/2O9suQtpaRMGuxC7yP
         9mG0qLr6iBeBdg/WzrT9bHtQTNbaYHMFD/bw3FiSNwHB5LzQMJjXSGGuj1Bdcss0V7Ne
         wt7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=P96q6ty/O2QML/E66Bqt9ZOvxzjhotk8fjwe1hzcff0=;
        b=JUoOlqKdav4bdV9LseEjrkoaSx87n5/t0PONFGbRQ7/OJfopvLCV1D89UbYJ1h+1aw
         RN6h7Cdm9IJjXX1LinfUiiZTUARF28GArM2kkR2rYZ6cCD1/JHHyPUUlZe/Li0UKvEI+
         bpquYJHQBPFCryiUnbaRb1dWl/GjKLTLrb8VUrrDLhZPmVUBQQr27+Ci8GA0cOSRpjE2
         UScdT8PZ9JeSNN4Oc+FNX220qaHh+JdFkUHmYwfzgEPKOw0fry6U0x2B73QGLCFBRSa7
         qzVB/vzRuxlFYNR+m3HrH8Zi40/R1TI5Fs7NMNYUu8V3RnoxbUoL9AALSf6CgrrPbv7S
         qD8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d33si930567qtc.23.2019.04.29.09.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 09:32:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E995887623;
	Mon, 29 Apr 2019 16:32:50 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 17BCD17A64;
	Mon, 29 Apr 2019 16:32:46 +0000 (UTC)
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
Subject: [PATCH v6 2/4] iomap: Fix use-after-free error in page_done callback
Date: Mon, 29 Apr 2019 18:32:37 +0200
Message-Id: <20190429163239.4874-2-agruenba@redhat.com>
In-Reply-To: <20190429163239.4874-1-agruenba@redhat.com>
References: <20190429163239.4874-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 29 Apr 2019 16:32:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In iomap_write_end, we're not holding a page reference anymore when
calling the page_done callback, but the callback needs that reference to
access the page.  To fix that, move the put_page call in
__generic_write_end into the callers of __generic_write_end.  Then, in
iomap_write_end, put the page after calling the page_done callback.

Reported-by: Jan Kara <jack@suse.cz>
Fixes: 63899c6f8851 ("iomap: add a page_done callback")
Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c | 5 +++--
 fs/iomap.c  | 1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

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
index 2344c662e6fc..b01ed5a28d2c 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -780,6 +780,7 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 	ret = __generic_write_end(inode, pos, ret, page);
 	if (iomap->page_done)
 		iomap->page_done(inode, pos, copied, page, iomap);
+	put_page(page);
 
 	if (ret < len)
 		iomap_write_failed(inode, pos, len);
-- 
2.20.1

