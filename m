Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5E6DC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F50120663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="c6rggi27"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F50120663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3ED48E0002; Wed, 26 Jun 2019 08:27:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCAC38E000E; Wed, 26 Jun 2019 08:27:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1A1D8E0002; Wed, 26 Jun 2019 08:27:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB218E000E
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:49 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s22so1369740plp.5
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0wBvIBHex+/cCiI1pboKPdW0nxKbhC7t4v1/DWHTWzI=;
        b=fASdm0kyePj1rBWkOsZSkTw1qCTzpwg7Pa6Lju6uiHQvCFDAEqvyth3DxvW6MhE69y
         /tQFu3ye8J/BpMw+Eaylh6QUK2IXrw6cFQeUXARx8MX0JdG21DLEevQmwJDi4jyDTW9N
         fRHC3QE869HFi5pZHjT7PQQigLOnMjXmk3TmMho9qtwRYufFK3LGfiE7ocJEIW6nRJjQ
         8Bzxwyt1SKkjgYL6kedpv5NqybTX8uoTY8U+91sJ56TenhcIrC9g7Ka4L68ZDIHedQV6
         +AIyRAfDLI5g6ioDwN33+ZiVw2FZ1Rgupnzxg+K4ZO8dxi5RUtAAjCCIxLnddwVy2utu
         UBWg==
X-Gm-Message-State: APjAAAV5Fh8/d79OcFhSbJk5vXpVzgubRRA5vCwfMqh0iqn4JlppRl2J
	jdV17W/z8AQPJE+9rq9hafyJnXsKq1KyONtVaxLDxvoVeQoKuFa7NB9srnv8Jx+8l9xm1BAglZE
	tTZYfPhTD6e9HKan12Nw7F1xz5jQ1TDfH8ySpjycCnxj23POK26LcfX8zZY1fKSY=
X-Received: by 2002:a17:902:148:: with SMTP id 66mr4887873plb.143.1561552069137;
        Wed, 26 Jun 2019 05:27:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5CvElvTnZO4eZDbsOfTyv+Duvr3Mcruyoh84hVkZ6EU1S1Oi7zO6KeZ9FQL1CsV6zOytn
X-Received: by 2002:a17:902:148:: with SMTP id 66mr4887823plb.143.1561552068488;
        Wed, 26 Jun 2019 05:27:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552068; cv=none;
        d=google.com; s=arc-20160816;
        b=VJE8HIh3rtwkydcU//ntEUwOslHnNpG42sAZjHxCIR4o/FrPaZTrv/S+ad7FdFony+
         LUqlfL1HQ0DHU/BJigMQGZ01wlj6TbADXc6r6PaIiyVbgZvSRTaXXCW8wQhRHyyAS90J
         Z3cIoCL6JRgzQ/aQJ8UVsECPxRalaXhOZx8BGm/U8kXYfc0231yjA4WDklVptg3lTg9q
         W3wX5k6Z+HTyrwzCKMRGAqsMIpRewyVl7SiqaNF/3xHRi/SHWxEtMaNFb6WFdsN/oRcU
         G8ySOKbNHN3qMQ5fi9UUtZ9F+s7XaDcJuO0SWpKk7/g2X5VunVktqUjI0sjT44fi/TMp
         mPxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0wBvIBHex+/cCiI1pboKPdW0nxKbhC7t4v1/DWHTWzI=;
        b=x00TftyMCayLHObcSIFngYX3H2cOCRQM9RPVUnmwPxSQ2lHc68E/z9//bhu3zxc47h
         sIo7GNwvg2Ls0obxAyCjTvSAJAgdyxnxi/e2f2NqX+PVUSPOFYLlhLuUjWAc7hrHK3G/
         q0l2RDaXjKZUAu7zcAVFfpRdNhVIZQfRwrt2+F5RnVwB6yBvORJubkkPKAv/W0zHUVzk
         4Xx1aM2q5I57vZJFm4m1nT3D0MsHfp1oqoZ2IZB4L7Zlf2GjheXBqT8bv4iSC56MQfX1
         u0eC309BASwMROxkNh0HjL0lhjy6TowVcoZ/qkdy3VNK6UvG/2Njbg/G/MTX4OCy+tMj
         R9GA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=c6rggi27;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v16si17728768pfe.39.2019.06.26.05.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=c6rggi27;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=0wBvIBHex+/cCiI1pboKPdW0nxKbhC7t4v1/DWHTWzI=; b=c6rggi27+6bcNfZZv1zIRlyPCG
	dTeW2W12t37x3woY9zWdBtIsP4n1E9dw47beifpdnx/fz2SnFKoQs6M0ObFbnzav7MGUD/YXjCZ/Y
	/nrVNGsZF9j5DfrhyO6TTdGG/hzYaJp6AQ98WUFsFTaB6Ol4fyNoNVg8mhvpvqgaxZEjbFL/UASiZ
	/3sLgB2UV5SSt6KHctKLOsDSch/tnc7UKteZTeFrWqxh0JqkYe6iQjKxxaOZL1CYQ9QXxFMmVhNNO
	27wXVoCLF43f+0c2qpIsvN2eFaGW98w89wJCDa2RWtuWV5oIL49PGwubBepu8AuvptmiewrxjXd5v
	6kqTr2hA==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71Z-0001Lv-4k; Wed, 26 Jun 2019 12:27:41 +0000
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
	linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 05/25] mm: don't clear ->mapping in hmm_devmem_free
Date: Wed, 26 Jun 2019 14:27:04 +0200
Message-Id: <20190626122724.13313-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626122724.13313-1-hch@lst.de>
References: <20190626122724.13313-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

->mapping isn't even used by HMM users, and the field at the same offset
in the zone_device part of the union is declared as pad.  (Which btw is
rather confusing, as DAX uses ->pgmap and ->mapping from two different
sides of the union, but DAX doesn't use hmm_devmem_free).

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 376159a769fb..e7dd2ab8f9ab 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1383,8 +1383,6 @@ static void hmm_devmem_free(struct page *page, void *data)
 {
 	struct hmm_devmem *devmem = data;
 
-	page->mapping = NULL;
-
 	devmem->ops->free(devmem, page);
 }
 
-- 
2.20.1

