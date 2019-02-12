Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEB16C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99C0821773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99C0821773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 401738E000F; Mon, 11 Feb 2019 22:00:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38A858E000E; Mon, 11 Feb 2019 22:00:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22BED8E000F; Mon, 11 Feb 2019 22:00:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E7D148E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:00:32 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n95so1246477qte.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:00:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=9d6f/k3uUCUckQQ3eaDd6rBnviayTR6LMrwP55wkWfc=;
        b=tSNZ1pG5XRIoj2lVS3gsWetpLfoRm4CqwZtp7oRojIm7jTO3+TjYQzdshN8HtU9lMy
         9pbTn1a1wZStfTOLxRwZKwyrK8GZS4KI4yga/ldtxPyXg766AD9Ey670+Jbq0/JVzGwu
         Vr2mcsQrQtdJsfohwv71o01/zGdDz3+L8z28/xVfSRjwWBxAa/pYGixm1vBzmvp2j9Q5
         pgmB+/U0UDcIYNvY0yIR5SYHr4UkSoQlOxqfJq0ZIpiv7QoWX63IlVuGHviwxNfUX7be
         BMb6s8ktjSgwmKhq4/ViNZZQvN+OFl+yPEWukabI1eWDj0ALpWOe289TICvX1LOVdDJv
         Miyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYbQuhW6PzhS1NGKO352vYkpT0HRwmaMFKKrb7Odvu/VItnXxGZ
	NanU7phJHVFm2JWYm8aqtO+cUjg+wRiz7G0NIlYrfinwTXONDPtxJjkr2MeOwB1GTVIeTxZjihE
	a9++NnkjR9jpz7iHSQUdSm08nI3jR64NaErtC8JRLO8aSPRHQz1f3gCo7zMEAnTkgbQ==
X-Received: by 2002:ac8:7016:: with SMTP id x22mr1058835qtm.325.1549940432729;
        Mon, 11 Feb 2019 19:00:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZfwSXHWSioJISWlKgdMDLGh2nNFjOdfVeGhYn/FjVETw+/b7KjlKkZeqqj5v1+D6++Y9mE
X-Received: by 2002:ac8:7016:: with SMTP id x22mr1058808qtm.325.1549940432294;
        Mon, 11 Feb 2019 19:00:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940432; cv=none;
        d=google.com; s=arc-20160816;
        b=wXQfGvPxrgS7Ovx8lU4Yyebk48k8AjZpBuPBf2mfgOZVj94a4rEIAdhB5u4Cujia45
         5FtfDCUEn/tTg7uGqhLnzQyLRrsWmOcTxFcgRRTPh5LIgxLO5+Sa6aJzYeS88p0tTNii
         Uo8gGxtZlyy/4hc4Olh+4ThYhtKiYQwIK5gnf87NJfjvs6dovoY4BMAiaxcgYKuniQHG
         FZRU+zd12vVo/LD0IBx1H4D7fYWVXFRMvs83VXyxu03nSBzvQ+a2dSuud9RtOJrciSz5
         uYzf3qzcrGuVIcMnHdDgz5obtuj3TpAWSbEo0xHaJ/L9uYqhY9k1vcnJ+SitxGjdkhCn
         yNzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=9d6f/k3uUCUckQQ3eaDd6rBnviayTR6LMrwP55wkWfc=;
        b=K3jNXGSw6dcLbnEJo6/auSEfAchM0QIfTAJf0oy9FD9O49y0lxbv8CyawY4dNrIX/K
         gX+yEm/jFhjXtfD5L7QmLf2193NhZhSivcaP66CiOHTL6f3f70l34an3K1qrpWrW6Ck2
         eH5TgLlskDBgWz5eMHRlwLczwd0sK05J5H1v7PhxcD9ih0aWGhX0NByruMoy+UFkLvBm
         hpBBKZ5AFS+saUqvFl1ejQG22YK58YXcaqDC8jJZRxuBibF4RaV7pX+oKbxxiORYSdNp
         u7mf9h4KZR5y/IzvDn/PaLT66dRzpiW4OZcfphA+CkM7ZMcRytrQiWkMXnfF76JjhWEl
         FmZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t7si724935qvh.32.2019.02.11.19.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:00:32 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 39ADE5F797;
	Tue, 12 Feb 2019 03:00:31 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8D46963F9C;
	Tue, 12 Feb 2019 03:00:19 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v2 20/26] userfaultfd: wp: support write protection for userfault vma range
Date: Tue, 12 Feb 2019 10:56:26 +0800
Message-Id: <20190212025632.28946-21-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 12 Feb 2019 03:00:31 +0000 (UTC)
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
index fefa81c301b7..529d180bb4d7 100644
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

