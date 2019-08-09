Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C3E0C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39AB6208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39AB6208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB0606B000C; Fri,  9 Aug 2019 18:58:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC38B6B000D; Fri,  9 Aug 2019 18:58:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B68436B000E; Fri,  9 Aug 2019 18:58:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8986B000C
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:58:49 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g126so14023939pgc.22
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:58:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tYh6rksf7SquyCqsn5ZWbafxgT2t5CvaacKb/a6zePI=;
        b=P2POxnrRMC+RfWLnQSETHL60rYAZqbkKxM1zniiT5vlXMb9p1wyBrVMVFCXbCwTvnB
         YTzbh40Ht4eoYu8Ex/Ne3+BLv7Z8nB+KmlXsersA/cqglFMvpL/nQDSpV6aBIa0SaknJ
         ay6jzMVlANOgS4ZX91gNsbOnwesk7Gti7nGkcpK3z0JerTBZ9OltMv+nz3ddqdnzfzOq
         GiVGKHLWPtUUUQnbn1f1AjgnsRE2HDJWNmxFMiopJV3DbVCjOj8C/niuLcI7YWbyxMjC
         HaFQvq5CEiwCXUJ1n0eAhd8OgdOLrNbf9nonJGCm/aQvdG68E/CLTZtaoKpo7chJI4WX
         1aHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUXqL/w3dkDeObpxzTiFLZb4XqBw+irYTbP1yKDfraQOOsGJ6ex
	TSFmhm6oEDLCvJAm04AsKnZjkZzPPDcDib54gkY508WHCQzO8URAXX4jKmwu0UxsGdXXSb95gqG
	0bXp/NXhygH8hmTu3GmPtB0AseOXLbEXK3nYR7EsmLjQyailng2pUERmKr7O3NUCq3A==
X-Received: by 2002:a62:7d93:: with SMTP id y141mr799263pfc.164.1565391529132;
        Fri, 09 Aug 2019 15:58:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPYDtjR2MZv94lBB/roakezkl8n1Zw2E3zISJBpV5xdZheem9726Uz6z5tro6CgUjFU7cb
X-Received: by 2002:a62:7d93:: with SMTP id y141mr799230pfc.164.1565391528435;
        Fri, 09 Aug 2019 15:58:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391528; cv=none;
        d=google.com; s=arc-20160816;
        b=wzuBDszS8mw0pWX6DftyFPNjGXGPdyWD+ztS67fQqYyFycdjEbcPdFvb5BkL6ZyOjo
         OcmVfOtD1VB+Nkv7qyVxlOTE+mfMSk4enQLKUuIxV/qRTbjf0Ifgwz5DT6WZbGAAjeTV
         fSjyTDzRouIoT4gHieFgF0c02fgVrbEWxfYKhDJHnrLyWEi2P27WLdcHcxWo00JTldYT
         Mp+1msNXgfhYupBn8BKcz01O5bF6648Mrsr+ZZ8IivH1XElq9+uSLU6wjo6ahv9dY2nL
         v617I8IW2Itj2fx/2P4hympWz7I97LUxKJhfg4SkJF4CAkmJ+mmxpCYywqvZDlZSNR5K
         240A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tYh6rksf7SquyCqsn5ZWbafxgT2t5CvaacKb/a6zePI=;
        b=y4cj8+sO11YgJgU5Ek6a+VPpRKPKLoM69H9/KSuQMIkuW5ZG1JWe5BIon/HZ3DWr5z
         ACjuR+aEgU+iL/x+szt5/qP4fpaviaIadSoa7DO0XDkzPphP8WZ9nBNjwnupqhMFq6Al
         pe0K+nyLcmIWrcnF6J/l5g8M1W98UHGa++Xoaw1n2JP2fYnyZPdrlmzpGYbsWOgrHASm
         CTQ/1OfrbmOZxJR1P8fSbhw/1zl5h8eLwt8t0CQkqhVHZGuLVcDsgWYzJjqdaE/ELvsR
         zcQYDGBmBRA52jTqMLFGN68Lm9b1k3uP2mxHugAU7zXd31YSeHoA2H5DTdNvAw01QiJQ
         0oew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f131si52945383pgc.265.2019.08.09.15.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:47 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="193483400"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga001-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:47 -0700
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
Subject: [RFC PATCH v2 05/19] fs/ext4: Teach ext4 to break layout leases
Date: Fri,  9 Aug 2019 15:58:19 -0700
Message-Id: <20190809225833.6657-6-ira.weiny@intel.com>
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

ext4 must attempt to break a layout lease if it is held to know if the
layout can be modified.

Split out the logic to determine if a mapping is DAX, export it, and then
break layout leases if a mapping is DAX.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from RFC v1:

	Based on feedback from Dave Chinner, add support to fail all
	other layout breaks when a lease is held.

 fs/dax.c            | 23 ++++++++++++++++-------
 fs/ext4/inode.c     |  7 +++++++
 include/linux/dax.h |  6 ++++++
 3 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index b64964ef44f6..a14ec32255d8 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -557,6 +557,21 @@ static void *grab_mapping_entry(struct xa_state *xas,
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
@@ -579,13 +594,7 @@ struct page *dax_layout_busy_page(struct address_space *mapping)
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
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b2c8d09acf65..f08f48de52c5 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4271,6 +4271,13 @@ int ext4_break_layouts(struct inode *inode)
 	if (WARN_ON_ONCE(!rwsem_is_locked(&ei->i_mmap_sem)))
 		return -EINVAL;
 
+	/* Break layout leases if active */
+	if (dax_mapping_is_dax(inode->i_mapping)) {
+		error = break_layout(inode, true);
+		if (error)
+			return error;
+	}
+
 	do {
 		page = dax_layout_busy_page(inode->i_mapping);
 		if (!page)
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 9bd8528bd305..da0768b34b48 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -143,6 +143,7 @@ struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev);
 int dax_writeback_mapping_range(struct address_space *mapping,
 		struct block_device *bdev, struct writeback_control *wbc);
 
+bool dax_mapping_is_dax(struct address_space *mapping);
 struct page *dax_layout_busy_page(struct address_space *mapping);
 dax_entry_t dax_lock_page(struct page *page);
 void dax_unlock_page(struct page *page, dax_entry_t cookie);
@@ -174,6 +175,11 @@ static inline struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev)
 	return NULL;
 }
 
+static inline bool dax_mapping_is_dax(struct address_space *mapping)
+{
+	return false;
+}
+
 static inline struct page *dax_layout_busy_page(struct address_space *mapping)
 {
 	return NULL;
-- 
2.20.1

