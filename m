Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FBA1C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:52:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CCAF206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:52:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CCAF206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA0996B0008; Fri, 26 Apr 2019 00:52:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A51F26B000A; Fri, 26 Apr 2019 00:52:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91A106B000C; Fri, 26 Apr 2019 00:52:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3BF6B0008
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:52:16 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o34so1898016qte.5
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:52:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=nYsVv5CHuVcs/SDWoc2yWG1yFmoVkxyWiX72w6VRjZk=;
        b=WA8lAEyrX+Nn0oVeg3tgd+qnkidyBzWX2g69OSVFHfLzTKEwlDtnnKCWs8JPo5k3U0
         ZVWJaTgmUt+DVj0+1JLiEX9DxcR9ChEIFC2/FZ1kMroQ1VZ2Bqek/0nDb0asXf7FagbM
         Qu9D/xuLf1/+S06Fl59kgrIfeCmuuvqpVmV6jdmlw/+WK6Z0whvfJoNIvTn8bJQTIANy
         BtEVz/NJSyiMeJIMJ1TZhrV4SgGRJ9Ix5ioDhDpWhd2+8Df9y3oSu+3GOMJ5Adbh77RK
         pFykYDdntaHEA7kc9kNG2Eq1SE+QCMQ84iNK+7DppNVSifkOU9Nv+nk1L8DEbe5q7P6V
         2IEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW0qTV7whtnJCCw8AJQYYoRTS4949IXyhVdGAm6zk/R8ioZrXTW
	qR7CdtseE+lxhGTpTd/7QDSUnIC8sjRggiGdIVtULo9OBl9LxTeeaV1OupSW9cUVcGNWhNIs/Vv
	/gC190ua0gXFKpsRP+FHK0FdkvbMCLlLBYwC2vrdcb8S5S8Fb33LYz+yiWjfFsSCXWw==
X-Received: by 2002:ac8:2dae:: with SMTP id p43mr25942936qta.14.1556254336217;
        Thu, 25 Apr 2019 21:52:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGXphqPDK0UJ4Nw6hJiSI40FdwAmIsCisZrmTMBTNPae5kVeIBuv/Zxq/cHSQpjCG1Q9jO
X-Received: by 2002:ac8:2dae:: with SMTP id p43mr25942887qta.14.1556254335255;
        Thu, 25 Apr 2019 21:52:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254335; cv=none;
        d=google.com; s=arc-20160816;
        b=x+8od/XHtoLhB1vZkuJ7J1MtcjICn2VpXJbzi3TKjPntJEQ81WDGrSMlMRffbnUKqU
         F9Nkxck6P2BV87Q9UG4hUxqAB6VhyvIZ9IMNeiPVyKekKVNfaTpobgLUTNS+bJiCKk1R
         t1uf/y/zPIpRL0KbyyK+S1H1VKlmDuyzj075NvB4cChsC3QswwQ0OyZ9RmvevNN2mQMk
         /nnf63LlowE6UfFM9laaH95tqkzOtZJnd5bnIibNJJMsa9hUc3vSRszu0j2wSZIYfwKb
         nASSWckEs4lySo7DM2eQ46u1vlAawwrlAESAD5PPZeaozdSUY1wkfspJAExBfueJhTfu
         pJMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=nYsVv5CHuVcs/SDWoc2yWG1yFmoVkxyWiX72w6VRjZk=;
        b=wuf7tdkaPM/pgHdnlSACI8tzT2/M/2UIC4gv1wVpvB4CbNRSN9GJycLPzy8V7tWVux
         6bqxRZaVW/fLTz8f3mCvyj/OgfHScnVwZW1HMYlrEyMYK2ohuPi1KVq8CR00OpEIewsb
         /N601cqAT4/RnSnq+j4MzoX3sSEoMdU+m2NlPCObTgWD9eEb25gjmpa4YbEzmKJDNUJd
         ex3tN/Qw8S2aaFJnwbf6qkbrBEEXwoWAe1Zf1fKssvXkEDu77uNrVjoGqBFiGLDgeJD9
         pt0PxyCnfdUH3h/lNwrCwu8ojqqb40GzANuL/k8XEVedJLRpMoij2zKrBcnHCPYcjWwp
         b+lQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u26si4076692qkk.265.2019.04.25.21.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:52:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 55B3330ADBD9;
	Fri, 26 Apr 2019 04:52:14 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 15FDF194A5;
	Fri, 26 Apr 2019 04:52:06 +0000 (UTC)
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
Subject: [PATCH v4 01/27] mm: gup: rename "nonblocking" to "locked" where proper
Date: Fri, 26 Apr 2019 12:51:25 +0800
Message-Id: <20190426045151.19556-2-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Fri, 26 Apr 2019 04:52:14 +0000 (UTC)
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
index f84e22685aaa..a78d252d6358 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -509,12 +509,12 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
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
@@ -526,7 +526,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_WRITE;
 	if (*flags & FOLL_REMOTE)
 		fault_flags |= FAULT_FLAG_REMOTE;
-	if (nonblocking)
+	if (locked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
@@ -552,8 +552,8 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	}
 
 	if (ret & VM_FAULT_RETRY) {
-		if (nonblocking && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
-			*nonblocking = 0;
+		if (locked && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
+			*locked = 0;
 		return -EBUSY;
 	}
 
@@ -630,7 +630,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  *		only intends to ensure the pages are faulted in.
  * @vmas:	array of pointers to vmas corresponding to each page.
  *		Or NULL if the caller does not require them.
- * @nonblocking: whether waiting for disk IO or mmap_sem contention
+ * @locked:     whether we're still with the mmap_sem held
  *
  * Returns number of pages pinned. This may be fewer than the number
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
@@ -659,13 +659,11 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
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
@@ -677,7 +675,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *nonblocking)
+		struct vm_area_struct **vmas, int *locked)
 {
 	long ret = 0, i = 0;
 	struct vm_area_struct *vma = NULL;
@@ -721,7 +719,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
 						&start, &nr_pages, i,
-						gup_flags, nonblocking);
+						gup_flags, locked);
 				continue;
 			}
 		}
@@ -739,7 +737,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		page = follow_page_mask(vma, start, foll_flags, &ctx);
 		if (!page) {
 			ret = faultin_page(tsk, vma, start, &foll_flags,
-					nonblocking);
+					   locked);
 			switch (ret) {
 			case 0:
 				goto retry;
@@ -1347,7 +1345,7 @@ EXPORT_SYMBOL(get_user_pages_longterm);
  * @vma:   target vma
  * @start: start address
  * @end:   end address
- * @nonblocking:
+ * @locked: whether the mmap_sem is still held
  *
  * This takes care of mlocking the pages too if VM_LOCKED is set.
  *
@@ -1355,14 +1353,14 @@ EXPORT_SYMBOL(get_user_pages_longterm);
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
@@ -1397,7 +1395,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	 * not result in a stack expansion that recurses back here.
 	 */
 	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
+				NULL, NULL, locked);
 }
 
 /*
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 97b1e0290c66..e77b56141f0c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4191,7 +4191,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,
-			 long i, unsigned int flags, int *nonblocking)
+			 long i, unsigned int flags, int *locked)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
@@ -4262,7 +4262,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				spin_unlock(ptl);
 			if (flags & FOLL_WRITE)
 				fault_flags |= FAULT_FLAG_WRITE;
-			if (nonblocking)
+			if (locked)
 				fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 			if (flags & FOLL_NOWAIT)
 				fault_flags |= FAULT_FLAG_ALLOW_RETRY |
@@ -4279,9 +4279,9 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
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

