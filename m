Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9E53C282D7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8163221773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8163221773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F25B88E01AA; Mon, 11 Feb 2019 22:00:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE0458E000E; Mon, 11 Feb 2019 22:00:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9CD98E01AA; Mon, 11 Feb 2019 22:00:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABB828E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:00:14 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 43so1263856qtz.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:00:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=qkUM5PHc4fGG1Gos3msNI5iqIZh+zFOQoQJ/383TR9s=;
        b=sdjvHejiP0nkAeGVgK9XgeuJ/FIGKWN/dmGY19BTb1pe9Fw7lCOeND3V7XYiyJPftd
         VU1Mev2A+3JElhUNWGHCpGCBdEaaHW9ePGrIzadEt2K12B48Bc24uA9XDIbNMHIT+pfD
         YriHXDFtVlaixvluSn/OxKkBGciQ0JGQS/fuI+ccf1z7JKXuw5Ts64mq2d0T1002ybya
         z/l5Z8DrlHf4FeIkDTRFqYcEXZUmwXhfUFeEkTLyB8r6Dlahf2eE9SQMgeclietryPGW
         EHhkoMF/W9GI7BeAcCmcpFQDBMdNzHQVUwtN4XWdKPvH0tpZBvsrnZxuLF4Uq22LtXSj
         ZXow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZM0qcj9JDT2+7plBlX/OXMxTzMCFSgXwDJtWyUdiQZGa44lY4p
	JyHLomXk9FJwNm8whK8F0i88xGFOJ8oGZjUjgBJtlsBltCZgTNWhNXwJ6yBE5z2mB44+t0qPB7W
	OO7rb+gw46YsgatLRjGK7gBY4LN01Zsf1D3qjvz+ULt3QDqqtt0iKL929vjPRFKrCgg==
X-Received: by 2002:a37:4f8f:: with SMTP id d137mr1042734qkb.325.1549940414483;
        Mon, 11 Feb 2019 19:00:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbcfFLRbvg/QCGtab7H+r/o9UGq3YDeeqpX7ql9uFCnLPjqMHt4oGpYZ+18L/zg+9S6ZFZY
X-Received: by 2002:a37:4f8f:: with SMTP id d137mr1042701qkb.325.1549940413931;
        Mon, 11 Feb 2019 19:00:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940413; cv=none;
        d=google.com; s=arc-20160816;
        b=uWE85TBTKZDHtoieCqWbPS6SwJOn3Al7JBOUQIuXxkvA1woj0vwYmm0aZ8YljsLdpB
         t8YcFagtl3f3uEzIrUBlcJ5+xzRq4KyKR6bJi/kGRXouzqPY5Or9cYhuHJ2bD7TngbVU
         GjMuiWCn3D5Hbg19aWiadGoH78J1bMHrqMlB5SP3ie2m7/KHYPDoc1QRbCXqqUnCTZbl
         c1RHyioPFv0in34JfloZmX1DaomWfCjh7qf5ioBibOQipPodPfOcmv8cADz6wKsAS3Co
         G7IJvTc1aekbh9/eGzZMrTczyA8FD4sCjiWagnfFNDmg87WGRednYMLNqWTVfQ7qm60B
         eYDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=qkUM5PHc4fGG1Gos3msNI5iqIZh+zFOQoQJ/383TR9s=;
        b=tNcqTRE0ih+b8EMNGHvepmpIE+OO4CXQ3NEr4cV//rl1HVzT3Aqmsnjy4X50PzCzpu
         DQVxVoF7CkrRYX0suP+xKTELSpkIQ77/3YfK4MlVhAM8JWYgKG/BIPrAh9ECIq89l37M
         6NAV1Hp4cXNAfVXiQn29pGyglYONCYgkWDRhZvE1P0lKi4Klet99kXAg+V4wvQf6lh3o
         v3vW3ewutTg03F762TikI5a+CX0qtLq2x7w6KHmyh4qBE4qYRJRKSX2vAdsB9Ac5RBkp
         p5VblAX4aT6jRbtRRDKkUQp7LOIaFI5HcaxB5hZ76lqAvioAK6AMQ1+RWFtJY3Z1hmWC
         Co0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u22si2181690qvf.20.2019.02.11.19.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:00:13 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C56DF9FDCC;
	Tue, 12 Feb 2019 03:00:12 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CD0EF600C6;
	Tue, 12 Feb 2019 02:59:58 +0000 (UTC)
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
Subject: [PATCH v2 18/26] khugepaged: skip collapse if uffd-wp detected
Date: Tue, 12 Feb 2019 10:56:24 +0800
Message-Id: <20190212025632.28946-19-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 12 Feb 2019 03:00:13 +0000 (UTC)
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
index 4f017339ddb2..396c7e4da83e 100644
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
@@ -1123,6 +1124,15 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
@@ -1142,6 +1152,19 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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

