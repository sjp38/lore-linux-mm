Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB0FAC10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 990D121734
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 990D121734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5714C6B026B; Wed,  3 Apr 2019 15:33:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 483AC6B026C; Wed,  3 Apr 2019 15:33:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3507D6B026D; Wed,  3 Apr 2019 15:33:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id F18E06B026C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:35 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g48so104277qtk.19
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yTkL8QdLNQoFxlLSf8gC3Y2jl4lnbj9zpLCjzX1svHg=;
        b=Oq/QrKcByTUxV1vcR4JfN9gz1SF5bKMEcdi2WPqh+NkwxR3YRuA0thdlF8UtWSyqrN
         ivf98zoWzKE9SMsCqtQAdMv1eUgmwB4PeQE1HY2KtbVB22ADrSrRrV006xy/NMoP1AZt
         sSnyvJ3IXhHuQkTOFOkKgk7tVomRWsGKuN1AvEO+TPdgur6XGZFZM1kR2oBmpjTiMeiN
         y1QOA8hheIYQEMQLNEXlAl1mh2GQQYRq7UeeFWkbqMkvixQoQTdhwNK0sApAZx4OurfD
         tiqsruj/z4hsbPkkgETf7Gati5JKIuaCey8B8wBnoA78/u9Ag+23j+Dv3L1/XzvhouO3
         8xQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU8AFb+QChavagiqT92N4h/HZ/KAKmiFfhl6bOSA59hpT7iByn7
	cshQw+TH422r5heS2j3iQws1jdA9/ZbFc9dfduGm6l6YL5FO9LdFmsYCEqDoDGSkHPNmHmygHrt
	UorPHwtndoTDZSbZQCYdiG9JGSisB77N5W2jYoGDCcmBFbnNDWR0Jj/1ZuVn8ZxnQoA==
X-Received: by 2002:ac8:75ca:: with SMTP id z10mr1674624qtq.224.1554320015732;
        Wed, 03 Apr 2019 12:33:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyq42MYQas884g4IsTWFLWP4ExEDjsAaceIY8LkEjM/somyN88+kGde6rQ0H2cmKZSQwTaj
X-Received: by 2002:ac8:75ca:: with SMTP id z10mr1674537qtq.224.1554320014178;
        Wed, 03 Apr 2019 12:33:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320014; cv=none;
        d=google.com; s=arc-20160816;
        b=i+RmrOVPFdtPd4G4+yiYjOc7ey3LCgOM2JvhGOHal3kpNNzn5JhMKteyalbGo/+Ofs
         d+6jb6b2fldcE1sLA7AOMRWDQxD5j6jy2JU7yHpsy85GGvZSeZkV4E8Erf0rSi47mG+u
         lVUa/U7+pSCwtwFNqjPkwj7557uXdrhhsoNDFbVqTdzKhLTMh3LOhKkOjrETC96ySUMe
         YJDiBxFhvAnfk5YxjvwthDFQdHlrqjqGllHIYNrRqR4/fuePgoYrEHbjLbdtglndCdZe
         Pa0CUb/EuV9enViUZGN+6yOWNjX6BXBe2emHbuDQxBsq38lHPzEDjIu4crjygrVIPMz7
         2vFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yTkL8QdLNQoFxlLSf8gC3Y2jl4lnbj9zpLCjzX1svHg=;
        b=oXKFunH52XSmjwK6Qgjq5fQ4r4iTrwGXuNibVQ/zI2gCs9QsJnUbJI28Pw12cNMbpJ
         H9E83qmIq5CmnbOuFngC2fCKPSzTZAhfI9uLBVEf98Wb6D/IgFvWUPeAnpH4c5n0gKR4
         DzFOxEJrB28RAfGuJpQYzLaBurhwtJSYoAsVksNsWdp4neI/HfpnkOCGAO4bnjnqdu1V
         keuZ9t/M0djrbhTyZeeAg7m0+zg5b16dJeqQxyPIJTLmiNTLeu2eOAlyaHDX/HmRl/Iw
         O5YXnLZ+lnnqbp/HfK7xndvXtCVna0hjBBIPVLxqQWoGD0Ily6ceIp9Vp4A2eHpa3BcE
         d5Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c18si628526qkm.240.2019.04.03.12.33.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 566A1C079C2A;
	Wed,  3 Apr 2019 19:33:33 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8C2836012C;
	Wed,  3 Apr 2019 19:33:32 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v3 04/12] mm/hmm: improve and rename hmm_vma_get_pfns() to hmm_range_snapshot() v2
Date: Wed,  3 Apr 2019 15:33:10 -0400
Message-Id: <20190403193318.16478-5-jglisse@redhat.com>
In-Reply-To: <20190403193318.16478-1-jglisse@redhat.com>
References: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 03 Apr 2019 19:33:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Rename for consistency between code, comments and documentation. Also
improves the comments on all the possible returns values. Improve the
function by returning the number of populated entries in pfns array.

Changes since v1:
    - updated documentation
    - reformated some comments

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 Documentation/vm/hmm.rst | 26 ++++++++++++++++++--------
 include/linux/hmm.h      |  4 ++--
 mm/hmm.c                 | 31 +++++++++++++++++--------------
 3 files changed, 37 insertions(+), 24 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index 44205f0b671f..d9b27bdadd1b 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -189,11 +189,7 @@ the driver callback returns.
 When the device driver wants to populate a range of virtual addresses, it can
 use either::
 
-  int hmm_vma_get_pfns(struct vm_area_struct *vma,
-                      struct hmm_range *range,
-                      unsigned long start,
-                      unsigned long end,
-                      hmm_pfn_t *pfns);
+  long hmm_range_snapshot(struct hmm_range *range);
   int hmm_vma_fault(struct vm_area_struct *vma,
                     struct hmm_range *range,
                     unsigned long start,
@@ -202,7 +198,7 @@ When the device driver wants to populate a range of virtual addresses, it can
                     bool write,
                     bool block);
 
-The first one (hmm_vma_get_pfns()) will only fetch present CPU page table
+The first one (hmm_range_snapshot()) will only fetch present CPU page table
 entries and will not trigger a page fault on missing or non-present entries.
 The second one does trigger a page fault on missing or read-only entry if the
 write parameter is true. Page faults use the generic mm page fault code path
@@ -220,19 +216,33 @@ Locking with the update() callback is the most important aspect the driver must
  {
       struct hmm_range range;
       ...
+
+      range.start = ...;
+      range.end = ...;
+      range.pfns = ...;
+      range.flags = ...;
+      range.values = ...;
+      range.pfn_shift = ...;
+
  again:
-      ret = hmm_vma_get_pfns(vma, &range, start, end, pfns);
-      if (ret)
+      down_read(&mm->mmap_sem);
+      range.vma = ...;
+      ret = hmm_range_snapshot(&range);
+      if (ret) {
+          up_read(&mm->mmap_sem);
           return ret;
+      }
       take_lock(driver->update);
       if (!hmm_vma_range_done(vma, &range)) {
           release_lock(driver->update);
+          up_read(&mm->mmap_sem);
           goto again;
       }
 
       // Use pfns array content to update device page table
 
       release_lock(driver->update);
+      up_read(&mm->mmap_sem);
       return 0;
  }
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 716fc61fa6d4..32206b0b1bfd 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -365,11 +365,11 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
  * table invalidation serializes on it.
  *
  * YOU MUST CALL hmm_vma_range_done() ONCE AND ONLY ONCE EACH TIME YOU CALL
- * hmm_vma_get_pfns() WITHOUT ERROR !
+ * hmm_range_snapshot() WITHOUT ERROR !
  *
  * IF YOU DO NOT FOLLOW THE ABOVE RULE THE SNAPSHOT CONTENT MIGHT BE INVALID !
  */
-int hmm_vma_get_pfns(struct hmm_range *range);
+long hmm_range_snapshot(struct hmm_range *range);
 bool hmm_vma_range_done(struct hmm_range *range);
 
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 84e0577a912a..bd957a9f10d1 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -702,23 +702,25 @@ static void hmm_pfns_special(struct hmm_range *range)
 }
 
 /*
- * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual addresses
- * @range: range being snapshotted
- * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
- *          vma permission, 0 success
+ * hmm_range_snapshot() - snapshot CPU page table for a range
+ * @range: range
+ * Returns: number of valid pages in range->pfns[] (from range start
+ *          address). This may be zero. If the return value is negative,
+ *          then one of the following values may be returned:
+ *
+ *           -EINVAL  invalid arguments or mm or virtual address are in an
+ *                    invalid vma (ie either hugetlbfs or device file vma).
+ *           -EPERM   For example, asking for write, when the range is
+ *                    read-only
+ *           -EAGAIN  Caller needs to retry
+ *           -EFAULT  Either no valid vma exists for this range, or it is
+ *                    illegal to access the range
  *
  * This snapshots the CPU page table for a range of virtual addresses. Snapshot
  * validity is tracked by range struct. See hmm_vma_range_done() for further
  * information.
- *
- * The range struct is initialized here. It tracks the CPU page table, but only
- * if the function returns success (0), in which case the caller must then call
- * hmm_vma_range_done() to stop CPU page table update tracking on this range.
- *
- * NOT CALLING hmm_vma_range_done() IF FUNCTION RETURNS 0 WILL LEAD TO SERIOUS
- * MEMORY CORRUPTION ! YOU HAVE BEEN WARNED !
  */
-int hmm_vma_get_pfns(struct hmm_range *range)
+long hmm_range_snapshot(struct hmm_range *range)
 {
 	struct vm_area_struct *vma = range->vma;
 	struct hmm_vma_walk hmm_vma_walk;
@@ -772,6 +774,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	hmm_vma_walk.fault = false;
 	hmm_vma_walk.range = range;
 	mm_walk.private = &hmm_vma_walk;
+	hmm_vma_walk.last = range->start;
 
 	mm_walk.vma = vma;
 	mm_walk.mm = vma->vm_mm;
@@ -788,9 +791,9 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	 * function return 0).
 	 */
 	range->hmm = hmm;
-	return 0;
+	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
 }
-EXPORT_SYMBOL(hmm_vma_get_pfns);
+EXPORT_SYMBOL(hmm_range_snapshot);
 
 /*
  * hmm_vma_range_done() - stop tracking change to CPU page table over a range
-- 
2.17.2

