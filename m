Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72166C41514
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33B5521743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33B5521743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F7366B000A; Fri,  9 Aug 2019 18:58:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 859746B000C; Fri,  9 Aug 2019 18:58:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D2916B000D; Fri,  9 Aug 2019 18:58:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3554C6B000A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:58:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so62340774pfj.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:58:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lElqodQf2pHfVO17BVRpL/ZEwcuJxLyXS4cguStFJ2c=;
        b=Cy6d8Pn0wSTDI72FmAsp+zp9l2YM4C0PC+NBRyD3uOddqQJp2OPOAbD1R1Re/5HoNU
         FzxL9IY+sKLUOPcNClw72WXGQ+WnRVSDFs9kCfTj1VKdoWvpjclk21s3C72hE5024xzA
         0bK2guaVG9Yzy4oSz15bk0A27GfTf0agv0lKcbsK3QfFwRXW2JpT2OM9efvBaAx1elDT
         BrpYRfwzZ73I/ZslRWC5bl0+Icv0HF22SZ3QAnlIyykDBQTFhGN36G2HxO++19oYwN8a
         s523MJtwgtYLZWLl5DjVfe6UHWcvzA/bcDCZ+okTuVSGcyiuQyvbdOEsRs2+EOp+EU5w
         3b9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXJFHAqE5GimE9FIlZwaWzovq8paNeK+1CuGNl/S2C7il/IgVmM
	9Iy7wpXFGRNnf5JGGvaNeUIGbKPyXVt8rxECHzlD8LLv6m8bsSdtDNB6IUdSAnHWCDh4nMWL7Dw
	/vJQT0JOFWufLSNXVoQLtV9PBuS7KHoqW8X82yabHMMOgkGvzI3A+CfgxmtJr/pBWrg==
X-Received: by 2002:aa7:9118:: with SMTP id 24mr23180450pfh.56.1565391527876;
        Fri, 09 Aug 2019 15:58:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwf+ndBVq1/LGeGnbRptpFL+WpyKr1VE25Z92uAP9r0uU9XL2qbsOVbOCuHGK4GiGVyrYW3
X-Received: by 2002:aa7:9118:: with SMTP id 24mr23180387pfh.56.1565391526978;
        Fri, 09 Aug 2019 15:58:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391526; cv=none;
        d=google.com; s=arc-20160816;
        b=R4LwmW+AVjGoqjV4XsFF5fvgwU5w1PBhhVzegi4RLEytFnj0lNtQdnQtfRvZlQ7IHh
         c6d7IkD/TCkqgbJDfQHHfXJ6Y0ukZ7223GGiHdmn6EDjTSZqt4oXj+8HOnUTQNRRgWtB
         IugyyXzq18jvjIrOQppKvpK9oeWiDEg3lI6bxpZiNQXUTPLl3wZh9fMxsbJgGQlQ9Q64
         K+68ox4DAJz1q047MmDQ6wtF8qzzwBAJmf3azCsuH0m0l1us6u4O2PvBzTwcLiHkVUAt
         eyQPKMIiynz/xsb5zf8fFkubFzAZRsINWw3KgNK/4YC/8yXjr0g8FO6vhpx4yEFZ9GUQ
         UjWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=lElqodQf2pHfVO17BVRpL/ZEwcuJxLyXS4cguStFJ2c=;
        b=WvfUBwbQMu71zsiywvEdCn2ii6nH+qVBjlxn1eMapQEMZ4D5P6Iuo+OpAkfvWL99yP
         3m0ohgEZIM8wbNgfxar1o+YE9S8s6MlrIe3EN2wBX/ORCDLwp63wr6x0SAZ7lxlDuC9r
         mcymL0POYd/d5Z6+eS3PayuD+YBu5d2qh8pL1zH79jHe42ilta3h5wf+b0E0ZBVT+Sls
         iwWzTIRG+cBKKIK047mn1/iXSQ5iehoQV67XG8HF33D0pxQQlPogfPlwooITI7A1lmW2
         nn7AJXkyYWUUG87WB3kKiSPhIcI6KDj8iNq8/IV4AES7qWragq0f5etx9PVfEZt+HEgr
         53zw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y14si41662198pfr.82.2019.08.09.15.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:46 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="204067068"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga002-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:46 -0700
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
Subject: [RFC PATCH v2 04/19] mm/gup: Ensure F_LAYOUT lease is held prior to GUP'ing pages
Date: Fri,  9 Aug 2019 15:58:18 -0700
Message-Id: <20190809225833.6657-5-ira.weiny@intel.com>
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

On FS DAX files users must inform the file system they intend to take
long term GUP pins on the file pages.  Failure to do so should result in
an error.

Ensure that a F_LAYOUT lease exists at the time the GUP call is made.
If not return EPERM.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from RFC v1:

    The old version had remnants of when GUP was going to take the lease
    for the user.  Remove this prototype code.
    Fix issue in gup_device_huge which was setting page reference prior
    to checking for Layout Lease
    Re-base to 5.3+
    Clean up htmldoc comments

 fs/locks.c         | 47 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h |  2 ++
 mm/gup.c           | 23 +++++++++++++++++++++++
 mm/huge_memory.c   | 12 ++++++++++++
 4 files changed, 84 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index 0c7359cdab92..14892c84844b 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2971,3 +2971,50 @@ static int __init filelock_init(void)
 	return 0;
 }
 core_initcall(filelock_init);
+
+/**
+ * mapping_inode_has_layout - ensure a file mapped page has a layout lease
+ * taken
+ * @page: page we are trying to GUP
+ *
+ * This should only be called on DAX pages.  DAX pages which are mapped through
+ * FS DAX do not use the page cache.  As a result they require the user to take
+ * a LAYOUT lease on them prior to be able to pin them for longterm use.
+ * This allows the user to opt-into the fact that truncation operations will
+ * fail for the duration of the pin.
+ *
+ * Return true if the page has a LAYOUT lease associated with it's file.
+ */
+bool mapping_inode_has_layout(struct page *page)
+{
+	bool ret = false;
+	struct inode *inode;
+	struct file_lock *fl;
+
+	if (WARN_ON(PageAnon(page)) ||
+	    WARN_ON(!page) ||
+	    WARN_ON(!page->mapping) ||
+	    WARN_ON(!page->mapping->host))
+		return false;
+
+	inode = page->mapping->host;
+
+	smp_mb();
+	if (inode->i_flctx &&
+	    !list_empty_careful(&inode->i_flctx->flc_lease)) {
+		spin_lock(&inode->i_flctx->flc_lock);
+		ret = false;
+		list_for_each_entry(fl, &inode->i_flctx->flc_lease, fl_list) {
+			if (fl->fl_pid == current->tgid &&
+			    (fl->fl_flags & FL_LAYOUT) &&
+			    (fl->fl_flags & FL_EXCLUSIVE)) {
+				ret = true;
+				break;
+			}
+		}
+		spin_unlock(&inode->i_flctx->flc_lock);
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mapping_inode_has_layout);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad6766a08f9b..04f22722b374 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1583,6 +1583,8 @@ int account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc);
 int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
 			struct task_struct *task, bool bypass_rlim);
 
+bool mapping_inode_has_layout(struct page *page);
+
 /* Container for pinned pfns / pages */
 struct frame_vector {
 	unsigned int nr_allocated;	/* Number of frames we have space for */
diff --git a/mm/gup.c b/mm/gup.c
index 80423779a50a..0b05e22ac05f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -221,6 +221,13 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
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
@@ -1847,6 +1854,14 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 
+		if (pte_devmap(pte) &&
+		    unlikely(flags & FOLL_LONGTERM) &&
+		    pgmap->type == MEMORY_DEVICE_FS_DAX &&
+		    !mapping_inode_has_layout(head)) {
+			put_user_page(head);
+			goto pte_unmap;
+		}
+
 		SetPageReferenced(page);
 		pages[*nr] = page;
 		(*nr)++;
@@ -1895,6 +1910,14 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 			undo_dev_pagemap(nr, nr_start, pages);
 			return 0;
 		}
+
+		if (unlikely(flags & FOLL_LONGTERM) &&
+		    pgmap->type == MEMORY_DEVICE_FS_DAX &&
+		    !mapping_inode_has_layout(page)) {
+			undo_dev_pagemap(nr, nr_start, pages);
+			return 0;
+		}
+
 		SetPageReferenced(page);
 		pages[*nr] = page;
 		get_page(page);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1334ede667a8..bc1a07a55be1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -953,6 +953,12 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 	if (!*pgmap)
 		return ERR_PTR(-EFAULT);
 	page = pfn_to_page(pfn);
+
+	if (unlikely(flags & FOLL_LONGTERM) &&
+	    (*pgmap)->type == MEMORY_DEVICE_FS_DAX &&
+	    !mapping_inode_has_layout(page))
+		return ERR_PTR(-EPERM);
+
 	get_page(page);
 
 	return page;
@@ -1093,6 +1099,12 @@ struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 	if (!*pgmap)
 		return ERR_PTR(-EFAULT);
 	page = pfn_to_page(pfn);
+
+	if (unlikely(flags & FOLL_LONGTERM) &&
+	    (*pgmap)->type == MEMORY_DEVICE_FS_DAX &&
+	    !mapping_inode_has_layout(page))
+		return ERR_PTR(-EPERM);
+
 	get_page(page);
 
 	return page;
-- 
2.20.1

