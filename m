Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE12FC5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 613BF2146E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MG3bxxRo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 613BF2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE8C98E0008; Mon,  1 Jul 2019 02:20:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D72F16B000C; Mon,  1 Jul 2019 02:20:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEC158E0008; Mon,  1 Jul 2019 02:20:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f207.google.com (mail-pf1-f207.google.com [209.85.210.207])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE066B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:49 -0400 (EDT)
Received: by mail-pf1-f207.google.com with SMTP id u21so8210123pfn.15
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bXqDiAvJQco6LqrLgE2xZQsqez3vWo2ZZ+dsCe1H1Ss=;
        b=sDNconEPRJXp0sWq61SbxBUNft5PL2hKKKFX4IIjAT+PxF2QK9JA70DRfTDwauw0j2
         tlbyJTDO3py2JZdkGsW+NXzXo6atMtf850oP6gvZMXJynmM4RaZSev5R2hjHc6McGg3g
         fNP2XKz31M1ghKskh5OByb9MA+k634Km9IVHlKVh8gPHZlQCtl3FET+FYMZbL21VSgx5
         pfaYzs7uVUpEKKC5gnkAXDaqR9etr3Djij9P9HTRcTjIic4lhap79JMY0JtYGqN5XbEa
         ACG99xENe79vYTNiPSKfsfwQfNRTuRk5wotldiJN+GJxRfLihkkV3J1jMJQBI2GTI+w4
         LDqg==
X-Gm-Message-State: APjAAAWKXAkKBv9+RteX18IkcC83vvjlcvztZCcrIOHTorXaFzaD6lkM
	X76jk5JwXFe7dWe9BcFnUR1azFHzd430Hn7tSPUHo9wiF2dfjKGuD2TcnY0+hkffbIdH7z0U3+D
	rKo34ALj+6QqwqSHUCQCCvIzUg85hhLjA98L+IGyiUmoCHqNGkwkXFSvUWzJnMSA=
X-Received: by 2002:a17:90b:8c8:: with SMTP id ds8mr29612548pjb.89.1561962049186;
        Sun, 30 Jun 2019 23:20:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6x7oqC43o8XgMibvPlynYFYm3ZRQq4j7CLtLw34GfDALWztg9YG+sj5fouYG4YOC1u1Io
X-Received: by 2002:a17:90b:8c8:: with SMTP id ds8mr29612480pjb.89.1561962048386;
        Sun, 30 Jun 2019 23:20:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962048; cv=none;
        d=google.com; s=arc-20160816;
        b=JYXBwz7QdGjrk/eNpPifLtZEdDa+ejkfZLSRHvD12cWVtX75bwTKH/FV21o0ek71nw
         XjE3LGMotfLKzK/6dBMDtYTphVQ8z8VoCwEweb48FFS/93d2fp67izcZoRRGOn9kvMtj
         zm4ntv1vlvMmdksOhMPRXjw/Rpz1FiLKLWu1/mmEXK5WqxqqKv3+3m/xUz9/8HnVGDc8
         M3LvPvm+tBXAvh3sxqXiCtd6awa4a4W1LP/1fqe3WhmrBc71mWmyicWasTHwGXOXjjOk
         QD81HEpNzIJ1joG3qd09qSP2hJVHoPu+rziPyMVShXzGGHbHRNbTf8K7XEXp43nHh8X0
         rXCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bXqDiAvJQco6LqrLgE2xZQsqez3vWo2ZZ+dsCe1H1Ss=;
        b=G4wTOoxOY4hg/mOTnwAPIyv7IcpWrEtCBIHrX/0R3R8DqUw/4q7jsblg4npj+h7bQ3
         Xs9v1JbX9DQB+fIPa1Ib6lHhtK+PoE9Kf6DUeZIAK0U8u/VMVkwdu7DXKKg7K1fUT10H
         qSWNBrjvyLgf4109UP+fK4uai6Mt63dKwBZaOljel4pHu3bQsdANyHxqZwA9J4LgIeL/
         j6f25VJNvfv1kEGAKq1sYc5QRd/QpiSouNjkDhvVLPozMYMetPmBR4XKpVK4ZSLyhIAO
         OvigD8iToZlTHWeXC6CHS0/M4IDbwd4iuss7oybubLQdcrbgKv37i9Z+rV9EpmvXVy6X
         3xSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MG3bxxRo;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id cd17si9790628plb.210.2019.06.30.23.20.48
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MG3bxxRo;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=bXqDiAvJQco6LqrLgE2xZQsqez3vWo2ZZ+dsCe1H1Ss=; b=MG3bxxRoYFqyzGKH+nrS8kwcHT
	y4aRjpQDTsEzCm695PnLVWV4y3Nrb7KXmkZHwkZH2ZSo+YGrZHifwDp5/3N2Q85v6ZTpB83rmHwSW
	2ZYA10EnLDTDWXHbqkWUJeCn12MZ76qYKsC8+eAoddv6/nO+8gFJtGrc/IScul0oIOi3hf/6zHlwR
	rA11CIUIt645tmGyq0jk63+C0aXj84m1y56+nvvBKt4o888CTQnsLXmPb0sMZMQWQabg0JYeoJ6lX
	YpLjzVCN9DpjKikQ+fmNMiIAg0IoiKxuPWZjAs+0qiOKMAUokvMS59FUFc+SETnlDJlxowjQF7kaz
	87AtjB8g==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgC-0002z3-Um; Mon, 01 Jul 2019 06:20:45 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH 10/22] mm/hmm: Remove duplicate condition test before wait_event_timeout
Date: Mon,  1 Jul 2019 08:20:08 +0200
Message-Id: <20190701062020.19239-11-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

The wait_event_timeout macro already tests the condition as its first
action, so there is no reason to open code another version of this, all
that does is skip the might_sleep() debugging in common cases, which is
not helpful.

Further, based on prior patches, we can now simplify the required condition
test:
 - If range is valid memory then so is range->hmm
 - If hmm_release() has run then range->valid is set to false
   at the same time as dead, so no reason to check both.
 - A valid hmm has a valid hmm->mm.

Allowing the return value of wait_event_timeout() (along with its internal
barriers) to compute the result of the function.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 include/linux/hmm.h | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 1d97b6d62c5b..26e7c477490c 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -209,17 +209,8 @@ static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
 static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
 					      unsigned long timeout)
 {
-	/* Check if mm is dead ? */
-	if (range->hmm == NULL || range->hmm->dead || range->hmm->mm == NULL) {
-		range->valid = false;
-		return false;
-	}
-	if (range->valid)
-		return true;
-	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
-			   msecs_to_jiffies(timeout));
-	/* Return current valid status just in case we get lucky */
-	return range->valid;
+	return wait_event_timeout(range->hmm->wq, range->valid,
+				  msecs_to_jiffies(timeout)) != 0;
 }
 
 /*
-- 
2.20.1

