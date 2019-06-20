Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 397DFC4646B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:24:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFE91214AF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:24:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFE91214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85D258E000A; Wed, 19 Jun 2019 22:24:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80DA98E0001; Wed, 19 Jun 2019 22:24:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 724A58E000A; Wed, 19 Jun 2019 22:24:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 518AD8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:24:21 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id o4so1747479qko.8
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:24:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W/X7WIccHO5S15YBTZPd+cRPsxXXqxtU7MmPZJUfJns=;
        b=FH2+7V1Va966XNLm3Nll1X4dzYudQJA8+txL/uQt2IBZ7/fV/jaUnuG3F19X8KJ2H/
         D2F7aqkc7HHtM/Z3M+aguXw1NX1cvssqEsEE+0VpQUT7+UOP3Rl7pWe/n8yQZ+dRnhW8
         1+3wm6LsNDWFVV/we+Z28MgFpkzXy/tnl5MOI+4g64J2nE7lWwKfaztfvjw7Tmxb8fF4
         JOG7+VXrqO1ttnnhUOKL4AuRtTBo4O3lMWHJG8NunJhRUy/g1sQcuElmi4B39x6Wd/7V
         E+02kUF/pbnt3ytHxFlNwKKEr4zCz73anWdi6p3M3COoj1MMsKeKJUDW/WMDlYGiywEe
         WPcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU61F+VMhnc1z0aa8ZpDd53Q2Ma48Qg5Q9i9c7f0UE6AoSeKn98
	xdOWB3uXEf3eZ2ysa6DIbo1k4PTdsgnJ4VyrEOLF474InS6iLQihuco2iIzIC1fCY0WNOiB1dCC
	jovqanaq7PzmnSFkCMB+eB8S3o3LpDJsM3gA/GIJPkcKtOSS/dUU41Dkp7UbkMCCz6w==
X-Received: by 2002:a37:9b01:: with SMTP id d1mr98599458qke.46.1560997461074;
        Wed, 19 Jun 2019 19:24:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZt/B2BXOoVOAxEI6FieaKVjFkb8NrCAXLtIfynpSzt/wtGg+kOAJE1kfHNT+PC4ycdKWC
X-Received: by 2002:a37:9b01:: with SMTP id d1mr98599416qke.46.1560997460214;
        Wed, 19 Jun 2019 19:24:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997460; cv=none;
        d=google.com; s=arc-20160816;
        b=q9Xfs77JzSp6x92fjlbXmt8fIO0pMnHZ0uZA9UMSxUxNPHgTmOOMvcXLRX0rMOuxl5
         o5Ib/IZX4cY08YRvivzt7nfJuWJTXHnKBs4nWJ2fVUAYCepWNgFSlFlDt1nxVZ6VyDDM
         iuVveOkonTT7rRPFcjRDD5jWzhTn+2vEqi86QwtxwAN3Sw3z65/r729k8S/+HPpwvGom
         aTeZ3CcmI1aoDAZeZ256EG89BB/YO8gYSfjNfXLcxfKlt1+tK3d+3qUA/6hNvG9BUcs3
         Shl2lhcac52+pdiUv8rC/YTNG5jGUzzPuLrJZfyhPyF0AgDBurFV9/X72yK2DbNG3yLn
         NSvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=W/X7WIccHO5S15YBTZPd+cRPsxXXqxtU7MmPZJUfJns=;
        b=GbCOgyp0wwyEKgm9JhLNAerXHMmh18yqiVktzxrK8AvVXriWnuEkfpUF7fFnqFf6Kb
         956pvLWIU/y5teR30lAZ4pD4HRIPgdQ6CVyurNTgiygP2+Pl6kiL/WS81iXe4HNKmwCr
         XylaeWbkKyytZdDEjGqVsYH1AzYOFO1OakdVEmL9Ts4ARMvu47x2JvumpqUgz7dDSmbA
         hkzoqYB53JMmbH5wVQ6MbpJHSvBuzcKYI/J+g6udzivYU4e7twdlRM6hJOnmGxf1ZCmJ
         RH1HSxwYSGBXjMketJEPArGv+C3ioZt2rD2onxIg+PacGktYp4O9qU9kSlNLc6SUhavi
         zGYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l4si3815488qtb.237.2019.06.19.19.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:24:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 55A133024552;
	Thu, 20 Jun 2019 02:24:19 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7A2781001E69;
	Thu, 20 Jun 2019 02:24:10 +0000 (UTC)
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
Subject: [PATCH v5 19/25] userfaultfd: wp: add the writeprotect API to userfaultfd ioctl
Date: Thu, 20 Jun 2019 10:20:02 +0800
Message-Id: <20190620022008.19172-20-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 20 Jun 2019 02:24:19 +0000 (UTC)
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
index c594945ad5bf..3cf19aeaa0e0 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -306,8 +306,11 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
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
@@ -320,6 +323,8 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 	 */
 	if (pte_none(*pte))
 		ret = true;
+	if (!pte_write(*pte) && (reason & VM_UFFD_WP))
+		ret = true;
 	pte_unmap(pte);
 
 out:
@@ -1258,10 +1263,13 @@ static __always_inline int validate_range(struct mm_struct *mm,
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
@@ -1293,15 +1301,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
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
@@ -1351,7 +1352,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 
 		/* check not compatible vmas */
 		ret = -EINVAL;
-		if (!vma_can_userfault(cur))
+		if (!vma_can_userfault(cur, vm_flags))
 			goto out_unlock;
 
 		/*
@@ -1379,6 +1380,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 			if (end & (vma_hpagesize - 1))
 				goto out_unlock;
 		}
+		if ((vm_flags & VM_UFFD_WP) && !(cur->vm_flags & VM_MAYWRITE))
+			goto out_unlock;
 
 		/*
 		 * Check that this vma isn't already owned by a
@@ -1408,7 +1411,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(!vma_can_userfault(vma));
+		BUG_ON(!vma_can_userfault(vma, vm_flags));
 		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
 		       vma->vm_userfaultfd_ctx.ctx != ctx);
 		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
@@ -1545,7 +1548,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * provides for more strict behavior to notice
 		 * unregistration errors.
 		 */
-		if (!vma_can_userfault(cur))
+		if (!vma_can_userfault(cur, cur->vm_flags))
 			goto out_unlock;
 
 		found = true;
@@ -1559,7 +1562,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(!vma_can_userfault(vma));
+		BUG_ON(!vma_can_userfault(vma, vma->vm_flags));
 
 		/*
 		 * Nothing to do: this vma is already registered into this
@@ -1772,6 +1775,50 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
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
@@ -1849,6 +1896,9 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
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
2.21.0

