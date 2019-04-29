Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C836C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 22:09:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 628282075E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 22:09:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 628282075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E2CF6B0008; Mon, 29 Apr 2019 18:09:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0947B6B000A; Mon, 29 Apr 2019 18:09:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EECC46B000C; Mon, 29 Apr 2019 18:09:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD4F36B0008
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 18:09:53 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id p26so11591312qtq.21
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:09:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XPoMyuuM4ApL6KB762g1/x7lGygMjp3tNkFYSkeVl1Y=;
        b=mrjlJOCTMhR4Nk0WsWlU9JhPIfs4fAj7G1q/SGkiP7fN7tsup0a4Dq/aJ6hB5d7zvM
         rzlyDSweidDx34aoy/X1QaaIUEfLQnWn1v0KkEMnel896IoSccYCuNqFJJ3KxT7rwSiq
         2V2SH6GAn6b3BIYWRZwGKdy7YOh1x1OkeWqbRfTD/KftQF5AnyiuScgooLl381jj1AW0
         bdEMfLPQBJaJ63pp/5m75Y2DufuWlgiqKUSfm9iRB3o8ls1llKXYaZOtKKAmRwqae+Yb
         l/AXXSjIrsuRZMJOIEDBuL0HCZovH3fXGoTcQbMtSUnywz66xx0TcJRwXIQhpRfjJ64L
         tkPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXFzIRcHH/gwTIy6z8a1t01S13t6fXbszre7B0s1wLLM1i51vzi
	xA8sT/rzOojRfrOQl1S52rjJrTtlSfvA0c0FhQFlBy1XJC6tIFv4TnTHTgFTvX/d0l8FDsiPkvI
	MxtgTwPLPYRyIQNPzXJRUt+mUUJtGgxTwBllJaigeu46SZsWjPxy5ODILbGKXDw3OJQ==
X-Received: by 2002:a37:6315:: with SMTP id x21mr40254052qkb.265.1556575793621;
        Mon, 29 Apr 2019 15:09:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJGwcHKSMvSJzQ8NmatdhdlK1HoDNg1QkcJDdIV8xPHWF0xMouZ+YZegcDWr2GYrsxqYpC
X-Received: by 2002:a37:6315:: with SMTP id x21mr40254007qkb.265.1556575792965;
        Mon, 29 Apr 2019 15:09:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556575792; cv=none;
        d=google.com; s=arc-20160816;
        b=iNvrPJyHvapKRp6QzEzlpIC5L3NAPQnXhK2WSFTkzK21zXMD/vAa/xy5T0jlwBHdQq
         4OGCSfD9WXWjkhEgHqrMSqNiY9uIn6XmRjeh2hXZT/Ou6XQlaQLrKNuE5ZDGOK87ro6c
         XZ+/YJ4HzZPSXcXKLUuh8phNvLOeDnWRAf8SrRQ4IiPf1emBd5KoqYQKP4objcY7P7LG
         6muQSZAZQgMjy23x/jpr1E2s1q+BXU3MwZLQoY/wCgKreAyTgDPIuY+5dX01uMA7lS+N
         mi0MOozZlN9EzLlrVhkovHYUuQm5EqNrHSPGHsklPNtlDrc+usMraUUDP5Hjcyag9jRE
         AngQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=XPoMyuuM4ApL6KB762g1/x7lGygMjp3tNkFYSkeVl1Y=;
        b=HeyFlnMZqyYNAYr+yn2rTKfe6rZ5vGHNeiTBmKaTc8rvOdMHIxFP9ZeuXT3TRwCXsL
         oDHuDmjgFKMSxzebXtnOY2nQ+M6wdBxfbDJuCstiXoAwu6jrLVsX37xTqbSQgKvq3R0z
         nJFapZDVJE88aAnx6HyntXP86MGSj400p0hEkkT1wbKxD0j8qVl4WPtX7OT8v94UEd6I
         Vj6MrBQ+cXQGWX8gzuTG6RTac0QlSowhrYl4nf7ACCROjhGwn5ndNcoznzIoux8b13TQ
         uSjhBQWe1qXJXi3srPySlo1jwmFNXNF6NY+oWPTCaSMetwQcKE6xFGHv//7PUGhdQICo
         ok9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 55si1269525qtt.144.2019.04.29.15.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 15:09:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2E63C308624B;
	Mon, 29 Apr 2019 22:09:52 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7467717CCB;
	Mon, 29 Apr 2019 22:09:49 +0000 (UTC)
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
Subject: [PATCH v7 3/5] iomap: Fix use-after-free error in page_done callback
Date: Tue, 30 Apr 2019 00:09:32 +0200
Message-Id: <20190429220934.10415-4-agruenba@redhat.com>
In-Reply-To: <20190429220934.10415-1-agruenba@redhat.com>
References: <20190429220934.10415-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 29 Apr 2019 22:09:52 +0000 (UTC)
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
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/buffer.c | 2 +-
 fs/iomap.c  | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index e0d4c6a5e2d2..0faa41fb4c88 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2104,7 +2104,6 @@ void __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
 	}
 
 	unlock_page(page);
-	put_page(page);
 
 	if (old_size < pos)
 		pagecache_isize_extended(inode, old_size, pos);
@@ -2160,6 +2159,7 @@ int generic_write_end(struct file *file, struct address_space *mapping,
 {
 	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
 	__generic_write_end(mapping->host, pos, copied, page);
+	put_page(page);
 	return copied;
 }
 EXPORT_SYMBOL(generic_write_end);
diff --git a/fs/iomap.c b/fs/iomap.c
index f8c9722d1a97..62e3461704ce 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -780,6 +780,7 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 	__generic_write_end(inode, pos, ret, page);
 	if (iomap->page_done)
 		iomap->page_done(inode, pos, copied, page, iomap);
+	put_page(page);
 
 	if (ret < len)
 		iomap_write_failed(inode, pos, len);
-- 
2.20.1

