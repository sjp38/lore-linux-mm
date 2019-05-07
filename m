Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 864B6C46470
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:10:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EFBD214AF
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:10:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EFBD214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2D716B000A; Tue,  7 May 2019 20:10:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB3FF6B000C; Tue,  7 May 2019 20:10:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7AD16B000E; Tue,  7 May 2019 20:10:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CEDE6B000A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 20:10:04 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a90so10331788plc.7
        for <linux-mm@kvack.org>; Tue, 07 May 2019 17:10:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=W6mjT0eRfCwfLc+G2YCpsPlEeRwl807aZwyCVJxSnaI=;
        b=oRCdgABVztA/NFEAxObfzZDRdrjoVrpkMYA+wLlf4Hw4v+Xt/ea2dASbrN2Kwh7N8K
         P+zd5auMTd6CYZru69DFe7X86Dc7ZuKaBNBRoq1f2KaWheQNvM7bOu4QVuE/w/pffKNb
         zqjsQLaunuqqzi3UDoOCnSoGJwUh584ZUFdRhJLMYc0J9+2Pq1X9I75RNY90hPbvdCbM
         kuuZm+vXBdBUlPvPjHdmmGI0CMfesatzK5C9JkN9QrM5DEdHaQJ+BodLCWi5RcbNOGub
         ulWMo/RtdgTb7BfFFGcdbovDU6UvJ8rmfVXwRpMsu23aX1oeC87FcFFm1cynTPBChC+0
         MluQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWup8JvVpvGSGU1eEizxoy6xUngVCT5zLISZZgs+909j5MULV8j
	9nWF98fij80TfAlrCpc5W2xbzIbnV4xpeQWDojMWChatk8u8Za9WxlSBeuSeed0nLvx7Dj11yiG
	JAxSGlZ8YmF0SuE4AYe/e4m7dVvzcp/An41rXqr39Yp4HV+3uvA/gOkHw+TRMNTxQsA==
X-Received: by 2002:a62:1ec5:: with SMTP id e188mr45388417pfe.242.1557274204171;
        Tue, 07 May 2019 17:10:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpOt8lqHoMGTjz85m67yFEueLy+oZJd+tFF2kNST4RExQA8G1mDl8aB1XOiRduwG3xxjAP
X-Received: by 2002:a62:1ec5:: with SMTP id e188mr45388335pfe.242.1557274203238;
        Tue, 07 May 2019 17:10:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557274203; cv=none;
        d=google.com; s=arc-20160816;
        b=br6fDSzAtBsls+RwT9Zle0A+toi5tC7sG7ynaBwRKyiu91qhzqezmTvXZ0Nb+syAgq
         NO+sC+vMBAzQzLuB6R81zgi/lFn7eTZQxA/WEp2GuA+ERN4sv3c1zb3IlbVnb+gzGhUh
         +Z/OXj3Eak+zCgp07U43R1jr6ytjxuRWameAdy5Hl9C34Yn+mATHbf/KYDx63+VGxx8e
         EFCeOxcx5BsvO/dc1u0ckVcfxN6vjygyRkPF44+gyRyDDe8VLxdEUnONeWEVIHR6SWQH
         Rhl4cYiDrpI/5wKljhJB/+ty8TGkv779KRELI4hyYpj/+Zv5CHMwTzeQGsPXSO9YNF2Z
         uq7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=W6mjT0eRfCwfLc+G2YCpsPlEeRwl807aZwyCVJxSnaI=;
        b=LB7xxMFltj3u2ud+16F1FQ3xUVLh2WR1CAqlBYtQxkfk1I2Ez8QYpCm0VbIBMGGxhq
         6igNPncevLxxu+J+mwfwsUz3SOx70qHbWl7FbnXNLlXOR4bd/4tbfQhB/Efn7ndd5Rwe
         +fpE6pyjeZ1duxE+677Rz7O4iZOU1XMLJtE7RAbnww/lXMyzVJFRmAVtpT5z8rjBzRKb
         T1uF4L1ihtAgTnB6jrJryXgqd8ZRGC3QgqnJb1yoT6lPOnv4ahXmbdO5dGP1C6Obr3wl
         2sFBVGPj9+nUovSbEwv2SdjjA4ayq5MLvMn5B/w5orIy9xeEM/8N6ZUQBiU5fdgpndOa
         wsLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 10si13164298pgm.332.2019.05.07.17.10.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 17:10:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 May 2019 17:10:02 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga001.jf.intel.com with ESMTP; 07 May 2019 17:10:02 -0700
Subject: [PATCH v2 3/6] PCI/P2PDMA: Fix the gen_pool_add_virt() failure path
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>,
 Ira Weiny <ira.weiny@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
 linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org
Date: Tue, 07 May 2019 16:56:16 -0700
Message-ID: <155727337603.292046.13101332703665246702.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pci_p2pdma_add_resource() implementation immediately frees the pgmap
if gen_pool_add_virt() fails. However, that means that when @dev
triggers a devres release devm_memremap_pages_release() will crash
trying to access the freed @pgmap.

Use the new devm_memunmap_pages() to manually free the mapping in the
error path.

Fixes: 52916982af48 ("PCI/P2PDMA: Support peer-to-peer memory")
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Acked-by: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/pci/p2pdma.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index c52298d76e64..595a534bd749 100644
--- a/drivers/pci/p2pdma.c
+++ b/drivers/pci/p2pdma.c
@@ -208,13 +208,15 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 			pci_bus_address(pdev, bar) + offset,
 			resource_size(&pgmap->res), dev_to_node(&pdev->dev));
 	if (error)
-		goto pgmap_free;
+		goto pages_free;
 
 	pci_info(pdev, "added peer-to-peer DMA memory %pR\n",
 		 &pgmap->res);
 
 	return 0;
 
+pages_free:
+	devm_memunmap_pages(&pdev->dev, pgmap);
 pgmap_free:
 	devm_kfree(&pdev->dev, pgmap);
 	return error;

