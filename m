Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D3BFC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ADEF208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ADEF208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 598B76B026F; Fri,  9 Aug 2019 18:59:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54F1F6B0270; Fri,  9 Aug 2019 18:59:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39CDB6B0271; Fri,  9 Aug 2019 18:59:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05DD86B026F
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:59:08 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g185so118959pfb.13
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:59:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KJ855nZTb3U4x3doVTE/WvrCgUCp2cy8KAAWpSqjQoo=;
        b=Sf4ouxkWi1TWlKiO2KnB1jfJtD4F9ICVy00vZqz39IeLV/6zcggy6ZHb9n+FLPEBfb
         6cmwPSYSx2Piw70bDgoXN184BDWN63wpDrE6fed2wBzeoZGCdgYRC2yLgCmxciD9BbUA
         VXEBPSohB6TMpW9AuMGUHyxg1+e04LUyRYosi1WV1NwgQT5F7LtIZ7nklNK4N4OiYHhj
         Yg6cSvueL68N8QUXITohjMNmN7FKmS/p+NVUpF5Jya7B3McP2AGkt6ABKixFf2UEwDMS
         OYXiydQCCcaOEk+04VXrMCdZJDTpZsxm/9dKbrmQOgnQ+MWFp/MN9Fz2PEGlsWt6RWsq
         TRJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXCw82wboysFcNTe5f+p0prFgFmXFDD4gaEDtiu94bCk10QAiNx
	z/7sRBg2Rp+M7Nj4aWl1knsgk8w3MRk5pZIL9isY+9lAb/oSwwPVVWBtsGzDTvMUzMuNVshYy6o
	DVXfy+TGhFg2vK5FdOycR8Me6jM8+nqBwyuvMKEcR1zWdeAAOqp9UhnBwcQ1U4ppHvw==
X-Received: by 2002:aa7:9118:: with SMTP id 24mr23181494pfh.56.1565391547745;
        Fri, 09 Aug 2019 15:59:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3BWMFID4xtuWbP00hgVZS5UTYdaFHKqZFNg/URcoLtABL5ObcV48tVOH1DJFFqrUQLaMB
X-Received: by 2002:aa7:9118:: with SMTP id 24mr23181431pfh.56.1565391546650;
        Fri, 09 Aug 2019 15:59:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391546; cv=none;
        d=google.com; s=arc-20160816;
        b=dzRZKYmJ+xf0fKcf4khlROD7jvBkKH5z+Ve7uhAPwE/Gd+Gv346DqyDs4/8Wzoxrcb
         +6ZfGJH9sXgFMF9ZHHaPBUpKnKmNV2nNfGnh6BFdFCIdAQdjkCuRFcttK17SKSdGKz8H
         nSOUdBp1Luq91z7WgaoKzqXm7kfpCWESXjX5W0ZBJwnKfdi8XaIidlZ8bQ9WMXaZ7pJq
         CW3pFmlJuQo5SGBHK8b2W4Srng40EHUWfLmFZSwAEQAT5MMEjogQYQ0NTNR9hab4zIXy
         jiWOu4B3Z/GWB35ltYsiiEQon+0orjnfkB6O9YoPD/JIzSvGHhhx/VooiO4S48YzqObp
         0wjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=KJ855nZTb3U4x3doVTE/WvrCgUCp2cy8KAAWpSqjQoo=;
        b=Ono8I+2deInAk+aZKnwk0Lr7La5pOeasfm8TS2D5tG8XwDzE0g7+/8ZzE/sO/xEW1N
         uTwWjOkOzP4FpUJ5uNYfso9Fnzj0bAAhjWt4CA6QjFUniZD4EHmoXyGk/zj/SVRN3zoB
         Fh7ks6kWSiJbABsSMAnagJ/38FqVVDlhLYs6e/6Ew7GoylnzlUu48CifRTmEJgZiasbn
         WJyvPpqzIyS0FIap2fsqdxeqBiqHaTdnMF9pyp5hQuxD/A93FcfutfUD/T+XY+Q8LU1a
         ePdnIFYgUparMniUblL6xmf4DyawpBu4EL52bMoVeLqgPVDPVO9OoJuC2HbjK3aXRm5+
         /3qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id r14si54783250pgm.406.2019.08.09.15.59.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:59:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:06 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="375343545"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga006-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:05 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH v2 16/19] RDMA/uverbs: Add back pointer to system file object
Date: Fri,  9 Aug 2019 15:58:30 -0700
Message-Id: <20190809225833.6657-17-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190809225833.6657-1-ira.weiny@intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

In order for MRs to be tracked against the open verbs context the ufile
needs to have a pointer to hand to the GUP code.

No references need to be taken as this should be valid for the lifetime
of the context.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 drivers/infiniband/core/uverbs.h      | 1 +
 drivers/infiniband/core/uverbs_main.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/infiniband/core/uverbs.h b/drivers/infiniband/core/uverbs.h
index 1e5aeb39f774..e802ba8c67d6 100644
--- a/drivers/infiniband/core/uverbs.h
+++ b/drivers/infiniband/core/uverbs.h
@@ -163,6 +163,7 @@ struct ib_uverbs_file {
 	struct page *disassociate_page;
 
 	struct xarray		idr;
+	struct file             *sys_file; /* backpointer to system file object */
 };
 
 struct ib_uverbs_event {
diff --git a/drivers/infiniband/core/uverbs_main.c b/drivers/infiniband/core/uverbs_main.c
index 11c13c1381cf..002c24e0d4db 100644
--- a/drivers/infiniband/core/uverbs_main.c
+++ b/drivers/infiniband/core/uverbs_main.c
@@ -1092,6 +1092,7 @@ static int ib_uverbs_open(struct inode *inode, struct file *filp)
 	INIT_LIST_HEAD(&file->umaps);
 
 	filp->private_data = file;
+	file->sys_file = filp;
 	list_add_tail(&file->list, &dev->uverbs_file_list);
 	mutex_unlock(&dev->lists_mutex);
 	srcu_read_unlock(&dev->disassociate_srcu, srcu_key);
-- 
2.20.1

