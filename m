Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D637C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15B0D2089E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15B0D2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A789A6B0283; Fri, 26 Apr 2019 00:55:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A27E86B0284; Fri, 26 Apr 2019 00:55:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93EB26B0285; Fri, 26 Apr 2019 00:55:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 727FD6B0283
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:55:17 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z34so1871166qtz.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:55:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=DauPO+I/hJ8SBuajGGHsJsj3lcEKHinvfF4ZjWhK/Gw=;
        b=Xk0hoQKVrpyMUGGAk9hSx5iyTFmVWIyv9j956UpcMrkUF0ACtNX3sV79HVKv//M7Lg
         ceBytUTDsGqrVZg84OkQcNwadW+uCnsrHQ7Vx8RAxBCJFFKAeIdeRFT15uCw3dhb8zD2
         QzSJLoVWMy/xGN2OJaNbyoah7tPSwMES+4L9ELCggzIb++Z4y+tCmmSIjn7tGZGQewpk
         wTKtMUmSjJgCDJxVpj97qjOlFz/ThFXL2Uh9Jrc3wGRwFrBRC6v9NSrZYyfoDv9861Gw
         95y6DMkq6RdyloYxTqWoMT9hGfHkV0C1fdNJzIYs1qx9qHFf6Bs83IEeGAUiH2+m9th2
         fuYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVmVUKEPSR0FDsZqQL6AM+06ErzTy9Ii1IJ8SZgov/yZt+MFmyI
	4wjNGJt5b528FlcxIMIdlCDX3JCxP6AOsCbtZcIu35X2HDWkQbYccpM3oRMAPVjOBuVUTPKUSBJ
	TVBKMs3ii4wXNiPcNtW3NlwdmdZemBENc3sqAw3Q5NLgAjDee74zJRNxUNPqrluaIXQ==
X-Received: by 2002:ae9:c313:: with SMTP id n19mr15847270qkg.87.1556254517207;
        Thu, 25 Apr 2019 21:55:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWBXfuWrjfrsPPmnf9YbmPQNMIWgdZXMbMXMz2ZRe0va3SD6sqQaLbL1j5+iLPvvFVmfUT
X-Received: by 2002:ae9:c313:: with SMTP id n19mr15847218qkg.87.1556254515736;
        Thu, 25 Apr 2019 21:55:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254515; cv=none;
        d=google.com; s=arc-20160816;
        b=VYemPpI56DM87lpIfxZR1xoLFELMXfKqjLPWktOrIaaopWoIJL3ciZKBfb0mgVKcNG
         e5v1s1+TiA4mFcTHzw2R9vGwG84+4khMX4bo3uRWDzAJeLrFrR+aVx3HEAtZBOTrFbLI
         eRO37zrJzo2dDU7k7diMXP6ZA0s1sHb64TD2a2zr8eoDYibV1hPJB1JT1qIrQyemjR3I
         QKBCaWTGdlzf7ih7Y5PGho4+lu9QjciWJfPBzc2fe1VNZLG19jVKcZ+UAg44PDXgAaol
         g593yAh3UTrmOBspVTeJtctVYvWL/wQGlwGEGwuGqACuNzwBdOvKzwXcGEvwIJzDamSO
         MyNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=DauPO+I/hJ8SBuajGGHsJsj3lcEKHinvfF4ZjWhK/Gw=;
        b=Qp2U/Hle7veEPD0QQXz/zwW+z6KkNc0DCjIkG1CcKesQDHLjO29SxQpOUDT+bOaSC4
         81yXzIGWTwJCNdpT5nJfhTfq3j0adqqs9K1CUYfFarKovQmZIXNSGgkQtz8oaJgsluUP
         IIz/1pbvuIxUGHBPzdliYTD98LNDtdDlFFU/QIZ3wFQRksBsf0z2tGZOHImHLPF6BYsQ
         Yu3S6vwFYh7GkmsYYNDr45SPObkX5OkcTADVymAI8uTb6LX9Jna9M13o3CP22/9BLN5i
         StUrvU7vrC92NxCj00+6Qf/0M7x9Ez3XSLj3id40rqfHpQdcb/czsrGW+rsMhel0ma2F
         SKSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t58si4474344qtc.36.2019.04.25.21.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:55:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CD2F1285BE;
	Fri, 26 Apr 2019 04:55:14 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3FDB917B21;
	Fri, 26 Apr 2019 04:54:59 +0000 (UTC)
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
Subject: [PATCH v4 21/27] userfaultfd: wp: add the writeprotect API to userfaultfd ioctl
Date: Fri, 26 Apr 2019 12:51:45 +0800
Message-Id: <20190426045151.19556-22-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Fri, 26 Apr 2019 04:55:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

v1: From: Shaohua Li <shli@fb.com>

v2: cleanups, remove a branch.

[peterx writes up the commit message, as below...]

This patch introduces the new uffd-wp APIs for userspace.

Firstly, we'll allow to do UFFDIO_REGISTER with write protection
tracking using the new UFFDIO_REGISTER_MODE_WP flag.  Note that this
flag can co-exist with the existing UFFDIO_REGISTER_MODE_MISSING, in
which case the userspace program can not only resolve missing page
faults, and at the same time tracking page data changes along the way.

Secondly, we introduced the new UFFDIO_WRITEPROTECT API to do page
level write protection tracking.  Note that we will need to register
the memory region with UFFDIO_REGISTER_MODE_WP before that.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
[peterx: remove useless block, write commit message, check against
 VM_MAYWRITE rather than VM_WRITE when register]
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c                 | 82 +++++++++++++++++++++++++-------
 include/uapi/linux/userfaultfd.h | 23 +++++++++
 2 files changed, 89 insertions(+), 16 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 3092885c9d2c..81962d62520c 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -304,8 +304,11 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 	if (!pmd_present(_pmd))
 		goto out;
 
-	if (pmd_trans_huge(_pmd))
+	if (pmd_trans_huge(_pmd)) {
+		if (!pmd_write(_pmd) && (reason & VM_UFFD_WP))
+			ret = true;
 		goto out;
+	}
 
 	/*
 	 * the pmd is stable (as in !pmd_trans_unstable) so we can re-read it
@@ -318,6 +321,8 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 	 */
 	if (pte_none(*pte))
 		ret = true;
+	if (!pte_write(*pte) && (reason & VM_UFFD_WP))
+		ret = true;
 	pte_unmap(pte);
 
 out:
@@ -1251,10 +1256,13 @@ static __always_inline int validate_range(struct mm_struct *mm,
 	return 0;
 }
 
-static inline bool vma_can_userfault(struct vm_area_struct *vma)
+static inline bool vma_can_userfault(struct vm_area_struct *vma,
+				     unsigned long vm_flags)
 {
-	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma) ||
-		vma_is_shmem(vma);
+	/* FIXME: add WP support to hugetlbfs and shmem */
+	return vma_is_anonymous(vma) ||
+		((is_vm_hugetlb_page(vma) || vma_is_shmem(vma)) &&
+		 !(vm_flags & VM_UFFD_WP));
 }
 
 static int userfaultfd_register(struct userfaultfd_ctx *ctx,
@@ -1286,15 +1294,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	vm_flags = 0;
 	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_MISSING)
 		vm_flags |= VM_UFFD_MISSING;
-	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP) {
+	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP)
 		vm_flags |= VM_UFFD_WP;
-		/*
-		 * FIXME: remove the below error constraint by
-		 * implementing the wprotect tracking mode.
-		 */
-		ret = -EINVAL;
-		goto out;
-	}
 
 	ret = validate_range(mm, uffdio_register.range.start,
 			     uffdio_register.range.len);
@@ -1342,7 +1343,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 
 		/* check not compatible vmas */
 		ret = -EINVAL;
-		if (!vma_can_userfault(cur))
+		if (!vma_can_userfault(cur, vm_flags))
 			goto out_unlock;
 
 		/*
@@ -1370,6 +1371,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 			if (end & (vma_hpagesize - 1))
 				goto out_unlock;
 		}
+		if ((vm_flags & VM_UFFD_WP) && !(cur->vm_flags & VM_MAYWRITE))
+			goto out_unlock;
 
 		/*
 		 * Check that this vma isn't already owned by a
@@ -1399,7 +1402,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(!vma_can_userfault(vma));
+		BUG_ON(!vma_can_userfault(vma, vm_flags));
 		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
 		       vma->vm_userfaultfd_ctx.ctx != ctx);
 		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
@@ -1534,7 +1537,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * provides for more strict behavior to notice
 		 * unregistration errors.
 		 */
-		if (!vma_can_userfault(cur))
+		if (!vma_can_userfault(cur, cur->vm_flags))
 			goto out_unlock;
 
 		found = true;
@@ -1548,7 +1551,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(!vma_can_userfault(vma));
+		BUG_ON(!vma_can_userfault(vma, vma->vm_flags));
 
 		/*
 		 * Nothing to do: this vma is already registered into this
@@ -1761,6 +1764,50 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 	return ret;
 }
 
+static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
+				    unsigned long arg)
+{
+	int ret;
+	struct uffdio_writeprotect uffdio_wp;
+	struct uffdio_writeprotect __user *user_uffdio_wp;
+	struct userfaultfd_wake_range range;
+
+	if (READ_ONCE(ctx->mmap_changing))
+		return -EAGAIN;
+
+	user_uffdio_wp = (struct uffdio_writeprotect __user *) arg;
+
+	if (copy_from_user(&uffdio_wp, user_uffdio_wp,
+			   sizeof(struct uffdio_writeprotect)))
+		return -EFAULT;
+
+	ret = validate_range(ctx->mm, uffdio_wp.range.start,
+			     uffdio_wp.range.len);
+	if (ret)
+		return ret;
+
+	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
+			       UFFDIO_WRITEPROTECT_MODE_WP))
+		return -EINVAL;
+	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
+	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
+		return -EINVAL;
+
+	ret = mwriteprotect_range(ctx->mm, uffdio_wp.range.start,
+				  uffdio_wp.range.len, uffdio_wp.mode &
+				  UFFDIO_WRITEPROTECT_MODE_WP,
+				  &ctx->mmap_changing);
+	if (ret)
+		return ret;
+
+	if (!(uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE)) {
+		range.start = uffdio_wp.range.start;
+		range.len = uffdio_wp.range.len;
+		wake_userfault(ctx, &range);
+	}
+	return ret;
+}
+
 static inline unsigned int uffd_ctx_features(__u64 user_features)
 {
 	/*
@@ -1838,6 +1885,9 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
 	case UFFDIO_ZEROPAGE:
 		ret = userfaultfd_zeropage(ctx, arg);
 		break;
+	case UFFDIO_WRITEPROTECT:
+		ret = userfaultfd_writeprotect(ctx, arg);
+		break;
 	}
 	return ret;
 }
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 340f23bc251d..95c4a160e5f8 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -52,6 +52,7 @@
 #define _UFFDIO_WAKE			(0x02)
 #define _UFFDIO_COPY			(0x03)
 #define _UFFDIO_ZEROPAGE		(0x04)
+#define _UFFDIO_WRITEPROTECT		(0x06)
 #define _UFFDIO_API			(0x3F)
 
 /* userfaultfd ioctl ids */
@@ -68,6 +69,8 @@
 				      struct uffdio_copy)
 #define UFFDIO_ZEROPAGE		_IOWR(UFFDIO, _UFFDIO_ZEROPAGE,	\
 				      struct uffdio_zeropage)
+#define UFFDIO_WRITEPROTECT	_IOWR(UFFDIO, _UFFDIO_WRITEPROTECT, \
+				      struct uffdio_writeprotect)
 
 /* read() structure */
 struct uffd_msg {
@@ -232,4 +235,24 @@ struct uffdio_zeropage {
 	__s64 zeropage;
 };
 
+struct uffdio_writeprotect {
+	struct uffdio_range range;
+/*
+ * UFFDIO_WRITEPROTECT_MODE_WP: set the flag to write protect a range,
+ * unset the flag to undo protection of a range which was previously
+ * write protected.
+ *
+ * UFFDIO_WRITEPROTECT_MODE_DONTWAKE: set the flag to avoid waking up
+ * any wait thread after the operation succeeds.
+ *
+ * NOTE: Write protecting a region (WP=1) is unrelated to page faults,
+ * therefore DONTWAKE flag is meaningless with WP=1.  Removing write
+ * protection (WP=0) in response to a page fault wakes the faulting
+ * task unless DONTWAKE is set.
+ */
+#define UFFDIO_WRITEPROTECT_MODE_WP		((__u64)1<<0)
+#define UFFDIO_WRITEPROTECT_MODE_DONTWAKE	((__u64)1<<1)
+	__u64 mode;
+};
+
 #endif /* _LINUX_USERFAULTFD_H */
-- 
2.17.1

