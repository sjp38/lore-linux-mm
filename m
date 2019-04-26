Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD58CC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF89A206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF89A206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D3716B0275; Fri, 26 Apr 2019 00:54:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 482886B0276; Fri, 26 Apr 2019 00:54:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3720D6B0277; Fri, 26 Apr 2019 00:54:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1293E6B0275
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:54:13 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k68so1812421qkd.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:54:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=+2zXM28mkRTFL/nZ1ldtHaKFT1vWRt0OYY5NDzGcXks=;
        b=YwiqyxWGYyWki91j4vHIUq6l1MB6nePvMml7BMo3vlibO3FxKlM/ShbNRbhcG1RSIu
         CnZB1/re8GnAAmo8CPSL9EjeEw3nZOYy250BIP+WZEJ8/+vCn3AJcSCvyDnizUKoCOJz
         s6Xgvvn1t5TqPNzEs/zdedWgn+n81V0PfglTqK7QHwDai2NyQCe5RutJ56dqncm7a/1R
         zbBTpBh60muiy6GQI9O9qB1Pen5l4ZwnkWwt+HAf0HSmqE6L5GsmqQrHjxmWCJ9WmwjF
         So78+tmD5LzUCQfiNaVk1H+5+Kke2zet+RWwfq9qgdXvafA3dvrn7v9jKiF9CGHrnToX
         Fxhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVdleTVWWUXSqvJ0wOobyMJcJkC9Nd3cBtSOv2IErrmSOA4/Mmc
	tgCA2KjyZlwhI59L0fHF+kddSPJOoBc9ZeDgfZjElGbRI+JMwnbsNNWbvs+mTSPy++K21Wm3rUk
	CAdqFsA+hqX5aLKdHZ45AUTM2a6518udwXr5Kc1Wn5eyIKMAAN/jMsDEmwMAPQ5f/Rg==
X-Received: by 2002:a0c:b8aa:: with SMTP id y42mr32827397qvf.66.1556254452852;
        Thu, 25 Apr 2019 21:54:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsF67o2wqm3TBLBXO7AkRP8s86B+PB1urRc1oPEDseT8yZtzUQX+Cuvs2/hngOKldxOFIE
X-Received: by 2002:a0c:b8aa:: with SMTP id y42mr32827364qvf.66.1556254451938;
        Thu, 25 Apr 2019 21:54:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254451; cv=none;
        d=google.com; s=arc-20160816;
        b=bdNK1gtI2l7ucQ4NNdjShvE8KAdqovvlD3lg4fj9leNJ54Lts9pCrCMyW4RYFw1rPz
         XcdMz1tr3Nji7/yzdmVQCVE3ab7ch3A73d3H8fXQydFsHjKBmqETUqRRSP/84/luVdjm
         /wQufFV1lo8bR1VdblNH5BHALY9kLTZHyLjG92lnwT7O8+mC744nZwaSIuOJnpjwkxpc
         0K3BbS80v/yrIu9bSOvcivPR3mKDYft6R+fXWJ2ogIdWvULcj8+s/Yaln7NY5HP+Ds0k
         4xBYVwtsTy56TCk8g1rqMPZFvyTuoPpcQxE8JeWZlcuXc/wzV7pqtVPkWnWAI5odRH6H
         BFNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=+2zXM28mkRTFL/nZ1ldtHaKFT1vWRt0OYY5NDzGcXks=;
        b=fGOpXXvc4dy4TDazCqmqHzSHDHu9nz1165Kf4o5hgvu+jUFb3nJMzuu2nVbBASxIeD
         /oxN3S6kwzI4XNur+fygnSnOmq1h/YoXvXCJO5TelzzgKAAzIzdTjz/2FKtYiN51JBK9
         lFkvT7VDU6tPfc8D8QUx9IhrD4UvCCNKSvKc+Jh0qH9dXVhDhpF1PjKPJbBeLRjQkzjG
         6zQgUDZnYxIcQSiUGouwqNUWSHfzTPQrnR6sRkIFLc4Zf08htw+RLKXWFcX/e0Ygs9vj
         +R8qEz3GuiYXmiN1Jm4fz4smQIZqWilnKu2oWrVXEKsSxhmig7uLomXlMxso4JkZwQ48
         DvOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l190si884793qkf.38.2019.04.25.21.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:54:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1EBBFC0842AB;
	Fri, 26 Apr 2019 04:54:11 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 80CB5194A0;
	Fri, 26 Apr 2019 04:54:05 +0000 (UTC)
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
Subject: [PATCH v4 15/27] userfaultfd: wp: drop _PAGE_UFFD_WP properly when fork
Date: Fri, 26 Apr 2019 12:51:39 +0800
Message-Id: <20190426045151.19556-16-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Fri, 26 Apr 2019 04:54:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

UFFD_EVENT_FORK support for uffd-wp should be already there, except
that we should clean the uffd-wp bit if uffd fork event is not
enabled.  Detect that to avoid _PAGE_UFFD_WP being set even if the VMA
is not being tracked by VM_UFFD_WP.  Do this for both small PTEs and
huge PMDs.

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/huge_memory.c | 8 ++++++++
 mm/memory.c      | 8 ++++++++
 2 files changed, 16 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3885747d4901..cf8f11d6e6cd 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -976,6 +976,14 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	ret = -EAGAIN;
 	pmd = *src_pmd;
 
+	/*
+	 * Make sure the _PAGE_UFFD_WP bit is cleared if the new VMA
+	 * does not have the VM_UFFD_WP, which means that the uffd
+	 * fork event is not enabled.
+	 */
+	if (!(vma->vm_flags & VM_UFFD_WP))
+		pmd = pmd_clear_uffd_wp(pmd);
+
 #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 	if (unlikely(is_swap_pmd(pmd))) {
 		swp_entry_t entry = pmd_to_swp_entry(pmd);
diff --git a/mm/memory.c b/mm/memory.c
index 965d974bb9bd..2abf0934ad7f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -789,6 +789,14 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte = pte_mkclean(pte);
 	pte = pte_mkold(pte);
 
+	/*
+	 * Make sure the _PAGE_UFFD_WP bit is cleared if the new VMA
+	 * does not have the VM_UFFD_WP, which means that the uffd
+	 * fork event is not enabled.
+	 */
+	if (!(vm_flags & VM_UFFD_WP))
+		pte = pte_clear_uffd_wp(pte);
+
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-- 
2.17.1

