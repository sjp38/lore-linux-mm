Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BCA9C28CC5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D49C620874
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D49C620874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D9256B0273; Wed,  5 Jun 2019 21:45:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39D696B0274; Wed,  5 Jun 2019 21:45:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A0596B0276; Wed,  5 Jun 2019 21:45:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3CC56B0273
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:45:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x9so650804pfm.16
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:45:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IdcCczW9Vt2bMohG/KgLyShIIfT/XdZU8+3ISgkl6NY=;
        b=RfFJ11XlLYuN0ntNu3R5jFLVJOGVu2hRYkgvzKbG2XTRZuPL8XyiZQJZoBY5onHD4u
         vYmlclh6GMLdZdrbWjVZL5iGSWjodzKEePGucOqTDEk4u1NPvE9uCpurCh3SieaSuJx7
         1MhObx5CzttOkYUuQqkl1lWLN3cHymcPdIdxxQwC1PIYKDgLv2pz3NhEVgfnREtBRyX0
         sRmvLm4sk+OJ9nm+TEjPQxPsddYbHKdpJnggYCnuMtxxz+cz55bNyGPG2UohSdADHYtX
         Zle9nJH5KMBUsUil95ORzYxLVpe/lXpLOxmjEMViHXts84YRT39PTtPw4ujyz2Q+TxhR
         P9aA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUhaUBJ1cfMDvJg+RNXm9hLToq+UnwLfvmgzoMHRm74EBqkHsKP
	zQ+MZZ4q36Ccm4kLLW/HglPmgOICCKGqoVXgi9IJlq2AhEducF7SdactZnJeH8QBt04VcdPvjlY
	ZorEelqtOO6ZKd6qiJzKni6F1xdYG3LtsVmNXfXYtL9ce0Q7/lnhc3L0nrB/OIT2j7Q==
X-Received: by 2002:a17:902:8f87:: with SMTP id z7mr21748412plo.65.1559785518523;
        Wed, 05 Jun 2019 18:45:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxq9OdwaMU2iDqfAgeDYWh/GwEHN1vHeBhUKLPpC0kQj051TE3JrplKTbWQHsQ2AIMN+Njy
X-Received: by 2002:a17:902:8f87:: with SMTP id z7mr21748359plo.65.1559785517742;
        Wed, 05 Jun 2019 18:45:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559785517; cv=none;
        d=google.com; s=arc-20160816;
        b=Zu32PpuJ0+Rc7ov5aYK+9szwESVq/+4hlGz9216XWFPfagqXwxqnI9ewteVdsgfCKv
         8Qr1HkRfI9Lo2AyVDDo/xphuwgLReeGcSTCHrdJbtU7BjxZMegjWGsvy7kUBvly7vSO+
         3FZuVp8fe58LGAL3TJ7ZH1yRMPtPGmFFYpfREM4mOzs9mindwjy1skf7WevKGUxftwQ2
         3p3OUFcGQZMGl7aVqpL9Xvdkig8SoRJqgvENGHNtt1g9HdKfx2dY97aq/SrszZx+Jz7B
         JKRuqY1qF0vHLrY69LYcdwAPxVgHBzLfGd3nyIekSaYRPUmp3qMrlwtfhGzuTBMMopC/
         ryZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=IdcCczW9Vt2bMohG/KgLyShIIfT/XdZU8+3ISgkl6NY=;
        b=ZwDP93zJQZ9ernMfxf4yeaDlXwdfzoZpyrkV/vr3OGJZVaoixYtxx+I4QJdw5mwajr
         dCiAdnAJF55CBSL6kt8qZ5O+VKFn6hilpleZzkGChPkZ2UY5MfY/pEKV/owzxxP4wc/8
         sp/VGEDZLhsXC80XwYpyjqYuV6qy9O/J+bVN3mcrMnQ2WSsaQ+0hDZhqVcvvwWLKV3D3
         6rIGUj14gd2OiKde1eCwTm0UrcEqKHGfJbySgNTU2gl//xwQQPSj+rI4yLgbTcCo/jvU
         3LQcXH32cI1l3fIJJjHUgQbu5rtgp5841oG958juj6MAQ1YZKn+UrQtVJjQT18Y/owyT
         9T7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k18si276921pfk.103.2019.06.05.18.45.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:45:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 18:45:17 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 05 Jun 2019 18:45:16 -0700
From: ira.weiny@intel.com
To: Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH RFC 05/10] fs/ext4: Teach ext4 to break layout leases
Date: Wed,  5 Jun 2019 18:45:38 -0700
Message-Id: <20190606014544.8339-6-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190606014544.8339-1-ira.weiny@intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

ext4 needs to break a layout lease if it is held to inform a user
holding a layout lease that a truncate is about to happen.  This allows
the user knowledge of, and choice in how to handle, some other thread
attempting to modify a file they are actively using.

Split out the logic to determine if a mapping is DAX, export it, and then
break layout leases if a mapping is DAX.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/dax.c            | 23 ++++++++++++++++-------
 fs/ext4/inode.c     |  4 ++++
 include/linux/dax.h |  6 ++++++
 3 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index f74386293632..29ff3b683657 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -552,6 +552,21 @@ static void *grab_mapping_entry(struct xa_state *xas,
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
@@ -574,13 +589,7 @@ struct page *dax_layout_busy_page(struct address_space *mapping)
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
index c16071547c9c..c7c99f51961f 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4241,6 +4241,10 @@ int ext4_break_layouts(struct inode *inode)
 	if (WARN_ON_ONCE(!rwsem_is_locked(&ei->i_mmap_sem)))
 		return -EINVAL;
 
+	/* Break layout leases if active */
+	if (dax_mapping_is_dax(inode->i_mapping))
+		break_layout(inode, true);
+
 	do {
 		page = dax_layout_busy_page(inode->i_mapping);
 		if (!page)
diff --git a/include/linux/dax.h b/include/linux/dax.h
index becaea5f4488..ee6cbd56ddc4 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -106,6 +106,7 @@ struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev);
 int dax_writeback_mapping_range(struct address_space *mapping,
 		struct block_device *bdev, struct writeback_control *wbc);
 
+bool dax_mapping_is_dax(struct address_space *mapping);
 struct page *dax_layout_busy_page(struct address_space *mapping);
 dax_entry_t dax_lock_page(struct page *page);
 void dax_unlock_page(struct page *page, dax_entry_t cookie);
@@ -137,6 +138,11 @@ static inline struct dax_device *fs_dax_get_by_bdev(struct block_device *bdev)
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

