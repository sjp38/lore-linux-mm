Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01176C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:59:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8F9F21773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:59:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8F9F21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D7B58E017F; Mon, 11 Feb 2019 21:59:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 586E38E000E; Mon, 11 Feb 2019 21:59:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 428FC8E017F; Mon, 11 Feb 2019 21:59:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 105A88E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:59:37 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id y8so1245533qto.19
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:59:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=7IiIqj97bzkfWOp+1GqlfOmQCtvZ1lzK34xFsh5m1uc=;
        b=hVMn7+xdsBFvukd/BGfGuXhGKVXVFhKI5oQWLUltsbQlk8JSnHd2pI8I0GU762tGpm
         7AcGFBDb4Og57NuUTldke8any/UnYK6e3sA2wVS+Xe6zH0vp2fe7Ez7TfBqxP8PNiLGa
         TE6hFinAz8QIXxBmNAUG64VWjmiZJzgfepa5uXmHPt884JmNYYEZJbbwp79FNtoZLsxg
         rn0e0Wtxv5XKs0NMBFVCBF+l9RUeVhYyeCsjrtEXSh6ZNW9PbbMXwRyhPckDpwVjY1NS
         aW8xjJR1b66xCPN7s0ukqunoSQJKnjq62ht44MgoO7bjycSe3p2xWOOWhRXsmGYkZ1O3
         z0vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubt2Fh7y+trWMk2F/NShScMUoEYKQXckVGushkVTWL7mU7xkm1f
	Y8R2NkRS9X0UbmiQdmAq0EIPZiSGwsWAcSeKaTasoapYAO3SvJoQZ2TrFAzxWYzYkfGcEOvEV9C
	bnt8BC7clEXGw6RMfmSFEGJoEtOOESZnmLjv3Bhzlx/QuY1Vv3eu0/25c60MaCNrN3g==
X-Received: by 2002:a0c:f184:: with SMTP id m4mr1022109qvl.178.1549940376859;
        Mon, 11 Feb 2019 18:59:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZnnukF/Xj9HQo9gNC80EUR79c/gurhyOBKsZOFSBGeho4+NgX5ztZYroTTXwBKvOFt0orV
X-Received: by 2002:a0c:f184:: with SMTP id m4mr1022093qvl.178.1549940376448;
        Mon, 11 Feb 2019 18:59:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940376; cv=none;
        d=google.com; s=arc-20160816;
        b=NLeqGizSyXxXE8zlhev0dHnmU2s7+IZZpo55PU2czDIQIMbh/KRVCsr2tgIcCkQ0Ry
         w3QuzRvTnQw/ICHDcUqYTdokNGo4UjxW3lmzhm75iXGrnCqvnr0nBJPTBZynzT/S+mE3
         KaOpHkXrQP4tShOe6P+NGYhE8CNKnNCA9+c5kOxCD3XWHeoc514piUyIv4nW7+7jwWBf
         Q7M1Tald6BjP2Qg6d5zCE5cGxU92qLGaxIrXuQdOHvjU2mHPd+0858oMXnwyIGQQr/E9
         Cu+17dxGg2sY9TBLT+BrImHxVNGCeqD0XLOJp1j1vrg40MN7Aahgr1ujh90SJDk/BaHl
         j7rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=7IiIqj97bzkfWOp+1GqlfOmQCtvZ1lzK34xFsh5m1uc=;
        b=JjKbH3fw4OJXIp86jvXIbwrXez7UXj8JgGPE94G+k9Zlbh6NJ0T8kcCHvNh+9t7inT
         h0nTNyKnlLUUOc7E7KT5YF9jyErgGeHuDe+ik07TFB7t40AUexED3l4ZyBQE9CENuB5L
         1RxyEp3VzuThictcpqeSfS8n5CVu/3hUtq+sko2Sw+oEDXQWvvewikJI0zMn1msWCFQZ
         6dT3MUdyVGLs7TgCEwLRe9CpuOIMgr7Vx3DS/nHv87UTea+woYdClQlSbNn87CZ14OgD
         kIwj/PsOKFOBunwwW0R/W2N8rt+4z1xPDEWYBr5e2YzW7zpymWR9eQJ+BZZZpQjcMRZN
         XaDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f17si7953511qvr.101.2019.02.11.18.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:59:36 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8CE4781254;
	Tue, 12 Feb 2019 02:59:35 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E3690600C6;
	Tue, 12 Feb 2019 02:59:22 +0000 (UTC)
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
Subject: [PATCH v2 15/26] userfaultfd: wp: drop _PAGE_UFFD_WP properly when fork
Date: Tue, 12 Feb 2019 10:56:21 +0800
Message-Id: <20190212025632.28946-16-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 12 Feb 2019 02:59:35 +0000 (UTC)
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
index b5d67bafae35..c2035539e9fd 100644
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

