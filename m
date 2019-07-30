Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49884C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AE622087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Rg7K55yo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AE622087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C18F8E0007; Tue, 30 Jul 2019 01:52:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94BE88E0002; Tue, 30 Jul 2019 01:52:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79E5B8E0007; Tue, 30 Jul 2019 01:52:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 464F28E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:24 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id k9so34639121pls.13
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MiAJz6/LGZ9crHwvj8CLjPFMqAcUr7sr54tyumAelRs=;
        b=hvY7MKJIxrRQeLzMfzVrejBAfDryORIe02JNZD1nhHnLOS4iw2bGFfg7Tbec33wjst
         1kS5+gGevXQnNruNTjvHAZwlwfB74UvAtdeoTRitbk9gExz4nulnJtIsjVgGp6Fs7wSJ
         FHbzidVYxTZc+IjM1qJ/ro3qHEseY1SI+CX6YanZlMbNexHft0Wkrybdyi78jdG4JFNR
         uR8qjnWldN+WOBqMuHKpUkOPqZbIrNKrgFgkAjc3pYPin6pyV5aHOp0FTGeeEbQ4HBRe
         Ifty3GXCmcMJkf+XvtpumLpPzwQAPjc7NAGP9kjwwB7D6OfTc326TNHvlpZa2W1oPeqW
         YOZg==
X-Gm-Message-State: APjAAAXwe2s1vcHbB4UkfS26OWNXKoWRnZTdTzs2b64gsSbO26TeRRNP
	fum/966jZ4M2Lf3nK8eA7Ia5COOcrJBT2H0WKsxfg4S2KUeu6yzjHOaAsP7xD1DftbfnT0P8t6j
	1h6ks6mbWR1yxdDgVf+C4VSV+J+xz4uXfzeWccNUaBPTwdIBaFz1Oa1N1Hqb+VIY=
X-Received: by 2002:a17:90a:c58e:: with SMTP id l14mr114716537pjt.104.1564465943989;
        Mon, 29 Jul 2019 22:52:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxj+SFMAb+37fUb5DzecxZE+7eHnr9lXjq5EO/aIc4AhSmsdARQSVCtOGUbZra+d0S/Hwnz
X-Received: by 2002:a17:90a:c58e:: with SMTP id l14mr114716498pjt.104.1564465943179;
        Mon, 29 Jul 2019 22:52:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465943; cv=none;
        d=google.com; s=arc-20160816;
        b=rymTk66LHoXqPxM1PbXWEvvivD+EDQ0eZ40e8sQuDe5WfRc9Jjs/ParcLhVzhxEC8v
         ddALHvRIfy8eH3xGMS4MXOWpIYyK5W33Qmkb2vpyZ+9oOoYjUAYqnPjbt9yANAUm63nH
         hLedFuIR+cLpn6MlIxhpFgFhIKxJ8NWM4GgEH1f4f0qg79BMEsTMZkDvuQ8SCYEIivUx
         by7tU4oKKGFrZt68Bdj7DMxLqjZ9OI0tmw0v5Xr7SPLmKVGotUEGfxxR6yKg4u+nv7d3
         aE+AMl9qKOEnXINCS0cE55+8aCH7WUFINVU7V4zu6KhjmQJ+VTvQQ+qnibNQuogjsJHg
         LZ4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MiAJz6/LGZ9crHwvj8CLjPFMqAcUr7sr54tyumAelRs=;
        b=AnOT7s6kHC23YnPculaMSz2O05WuH+ulUST+yGzeJPeXJ9Ik5xHxLEq9dcnTxCQ0uO
         4cbmVpquB/a2ziZhiuGuAzbOYBRQsJmb9oXVU97fpi9O5OyND3zbG1HB0jdD00DUuylM
         F4jT6oY++Oj0hh0dYMcloZkimpcsN1ynLc+8/tYcDeIe9RjxvWRhwe76tQ4X1aqxzIBZ
         90bhfAlkB8snImRTUS4sjV5zJ7Kpy0bU+77wMgYp2OKOK5UKs0MwVCmrXeGF+AxLxTPq
         vPvPbM3U2fL5pqwdNjwIPTloRKisuOXBrkCzbE13NFPcdFzDH1q5ygtdWoRmuSzCXkUD
         aYmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Rg7K55yo;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c18si27689394plo.316.2019.07.29.22.52.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Rg7K55yo;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=MiAJz6/LGZ9crHwvj8CLjPFMqAcUr7sr54tyumAelRs=; b=Rg7K55yowl6k/ZPgtgKzOFotco
	EVRGBimUYALuPVAK+Kd0lIYGAgz8qtzz4r7Rt2jsMd0MtpQWT8xWTjMhSpjmP6B+WzSAt0NQxsH3z
	+abmLHxfsepvGEZ16JG88WTk4KK/xmmi/835FUkRt3rJXl5jFfuGcN+T4XXHJZr+nfh2bJRDlW3PY
	pEOwZbQr5FVYHNr00EG+63WsoZ6aeTTX2HHITa6njQqVgFg/XDoSqkAj0N5KDOYMSp9n85MUhgF5D
	whhEQ2w7Jug4LOPnVeW4QA+7KPrsRNLvw5OSVDmss722pMK5UEW5tPkequZrhaCLygy8OXTJOT9po
	zeDCXljw==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL3c-00015E-DZ; Tue, 30 Jul 2019 05:52:20 +0000
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
Subject: [PATCH 02/13] amdgpu: don't initialize range->list in amdgpu_hmm_init_range
Date: Tue, 30 Jul 2019 08:51:52 +0300
Message-Id: <20190730055203.28467-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055203.28467-1-hch@lst.de>
References: <20190730055203.28467-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The list is used to add the range to another list as an entry in the
core hmm code, so there is no need to initialize it in a driver.

Signed-off-by: Christoph Hellwig <hch@lst.de>
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

