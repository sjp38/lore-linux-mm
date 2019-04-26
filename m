Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 553ADC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12160206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12160206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A50D26B027D; Fri, 26 Apr 2019 00:54:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A00BB6B027E; Fri, 26 Apr 2019 00:54:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F0586B027F; Fri, 26 Apr 2019 00:54:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7156B027D
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:54:38 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id j20so1831480qta.23
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:54:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=jp0YVUZ3P3SiDKVWqlmFTg+hIs4LHhTDtGXxqzlDiEY=;
        b=jUNHKowXwzzeOMcWXN47x4Ax+PTffzOD+I4tYOe9gj9S0cRRWT3VyxY7HWm1+b5RNm
         dN43YfHTU6GX5oBO/NQ4YvScpRP9XneJK0m4nPjZsOQXF1OKyNhr5EqxJ3Vr0pVB4cSC
         enf1kOcIwBb2yUtWK46vc02h68y8mtHN3wMkilTcN/GYIJRF8PmIzOk7TAuVRXV2Y2Ev
         d4/7e3L6a2sRWxxK4B76Nbf9CLfxT2FuS1xcP8z0jqQ5nRcgN//aP1I9zFKYDl277Hpu
         T5sNszOPEau8NGS4SiHu1XFDp1EGRoY6taOgiSWFYZwT93qOnjwx2dKRYV4BlcYsWYff
         XcqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWLjxX9etZ5P8gqJDdhKe65SHcSm8raVsNW0+Ec/qAZFRb2+Itv
	+t0IhC+rD2UjA1Ir5rJoaNDlEZV1yPBh91qydkrjMpJrrMMjehwQMc+RVN2Ld1x7WBaXFyDQ9Kw
	m1NDrU/HLsNaCBQE2GuoM38VqW4fm9ZhsTxvP2psl6wWtTcbDL27OMjhlcIMIPqE3GQ==
X-Received: by 2002:ae9:e406:: with SMTP id q6mr9242914qkc.227.1556254478235;
        Thu, 25 Apr 2019 21:54:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxf9NlglyMXlfQdZeAeQmUTW7HqcVjW2NnSjPh82vOnwRyFduz0T9ggX/DRdfCzHbX+dI/M
X-Received: by 2002:ae9:e406:: with SMTP id q6mr9242872qkc.227.1556254477178;
        Thu, 25 Apr 2019 21:54:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254477; cv=none;
        d=google.com; s=arc-20160816;
        b=lv4+qoRCNeiQiaoHGorJXYvZ1Z/cCIstQJTrwToXW8XhqkhTFGaSchS7N7/q9rNgTJ
         XdFpOwIo4L+gautQnYVlH+LLzMZ7veQvy4nA+lgN3YOVvFIs76Xgv52Pu6+SGbVswKtS
         3JXax987wdxAQCYlYSCFFELL9ZTNO3KT5CWTUapvX9OUZfzguiX9A2ITzctSxANj7PWv
         NT/3Jrt5OaV+F73ap37Gw9h4xhhBydo7I+ZYFqJ5uaht1YKJ7Vt+81dpFmYI5fvKm3jK
         PGN1poh7cLeUd1hWYSpz7yliq6OX1/kJKY1m0HeY8a83dEgLXbgXe7mZV65/zK9rFiX6
         XNVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=jp0YVUZ3P3SiDKVWqlmFTg+hIs4LHhTDtGXxqzlDiEY=;
        b=I3+a0W7nw26GJ8yedxVwKtrxTbV3YSNX5PIG6boDCf62GBrLvD8rtfJuJqT6D/JnDd
         TiBBt0N8LJ1A5Q+MGYSOeiwqojdPAZHKkQ4jE1o9ayHZ7M6GaZmu4asp/oADbaIcvVd6
         6xrP93iX2ZjXADgtlJQ/S2/s0I7HxeepLk7bXX80DsmG5imTstAuyMJhWxoLJ04m7BtV
         /mPAHebt/6zRa4ZPf2kxJP9wZI/z5mkJYm+Wn7nwZiWTwRoLRihuDDxQ6u45b2GPpKDi
         qVAhfny1NVn9NdwWnh7cp8F9eGfUiW2cGgsQ6QM3aoT4ftWXIoU65IoEhTsfOO3naZY/
         qCnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d54si9333817qta.89.2019.04.25.21.54.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:54:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 53EEC85543;
	Fri, 26 Apr 2019 04:54:36 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EB8F918500;
	Fri, 26 Apr 2019 04:54:28 +0000 (UTC)
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
Subject: [PATCH v4 18/27] khugepaged: skip collapse if uffd-wp detected
Date: Fri, 26 Apr 2019 12:51:42 +0800
Message-Id: <20190426045151.19556-19-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 26 Apr 2019 04:54:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Don't collapse the huge PMD if there is any userfault write protected
small PTEs.  The problem is that the write protection is in small page
granularity and there's no way to keep all these write protection
information if the small pages are going to be merged into a huge PMD.

The same thing needs to be considered for swap entries and migration
entries.  So do the check as well disregarding khugepaged_max_ptes_swap.

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/trace/events/huge_memory.h |  1 +
 mm/khugepaged.c                    | 23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index dd4db334bd63..2d7bad9cb976 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -13,6 +13,7 @@
 	EM( SCAN_PMD_NULL,		"pmd_null")			\
 	EM( SCAN_EXCEED_NONE_PTE,	"exceed_none_pte")		\
 	EM( SCAN_PTE_NON_PRESENT,	"pte_non_present")		\
+	EM( SCAN_PTE_UFFD_WP,		"pte_uffd_wp")			\
 	EM( SCAN_PAGE_RO,		"no_writable_page")		\
 	EM( SCAN_LACK_REFERENCED_PAGE,	"lack_referenced_page")		\
 	EM( SCAN_PAGE_NULL,		"page_null")			\
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 449044378782..6aa9935317d4 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -29,6 +29,7 @@ enum scan_result {
 	SCAN_PMD_NULL,
 	SCAN_EXCEED_NONE_PTE,
 	SCAN_PTE_NON_PRESENT,
+	SCAN_PTE_UFFD_WP,
 	SCAN_PAGE_RO,
 	SCAN_LACK_REFERENCED_PAGE,
 	SCAN_PAGE_NULL,
@@ -1124,6 +1125,15 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		pte_t pteval = *_pte;
 		if (is_swap_pte(pteval)) {
 			if (++unmapped <= khugepaged_max_ptes_swap) {
+				/*
+				 * Always be strict with uffd-wp
+				 * enabled swap entries.  Please see
+				 * comment below for pte_uffd_wp().
+				 */
+				if (pte_swp_uffd_wp(pteval)) {
+					result = SCAN_PTE_UFFD_WP;
+					goto out_unmap;
+				}
 				continue;
 			} else {
 				result = SCAN_EXCEED_SWAP_PTE;
@@ -1143,6 +1153,19 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 			result = SCAN_PTE_NON_PRESENT;
 			goto out_unmap;
 		}
+		if (pte_uffd_wp(pteval)) {
+			/*
+			 * Don't collapse the page if any of the small
+			 * PTEs are armed with uffd write protection.
+			 * Here we can also mark the new huge pmd as
+			 * write protected if any of the small ones is
+			 * marked but that could bring uknown
+			 * userfault messages that falls outside of
+			 * the registered range.  So, just be simple.
+			 */
+			result = SCAN_PTE_UFFD_WP;
+			goto out_unmap;
+		}
 		if (pte_write(pteval))
 			writable = true;
 
-- 
2.17.1

