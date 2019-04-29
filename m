Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85984C04A6B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 427EC2087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 427EC2087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A06B46B026B; Mon, 29 Apr 2019 00:54:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96F386B0266; Mon, 29 Apr 2019 00:54:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 807766B026B; Mon, 29 Apr 2019 00:54:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 457BE6B0266
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 00:54:11 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t5so5883755pfh.21
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 21:54:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hM+H6Xv3+Di+oM/qPT2dUWnf4wFEXXxrAobMtpZPNAE=;
        b=cbFQVbA4DDT4eOFIaSgCgA2rTX3UaZJRmo3SPVy4aCkoAOtguBXxIKFO5EWbT42uQ3
         wLA7db+N0Xy5Uzey3P9ogW41fgoFcTY9hauwQIyefjHUutRr+mAJUhEOANreg8rWC6So
         Hqj1Kyy8qgbz+8belkaUOCkalAaSYHRBTnd+TLHQhde4H2fZ/4e2DzAZPE9CqAtNXF3R
         KZTL/5JEJVcY5IALRKtwK601sE2AR24vaoYUuMoVv4JLQJcmPwVFNH5QNh56HQaIP3M4
         YLf8PjTVmk6MRvrgUUKIJqv7wwST+BX/N1g+1zKv41Td9lnvvEcl+1FHhB4aTksHjCOM
         SiKQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW86DiqgUQLrqm0yKloV5zq3n1llnFv2jwMT74+W5lFhf46Tgn5
	oXJn0wppwbKCDpnIdhmAk+CFwwKmcPUGOrczkBv730iZ6H53d8qHy7+NQYZUl57BPq4HrFaBquy
	A5rag05GtYuTVD0SblECSkCJ3E8vWuss5ZLD8O4Z35RP88Z9jKZ7gAytXkYLJTczAqQ==
X-Received: by 2002:a63:155d:: with SMTP id 29mr56560694pgv.389.1556513650955;
        Sun, 28 Apr 2019 21:54:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhM8bcEkfZ+2F/4CNS5dsePVfmjNiRg3bEUu9SgKbZAe3+uO3EMJ6eMFkyWRRjEMB9ZIw2
X-Received: by 2002:a63:155d:: with SMTP id 29mr56560652pgv.389.1556513649779;
        Sun, 28 Apr 2019 21:54:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556513649; cv=none;
        d=google.com; s=arc-20160816;
        b=di+iZCw2Gv4xf/mFh+P3A3z4dxnDfZfdfJdBuLpQEPEVh8HTwlXvRHIWcmhR9zgtyX
         5ko163su8DxmQMMRt3DqZPK13LgicSyc1Zr4TgDcYSrI159ejuuPT3F9uWdHaOZuQAqd
         McQUhEqKdKBpUef00TbmVk0BBvoUNP1qCpBhvud+TLNEynQ1a3lmlSdHxcAc3RHdmiYQ
         S6VFqXWLC9UwjrxT3RxaD/8yylnwJEyIHyyXQ0E/QVFSpu4iT2ijh+8RwEC+r8Y8kCf4
         xdYXsF52wNLieZ1ZLMy3aQPOqkNfD+jO3w8i6qJ536beEmxabtoEpjsk8Gh0d9vwLiLh
         Rp2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=hM+H6Xv3+Di+oM/qPT2dUWnf4wFEXXxrAobMtpZPNAE=;
        b=JqIgnFOVFyJ+vIjg3ne8ueesYCEBvLmkBEfWsRciiBGi+kYbIW8Sb+hQIVKfLR0ft/
         MoZjM14xQj29ZrOEHoUZuM9YlQl0sfBNnq6ictK4pHUu3rZxVgcP5xQu0iHBBjaTpzXC
         yTQndYtTuj7DhtqpEdZxZQmYwqQ2xtj7WGPL8fLZp2SCwylR/nfhJHz24rsX9BCD1/hj
         LC/1So3uzht5kRiQCtXLr4GV4phBq/UPKgGA5rgTzuqG3xcgHXlHVyrbzNTIxOZeMTD+
         ZZojNzp62IavTok/eC4wClAdlP46LcclTi9XXnQ2YFAe/H8bfrsIvQcqU1Nz8JsnGTRm
         Zd0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m184si14181099pfb.166.2019.04.28.21.54.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 21:54:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Apr 2019 21:54:09 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,408,1549958400"; 
   d="scan'208";a="146566306"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 28 Apr 2019 21:54:08 -0700
From: ira.weiny@intel.com
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH 07/10] fs/dax: Create function dax_mapping_is_dax()
Date: Sun, 28 Apr 2019 21:53:56 -0700
Message-Id: <20190429045359.8923-8-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190429045359.8923-1-ira.weiny@intel.com>
References: <20190429045359.8923-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

In order to support longterm lease breaking operations.  Lease break
code in the file systems need to know if a mapping is DAX.

Split out the logic to determine if a mapping is DAX and export it.
---
 fs/dax.c            | 23 ++++++++++++++++-------
 include/linux/dax.h |  6 ++++++
 2 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index ca0671d55aa6..c3a932235e88 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -551,6 +551,21 @@ static void *grab_mapping_entry(struct xa_state *xas,
 	return xa_mk_internal(VM_FAULT_FALLBACK);
 }
 
+bool dax_mapping_is_dax(struct address_space *mapping)
+{
+	/*
+	 * In the 'limited' case get_user_pages() for dax is disabled.
+	 */
+	if (IS_ENABLED(CONFIG_FS_DAX_LIMITED))
+		return false;
+
+	if (!dax_mapping(mapping) || !mapping_mapped(mapping))
+		return false;
+
+	return true;
+}
+EXPORT_SYMBOL_GPL(dax_mapping_is_dax);
+
 /**
  * dax_layout_busy_page - find first pinned page in @mapping
  * @mapping: address space to scan for a page with ref count > 1
@@ -573,13 +588,7 @@ struct page *dax_layout_busy_page(struct address_space *mapping)
 	unsigned int scanned = 0;
 	struct page *page = NULL;
 
-	/*
-	 * In the 'limited' case get_user_pages() for dax is disabled.
-	 */
-	if (IS_ENABLED(CONFIG_FS_DAX_LIMITED))
-		return NULL;
-
-	if (!dax_mapping(mapping) || !mapping_mapped(mapping))
+	if (!dax_mapping_is_dax(mapping))
 		return NULL;
 
 	/*
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 0dd316a74a29..78fea21b990e 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -89,6 +89,7 @@ struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev);
 int dax_writeback_mapping_range(struct address_space *mapping,
 		struct block_device *bdev, struct writeback_control *wbc);
 
+bool dax_mapping_is_dax(struct address_space *mapping);
 struct page *dax_layout_busy_page(struct address_space *mapping);
 dax_entry_t dax_lock_page(struct page *page);
 void dax_unlock_page(struct page *page, dax_entry_t cookie);
@@ -113,6 +114,11 @@ static inline struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev)
 	return NULL;
 }
 
+bool dax_mapping_is_dax(struct address_space *mapping)
+{
+	return false;
+}
+
 static inline struct page *dax_layout_busy_page(struct address_space *mapping)
 {
 	return NULL;
-- 
2.20.1

