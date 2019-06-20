Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C135FC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:20:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 719BA2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:20:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 719BA2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D00E6B0005; Wed, 19 Jun 2019 22:20:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 180FB8E0002; Wed, 19 Jun 2019 22:20:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06EE98E0001; Wed, 19 Jun 2019 22:20:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D95C16B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:20:39 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so1665333qte.8
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:20:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x0adZNsyyZj3oLuHDkXHPlZ8L8iyk5kBrsICEZ96nek=;
        b=RqUQ7n562S5eioQEkmi2UL0CKs+W3WsHjPBrGMn6FbVAJIIA0Lo3GobJhZ+lG2VbPL
         Y781GP8/YWOpo52xYQ3Tr3fS/aMm1+hN1PH/N4WjRDbS+wpLS+XCIpWMJiz1O3U4eMJ5
         OKgLDfP3Yh7fleQoY5wcQGEGEI0vA1POKNqhS4xXLHvaWgWgjLI6dCcRCPSto25Iujr/
         /jRUMZ6xut01aeb424JzmlZoBNAdkvYc//eUMNhpa4OI9/2k7jzEqvnraj8k3SRXDoF0
         fNNXQ5aGtBH1U0a10ltzDL1tV1bEqeFGB9EemFWZaVzVaI2IFRezZbgMtO5qZDXD1Z5u
         ccZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVzcccBs9IfkY7QD48csIUjSqe7F4bvWKyLO0xUi4fhayialAgG
	3Bfm4w2AcfMvDFkKy6yfLYZQpVz6DhQ2SaCOvwqcHA0VMFAgnuve2RZyEit40jb9j3YJkCwzGya
	mFOOz0sBJURjtm+y4IoRsn+8Q3/wMkFwo6RU44mAHyq+WsCvp9LvlNqgbpv/IZazufA==
X-Received: by 2002:ac8:2268:: with SMTP id p37mr77134609qtp.187.1560997239534;
        Wed, 19 Jun 2019 19:20:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyw1+SV4A+NSRXlSuCbaQPyuj0dTSoxReankDVF6ehhNlCP3205A/0zdUcbximFzzB+CMCW
X-Received: by 2002:ac8:2268:: with SMTP id p37mr77134533qtp.187.1560997238557;
        Wed, 19 Jun 2019 19:20:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997238; cv=none;
        d=google.com; s=arc-20160816;
        b=Ld2nI7rcDRaj+q4y+2MxJ0fjLpGuzgqM13Oi/hoeAckzOXZCz4vBpwinIjAmuOS0Z+
         ZzPOp1MnKyM0YzL4UXjz13UKi8K1cxoYQvWBiUFZMFxsgtOMv962FFNaYI78PhgpvobL
         KsXSm3Myw7+qe9me0i3aOBlwEWaoEOm1hAQA4WclZukXO6NsbiTDmWyEGOO10kqj0Kul
         b4/GoiBzZ/HoVwhGa1hJI9upf6YTDCTstDTJNWtOTr1SzDiMsIttob10eckNd9lD05Xf
         kdDZL+50ypTay1BSiZ4TY6bdKcWuZ5hv2FluQTW8xl2VLOXs7Srpo4BqxlIfydgH+VSQ
         33dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=x0adZNsyyZj3oLuHDkXHPlZ8L8iyk5kBrsICEZ96nek=;
        b=1Hi/7109Trhw+BZ+XytI6M408HYvZZKVFPGcs022QSaMa5pxo58Z5lt9+20qKSZZlj
         OsSibLZS8MEC25hIpsUOMChN4D1LYk1xM9XVKDRH6LHh5xZmbniDtgNblDLEg0dXqFjl
         ypiWUnqJtu5ngFUG5dFLtCKh5SFPJGKVHOBum5H4ki3fvCuCzJY6xZCyrEcEi9cmc7Ps
         4dCO/R/DOw2Mv0yhnjy5/xAyFQ4b7UjlE+UuOTZXjBYjTAeSu4SwyeuEqNh6Rpy76cZ0
         lg9rLZmqWqfRjazXNRWlx4Tk4KFgni+K1XBHDPUQfNHKEYJAKSqsPsB0YSQUzV7wSfb7
         pp0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r8si3946871qte.143.2019.06.19.19.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:20:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9E7CF3082E25;
	Thu, 20 Jun 2019 02:20:37 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 93ED31001E6F;
	Thu, 20 Jun 2019 02:20:25 +0000 (UTC)
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
Subject: [PATCH v5 01/25] mm: gup: rename "nonblocking" to "locked" where proper
Date: Thu, 20 Jun 2019 10:19:44 +0800
Message-Id: <20190620022008.19172-2-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 20 Jun 2019 02:20:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There's plenty of places around __get_user_pages() that has a parameter
"nonblocking" which does not really mean that "it won't block" (because
it can really block) but instead it shows whether the mmap_sem is
released by up_read() during the page fault handling mostly when
VM_FAULT_RETRY is returned.

We have the correct naming in e.g. get_user_pages_locked() or
get_user_pages_remote() as "locked", however there're still many places
that are using the "nonblocking" as name.

Renaming the places to "locked" where proper to better suite the
functionality of the variable.  While at it, fixing up some of the
comments accordingly.

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/gup.c     | 44 +++++++++++++++++++++-----------------------
 mm/hugetlb.c |  8 ++++----
 2 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ddde097cf9e4..58d282115d9b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -625,12 +625,12 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 }
 
 /*
- * mmap_sem must be held on entry.  If @nonblocking != NULL and
- * *@flags does not include FOLL_NOWAIT, the mmap_sem may be released.
- * If it is, *@nonblocking will be set to 0 and -EBUSY returned.
+ * mmap_sem must be held on entry.  If @locked != NULL and *@flags
+ * does not include FOLL_NOWAIT, the mmap_sem may be released.  If it
+ * is, *@locked will be set to 0 and -EBUSY returned.
  */
 static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
-		unsigned long address, unsigned int *flags, int *nonblocking)
+		unsigned long address, unsigned int *flags, int *locked)
 {
 	unsigned int fault_flags = 0;
 	vm_fault_t ret;
@@ -642,7 +642,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_WRITE;
 	if (*flags & FOLL_REMOTE)
 		fault_flags |= FAULT_FLAG_REMOTE;
-	if (nonblocking)
+	if (locked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
@@ -668,8 +668,8 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	}
 
 	if (ret & VM_FAULT_RETRY) {
-		if (nonblocking && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
-			*nonblocking = 0;
+		if (locked && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
+			*locked = 0;
 		return -EBUSY;
 	}
 
@@ -746,7 +746,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  *		only intends to ensure the pages are faulted in.
  * @vmas:	array of pointers to vmas corresponding to each page.
  *		Or NULL if the caller does not require them.
- * @nonblocking: whether waiting for disk IO or mmap_sem contention
+ * @locked:     whether we're still with the mmap_sem held
  *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
@@ -775,13 +775,11 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  * appropriate) must be called after the page is finished with, and
  * before put_page is called.
  *
- * If @nonblocking != NULL, __get_user_pages will not wait for disk IO
- * or mmap_sem contention, and if waiting is needed to pin all pages,
- * *@nonblocking will be set to 0.  Further, if @gup_flags does not
- * include FOLL_NOWAIT, the mmap_sem will be released via up_read() in
- * this case.
+ * If @locked != NULL, *@locked will be set to 0 when mmap_sem is
+ * released by an up_read().  That can happen if @gup_flags does not
+ * have FOLL_NOWAIT.
  *
- * A caller using such a combination of @nonblocking and @gup_flags
+ * A caller using such a combination of @locked and @gup_flags
  * must therefore hold the mmap_sem for reading only, and recognize
  * when it's been released.  Otherwise, it must be held for either
  * reading or writing and will not be released.
@@ -793,7 +791,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *nonblocking)
+		struct vm_area_struct **vmas, int *locked)
 {
 	long ret = 0, i = 0;
 	struct vm_area_struct *vma = NULL;
@@ -837,7 +835,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
 						&start, &nr_pages, i,
-						gup_flags, nonblocking);
+						gup_flags, locked);
 				continue;
 			}
 		}
@@ -855,7 +853,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		page = follow_page_mask(vma, start, foll_flags, &ctx);
 		if (!page) {
 			ret = faultin_page(tsk, vma, start, &foll_flags,
-					nonblocking);
+					   locked);
 			switch (ret) {
 			case 0:
 				goto retry;
@@ -1508,7 +1506,7 @@ EXPORT_SYMBOL(get_user_pages);
  * @vma:   target vma
  * @start: start address
  * @end:   end address
- * @nonblocking:
+ * @locked: whether the mmap_sem is still held
  *
  * This takes care of mlocking the pages too if VM_LOCKED is set.
  *
@@ -1516,14 +1514,14 @@ EXPORT_SYMBOL(get_user_pages);
  *
  * vma->vm_mm->mmap_sem must be held.
  *
- * If @nonblocking is NULL, it may be held for read or write and will
+ * If @locked is NULL, it may be held for read or write and will
  * be unperturbed.
  *
- * If @nonblocking is non-NULL, it must held for read only and may be
- * released.  If it's released, *@nonblocking will be set to 0.
+ * If @locked is non-NULL, it must held for read only and may be
+ * released.  If it's released, *@locked will be set to 0.
  */
 long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking)
+		unsigned long start, unsigned long end, int *locked)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long nr_pages = (end - start) / PAGE_SIZE;
@@ -1558,7 +1556,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	 * not result in a stack expansion that recurses back here.
 	 */
 	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
+				NULL, NULL, locked);
 }
 
 /*
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ac843d32b019..ba179c2fa8fb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4240,7 +4240,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,
-			 long i, unsigned int flags, int *nonblocking)
+			 long i, unsigned int flags, int *locked)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
@@ -4311,7 +4311,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				spin_unlock(ptl);
 			if (flags & FOLL_WRITE)
 				fault_flags |= FAULT_FLAG_WRITE;
-			if (nonblocking)
+			if (locked)
 				fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 			if (flags & FOLL_NOWAIT)
 				fault_flags |= FAULT_FLAG_ALLOW_RETRY |
@@ -4328,9 +4328,9 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				break;
 			}
 			if (ret & VM_FAULT_RETRY) {
-				if (nonblocking &&
+				if (locked &&
 				    !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
-					*nonblocking = 0;
+					*locked = 0;
 				*nr_pages = 0;
 				/*
 				 * VM_FAULT_RETRY must not return an
-- 
2.21.0

