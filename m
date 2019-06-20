Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6364C48BDF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:23:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87E7C214AF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:23:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87E7C214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 355E28E0007; Wed, 19 Jun 2019 22:23:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32BCC8E0001; Wed, 19 Jun 2019 22:23:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2426F8E0007; Wed, 19 Jun 2019 22:23:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 059C88E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:23:45 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id h47so1646075qtc.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:23:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rQ3xbJr7eyqpQk5fPSSoYksSki3uJVgyjd8kC+XAB+g=;
        b=pZVY341BsTSZ7mLvYcDszSmLbttkRsCAQBFxAvUpsUaL5Uizj//BwyJSm9zywkHoDd
         wyZQgGkvX7SMf1LndS3pGP3eFr1GfvkG9IjapLoYacxXT3oYS7u+Qk4KlisaHio7423V
         1tt+5OMJuF9bPdek1griJRPU69r3LaUOsh2tFCjgaYSPTKAJhU7ZFKA7H3gv9mTcFG3O
         oY8bAJEOk1YyolCltv5AUTcWJxuS/cmiuVaPkuf05pvKYcvgelsFfFyKISxsb4KnYePf
         awSf3Ub/g0Gawp/cf25u3NSclY/gT1xXCCr9ALH/vuxso4ANDTv400AtimGDt7EnQTto
         fxUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV0cfREwp6urbiXI5AFl1mAENDLokYS1gnZu+cb4MOD1PvcLBgi
	oEkWWaYp/I2Vzg3FHdvhrb9aGzQlJ6TLw0NahnUtfw4MKPvLvwpqV8FLNFrlFrLTN1FSzKTMAjO
	noEFC18E+rAppSVs394RXNd6ApLqxH0+4YhbkRvU3rG/hc160Y2Jp861jmYfLO4jVaA==
X-Received: by 2002:ac8:3325:: with SMTP id t34mr105520127qta.172.1560997424805;
        Wed, 19 Jun 2019 19:23:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlMROoeFn+rEGkMhrkoatczTed0iteiCXOdQg6DYjnlXOqa4g0EMd5Gvh7RsCpG/ZhyADW
X-Received: by 2002:ac8:3325:: with SMTP id t34mr105520074qta.172.1560997423889;
        Wed, 19 Jun 2019 19:23:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997423; cv=none;
        d=google.com; s=arc-20160816;
        b=qnZo/RR3BWGcAysWqui7N1S+cexAbUfP+YaLWGwsOH+0VzkwrOYtb3kfY12XfZEXJi
         84erepDmEYjN9J7lO5hANQdL4QJ3BckYfz8L4jWaHEzwO7ZPEjTjb8bHzejBI1eQW20r
         g5uUfdHZv6MBMKUVQLm7NCKcBVfFI7HAZRKqtfgtlHPDVgMxG8/m9bF7kBGDQv9c7umx
         anV/SMfeY9TVpzKpNwl9agIiWnIzyvoNnlwWsDMm9NUf4G/dUGxGrNLwfpAPC9f73fRu
         1quzCuk3q+mME4yW/UC9ZkClh6ggVtseORwBhPcAAjdMAbc4zgrQ9RiIWxVYgbatpu9U
         LkPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=rQ3xbJr7eyqpQk5fPSSoYksSki3uJVgyjd8kC+XAB+g=;
        b=GHVtYKvVMNEGiyeh+68YjBdS2qklTbSBGyuWso+IWGRJSVcgVE6ZfBPlZj3zh3eaD/
         o0woRo4C5Ok/2oZzOGg0nZPz9YMwkUBvbbCHAvztNm54Sotodx9dQXM56GzcR/o15F0R
         RZfiSosorlHS1V6ANgcXxJvaZ7Zc8dKWihsJPJM/tcNRPSoOTnpN2pDksiyrriyIFgls
         NSk/bIaWMgT9t307co4S8Fl2VQvgvKmA0eIX9c3RsU5vEAogzh6aFCzac/zx5+NhyM2Q
         P1MEX/r773jc8rHFHUGrTLhiJdv/btFRu3VJE8rb22Dp5F5hDmOd1PeDUrx6lNmNzntD
         jMeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f19si4122503qtk.184.2019.06.19.19.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:23:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F3594223880;
	Thu, 20 Jun 2019 02:23:42 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E968D1001E69;
	Thu, 20 Jun 2019 02:23:28 +0000 (UTC)
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
Subject: [PATCH v5 16/25] khugepaged: skip collapse if uffd-wp detected
Date: Thu, 20 Jun 2019 10:19:59 +0800
Message-Id: <20190620022008.19172-17-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 20 Jun 2019 02:23:43 +0000 (UTC)
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
index 0f7419938008..fc40aa214be7 100644
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
@@ -1128,6 +1129,15 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
@@ -1147,6 +1157,19 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
2.21.0

