Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83839C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FB2A2084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cb4e9uP9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FB2A2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A96D8E0018; Mon, 17 Jun 2019 08:28:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 798168E000B; Mon, 17 Jun 2019 08:28:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61FAA8E0018; Mon, 17 Jun 2019 08:28:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E25B8E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:29 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z10so7646978pgf.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=a9DxKrjk6QhfPonTyrF2mzugaowpnIicUuVlQP+zq4o=;
        b=CXYdy3M0Ir84E1BSeyuCVXsja78fcfroDFXh1KuMIzpt53z3WbPKVSD2mQ+qYbTVkr
         aIvo+yyh1Qu2cx8nTuV7fee8KzDRGhIcG8MzCT1dHNp3Ym4+Svb+maDTCp/Mf+gUxWMw
         3nCeljzVHN0dp3esw/N+wRfSVssXfk3dI1DRrOfEeutzQb2MxInFQ/yvlibNn/6vAG/w
         2R7c3RbkKIqw3EGzjn49hsq0Yv4IpmVSePcwSYxOLSRFMKIWLTefwMUQxz9O9UKv1AYU
         n1zGgsRTy7a532LSs2j0oFOcWjZ9VV05QDC8s0EDVkvjgSygl5snaRt4vCzL5ZsBQMMS
         K3Kg==
X-Gm-Message-State: APjAAAXbpqWR50uc/cXlcXqw3YE7kh/1cgniVScZRPGc4voeA9r/HhS7
	hZW2lyzyQxjICBmStNY34NkpOjq9LtX8VMmHTMiIY0ykuyBXhbi1MWbUWqfJdGMw9Nu22ahdoVV
	IqUhQYiy7MCsBs0SnFbLd4bdJQUzdQjceTTN46n2UJfglm3crLSw8nMKtSjfbzzk=
X-Received: by 2002:a17:90a:22ef:: with SMTP id s102mr26702265pjc.2.1560774508866;
        Mon, 17 Jun 2019 05:28:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhz6XGz4YL7urjKA2gulmYABHmJHnXwzE9TkkVJS9SFB2sc/QJFuvLbic606q0dHk7a3vI
X-Received: by 2002:a17:90a:22ef:: with SMTP id s102mr26702236pjc.2.1560774508275;
        Mon, 17 Jun 2019 05:28:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774508; cv=none;
        d=google.com; s=arc-20160816;
        b=m5x/WK5r8sHJI76T4I7486R0v08RSq/fxLZ46+E+2TTtIPP/dXvlZGavUER48IhFY6
         XIIFi2AIlw3glurr3RC1ola3diJ5Xskqc4ihOTywqMRVlETHAopcIPUrLC6Nz7E9e3LN
         iAh0hJHhDOoDy5O0nbCXfqeMTMaZaV1wt96F6pJmxUjs8cqAXKZOb1de7jA2TipAmANO
         R/RcxeWJadftTdLrFP5Zr8h7EEDNWpRo4Qre31XJsg06rjWC0MinL2kc25GhaoNtxhuf
         Yhm7W/99kQOiMJ/zh486//PvS56PUjjYR5dku76usGCAOhzZnGlwcap48dgzUQ1YNFab
         Szng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=a9DxKrjk6QhfPonTyrF2mzugaowpnIicUuVlQP+zq4o=;
        b=NdxfNX3nl0boZam3Q0YFK3gE9hnsKExD+sw745m8/yev9b0UodwFAnQLbasXsWSS66
         Bww8jP2ox1rRekJtuLCxkmQHzzKRaVBQizAqF+EoG+TdKERVX9duNjchR5vMa47T5JVG
         nsXxn18gOFWMgimkG2V3IyuigW2ZjX+XTXL50AhWieG0V9vioD+FFNKMqe5Tnmf3fkN3
         jnsMii9YJ51lK1UkLvyM5btyXURuPupTC6aDHce9m6GUTwMJFWBltA4OuqB2GpZvOreN
         1M7APgbRYXV+iTPN+rZ5n6wJyOSEWYwbgL5cqpnOawp+j3S8X1fZjwJH889Ivx/OfxBJ
         qLUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cb4e9uP9;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p15si10997340pgj.191.2019.06.17.05.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cb4e9uP9;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=a9DxKrjk6QhfPonTyrF2mzugaowpnIicUuVlQP+zq4o=; b=cb4e9uP9535wnLLOSnyqggTl8I
	82wOdiYWnYuuZDAUgSyu83ySmcMJojBjfZpU/s/pwummAkreTbFbiDHxAlfmBp5zlGTCnvwaEkK/L
	m1+oWm8zfvKdQd7GjZ0w1pVZLn03vSyh1IoQL4nXiuZP60/CtR4bs0Fm58kSyrWF4OpfS1kgWP6tx
	YnPl/xrcUiJCqrWQhwC7a/lCoLnzRnV06voZ+USZ2cbZhzpOyPZZwkkTeqQsbHiFvOxIVh2073+QJ
	QM/0SM6iEz4vo+RuWl6T+Yc7bPyaPv8+xdh1ViBq0agPBngSwftA/sRBlGXYsGYx+CFcC1b9d2sia
	w6ZGeIZw==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqkJ-0000Qu-Su; Mon, 17 Jun 2019 12:28:24 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 21/25] mm: mark DEVICE_PUBLIC as broken
Date: Mon, 17 Jun 2019 14:27:29 +0200
Message-Id: <20190617122733.22432-22-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
References: <20190617122733.22432-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The code hasn't been used since it was added to the tree, and doesn't
appear to actually be usable.  Mark it as BROKEN until either a user
comes along or we finally give up on it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 0d2ba7e1f43e..406fa45e9ecc 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -721,6 +721,7 @@ config DEVICE_PRIVATE
 config DEVICE_PUBLIC
 	bool "Addressable device memory (like GPU memory)"
 	depends on ARCH_HAS_HMM
+	depends on BROKEN
 	select HMM
 	select DEV_PAGEMAP_OPS
 
-- 
2.20.1

