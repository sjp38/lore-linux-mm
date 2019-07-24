Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C84BC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55C5820644
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PTpmJ/2q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55C5820644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE64E6B000A; Wed, 24 Jul 2019 02:53:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBCAD6B000C; Wed, 24 Jul 2019 02:53:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D853D8E0002; Wed, 24 Jul 2019 02:53:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A264F6B000A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:53:09 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so23553009plp.12
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:53:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DSjx3V8seGjWbwtcA9zyGdO2uw7ke18fmJwoWmqMVnM=;
        b=gFiteGybsF5mDsxB4zBADgeWLnHFjb/qRv4yOdBNgZnbLBfxbv8QLxHIY1JtSB4nan
         NVJ45NO0DTwBVqs8jN99HnDx/o38dJW8IvXG15WYdNcwqv1gBx8gExZDz26o2tPzviZU
         s1rH5jbM8t8CZRPqXOxzfPuFP8BsWhaq+9LjjYIqt++UcD9Kbv7yPXtqkxDrJEwYrPpq
         F1IaerbLPN5etkFkb/CwMYYnEOhqJoCbSTs89mxiActyIossiEVofbT6NpqI4wNMcfTP
         LxKOzB5XFrgHzHWjPNKi+t36j5FYe4rrqpY/2vRw8AO7ffY0Ct+FlKaU8MHqxXnn9Vn3
         Cd+A==
X-Gm-Message-State: APjAAAUNrwxhHOm0TJOU+RRuz2xeMbcwYVQ9copSmc7AXiOEDLv50q0r
	F4OAFIw4Y2DY3F/LQK+hmOgeW8oilsTcD5khKUzjU9XDXxs4nhpyLMgoFwc7gdKfpTre4j2GC0q
	pCLKfoUiX6wD30h8Pwq7h71B0DQ03redzmyyk5wsmkVgrVZePazlen7rnpzI1r9U=
X-Received: by 2002:a63:5a4b:: with SMTP id k11mr20877097pgm.143.1563951189166;
        Tue, 23 Jul 2019 23:53:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGr/b8ETfGlUKcJECUsOFLJgQBxnc4vNWKGwzZQNb4IICnQ4r8uqgQJsBKESiYMTTkNAYB
X-Received: by 2002:a63:5a4b:: with SMTP id k11mr20877037pgm.143.1563951188071;
        Tue, 23 Jul 2019 23:53:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951188; cv=none;
        d=google.com; s=arc-20160816;
        b=yB5YyTseaoRwWJQbgTVbivvn0z6puM+GzrJ8Z6DcWRKkeqQRNNhdUeQpBp5Teigtxg
         UKLyE+9M24Zjujx3y2CpURXd8aRhmfG5AZb5beGZwBEFWU53WmM2CkP7zaiBP0JJgp0a
         vOn5ItMLJgE4A/hPPF7IOsbxTisJkQv/sDrxVY3K1Wx9kbxgVGOR9XyDoDXAA5l9ZAKi
         +Hc2B7DB5ZsoQl8iWFKWVPFt65x9qcfQy+KWRk0uG92j6f9Wbs+gJt4kHEJ8SjcdRgF0
         ngLPvLgwpXAGUro6DebO3OnW1oe+Uz1Qx80o1Er1fCNSMn/H8okRki0IbFFr9XtqGedk
         Fm0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=DSjx3V8seGjWbwtcA9zyGdO2uw7ke18fmJwoWmqMVnM=;
        b=aoJ+Kf/sGId52cdCafFMwZ9Ww9r6Q7iSSDvF88/V6L8SGqUM8ZaUBdckQBEvTCi2tJ
         QORRA+riC4f8mgRG/TqKt2FbqfNP2mYTKodCi5m40mfJP/ZfhfuWkeI0BboSNDVflF4C
         qN4WoIohreFlDtONpIsnOIc+TcKqxMXzhMKjjaWqu0Q+bWOp0F1gWMRgG/aAfPcbndgf
         XpM32IVH2GJW4HwKjgQWgxLV19PRqDKM0JDt2M+oSAW01t0dQC2vAgAOkfY+v7njNj/W
         N0xI/fSkPRhyk7nELRARUDur6vrLOA23e0jnqqM/43+hDNEq71Sc9I9qs0MdlgV/nJI6
         q4+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="PTpmJ/2q";
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g35si12243062pje.73.2019.07.23.23.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 23:53:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="PTpmJ/2q";
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=DSjx3V8seGjWbwtcA9zyGdO2uw7ke18fmJwoWmqMVnM=; b=PTpmJ/2qJ58v0Yn7xWag2yZ4ef
	VhRhiyB0VamFSm/AzvXGbwI1J1iNXfwAIOx9CqQeqJG+6qoNH24LLcL8LRkeL0GGTNRFSff85NWoz
	xBcuEzvSyLoJpa2SwhN9ePQsgmeTvYsFJwH61I34/01jbQSmoVRmNu0Dqvyu8LxE/c6XLsw0PIDgs
	EsRCpWtRTg/GzpZPGrSl3fkLoByjtS8UwgWbA+pnyBgqRQHBBjASyZ2gZHwMeRF9rLwoYxcrFzbqs
	LBOcdZ/AW4DSb5YW36uQh7jbcNN5xQ7CSV6LHqd+GuCw3/ziT1lLD7n4rUIezcKRBCUNNWstdC55d
	yxqUSZjw==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hqB97-0004IF-4l; Wed, 24 Jul 2019 06:53:05 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>
Subject: [PATCH 1/7] mm: always return EBUSY for invalid ranges in hmm_range_{fault,snapshot}
Date: Wed, 24 Jul 2019 08:52:52 +0200
Message-Id: <20190724065258.16603-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724065258.16603-1-hch@lst.de>
References: <20190724065258.16603-1-hch@lst.de>
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
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
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
index e1eedef129cf..16b6731a34db 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -946,7 +946,7 @@ EXPORT_SYMBOL(hmm_range_unregister);
  * @range: range
  * Return: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
  *          permission (for instance asking for write and range is read only),
- *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no valid
+ *          -EBUSY if you need to retry, -EFAULT invalid (ie either no valid
  *          vma or it is illegal to access that range), number of valid pages
  *          in range->pfns[] (from range start address).
  *
@@ -967,7 +967,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 	do {
 		/* If range is no longer valid force retry. */
 		if (!range->valid)
-			return -EAGAIN;
+			return -EBUSY;
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
@@ -1062,10 +1062,8 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 
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

