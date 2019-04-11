Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE20CC282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:08:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 756852146F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:08:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 756852146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28DB56B026B; Thu, 11 Apr 2019 17:08:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 218646B026C; Thu, 11 Apr 2019 17:08:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BC2C6B026D; Thu, 11 Apr 2019 17:08:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D41266B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:08:49 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id g25so6168933qkm.22
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:08:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7Ca7Z8NG5OMgg4MbdGL4h958yxZA80rzhHRQRgRbXrM=;
        b=hwCvUaeljYq2BX4U53UkU8cQL4iHYQD6Qn1LUYOo6SnGHtiWGNsYhFD2uEoGCyrFDL
         zAfDFOcTAdMpisKCprSpvywKGU6djkyHCGoVPVBI6etyyyCKKW1Ux3UXCLQcSzQmMlrT
         KHQe/U7SbPQ1eS7JfwIbar/jfR483bSdv5Z6WWg/yCKAC85skJTOLMeGWbSDPxD//8GA
         thmFXcVHrRjVqRwiXsRFg1lABx81OqacB23k22B/4gse/i0N5EjU2UdpmjNnAr5EuM0D
         QhiZ2e3tOAszddweTLCdN+jjfuDPmbddAV2LFdjTT70I2SvkkzpHiVW5TwXLAGTy5j0f
         28OQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUCXyfdNYXECV+AQZ4lex5UslkDYAjgyX4ozICsJux/4cNXSAjL
	HlaE9fb+uIFW3g6kfijLxo6NOLfF3am4raDOHdthFhDSTD6KlNpl+pUARLct6sC+r3ntLgW7prw
	M4dux655UrColYKJMMW8p6NDnMJNBM1UKnwCaeaI45mRWzKREh1xHcdLIAWTXVV/3XQ==
X-Received: by 2002:ac8:30ea:: with SMTP id w39mr44240917qta.351.1555016929594;
        Thu, 11 Apr 2019 14:08:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6Ad2h1xz9pNa8yrrzePgNYqlOk3B1AFqJ2TCEfAwsKy8t3tPEwBIocIBlezM3+cbvMrLv
X-Received: by 2002:ac8:30ea:: with SMTP id w39mr44240840qta.351.1555016928644;
        Thu, 11 Apr 2019 14:08:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016928; cv=none;
        d=google.com; s=arc-20160816;
        b=uarwICkayo3JSLA9YLF+bTOQRDrVrVhS7xUkiytZx0bYiXdrrW4l2AQIkH2AjnrImQ
         bocf3aVXFzaasO9y2H92NqHAbo0CMS599nr8C0QfkgST9Sx9pWcFmhlQ/j8QQhKAhl01
         iH5vx2XytkHZdZ2JCzzfhRXKLgGDMger4/UwyaJQ9H0A710+3eyNseXmtGHidkqAOJJo
         4ceJR7Jbhn8FoCom1Tv2x9wDCOF18E+aETZ9gvZmahOrvD2UP8566jobghCoQIzB38KV
         yvrzRQk8BmyVdCORuQU0UA5nEwEXWO2AlgLP9r31etVW2yyc/pCTK4i/UOzoxxMLamyB
         hJXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=7Ca7Z8NG5OMgg4MbdGL4h958yxZA80rzhHRQRgRbXrM=;
        b=IrwhSXdLj4dCOHvlrFvV+5QsY6ixv9wU6bijQUinW3l3Fl/uOmm+WNCWcYnNXyHprm
         8Qyv5zpeiDI1FIPybu8G2aYGCze4uZN8NWjdHNclKRef18LceseOkoGwffacm4FybDeI
         CQJtpc1gkXPeqjrFpU/Fpea9lm8yZJGTBLmGH1zbku5D2dBWW1P9qme+TAWlzhSwh2ko
         wNY+M5rjYzZT24a+ActhawtdcnVs8hGF+vau927V+OFvK/jxvvhk/wD5itmk4zSKcusj
         RPdL6ZyxYf0FpoyEoaPzCqeBeptWYRGkxkjX21E9UIUMTQtQDCyjq2lE+bEkUbf2k4w2
         fdpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i33si2138482qvd.144.2019.04.11.14.08.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:08:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BBE38368E6;
	Thu, 11 Apr 2019 21:08:47 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 492F15C21E;
	Thu, 11 Apr 2019 21:08:46 +0000 (UTC)
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
Subject: [PATCH v1 02/15] iov_iter: add helper to test if an iter would use GUP
Date: Thu, 11 Apr 2019 17:08:21 -0400
Message-Id: <20190411210834.4105-3-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 11 Apr 2019 21:08:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Add an helper to test if call to iov_iter_get_pages*() with a given
iter would result in calls to GUP (get_user_pages*()). We want to
track differently page reference if they are coming from GUP and thus
we need to know when GUP is use for a given iter.

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
 include/linux/uio.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/uio.h b/include/linux/uio.h
index f184af1999a8..b12b2878a266 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -98,6 +98,17 @@ static inline bool iov_iter_bvec_no_ref(const struct iov_iter *i)
 	return (i->type & ITER_BVEC_FLAG_NO_REF) != 0;
 }
 
+/**
+ * iov_iter_get_pages_use_gup - true if iov_iter_get_pages(i) use GUP
+ * @i: iter
+ * Returns: true if a call to iov_iter_get_pages*() with the iter provided in
+ *          argument would result in the use of get_user_pages*()
+ */
+static inline bool iov_iter_get_pages_use_gup(const struct iov_iter *i)
+{
+	return iov_iter_type(i) & (ITER_IOVEC | ITER_PIPE);
+}
+
 /*
  * Total number of bytes covered by an iovec.
  *
-- 
2.20.1

