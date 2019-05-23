Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09B86C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6DF621773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Q1iR9o21"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6DF621773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0A8C6B0280; Thu, 23 May 2019 11:34:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BE196B0282; Thu, 23 May 2019 11:34:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 835BE6B0283; Thu, 23 May 2019 11:34:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3CC6B0280
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:44 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id c54so5659308qtc.14
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=f4j069c7ZUzoxaaL4dTtRuO7XDhSw6R18jQGsXmwSSU=;
        b=XCQWGO0LRAdE+SzaVcpwOgBPyhSVnV8TXjM0tvTIyZakoMYGfSfS1BzFqM9GTED71H
         xaR8mirRDzS0bVmh4Fc1Jklpf2VQAbsLyk/VxbZ1ocgL5vqkxfSa2H2knNkaciSZSfY7
         RMepmBPGQQeexDGA3SotdSvX1r0Jys37SWQ1JfnU6+K7rtPeCVGlUlD96gLEZQyJidaI
         ax0HhyF4Um8Xnt9o4e0EYUVqYAtxdjXAGcDrdhAj1afrsPx5WQGRgmdWOyWb5Yb29F57
         ffU1fl41x6NABlzT8b23virCe+Hekj2LYACIG9joM7rLT+HbE4X+xTrSZXhqIbxMvyAD
         uxaA==
X-Gm-Message-State: APjAAAXkRpZ355/L3QcLNsf91W5lZ33DN5rrVFWJVyWCeuXnYn/kf6RQ
	mdJQwF6c2yoxExjeG2dym+rYdHR7T+Ji6mBtrrwuqyNCWfFwJ0nt8nj0fJ4qHQUHq1VvhyqEGK5
	bxa8jdmjsIbignh1UDu/JSy+DruddujdSxP3erKDZOrpkaofuLtgNsSoDrmOH+ER0SQ==
X-Received: by 2002:a0c:ba09:: with SMTP id w9mr7032713qvf.67.1558625684094;
        Thu, 23 May 2019 08:34:44 -0700 (PDT)
X-Received: by 2002:a0c:ba09:: with SMTP id w9mr7032633qvf.67.1558625683257;
        Thu, 23 May 2019 08:34:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625683; cv=none;
        d=google.com; s=arc-20160816;
        b=lLU7a2s+MJDmFkGRQ8M/r7U7Shoq9HONEj8M6o9pEK8nUefAKy7v7b4it58BM2NBEv
         AV5qPrZeUVPUq7nDDfBoAWpnKebyE76tSkAyAT4gjMMj0rGySThoiyfStkCFVkuCyHsQ
         pIM5ibOPlnGcqbQOwziRY6hzrCy/wZ+pw6yY2RiT3PTcNNFrE/qOmf36w/cj2Ypw6yuA
         qFIFeYZ7Ky81apeyzjcIKQ4WnfoNPAXA+/7kUq9DgGuJkFjazIVPusk29DNdUHRMZFzw
         L2bzXRc/t6tQqLIJ6TnDawnGr4L2UM/Ei/8iYUjmeKNlm69s9zJF/R9fvlGi3IjdKA9Q
         dD6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=f4j069c7ZUzoxaaL4dTtRuO7XDhSw6R18jQGsXmwSSU=;
        b=X+qIPSXighuZ/Y2xzffH5+kw43dGeOCoc8OdBy1kqG5n6l96FHNJajC2dcE6QBMSGw
         4z2JXx/45hs4IA8pkxQcmq0yBwPQ4L/0aJkv1T9hoeZbmxh0q09yRJj9x3XYnIe3EUBs
         tCx7qwiZ9NPdQIC1m4VFVxM/QhPKurgB4jKri3dBCmyAt9CwsWVFo0X2CsIJ2MfCC187
         l9Qh75td063rtLZn4oRfMB/R33t9gxU2Di7aAFSpZj218kRjiSM/odCkmpW320r2DYSL
         jNzMon265cPjzlA0MMXaaDb3x7WVvN7sidHs7qPyYIVsg5aPBjWS4ghnX15ho5nF02uL
         SBOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Q1iR9o21;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2sor35347116qti.49.2019.05.23.08.34.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Q1iR9o21;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=f4j069c7ZUzoxaaL4dTtRuO7XDhSw6R18jQGsXmwSSU=;
        b=Q1iR9o21bGF01UbFLx0luDqo+LhUazJlW9vM4h0+z3TY9W6sEyxEw1R8DRsXKzCFjm
         fcxDLu6fBdQ7+NFUWl/isFjecvb1MU2/EYhsJDaOAM7XH95HyJYuhAmdg/ngedBPOT2f
         A/UL3DDA9lTnFoM9t+t3e2u8hSjSbbYi6FkF8FVBMPrnALhwH2m8B9e+n4RvWRsmYIpR
         VWSYlsfP2MkG7ZigmeiUQ0n1/bZgKIlqHLtsxqRXpvC7SLAUBoMfzAuE7zfXaTtKTa8A
         VGeDoQ8pTFRVKqryBcVNxJtEZ8Cn0TIIINgbBg2xyE45bsPeuNCxS8mtks9fFUZS1sdG
         oPlg==
X-Google-Smtp-Source: APXvYqzldSamHhkoEu6IIunxCJ747qr3gst7TXBS5fLpoamgpQBiEE2VbTR+wtaPARW5aq21amozzQ==
X-Received: by 2002:aed:3a0a:: with SMTP id n10mr82588942qte.145.1558625683002;
        Thu, 23 May 2019 08:34:43 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id p8sm15951242qta.24.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjq-0004zr-6W; Thu, 23 May 2019 12:34:38 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 08/11] mm/hmm: Use lockdep instead of comments
Date: Thu, 23 May 2019 12:34:33 -0300
Message-Id: <20190523153436.19102-9-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

So we can check locking at runtime.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 2695925c0c5927..46872306f922bb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -256,11 +256,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
  *
  * To start mirroring a process address space, the device driver must register
  * an HMM mirror struct.
- *
- * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
  */
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
 {
+	lockdep_assert_held_exclusive(mm->mmap_sem);
+
 	/* Sanity check */
 	if (!mm || !mirror || !mirror->ops)
 		return -EINVAL;
-- 
2.21.0

