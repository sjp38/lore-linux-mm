Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 093C9C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:08:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B620220850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:08:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B620220850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 991DB6B026A; Thu, 11 Apr 2019 17:08:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F7226B026B; Thu, 11 Apr 2019 17:08:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 724E86B026C; Thu, 11 Apr 2019 17:08:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 436366B026A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:08:48 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id g25so6168867qkm.22
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:08:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0Njb3cVhtrdJZi5FqSZVo9erCodEOGeR5p/8OpCuACM=;
        b=CsA5u2scsGW8VNhgr8blLsF4IjX2upaCQ+NB5DgrWHciuV/sJNpzf+uVLXXWtTzfp0
         J08SKt3K6ZRQenJ13VEfGEVJNAMi7Qdws56de4nS4Lfsn8i0lfTbfl3MrZ9TfgxedGdj
         /HU/92ahBmJlM2yuvqzOZ1XUK0NEX2hgRCdGPfq3KjiqkYnJkJXIxmMSW+3ZVv2JMtB6
         Urd/O6pbibAIePMrxxk3IYJlZshxAW+v2ruUWpamKjwUSGT2LNMa4gwtj+4+RcwIw7n3
         J9s2RXzUbPwrr+CcOXGblzjmSNbPXXKMsoERkkMebZc784+ARs59aTxYuj3c2rAp+r2R
         bIvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV+GNZ1I6hXIH1e6Dgdq4/LpRKNJ6wDOKhKHeK6CY+woV4RGmI6
	7IEJ2keHBDvDJtK5OtBLE1nnAqeoSHPVyCM6SMXM3gJg/8pTXRcg0d27JrFvGVK4m3LlshO+X8M
	yBsSGLVfNhI9WeM0zjr+1nb1i4nyW/C77fwgiEUM0+kC74bV8CIan5/CCBm2HR8FaAw==
X-Received: by 2002:a0c:b15c:: with SMTP id r28mr42301991qvc.122.1555016928038;
        Thu, 11 Apr 2019 14:08:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTG3QUqHOVmSPOXxmE+80iweJjEm3E4AxV0LUROnZ3bZWE7ESJYX0hhPpgvzVE/Q44l1fF
X-Received: by 2002:a0c:b15c:: with SMTP id r28mr42301883qvc.122.1555016927035;
        Thu, 11 Apr 2019 14:08:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016927; cv=none;
        d=google.com; s=arc-20160816;
        b=NRsFo9SZDZkm8fVkyUg1dQ9VO+CzssjGP/qFT6dN/flwfSHRozTtOxlFFr1jWmQq2a
         EdGSzR4JgAQi99IrjrDNFQ+1b87gAJ7f/At3h1sbbTQA4fkQBtbNtvaFzj/6MBVNhmXS
         DFExUqkf0scWT/rPEMwwfb7wtNZBxpw/17hX7RowavVMGK6NVNLN8KO8WBUkUPs7B3O3
         Lg5mcgzP9FlvKu1jpbVOarCi4OjxAFK7HaalX5ifkjuc/WVGFk/Yse0aI26WFGm1tb0Q
         M3nuoezajIkWb8JjtcC/WzgEn3uQEYDHZ1GAUm08Fzjc6P9e0Hdau71wmaTX4xbsO+VU
         UOSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0Njb3cVhtrdJZi5FqSZVo9erCodEOGeR5p/8OpCuACM=;
        b=mmvU98fqNSL26KQLAV3RmMjHO1F0JJfdFvq4vrqNwEPVWaeWbEqxoUFi+Sr7+y/ED3
         6e99Uq4yl2sPpj2KKYblf3CyBzKDCSA4guvakut8NNTrlaXrW0q/ALukPNWBKuOYnZWO
         lNdD+7ESEmJXS7F6ryu4N3AvmQ+/f+ptoTxTTfYc/LpOnikuD39v+t56K78fBEATthL4
         GAZbW/GZ0sLKt8FoPA3DET6HcL9s7fxNT5AgyprK6ZcfR1ClfV4GFxT7HjJW57Xt+arO
         5hmrcXjaDKUGYx+ltbm55jPo9I8xx/qC6wtBwJpN/+m3vjS/5bOBaduA3GPHFXDRS1XO
         7+mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e3si1309901qvp.90.2019.04.11.14.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:08:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 27B22307D910;
	Thu, 11 Apr 2019 21:08:46 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 99D0A5C219;
	Thu, 11 Apr 2019 21:08:44 +0000 (UTC)
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
	Matthew Wilcox <willy@infradead.org>,
	=?UTF-8?q?Ernesto=20A=20=2E=20Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>
Subject: [PATCH v1 01/15] fs/direct-io: fix trailing whitespace issues
Date: Thu, 11 Apr 2019 17:08:20 -0400
Message-Id: <20190411210834.4105-2-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 11 Apr 2019 21:08:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Remove bunch of trailing whitespace. Just hurts my eyes.

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
Cc: Ernesto A. Fernández <ernesto.mnd.fernandez@gmail.com>
---
 fs/direct-io.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index 9bb015bc4a83..52a18858e3e7 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -196,7 +196,7 @@ static inline int dio_refill_pages(struct dio *dio, struct dio_submit *sdio)
 		sdio->to = ((ret - 1) & (PAGE_SIZE - 1)) + 1;
 		return 0;
 	}
-	return ret;	
+	return ret;
 }
 
 /*
@@ -344,7 +344,7 @@ static void dio_aio_complete_work(struct work_struct *work)
 static blk_status_t dio_bio_complete(struct dio *dio, struct bio *bio);
 
 /*
- * Asynchronous IO callback. 
+ * Asynchronous IO callback.
  */
 static void dio_bio_end_aio(struct bio *bio)
 {
@@ -777,7 +777,7 @@ static inline int dio_bio_add_page(struct dio_submit *sdio)
 	}
 	return ret;
 }
-		
+
 /*
  * Put cur_page under IO.  The section of cur_page which is described by
  * cur_page_offset,cur_page_len is put into a BIO.  The section of cur_page
@@ -839,7 +839,7 @@ static inline int dio_send_cur_page(struct dio *dio, struct dio_submit *sdio,
  * An autonomous function to put a chunk of a page under deferred IO.
  *
  * The caller doesn't actually know (or care) whether this piece of page is in
- * a BIO, or is under IO or whatever.  We just take care of all possible 
+ * a BIO, or is under IO or whatever.  We just take care of all possible
  * situations here.  The separation between the logic of do_direct_IO() and
  * that of submit_page_section() is important for clarity.  Please don't break.
  *
@@ -940,7 +940,7 @@ static inline void dio_zero_block(struct dio *dio, struct dio_submit *sdio,
 	 * We need to zero out part of an fs block.  It is either at the
 	 * beginning or the end of the fs block.
 	 */
-	if (end) 
+	if (end)
 		this_chunk_blocks = dio_blocks_per_fs_block - this_chunk_blocks;
 
 	this_chunk_bytes = this_chunk_blocks << sdio->blkbits;
-- 
2.20.1

