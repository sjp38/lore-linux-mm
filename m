Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5922BC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20E73206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20E73206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3B866B027F; Fri, 26 Apr 2019 00:54:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEB0A6B0280; Fri, 26 Apr 2019 00:54:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A02DD6B0281; Fri, 26 Apr 2019 00:54:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 814CD6B027F
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:54:52 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q57so1876140qtf.11
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:54:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=g4CUT7wn2ZfM204z66Iujtc9aw73Tdzc6nKReP/7dxM=;
        b=NfL7l0hqPiXAGsLupLpDaNBQeRqdW+A9qYHP/n2S+ufL8Otek60B1olqqsqLX00f4U
         34J1IoN0Fr2y+C85UvMSgqARM6uJ2ZijpatWNR+XE4i8XAUxLjNUYC6h6kEzgp3DbvgZ
         BdUf/fY6b3L0nTehDdx+knX/is9y8uESJzdDhxZ06bWigJFixrVi+sJPUV8E0lLYNhel
         FyORaqfSwO/ysNgqBarzRIAtzFJBHwAJmZ8mCD/htn3ln8X6sEw1S82M4wc4PWXNAt9K
         DBqLVPL/y5cGECFDkY1daBbDWLDxg9Fo8vCsX8jJBOnSK8pkVAqoOXAZ9dIyFtDmCFyT
         U94A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWR63dKBEr8f1tvQT/r5e1jPDFAhwg+N9vqZHqY7EvRpVCvHfis
	Gw+jDqeIEPwbJfai9Br+6SbkdpIZ3AscjqqDcT7IOMz8Fk15zILf0KcHaYUUj1XoUGSfHnTz5BJ
	j7bUDwxb8j8gNj6rVYIuMgM1AfSeikztrU6IfG7trOchu3OTdzN6LC11N8riN3J6k9A==
X-Received: by 2002:aed:3aa1:: with SMTP id o30mr19616698qte.218.1556254492326;
        Thu, 25 Apr 2019 21:54:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeK1UqlMa+fBrPhWwETer1R0fv9M0ayjQ3DuZ6NAkpWEsCx9boWpWqEgqeGW9El7wuS9L5
X-Received: by 2002:aed:3aa1:: with SMTP id o30mr19616678qte.218.1556254491710;
        Thu, 25 Apr 2019 21:54:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254491; cv=none;
        d=google.com; s=arc-20160816;
        b=IMdNQ0LW6CqRaykK3XvFekKaU6zFKamFmrqb8WSsVv76aL6Y+UX6Cd0d9FzNI9HDg+
         bA7Mw140olQ+arGAmYrDdmhuJAPBe9ea/jw7Ugzs6H0KXvnzMnqLB0oJqIDPAvlhbm56
         wUFAvCMyj3g68mTaqXkCwU+/IAJRYl9PwPNQlE1YhW9U//SPic3TMn0aVYFup7Pco1YT
         2aBTc7l6XpYe5OLyrxm7P48tsA2CEVJt0UlY0rqHg7f2gfik6AbXGorBs9MZq1km7l3j
         Ajnp7ZwXBIRpKiQledPP4NdXGrxKISKfmJG2eUBA1WOInUbU/tZ15vO3MGeMhx9zCmPb
         8aIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=g4CUT7wn2ZfM204z66Iujtc9aw73Tdzc6nKReP/7dxM=;
        b=zeM2by4x9ZwGPAh0ZmPxWgR+kTg9feM16Br36ruc2a2Ievf5gWgkwwOwjif/bLoXL7
         7sZRpTbv5caL9hz2qhea/B0p0kUidkN4MPvUKyRM3YQp4KK5yHRn8sVe0uC84dO0xFUx
         hsMWtn0Zi3bHeg556reZg3rVHe3ttTiFKhwM8zLLU6eJJlwiY2mA8MaZ160B1sjq9kEG
         fBEt7fOnx/hVaUe4Szo3uDKl9LXP7Rtike5vhoWdKBCzEc7n6XyZFhZ1RLGXskFTYgtY
         FMH66B/5v49dBPZWA/sx2cNaJekfLfxDDODGDgybgdlO6apqT5fU7ZeKTqI7VVjyMGcQ
         vc1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l28si1596307qve.85.2019.04.25.21.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:54:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D1935859FF;
	Fri, 26 Apr 2019 04:54:50 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CC7F218500;
	Fri, 26 Apr 2019 04:54:36 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v4 19/27] userfaultfd: introduce helper vma_find_uffd
Date: Fri, 26 Apr 2019 12:51:43 +0800
Message-Id: <20190426045151.19556-20-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 26 Apr 2019 04:54:51 +0000 (UTC)
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

