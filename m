Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10A2DC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1081217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1081217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FE026B0278; Tue, 19 Mar 2019 22:09:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 685656B027A; Tue, 19 Mar 2019 22:09:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 527C76B027B; Tue, 19 Mar 2019 22:09:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B94F6B0278
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:09:38 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 23so19467896qkl.16
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:09:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JJc0h+L8EKEiFRWPZySSJxSRlflCCV4CfqhuFZTjUzs=;
        b=RRWUCNqE24cdRyGBnrEyremQHjvWhBtWQRQUtn90I9nodlg7+eb2rMrojBj1SkjK7L
         7RwrQbKiBVWEov9bUUCCNj+JM0XCNok+SZ1t9vE6wDI5O7wrWhfMsVC7uWx9m7GX95ra
         tBX4doD9e6gsIvFArH5DpbImB7LWjZfeGl87jttcca6SXlyZmqBIYvYzM6DDzM02+NhQ
         t9oc0z1OWzMhxUZeRHs0bi66tCIhK23ZCW9Ld0SX4KvlGIUDcJAMQSnJNuXiIpcbz9qb
         ehfcbhOk9t4YJ0MKZotI/wHegWiaiYiEYS10FY/FNriAPVYKXR2ArLvg+rWY4ZXtId8S
         3U7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVcJV304/302X1xr6trYxABlDYrsKBMJyBQhPD7t0/TzH6/yN8v
	7vKjIPjnuGxTVBfxnmnCwVaAjXk9MPlj0YuFv2ZjRRha7Ae7RTnyDyhbh+DUN82AE8U8vHMSwZ9
	1rUblIjd+1CNOTByrd7/UPjTRbQHrHdKzS4JKbzut6+tdo9SO1GF8c6Y3PCytE/ygvQ==
X-Received: by 2002:ac8:2f10:: with SMTP id j16mr4838881qta.29.1553047777972;
        Tue, 19 Mar 2019 19:09:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIHiqAqiZUXRl47O8F7B0f93bvnP72t1+xURHU2Ld6u0N6DqAQ31MQ5ws0XuYs89sfsDJL
X-Received: by 2002:ac8:2f10:: with SMTP id j16mr4838859qta.29.1553047777339;
        Tue, 19 Mar 2019 19:09:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047777; cv=none;
        d=google.com; s=arc-20160816;
        b=y/6zL4jgc7ZFQWA76x4k02XGHjn/gn9Sf6OnggwxjirO1FkaGXU8rCh0aBzd5ZSdYe
         IUf+P74OLVnYi8PAlIhbRqy4/9HUG2UybJOSFxg4+lczObJrwn7rQy8qz40H8u11ibD0
         VKJYOvf5xTYZm9ezkYxqidltGHBXsN8sk+27vR3JdxARTyGYjeCOQAG/1hLC/gTCy6f6
         LKoqp8rBfQsX30nVOSQVYFUvjtJ8G786uU67TcQaWLWCMAgC7yze+LgwEaRji/yApO07
         VguiAMzMtT5N4SE1l53257S1lLoGJsjpP/sbDVlGduJBnD569M4fBg/NUNa1oankjF/8
         nGMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JJc0h+L8EKEiFRWPZySSJxSRlflCCV4CfqhuFZTjUzs=;
        b=cseqgklDh5kROeC7ZMSEtiLTEVoydZk5OKsbhyfjbgbBCp66861C8PC8kNYb3D8bVp
         LVhZsRs32kJNYUoPrtEAnuSnro+X9NU34f3PBbvRcDn24viXsbpXqPmf4GadFcTyvlBj
         Y72Xj8016LEZ8059TXwo3F2Mez1PGMQTzw+PwXh1E901cH2S2sDi0Tg29nUNkr6hbmku
         bebBiS5XuoAwZTau3tzeWkmgo4dEaAenF6WFiFry7P0Vj2g2yndoQ+3mddYz3Sb7YptQ
         aF6tx7qA3lrOCS9IrvgsFcFMBDNYx0T//w7SiNpPCEeMzNEWHKNjINoxxA5mH2jA4ntv
         WWMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e25si455289qtm.381.2019.03.19.19.09.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:09:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6CDDC308FC22;
	Wed, 20 Mar 2019 02:09:36 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3A2446014C;
	Wed, 20 Mar 2019 02:09:27 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v3 20/28] userfaultfd: wp: support write protection for userfault vma range
Date: Wed, 20 Mar 2019 10:06:34 +0800
Message-Id: <20190320020642.4000-21-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 20 Mar 2019 02:09:36 +0000 (UTC)
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

