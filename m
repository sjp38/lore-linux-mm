Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 543AEC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:52:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B5E4206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:52:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B5E4206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A04476B0010; Fri, 26 Apr 2019 00:52:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B4BA6B0266; Fri, 26 Apr 2019 00:52:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A4DF6B0269; Fri, 26 Apr 2019 00:52:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63C0A6B0010
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:52:51 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t23so1879503qtj.13
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:52:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=6n1/wIReuyJP1CMWC1mqNA//1zjNIv45DTVZimaytg8=;
        b=X4enOqnUNbOcOsJuIwy21ixWUBdH5DlVz0tGsEzKA/gktTM2zD0NPcujs4sMGqn7GB
         iP9gxTObvCGOO/KwI26Z+Wq4t5b/sEDfl89xd/BgMFfMK44YETt9svxzb4H1r/xl5tE9
         2YxoGZ+RfPCoM/OPTHGvu84RF+sw0slX7+vckMLTRcRcPBGxzODOQ214pJksVY5KcQ76
         TTUzICvQYOoeC95k/jTsS9dhRf8FKcNWdYSzkjq2Kp6Ciu5kLe547leUDjLw/7MH+uKI
         p4QJDOx8pSOu46PWG9ScTNaWuBAGMmWhNxwGU811uVtpQ5NcPl6WcKqu7yxLMpREdVki
         SXBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVJcGtdYzgkdyEb6YKerF3iARvnolygm5JtwWY2wzIDvDY9PxJG
	z4hD6DIojKQ7qWJWiYpPWgocwajEXvtxLfqNamLqPPNtWdKN8nipzOhliBmQNYkt/0aOMN7kU/K
	cYDlnbX1s6OJ5vJ3P0ynPLKjtcZCpXxDXcR47O0Qh4PbTyYcbo7iLqFisK9m7nBEXjA==
X-Received: by 2002:ae9:f218:: with SMTP id m24mr32696863qkg.261.1556254371196;
        Thu, 25 Apr 2019 21:52:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysPDLtwK2tKu9bGqwsL+TFmkuqpgx4CBYK9SyJBlqgh6wXT0/lWzAuCOSxwGgGjQLTThWa
X-Received: by 2002:ae9:f218:: with SMTP id m24mr32696844qkg.261.1556254370634;
        Thu, 25 Apr 2019 21:52:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254370; cv=none;
        d=google.com; s=arc-20160816;
        b=Hljfac/fMklfj3b4iPouCT3WTfjLCaZgCRRHSuB+xhNa981wcUs+AkEQ6wJpeRGTKW
         g5epwvZtRIQ39aa5ADgArSR70c/r1yHDJy5PtgXT/Cl3auRU6YaZOelp3Yu1XmqE7idh
         GUZ3tmCNawiio/J0ZMp8tL9WXdAm2Q4ufXXCBkF8mvNDgUKDTTmzAc/tIQR7moe0Pb6l
         XzuQoeDXlq5xEkW1ipSR6DbeW/Rgylw/EwiNTE3YZd/h+/+wwvSZNNf09y2SMFQAoQ/e
         Beo+Yzz1YvAfTWCEpGhnCo4FawQexLw2EkmBpSTHpXn/1HTi/FWeEQ2xdwYz3nbNUn9/
         9riQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=6n1/wIReuyJP1CMWC1mqNA//1zjNIv45DTVZimaytg8=;
        b=c6NKGSU3jaJg2bmvZ4WHTDAHlXT0Ztrt8MvYRdJYJWlNu8sKSroiGsNe5vC5XdKtai
         +Xe+nyejWQ4QIMtbgUlvvCZnYD0f/h9rc4uxMiqgU2TWBaz8jWqfQqTuxqMuzwctuQbb
         ygC8HX3dxWtN2T0ZK7kqd97tnjQUY/Er2KGbNu3ivrBjiXQr9QorXykphvBeElU9Oh1h
         HkTvc0yHlDPAYgljtPo+8DXwbvS1kACp9fegxzkfOrt1pGNv89785SD4Glur87uzfY8N
         +2ynBUmYSvz3wz9R0x3HF4lyqxZFmPbAz4YGMfpjaLHttSOzyuAi5V90P4m0d+9Eqq5L
         DyDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l35si4420734qte.230.2019.04.25.21.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:52:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C6AB33082B41;
	Fri, 26 Apr 2019 04:52:49 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B7AAD17B21;
	Fri, 26 Apr 2019 04:52:38 +0000 (UTC)
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
Subject: [PATCH v4 05/27] mm: gup: allow VM_FAULT_RETRY for multiple times
Date: Fri, 26 Apr 2019 12:51:29 +0800
Message-Id: <20190426045151.19556-6-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 26 Apr 2019 04:52:50 +0000 (UTC)
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
index a78d252d6358..46b1d1412364 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -531,7 +531,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
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
 
@@ -946,17 +949,23 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
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
index e77b56141f0c..d14e2cc6f7c1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4268,8 +4268,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
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

