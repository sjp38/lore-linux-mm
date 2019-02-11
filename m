Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A7B6C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:17:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3EB2217FA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:17:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3EB2217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D49F58E0154; Mon, 11 Feb 2019 15:17:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C32C78E0134; Mon, 11 Feb 2019 15:17:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A813D8E0154; Mon, 11 Feb 2019 15:17:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67B9F8E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:17:07 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id l9so143413plt.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:17:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jVNOA9HfNnBBWM4K63/t8TJ2OL6pPpY/Hp9DuePEfDc=;
        b=Xa4srTxKyWJQA3D6+92f8x10gOf71pvuZKYhEPw1zD+ro9H5Ck4wNDh6JntmOXMx42
         cd+VZf7nFOLRRfYq1wj8CVtM0LAUzN5zhoRopSJtTqLgHI+mTKm/HmsA2o1HjMhlB1ST
         j2Bq6ByHgdcFU7iANiLau2WwkmIBvZKilSfootUxN35tymJslNTfyvPoEMGsuKYDYAsT
         ICn4lwU1aJO/qGgtOKBjCruZ+ukLKTjOxkjpud6rGmJB18kfH1qgtYyZTF3v/970NUBl
         evZFQ4YXq2eJfmsDGLOqmP7FAZK74+uKmqbfY25WVzE9z/VAaVL3d8wg0+UNScpwPJfi
         asVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY4fLMjYq0yYDmEQviXPcIsyw70o6wRhoJFGtV+Xh4QOF/3q3sJ
	y1VpqvoWJzjpHkReyfnv9JYKId+bj70HA1UXoXoAymsfEMNih6pXNVUnnEDfqaOUZgpwDx96jSQ
	y9URAzZYDxMoLtQ/MEo/7WtbjYMHuVgNF0FRRa0K4ZkIGVyv9ZkjAB+tvXAqBa9TfjA==
X-Received: by 2002:a17:902:925:: with SMTP id 34mr45318plm.14.1549916227076;
        Mon, 11 Feb 2019 12:17:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYp0nYPMRpjWDZhzM7VbyF+okHwGLv/TPvighAJQnYFmyB2vz7Zb26tYblIgLpGEVWMrtgY
X-Received: by 2002:a17:902:925:: with SMTP id 34mr45247plm.14.1549916226035;
        Mon, 11 Feb 2019 12:17:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549916226; cv=none;
        d=google.com; s=arc-20160816;
        b=gGGWraZcbZk4x5lWGqT7ltlchg/adtF0mYCHYQzAw5bk64Loc7XezhbO/W/4Q6aohu
         4uu4YNUUYyMBQ7pwKPmNXWyaX7DO1OZ9n4fTB4hatnjTtSeVsADIAZVFecSAdZcPDdrP
         7Wix/WvTEA1N3s1Fu6cIja3B12OoXleanAcapKJjeM33nDDHn1fneWZ2YOFd7PaqF9zQ
         8QuC5gYaPz99lVrTrl3kQIJgECxilCpE+p11w8Gw2ivR3qVG8qG4bFHxDLBEE5cMDdhR
         2NTKzHFrNDkw483/vGCOubHonlyWnXYiH2C9YoaZVgemjkDbyLuXHDRG+5XIR+CXrywA
         7WHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jVNOA9HfNnBBWM4K63/t8TJ2OL6pPpY/Hp9DuePEfDc=;
        b=jElPgKJ6FCWxlfOGp+zMYb3teW1DCnW6xTanN2LlURx02+LHJw4TQbqx2TLuR1u7cw
         j1HldSjx7rfW81Bqq1K2csV3xiL8ihRLToqC3EvzUADznwpyJZ+IHL5cnJs/us5KgkAw
         cr5sIiAOn4wcdGhtUv837FCFN7uKKpOFXLt17z+T00sABb79sfGRfCT9q5FtM85e4ON3
         7OT5obBJBFoBG54AwYnRiIJddfLiJNahbzfKr6aVf4s1OB6yOzX1cQlKb+mmYhXM3AAQ
         uHzq/vX8GQ01JELIsK//mg1JBe6vl8Q/0PnmkpWmWOvk6VcQ3wFfK0UOkKawJZeAsGdO
         chrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v1si10376043plp.12.2019.02.11.12.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 12:17:06 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 12:17:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="319498288"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 11 Feb 2019 12:17:05 -0800
From: ira.weiny@intel.com
To: linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>,
	netdev@vger.kernel.org
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
Date: Mon, 11 Feb 2019 12:16:42 -0800
Message-Id: <20190211201643.7599-3-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190211201643.7599-1-ira.weiny@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Users of get_user_pages_fast are not protected against mapping
pages within FS DAX.  Introduce a call which protects them.

We do this by checking for DEVMAP pages during the fast walk and
falling back to the longterm gup call to check for FS DAX if needed.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 include/linux/mm.h |   8 ++++
 mm/gup.c           | 102 +++++++++++++++++++++++++++++++++++----------
 2 files changed, 88 insertions(+), 22 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..8f831c823630 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1540,6 +1540,8 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    struct vm_area_struct **vmas);
+int get_user_pages_fast_longterm(unsigned long start, int nr_pages, bool write,
+				 struct page **pages);
 #else
 static inline long get_user_pages_longterm(unsigned long start,
 		unsigned long nr_pages, unsigned int gup_flags,
@@ -1547,6 +1549,11 @@ static inline long get_user_pages_longterm(unsigned long start,
 {
 	return get_user_pages(start, nr_pages, gup_flags, pages, vmas);
 }
+static inline int get_user_pages_fast_longterm(unsigned long start, int nr_pages,
+					       bool write, struct page **pages)
+{
+	return get_user_pages_fast(start, nr_pages, write, pages);
+}
 #endif /* CONFIG_FS_DAX */
 
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
@@ -2615,6 +2622,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
 #define FOLL_COW	0x4000	/* internal GUP flag */
 #define FOLL_ANON	0x8000	/* don't do file mappings */
+#define FOLL_LONGTERM	0x10000	/* mapping is intended for a long term pin */
 
 static inline int vm_fault_to_errno(vm_fault_t vm_fault, int foll_flags)
 {
diff --git a/mm/gup.c b/mm/gup.c
index 894ab014bd1e..f7d86a304405 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1190,6 +1190,21 @@ long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
 EXPORT_SYMBOL(get_user_pages_longterm);
 #endif /* CONFIG_FS_DAX */
 
+static long get_user_pages_longterm_unlocked(unsigned long start,
+					     unsigned long nr_pages,
+					     struct page **pages,
+					     unsigned int gup_flags)
+{
+	struct mm_struct *mm = current->mm;
+	long ret;
+
+	down_read(&mm->mmap_sem);
+	ret = get_user_pages_longterm(start, nr_pages, gup_flags, pages, NULL);
+	up_read(&mm->mmap_sem);
+
+	return ret;
+}
+
 /**
  * populate_vma_page_range() -  populate a range of pages in the vma.
  * @vma:   target vma
@@ -1417,6 +1432,9 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			goto pte_unmap;
 
 		if (pte_devmap(pte)) {
+			if (flags & FOLL_LONGTERM)
+				goto pte_unmap;
+
 			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
 			if (unlikely(!pgmap)) {
 				undo_dev_pagemap(nr, nr_start, pages);
@@ -1556,8 +1574,12 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	if (!pmd_access_permitted(orig, flags & FOLL_WRITE))
 		return 0;
 
-	if (pmd_devmap(orig))
+	if (pmd_devmap(orig)) {
+		if (flags & FOLL_LONGTERM)
+			return 0;
+
 		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
+	}
 
 	refs = 0;
 	page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
@@ -1837,24 +1859,9 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	return nr;
 }
 
-/**
- * get_user_pages_fast() - pin user pages in memory
- * @start:	starting user address
- * @nr_pages:	number of pages from start to pin
- * @write:	whether pages will be written to
- * @pages:	array that receives pointers to the pages pinned.
- *		Should be at least nr_pages long.
- *
- * Attempt to pin user pages in memory without taking mm->mmap_sem.
- * If not successful, it will fall back to taking the lock and
- * calling get_user_pages().
- *
- * Returns number of pages pinned. This may be fewer than the number
- * requested. If nr_pages is 0 or negative, returns 0. If no pages
- * were pinned, returns -errno.
- */
-int get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			struct page **pages)
+static int __get_user_pages_fast_flags(unsigned long start, int nr_pages,
+				       unsigned int gup_flags,
+				       struct page **pages)
 {
 	unsigned long addr, len, end;
 	int nr = 0, ret = 0;
@@ -1872,7 +1879,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
-		gup_pgd_range(addr, end, write ? FOLL_WRITE : 0, pages, &nr);
+		gup_pgd_range(addr, end, gup_flags, pages, &nr);
 		local_irq_enable();
 		ret = nr;
 	}
@@ -1882,8 +1889,14 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
-				write ? FOLL_WRITE : 0);
+		if (gup_flags & FOLL_LONGTERM)
+			ret = get_user_pages_longterm_unlocked(start,
+							       nr_pages - nr,
+							       pages,
+							       gup_flags);
+		else
+			ret = get_user_pages_unlocked(start, nr_pages - nr,
+						      pages, gup_flags);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
@@ -1897,4 +1910,49 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	return ret;
 }
 
+/**
+ * get_user_pages_fast() - pin user pages in memory
+ * @start:	starting user address
+ * @nr_pages:	number of pages from start to pin
+ * @write:	whether pages will be written to
+ * @pages:	array that receives pointers to the pages pinned.
+ *		Should be at least nr_pages long.
+ *
+ * Attempt to pin user pages in memory without taking mm->mmap_sem.
+ * If not successful, it will fall back to taking the lock and
+ * calling get_user_pages().
+ *
+ * Returns number of pages pinned. This may be fewer than the number
+ * requested. If nr_pages is 0 or negative, returns 0. If no pages
+ * were pinned, returns -errno.
+ */
+int get_user_pages_fast(unsigned long start, int nr_pages, int write,
+			struct page **pages)
+{
+	return __get_user_pages_fast_flags(start, nr_pages,
+					   write ? FOLL_WRITE : 0,
+					   pages);
+}
+
+#ifdef CONFIG_FS_DAX
+/**
+ * get_user_pages_fast_longterm() - pin user pages in memory
+ *
+ * Exactly the same semantics as get_user_pages_fast() except fails mappings
+ * device mapped pages (such as DAX pages) which then fall back to checking for
+ * FS DAX pages with get_user_pages_longterm().
+ */
+int get_user_pages_fast_longterm(unsigned long start, int nr_pages, bool write,
+				 struct page **pages)
+{
+	unsigned int gup_flags = FOLL_LONGTERM;
+
+	if (write)
+		gup_flags |= FOLL_WRITE;
+
+	return __get_user_pages_fast_flags(start, nr_pages, gup_flags, pages);
+}
+EXPORT_SYMBOL(get_user_pages_fast_longterm);
+#endif /* CONFIG_FS_DAX */
+
 #endif /* CONFIG_HAVE_GENERIC_GUP */
-- 
2.20.1

