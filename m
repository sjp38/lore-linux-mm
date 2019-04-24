Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C80F8C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 17:18:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91CFE21909
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 17:18:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91CFE21909
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EA286B0005; Wed, 24 Apr 2019 13:18:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 397CA6B0006; Wed, 24 Apr 2019 13:18:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B0FD6B0007; Wed, 24 Apr 2019 13:18:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D64F6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:18:14 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o16so5307774qtp.18
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:18:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=8PN4q84qh1f9OH8MwcxBKyw+Qn2Lh6fcIVoT1N4C0nQ=;
        b=PQnMt3Ql+PHIGBdFq+xtSqhOfmbrJH8KnPKkRGTnKI64vltRPc8s1pAI28JoBJDfHY
         T89dZEFOALt36WsbAIo0GZ1EVqeD39FAHCIZCwLdWtSV4QhCyHaAvCTP7yHYlXzDVUw8
         rqor0phLyb6pytNu1Cb7Sfk4uatROoYPp0ra7AkT3w4+KxyajmSC3f1JK3atGmQknxfo
         u0WrDJF+3VtiGRg1raCP1G5fH5T5DGIQFm/HKBoGviCLlfPfqAZiEPoZdMw9VcGR7+CJ
         m84GG17dqlVR1BUg2/NNqIi4Tumj5cWIi5Y/u9RZM2OyeCm+7SvwUKW0WPsWHVNXbPMo
         w8Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUumNWJteDL/GZeAjPOgVzdom1i7+XafNcSOAe4dqhrucxl5DoW
	wLdoPJ9Wjkp/gBB9Khoji3cMZ1h1ayQfgrSLJOqTLmpSNxOyGnzCRZrMcsoyWr1yQRrc3161rUl
	DY3t5uAAdxTzWUL2N7DLZdmM1N4xyevOBZjG3/Agd3l1sUrQBvVICc/6EGTCfCFp3tA==
X-Received: by 2002:a37:5b86:: with SMTP id p128mr19425715qkb.10.1556126293807;
        Wed, 24 Apr 2019 10:18:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTMvmZCecso3Jqtdf2ufM0GrD3fnSfFlxn+S0uOE3r4xCNz+La5IX/ORO8TW41/f0VxFqQ
X-Received: by 2002:a37:5b86:: with SMTP id p128mr19425658qkb.10.1556126293044;
        Wed, 24 Apr 2019 10:18:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556126293; cv=none;
        d=google.com; s=arc-20160816;
        b=TEBKW1rc3c3tNtOEol9KWEcJGSEtp7mcT5qKHSLFhf+j0il70YJwGaU1pk4SmvyZwG
         P2jbG/IHd3MJNwgEpRwlFZqdHZRf0VhlYfB3k67X+7xVVt1XVAlZzOuqdWhM9pDfalB9
         RIm6u51m/5gXoR4vv2yAC8Sq4WiuW1qRUDyN1XQNFmlD66vCqo6vLsRhF2gZ2GVqqxXM
         5Me55IhY87j6PzvvJ+mLhIaEgFMxIE80jSEy57ztu9idjePrRgSwbdinYJu2cClFqhvr
         fpCTVb65sQ9uddyrnjkDd2fw2hxNATbjP7qEVEfN6JeapK87k+7q9crSVcaKX2KK2L2+
         buCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=8PN4q84qh1f9OH8MwcxBKyw+Qn2Lh6fcIVoT1N4C0nQ=;
        b=GY2gSxsDW+q7XsHD9j/WbfVY1CQm37rFzAYb9KmGf4B9fKweqOxVYze5sf2g74cIMZ
         Hh+zQ607UJ2WoT4kBA9B+ntnA91kNcNDDcOxXe04+20Ugje5yrB5Ki/hMFrfGHAIHDTK
         4gKQKsiNtza5TkxR+3Un6CNxg4bLr0CycOz8OagzojmIfMTtB0sPXKHlWpdyn5Eat+jA
         uimGuF5srZpoUE1fyKXU/8rOvbDffhL6/3coxb910QLjvilgPMBW8GA5JK3Il3gYs1tr
         RjWxmpNnYXCfhvLvIRWMOcgOPAWtyZgRJOktZdhE65R8lYe7htPFcEredQJKonUrIhyx
         UWfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l21si1698879qtb.379.2019.04.24.10.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 10:18:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1C0093147DD8;
	Wed, 24 Apr 2019 17:18:12 +0000 (UTC)
Received: from max.home.com (unknown [10.40.205.80])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 164305C21E;
	Wed, 24 Apr 2019 17:18:06 +0000 (UTC)
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
Subject: [PATCH 1/2] iomap: Add a page_prepare callback
Date: Wed, 24 Apr 2019 19:18:03 +0200
Message-Id: <20190424171804.4305-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 24 Apr 2019 17:18:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a page_prepare calback that's called before a page is written to.  This
will be used by gfs2 to start a transaction in page_prepare and end it in
page_done.  Other filesystems that implement data journaling will require the
same kind of mechanism.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/iomap.c            | 4 ++++
 include/linux/iomap.h | 9 ++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/iomap.c b/fs/iomap.c
index 97cb9d486a7d..abd9aa76dbd1 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -684,6 +684,10 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
 		status = __block_write_begin_int(page, pos, len, NULL, iomap);
 	else
 		status = __iomap_write_begin(inode, pos, len, page, iomap);
+
+	if (likely(!status) && iomap->page_prepare)
+		status = iomap->page_prepare(inode, pos, len, page, iomap);
+
 	if (unlikely(status)) {
 		unlock_page(page);
 		put_page(page);
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 0fefb5455bda..0982f3e13e56 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -65,10 +65,13 @@ struct iomap {
 	void			*private; /* filesystem private */
 
 	/*
-	 * Called when finished processing a page in the mapping returned in
-	 * this iomap.  At least for now this is only supported in the buffered
-	 * write path.
+	 * Called before / after processing a page in the mapping returned in
+	 * this iomap.  At least for now, this is only supported in the
+	 * buffered write path.  When page_prepare returns 0 for a page,
+	 * page_done is called for that page as well.
 	 */
+	int (*page_prepare)(struct inode *inode, loff_t pos, unsigned len,
+			struct page *page, struct iomap *iomap);
 	void (*page_done)(struct inode *inode, loff_t pos, unsigned copied,
 			struct page *page, struct iomap *iomap);
 };
-- 
2.20.1

