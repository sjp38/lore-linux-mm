Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C813C48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:23:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DE962084B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:23:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DE962084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3A948E0008; Wed, 19 Jun 2019 22:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F13038E0001; Wed, 19 Jun 2019 22:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E28998E0008; Wed, 19 Jun 2019 22:23:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C08538E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:23:54 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t196so1774275qke.0
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:23:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ws8pFVJ/7iUsU4uFKaRwTCDRS4voTwx2y4IltkXPrv8=;
        b=a9leBzbSGUhqpQ4Xkzpt+jmXavDab6BDqRI6pPmL8rfL1q8Z5Bhcz8wBru7LCd2bUL
         94OjlsA07DwzOV+T4EN608ZUcNKktd1o1gYLw5AYRY7ki0EOUweB5y9jMLG1KQfHfYpc
         PSrSLUN6JH0LRv0L393KGWX435nTDLsiBT9uDEhYhpkSu/6fFV2XvJ7ZpbyLqNBpc+hC
         928QHrmKiJyD1HzCrXG9ktezHJreie/Yjbh30tV64+DfFJDfRU8WVjkAOaRxgRVXJ12N
         IZ0Rqi1lcVTkpovfSb5Sj/1wqqNXUYHM67Hyti4T3r3SXS8Oeqae/j9a0uFO3jwqkQGA
         29Zw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUYJk+604UgfRIvAb2y9hP0wJNvCo0gqwa5IXJKtO/Of/RuTSw2
	aIBUONEvwuIirXHFxTJIRuGk9d3M7Pdb/t0ZHRcaZZlSJwsGixxzzonfag4FhdZLNSAIUOKu8lU
	9avgQCHk1dXvAje5TLfHMeDX3tUHnpg1LYkCNwe+ubzSd04993yD2pK8ayCcomZetgw==
X-Received: by 2002:ac8:1acf:: with SMTP id h15mr109009840qtk.67.1560997434582;
        Wed, 19 Jun 2019 19:23:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSIk5nfBPpXDbYSZi8vD52Tbl8PS6gKhl8mjDIq8nbnYSlzXhvxGmvEcwGihhWv5V2+7QX
X-Received: by 2002:ac8:1acf:: with SMTP id h15mr109009806qtk.67.1560997434034;
        Wed, 19 Jun 2019 19:23:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997434; cv=none;
        d=google.com; s=arc-20160816;
        b=GyDT+ogGokGvf9vaPWEm+1xpCWdInjX6yN/VfLsrizhNjD8hYpJ8iclVF1T2mOmRA6
         zH4udDEQwFuNqGS476TRXPKeUssriguCSGxeoD8fVoTtJ1h88Bx7FGGAXfeK3ZhsCmj1
         tlbiIztqZBiMqHJdcNqqM084u+U/5ueEIsW+lmyPkamOG3YzUxDwMjjHRrvY+RW/WRvo
         iyV/i1wVltGw/0hcqAT75N7P89rKYjDdMAaUVgkaKdtKkyj7cd1heReRHkhJhmOVFhTB
         jDLu8bMf9iZ2aACtiXl39y54rTIxryfOYn6m+8Fz4DYbdL9LQlQqZiMgP8qGXyYG7oR7
         WBlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ws8pFVJ/7iUsU4uFKaRwTCDRS4voTwx2y4IltkXPrv8=;
        b=QRMpKLcCbFe5XUY0sD5NnH914KP9+TrGqoGNW0PvFuHZvhDaPoYDtOsK4idhZkZcpt
         Q/G5CIDMXShOboI1piwqDAaeTACm3585XfiXLtapW0xZFFE0r3/zCdwFly4UQgHkq2X5
         KuIIUJb7qVbh2YDfzOdwqCV8zkqRgBSyBm5UCBPFJyfRzvvzt0l6XbYeEIvIHWw5TI3Y
         FGXHsOnAIkmqLsN+o6F9JofuaxCI2egasdJVXqBL+OpS2Z1QC1AhL5tywJiRKH+MZPFf
         gSGpoQsoNqws6YfHTAxWTuGLrlBJoVhEDCachuGoMX7twB5bgR56u2oiNKJdOSO+zWXA
         Ynmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h8si3902581qtb.258.2019.06.19.19.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:23:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1CF9B21BA4;
	Thu, 20 Jun 2019 02:23:53 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 89BBD1001E69;
	Thu, 20 Jun 2019 02:23:43 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v5 17/25] userfaultfd: introduce helper vma_find_uffd
Date: Thu, 20 Jun 2019 10:20:00 +0800
Message-Id: <20190620022008.19172-18-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 20 Jun 2019 02:23:53 +0000 (UTC)
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
index 5363376cb07a..6b9dd5b66f64 100644
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
@@ -487,20 +504,9 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
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
2.21.0

