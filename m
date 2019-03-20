Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34D35C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB2D3217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB2D3217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85E1E6B000C; Tue, 19 Mar 2019 22:07:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80DB16B000D; Tue, 19 Mar 2019 22:07:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FD806B000E; Tue, 19 Mar 2019 22:07:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 516A56B000C
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:07:34 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 75so14388899qki.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:07:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=EMuqhh7UDP9mueKADKHGwGeKC3lB3y4BVPe1BKF6cgY=;
        b=r0yowNc1r/6lk4R9pCGRUXEimtlLXGdlVgJ+PB+FHLtvmjfzFD2YlNDQ68FXvauRUo
         rUTESVvyCYy9eQb1PMbcURPDXCzIF4umAJOuQCuGA1TLsF/kcReRAnsj12rXfk1DFeus
         Os0pfO84VQcQAqi9G8kpimDE6V/w6JVxgt7nNP9SHnyBBhqpq+l49lCuKO3w2xNSiwoB
         GFALukBRJVNswIzLJg2zwq88gR/KD1D+LM3g5j4GlmhfAR2X3ZfYVr98BUz8ykIKdAsq
         obiHMkBVYBMsKCspSOIbweH5SQrbU3jrRUAakmxtEenfU2R1/by9lQBVQ3PrBbCK2Cw+
         PR6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWzIFIzVQctXK8IKcNOIkd5ZBt5Ue/Co4n2oxQ1J8VCa2o6h89C
	XUN3pToHu9bT13amRNhfqIp6E/s1NnFBjdxH3J13dIolbHzSDhq/Gs0vouyWEo83mlfoO/d1KpA
	lhZeIl1GHbt59F0wyqpJLh60e/PkBfJf0GRGL96wpTBHJsUJrogQ4IP6vxNLiY8+ksw==
X-Received: by 2002:aed:3e8e:: with SMTP id n14mr4966042qtf.390.1553047654126;
        Tue, 19 Mar 2019 19:07:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxV01AhwzNypmXTPZvJl7OrwDZF6m9i8KxNkBrw+87HZHnaUb8PehbToxGF03JC4mX05q7V
X-Received: by 2002:aed:3e8e:: with SMTP id n14mr4965995qtf.390.1553047653107;
        Tue, 19 Mar 2019 19:07:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047653; cv=none;
        d=google.com; s=arc-20160816;
        b=bXKUKrFW4EUZUSb/Xk/lghTk4b5zPRoSvAkjbwXfakNQX9IA8TT6CM1pLFlQrquok7
         e3KVd2GQpHNiZ93Gp1TSePTTUtN3Njm0Z50ANKBs3jDiMxKWG+LXmUP+ojFYfKsMi/Ob
         /UGdsASFIAeAgDyQXMR/INQdKEdL8FLWtNOzXwOR/447H4yYCxhHz9xw9Co+foJE0YOm
         FWqIR+O+WG+yICBPOodS69qHq4HWHfbQzrqfeK4TCIzIy6/Kgfj5VM+wFIvlNcTyrKfh
         c+LUoJBsgHoTaAaihEgxq+r9uqEoTS5YE3Oz/9aXcG6AS5MbUjOw00ppWbBSy11YAPGM
         59VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=EMuqhh7UDP9mueKADKHGwGeKC3lB3y4BVPe1BKF6cgY=;
        b=ru2sZXWbcYmF4hqA4ueiiTpgUrXLC/VFjIsRmJT5JYq9XU2TPAOgefgWf5of6MoANq
         b9SR5yj5MLQpSVBBW82KlLp2xDHHif2D3k1X/ifWyk4LkISjdgCPngkl7ffeAea0jA3J
         Iw9frWe4wnOAoge01LVTrtLKbH9q7A6T9aHjYIaGgUQx+ykKylDV4blRIjaABkdA6Skx
         JRfQQ/pn8RbUJMOHwBQPibGSqXK/avnxdG3CsmPS+Mf9iFddSn8eEq0Dn/y7vdAGo4RS
         rDCbDD5agFZzc1LSYI4jIGSfpCgVI33pvGTAQfJwGHgPPvHXdesfCvEGNMGSTrO+C1TX
         L7DA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g22si411607qtb.326.2019.03.19.19.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:07:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 445743087938;
	Wed, 20 Mar 2019 02:07:32 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 88B24601A4;
	Wed, 20 Mar 2019 02:07:24 +0000 (UTC)
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
Subject: [PATCH v3 05/28] mm: gup: allow VM_FAULT_RETRY for multiple times
Date: Wed, 20 Mar 2019 10:06:19 +0800
Message-Id: <20190320020642.4000-6-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 20 Mar 2019 02:07:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is the gup counterpart of the change that allows the VM_FAULT_RETRY
to happen for more than once.

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/gup.c     | 17 +++++++++++++----
 mm/hugetlb.c |  6 ++++--
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 9bb3bed68ee3..f56dee055f26 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -528,7 +528,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
 	if (*flags & FOLL_TRIED) {
-		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
+		/*
+		 * Note: FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED
+		 * can co-exist
+		 */
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
@@ -943,17 +946,23 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		/* VM_FAULT_RETRY triggered, so seek to the faulting offset */
 		pages += ret;
 		start += ret << PAGE_SHIFT;
+		lock_dropped = true;
 
+retry:
 		/*
 		 * Repeat on the address that fired VM_FAULT_RETRY
-		 * without FAULT_FLAG_ALLOW_RETRY but with
+		 * with both FAULT_FLAG_ALLOW_RETRY and
 		 * FAULT_FLAG_TRIED.
 		 */
 		*locked = 1;
-		lock_dropped = true;
 		down_read(&mm->mmap_sem);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+				       pages, NULL, locked);
+		if (!*locked) {
+			/* Continue to retry until we succeeded */
+			BUG_ON(ret != 0);
+			goto retry;
+		}
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 52296ce4025a..040779a7b906 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4267,8 +4267,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				fault_flags |= FAULT_FLAG_ALLOW_RETRY |
 					FAULT_FLAG_RETRY_NOWAIT;
 			if (flags & FOLL_TRIED) {
-				VM_WARN_ON_ONCE(fault_flags &
-						FAULT_FLAG_ALLOW_RETRY);
+				/*
+				 * Note: FAULT_FLAG_ALLOW_RETRY and
+				 * FAULT_FLAG_TRIED can co-exist
+				 */
 				fault_flags |= FAULT_FLAG_TRIED;
 			}
 			ret = hugetlb_fault(mm, vma, vaddr, fault_flags);
-- 
2.17.1

