Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D908FC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BE13217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BE13217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32ADB6B000C; Tue, 19 Mar 2019 22:09:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B8636B0276; Tue, 19 Mar 2019 22:09:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 156FA6B0277; Tue, 19 Mar 2019 22:09:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC4FA6B000C
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:09:19 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c25so905739qtj.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:09:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=m5VRtYdvEYOOA3DJLOgIjYl2bvguQi+nAgVZ8BaRsF8=;
        b=pLw6pa3jWLo0pSEDlq+oODK5pCZY/icqgrclh6QJoyXoLXK5AoDwzQ8HVYwrCcV+nK
         TPWBBsInIc/0Wis7n0J9iweQ0ZjswV0fUwobjnUh+bdN0SusskzdFRxUPtsiSKOx5prz
         CMhGfS5pwoQfWIvKDwNtvyEXZSaHDJfyVt1L5xgZQFbAUqE/MCUT9lmom5nAonEDolJ3
         b8xMOuQ8OKMcm7Z4xNHpBfW+3LTc8fjbw3QqK70F+mqjrbrNnBNEE02N1YuxjPCUgnHO
         IUUV5hOd2DE6LwMMXkYqR6ceIc4bVHx+NCJUCM+/lTff/YTZ5SPsadEr1B7nW0W6RPK+
         I/sw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVvZf2zN+osogb74+sk5+OphFhyheZ5Lxsm3Ymhi+FcnYXCivgB
	0nWW0OdiSWnBw4lBtymkAc9dged4hJaS/bYgj+IdYSuAHLl/JiIZYqKjoD8LrFTgYB+MRWIRI0t
	b1wyLO1JR1CTljiDIToZloLffmmEfU+W/bXcfjlcnkIjNq2h+3jPhGCc0oQXRtxabKw==
X-Received: by 2002:a37:650c:: with SMTP id z12mr4537273qkb.115.1553047759685;
        Tue, 19 Mar 2019 19:09:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCiCj8qykdOifH1dHx//XDr1scqCeEV6khjBI79Zfi3c6HcqiR1MF2NX2MNFL8sbmp1OYZ
X-Received: by 2002:a37:650c:: with SMTP id z12mr4537220qkb.115.1553047758588;
        Tue, 19 Mar 2019 19:09:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047758; cv=none;
        d=google.com; s=arc-20160816;
        b=V7UnG1sIzkeJrulZsvCYptYHnsHMllcyljd43H0/j8nHqMM0KFqqaQyksNuLxAaIn5
         L9vtCuVPM8OECgu7YaT8u4VGeptCM65pfCBWhk2hp6Hx3jXKo6uIkylNswEiEJXZO/Kj
         n3SZWtDcLNlYtlRgxm91wRsLm931FEic9jDb784b9/Vd2OhhnSN5Z0ZtAfnAot4SAyET
         dvvX8S0k3HSqz1UqOJLC38QZV4VIDdZuS7RG+ePdJ6sJM+IsGnBQYc9qfBtTRPFLd4ak
         hS0S3ujdU6XeewbZNuVD1r7RfjihS/5ZQX7EpT2VwkA2F3di5kS/q0qXKpuk60QP3+Rt
         23GA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=m5VRtYdvEYOOA3DJLOgIjYl2bvguQi+nAgVZ8BaRsF8=;
        b=wi4zJhqwo8pbm12fXGfdvfCNNQCobydeisJbVWiRcy3GzMsCS8lUbMfyS2avGO20N8
         3rkXEsylBTtuO3wpXoICz7sjNJ4DEdBMB6QjZDMyncwPV7TwIpAKR0zftA4ZiSX8HAxh
         qHddO7WjQTR+mJDdTefSZlQYbDqv7IJABWFxBvmTGxQL01pTRDLlbnUrUuk3qCcRgcA6
         6nGUKaAlx7C/68Kgi/nGGYaxfaa+eIeuY3LIumgxWirFh+ubgUZKXW5kVRSxiP6HEY1o
         tck/OJtwRUW1rF7SkI8W80l89O9ZYpufyXsSA8cjoIS2BDk+l7s/Q+2iyX9Ifn8t87PK
         j2EA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 91si426127qte.160.2019.03.19.19.09.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:09:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8CD47308FBAE;
	Wed, 20 Mar 2019 02:09:17 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CBB49620A0;
	Wed, 20 Mar 2019 02:09:11 +0000 (UTC)
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
Subject: [PATCH v3 18/28] khugepaged: skip collapse if uffd-wp detected
Date: Wed, 20 Mar 2019 10:06:32 +0800
Message-Id: <20190320020642.4000-19-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 20 Mar 2019 02:09:17 +0000 (UTC)
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

