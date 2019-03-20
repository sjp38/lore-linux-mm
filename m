Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B70BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC474217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC474217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 884F26B000E; Tue, 19 Mar 2019 22:07:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 834476B0010; Tue, 19 Mar 2019 22:07:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 722676B0266; Tue, 19 Mar 2019 22:07:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 49B916B000E
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:07:53 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id c25so902901qtj.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:07:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hNINBJ5UPUtfO+zxQq1V9aretMuFnZBdzgd4L900j30=;
        b=T1o/EOoDZUVdRW7wYZ97AxItXAmf9jiLtabzF76WzCDV8rzCurMwDmuMXyEUVM/FzX
         mOj5KGjpmwTDMVv75rk3+VZDLD7EL3j/MPdZhQhTp3iIpFC7iF4W5u0ID0u5dD/sHrD7
         uICjRFC+8/YzA1xy2nMir9xhMFMtdbYGLcNNyTX2e2E7ixN0FV9QmjfIAOxXvHSEqyKy
         NwUCCaVtzfDMX7+2kpjGbqDePZSebntfFtq14iF487S/1P/6UCbprlDdh09sTNkf8YHu
         TnzQYNWqo6iLLFxRfF243RzQYklNFF/orbh0RwrQD5yUZWhOLxH5gQdnSVp6SZT1Bh0c
         mtPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWi4cDXFdXmxJBZZWUINrhXiXx+k+M3zqJ5dEumK/BiePqmxpyx
	RwXS83Dvrz25Xi0GB/AcXtRJ+xI6p55LHVKN7OQkODIyCSRWJnt4Pc5HgpJ3SglJvyQi9Rt1M/4
	ODhug6hEjkJ0IaxCuINJnSGJagnB+UIFlXgIZMYq3s40zqPiiMbaiFT3t+55RJHdCtA==
X-Received: by 2002:a37:5c05:: with SMTP id q5mr18757050qkb.20.1553047673051;
        Tue, 19 Mar 2019 19:07:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlG1GeLwrKc0bWwItgWq0oXxqBk9rCGaT17qkbbvmEOB+2NpyUf8r6OJ+9SCiJABz1XKGE
X-Received: by 2002:a37:5c05:: with SMTP id q5mr18757026qkb.20.1553047672472;
        Tue, 19 Mar 2019 19:07:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047672; cv=none;
        d=google.com; s=arc-20160816;
        b=BOiZmM8hh7Mq1aEV/w1Dg1x5cSPNPbz3Dve47Vh2TFvbpkbr9gFQZxpLE69MO0sfJU
         xBT5wP1HrZNsPg5FjykzJiD49aBJGzzyQqX7/Gp5df27CNMdiq+kmXYS/j8zR3KbPS7Y
         n9+wGFhcf0mOdWfYyXgUaVsQvqMY/9eqjndbhUk8eyfYQUIHh+5OogEyUsb8dBvDxDZh
         TzV9is4r1OzNn94P9bpQJTMcaS+RB+OVFSYxzkTePj33St6bIbxt4gYCvcq6O5j/tSrh
         RVC6ttj5z4kyhP9t/ZV7Z+Yx8tyvlqNdf9HeytJjLwEGCYKXnim09/N3lRZm4qgbEESt
         wFYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hNINBJ5UPUtfO+zxQq1V9aretMuFnZBdzgd4L900j30=;
        b=VH/awJCgNnEMvYLg+Ore56dczv0jNmuhpqLOshn6z78f65jaJIhFGQ5GRiBMFcY+Sp
         xFftcmpRUKzvj2etOojd8awENJTfaxl/IJ8OfklDxuXmlKwqFNOyDadIgrDKp0jFMNbJ
         LOYkFy+f+iHWaCZ8Id4NDhnrYFy0tL/iYe1BKiygK9laRGAj8RmCxc13tbWkxGSLLmnG
         Sy/Y7eGA4qCjHTe4YaiNscrlyN0EA95K6sJhFUa8lYuzTJ5ay1PL3Tg06dmMnDpA4JzG
         NuJ2Q5uMRp1t+ve1xreV5dWNi4p5U2H2bb9bAPVA02uDBzWTPpHp099qyGeqBTjwSp8E
         +Sog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v44si262379qvf.137.2019.03.19.19.07.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:07:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6E445308FBAE;
	Wed, 20 Mar 2019 02:07:51 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BDF9760634;
	Wed, 20 Mar 2019 02:07:43 +0000 (UTC)
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
Subject: [PATCH v3 07/28] userfaultfd: wp: hook userfault handler to write protection fault
Date: Wed, 20 Mar 2019 10:06:21 +0800
Message-Id: <20190320020642.4000-8-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 20 Mar 2019 02:07:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

There are several cases write protection fault happens. It could be a
write to zero page, swaped page or userfault write protected
page. When the fault happens, there is no way to know if userfault
write protect the page before. Here we just blindly issue a userfault
notification for vma with VM_UFFD_WP regardless if app write protects
it yet. Application should be ready to handle such wp fault.

v1: From: Shaohua Li <shli@fb.com>

v2: Handle the userfault in the common do_wp_page. If we get there a
pagetable is present and readonly so no need to do further processing
until we solve the userfault.

In the swapin case, always swapin as readonly. This will cause false
positive userfaults. We need to decide later if to eliminate them with
a flag like soft-dirty in the swap entry (see _PAGE_SWP_SOFT_DIRTY).

hugetlbfs wouldn't need to worry about swapouts but and tmpfs would
be handled by a swap entry bit like anonymous memory.

The main problem with no easy solution to eliminate the false
positives, will be if/when userfaultfd is extended to real filesystem
pagecache. When the pagecache is freed by reclaim we can't leave the
radix tree pinned if the inode and in turn the radix tree is reclaimed
as well.

The estimation is that full accuracy and lack of false positives could
be easily provided only to anonymous memory (as long as there's no
fork or as long as MADV_DONTFORK is used on the userfaultfd anonymous
range) tmpfs and hugetlbfs, it's most certainly worth to achieve it
but in a later incremental patch.

v3: Add hooking point for THP wrprotect faults.

CC: Shaohua Li <shli@fb.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
[peterx: don't conditionally drop FAULT_FLAG_WRITE in do_swap_page]
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/memory.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e11ca9dd823f..567686ec086d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2483,6 +2483,11 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
+	if (userfaultfd_wp(vma)) {
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
+		return handle_userfault(vmf, VM_UFFD_WP);
+	}
+
 	vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
 	if (!vmf->page) {
 		/*
@@ -3684,8 +3689,11 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
 /* `inline' is required to avoid gcc 4.1.2 build error */
 static inline vm_fault_t wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 {
-	if (vma_is_anonymous(vmf->vma))
+	if (vma_is_anonymous(vmf->vma)) {
+		if (userfaultfd_wp(vmf->vma))
+			return handle_userfault(vmf, VM_UFFD_WP);
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
+	}
 	if (vmf->vma->vm_ops->huge_fault)
 		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PMD);
 
-- 
2.17.1

