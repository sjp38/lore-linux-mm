Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C587C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D38420818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="q54LJoAx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D38420818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B39C86B0007; Tue,  6 Aug 2019 12:06:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9CD26B0008; Tue,  6 Aug 2019 12:06:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A18D6B000A; Tue,  6 Aug 2019 12:06:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56D2D6B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:07 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j9so1205194pgk.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ufYdFo+9XJwMOX62CI8v2zFvEvykN+4LFgKRtsn/jXw=;
        b=uj1TTtP3JuQkI+mskBIUWJmjMTcA9S7/m5o+Fx7hfQoOSU6m3A4bItRJmv56x5MsFG
         NtT+ri0B8nm77IzLmKfKm3Ny/ZvzVe9Eavaxof472ryRD/05z1k0+jrrZFQo8dOd82Iy
         I81QGwZlB5JATak1GbbvVYcw41UbL9ngkRAFaIwqnHMoUIeM9XSPLu9kpCY0U6ZyR3ha
         B05ZrYMAN9PIV7U5IDri2tXtnJkDcVBcGxOXTpITAP3JY6SW3cVUsVsXhjIqTdRlni1X
         AVZiXFK3VBV3SR7wzY6pIujQ/or+kpR1hnxb2MPNrLt81+9oXCIt7JEQC6yPgWkGMoov
         V9zg==
X-Gm-Message-State: APjAAAUndBNqZWW0VrsvTIW4SvVucgieTJq2mGQhUjLZz8o1kTWQK02s
	oKykahl1NlM9Xj2w6im7LJ9sRPFIIGOLUQiARtS3ah+4rg4S/oyYD4MEKBuGFv8BGiLNu882IUT
	P9Ozq5X6ExW9CufYbtpnD/dIUvdzkZ8W23Z44zOKrsitiB672n3FWwNpX9aiyndk=
X-Received: by 2002:a63:2c8:: with SMTP id 191mr3637695pgc.139.1565107566904;
        Tue, 06 Aug 2019 09:06:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/m3MK3AgpOuH7huOS8QGE37ggPOWljBXiOGQ0uATdIop/f0pP3Z98ZYEnn8YUxrt5yOfy
X-Received: by 2002:a63:2c8:: with SMTP id 191mr3637631pgc.139.1565107566102;
        Tue, 06 Aug 2019 09:06:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107566; cv=none;
        d=google.com; s=arc-20160816;
        b=U6jnYgedPUIMKzqjRQsj/W1hnOalwjHBYYjROQm28BQIf7k8Jr6Ep1BEM0nF+AT6wG
         661UNveyK6xsYjtnd4rkMsMmT1ErO/dfLr+iJQPNZrbpKRu/3GHXsC70MIptErHY1avA
         vwchglMW6jKqB9t1yUH1vm7DrFWNzxcyNy8xYZaZ/QNirNmCP0j02RQdJDawTanM2Fv0
         I9aHRH/3d5mgMTMLGPHI+cFMMmDorh4/DkOhHv5jiPtfIgE9AWQ6kdIv04OieJlR3hO7
         4fDCS5Ioxks9KEjAinb7QO4QhePb9Agn3XFaEupGdmZ5GJhjum0BChb7VnmegcyWnpND
         fW8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ufYdFo+9XJwMOX62CI8v2zFvEvykN+4LFgKRtsn/jXw=;
        b=0qrSRVm1ayQq5FzshuQUKDk5vl3P2xuG2+Xj8FEdSC1ylE7s3x7L4KrzWVv4R2VXas
         2Rna48Lck1I/D/YZ+ffs0fGDquC0ETkTHwIkulf262Z5//KKCi1kWxrDB1CqVEXdQYXF
         0T5T1A8omr36Q9YfQ3aaoIqXyeJl6BHT8aii60uw5IMmRpSdNc0QfWOOlHQZ/e/r85Pt
         LjFgpcOmRyuGaTSKkH2txxH09sU18WOn+TEDN9RNN/KPB4n8KEhhRV7m59u8qvTL6jB9
         ZQ924QDrNlK1fMto0ynllJpK7GT78DP9mNp/0irq/xl35LgHYq1TBWgjFZw+2Rg6eAna
         GYsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=q54LJoAx;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c13si42063228plz.242.2019.08.06.09.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=q54LJoAx;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ufYdFo+9XJwMOX62CI8v2zFvEvykN+4LFgKRtsn/jXw=; b=q54LJoAxOoyTjGRyl8D80iZGMb
	lYxNuteSkjzIL5LB2TYkC0TXo+C0bsRy0oaVuqo9j0MlqChurC+FdW3n95QWIEUWw/aLfcWCP06yu
	YXY4J7ATQpT5OS8URVwWNOdqkWOYwNLcl0Hw3gLuN6FJ0B2COSdS/G5yYN5hPpGFTaOp3SSAoAhBN
	qThI/PXzNb6HKEIEt8dVxjuNyMmN3/LShHRtoUekUi9yBJA6s3ob8DsdTaxVBL+x/f2AtJACyVtKV
	r6sws4m88ditq+6B0oyycJeE1GcnQuNUd5x4WojtPgxtoFGkbowjE63VyCmmwr/UBTCy6BBjx33BB
	No0OVtTQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yL-0000WO-Aq; Tue, 06 Aug 2019 16:06:01 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 02/15] amdgpu: don't initialize range->list in amdgpu_hmm_init_range
Date: Tue,  6 Aug 2019 19:05:40 +0300
Message-Id: <20190806160554.14046-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806160554.14046-1-hch@lst.de>
References: <20190806160554.14046-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The list is used to add the range to another list as an entry in the
core hmm code, and intended as a private member not exposed to drivers.
There is no need to initialize it in a driver.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index b698b423b25d..60b9fc9561d7 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -484,6 +484,5 @@ void amdgpu_hmm_init_range(struct hmm_range *range)
 		range->flags = hmm_range_flags;
 		range->values = hmm_range_values;
 		range->pfn_shift = PAGE_SHIFT;
-		INIT_LIST_HEAD(&range->list);
 	}
 }
-- 
2.20.1

