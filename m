Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2AA5C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52B78217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52B78217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F13486B0007; Tue, 19 Mar 2019 22:08:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC3A56B0266; Tue, 19 Mar 2019 22:08:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB3226B0269; Tue, 19 Mar 2019 22:08:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBA8B6B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:08:22 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id o135so19458329qke.11
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:08:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=guN7gYgnmDjc0dZDM0nP8l0/tmhZ7IhmP3yHcVRz/U4=;
        b=eMM/mNeVCLsDM8a+r/SugUDJSkHPydbVvlavpk4DFlzxz322xpj7dfDRIt5YdFYwiP
         okMrPenzraXCLFPfMYBlvTAPX1L+sj6j7TDsZ73EWI1Y0LxCrWO/5wIq9BLH+3TSns5N
         0D9simKYko59kknO2T/Wc3/dB++kXuYc2ff3XFzmTz9THgU26WTycnKD4t2WTMPLDxdZ
         taOm7HpZrQudwqeYQujjvBUPcjrgpCC7MM3PpUuAZvR9vtGH8MsC24WKUxtDZllpOcmL
         qv1LJo08V4ZHndq6mKk7u2wioiTwnPUEBeFa95yF/EIcGJKu9O2vzZacgzZB7/WP0Bo9
         iMRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXZ1NnSD1HbGhhnSaX3n3CveMsMpxBNfUpyxJCPKtH0I7bKzws5
	ffJCSKw5j0+qshbLF1B444WTFn16DlbFev8sWbOk7D2wMvK+JJS75Sf7/LxypDAGqF7cKQ70JJx
	41rtrkIcbniPYqUt6aTSGXB3Ec+zu9NRfRzm+Mtn+sJ5uviDiDL+MdLPBmP6vG907bw==
X-Received: by 2002:a37:98c7:: with SMTP id a190mr4435407qke.308.1553047702523;
        Tue, 19 Mar 2019 19:08:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgSmq3Ug2bdf8pio4DLaR3SiX/1aEaILZR2y3yWopfaeExifRDTSOfRToiGjeJxZnVtgyj
X-Received: by 2002:a37:98c7:: with SMTP id a190mr4435344qke.308.1553047701173;
        Tue, 19 Mar 2019 19:08:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047701; cv=none;
        d=google.com; s=arc-20160816;
        b=un2ir8mQZxEWQSO7gSJ7w5JZ+Ddv7W3GZqTHCV2iIT0lXGWIX6IvDLxpB4LNEOGuZB
         VF6UspuhGwPh/FE9us96E5mp87G2Z0goKTeGGSs23icXXVItJAQV537AGiaz9mlGaINi
         0NHdIcPT/MaJPARQtcTk1OAX+7kQkedLfnNDQmTCYem5VxxCgiU6z4Agpxp/1rdCgcWP
         aydi4ASZMlE6kNGGEf/mb3e25wCmRZeRiMZQk/lpIY7F0ZFvgGwcVuFrgxU48gOGZKo5
         uAAWR2eij1o8a1tB6VH7dkcjKcXKk4FnS422+mAbLlH4a60/kQci8OKxUoXvX4VKX+E0
         9lxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=guN7gYgnmDjc0dZDM0nP8l0/tmhZ7IhmP3yHcVRz/U4=;
        b=oIoyLRSuzzgvhOaTAmTPATQmOKdDHQ05/7h7FJJbgV0XGhRQAd/maFQ0pUIjrGjTJE
         RgAUlQDFHzoYL5cTAAWcECgniDkU66Y0Ky2NkL+ExldtWNT4yNh3znOvlnFm8XbJ61Yb
         f1NWC3+oyIceURywEnllMRSYC2rsJ3zGLZqNO6apTrvmgIE31rBUWLMrWq1LHsyc9AGH
         iFePVC7Fn9GplSuIS9aBK2XwwTD8kYwJloFZCRkMKWFKOm3ZtKTEGQwtQPuX7cqILmvJ
         yojlHF2JA8p4ZjaBotXVPaw4kL1GyTQHf/wpfB5v//9V51UkNNdqtqbW9xv4lp9jp0Hh
         83Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n54si428411qtf.156.2019.03.19.19.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:08:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 37A2A83F42;
	Wed, 20 Mar 2019 02:08:20 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8ED18605CA;
	Wed, 20 Mar 2019 02:08:10 +0000 (UTC)
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
Subject: [PATCH v3 10/28] userfaultfd: wp: add UFFDIO_COPY_MODE_WP
Date: Wed, 20 Mar 2019 10:06:24 +0800
Message-Id: <20190320020642.4000-11-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 20 Mar 2019 02:08:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

This allows UFFDIO_COPY to map pages write-protected.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
[peterx: switch to VM_WARN_ON_ONCE in mfill_atomic_pte; add brackets
 around "dst_vma->vm_flags & VM_WRITE"; fix wordings in comments and
 commit messages]
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c                 |  5 +++--
 include/linux/userfaultfd_k.h    |  2 +-
 include/uapi/linux/userfaultfd.h | 11 +++++-----
 mm/userfaultfd.c                 | 36 ++++++++++++++++++++++----------
 4 files changed, 35 insertions(+), 19 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index b397bc3b954d..3092885c9d2c 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1683,11 +1683,12 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 	ret = -EINVAL;
 	if (uffdio_copy.src + uffdio_copy.len <= uffdio_copy.src)
 		goto out;
-	if (uffdio_copy.mode & ~UFFDIO_COPY_MODE_DONTWAKE)
+	if (uffdio_copy.mode & ~(UFFDIO_COPY_MODE_DONTWAKE|UFFDIO_COPY_MODE_WP))
 		goto out;
 	if (mmget_not_zero(ctx->mm)) {
 		ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
-				   uffdio_copy.len, &ctx->mmap_changing);
+				   uffdio_copy.len, &ctx->mmap_changing,
+				   uffdio_copy.mode);
 		mmput(ctx->mm);
 	} else {
 		return -ESRCH;
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index c6590c58ce28..765ce884cec0 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -34,7 +34,7 @@ extern vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason);
 
 extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
 			    unsigned long src_start, unsigned long len,
-			    bool *mmap_changing);
+			    bool *mmap_changing, __u64 mode);
 extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
 			      unsigned long dst_start,
 			      unsigned long len,
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 48f1a7c2f1f0..340f23bc251d 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -203,13 +203,14 @@ struct uffdio_copy {
 	__u64 dst;
 	__u64 src;
 	__u64 len;
+#define UFFDIO_COPY_MODE_DONTWAKE		((__u64)1<<0)
 	/*
-	 * There will be a wrprotection flag later that allows to map
-	 * pages wrprotected on the fly. And such a flag will be
-	 * available if the wrprotection ioctl are implemented for the
-	 * range according to the uffdio_register.ioctls.
+	 * UFFDIO_COPY_MODE_WP will map the page write protected on
+	 * the fly.  UFFDIO_COPY_MODE_WP is available only if the
+	 * write protected ioctl is implemented for the range
+	 * according to the uffdio_register.ioctls.
 	 */
-#define UFFDIO_COPY_MODE_DONTWAKE		((__u64)1<<0)
+#define UFFDIO_COPY_MODE_WP			((__u64)1<<1)
 	__u64 mode;
 
 	/*
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index d59b5a73dfb3..eaecc21806da 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -25,7 +25,8 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 			    struct vm_area_struct *dst_vma,
 			    unsigned long dst_addr,
 			    unsigned long src_addr,
-			    struct page **pagep)
+			    struct page **pagep,
+			    bool wp_copy)
 {
 	struct mem_cgroup *memcg;
 	pte_t _dst_pte, *dst_pte;
@@ -71,9 +72,9 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 	if (mem_cgroup_try_charge(page, dst_mm, GFP_KERNEL, &memcg, false))
 		goto out_release;
 
-	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
-	if (dst_vma->vm_flags & VM_WRITE)
-		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
+	_dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
+	if ((dst_vma->vm_flags & VM_WRITE) && !wp_copy)
+		_dst_pte = pte_mkwrite(_dst_pte);
 
 	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
 	if (dst_vma->vm_file) {
@@ -399,7 +400,8 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
 						unsigned long dst_addr,
 						unsigned long src_addr,
 						struct page **page,
-						bool zeropage)
+						bool zeropage,
+						bool wp_copy)
 {
 	ssize_t err;
 
@@ -416,11 +418,13 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
 	if (!(dst_vma->vm_flags & VM_SHARED)) {
 		if (!zeropage)
 			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
-					       dst_addr, src_addr, page);
+					       dst_addr, src_addr, page,
+					       wp_copy);
 		else
 			err = mfill_zeropage_pte(dst_mm, dst_pmd,
 						 dst_vma, dst_addr);
 	} else {
+		VM_WARN_ON_ONCE(wp_copy);
 		if (!zeropage)
 			err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
 						     dst_vma, dst_addr,
@@ -438,7 +442,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 					      unsigned long src_start,
 					      unsigned long len,
 					      bool zeropage,
-					      bool *mmap_changing)
+					      bool *mmap_changing,
+					      __u64 mode)
 {
 	struct vm_area_struct *dst_vma;
 	ssize_t err;
@@ -446,6 +451,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	unsigned long src_addr, dst_addr;
 	long copied;
 	struct page *page;
+	bool wp_copy;
 
 	/*
 	 * Sanitize the command parameters:
@@ -502,6 +508,14 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	    dst_vma->vm_flags & VM_SHARED))
 		goto out_unlock;
 
+	/*
+	 * validate 'mode' now that we know the dst_vma: don't allow
+	 * a wrprotect copy if the userfaultfd didn't register as WP.
+	 */
+	wp_copy = mode & UFFDIO_COPY_MODE_WP;
+	if (wp_copy && !(dst_vma->vm_flags & VM_UFFD_WP))
+		goto out_unlock;
+
 	/*
 	 * If this is a HUGETLB vma, pass off to appropriate routine
 	 */
@@ -557,7 +571,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 		BUG_ON(pmd_trans_huge(*dst_pmd));
 
 		err = mfill_atomic_pte(dst_mm, dst_pmd, dst_vma, dst_addr,
-				       src_addr, &page, zeropage);
+				       src_addr, &page, zeropage, wp_copy);
 		cond_resched();
 
 		if (unlikely(err == -ENOENT)) {
@@ -604,14 +618,14 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 
 ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
 		     unsigned long src_start, unsigned long len,
-		     bool *mmap_changing)
+		     bool *mmap_changing, __u64 mode)
 {
 	return __mcopy_atomic(dst_mm, dst_start, src_start, len, false,
-			      mmap_changing);
+			      mmap_changing, mode);
 }
 
 ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
 		       unsigned long len, bool *mmap_changing)
 {
-	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing);
+	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing, 0);
 }
-- 
2.17.1

