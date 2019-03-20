Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8D12C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5ADBD217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5ADBD217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E3816B0006; Tue, 19 Mar 2019 22:07:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 094866B0007; Tue, 19 Mar 2019 22:07:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC52F6B0008; Tue, 19 Mar 2019 22:07:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9A2A6B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:07:03 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v2so811905qkf.21
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:07:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=vEMcSd27exybzmip3JgYjLqtTvZHhvrIgjQE9HQqX1c=;
        b=SuofEe93sQAEKlVyb0jfb309KY2VzGmoHpBKBS/RwwnF0U5jclp4kz0rUgb6LnuiSE
         mKB/q4HFZBv8S5UE8Uv6jVtGageGsM0NbRX5vhsc+FY2p0dOrii2jMNS3iPzBse+7Zil
         zDk7t5ZrjcMC94dRcSvO4/aiGK5FNV35BPRDgqsiHvXbkzBzf7GC0IG5tkYIh+ZXXpF4
         NfEb08i1/9La2u+YyoGd0TxItqPOkNI7i9p28HWG+ird2SgVGaCv0GO5AKOWYtS12SQ7
         wyUIZtOyJzTLC0WYvRhTqU4lvm0eYI65mFd40S8R7a1qMowOGSOyB7lmIr9Paz+/Y3MQ
         qkLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVQbOMQeNtxbiJLEVFs5yc1OxbRkS+qMR6/dofkjkPW+af1X+JA
	IlzD/0L+CYuA9fmwBm8C44QG+B+pTGk6hbSKYmqfVgnybV58dpMCRIQ2LSCM0/Wu18uSZ4h/v9U
	hykvKksDVDyKtc35n7wpKl9fcvbIPcXjeKLwMkWXA45AJMIhrytRU9x9l3FxQV2V91w==
X-Received: by 2002:a05:620a:14b0:: with SMTP id x16mr4317855qkj.187.1553047623576;
        Tue, 19 Mar 2019 19:07:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmT9wLYfaVyXZgYDi0qSm2xrx1ZQzCiLh6uloM7BfQD5TTxDP6ucUU5g5hI1UW3ex/pAAm
X-Received: by 2002:a05:620a:14b0:: with SMTP id x16mr4317784qkj.187.1553047621986;
        Tue, 19 Mar 2019 19:07:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047621; cv=none;
        d=google.com; s=arc-20160816;
        b=moL76mwoj5MTR1H3UWtejw0k7beHRyUzymcsDLAIS6nX68H590H4LPw+p/MH0iHKs3
         wyKAs0dmHVHcJiedCGQRPemLuL521l57s0p8kS46BPbx88MJKGa+QL/w24KDPHhQjJG9
         NQGuRsAYjqq5UZDWCQ3I4Hn9/M7Dsn6Bei1NHyYj1ArSSX/AXirI8V8PYJgTYLK7Rb9i
         o65Mt2H2wdSRZtmKmM362QQKcjFDI83LNfH72URqOV35mVQiWpug89DzEzH7DlvhBaIO
         aPOEa3y7ijBFrVFx2SnkTLNYTXw6xvyVFeOEBu0SozsmbtM59Zsi0GmcspLy4R0GGUaQ
         ApEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=vEMcSd27exybzmip3JgYjLqtTvZHhvrIgjQE9HQqX1c=;
        b=jZOPordU1xCiJ9mlvJu36LEP9rdEK/SCPiE6MlBJFL2xdByMe2tag5T9KAr1qIPb3G
         HVEeDK8ZrWGIro86TSpw3Yn4zWT7YDCUSZVZ6pFantpFBUIq09z6JcdRzubWhwnmWQRk
         baVofRpZcnARt1Gr+sr3n3Sf4F0GV/WBb4Ok1oznXaC3rh+O2yEMhef3zaktUYTRloOt
         c4Jdp5HY7LE21rf8Tm9AwnaL9uq6FUAyvZbep6zhFB4mJXDmdXk9AZi8CZMWCd0SX0HV
         cI5VNcYZglP7Y2T8Mna0j/4YSTqOIuhxwxd7uFCNJdlnlhnMK8/aMUckv76dufgmA1zl
         BzcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d58si487016qtk.97.2019.03.19.19.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:07:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 19A32308792D;
	Wed, 20 Mar 2019 02:07:01 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 38015605CA;
	Wed, 20 Mar 2019 02:06:54 +0000 (UTC)
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
Subject: [PATCH v3 01/28] mm: gup: rename "nonblocking" to "locked" where proper
Date: Wed, 20 Mar 2019 10:06:15 +0800
Message-Id: <20190320020642.4000-2-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 20 Mar 2019 02:07:01 +0000 (UTC)
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
index 75029649baca..9bb3bed68ee3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -506,12 +506,12 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
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
@@ -523,7 +523,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_WRITE;
 	if (*flags & FOLL_REMOTE)
 		fault_flags |= FAULT_FLAG_REMOTE;
-	if (nonblocking)
+	if (locked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
@@ -549,8 +549,8 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	}
 
 	if (ret & VM_FAULT_RETRY) {
-		if (nonblocking && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
-			*nonblocking = 0;
+		if (locked && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
+			*locked = 0;
 		return -EBUSY;
 	}
 
@@ -627,7 +627,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  *		only intends to ensure the pages are faulted in.
  * @vmas:	array of pointers to vmas corresponding to each page.
  *		Or NULL if the caller does not require them.
- * @nonblocking: whether waiting for disk IO or mmap_sem contention
+ * @locked:     whether we're still with the mmap_sem held
  *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
@@ -656,13 +656,11 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
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
@@ -674,7 +672,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *nonblocking)
+		struct vm_area_struct **vmas, int *locked)
 {
 	long ret = 0, i = 0;
 	struct vm_area_struct *vma = NULL;
@@ -718,7 +716,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
 						&start, &nr_pages, i,
-						gup_flags, nonblocking);
+						gup_flags, locked);
 				continue;
 			}
 		}
@@ -736,7 +734,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		page = follow_page_mask(vma, start, foll_flags, &ctx);
 		if (!page) {
 			ret = faultin_page(tsk, vma, start, &foll_flags,
-					nonblocking);
+					   locked);
 			switch (ret) {
 			case 0:
 				goto retry;
@@ -1195,7 +1193,7 @@ EXPORT_SYMBOL(get_user_pages_longterm);
  * @vma:   target vma
  * @start: start address
  * @end:   end address
- * @nonblocking:
+ * @locked: whether the mmap_sem is still held
  *
  * This takes care of mlocking the pages too if VM_LOCKED is set.
  *
@@ -1203,14 +1201,14 @@ EXPORT_SYMBOL(get_user_pages_longterm);
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
@@ -1245,7 +1243,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	 * not result in a stack expansion that recurses back here.
 	 */
 	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
+				NULL, NULL, locked);
 }
 
 /*
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8dfdffc34a99..52296ce4025a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4190,7 +4190,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,
-			 long i, unsigned int flags, int *nonblocking)
+			 long i, unsigned int flags, int *locked)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
@@ -4261,7 +4261,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				spin_unlock(ptl);
 			if (flags & FOLL_WRITE)
 				fault_flags |= FAULT_FLAG_WRITE;
-			if (nonblocking)
+			if (locked)
 				fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 			if (flags & FOLL_NOWAIT)
 				fault_flags |= FAULT_FLAG_ALLOW_RETRY |
@@ -4278,9 +4278,9 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
2.17.1

