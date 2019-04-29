Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2082BC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 22:09:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDC7D21655
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 22:09:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDC7D21655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FD636B0007; Mon, 29 Apr 2019 18:09:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6ADC26B0008; Mon, 29 Apr 2019 18:09:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C4746B000A; Mon, 29 Apr 2019 18:09:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3400A6B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 18:09:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n1so11586843qte.12
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:09:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CCsyaAq6NUSRHpNkWBkGVY0ELs69+m3iSE/8GgOpi8Y=;
        b=PswsPrgo+1ZOW59fMpbjsnQgOLpHp4M3DlW0fMwyUtz0hTMTag+PeZPGu/FKck2qob
         rS8LsWG4/boWYFA+ihQv/yWk0gdxdUhgCimqwxYDAZq1SzYSVxwGYQZrC4J9Cv3L6YeG
         eii7fs7/0gzE4Cxw4f0RFY7Y9zItXrrUBksZUsZZ2/5XJZ2BvOZTVEoaIrtEgb+wvhal
         +sfNyhTozD2fYlsUi9lSBFUmjP9WyarAO/xi/GGaGD5pnsdC9YqT6VTu8Xih8YcYPaTi
         vjyMHZVtwYCw36RMLCGvMDmLXvpOMB3Ud0nj0Yh1LvQCvfPlVdO6HQ/GybwHI5lkXAFL
         6yVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/0MwYrQXPRDEKenwiblp79H/3BXMQ/Khqp8SAvZIKfF0Tv4BR
	J23iXt5sWpGEThkOUQaGO1H0HZpBwvbMTViklNvofqdpSOoxIessmls2/EgfioOknPSv1oDRY/z
	+ah7b2Q/kdJF/fek+mglIbWIuz3FwVknaUcdSplOnP8qOh7If2JutKy8xeZALLvzcFg==
X-Received: by 2002:a05:620a:1088:: with SMTP id g8mr24473164qkk.173.1556575790991;
        Mon, 29 Apr 2019 15:09:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyt3AOwKIcDw98UGhiJbEomrEUxOj9gyjN307ipcoSfk27U/bGg/BRxXus7MntgJ8sdg4pD
X-Received: by 2002:a05:620a:1088:: with SMTP id g8mr24473100qkk.173.1556575789983;
        Mon, 29 Apr 2019 15:09:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556575789; cv=none;
        d=google.com; s=arc-20160816;
        b=unPvEq0Uec2cDGXdMAdKitZSgU0kjjicWYZWzzxirQNlpgRZlwu404KQ/+TfoKQzV5
         rjWx9502B8fbxu2uRp4q0V8/bAAokVUF7IWkFIGWuzhMUxCPBGF5lBBh1YxbaYViFNP1
         pEkPv0KyOIrAqbmfTTn4mwK197pZ6+YMQauDyJzbFUQmIqeM4ULAYdHtmX8mI5IyH6T5
         QiOjebc2rzI4MNL1p7UJ/AcKUdkZvihW9jbfAu0KvhX3fnbhALLHUskoYI8aCfei18LW
         N+fc7VDJM9CG1LVBgCRqh2luZoNMV+GvvZLIFPnotoXc7mhROnvUJOfaqfJ83iRnfaS2
         k0pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CCsyaAq6NUSRHpNkWBkGVY0ELs69+m3iSE/8GgOpi8Y=;
        b=vD1U2ZfC5XdWRKFhO2ZVgTIZyM9RraX7Qfx19tRu0Eqz/OaOdBwrCmMtbLz4yGPNPx
         s2SBQ6S6/s0n0lNFuxpQ5uRRFA0Zb4c9MslxkcAGOQy49lBM2N8zMsZ4VH+6NK1CWKhC
         47CKXuRV37twieN+AwOhcYamAg8oa50Yo7L1h5RS6CY2fTGbQ8aekPR3hSVrTWfkadi0
         ZFIN/SlViF//VN43TN/Fcxi+DWujQtqmaMKNRHFxVW4WYi+m4kYXxTJsJa8xZmK7J2HN
         GWRNyNdv52XifuvIcviiwwGwRJxA9RbeieZ1O0Bp4Bo5pOVkdO0+43hFsdk0+UPyT1zx
         +zjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 14si6787733qtw.393.2019.04.29.15.09.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 15:09:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1A3BC308624B;
	Mon, 29 Apr 2019 22:09:49 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5D9AA1850B;
	Mon, 29 Apr 2019 22:09:46 +0000 (UTC)
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
Subject: [PATCH v7 2/5] fs: Turn __generic_write_end into a void function
Date: Tue, 30 Apr 2019 00:09:31 +0200
Message-Id: <20190429220934.10415-3-agruenba@redhat.com>
In-Reply-To: <20190429220934.10415-1-agruenba@redhat.com>
References: <20190429220934.10415-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 29 Apr 2019 22:09:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The VFS-internal __generic_write_end helper always returns the value of
its @copied argument.  This can be confusing, and it isn't very useful
anyway, so turn __generic_write_end into a function returning void
instead.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/buffer.c   | 6 +++---
 fs/internal.h | 2 +-
 fs/iomap.c    | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index ce357602f471..e0d4c6a5e2d2 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2085,7 +2085,7 @@ int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
 }
 EXPORT_SYMBOL(block_write_begin);
 
-int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
+void __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
 		struct page *page)
 {
 	loff_t old_size = inode->i_size;
@@ -2116,7 +2116,6 @@ int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
 	 */
 	if (i_size_changed)
 		mark_inode_dirty(inode);
-	return copied;
 }
 
 int block_write_end(struct file *file, struct address_space *mapping,
@@ -2160,7 +2159,8 @@ int generic_write_end(struct file *file, struct address_space *mapping,
 			struct page *page, void *fsdata)
 {
 	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
-	return __generic_write_end(mapping->host, pos, copied, page);
+	__generic_write_end(mapping->host, pos, copied, page);
+	return copied;
 }
 EXPORT_SYMBOL(generic_write_end);
 
diff --git a/fs/internal.h b/fs/internal.h
index 6a8b71643af4..530587fdf5d8 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -44,7 +44,7 @@ static inline int __sync_blockdev(struct block_device *bdev, int wait)
 extern void guard_bio_eod(int rw, struct bio *bio);
 extern int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
 		get_block_t *get_block, struct iomap *iomap);
-int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
+void __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
 		struct page *page);
 
 /*
diff --git a/fs/iomap.c b/fs/iomap.c
index 2344c662e6fc..f8c9722d1a97 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -777,7 +777,7 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
 		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
 	}
 
-	ret = __generic_write_end(inode, pos, ret, page);
+	__generic_write_end(inode, pos, ret, page);
 	if (iomap->page_done)
 		iomap->page_done(inode, pos, copied, page, iomap);
 
-- 
2.20.1

