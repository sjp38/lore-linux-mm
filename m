Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C14A1C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E72F208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E72F208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 720286B0010; Fri,  9 Aug 2019 18:58:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FAA26B0266; Fri,  9 Aug 2019 18:58:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5299D6B0269; Fri,  9 Aug 2019 18:58:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10BA06B0010
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:58:55 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id j12so58177778pll.14
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:58:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o3LFNt0eHSKoEB+BEnprqBSe2zk7FW3mS2UHtjP/KF0=;
        b=XLycgicqhgkKhP+AoiihmV+KQ6KfphWqDC3RcujB61cwITTVopZWMIrPwd9FUZvZ3Q
         ZTGcO9AaLLBnIhxwt/mpCSmaJafReGOtKtLWZPZyEdFlLgQMxK7zB9z2plFIaTgJRueB
         jimGOI8reLW+XqNjrkg/vinVPjTf50Q5c5VKg0UGM23oKYxtA/MN2OMHGJ9PblbGsH08
         9HWT68IJX22S3aqYd7p8SqbYvdf26iGpgddKH9e2NcXjqgo3kLG89ukRXrBwk9hncWuq
         n8evhPlgsKFkUYxGw6N7obgLsm7nJATMRu3cDt6Zyqnc7XsP6ETmlsXLtUKTSHGyjblI
         ANoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVadt+yLIycHlUQ/V4Y+PbUF3PWghdfTqsDiQjjzvJNoAUFi2GZ
	5jj2+YZBZWjGoJUw1spwBVkkFuHThdaa5fxtVTbja14XTNsYHly9lv8/scRgyWHSLoc/PxXh65C
	a1QTNjofwesvMspUvQsxad8G7brcgV71ny9dkh3gDVcQYclrJQGj/jZg2ueYXuf79nQ==
X-Received: by 2002:a17:90a:a897:: with SMTP id h23mr5207333pjq.44.1565391534697;
        Fri, 09 Aug 2019 15:58:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAMSQxC2QbgbqXGePaXVPPI5ltCCjwnODtVd5zoJ5EzSY9ZAvsVxJ+xsiMR4+r2GC7KzMi
X-Received: by 2002:a17:90a:a897:: with SMTP id h23mr5207295pjq.44.1565391534014;
        Fri, 09 Aug 2019 15:58:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391534; cv=none;
        d=google.com; s=arc-20160816;
        b=R4MO735I4ECRHCUZZFDsr7rBJePj24gagGAA+qEk7NlHDLwRI0dFvjm+sZ2CpJ40aq
         reCbC8zyrSqTvfTBvXWlaptXETHKLAUr1jh7Gns0/Th0GxmhThPjwj2KUITRSwu0mpgh
         eavpuoNl/yciku5zmFEmIBuauDG5z83e2hJ+ZJbkPXnclNDplrICHs6ohBWlITusSKEp
         EdeiyH2qZTr02GDOMoUozZeNGsJYVIJSONxw1eNwWwjUfES8Hm78u3mv6FV3SDn18WPo
         XV/OWG6on98GM5UybKdeWFwWVjklCYTQKjS1Dg2x50iOddsCA3j66RsbHuPe634TKW6S
         MZYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=o3LFNt0eHSKoEB+BEnprqBSe2zk7FW3mS2UHtjP/KF0=;
        b=cn84o51ec/DlhJa1HEU60xDMl58NdBHsX9m4gvIIva39ONsPpCFf3DBKxQx8QY2xum
         PR+jp0ivd+iEIJGac8YhncOl/4/nZFCI7V3tF5bcj5hh7QuanXDNngX7eUJzHKkL2qVw
         bT9whKOVxE1CYMJNqU2U+QcweaxK7FB4u1cXcDQxXxhSBlVHJTxMSqXQlhqZmQ9Sqn/T
         1z4B0QBQvyqS7ky5PdjWsibu9cOsoFpap9AB6zDqbYNDh8cqxXvFPdzZ/uk1+qvcQo4R
         7pi4O/OobHyW9l1L0zJK1MxAKUZYXnLhYLQDUK0iIdEDUv9P4IgcJSQ2fZCEkslcUHtV
         q2SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e17si22370683pgt.192.2019.08.09.15.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:53 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="180270005"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by orsmga006-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:52 -0700
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
Subject: [RFC PATCH v2 08/19] fs/xfs: Fail truncate if page lease can't be broken
Date: Fri,  9 Aug 2019 15:58:22 -0700
Message-Id: <20190809225833.6657-9-ira.weiny@intel.com>
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

If pages are under a lease fail the truncate operation.  We change the order of
lease breaks to directly fail the operation if the lease exists.

Select EXPORT_BLOCK_OPS for FS_DAX to ensure that xfs_break_lease_layouts() is
defined for FS_DAX as well as pNFS.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/Kconfig        | 1 +
 fs/xfs/xfs_file.c | 5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 14cd4abdc143..c10b91f92528 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -48,6 +48,7 @@ config FS_DAX
 	select DEV_PAGEMAP_OPS if (ZONE_DEVICE && !FS_DAX_LIMITED)
 	select FS_IOMAP
 	select DAX
+	select EXPORTFS_BLOCK_OPS
 	help
 	  Direct Access (DAX) can be used on memory-backed block devices.
 	  If the block device supports DAX and the filesystem supports DAX,
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 447571e3cb02..850d0a0953a2 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -773,10 +773,11 @@ xfs_break_layouts(
 		retry = false;
 		switch (reason) {
 		case BREAK_UNMAP:
-			error = xfs_break_dax_layouts(inode, &retry, off, len);
+			error = xfs_break_leased_layouts(inode, iolock, &retry);
 			if (error || retry)
 				break;
-			/* fall through */
+			error = xfs_break_dax_layouts(inode, &retry, off, len);
+			break;
 		case BREAK_WRITE:
 			error = xfs_break_leased_layouts(inode, iolock, &retry);
 			break;
-- 
2.20.1

