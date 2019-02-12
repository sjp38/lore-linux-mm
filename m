Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB7DAC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0D4521773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0D4521773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 403A08E01AB; Mon, 11 Feb 2019 22:00:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 389E88E000E; Mon, 11 Feb 2019 22:00:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 252628E01AB; Mon, 11 Feb 2019 22:00:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E65B78E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:00:20 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id q81so14413756qkl.20
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:00:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=9uk3Q0rvNodB/4vR1QWlwzCboqvJ+Wix/SOodhBg4sg=;
        b=N60BbA7Ft+pA2sLzwWbGO1VOcvHh5eslyVNM0Wo5RzkdgJiuCr82LZxbu0qSnksPAa
         OfSdZYMNG90pw2tlCEFOcKRpj4AjK4yDPZNTrN7SI55+W4gO3dQo9qyjLPD66ejVPMhu
         tQkLFYXHrTrAZYzYGzt82gdEYcEbc3fr3LWA4fZlpM1TK3pv8lk7MP8xDHKGT1NJT4bh
         npDHW60bhoBLXjyoMSCi7viDeMzoA5hNU1Lre6GBBqeS0ZvKIo2+mDCAYuNVY5TsyiNQ
         0DoOZdfAGJNzCX9r0B6ILvEsRV3gIL/+Iws6y3urae5W/NgX5qagIEQdKYK5N7NmtuZD
         gl0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaeVoYg6OqeSa0/puLUL2AM7dZY48Z082l0+yJUjwsjXAom08x2
	2aoMUixYrOBpVRVKIOPRT64gdgH687/Atojs4TKU8bpxldKhBApRmCsi4Egys40HEJQhIz0iTQK
	FTw1BrtsasCAPW+IVRQsUedPqMhjjsN1wZ+/NMQ12AvxydS4duRcrdlnhyToEQvDF+A==
X-Received: by 2002:a37:b405:: with SMTP id d5mr1040290qkf.162.1549940420730;
        Mon, 11 Feb 2019 19:00:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZgX/B0DN5fn4Zw9F+5CJK1C+WnaHcFnHERH/Lz0eHl8fEwCAwUtnCVgy/qEzFoHo6XblGm
X-Received: by 2002:a37:b405:: with SMTP id d5mr1040262qkf.162.1549940420195;
        Mon, 11 Feb 2019 19:00:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940420; cv=none;
        d=google.com; s=arc-20160816;
        b=WWDO4m0W92jkZsfdpszCJJ6+OGz8zvOzgg+cKo4xhPByg20VeE0pZ81/UPAzJ7uOLy
         QDxQDWe7TsJKKfeVanV6wZewOqWLKZmJYLNqTAvwfTtk0nfk35OXkPSUEFCSi+TXz9m2
         D6U+tWDM/vIWGM0/Pbu4Hk8AOXHCC6FunybRi0QxiKeiGmxg/wwtHTxR+n8HABoZj0g0
         fJqo4Idkj5xotZQWD/bjPrAd8raHmNHAwO1lDgoC9fxY6TrWZ8vnGq6Sp4+8dxZdCJbd
         qY//kPIzx126eKZ1rOKZd1SGH4kKE+9nftrwWNhQy3PHxcpAxNr8Lmif3mEqzeOJdX0K
         csyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=9uk3Q0rvNodB/4vR1QWlwzCboqvJ+Wix/SOodhBg4sg=;
        b=n/24NT2ci/vXKHI5m3Q74sDs6UZR9mSYjDoA6MTZaGz6HwT45yJmP+ckDUyUTkK3Vi
         Xd4tvoNrOKIjqivE7dmhin9bI+0PmwtXZn+s8gCsocsPi/sij0ojCzCfGtA7v+WLTU6B
         graWdYEmHclqQWsF2+lgdWJUuRz2bVlsqpHH8uMF86GSYkrXyQziFkw9JujK+CYNX8+O
         vdXJNDOaxKnGabTAgZm40XPXwWXc3rXBm7/1uFKNFzxnVfsgkIVGxIsskr838DODzRG5
         cwTVFFYHzW/3f/wkFGtxHyXRPOstx1Lbv8zZEBidGOgUOZsvjs3XxCdAJ7xHj0gXWQ5L
         DkHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q31si1005650qvf.108.2019.02.11.19.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:00:20 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0FC7D85362;
	Tue, 12 Feb 2019 03:00:19 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 15BC8600CC;
	Tue, 12 Feb 2019 03:00:12 +0000 (UTC)
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
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 19/26] userfaultfd: introduce helper vma_find_uffd
Date: Tue, 12 Feb 2019 10:56:25 +0800
Message-Id: <20190212025632.28946-20-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 12 Feb 2019 03:00:19 +0000 (UTC)
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
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/userfaultfd.c | 54 +++++++++++++++++++++++++++---------------------
 1 file changed, 30 insertions(+), 24 deletions(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 80bcd642911d..fefa81c301b7 100644
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

