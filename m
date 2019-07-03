Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F46AC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABD5221852
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="aZ2MSmqH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABD5221852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25EBF8E0015; Wed,  3 Jul 2019 14:45:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20F7E8E0001; Wed,  3 Jul 2019 14:45:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FE618E0015; Wed,  3 Jul 2019 14:45:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C98C88E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:45:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e25so2016082pfn.5
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:45:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XPK7j/nhYPSNHk18lJxr0eWlUo0mNfNPUUeKs4LCTRc=;
        b=Fa5ymS4ktCVBvC3ZwfNVdzcf4RBLQYZmMkZEBtkyydTKdEET6IvbLZ3FxLtmBWQZeN
         qixfyI/Z8dSShhkwf8caZ54qe1bStGdPtwdT0CeTNlPETYFkZnFDX2eTDy1oahd+mtyx
         EZzKX8sYp+6iggHYObZXSlDyoTBGyw3SnMRKLIM2CrAeffEZ0NHrZP1SNZr7Vhr5hSAA
         +2B2UKq0Qs2nIVHfUzyZH2+XSyLAJquYlVIJPtzlAMYknNXXnhKnZEnyTGuJrkvful3a
         9BxHwOEsvTiN9wR5ScwgLV7Atyw4C4dZwcY4SkBaqnM7Z2UzcnvS2F1rvB2BZGoiiOC8
         lXag==
X-Gm-Message-State: APjAAAX9Bn+hl7JoCJHsve4jIzyzsY8QWDPXE+4tKSbiExtd3vRwI8wU
	QAaXOQWeQYr6PhrN6/peMTquFLiWxYxs2zZSUfBpQEofHf9CmXM+kjkbB0dgOsN0Sh7x4+N/ogB
	Aw1h8hiDG3kiYMlUX/T63U/E0D1eKgsCZhR8ts1V8aan/hRickSCPceCWFOiwprY=
X-Received: by 2002:a17:90a:80c4:: with SMTP id k4mr14631026pjw.74.1562179508362;
        Wed, 03 Jul 2019 11:45:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNmZeKVOdeJ0UNaQ8u+p/N6PNBsZzmfaVmuooZV00W1kYO1gQ6qZnHrWPRw0NmROjUjBWa
X-Received: by 2002:a17:90a:80c4:: with SMTP id k4mr14630894pjw.74.1562179506964;
        Wed, 03 Jul 2019 11:45:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562179506; cv=none;
        d=google.com; s=arc-20160816;
        b=JZd03Gq1DrOPYr7tJqJy9HGDEO8i/r9XWEFmwbgeM9pQXFaPLufnor/nZzA12c13sV
         bB2GUPGJEUA3bNZrn0ITETBZk459zCx6wEULU8ozQDXlri+v/clm+PjioWno+HSuedsX
         rOmbIjvAWZqnkrHA8/S9FpUlS93l6bKZjFGb+D2i4kahsVxPlN1ConPJYC3AztrXD9vC
         2dRBIPsY5uYaT3w4iA0e4ftwVO9dIkHqhWHA1YfNME/up6uUC0y5w5Jhap5E4sXHGh9I
         7KWV1DXmvsXAgAMPWCGA6sL0RacsDRA2ZusyxCglgvBiEDdBPgaE2kwh1TriBrgDEB4/
         vldg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=XPK7j/nhYPSNHk18lJxr0eWlUo0mNfNPUUeKs4LCTRc=;
        b=KpwpLybipi0CeQVhY3kRDhuSCUo5KV8t7AMf558fhtOZ2KH5JNMw21H4OBcGjR8QSh
         pSykrRG2dJXJJN0djEZT1Zr1jcnTrjh7sKTPvPgMSLO8Rr9TZEA+9NzzQwOZk3mKNi1F
         4iZk5OWMe415VeHKea5jfJqPTL+LeVOugeTXc0fWSSbQ8DVV5/pjl6DGisvyWGzAQ4S5
         Pdee6tGF2JZYcn+wypUs5iA7cJ7ysn7VBgTh2XDEHlBLi68bFjeRqJF5f3+Msknba8sM
         w02oXZ9jLLGJiVPkwJH0vqYIAweJIVvjvQ5rLWfaMafqpV8zTynOJLhpbUBuq2gFiPrH
         25Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aZ2MSmqH;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d3si2803631pgv.492.2019.07.03.11.45.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 11:45:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aZ2MSmqH;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=XPK7j/nhYPSNHk18lJxr0eWlUo0mNfNPUUeKs4LCTRc=; b=aZ2MSmqHWGdzBWO6EJxpYOa04X
	rkOZ+JMScGnu4yWDwlFxB39C2SPRFDcqLe7Dp/z0XmphWB6IcXHc9g5dlRPHIwpQXCxtj+ptv86PT
	H/2f14bm3KweE5cA7cgg/8vIswk/ASZ12Ao9lNsu8f5xDjtzfL3NxD2ubcaSPhXhbsIqpG6LwD0dd
	TAe8Pj4LW+QVyGJcOcRujk4MCpIGaoxL2WcWtqXC+OTUz82dGOCQqZZZWf1L9myYX4kRb1dhNjDHD
	r+JDLlNb3K0dqshIVOE+pzLZRaDXTKBWTaXw/DvHcM19MFb3KccsVWspKp0L8bI9lFoFqH4nX4cYE
	9xyin7wg==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hikFb-0007Dn-EY; Wed, 03 Jul 2019 18:45:03 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Subject: [PATCH 2/5] mm: always return EBUSY for invalid ranges in hmm_range_{fault,snapshot}
Date: Wed,  3 Jul 2019 11:44:59 -0700
Message-Id: <20190703184502.16234-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703184502.16234-1-hch@lst.de>
References: <20190703184502.16234-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We should not have two different error codes for the same condition.  In
addition this really complicates the code due to the special handling of
EAGAIN that drops the mmap_sem due to the FAULT_FLAG_ALLOW_RETRY logic
in the core vm.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
---
 Documentation/vm/hmm.rst |  2 +-
 mm/hmm.c                 | 10 ++++------
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index 7d90964abbb0..710ce1c701bf 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -237,7 +237,7 @@ The usage pattern is::
       ret = hmm_range_snapshot(&range);
       if (ret) {
           up_read(&mm->mmap_sem);
-          if (ret == -EAGAIN) {
+          if (ret == -EBUSY) {
             /*
              * No need to check hmm_range_wait_until_valid() return value
              * on retry we will get proper error with hmm_range_snapshot()
diff --git a/mm/hmm.c b/mm/hmm.c
index ac238d3f1f4e..3abc2e3c1e9f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -951,7 +951,7 @@ EXPORT_SYMBOL(hmm_range_unregister);
  * @range: range
  * Return: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
  *          permission (for instance asking for write and range is read only),
- *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no valid
+ *          -EBUSY if you need to retry, -EFAULT invalid (ie either no valid
  *          vma or it is illegal to access that range), number of valid pages
  *          in range->pfns[] (from range start address).
  *
@@ -972,7 +972,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 	do {
 		/* If range is no longer valid force retry. */
 		if (!range->valid)
-			return -EAGAIN;
+			return -EBUSY;
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
@@ -1067,10 +1067,8 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 
 	do {
 		/* If range is no longer valid force retry. */
-		if (!range->valid) {
-			up_read(&hmm->mm->mmap_sem);
-			return -EAGAIN;
-		}
+		if (!range->valid)
+			return -EBUSY;
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
-- 
2.20.1

