Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84356C48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:22:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4989C2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:22:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4989C2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E51896B0007; Wed, 19 Jun 2019 22:22:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E02E38E0002; Wed, 19 Jun 2019 22:22:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D18828E0001; Wed, 19 Jun 2019 22:22:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B10F36B0007
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:22:15 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id j128so1683353qkd.23
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:22:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jN8gpQC/k7eZtjFNJDwsdS9nBmHNvi88dujJcJMSTFw=;
        b=dAjDYAj7X+e5J3g55EOsDB/qhl/OGKh3tW4nEhN3c3bvwG9l6x9b24paiei7mYOrJG
         JQX2uTE9FF5F7IAHpFD82AAhxCEMndb4vp2PlGgYplvICsxrWSr9aXdBpHxcKv9Bmled
         kS6qZCqEjc8A/mj+NgciWq29fnt9lTRQdQkvmKk2yEl0nyC0xh3HD1ZvuLmvEx1hHy7h
         kv4IYPyPw7M0XL8WMxX8Hkgu+IHG4xfoQcqm54qWnz1JFG27KGpW+UcTa2o65sT47xjy
         jU8azLW5RJw5yFR9rj5/bCXjVJTxN+nxx95pHtmwQGIrFkpDte4p/qLtfK7NtS8HR0UV
         UMXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUBtMRpVuPyPYjtYZ1KzFkDGoXX2hNyGdm8uRVsbZ1u2bsCSwhp
	Q+ZToKkyTSsCTgt8WMX2sXvpdD1KCC/moFpcYLKA+6s+U1/PA6CfuLJlfPvqTT7RNV1x7hvaDxL
	VEed4gIhRqN3UJMEsu2dvjtcwdcyNpU2+JkhMBmfqzlLo8zbSYRHfhqGRiQjTYNxXYA==
X-Received: by 2002:ac8:22db:: with SMTP id g27mr109817177qta.221.1560997335508;
        Wed, 19 Jun 2019 19:22:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxE7DH03ZmjlCx7KTEQpxuYumts+964ihwYI23UX2scR8C8y0O9hBJJHjrhiOLn/jcp/xN8
X-Received: by 2002:ac8:22db:: with SMTP id g27mr109817100qta.221.1560997334639;
        Wed, 19 Jun 2019 19:22:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997334; cv=none;
        d=google.com; s=arc-20160816;
        b=ArnbGmHgMQxNQLv+1noHnlJLaVTieS4VBKUOdEj+NdargqwwqTzsDEud/SC7O5Yd5T
         c2QPIh9rN+TN9zORFClGyDZYhXV1HXtLYWWxg/o7PKiPHPH4nvgcR9jNtGg9wqV3cQWV
         xHCfs9mfqU3qTXkEA5aJam6MgQsHEnns67Px3O92+nC0znVQTkmOwDeeLufa+KOIgtpD
         YvnWzRC70+JjWjYubzxEopAfivjdxP1FpcmtBfOWf35kJB+k4vMf3+0mCbHiKbsfmqBs
         giXl+ngbLhx+K7tjV0kEEbxnYh5nFqO9FWr+6LpL2B9E47ry6FECz5pGHF5j13LYTrSX
         SDJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jN8gpQC/k7eZtjFNJDwsdS9nBmHNvi88dujJcJMSTFw=;
        b=l1oAagzH2ptUE7VufDWxMLuo3BgM5GaWijyKvEFwxamUCd62oQC+xL5bkEFstY4B8Q
         oRclBa3EqIfmJ8IgpALqW3frxZGjtNIQUlnhQREYeDpB42ImGaXbcTelb3uri+YWt37s
         g93oLCv8VG96Y+q3IL92p2E4qUNPox1nPPd1nt4iSyLpxYMLfGUS9vrIZMaX9DRXbbyW
         aSV6ZT2ku15WD/RQ3E+on+vJOv8dSsKETLuJdzmEVLlD5MuOX1ATHg55JQpYf7UnJj60
         EuUbdcmf7JcSQuClirzeqF92DgICxxcZWOGsVcnTOyEdM66Fpar80RF5RbrNRB/IAb1W
         j3fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v65si13406854qka.78.2019.06.19.19.22.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:22:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D444F1796;
	Thu, 20 Jun 2019 02:22:13 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6663E1001E69;
	Thu, 20 Jun 2019 02:22:07 +0000 (UTC)
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
Subject: [PATCH v5 09/25] userfaultfd: wp: userfaultfd_pte/huge_pmd_wp() helpers
Date: Thu, 20 Jun 2019 10:19:52 +0800
Message-Id: <20190620022008.19172-10-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 20 Jun 2019 02:22:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Implement helpers methods to invoke userfaultfd wp faults more
selectively: not only when a wp fault triggers on a vma with
vma->vm_flags VM_UFFD_WP set, but only if the _PAGE_UFFD_WP bit is set
in the pagetable too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/userfaultfd_k.h | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 5dc247af0f2e..7b91b76aac58 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -14,6 +14,8 @@
 #include <linux/userfaultfd.h> /* linux/include/uapi/linux/userfaultfd.h */
 
 #include <linux/fcntl.h>
+#include <linux/mm.h>
+#include <asm-generic/pgtable_uffd.h>
 
 /*
  * CAREFUL: Check include/uapi/asm-generic/fcntl.h when defining
@@ -57,6 +59,18 @@ static inline bool userfaultfd_wp(struct vm_area_struct *vma)
 	return vma->vm_flags & VM_UFFD_WP;
 }
 
+static inline bool userfaultfd_pte_wp(struct vm_area_struct *vma,
+				      pte_t pte)
+{
+	return userfaultfd_wp(vma) && pte_uffd_wp(pte);
+}
+
+static inline bool userfaultfd_huge_pmd_wp(struct vm_area_struct *vma,
+					   pmd_t pmd)
+{
+	return userfaultfd_wp(vma) && pmd_uffd_wp(pmd);
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
@@ -106,6 +120,19 @@ static inline bool userfaultfd_wp(struct vm_area_struct *vma)
 	return false;
 }
 
+static inline bool userfaultfd_pte_wp(struct vm_area_struct *vma,
+				      pte_t pte)
+{
+	return false;
+}
+
+static inline bool userfaultfd_huge_pmd_wp(struct vm_area_struct *vma,
+					   pmd_t pmd)
+{
+	return false;
+}
+
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return false;
-- 
2.21.0

