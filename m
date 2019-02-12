Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85B54C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:58:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41BE62084D
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:58:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41BE62084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC6198E012D; Mon, 11 Feb 2019 21:58:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D75B08E000E; Mon, 11 Feb 2019 21:58:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65688E012D; Mon, 11 Feb 2019 21:58:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9841B8E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:58:04 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n95so1240994qte.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:58:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=/0tGI+WMMQCIgqP4tW1kg30CUM4gY3lrMug3d0U0StI=;
        b=FzgNOprSrpkR9zQvSBfF5UDkHXI/9Pu6xW/RpgJUDLEFrKGCaTNPJdksu/DEd2N2Ce
         pxXhTSHznn22US3iPoDdKjdhBuy69cPYGqIzJqSmiJQ5jnenlvnJ6oxe6UasjnLZPcCX
         76eSiFHkhNS0+I5pqd9w+9L2LFusCbn8V3o/VbA1mZ0fvwi46UdnFWUL0o150wpMu0L4
         vhm6t62n2/3NGsLyEnhapp3WsEq8GClwtKWGISIpy+Snlr3aUv2u/VGZwiht3s55VNBX
         CoJZBwDwKYhx8ReXY6t+XJFmW83O9MbVsvBYzB0DlAyQWwm9RwRgxJHQsFI6iPwxawkU
         jOtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaHJmG8aAm9TXvszsXe28U4npqpZ6TvePPI7cJEa9CJKke09STw
	kKFkbz4ps/9TQOo5yhlE6v1Ie5fka3eMMNS4GufgV1Hhjo5YR3lOJORIKZ2/1I5FXJjOjtne+yB
	6PH3eygKrw+aM3zM1MGmcvPCAatQWAB6cex+e3Lb2pK6ZLQucilDAsiwI4rDKFJHbqw==
X-Received: by 2002:ac8:581:: with SMTP id a1mr1148324qth.168.1549940284394;
        Mon, 11 Feb 2019 18:58:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZKgiSvCYOuwr7Fnc8UhYu4gsDGd2W89YdY/mOIoBk9R2wmfn6hytj/CS24xZibxYm+xbeG
X-Received: by 2002:ac8:581:: with SMTP id a1mr1148304qth.168.1549940283854;
        Mon, 11 Feb 2019 18:58:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940283; cv=none;
        d=google.com; s=arc-20160816;
        b=Gr4x8QWgCyEfITm2YvdrvP070xjf+4m8JkEhVKzV1tGIRSV1IVwKVI31Bq5GDs4yiA
         Rs+62GTu7ZxbKH7SiCdHVFWAK+nhQ1U+T30W47MOrKC/OpNTk83v2F4v9UpPZeg8o7Xz
         sL3LqMy37Am+nJa/XKA6e3G9MRgPAgzblVz9VA/ZLgYMa7D6zSP2SZDlZtTbaY4jZgvc
         uc6WtME0pvc32W/IPB3daOyqOvnsmllMXcLqCbAskL487A3HwE+YgNvGpxHeXVXh3bHu
         D6Q2kY3Aah69PxR7RgSoF+yAB7y6k3ufl+UAFnghnrp1DTyp8xjKK9lY5e0j2ZpLenj2
         R5zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=/0tGI+WMMQCIgqP4tW1kg30CUM4gY3lrMug3d0U0StI=;
        b=B8hu10umiRwMqSautDchirji+ApLaxr1zRNb6qFTzpGg41HQB0P6kJOY7IbYXqZRgm
         Y1yHcYcNva2tvjZ/D7zG0LuUMXsMAp4DArRPjCqnHgQ9xZ5/G1mm5WJdSwlGWRci9ASv
         tu9JTr6lq4i0/hwhgGFwkUuqcB2Gi7Q7ixM+qId93n2S2ZJHqbwSNjR1Zhf9ITeQ/tQS
         ipWZu+a+hJSt5ceKd2L+014FO+LxjoKg0a+GEtSeyXDaI6cen1YcmBH8fEVzgRtEhHrc
         hRUU+F9l8sZmXyjROBvsNZjjzqbTt/WLV5Hk3F8YSaFPxSy5lIkBUWCHsIu15EhppDO1
         zMeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p9si4917383qvq.61.2019.02.11.18.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:58:03 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DB26BE6A60;
	Tue, 12 Feb 2019 02:58:02 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 62382600C6;
	Tue, 12 Feb 2019 02:57:56 +0000 (UTC)
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
Subject: [PATCH v2 07/26] userfaultfd: wp: hook userfault handler to write protection fault
Date: Tue, 12 Feb 2019 10:56:13 +0800
Message-Id: <20190212025632.28946-8-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 12 Feb 2019 02:58:03 +0000 (UTC)
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
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/memory.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e11ca9dd823f..00781c43407b 100644
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
@@ -2800,6 +2805,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
 	pte = mk_pte(page, vma->vm_page_prot);
+	if (userfaultfd_wp(vma))
+		vmf->flags &= ~FAULT_FLAG_WRITE;
 	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		vmf->flags &= ~FAULT_FLAG_WRITE;
@@ -3684,8 +3691,11 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
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

