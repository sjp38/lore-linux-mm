Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4CB5C48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:22:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C2472084B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:22:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C2472084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F5EE6B000C; Wed, 19 Jun 2019 22:22:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A5318E0002; Wed, 19 Jun 2019 22:22:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BB9A8E0001; Wed, 19 Jun 2019 22:22:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCE9E6B000C
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:22:28 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o16so1690194qtj.6
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:22:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o7nPoQszb1KyhdX6zpXj78a4J8XdFeDwU7Jyt6eo1Ag=;
        b=sYomeDf76ojBhqy/nvILStznGAoAsOHRzCsQAOS1BiCz6h19ZNjJoqZT4m3p98U0z/
         ownM36ztr3/woqvWtw6O1ygzKo15/bsU7x1mKc90mbM8wTV6s+++8j5bJ4t2WKuGOfOG
         BX0JTOlM1YqO4CjCQt8+isPT0tZTGZeCvltj3r4zGia6ojmkGI8MqgzqL6xaTFh6hIbE
         AqAjt+JyjQOhDOR7xQmh1b4A8DSoJMd4ZKYdKcpU0Z4+94wg1wOXctfu0T0mNyBVhpdj
         RKVFg5HVsRrUAdMsPhnebPw2med8FutguKAgrVTB49GXikzBiPNc07AQye0rGBxg0iPa
         9/lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV5ga9DFMGtleK01vRpjO0MZ8WNpmDIG3hqA6GLkYhGq72w8nbH
	B6QIMj5YwpBsHjPmIudUbX9rN48cNnuDkdPq24rGob4nzxy/1IMMFBMzqf9zBBUBLhDuVPsXqbS
	EiT12c65s+gAYniutM8kjyWU275cymAsprgYjFrNXp4d7sYHw2e8p8RFtTt6Q0Fhbmg==
X-Received: by 2002:ac8:34f4:: with SMTP id x49mr99113718qtb.95.1560997348667;
        Wed, 19 Jun 2019 19:22:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzt8SN2FjjNh4xjpM0alMTa0T6sHM2vP23JCJHU3GkALNq1U6l7nBsNq4/QJlcsqrEA9P3e
X-Received: by 2002:ac8:34f4:: with SMTP id x49mr99113684qtb.95.1560997347927;
        Wed, 19 Jun 2019 19:22:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997347; cv=none;
        d=google.com; s=arc-20160816;
        b=CTYqgvNLyLYdy0BNXyJCkalbe3V3ZDy8En+oOJ2Dwsef1V0zSm4ZNdME4OtE0usZnQ
         sMFshj53zO4sNz0LHnB0DWe2T3MeiqWO6q+elwKGQqlFDbNamgYUp05T6vKDeBofiSQi
         CKVqNFNr6G3qkNQNRNTc7eBRm3OoLVW8nuEg99uS+arATEh03oN9KcWPXeQpNmbGJcsc
         ElxdA5LfplI12ZLacZR3l4FI0YfEXCiRiJxjw3kYqxjoek07ML4BJLI+fLu58c9phgP0
         qVZyWVjCoK6rpC7P6/5rvvhazreH5TQ9tFQd5QhYrNzcAZZTq+iaULT3Ssleq7azp9HN
         qsKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=o7nPoQszb1KyhdX6zpXj78a4J8XdFeDwU7Jyt6eo1Ag=;
        b=o7Otc5wybSCuIn511YP/mXOLgxuM86JFcYIfFCKkI3wZvuo7ovpHRfJ6DmuBo+OAxq
         /+VKMLPJOAe7KsH+y4egEX1xtV0nnsUkBveSMV8WYaojk8EFTP47JdWBQy5HCv9fxM3B
         cNNWX0euOa2ocYSZBTvj74xojA6qW2ZamaTT4VAWa+OwEceK31sHz88LWEstneeNpuWL
         GwQnYaWBPrw0iS1ZYdbg6aeAK5yEeJX+Y/HQX+yTXCfk8olMrCFTc8RKf8N9eFnv1eaP
         d3OmcSH87egSBsuADAXp7JTOWUAKoyu6D6GZjcy7dWgTUehnkDE91imBUZze5VYy0Z5f
         BZew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q19si3507249qtn.43.2019.06.19.19.22.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:22:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E5C63307D866;
	Thu, 20 Jun 2019 02:22:26 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 57FA11001DC3;
	Thu, 20 Jun 2019 02:22:14 +0000 (UTC)
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
Subject: [PATCH v5 10/25] userfaultfd: wp: add UFFDIO_COPY_MODE_WP
Date: Thu, 20 Jun 2019 10:19:53 +0800
Message-Id: <20190620022008.19172-11-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 20 Jun 2019 02:22:27 +0000 (UTC)
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
index 5dbef45ecbf5..c594945ad5bf 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1694,11 +1694,12 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
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
index 7b91b76aac58..dcd33172b728 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -36,7 +36,7 @@ extern vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason);
 
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
index 9932d5755e4c..c8e7846e9b7e 100644
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
@@ -398,7 +399,8 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
 						unsigned long dst_addr,
 						unsigned long src_addr,
 						struct page **page,
-						bool zeropage)
+						bool zeropage,
+						bool wp_copy)
 {
 	ssize_t err;
 
@@ -415,11 +417,13 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
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
@@ -437,7 +441,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 					      unsigned long src_start,
 					      unsigned long len,
 					      bool zeropage,
-					      bool *mmap_changing)
+					      bool *mmap_changing,
+					      __u64 mode)
 {
 	struct vm_area_struct *dst_vma;
 	ssize_t err;
@@ -445,6 +450,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	unsigned long src_addr, dst_addr;
 	long copied;
 	struct page *page;
+	bool wp_copy;
 
 	/*
 	 * Sanitize the command parameters:
@@ -501,6 +507,14 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
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
@@ -556,7 +570,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 		BUG_ON(pmd_trans_huge(*dst_pmd));
 
 		err = mfill_atomic_pte(dst_mm, dst_pmd, dst_vma, dst_addr,
-				       src_addr, &page, zeropage);
+				       src_addr, &page, zeropage, wp_copy);
 		cond_resched();
 
 		if (unlikely(err == -ENOENT)) {
@@ -603,14 +617,14 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 
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
2.21.0

