Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 314E5C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:40:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9E352075E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:40:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9E352075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DAF96B026B; Fri, 29 Mar 2019 11:40:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 960246B026C; Fri, 29 Mar 2019 11:40:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D8FC6B026D; Fri, 29 Mar 2019 11:40:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 444AC6B026B
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:40:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b11so1723946pfo.15
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 08:40:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=bfbRtSXnvBNgnAga55D234OHrkN1o27J7rPg1iia1mI=;
        b=MYyCGEZKZEuo0s5YQK9kCeR6QnQeaPuVoURNwwotWBh3Z5kV+YeCZ5pAVfOh7vhcU+
         UJxp68iYQxntjUs/Ix+0weeUmq59U41uY3HfhL3yqoTCQKcD7iJ4X/6Hva5mHM0MHpal
         5gG9jkhwGod48whgRtDg/zBiw8R1yw1d2TZ2o8qyKMBfLFCso94wlziusnSQvnA72gxW
         VBQ6nM5Y9skN3bBJZxg7kvbQykIr3XqlLSBoMZbCQNpdVDd4xxkkuF+ymcI7J/Hm7L47
         WjPfQTYcRi2b8QPi86Hx0+JT6frBedRSD9iT/EWQ2c8YZ3ISo4h2nBxWhmL6MZzkNcME
         Asog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX70ij+0BH4pVqnrdVC+1fEGaw3AlU3WTzuTV5nCLQs7KJpNkv7
	MZYg/CDl6uA2LeA0qQp8JkYi39WDdOyUdXJ6fu7Ce7h5/8UJKD4/SFTtp7+RDL2mtoHLVcdzfe+
	URuKO8MeJV2Ps53mkHYyyIei7A9rXRwNiOgUFY0MIv+ErdrLvzpHTEV+jFZo2nREZcQ==
X-Received: by 2002:a62:ee0a:: with SMTP id e10mr29454917pfi.6.1553874014958;
        Fri, 29 Mar 2019 08:40:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7OsovC2/2aORHtoP97Krg4GVRnslY8RBz7yaxhXou1zzhUXZ/C85EEL1Lz3+Jbv7+TwT5
X-Received: by 2002:a62:ee0a:: with SMTP id e10mr29454874pfi.6.1553874014306;
        Fri, 29 Mar 2019 08:40:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553874014; cv=none;
        d=google.com; s=arc-20160816;
        b=V77H03eLi5PJvKVoaMHCG9K31E+lrKqpP08z/RBkt1tDP75Cx1LLE85/7XGihkK/sP
         K0JoWoRk/ijHsas/yKHZ1p9VdBUdKQ+aBtnExl8IUTwBFFdvk+qbtqUMIQSogNZY38sW
         aV8HnTnuD/XA4l5ggYOphJ8Xl4PMPcoEtQ0nKTxi4lXm6wzxMHxGphLo40xALjQrcVZP
         CraKvufaGJjKBoiDOQQ3ikTrQNpeWyT3Z9tpHGd3R+9ki5bq5dNCzVGCluG0f4gGaSqu
         FjvwcYFNC3H+njnV3sdiDmHdZbrfQOxvUZj7mGwfuCc6yayH3C4lUGASGXYt5AG9XJGp
         6NvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=bfbRtSXnvBNgnAga55D234OHrkN1o27J7rPg1iia1mI=;
        b=TcfWmaC0MFCQ2in3FVpow0sDJVUwn8DBOLw17tjOa4S5VdyatC0Zbor3+Gi+BtWmZW
         9gN4xMxkUXqFIF4xCHVF+CpuDUgM7ZFnc87B8DpAjib81plIRYcpifPDBrcQtZe6xBUK
         S7+aOyUOKT+6vq1r0CQDAi84DJHqefipWpct8cVOfRC2S6OBQj0BPofl/1HsERx6RB48
         IekHuIjCCQz1NDffgpc6dfwskAEgVC0+AFunOYzMkf9rHZaZ2yJPmzOTydh5W5rZ/gCR
         lAb6LeCIVKn2Qi9Kyb6rlSOtEJO3DGIFt85YmItYxxhLCU3U8QyxTEPnz+4uOZeZrLIf
         hHLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id k9si2139027pgb.532.2019.03.29.08.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 08:40:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Mar 2019 08:40:13 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,284,1549958400"; 
   d="scan'208";a="287036931"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga004.jf.intel.com with ESMTP; 29 Mar 2019 08:40:13 -0700
Subject: [PATCH 2/6] mm/devm_memremap_pages: Introduce devm_memunmap_pages
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Ira Weiny <ira.weiny@intel.com>,
 Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@lst.de>,
 linux-mm@kvack.org, linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
Date: Fri, 29 Mar 2019 08:27:34 -0700
Message-ID: <155387325416.2443841.6074930471073650165.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
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
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Christoph Hellwig <hch@lst.de>
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

