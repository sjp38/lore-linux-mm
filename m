Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 304ECC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC59C206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC59C206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 792506B000A; Fri, 26 Apr 2019 00:53:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 743446B026F; Fri, 26 Apr 2019 00:53:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60D6A6B0270; Fri, 26 Apr 2019 00:53:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD4D6B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:53:37 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q57so1874488qtf.11
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:53:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=guN7gYgnmDjc0dZDM0nP8l0/tmhZ7IhmP3yHcVRz/U4=;
        b=F4H0lyIVErzJFoDJfwaPNuIUknJ9kbKmjjcKuy++jbnc6Qgy/1w+uypCVwB/AIocM7
         A7SH98sSfogWHbPUTwgU6/+nCzPIG/mwFm2x/jiQ9a0+jSwoaTa6/yQ7hsjYROlhSvaF
         y+F91J/d+RJRvRrA93BW7enqfUbvin2vYXzHjBmiPyL3VACsD29t5Yl5C6Bet6vLQIw+
         jBGuzIBR7pXldDKJ1RL4ySrGqBjqQI/Y3NeHlFuZ0F4cUmwmtBZrsWHLJRzpJejpUEiP
         hHvmfltnnjzkO3RMTKUbNxAxxKarNaEGzLgCYRVVsO9Qkp+hzRn1QTm+HH+L4JGUbziB
         wEZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV77chEhrIlOwyBYUuPLRTeJESa9nNOxLWjgkokJnB7vPcPrefU
	qIVy4MrmKvW2JsGf7Q1gn2qzWWwjXiGd1y8GMhCpGHekaVM3HXLxmYRHqDDCPMOUxqqIK/DfkwH
	7xEuK1CfdFK5apZ5VDILZIvM3PcsB0Rp9aJxJzgFbpkCRXRCztS5zCP+X580sx0WSOg==
X-Received: by 2002:a0c:9810:: with SMTP id c16mr34655772qvd.192.1556254417006;
        Thu, 25 Apr 2019 21:53:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqG9Kesz0beVChGRRxHLMu/2N27pkouw0o4JGSzvwHmgS7nFLI/wSaFIhdxWlnyVyrayga
X-Received: by 2002:a0c:9810:: with SMTP id c16mr34655739qvd.192.1556254416282;
        Thu, 25 Apr 2019 21:53:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254416; cv=none;
        d=google.com; s=arc-20160816;
        b=gDGtnlYHpDKpD5bXwNoExRMIeAFriYYeRGQ+Dir8o4ZoIosqmsc+KaQdn2aYHOmsiq
         pmpXSirI3p+eo2RA2CXayVxWOWUlA8XyCUpyPan8uyUE39uYBB1KoBfsE5SX/twxe8U2
         1+fQ18djBeUfdO4LrSLzZnztd6Nfb1bHYoyATJKGEwbrOt4MzhcGQ+Pw+pn6h13C1Lnq
         e6tCbNk03gEE5yZMQkc5S3efmaq3ZqHhnOcbsokmNWcw7mR4FfkXrsBpZ++WMNZ+GAgc
         Lxeih8iR5oaM6J+nlS4b/82VQTwRInhLuo3F1RQl0PexiwXt1B95NINt2/0VF+Qly/hg
         9j3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=guN7gYgnmDjc0dZDM0nP8l0/tmhZ7IhmP3yHcVRz/U4=;
        b=guWQ//3T7U6QR6Sgv7FnCROiARPJNo2eq2Qc1QUzp+hHfTFicJYjcX8IXCVdHU3Zkl
         R2sHOe9cUdgXz3FzSiOWEY5i+uhSH50mkEADmDr84cEbOz6yDK3S0exENBybtIEPCXNN
         SnvDvr1LIF3+0357qXcSGJ2oEq1lXhDkTABlN9fvyVkbd7/ut6C25nuSdk+Z4il+2AB4
         M4pxbDFS23gZiHMW+0F5iQedXYdwjk10p7u4JFsJMMXE6IDYsujRqjNLhuhMJpR8/Jg3
         ZNZ0CKWKMpBshE+sk0wdIufzb3rm0zGxYrj8JlWRQLz3HMt7KYklADnGpYWZ43Wz74yv
         6GdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o10si4291973qkj.36.2019.04.25.21.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:53:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6156512F8FE;
	Fri, 26 Apr 2019 04:53:35 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id ACD4918500;
	Fri, 26 Apr 2019 04:53:24 +0000 (UTC)
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
Subject: [PATCH v4 10/27] userfaultfd: wp: add UFFDIO_COPY_MODE_WP
Date: Fri, 26 Apr 2019 12:51:34 +0800
Message-Id: <20190426045151.19556-11-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 26 Apr 2019 04:53:35 +0000 (UTC)
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

