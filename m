Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91C4CC48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:21:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B3DD2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:21:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B3DD2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E78EB6B0005; Wed, 19 Jun 2019 22:21:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2A638E0002; Wed, 19 Jun 2019 22:21:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D19058E0001; Wed, 19 Jun 2019 22:21:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B06316B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:21:54 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id p43so1623580qtk.23
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:21:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6t42ZVA7nQGmUriMjbIStZ4r/pZ9wxkWvWVsOfcj4vw=;
        b=J2zU9nKcYeTGqaFQI+QEhiE5/ojcz66skdeeNgvUvRC52A1TFrVP8gNixyHuLJiQRy
         w2wCCfG5LiXbGepu1MSJWLlsFLfNrzb9M2yJzAqzpO7jWoOB95EUHYTOwlQDdaUFqKWI
         MAtnK5LVd+k5bP/IkE40re+9uMYQlNe3X8+Y1gNv/zEAEr53H9N0pLIhqPvaMcqoYnv2
         qt1SH6qz2HVhmup5yJBaZ0UkO6TQVTvypIkv5XA8RR5udR6XH+i0l3WBREklGDLtFh+1
         SOBecYLOChvuqV2vimbAj2RBb575GcKEqZk/incYzOwaitbruY5QVZXECShewzToKjaO
         P3Ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVvAm194PbqiE1KTZ+KEd4AeUX+c8zej9k4KzX0PRtOHdmNLsgt
	ozpuffxsCbN9niCmtDsuEglUHvKjC+88doSpu7rVSGrKylhYTPz8qSmKWJDwTC+/zrCuIBrMAxi
	PV4jgZHe7DNbPFTSkt+jXhXRPP+PoLpmze7oiSu6tt/yvTeac9kf5LdWH6YouSYH4yQ==
X-Received: by 2002:ac8:2b14:: with SMTP id 20mr17035491qtu.295.1560997314502;
        Wed, 19 Jun 2019 19:21:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHM01JVqa++WVEYLDGUQHKaK52QpXrAgouSJEiznyFvbUZrSJABuDx5u1GoeV+tkH7EWet
X-Received: by 2002:ac8:2b14:: with SMTP id 20mr17035450qtu.295.1560997313824;
        Wed, 19 Jun 2019 19:21:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997313; cv=none;
        d=google.com; s=arc-20160816;
        b=wT8gufIRE/ASwBfuQkXx4IBA3KYMUWrEwRP9LQnwccqddM/APq5Q5/EySkCF24HnKx
         VsmbTJPnQyvVbzNs1UnaiIbhBmstm/zt/qmVeKbKvbxnyp2+RLracxVG5Nl+IAQBCg14
         TyOWZLYuu13CetzdtjIUfsW+Aa+GmAdj80/WiezFZDsSM2LCDicNXjqa02JbzF83IayO
         gxTp4xlFWzmxsqRpUl5bTdRIfZr2jowV8Soe2az9keXQXrkWYeLZeSDC/XBFBpODPLT+
         tRqUb+I+BFpzX0db8z3RlgXHtt2fWcBDh5uKlYZeFjt2/w5roWFVm6Ka7/8fvKY/MTmR
         X2EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6t42ZVA7nQGmUriMjbIStZ4r/pZ9wxkWvWVsOfcj4vw=;
        b=UIgc1UzzGwTc7usY/GLQeSk3201FZxY4ywe4prG+06+8H+4f2uu3uw/p2AKbtyprIT
         Ze4ENCBF4X0Ihmty02rus2NZeHY1iKtAEYkr2Eme2YIIxg0R/hzXHIjPRRJG10CrBled
         wRl0wRTlA8cn0HAexEmXLkUVpn0mHOpohgMNu/Keu623sb6JiqBA9pFt4++JAOSwE4ss
         qTfQMxoThhmtPXTXxrG4vKe/qB+MJWi/8g1u8oj9Pwvsts1AM730oypW6d4wfcnPUt5z
         Gm6TYBW1Zww9xP97IoDg1aDQQJ+ks2Gat/OmLsDCJ8Ne13XaaGDLw0FtonxuFu2DH29U
         jAAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w21si12801836qkj.69.2019.06.19.19.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:21:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EC73E30872F8;
	Thu, 20 Jun 2019 02:21:52 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DB4D21001E69;
	Thu, 20 Jun 2019 02:21:43 +0000 (UTC)
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
Subject: [PATCH v5 07/25] userfaultfd: wp: hook userfault handler to write protection fault
Date: Thu, 20 Jun 2019 10:19:50 +0800
Message-Id: <20190620022008.19172-8-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 20 Jun 2019 02:21:53 +0000 (UTC)
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
index ddf20bd0c317..05bcd741855b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2579,6 +2579,11 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
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
@@ -3794,8 +3799,11 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
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
2.21.0

