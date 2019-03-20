Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B359C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9F28217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9F28217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96E706B026D; Tue, 19 Mar 2019 22:08:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F7C36B026E; Tue, 19 Mar 2019 22:08:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7987B6B026F; Tue, 19 Mar 2019 22:08:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4416B026D
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:08:57 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id v2so815294qkf.21
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:08:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=GFGx0IdWQ0ZPrL6vkXilEv/IYCsyBmlgGdp7pG6DT9M=;
        b=Q/vBlX5t6oKIbAAMiiFwpKjOZqerhhMJR6Hn/RVOTIIuyn7cgMs6Ve/Baya4wHFMDM
         aOPpeOi1BK8iYO9rB9wQ2/X/1jbVHZyBBmxlWFUzl98N2rpYb5jBpN2kMgJ6E6SdWIV6
         3BPrle2K737GpT4XVNIre/r8irHWH/6ehfhsqbGx+karTHDDUMJFbFJ6nRdr5fnY2g6k
         qRgAfIld9PQSHlDTXNdWmJJMryIBEGd0qX9nc+BIu5QNGs1vo25d03XgipaYKUiTOCSv
         gi/pG/Xw0hVjYnpIl9eqFVvPAWf0JKmxRksStAHDBjICN+YEZ3Jc/cwE8yXVbfoNQc5l
         8mcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXeJarHsIwLFn//BYXqqWbwGSynN/6gJExRyEoBPPW20qxqBiAx
	9TGVz8wr0pMsZM4j+WPSmuYdCwr++CV2ybEGcp6Ul8gOhlTOyBUOd+0EANLq3XdMXj+nH7O2B+v
	fxTsx3fNu3aUfpLtUAQVNUoB4DqnGSsDvnbxt77zRZM+CbV09rusFJW5OIqzYQerSWA==
X-Received: by 2002:a0c:d0f3:: with SMTP id b48mr4481331qvh.139.1553047737120;
        Tue, 19 Mar 2019 19:08:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzewOUe+/0kegXz0p+odpf8cEsSMZdoq9m7XIsBqwx44uLSNhy721m1eM6V1S0VwBAsqph/
X-Received: by 2002:a0c:d0f3:: with SMTP id b48mr4481283qvh.139.1553047735912;
        Tue, 19 Mar 2019 19:08:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047735; cv=none;
        d=google.com; s=arc-20160816;
        b=x0p5O5kGJuru+/6fwy8oPOkgGWIRPMMYdfhq5r9Il4KWGUW6dY136h5xgXCKVmpoDY
         0caIY8obsP8DblmXwaYhBjOpnjmbxS7nQKxkQ2qc6RPsMLiFCt0SR+EowGvKiHnRqe94
         rTv0dGgbNU8OA7hhDjlt9xYxTc90s2+oin/YE5WIoZoe11LApy+cNUSzLYsNvDNfzCwi
         JVX7FFDMidTysnye6AQu1WDyeHPCVyArtpNUNzY/keUpx7EbSIsekqXW85yAamdEorSq
         vwBDkdSEQZJQLbgXFLjNLHuJv8IV0TSzv467h8PS29uIk1EynGau2qxHC/no3/bKJC1X
         STyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=GFGx0IdWQ0ZPrL6vkXilEv/IYCsyBmlgGdp7pG6DT9M=;
        b=JpaaNeUzhFtteSYOd+Hx+HuwZACRoR/X/sLGaN8PjDaS4fTxPHgIE7uQ6GllCEXATL
         F2KHpqAmMUj8zigop0mcFAsw6fhIlKEcS51DgBcVx0DVedLyGOFAwLKW9xvlm2LZOYY0
         S0xx3dBuPgY2Ygd8jW2KZ6/pEqVdWNhcIrLFiPqnFJccLuBuckECKTX4ZS0X3g4N+RJ1
         Po7fz19ZJJRaf3TupygaIbjvyDaRRwSXLsS58iF+kp8P0TuE814SZR3DJnQpsBteqAeO
         kgwAllg7733Lipb5n7P55AiKyTxIp7+3xi1D3Xeoa1ukvW3hwh2QyeSeDzu162D7wVuq
         ofCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a67si349337qkb.112.2019.03.19.19.08.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:08:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 139C0859FE;
	Wed, 20 Mar 2019 02:08:55 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 592C0605CA;
	Wed, 20 Mar 2019 02:08:49 +0000 (UTC)
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
Subject: [PATCH v3 15/28] userfaultfd: wp: drop _PAGE_UFFD_WP properly when fork
Date: Wed, 20 Mar 2019 10:06:29 +0800
Message-Id: <20190320020642.4000-16-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 20 Mar 2019 02:08:55 +0000 (UTC)
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
index 817335b443c2..fb2234cb595a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -938,6 +938,14 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
index b8a4c0bab461..6405d56debee 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -788,6 +788,14 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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

