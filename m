Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BEB1C004C9
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:10:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FEBF20675
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:10:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FEBF20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA38D6B0008; Tue,  7 May 2019 20:09:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B532B6B000A; Tue,  7 May 2019 20:09:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6B166B000C; Tue,  7 May 2019 20:09:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 70C3C6B0008
	for <linux-mm@kvack.org>; Tue,  7 May 2019 20:09:59 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f3so10316947plb.17
        for <linux-mm@kvack.org>; Tue, 07 May 2019 17:09:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=rly5zRrCSESMX4aeor/m6oZVFemBQhV/3bqm72CMmro=;
        b=evZAC5d/qg/tbJjd9o/3TGPnt56Uj3OdKt6Djw/+YnRnttXDhpdcfL8MaLN+lesv3z
         LveaQHyqFI5qAlPRCv7BiQF1S6GIlfOCMpY2Fo4IkHZGKYz/P02slPV6Ob9qvvM8I08k
         p58VM+v/K0XkDbSVe0hw0mNjc2hyro7FhkoVIc0KNYComzol3rYTYtO7WkqCaWwU8cY/
         BwGfdGcStsClELZQsC1WLGgGhIkQrB4sJuItf3jhzhiCRWEMzkaj19YEMbC+hMBHCvVd
         0ev0cOeFo/ARdkBxVX4D1U1CwiM0huMtgPZrWL0gqZVHzkfCxJKtmA75FZM4A6GPhkti
         IKNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWWgq3/F2cW87g+oy1B3JCGP1mZHSLJ7urOdaBxd7zfTjPc4mXL
	hZ7N474qesdHEJFYasnOuxDA1TXRfbdL0fPVk1FHhuuKm2omT9jtDQHVBnkqPusJzma6kj8+OPh
	n852+7kOzMjP+mayfJcqXGJfCrK2KIO9Hqv8iDWHy9ST/yXJ6uGwrUyw0xGUL1ZdCfQ==
X-Received: by 2002:a62:1d0d:: with SMTP id d13mr44869428pfd.96.1557274199121;
        Tue, 07 May 2019 17:09:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPOGVo3nFokpjOzBT/S1s1YhcIDRT9V96XyQ+LfHv+Z7Yf0dbY7P4tmkkJlYMSH7j4J3JY
X-Received: by 2002:a62:1d0d:: with SMTP id d13mr44869353pfd.96.1557274198127;
        Tue, 07 May 2019 17:09:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557274198; cv=none;
        d=google.com; s=arc-20160816;
        b=JayrvN/+XTB1e/gl9DutF70zEhapyObC0I3RhqU3GG/tzQvS7hrrrl/HZPO1fAl9cQ
         tu2ogPCGauTrL5f/oQR9uWmfYWA0ZclgzM+4xTJ93cVbMMMg2kt3zOK6GgM5X5QZnGUI
         K5zsOw/S5znkMqgxrNkD0MBBR4Ab8wrERxY/4Qn3y7W77mdARF4JX2d3NZPZnSOc3rgm
         klNqXBssVtfJoQ+juHrXJObgErBJ30/MWwN58fa+hidVP9l2ktjQb/0Ps3C2MTE7nmOO
         Z7K4AfpAaEdFRPCFQyixlcyO0HgJeTczcigCKdkMvddRjKlVuePEy9nQTnuvWWEQ/+qy
         hJ1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=rly5zRrCSESMX4aeor/m6oZVFemBQhV/3bqm72CMmro=;
        b=THYb4QIKotpZjgOk9SCJ7jR/hx7hmElhnT8Jc0/G03lZobUxy24ipZ0iywJ/2pChs7
         NaJh96ARtuitbpdeDFzIdOSycK2Y97U3dDCtSxbLX5v/hfy+XkmpSPb8RIIjGt3CMtoh
         wPd7X78L4AuoDMY2kPHWLZk/6PnsrKo91s1Nk+H/bii2u7srvTcsn6vHwsEbyXEadwq9
         Yv4gDQuUmSWOxtSIQ0kuQemRahOMoko53s1UzTR5SEueJXs5/I5tVzVSV7wC4OhCbOl7
         YIIANqxwUcWSrOq7ZHcsF4tcdQskbABASwmWOXhH3ebYx75s8GeTkqfXTO1xl5Geq9IF
         QlyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v20si13622756pgn.266.2019.05.07.17.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 17:09:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 May 2019 17:09:57 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga002.jf.intel.com with ESMTP; 07 May 2019 17:09:57 -0700
Subject: [PATCH v2 2/6] mm/devm_memremap_pages: Introduce devm_memunmap_pages
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>,
 Christoph Hellwig <hch@lst.de>, Ira Weiny <ira.weiny@intel.com>,
 linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org
Date: Tue, 07 May 2019 16:56:10 -0700
Message-ID: <155727337088.292046.5774214552136776763.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Use the new devm_relase_action() facility to allow
devm_memremap_pages_release() to be manually triggered.

Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/memremap.h |    6 ++++++
 kernel/memremap.c        |    6 ++++++
 2 files changed, 12 insertions(+)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f0628660d541..7601ee314c4a 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -100,6 +100,7 @@ struct dev_pagemap {
 
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
+void devm_memunmap_pages(struct device *dev, struct dev_pagemap *pgmap);
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap);
 
@@ -118,6 +119,11 @@ static inline void *devm_memremap_pages(struct device *dev,
 	return ERR_PTR(-ENXIO);
 }
 
+static inline void devm_memunmap_pages(struct device *dev,
+		struct dev_pagemap *pgmap)
+{
+}
+
 static inline struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 		struct dev_pagemap *pgmap)
 {
diff --git a/kernel/memremap.c b/kernel/memremap.c
index a856cb5ff192..65afbacab44e 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -266,6 +266,12 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 }
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
 
+void devm_memunmap_pages(struct device *dev, struct dev_pagemap *pgmap)
+{
+	devm_release_action(dev, devm_memremap_pages_release, pgmap);
+}
+EXPORT_SYMBOL_GPL(devm_memunmap_pages);
+
 unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
 {
 	/* number of pfns from base where pfn_to_page() is valid */

