Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FA18C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:17:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C2CB214AF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:17:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C2CB214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B1828E0004; Tue, 12 Mar 2019 10:17:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 920CF8E0006; Tue, 12 Mar 2019 10:17:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E96E8E0005; Tue, 12 Mar 2019 10:17:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 23EEB8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:17:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x13so1162091edq.11
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:17:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QjxejvXZfx3iwKfTotkvh/SLhkUtiu62B/h1whThaVA=;
        b=BVSzgVdJ9LJOlE813USMsGikZwOH754xQORSwzbJhoHS3NdjkvLiMdCvlSn38/GQpH
         Ayav10PEGzZIpsXlQMSPoADGQth6YFyc/dc3Zz0VXmcnsuWxKtvAeJFUqAZjyTNvbCMm
         G/N5Mrsv1BD4gU8qN3pb5wtBzTNKfTwnmZ0OXF/2uwqwTj8+ebvrDAqnWmQMFy4zmxd2
         iKt6f+iU2XXtUMDTHnG9YQI1CMfmgzOj/QzeYh5ZV40kRqWy1TWA0xpaH8962++bPaT/
         gXhjwK3u1S8H2C4fV1c2fV3uyrtKo4fPAC9gM5JvdjoAmMTvw47GZ2Uf++NRzab28p2/
         6ScQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUD5NABt/ATM/93Mc4JTlJYU1SR+VAEpyJwRxfxbx/+YcBIUPuo
	9RmpHjjJfFpkD7feuTDSXtR/0fHaE5kCL/4NPAeS02K15DsdjxagIf11WeUTUr7ZBAUQmfKy307
	QlaJRWJA+PEn67V8etYbr4KRC9DoGEC2ENuXFzdr9VVhlJhGjMlxbQbmTBQp4K20lmA==
X-Received: by 2002:a05:6402:1807:: with SMTP id g7mr3620801edy.184.1552400274636;
        Tue, 12 Mar 2019 07:17:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1I2E5RJUWs5T7+fX1UKU0WjrozazC26BsWMjcVaL69aThjbrYEfG+ErYZPjsKGsLfdrgg
X-Received: by 2002:a05:6402:1807:: with SMTP id g7mr3620745edy.184.1552400273552;
        Tue, 12 Mar 2019 07:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552400273; cv=none;
        d=google.com; s=arc-20160816;
        b=BE69dnVgClNQyBvzuUByNzZDLQU04H8j20NZQkJTgbF9UZokXxW/GAOzwcb7nMck0I
         V4zGmnQ3XCa28zS2U8Ct2ISHc/wdmz+DAgVRt6lwqpCdbr21pIzm/RrxStd1UlDupNNQ
         TH7QrimK3SmjLVv4/EHqweQ8h2C9rF+0CEnhhOwyX2AWHTwP92zFzcH0T9cNNEMQVBUt
         gOJ5FcnFJag9opsyUMyu5jLzBZgDlDb3E3TL7PcMNimlEH1BOPhVUb+EYIimmRbjMVcQ
         zvxOMNd34kfyJD0svJdwVG+U/zt7iHqTTjoIy6oiERhg19W3segTK/mpDi0YIUM/t1on
         jAWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QjxejvXZfx3iwKfTotkvh/SLhkUtiu62B/h1whThaVA=;
        b=dN9fgkbXSEguffLDQhg47iomqq9kmZSjTGzheOJ0kH2VcgztzXISBMjRP0d2aaa5tj
         3mql0tekmDHX5H3nTJfUAwuCkqn4sYWytYOLNTxtF3NYw3j7OfPXGDTu199Eh3NWkAEM
         cFRgpFytKI9LU+P0PVOjWmF90aES0vJ+pwbELREGNYYrvXKMyNMBi2kD5DBSsnRFuu45
         BUH9Hsgk7ivQDlbuHqDFfn6fknhjFmdCf/S4ta2s6fM/TDCO0p14kpgaS1b0uVJbV2kn
         xQDi4DQdQQ8rqeyeL2slH9HfkAoDyeOkMUWr0gJ/SWPL5pAV+e+1Os54lItfeWqEKwOv
         vwfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s33si744524edd.306.2019.03.12.07.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 07:17:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A6619B63E;
	Tue, 12 Mar 2019 14:17:52 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>,
	Jiri Kosina <jikos@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>,
	Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>,
	Jiri Kosina <jkosina@suse.cz>,
	Josh Snyder <joshs@netflix.com>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH v2 2/2] mm/mincore: provide mapped status when cached status is not allowed
Date: Tue, 12 Mar 2019 15:17:08 +0100
Message-Id: <20190312141708.6652-3-vbabka@suse.cz>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190312141708.6652-1-vbabka@suse.cz>
References: <20190130124420.1834-1-vbabka@suse.cz>
 <20190312141708.6652-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After "mm/mincore: make mincore() more conservative" we sometimes restrict the
information about page cache residency, which needs to be done without breaking
existing userspace, as much as possible. Instead of returning with error, we
thus fake the results. For that we return residency values as 1, which should
be safer than faking them as 0, as there might theoretically exist code that
would try to fault in the page(s) in a loop until mincore() returns 1 for them.

Faking 1 however means that such code would not fault in a page even if it was
not truly in page cache, with possibly unwanted performance implications. We
can improve the situation by revisting the approach of 574823bfab82 ("Change
mincore() to count "mapped" pages rather than "cached" pages"), later reverted
by 30bac164aca7 and replaced by restricting/faking the results. In this patch
we apply the approach only to cases where page cache residency check is
restricted. Thus mincore() will return 0 for an unmapped page (which may or may
not be resident in a pagecache), and 1 after the process faults it in.

One potential downside is that mincore() users will be now able to recognize
when a previously mapped page was reclaimed. While that might be useful for
some attack scenarios, it is not as crucial as recognizing that somebody else
faulted the page in, which is the main reason we are making mincore() more
conservative. For detecting that pages being reclaimed, there are also other
existing ways anyway.

Cc: Jiri Kosina <jikos@kernel.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Kevin Easton <kevin@guarana.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Cyril Hrubis <chrubis@suse.cz>
Cc: Tejun Heo <tj@kernel.org>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Daniel Gruss <daniel@gruss.cc>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mincore.c | 67 +++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 51 insertions(+), 16 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index c3f058bd0faf..c9a265abc631 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -21,12 +21,23 @@
 #include <linux/uaccess.h>
 #include <asm/pgtable.h>
 
+/*
+ * mincore() page walk's private structure. Contains pointer to the array
+ * of return values to be set, and whether the current vma passed the
+ * can_do_mincore() check.
+ */
+struct mincore_walk_private {
+	unsigned char *vec;
+	bool can_check_pagecache;
+};
+
 static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
 			unsigned long end, struct mm_walk *walk)
 {
 #ifdef CONFIG_HUGETLB_PAGE
 	unsigned char present;
-	unsigned char *vec = walk->private;
+	struct mincore_walk_private *walk_private = walk->private;
+	unsigned char *vec = walk_private->vec;
 
 	/*
 	 * Hugepages under user process are always in RAM and never
@@ -35,7 +46,7 @@ static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
 	present = pte && !huge_pte_none(huge_ptep_get(pte));
 	for (; addr != end; vec++, addr += PAGE_SIZE)
 		*vec = present;
-	walk->private = vec;
+	walk_private->vec = vec;
 #else
 	BUG();
 #endif
@@ -85,7 +96,8 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 }
 
 static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
-				struct vm_area_struct *vma, unsigned char *vec)
+				struct vm_area_struct *vma, unsigned char *vec,
+				bool can_check_pagecache)
 {
 	unsigned long nr = (end - addr) >> PAGE_SHIFT;
 	int i;
@@ -95,7 +107,14 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
 
 		pgoff = linear_page_index(vma, addr);
 		for (i = 0; i < nr; i++, pgoff++)
-			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
+			/*
+			 * Return page cache residency state if we are allowed
+			 * to, otherwise return mapping state, which is 0 for
+			 * an unmapped range.
+			 */
+			vec[i] = can_check_pagecache ?
+				 mincore_page(vma->vm_file->f_mapping, pgoff)
+				 : 0;
 	} else {
 		for (i = 0; i < nr; i++)
 			vec[i] = 0;
@@ -106,8 +125,11 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
 static int mincore_unmapped_range(unsigned long addr, unsigned long end,
 				   struct mm_walk *walk)
 {
-	walk->private += __mincore_unmapped_range(addr, end,
-						  walk->vma, walk->private);
+	struct mincore_walk_private *walk_private = walk->private;
+	unsigned char *vec = walk_private->vec;
+
+	walk_private->vec += __mincore_unmapped_range(addr, end, walk->vma,
+				vec, walk_private->can_check_pagecache);
 	return 0;
 }
 
@@ -117,7 +139,8 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	spinlock_t *ptl;
 	struct vm_area_struct *vma = walk->vma;
 	pte_t *ptep;
-	unsigned char *vec = walk->private;
+	struct mincore_walk_private *walk_private = walk->private;
+	unsigned char *vec = walk_private->vec;
 	int nr = (end - addr) >> PAGE_SHIFT;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
@@ -128,7 +151,8 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	}
 
 	if (pmd_trans_unstable(pmd)) {
-		__mincore_unmapped_range(addr, end, vma, vec);
+		__mincore_unmapped_range(addr, end, vma, vec,
+					walk_private->can_check_pagecache);
 		goto out;
 	}
 
@@ -138,7 +162,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 		if (pte_none(pte))
 			__mincore_unmapped_range(addr, addr + PAGE_SIZE,
-						 vma, vec);
+				 vma, vec, walk_private->can_check_pagecache);
 		else if (pte_present(pte))
 			*vec = 1;
 		else { /* pte is a swap entry */
@@ -152,8 +176,20 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 				*vec = 1;
 			} else {
 #ifdef CONFIG_SWAP
-				*vec = mincore_page(swap_address_space(entry),
+				/*
+				 * If tmpfs pages are being swapped out, treat
+				 * it with same restrictions on mincore() as
+				 * the page cache so we don't expose that
+				 * somebody else brought them back from swap.
+				 * In the restricted case return 0 as swap
+				 * entry means the page is not mapped.
+				 */
+				if (walk_private->can_check_pagecache)
+					*vec = mincore_page(
+						    swap_address_space(entry),
 						    swp_offset(entry));
+				else
+					*vec = 0;
 #else
 				WARN_ON(1);
 				*vec = 1;
@@ -195,22 +231,21 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	struct vm_area_struct *vma;
 	unsigned long end;
 	int err;
+	struct mincore_walk_private walk_private = {
+		.vec = vec
+	};
 	struct mm_walk mincore_walk = {
 		.pmd_entry = mincore_pte_range,
 		.pte_hole = mincore_unmapped_range,
 		.hugetlb_entry = mincore_hugetlb,
-		.private = vec,
+		.private = &walk_private
 	};
 
 	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
 	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
-	if (!can_do_mincore(vma)) {
-		unsigned long pages = DIV_ROUND_UP(end - addr, PAGE_SIZE);
-		memset(vec, 1, pages);
-		return pages;
-	}
+	walk_private.can_check_pagecache = can_do_mincore(vma);
 	mincore_walk.mm = vma->vm_mm;
 	err = walk_page_range(addr, end, &mincore_walk);
 	if (err < 0)
-- 
2.20.1

