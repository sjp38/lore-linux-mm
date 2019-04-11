Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30B79C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D90342146F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D90342146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF8976B0270; Thu, 11 Apr 2019 17:09:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DD7C6B0271; Thu, 11 Apr 2019 17:09:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E5A76B0272; Thu, 11 Apr 2019 17:09:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACAF6B0270
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:09:01 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c25so6222824qkl.6
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:09:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QAyr/Sl3Z5T9efjHdFE117mrYZdiLhcoqaBQJPWPmnY=;
        b=dkrKeHhcw5bwsdCvbn5WdpgNC8dxgvTeWO2ICqIfbj1auyc0lqQeLoNKb4aYcxcj7p
         WuczPCNtR1B+pw1AITF4RxJmA8tdakV6ZTO+dPizunEXX0gLDnRzqPm2f81xmH5M6/4S
         +aQ8D3M7ZJwgiOZX8s87rFnIELV6iaAsbL/bbhhKP5ahY7ltzajG3xG6vXA25p5+wEbk
         lRI0fWNjMtISMHeMDQ/XC6zRn5HPeNh663RUnzWVIwJnauE1v1XBjBtMblcIAe+2Zh+g
         +mR0GhOBl55MmGTL3Z6vxfsmWLwTXcj4JZKK2CRe8kXn4kTeYtdsty/bUGdYNixo05uB
         gpyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVR5bfi9/DCaCI7XdGtsUdY+do/WW95Dcb3Z+uAtOqAuoatNnbb
	D0mU8PTY9wjiQb5eFV5r6Ix1Ren4hb5m4lxIdYAjljYE3YTXWt34WvFwyCOyl2IyS0YE3FqwfB4
	DdisQ11rirzqSFILs5AsTMBJVlYftjzK9mVjxj2XciQJ7+G1oOmOsmvi7gdD21bU8DA==
X-Received: by 2002:ac8:2ed4:: with SMTP id i20mr44944572qta.52.1555016941151;
        Thu, 11 Apr 2019 14:09:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzO7iGDHS9W9Hco1/mRzCoiy5/cSSogroyfHnm+RWpRt4cBRXhR0heUcaUmL9rKgAqWBmAo
X-Received: by 2002:ac8:2ed4:: with SMTP id i20mr44944518qta.52.1555016940474;
        Thu, 11 Apr 2019 14:09:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016940; cv=none;
        d=google.com; s=arc-20160816;
        b=QOuAMu57rTmo5XUlz+kVAxn5p6GapJDYyK6f9yXPsevcZjc7mG1mlKKIUemBr3SSnE
         VE9nm8a8WfUeLIf6d9pJBwqzqFIn1z2dPN0uSMOtiTuza8Z69kmZBTVikyUiXz8qQ2gj
         9fsASXl+MSCxYmuIOIEO5aNlcJQ5GJeXGT+YqjxQiXxEqpH7EnUqiHD/r/+fVywFS25Q
         w3MfTftKjcWIV/+FbA5k9CHVL0S2gvP7aJiboP6LnFlg6K2lx+tW5EDH64XwlG2FF2mg
         tS//o5eUF24kxkqgNtww8kBLZj58H5P5ymvwcoxYfHGkfAH/gchavTX34iWIltgJMN81
         pafg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QAyr/Sl3Z5T9efjHdFE117mrYZdiLhcoqaBQJPWPmnY=;
        b=qXbNXCNhEz/7Md4MoYwa7Cx7n6ldHC/qCia68EBhuapZ86VJnd/FKAHWK+pXUA7qVy
         gXYuo5qwSwkHf13VdYR/2FkY0fcP2ThjPDSHJStYIA5bYhMHEsbM04QQOPRBD7O9aH/D
         an3wtC0A49bCTGS9soJa/46lZsqnNfHAbVrW32zZA5ZhpOOpT+SFIWw19TrFEpjsYz//
         Dl4lp0BgTeFPzotLNKRqnqGdhFU+ygAEZ7O/+lL6esdmrwAMCsV3x9aDaG+yhEiYTOHT
         eD2igiIBV8BxsXS+IvdnEU8HLIGggGLjBIwlMCYf+ruNkC3bKhAD4ytNOU6Ob60YniXJ
         Uo+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g10si4726430qvd.203.2019.04.11.14.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:09:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 80026A1F6F;
	Thu, 11 Apr 2019 21:08:59 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0E0C05C221;
	Thu, 11 Apr 2019 21:08:57 +0000 (UTC)
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
Subject: [PATCH v1 07/15] block: add bvec_put_page_dirty*() to replace put_page(bvec_page())
Date: Thu, 11 Apr 2019 17:08:26 -0400
Message-Id: <20190411210834.4105-8-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 11 Apr 2019 21:08:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

For bio_vec.page we need to use the appropriate put_page ie put_user_page
if the page reference was taken through GUP (any of the get_user_page*)
or the regular put_page otherwise.

To distinguish between the two we store a flag as the top if of the pfn
values on all archectitecture we have at least one bit available there.

We also take care of dirtnyness ie calling set_page_dirty*().

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
 include/linux/bvec.h | 52 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 51 insertions(+), 1 deletion(-)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index ac84ac66a333..a1e464c708fb 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -20,6 +20,7 @@
 #ifndef __LINUX_BVEC_ITER_H
 #define __LINUX_BVEC_ITER_H
 
+#include <asm/bitsperlong.h>
 #include <linux/kernel.h>
 #include <linux/bug.h>
 #include <linux/errno.h>
@@ -34,6 +35,9 @@ struct bio_vec {
 	unsigned int	bv_offset;
 };
 
+#define BVEC_PFN_GUP (1UL << (BITS_PER_LONG - 1))
+#define BVEC_PFN_MASK (~BVEC_PFN_GUP)
+
 struct bvec_iter {
 	sector_t		bi_sector;	/* device address in 512 byte
 						   sectors */
@@ -58,7 +62,13 @@ static inline unsigned long page_to_bvec_pfn(struct page *page)
 
 static inline struct page *bvec_page(const struct bio_vec *bvec)
 {
-	return bvec->bv_pfn == -1UL ? NULL : pfn_to_page(bvec->bv_pfn);
+	return bvec->bv_pfn == -1UL ? NULL :
+		pfn_to_page(bvec->bv_pfn & BVEC_PFN_MASK);
+}
+
+static inline void bvec_set_gup_page(struct bio_vec *bvec, struct page *page)
+{
+	bvec->bv_pfn = page_to_bvec_pfn(page) | BVEC_PFN_GUP;
 }
 
 static inline void bvec_set_page(struct bio_vec *bvec, struct page *page)
@@ -71,6 +81,46 @@ static inline struct page *bvec_nth_page(struct page *page, int idx)
 	return idx == 0 ? page : nth_page(page, idx);
 }
 
+static inline void bvec_put_page(const struct bio_vec *bvec)
+{
+	struct page *page = bvec_page(bvec);
+
+	if (page == NULL)
+		return;
+
+	if (bvec->bv_pfn & BVEC_PFN_GUP)
+		put_user_page(page);
+	else
+		put_page(page);
+}
+
+static inline void bvec_put_page_dirty(const struct bio_vec *bvec, bool dirty)
+{
+	struct page *page = bvec_page(bvec);
+
+	if (page == NULL)
+		return;
+
+	if (dirty)
+		set_page_dirty(page);
+
+	bvec_put_page(bvec);
+}
+
+static inline void bvec_put_page_dirty_lock(const struct bio_vec *bvec,
+					    bool dirty)
+{
+	struct page *page = bvec_page(bvec);
+
+	if (page == NULL)
+		return;
+
+	if (dirty)
+		set_page_dirty_lock(page);
+
+	bvec_put_page(bvec);
+}
+
 /*
  * various member access, note that bio_data should of course not be used
  * on highmem page vectors
-- 
2.20.1

