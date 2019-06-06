Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76605C28CC5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39BD820866
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39BD820866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB2A76B0272; Wed,  5 Jun 2019 21:45:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C76B96B0273; Wed,  5 Jun 2019 21:45:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC7CF6B0274; Wed,  5 Jun 2019 21:45:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E51F6B0272
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:45:17 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f9so665733pfn.6
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:45:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cJXDXTe4LEXK71E9x18N/OOUKaBMgZQnZxMV1+LS/IU=;
        b=RSuV3lr+BaVeq39vFiyIKky8dHcwrS7fGoUWscfxrkN0R5VJF+CcJf5TrmqcUhzlBE
         u86bqOae6/4b9VmG8k3Leu0W2u0xoFZteAwPr4EpajO0s8EztX7yR+Gmn5uDeK72Exex
         K9ywE4TbAZE4qWe/WB5sZV6+E2Tmr+QHO450vCN4br3utMSw4ZLziKWQds9O4CYKXRhZ
         WakloIeLJZKbwlgfPBWWN4FwTIwOjQeffwtssmVjgPgq4e8XKaCkz3pvrMW7zPg1Q8V1
         GIXO5ywiqJ7KY+OTWsIvwgshWbGcXmFGPp5Em3wGej92h1+kPwVyyoMwak2hHi4xDBkx
         x5oQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVHFOkUBH4bPiT1WKM0TJ8t0wWXsOs2Cgiyj0y0M31gRe1m7+Cm
	1Ii5hHIsdqHYfJExqfSDmw0t0EWSuDYms/7ZAdT4UNbmxuh8yD+5xsc5LesajK2aYxtXTkKSu4V
	FYNzyIEJ2ROfxr5c0quWVQyUJf8BKnGESxN2quEMdb4PplZq6qwqU9O5xCnf+O3JoRw==
X-Received: by 2002:a17:902:8204:: with SMTP id x4mr46743227pln.226.1559785517099;
        Wed, 05 Jun 2019 18:45:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlmJY/+zxKrcOAYHA6KYwkysTMN4s2A+2XhAKCrj857SJWE73cnBoAEUiatwJYa013TDtL
X-Received: by 2002:a17:902:8204:: with SMTP id x4mr46743148pln.226.1559785515851;
        Wed, 05 Jun 2019 18:45:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559785515; cv=none;
        d=google.com; s=arc-20160816;
        b=gjuqaXdqY5KguU4yncsjNYOyAJC8a2xpudOMW1j5efplBYCNADpI5j4ztqICsKAwen
         9fbw15VMAzq13ZXOs42gdZd2lJx31vznutxH1VTLgOcdx/3BjxwBVbEY873RGvBQ0I/U
         +GUtuge3Xgv3MbKOcfp1o0gdB6fPj9QgRap+gIE/Uhxyz+f1cFiXLXXOzJuAYcysGvWK
         7ewtKTES27r4oyTcqwvYa9XG3cWLIoRLdsTWIEH45emx5g58Mw/cfaoeFyprt26f4/HM
         +aO1c5pOixbp7xioKFjY5mYf5HvqRm4MnYLVjAO3uMRgQV5GikYgbDHCj6a/vt92Wypj
         wvSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cJXDXTe4LEXK71E9x18N/OOUKaBMgZQnZxMV1+LS/IU=;
        b=hXd4Jc31K9ct+gdK8HmrqLjmJxZt2LQ0lycd3ig4L83iWu8oeenrhqwY3OICYMx+35
         Hf0LINIUg/UGCVw23fKBYSKhbvWR7MrCMLJHDUm+3HKeef1GqTRewHYd0malioWmqYQv
         owz6urIJV+OnVhCICWpq7iN6KsV652KCFndWv7AWIgJiLBG61LIe1FqG9o3MjK6E4shv
         xwa5oSUlsagUiDik+POAQvM6BzLPCjiNsRqidxaRkV7R+cszGrvUwNPMeBqFDYXp7yaq
         1FRQj/GvoDkNJqtoQ8OSD3+2vuwZJMNq8wTjmL0X5FYXsDtCoK/Q6uR7a04ls9iD3CMi
         llFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k18si276921pfk.103.2019.06.05.18.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:45:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 18:45:15 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 05 Jun 2019 18:45:14 -0700
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
Subject: [PATCH RFC 04/10] mm/gup: Ensure F_LAYOUT lease is held prior to GUP'ing pages
Date: Wed,  5 Jun 2019 18:45:37 -0700
Message-Id: <20190606014544.8339-5-ira.weiny@intel.com>
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

On FS DAX files users must inform the file system they intend to take
long term GUP pins on the file pages.  Failure to do so should result in
an error.

Ensure that a F_LAYOUT lease exists at the time the GUP call is made.
If not return EPERM.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/locks.c         | 41 +++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h |  2 ++
 mm/gup.c           | 25 +++++++++++++++++++++++++
 mm/huge_memory.c   | 12 ++++++++++++
 4 files changed, 80 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index de9761c068de..43f5dc97652c 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2945,3 +2945,44 @@ static int __init filelock_init(void)
 	return 0;
 }
 core_initcall(filelock_init);
+
+/**
+ * mapping_inode_has_layout()
+ * @page page we are trying to GUP
+ *
+ * This should only be called on DAX pages.  DAX pages which are mapped through
+ * FS DAX do not use the page cache.  As a result they require the user to take
+ * a LAYOUT lease on them prior to be able to pin them for longterm use.
+ * This allows the user to opt-into the fact that truncation operations will
+ * fail for the duration of the pin.
+ *
+ * @Return true if the page has a LAYOUT lease associated with it's file.
+ */
+bool mapping_inode_has_layout(struct page *page)
+{
+	bool ret = false;
+	struct inode *inode;
+	struct file_lock *fl;
+	struct file_lock_context *ctx;
+
+	if (WARN_ON(PageAnon(page)) ||
+	    WARN_ON(!page) ||
+	    WARN_ON(!page->mapping) ||
+	    WARN_ON(!page->mapping->host))
+		return false;
+
+	inode = page->mapping->host;
+
+	ctx = locks_get_lock_context(inode, F_RDLCK);
+	spin_lock(&ctx->flc_lock);
+	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
+		if (fl->fl_flags & FL_LAYOUT) {
+			ret = true;
+			break;
+		}
+	}
+	spin_unlock(&ctx->flc_lock);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mapping_inode_has_layout);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bc373a9b69fc..432b004b920c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1630,6 +1630,8 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 int get_user_pages_fast(unsigned long start, int nr_pages,
 			unsigned int gup_flags, struct page **pages);
 
+bool mapping_inode_has_layout(struct page *page);
+
 /* Container for pinned pfns / pages */
 struct frame_vector {
 	unsigned int nr_allocated;	/* Number of frames we have space for */
diff --git a/mm/gup.c b/mm/gup.c
index 26a7a3a3a657..d06cc5b14c0b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -361,6 +361,13 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 			page = pte_page(pte);
 		else
 			goto no_page;
+
+		if (unlikely(flags & FOLL_LONGTERM) &&
+		    (*pgmap)->type == MEMORY_DEVICE_FS_DAX &&
+		    !mapping_inode_has_layout(page)) {
+			page = ERR_PTR(-EPERM);
+			goto out;
+		}
 	} else if (unlikely(!page)) {
 		if (flags & FOLL_DUMP) {
 			/* Avoid special (like zero) pages in core dumps */
@@ -1905,6 +1912,16 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 
+		if (pte_devmap(pte) &&
+		    unlikely(flags & FOLL_LONGTERM) &&
+		    pgmap->type == MEMORY_DEVICE_FS_DAX &&
+		    !mapping_inode_has_layout(head)) {
+			mod_node_page_state(page_pgdat(head),
+					    NR_GUP_FAST_PAGE_BACKOFFS, 1);
+			put_user_page(head);
+			goto pte_unmap;
+		}
+
 		SetPageReferenced(page);
 		pages[*nr] = page;
 		(*nr)++;
@@ -1955,6 +1972,14 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 		}
 		SetPageReferenced(page);
 		pages[*nr] = page;
+
+		if (unlikely(flags & FOLL_LONGTERM) &&
+		    pgmap->type == MEMORY_DEVICE_FS_DAX &&
+		    !mapping_inode_has_layout(page)) {
+			undo_dev_pagemap(nr, nr_start, pages);
+			return 0;
+		}
+
 		if (try_get_gup_pin_page(page, NR_GUP_FAST_PAGES_REQUESTED)) {
 			undo_dev_pagemap(nr, nr_start, pages);
 			return 0;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bb7fd7fa6f77..cdc213e50902 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -950,6 +950,12 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 	if (!*pgmap)
 		return ERR_PTR(-EFAULT);
 	page = pfn_to_page(pfn);
+
+	if (unlikely(flags & FOLL_LONGTERM) &&
+	    (*pgmap)->type == MEMORY_DEVICE_FS_DAX &&
+	    !mapping_inode_has_layout(page))
+		return ERR_PTR(-EPERM);
+
 	if (unlikely(!try_get_gup_pin_page(page,
 					   NR_GUP_SLOW_PAGES_REQUESTED)))
 		page = ERR_PTR(-ENOMEM);
@@ -1092,6 +1098,12 @@ struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 	if (!*pgmap)
 		return ERR_PTR(-EFAULT);
 	page = pfn_to_page(pfn);
+
+	if (unlikely(flags & FOLL_LONGTERM) &&
+	    (*pgmap)->type == MEMORY_DEVICE_FS_DAX &&
+	    !mapping_inode_has_layout(page))
+		return ERR_PTR(-EPERM);
+
 	if (unlikely(!try_get_gup_pin_page(page,
 					   NR_GUP_SLOW_PAGES_REQUESTED)))
 		page = ERR_PTR(-ENOMEM);
-- 
2.20.1

