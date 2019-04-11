Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A60BBC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60ECC20850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60ECC20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48AA16B0276; Thu, 11 Apr 2019 17:09:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 414A66B0277; Thu, 11 Apr 2019 17:09:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D9CD6B0278; Thu, 11 Apr 2019 17:09:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0BE6B0276
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:09:13 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id b188so6237201qkg.15
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:09:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RRRsdcWKEG59mpUZe8aMcPhxrPUhtqtJ/Wi0sfvATAg=;
        b=HGS6GtgKgHYXmrNL7YuDujtJ2sRgSobv9E3Y3SgSO1y/f6x8K94+mjnVVE55/pTa/s
         uK+AkvWgX4LwFvTCtDRVhMkXIlVt9FZJZJuYr2qLLHr7ThaTH77DDrUGvatjfRr/Dj7h
         SlSk76bCXQsOtM7l2uA/bnEUvp1mcntY0I4VVaeWx+MxupqV8M/VBFRaWgRtn9IvpNp8
         iQC6rt+5jdOTQQKaX4Nly0cQC25puYTBdLMYzTcxSYP0a05YtTf7e4LyGIiXEG6a9r4H
         0Lm6LrjYOatFDpt27kvMq0ImdCzlgHgjfq2my9DmXl9FPz163xkRA0zbrF2fKQI7H+UD
         k/9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVFDpD6kGV9Tk0CCxE41ruXIZk1uxZPC9TzefR+mptUYC8yzm/p
	8ttuvV8edXvA+aqDrPAfR/uULgXiVVXkPpuAlwuXbcqXveRx54QRM6xA0+b2PxU4DubLuxm3Q0y
	hALHfhZAbmObgaZKaO0BI9hN0aUPESZwnPLudOdV4UpX0VdyAN6O3qgHYJj1QiGk7uA==
X-Received: by 2002:ac8:5493:: with SMTP id h19mr29884902qtq.23.1555016952830;
        Thu, 11 Apr 2019 14:09:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQ4GlvLWpzAyigLFuRBueA4OgHoSv0CBlO4utujGtTkgadJBF6eykpAzgXQCY094dDgcNw
X-Received: by 2002:ac8:5493:: with SMTP id h19mr29884833qtq.23.1555016951984;
        Thu, 11 Apr 2019 14:09:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016951; cv=none;
        d=google.com; s=arc-20160816;
        b=B0y3u8qCdyxevUJd7gjbSGMmZZrsvWf735HwRLw0sxetH6hVWVjL5gQgowKTjXQcy1
         Ble9ia1nUKkNE4BxT0zxTDcAoiCpDazm/Tdpc5BrMwJH++Cfcmam8f/iKvh1AksMwSrv
         HiQYewMI0KvBSGb0a/jLHRogNNE9gFxswnL1aAs1f9I51IS4Qv6XlxgRkWnm97TQ7lsp
         qZ/2aU27rjEkBhdeZLWPllBqMZkiVe6tOpg4dzqdSN3k1Er3t55OOec0eCowjS3/2X0J
         tPwU9sB+7U1K+9R3VkU7P0OZDi1PHPTug4PDYWS6U7VauzWPo8+R4EkqEUtRnwk8/x/W
         IUqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=RRRsdcWKEG59mpUZe8aMcPhxrPUhtqtJ/Wi0sfvATAg=;
        b=TLyhpg6GNpwgogdSo6RfrNpCczYY3wu8ejBMr5KRMWkDjnunZAnfipFUaNoLwP+PQ6
         cj2vNWrhu3w+TF6oD8hnL8xXLYPA+b739khVkD3LcE+X8dZBRR7SVMOkdLIV9OxwkjjE
         t2XhCRpA/o1Tkixj3uO/j84YiwlZssIK/BBwxkewVw5WmdIC318/HJiNBatnvbZ5n9nV
         OzkZzgOBlzXxhylv1SFcl4x0Cl/gnhQAF3ltHg9Bg2cXETQXZB+aknB6vMUU6yTPAI00
         Kwq7K4kiB15jn9IbM5sGRjbnMaC5pb33dgm3xNcnz8SC5xkUTqKwm46y+MSbV2wD748e
         PoEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si4111661qta.351.2019.04.11.14.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:09:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2C86FA0C5C;
	Thu, 11 Apr 2019 21:09:11 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AB5D95C21E;
	Thu, 11 Apr 2019 21:09:09 +0000 (UTC)
From: jglisse@redhat.com
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v1 13/15] fs/splice: use put_user_page() when appropriate
Date: Thu, 11 Apr 2019 17:08:32 -0400
Message-Id: <20190411210834.4105-14-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 11 Apr 2019 21:09:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Use put_user_page() when page reference was taken through GUP.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>
---
 fs/splice.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 4a0b522a0cb4..c9c350d37912 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -371,6 +371,7 @@ static ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 	unsigned int nr_pages;
 	size_t offset, base, copied = 0;
 	ssize_t res;
+	bool gup;
 	int i;
 
 	if (pipe->nrbufs == pipe->buffers)
@@ -383,7 +384,7 @@ static ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 	offset = *ppos & ~PAGE_MASK;
 
 	iov_iter_pipe(&to, READ, pipe, len + offset);
-
+	gup = iov_iter_get_pages_use_gup(&to);
 	res = iov_iter_get_pages_alloc(&to, &pages, len + offset, &base);
 	if (res <= 0)
 		return -ENOMEM;
@@ -419,8 +420,12 @@ static ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 	if (vec != __vec)
 		kfree(vec);
 out:
-	for (i = 0; i < nr_pages; i++)
-		put_page(pages[i]);
+	for (i = 0; i < nr_pages; i++) {
+		if (gup)
+			put_user_page(pages[i]);
+		else
+			put_page(pages[i]);
+	}
 	kvfree(pages);
 	iov_iter_advance(&to, copied);	/* truncates and discards */
 	return res;
-- 
2.20.1

