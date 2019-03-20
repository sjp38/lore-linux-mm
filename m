Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE7AEC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E7EE217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E7EE217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B3B86B0276; Tue, 19 Mar 2019 22:09:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43B456B0278; Tue, 19 Mar 2019 22:09:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DE016B0279; Tue, 19 Mar 2019 22:09:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 07FAF6B0276
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:09:30 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d49so911013qtk.8
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:09:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=g4CUT7wn2ZfM204z66Iujtc9aw73Tdzc6nKReP/7dxM=;
        b=SYz5HF1xq5xQLhHqswgYasbX8cHMbK/VA9/x7voQl5HlWSKIopYT1QC8basFhU4z4M
         AUtfMaj0G94gWYx4FOz7ocnaach5OhEvIKuViHMmCa/lY2bWP2jfpYgXrThk2O9flFNm
         ShQfAL3BFyFKsG14wZFArQjUkh/DB6QWK66kgBAt7Ukx1feXtM40xHhrhEbND+Jn2aHM
         PBZqryowXie+stxDPgnrlMj8Fsg33Ek2wpqM+RosTdrop+RnmrIHwBsVzxutrLmLL6K6
         VBd53mincweR1JVIiHhBbXT3Q5MFGi6CyrJHXUnVPABJkqH4gSnEqcvd3fDcAR/e9wHU
         pZbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW4XNsAEnpk9hfzrqJuVvStmEc0ZRF5quXqEuo+dgH8N+/FJHyR
	MQ1PenOqaEWBlZBGXv+if0hzPhgq3bwPP86aSYrXSo2cFfnKuDE/X7i0Z9aLQIP1e4rYZCTKEFf
	7GK1WtOADKldSIBU5KAypfDc7AUysUJArvT/KXZgwhKPJERo2SeKQk8MX6xrkLofUGg==
X-Received: by 2002:ac8:84a:: with SMTP id x10mr4983466qth.273.1553047769816;
        Tue, 19 Mar 2019 19:09:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsnAMrIwwmZY57jGNJSwLVFF3jy856pxFl9BwIpjTHUdWwQvjs4BCMAUGkf+G9611s/NQ2
X-Received: by 2002:ac8:84a:: with SMTP id x10mr4983397qth.273.1553047768736;
        Tue, 19 Mar 2019 19:09:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047768; cv=none;
        d=google.com; s=arc-20160816;
        b=PA22os9epbpNclI+AMv2Dop5/FzPYiVJtfXfbvB7XmvQ2HVC3kq1pw70W0FPJVrcEp
         qEJ8aJ//YvcG4H/Vl2JLcP9qxmvr6Z2l36ut+wzQT24+jiayIZiDtbJEarFmiJQ2Sj3K
         td5Xenl/RoF5m7u+KSJAo11suE+PZzB1mNs4Fa17zzFuE59vd0vcj8cZD+Z/oPTq2wZ2
         I96ntqllwKU+aUPMMceRmNCr7V7+3vDG+PJG3uBbY3yMi+ZT1Epd7zcxUKCvVqv//Jyb
         Azj1pFCEJ/psHFLRXBpAD4de5/WLqtnEOjDof8jiZhWh9KazL+sifMsduu2IsmVc/Han
         ksMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=g4CUT7wn2ZfM204z66Iujtc9aw73Tdzc6nKReP/7dxM=;
        b=Zni6VQAuDcRpzi1lc8HTw+2BbZjOE0PGiD1aQVlCIRbZBcoc/SfWxqUoP6bZSWxwpR
         sCw9yXYyemager6FOU2uUuw8JHhcaaTvpmXq3SkdL6huFRhZGnH2GEFVtNWqa/9VBPEq
         LzHcVh6nXVPbplo3Uk0fIG/PXUvYROS2OASJoY43zxYVCXbCsoVCU1vbu+7p04ukeGvN
         yoUuMOA+2Us9AJf4MNvHFNpmXADMtqlb+aKIYQdEI+EL84PvBi0eCDr+BEB6m0B2lsxc
         ZegVrkaANsgZBHRrkLndozVAAjF17CC0DlcWY3u5HZ+k0EWwLzOg+KcP6RWCfDW43fy/
         8Kuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u18si213087qvi.216.2019.03.19.19.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:09:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B383680462;
	Wed, 20 Mar 2019 02:09:27 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1382F6014C;
	Wed, 20 Mar 2019 02:09:17 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 19/28] userfaultfd: introduce helper vma_find_uffd
Date: Wed, 20 Mar 2019 10:06:33 +0800
Message-Id: <20190320020642.4000-20-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 20 Mar 2019 02:09:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We've have multiple (and more coming) places that would like to find a
userfault enabled VMA from a mm struct that covers a specific memory
range.  This patch introduce the helper for it, meanwhile apply it to
the code.

Suggested-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/userfaultfd.c | 54 +++++++++++++++++++++++++++---------------------
 1 file changed, 30 insertions(+), 24 deletions(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 240de2a8492d..2606409572b2 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -20,6 +20,34 @@
 #include <asm/tlbflush.h>
 #include "internal.h"
 
+/*
+ * Find a valid userfault enabled VMA region that covers the whole
+ * address range, or NULL on failure.  Must be called with mmap_sem
+ * held.
+ */
+static struct vm_area_struct *vma_find_uffd(struct mm_struct *mm,
+					    unsigned long start,
+					    unsigned long len)
+{
+	struct vm_area_struct *vma = find_vma(mm, start);
+
+	if (!vma)
+		return NULL;
+
+	/*
+	 * Check the vma is registered in uffd, this is required to
+	 * enforce the VM_MAYWRITE check done at uffd registration
+	 * time.
+	 */
+	if (!vma->vm_userfaultfd_ctx.ctx)
+		return NULL;
+
+	if (start < vma->vm_start || start + len > vma->vm_end)
+		return NULL;
+
+	return vma;
+}
+
 static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 			    pmd_t *dst_pmd,
 			    struct vm_area_struct *dst_vma,
@@ -228,20 +256,9 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	 */
 	if (!dst_vma) {
 		err = -ENOENT;
-		dst_vma = find_vma(dst_mm, dst_start);
+		dst_vma = vma_find_uffd(dst_mm, dst_start, len);
 		if (!dst_vma || !is_vm_hugetlb_page(dst_vma))
 			goto out_unlock;
-		/*
-		 * Check the vma is registered in uffd, this is
-		 * required to enforce the VM_MAYWRITE check done at
-		 * uffd registration time.
-		 */
-		if (!dst_vma->vm_userfaultfd_ctx.ctx)
-			goto out_unlock;
-
-		if (dst_start < dst_vma->vm_start ||
-		    dst_start + len > dst_vma->vm_end)
-			goto out_unlock;
 
 		err = -EINVAL;
 		if (vma_hpagesize != vma_kernel_pagesize(dst_vma))
@@ -488,20 +505,9 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 * both valid and fully within a single existing vma.
 	 */
 	err = -ENOENT;
-	dst_vma = find_vma(dst_mm, dst_start);
+	dst_vma = vma_find_uffd(dst_mm, dst_start, len);
 	if (!dst_vma)
 		goto out_unlock;
-	/*
-	 * Check the vma is registered in uffd, this is required to
-	 * enforce the VM_MAYWRITE check done at uffd registration
-	 * time.
-	 */
-	if (!dst_vma->vm_userfaultfd_ctx.ctx)
-		goto out_unlock;
-
-	if (dst_start < dst_vma->vm_start ||
-	    dst_start + len > dst_vma->vm_end)
-		goto out_unlock;
 
 	err = -EINVAL;
 	/*
-- 
2.17.1

