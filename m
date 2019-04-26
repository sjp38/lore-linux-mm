Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 012E1C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B20A2206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B20A2206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54A776B026B; Fri, 26 Apr 2019 00:53:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F96C6B026C; Fri, 26 Apr 2019 00:53:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E92E6B026D; Fri, 26 Apr 2019 00:53:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA7F6B026B
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:53:12 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id r13so1798596qke.22
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:53:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=DP8rIuiZbwGD1DEvgaImLarPGpPXGWXJpd5zHekgvPw=;
        b=NK8aySJrwbOsoMOABSZxvBSSxYB+4w4CvapGbzRIaMNlOMn3UPxFEoJ8eLLdgSiaZa
         HlZ2iUYYr2oZ+2HPDVTeRTKT4sYLugyTO/FOoVmvX/usc4cLeRgEt3+/IixMwvDQNS8c
         hDpBrl4jV/WQc5Kz56ueGr0lMThvvxhNB6nh1+q3vQDTBqPpUYraRKAaJrKx4YgGAZDl
         7kdAHJWTXWe8pQYwEJeu35fJJGCqdUZl5yhe9Wo05rACcjL9HwSpWFxN+zRv5S0i++2V
         NGOPKl750TTtFFO7iihghSNM6mZUCnar3Csf/ETGV3NAaryGRcYgW+ZJ7mNnS3pAHwe2
         DjGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXeJwrKPIkETVAPgjnGWm+mxI4B525CfXvkQf/tMjYJs3zanqkX
	j0TRR5NCYCgQCg9h/mNlRm49Gq1TRa3mwyNdBanLf0TO8tbXhf035fiihmedxXHc1CdkXxyDnu8
	vSVuMjLBHoS/40A9gMgOHMKE9UsKWwi8phLlL4s/roRZYeCQLfX+qrzXOdNq+T+IBIA==
X-Received: by 2002:a0c:c110:: with SMTP id f16mr34137436qvh.190.1556254391885;
        Thu, 25 Apr 2019 21:53:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynKwsxCtJ1Dz8L+pgjbFC+MKlkP6tvMHEqPqsFCDspkvqqsfHrHBDtiDlPj/i0Z1eiNn1b
X-Received: by 2002:a0c:c110:: with SMTP id f16mr34137408qvh.190.1556254391266;
        Thu, 25 Apr 2019 21:53:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254391; cv=none;
        d=google.com; s=arc-20160816;
        b=rlTOOr0Ww0ZtduA5K2Qjq7qF2jMvQJXXZikXTFJRh+l9Tvx2E91LXFK7Bj7I/WyiRl
         IFYveg+ObMkFtP/8+KB/dfJDEs5bMYPPoW7VXt2GeYlAHdSNbiQQHNdIkjWFWTA9fwCq
         KccjUVql431ZEt3J4rZnWgxzUg9Bk3OaBHVXw70vdPy8Fb9NWVFIYDp27XCbkAo+RH4+
         HLnpyO0G2NUlEGoZ4piwVmzDCd4hpQrTEPogoMR9tXp60+DM2dOH4KQnlAePu9gmjkfP
         DebFWSViHOlGoceQbHNvKB5+savX+A6G+7UzOSve/MEosQWbDFOvC5vmAQS9AVeM+g73
         oWGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=DP8rIuiZbwGD1DEvgaImLarPGpPXGWXJpd5zHekgvPw=;
        b=dADS72p8sF0c8ujYJjiKXGKVhPnwfrIbPDuw4xb1lb0D6zsU8C/07IWR+RMyvQ+FQF
         uV/JiEnMvYjh5/Qp/RZl2WXZfgBmhgA9z3RGARWuvTgwdBlJkaTPmnkoUuvr0YR0lF1l
         PCBjG1l/Ox2CqkvjiylTeL+d+Yg3rfjWQIi4cvGvYkkxD8mr1n0V/i5oGr3btiv0NLAH
         iAysnNt3BZGOGMSq63ZVxmPHSW0UNUyTbU7FKJUCHmPv3toRNQ5bTe5QA6OEnGo6mvm0
         6LmaJXo4OGO5n/1GQqt0G+djJcUkBjaguGq/cCUWOPXBiwFkJkgP77dbqxGzOeFxZUaA
         hK1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e1si5695661qvv.205.2019.04.25.21.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:53:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5ECBD307D847;
	Fri, 26 Apr 2019 04:53:10 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 871F018500;
	Fri, 26 Apr 2019 04:52:59 +0000 (UTC)
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
Subject: [PATCH v4 07/27] userfaultfd: wp: hook userfault handler to write protection fault
Date: Fri, 26 Apr 2019 12:51:31 +0800
Message-Id: <20190426045151.19556-8-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 26 Apr 2019 04:53:10 +0000 (UTC)
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
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/memory.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index ab650c21bccd..8ccd4927b58d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2492,6 +2492,11 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
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
@@ -3707,8 +3712,11 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
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

