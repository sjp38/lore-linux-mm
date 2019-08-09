Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54FBCC32759
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16912208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16912208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F36EC6B026E; Fri,  9 Aug 2019 18:59:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE7D26B026F; Fri,  9 Aug 2019 18:59:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3C5B6B0270; Fri,  9 Aug 2019 18:59:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA2F6B026E
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:59:06 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d190so62312479pfa.0
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:59:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YBf7bCSsZFTvPoM1NYxMaQl2NfTT88MOelJjIEo0m6Y=;
        b=WaW5WKr+SZiyjDif0n0t2W3Qf/K2QCQhPuQ0+gCRPX2ajEq2FNmqqRg1OR7u0ulywy
         GuMhGfv8p82FEpU6sW7PxsNE/sjSiaVfPCk5Z1dGjJTWm50NRFPBEGThmBHq/MAF1SZZ
         vz8itvyFen5ogh10z2rq2/2IKqtWFU5Nd8s0APzI5RWNOCh2+lYcG93FrdXawKTLhmdv
         C2JeZEv1gcDimW9+2/s0fCPuvZDolex7CtwBMdG1cX/XxgGP4fCzwHtREMBo3Ug+MU1a
         pYg0st2S84DkQ2NQZgj8wG3UW9s9a5xu5HQ74O/0ThckWrwkevBbz169atSyGxXguew/
         +nag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWWri8wOxcxaRp5DB/2ypyIqRA2RDyFbPCIDqjnq1d7t/MHV3/I
	FlEk/d8BuR6AWI7skJB5zGzKq/75W/davYHuL2Zy0IAhRzWDhDDVHTx+++8XG6Xup0rK6Ddj+2H
	bETOpxMe4w+S3vXTJvvokogqF8VwkrpXyXvJmSlQVcsd8ntp+mPvNqiOnq9zpRiUA4A==
X-Received: by 2002:a17:902:6847:: with SMTP id f7mr20940565pln.311.1565391546289;
        Fri, 09 Aug 2019 15:59:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzremvC3hduSRFZjuEehK4Pj1m9Z/IwyTvWSPzFb1llLIZIxkaFJHll4INV1NuKnVL2UGXc
X-Received: by 2002:a17:902:6847:: with SMTP id f7mr20940529pln.311.1565391545525;
        Fri, 09 Aug 2019 15:59:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391545; cv=none;
        d=google.com; s=arc-20160816;
        b=k2tbJRo02dicPIEYaByZyWAFSHh+9EPCKhdALlG07vzlNSFIyG2o4bvX1mKVchkb3W
         lMlKJCPw8Vehv78ncHI3fs/Jc7k/JBmxuo39Vlsz/F/chOKUkeizKlDIuKUVRtG7QIUc
         p/etmiO9nNzmaHJC5ONzulHCS9o91KLCZvHk2x13IfQmra0bekncC8jhtYRc+DiP/Hl7
         o+GFX2rev9xQLX2RElkT+TTMZDAKnZKEZFXAJJPN+I3GVDDFfmNHQ+7EC7QqWMdOgCw6
         caF6WAb4qTUj4ixgRhTwy2uIIYfIsFQNmWAyyGrh1OB0TQBvhxkHKo1xIujDP3lJLud0
         6DBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=YBf7bCSsZFTvPoM1NYxMaQl2NfTT88MOelJjIEo0m6Y=;
        b=qroeHdRHiziJpmEFMx37ISZh573zxzqDpVmhP7sc9m+nDXdNW096eMGK6WyOCXebgk
         bDitxDIAQdr8d78H4lCOR8AEM+WzyVEscGUDiG+3Vnz/y/E0Whk3v1nVHhJoZXrF6ort
         Zb90Ym0VdlgUfcXDW1RnOiNKNcLVnRvrbQ0+/sfeGlM6F5voCBlK6ujTUFAxohxCWDff
         qYdHaTKCa18E7Sjt3z0B0/3QNQnboGE8XXU5T/qwgAivQ2rvghfum9uiY+HY17RT53Oi
         F3LQZolNDFLh2FoisDsbm/JSLCvidHImqIeGBWnZJ8JjwyC7hb8wS21+733b5qIkOMwM
         PgHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id i188si56395012pfe.96.2019.08.09.15.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:59:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:05 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="176932450"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga007-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:04 -0700
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
Subject: [RFC PATCH v2 15/19] mm/gup: Introduce vaddr_pin_pages()
Date: Fri,  9 Aug 2019 15:58:29 -0700
Message-Id: <20190809225833.6657-16-ira.weiny@intel.com>
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

The addition of FOLL_LONGTERM has taken on additional meaning for CMA
pages.

In addition subsystems such as RDMA require new information to be passed
to the GUP interface to track file owning information.  As such a simple
FOLL_LONGTERM flag is no longer sufficient for these users to pin pages.

Introduce a new GUP like call which takes the newly introduced vaddr_pin
information.  Failure to pass the vaddr_pin object back to a vaddr_put*
call will result in a failure if pins were created on files during the
pin operation.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from list:
	Change to vaddr_put_pages_dirty_lock
	Change to vaddr_unpin_pages_dirty_lock

 include/linux/mm.h |  5 ++++
 mm/gup.c           | 59 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 657c947bda49..90c5802866df 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1603,6 +1603,11 @@ int account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc);
 int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
 			struct task_struct *task, bool bypass_rlim);
 
+long vaddr_pin_pages(unsigned long addr, unsigned long nr_pages,
+		     unsigned int gup_flags, struct page **pages,
+		     struct vaddr_pin *vaddr_pin);
+void vaddr_unpin_pages_dirty_lock(struct page **pages, unsigned long nr_pages,
+				  struct vaddr_pin *vaddr_pin, bool make_dirty);
 bool mapping_inode_has_layout(struct vaddr_pin *vaddr_pin, struct page *page);
 
 /* Container for pinned pfns / pages */
diff --git a/mm/gup.c b/mm/gup.c
index eeaa0ddd08a6..6d23f70d7847 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2536,3 +2536,62 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	return ret;
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
+
+/**
+ * vaddr_pin_pages pin pages by virtual address and return the pages to the
+ * user.
+ *
+ * @addr, start address
+ * @nr_pages, number of pages to pin
+ * @gup_flags, flags to use for the pin
+ * @pages, array of pages returned
+ * @vaddr_pin, initalized meta information this pin is to be associated
+ * with.
+ *
+ * NOTE regarding vaddr_pin:
+ *
+ * Some callers can share pins via file descriptors to other processes.
+ * Callers such as this should use the f_owner field of vaddr_pin to indicate
+ * the file the fd points to.  All other callers should use the mm this pin is
+ * being made against.  Usually "current->mm".
+ *
+ * Expects mmap_sem to be read locked.
+ */
+long vaddr_pin_pages(unsigned long addr, unsigned long nr_pages,
+		     unsigned int gup_flags, struct page **pages,
+		     struct vaddr_pin *vaddr_pin)
+{
+	long ret;
+
+	gup_flags |= FOLL_LONGTERM;
+
+	if (!vaddr_pin || (!vaddr_pin->mm && !vaddr_pin->f_owner))
+		return -EINVAL;
+
+	ret = __gup_longterm_locked(current,
+				    vaddr_pin->mm,
+				    addr, nr_pages,
+				    pages, NULL, gup_flags,
+				    vaddr_pin);
+	return ret;
+}
+EXPORT_SYMBOL(vaddr_pin_pages);
+
+/**
+ * vaddr_unpin_pages_dirty_lock - counterpart to vaddr_pin_pages
+ *
+ * @pages, array of pages returned
+ * @nr_pages, number of pages in pages
+ * @vaddr_pin, same information passed to vaddr_pin_pages
+ * @make_dirty: whether to mark the pages dirty
+ *
+ * The semantics are similar to put_user_pages_dirty_lock but a vaddr_pin used
+ * in vaddr_pin_pages should be passed back into this call for propper
+ * tracking.
+ */
+void vaddr_unpin_pages_dirty_lock(struct page **pages, unsigned long nr_pages,
+				  struct vaddr_pin *vaddr_pin, bool make_dirty)
+{
+	__put_user_pages_dirty_lock(vaddr_pin, pages, nr_pages, make_dirty);
+}
+EXPORT_SYMBOL(vaddr_unpin_pages_dirty_lock);
-- 
2.20.1

