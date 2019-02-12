Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC45DC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85FFE21773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85FFE21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CAC88E0125; Mon, 11 Feb 2019 22:00:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2781C8E000E; Mon, 11 Feb 2019 22:00:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11ACE8E0125; Mon, 11 Feb 2019 22:00:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D62368E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:00:42 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w124so14420128qkc.14
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:00:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ri/plaGGPGNBrPDmiuoX3iMv+Of0DqCouwOYW+z6hkk=;
        b=Gk4QP1vFCzaP1SS43yVVnv1tuygL1/r3JTpoy/RSPFSIaUNq4s89/vCdHHdq1BIwQB
         v7FhQfioofb072m26sSgAl4/RY4pVXV752fEbSmfy6iaMPimVAHZfF59AynhnHbsmwh8
         IOhKOCSZtCyI0simEqwhxsBvvaE0reK1OmgMAVTYj9UEsjhcDoUE1ywwfAkmTG8kYeF9
         xAgz20EHhxmVw9UxER8qYnyiXf57CQKmwBYOYFU9+No3o/VbI0Xl3JX/6RBdYDHy08FF
         MFC+HHFgHU5D3rgsZ+zrqaZ6Io8hvZLD4ZjHVTDs+9F/Ls+2GdS7a9ojTfZaVq2uySB+
         RVbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaiFbqbZlZs21vP9BInedCHZx4MvQ8ymLScy2io6qjJYTTAkw1l
	c4x9a/Kw8RXzsQTQFHB3WGDAH399rr1mMjuPOrsyVVwo7ekwqJczvndDigcYscseRjrkgQyO1Ds
	EKkFhAGDuU/a/HkLicgHSTatF2S5L2sgHIq/1hmdlC64ehJWu9a8weTwbpHXdBFKx9Q==
X-Received: by 2002:ac8:4792:: with SMTP id k18mr1133934qtq.294.1549940442631;
        Mon, 11 Feb 2019 19:00:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbmM9zPgbyz+IgNi1VLfr3KT5E8UFSO9RqFAUTRMUJwyDkSt7SjgtxATe/qB3V+s8ZBEzfb
X-Received: by 2002:ac8:4792:: with SMTP id k18mr1133920qtq.294.1549940441924;
        Mon, 11 Feb 2019 19:00:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940442; cv=none;
        d=google.com; s=arc-20160816;
        b=tdbDv7cNKGA3seimRORpkc10byF1FPbvGKHwRmEwN+71wz0x8cjFFcAgv0pHks5j5w
         DLqgDXjFl/3uUEIFHfYDFZNVlgqkZOwRStLD/IhgDK2OUowRXD7hL6K65HaImpA0wg7S
         3ABBUiLQ9d+GbPiEywrJpWf4UrDuV4Dg+DOvK0b+TWA9IJR03JAykhdPPcq2tCO6ZUj4
         pxPG5i/5Pw2ven7MVKgY2g8x/KP+1NR0ZLjBNYI0yk3rXWIJX0pvV/02rqAN5MVolIRk
         JjOW0i0u6xY0Z0ySqEx2ZNxJbyX5Rzm7554pxW1R0F7VnRCx8wm+QJVR5QnNFrSWHo9J
         y/8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ri/plaGGPGNBrPDmiuoX3iMv+Of0DqCouwOYW+z6hkk=;
        b=g4Hh/W4VH0DBT1mYVrbkLLFTqyo/q37dMCDcdQclqbPMhaVn9AsImsRvikE8LUSXmc
         AMU5JKlpLticHgncmm1xK51sjPU59GnwpVsgefhJOHu9zRGu5xnovmb1kiEbGh+rXX5C
         eiPWiWwPrAa8r+cbPkRdBGHUD1dmX5H2DPtHrjF5obod4ul5P3THOXEyiQfYPToGrD/Y
         9ucdPUlphMprVg4lrlAX14WhUL5bDuDksFf/2Xs/sogEEbVOGPPd4j6b65kT2p0gsbi6
         pbMJCVawt3GCoU8M0aeKlGN9VG6Nzos2sCvq0m3O8gzFI2Lv/kgsG2/QldzGlyjuNW9o
         rv8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r20si17951qvl.44.2019.02.11.19.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:00:42 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E8EE6A4035;
	Tue, 12 Feb 2019 03:00:40 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B53C9600CC;
	Tue, 12 Feb 2019 03:00:31 +0000 (UTC)
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
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 21/26] userfaultfd: wp: add the writeprotect API to userfaultfd ioctl
Date: Tue, 12 Feb 2019 10:56:27 +0800
Message-Id: <20190212025632.28946-22-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 12 Feb 2019 03:00:41 +0000 (UTC)
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
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c                 | 82 +++++++++++++++++++++++++-------
 include/uapi/linux/userfaultfd.h | 11 +++++
 2 files changed, 77 insertions(+), 16 deletions(-)

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
index 297cb044c03f..1b977a7a4435 100644
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
@@ -232,4 +235,12 @@ struct uffdio_zeropage {
 	__s64 zeropage;
 };
 
+struct uffdio_writeprotect {
+	struct uffdio_range range;
+	/* !WP means undo writeprotect. DONTWAKE is valid only with !WP */
+#define UFFDIO_WRITEPROTECT_MODE_WP		((__u64)1<<0)
+#define UFFDIO_WRITEPROTECT_MODE_DONTWAKE	((__u64)1<<1)
+	__u64 mode;
+};
+
 #endif /* _LINUX_USERFAULTFD_H */
-- 
2.17.1

