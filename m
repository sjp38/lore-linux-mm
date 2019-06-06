Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3FBDC28D18
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99F7E2089E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99F7E2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 942C66B0279; Wed,  5 Jun 2019 21:45:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A38F6B027A; Wed,  5 Jun 2019 21:45:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 721C26B027B; Wed,  5 Jun 2019 21:45:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33A1D6B0279
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:45:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id m12so506736pls.10
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:45:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PNYBk/3BEslXLtRMKRLhSbGGd0Jj/+WqkjRHb0gPhHk=;
        b=Q7OrF9vj1d6I/kU5P7AoCnp7pI1oSgyLgS05/7yEyPPcbbNL0mgqu6t9ymXylee+/u
         rODtpqlSJScOjTF9KajY4sQr22IcKj7QC2syQF3AKRYSGSl0Vbta7Fe9WuyHz0++EDXr
         30wBTupZbhMT8MlSFrcS1Dg+LhZTgipnmZZ/2JdlkHZ0y981h2WcYUtPnUlGOiNUzoRQ
         LyFpAK1POI+sHI9OFmoyENIJufUTesJtM7yPxuoqFqe6RqyDSI6VoVZFo7o7CKa+Mc6e
         SSe3KtRYQuVxiCiktthjnEJ5t5Rrstpi11/YfottyD68MI4Opp9numXDjLTCFdtwKNjS
         JqjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVwhweuqgU8RukSaPNzzptWUYSEL/BMRTlckMH9m3FknmJjOJeS
	+GEaKSXiC2OLTt8re/M0TE7LhezWJNQQ5yrB1EveWStZLv+XlsxlRO/+jN+zr46EUIESlagpzw2
	RZ18QiIvcPj8bSVKPwaJzlyzTtSrj9whVVfskbe22+KkfWsoffScephrvNSy1sFbITA==
X-Received: by 2002:a17:90a:7f93:: with SMTP id m19mr31278285pjl.73.1559785528859;
        Wed, 05 Jun 2019 18:45:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxb+syro6M2WaR4q7Qy8CLb7S98AUF0GVfkxT7fvVNyAIBIAR9dCJHpdRyX+LYBc3lJWwR
X-Received: by 2002:a17:90a:7f93:: with SMTP id m19mr31278241pjl.73.1559785528037;
        Wed, 05 Jun 2019 18:45:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559785528; cv=none;
        d=google.com; s=arc-20160816;
        b=XErr++NbsLbDnfjm8rq9n6uB7NI4is9lpmqGSbmaQUipOME1L76kM91rA1NzOg4AlU
         QseatNqCZCw6nMjlBGmolEF/AwJSSqpRnvkm1z5fCC3EBgeNceDrENwFKP/ozSwg2o5G
         nY18ldTYU4VvOW4S7twcP8Z/dkKr8opLGTFHdKEnaVWlLJdjofa/baiBsfU49/Fr2wlq
         lsWHnWXJZBSEImin/NNxlQVRvahF4LNq9oauYwax86ots+hifQIi9iu5t5vYj5lx5MIh
         4Qb6V2fDS7jA/YcMvfJU1/FXxj5+oUyH+vkt3/Fuc4uJnMLGN8EiJUcCSNfjRuuMA+6C
         gqUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PNYBk/3BEslXLtRMKRLhSbGGd0Jj/+WqkjRHb0gPhHk=;
        b=wUK0SL1JlGAo3Qr4WKETTVd0ibLt2p74xu/TkPS1umywBKuJNARgUSGmi4M0frsTWr
         rUH2H/HVdiHY03zM4yaSg6dfmcEvOjWRL7IbWGNx3hsB1zl3EHrxZYEme/mbqcam+uiA
         vuifV2Ta9lL1eYiDVDi5aFFAY8DH70b+JYpG8aQ+KeJRSnv1nCQvdkDGv6SSB0j4YAzx
         WvavdqVxIiHuWlUs9aHGzds+gAsorVuLqCwEVnFzOxpEx0/KGlzGfhqvT5fO9SvmdUO1
         Kj/RSZ7zZQc8/lJVFL4iS/ilL93boIsi8E4+mU712m/wFzCfZzaMtfwKjxNC6uiYnm7W
         niwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 71si254942plf.156.2019.06.05.18.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:45:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 18:45:27 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 05 Jun 2019 18:45:26 -0700
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
Subject: [PATCH RFC 10/10] mm/gup: Remove FOLL_LONGTERM DAX exclusion
Date: Wed,  5 Jun 2019 18:45:43 -0700
Message-Id: <20190606014544.8339-11-ira.weiny@intel.com>
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

Now that there is a mechanism for users to safely take LONGTERM pins on
FS DAX pages, remove the FS DAX exclusion from GUP with FOLL_LONGTERM.

Special processing remains in effect for CONFIG_CMA

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 mm/gup.c | 78 ++++++--------------------------------------------------
 1 file changed, 8 insertions(+), 70 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index d06cc5b14c0b..4f6e5606b81e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1392,26 +1392,6 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(get_user_pages_remote);
 
-#if defined(CONFIG_FS_DAX) || defined (CONFIG_CMA)
-static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
-{
-	long i;
-	struct vm_area_struct *vma_prev = NULL;
-
-	for (i = 0; i < nr_pages; i++) {
-		struct vm_area_struct *vma = vmas[i];
-
-		if (vma == vma_prev)
-			continue;
-
-		vma_prev = vma;
-
-		if (vma_is_fsdax(vma))
-			return true;
-	}
-	return false;
-}
-
 #ifdef CONFIG_CMA
 static struct page *new_non_cma_page(struct page *page, unsigned long private)
 {
@@ -1542,18 +1522,6 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 
 	return nr_pages;
 }
-#else
-static long check_and_migrate_cma_pages(struct task_struct *tsk,
-					struct mm_struct *mm,
-					unsigned long start,
-					unsigned long nr_pages,
-					struct page **pages,
-					struct vm_area_struct **vmas,
-					unsigned int gup_flags)
-{
-	return nr_pages;
-}
-#endif
 
 /*
  * __gup_longterm_locked() is a wrapper for __get_user_pages_locked which
@@ -1567,49 +1535,28 @@ static long __gup_longterm_locked(struct task_struct *tsk,
 				  struct vm_area_struct **vmas,
 				  unsigned int gup_flags)
 {
-	struct vm_area_struct **vmas_tmp = vmas;
 	unsigned long flags = 0;
-	long rc, i;
+	long rc;
 
-	if (gup_flags & FOLL_LONGTERM) {
-		if (!pages)
-			return -EINVAL;
-
-		if (!vmas_tmp) {
-			vmas_tmp = kcalloc(nr_pages,
-					   sizeof(struct vm_area_struct *),
-					   GFP_KERNEL);
-			if (!vmas_tmp)
-				return -ENOMEM;
-		}
+	if (flags & FOLL_LONGTERM)
 		flags = memalloc_nocma_save();
-	}
 
 	rc = __get_user_pages_locked(tsk, mm, start, nr_pages, pages,
-				     vmas_tmp, NULL, gup_flags);
+				     vmas, NULL, gup_flags);
 
 	if (gup_flags & FOLL_LONGTERM) {
 		memalloc_nocma_restore(flags);
 		if (rc < 0)
 			goto out;
 
-		if (check_dax_vmas(vmas_tmp, rc)) {
-			for (i = 0; i < rc; i++)
-				put_page(pages[i]);
-			rc = -EOPNOTSUPP;
-			goto out;
-		}
-
 		rc = check_and_migrate_cma_pages(tsk, mm, start, rc, pages,
-						 vmas_tmp, gup_flags);
+						 vmas, gup_flags);
 	}
 
 out:
-	if (vmas_tmp != vmas)
-		kfree(vmas_tmp);
 	return rc;
 }
-#else /* !CONFIG_FS_DAX && !CONFIG_CMA */
+#else /* !CONFIG_CMA */
 static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
 						  struct mm_struct *mm,
 						  unsigned long start,
@@ -1621,7 +1568,7 @@ static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
 				       NULL, flags);
 }
-#endif /* CONFIG_FS_DAX || CONFIG_CMA */
+#endif /* CONFIG_CMA */
 
 /*
  * This is the same as get_user_pages_remote(), just with a
@@ -1882,9 +1829,6 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			goto pte_unmap;
 
 		if (pte_devmap(pte)) {
-			if (unlikely(flags & FOLL_LONGTERM))
-				goto pte_unmap;
-
 			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
 			if (unlikely(!pgmap)) {
 				undo_dev_pagemap(nr, nr_start, pages);
@@ -2057,12 +2001,9 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	if (!pmd_access_permitted(orig, flags & FOLL_WRITE))
 		return 0;
 
-	if (pmd_devmap(orig)) {
-		if (unlikely(flags & FOLL_LONGTERM))
-			return 0;
+	if (pmd_devmap(orig))
 		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr,
 					     flags);
-	}
 
 	refs = 0;
 	page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
@@ -2101,12 +2042,9 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 	if (!pud_access_permitted(orig, flags & FOLL_WRITE))
 		return 0;
 
-	if (pud_devmap(orig)) {
-		if (unlikely(flags & FOLL_LONGTERM))
-			return 0;
+	if (pud_devmap(orig))
 		return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr,
 					     flags);
-	}
 
 	refs = 0;
 	page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
-- 
2.20.1

