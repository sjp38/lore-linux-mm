Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C066C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:24:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DBCB215EA
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:24:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DBCB215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D17738E0009; Wed, 19 Jun 2019 22:24:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEF728E0001; Wed, 19 Jun 2019 22:24:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C05DA8E0009; Wed, 19 Jun 2019 22:24:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1E0F8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:24:11 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id y184so1727596qka.15
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:24:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=n1hFkPZtnzXNVbq0M+P7hVnKByN4oXMlp+t0H+PU8qo=;
        b=j/jliSmPUfKCvaDATMzBb2FhEaaAjJIbFJ4aADvbi9SKzguCJGTpbw8jlGOq/oNGWH
         k0gcDSAaWpWVcujt7bRcp9FI4RYUowkbtU8EQcRTIXAxrrXkjwwwZaET5wjZMcVJ0sRs
         5o+1vuXfjmfCB6PDhVJcanxQmDVOxrHGclqH7+pc3mFo5bi5ZtZWVZ4ssSUFvoBqWTWl
         BIN/csQREgVQxay5z1OmK8xtBtLwjF5+qUpi+Li4USWxVEqrv3EftOkumykWNhpetSNp
         Qyed7D1qbXQugQWY1ipOmkjtTsSyWkkTw0jgyLlBLwc7J/FtVrziIFHZc2SiQvgHqwyf
         +DLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVpfBgRqbxJomCNXcHLb/4DsSRWKsqgC3CQp5THw05zZKEfTB+y
	lTZY3ePNcGkoSuEIjeBuEve8YmoZYLDHhxhchOhoMWfZ30WOTdTJ15i24PjS9xK/o0tyCVEkPbe
	Jhml/AF2gfGMfI8TKTDEPNONoX2DN3gkkyWrs7T/4q+nf5+HdOd8rJJ5vBXBdWcjDuQ==
X-Received: by 2002:ac8:2e5d:: with SMTP id s29mr101482332qta.70.1560997451443;
        Wed, 19 Jun 2019 19:24:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxa0Z1rPtjl+d5K6CwKZwOiuLg5HV+2R8+7yxgK6I8toqlCyxvrUe+xj2cmnPXTaW83k4ka
X-Received: by 2002:ac8:2e5d:: with SMTP id s29mr101482310qta.70.1560997450889;
        Wed, 19 Jun 2019 19:24:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997450; cv=none;
        d=google.com; s=arc-20160816;
        b=iKnqm5GWeeRwpKmwSwam9jhCTJicw6ySBQEc3Zh3mfpz+wXQuW1RC9Vyucw2+BmoHa
         SfbM6foaMxTFLCZ4bWIpi+e0xLkdsnG18w8uvdm9YussFf1ZWG47ozCHIyrb7odvOt9M
         JdEkhILkuWFscJgE5qiB7LqqOMNuyJ36fRn2CBdTQJ2+qqi32j0eayY5qKjuAqTXfJZz
         9W8aHG57vO12Wb/4zwmrPcWLqhTgldLa9vcru4jTWhPnTzXlMygz7nuc/CBYCfT1PDQL
         vD1zdhW74y43DIwnjiVuhWwC6hpLbVtTCJnWqf7o1xWaycl/hYoikRhBxEQXXQbi2Tgx
         Ucsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=n1hFkPZtnzXNVbq0M+P7hVnKByN4oXMlp+t0H+PU8qo=;
        b=XjSrB5DiPVktnq9+goX5Li78bfNljDrjIOB3YaSo1ZykW2LXYohCENRRdoOwv8UmAB
         xNqep0P9LoDmBEuVPEL92u/g8xh6D/Uh1Nq24yVvmGaHfpbd9pxtV5mXrbhl+gj/NVKo
         8nmR0DB+9P1+hUrmfzCm19ypvhkAJ2yVjIshh8YIvDot0E0AgRNC2r8C2H/Ev6en53js
         qGwmIyrnMTdjepdbljrAjHe6UjKLhq5raBmbkaQQ3ShzU0l5922UOFcOwt5LYZpj/jeE
         egSJ3FwxwRvyXTK1Ty9V1JFlXMDrjT9C7uHxnJdcB/ePI61BOi/4rrTilrT31YU6Mkux
         A8Vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c127si13489462qkg.194.2019.06.19.19.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:24:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E30A3C05D275;
	Thu, 20 Jun 2019 02:24:09 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A7B5610190A8;
	Thu, 20 Jun 2019 02:23:53 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v5 18/25] userfaultfd: wp: support write protection for userfault vma range
Date: Thu, 20 Jun 2019 10:20:01 +0800
Message-Id: <20190620022008.19172-19-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 20 Jun 2019 02:24:10 +0000 (UTC)
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
index dcd33172b728..a8e5f3ea9bb2 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -41,6 +41,9 @@ extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
 			      unsigned long dst_start,
 			      unsigned long len,
 			      bool *mmap_changing);
+extern int mwriteprotect_range(struct mm_struct *dst_mm,
+			       unsigned long start, unsigned long len,
+			       bool enable_wp, bool *mmap_changing);
 
 /* mm helpers */
 static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 6b9dd5b66f64..4208592c7ca3 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -638,3 +638,57 @@ ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
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
2.21.0

