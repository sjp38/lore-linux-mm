Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F4A2C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AFAD206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AFAD206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C72C36B0281; Fri, 26 Apr 2019 00:55:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C26D56B0282; Fri, 26 Apr 2019 00:55:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC68E6B0283; Fri, 26 Apr 2019 00:55:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEE86B0281
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:55:01 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k8so1815662qkj.20
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:55:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JJc0h+L8EKEiFRWPZySSJxSRlflCCV4CfqhuFZTjUzs=;
        b=sJeYl6AyCyyjoGtQuhDpqXa8qveNGES7EHt8a41T1r4usm5LwintbAvTPEFty4QvE6
         fzDYZuaJrI35T/KkLvlBvN6jU2BBgmI7pg/bPl1UnJuqQjn96KFy5IPnfq/AVDArf+t+
         YL2jRd2ho88efJQEaThg75AN7IVki1tq949cruxR1I9Bbd4XNw2QhqAdCv2bf01SoBRT
         m0EqAI7Vl74Npydf6G0apxOKDKijp0QQObevTShGB2jP3gPjRUWKHwb+yzLV2LV6cJXl
         80hChLh+WOHiMmglB596QMNr7LnTdSRWWnnUd4EWcw+yH5ar41leesvnQz+LibC/cWhO
         os/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV8ANVvzDunT+GzYMHOYU7DV8EjencEfViHPH3rOXd11i501pNQ
	kJrcAtKHmZTMToLpXq/qa5pbG7z8s3UfF5PRLDdGsTqUShux9Kycs4AQCcEUEqp935J9FYIkgzC
	j/D0RCcN8NouDIgE9XaRXr4ButZmMMGO+kM5k/bqKokKm8pKXBs1ESz8jifyiNsJVVw==
X-Received: by 2002:a37:58c4:: with SMTP id m187mr11496033qkb.138.1556254501311;
        Thu, 25 Apr 2019 21:55:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtjPgr3iYx++IWGgge83BqyKj+Hv6yAZTKjIKuJN1iUAi+VOzPAfdlplL5M2Eqm+ByMOCu
X-Received: by 2002:a37:58c4:: with SMTP id m187mr11496009qkb.138.1556254500642;
        Thu, 25 Apr 2019 21:55:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254500; cv=none;
        d=google.com; s=arc-20160816;
        b=IF7ee8+e0AvlsUpAjIpqY2sOGIKkUcI0LDSXpXpRAjGaNWLQgPbufnMW1hMElporwc
         pG8AzmcMMplM625l5DgywpCg+blHcY1XrTEuoFYW/lKdN/B/I1taAZ2QRrPC57aa+rv+
         BDpKlf98bKxOdvblySArbBQ+2LDAqL+3u+SDBUToDgjLtKO5u4MxqoMQXydJza1c/YMq
         3tjP1EKY7YwomavDfssL1rehD6jltCGQ1P5GN8a4j9AJgWcYa1LsLCVUNF6vX0ztiQz+
         MCKWKOJuzHwfjCC3IgSpDTZgvRoVB+LR6teRbCkW2qjFI2q530rgXTdBHoST039z1GLZ
         A0/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JJc0h+L8EKEiFRWPZySSJxSRlflCCV4CfqhuFZTjUzs=;
        b=vdxTH17MbqlX4eTft2LwtVJjSr8aJ9uI4kfPhbN9XKKmkUyay91kG3oXwXmLQZOu2w
         1aFkEj0uxGDR8OPf33UBq/4gpByhmFeFrVvXjmYApt7xKJyHfcA3drWWh3OKiF+7jxWB
         bylpCgBSaOQAAbeFyJ7lk8hFbCcmJr+9TCgi0W64t4MXY9BaomochbnZC/e9tf3ZhCxe
         sKJfcKaefn/wmQdUGRY77FYh5ePvFpP+XXCzEK+gtYrBxQvvtEy44VP94ycBta9381aU
         YrDxoRsB/bB6ByjRZ9DdlbrCewmeAWpq0umhXjrd5Iltqza0zS/qLK1IpPjfP6Crk6Kv
         tC5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v195si857480qka.194.2019.04.25.21.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:55:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BCB8E59455;
	Fri, 26 Apr 2019 04:54:59 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 54DA718504;
	Fri, 26 Apr 2019 04:54:51 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v4 20/27] userfaultfd: wp: support write protection for userfault vma range
Date: Fri, 26 Apr 2019 12:51:44 +0800
Message-Id: <20190426045151.19556-21-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 26 Apr 2019 04:54:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Shaohua Li <shli@fb.com>

Add API to enable/disable writeprotect a vma range. Unlike mprotect,
this doesn't split/merge vmas.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
[peterx:
 - use the helper to find VMA;
 - return -ENOENT if not found to match mcopy case;
 - use the new MM_CP_UFFD_WP* flags for change_protection
 - check against mmap_changing for failures]
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/userfaultfd_k.h |  3 ++
 mm/userfaultfd.c              | 54 +++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+)

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 765ce884cec0..8f6e6ed544fb 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -39,6 +39,9 @@ extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
 			      unsigned long dst_start,
 			      unsigned long len,
 			      bool *mmap_changing);
+extern int mwriteprotect_range(struct mm_struct *dst_mm,
+			       unsigned long start, unsigned long len,
+			       bool enable_wp, bool *mmap_changing);
 
 /* mm helpers */
 static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 2606409572b2..70cea2ff3960 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -639,3 +639,57 @@ ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
 {
 	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing, 0);
 }
+
+int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
+			unsigned long len, bool enable_wp, bool *mmap_changing)
+{
+	struct vm_area_struct *dst_vma;
+	pgprot_t newprot;
+	int err;
+
+	/*
+	 * Sanitize the command parameters:
+	 */
+	BUG_ON(start & ~PAGE_MASK);
+	BUG_ON(len & ~PAGE_MASK);
+
+	/* Does the address range wrap, or is the span zero-sized? */
+	BUG_ON(start + len <= start);
+
+	down_read(&dst_mm->mmap_sem);
+
+	/*
+	 * If memory mappings are changing because of non-cooperative
+	 * operation (e.g. mremap) running in parallel, bail out and
+	 * request the user to retry later
+	 */
+	err = -EAGAIN;
+	if (mmap_changing && READ_ONCE(*mmap_changing))
+		goto out_unlock;
+
+	err = -ENOENT;
+	dst_vma = vma_find_uffd(dst_mm, start, len);
+	/*
+	 * Make sure the vma is not shared, that the dst range is
+	 * both valid and fully within a single existing vma.
+	 */
+	if (!dst_vma || (dst_vma->vm_flags & VM_SHARED))
+		goto out_unlock;
+	if (!userfaultfd_wp(dst_vma))
+		goto out_unlock;
+	if (!vma_is_anonymous(dst_vma))
+		goto out_unlock;
+
+	if (enable_wp)
+		newprot = vm_get_page_prot(dst_vma->vm_flags & ~(VM_WRITE));
+	else
+		newprot = vm_get_page_prot(dst_vma->vm_flags);
+
+	change_protection(dst_vma, start, start + len, newprot,
+			  enable_wp ? MM_CP_UFFD_WP : MM_CP_UFFD_WP_RESOLVE);
+
+	err = 0;
+out_unlock:
+	up_read(&dst_mm->mmap_sem);
+	return err;
+}
-- 
2.17.1

