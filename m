Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5191C10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 923122087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 923122087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05EBA6B000D; Mon, 25 Mar 2019 10:40:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA2176B000E; Mon, 25 Mar 2019 10:40:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF1416B0010; Mon, 25 Mar 2019 10:40:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 98CE16B000D
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:19 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q12so10387029qtr.3
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WjrNKWZy4qqYcworrBkysnGT86CRGtPdOxAeIcFioOM=;
        b=gw/7A4wQHbOZuNZ1jC8/1acFsStU26vZW4hI5d01xKn/BqbJZfeKb1aB9PQIlDBv6K
         5PSS2/tSBQ1/pZCRM7H0uJO0koQ4KMlmcVzI8C9BC5v8aFXrj/o1gM9dqCQ2RvgLqc8a
         ZY+KFgkxIo8TnLe/PcswBGWTJQygL1SuZiuVybPVnB0Vt6xIJDlk+Tt9Bb+snUP7EY2Y
         auKOjlWs/wHngpIv5zmTTANCuQhOOEI/b1X8eaoJuHlbwF4R4C9TNtIio1CX8VQROEbr
         fsjjiyV3Ho+7eyIAo28OHCAspA4RuvLjr/Z891CZLz49sfLpVzspmUTygSS+jZ9dL62K
         LXQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUO0avbu/6bMKD35n5/NdwIiEiIIl9z/oJvDhMqwbVdI4MYu0Hk
	oNcSKjxzLoyaABQRrBBehW6FoiTxSUamCQCVgvmQQSxkj675fVj3rgFh1Nb8qqC2Gfo6CCIFe0s
	EinO1jm0Kmw8JeiR4PiGDvnV6WWR5pUKQfSesFevAOi1aQlPuU+aI9MgJWPL8uz6aXA==
X-Received: by 2002:a37:4c08:: with SMTP id z8mr19791481qka.32.1553524819367;
        Mon, 25 Mar 2019 07:40:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx65YycVC2ltcgt5jnOjSy6C7KRXxYdU7bSa4HKFKeKJz8AbLkxTbebiRzdVQpwbON3m9Uv
X-Received: by 2002:a37:4c08:: with SMTP id z8mr19791424qka.32.1553524818421;
        Mon, 25 Mar 2019 07:40:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524818; cv=none;
        d=google.com; s=arc-20160816;
        b=x5CCh52t6Fok2djJFJXPLVXUt+eYrjLrRSJxhl83VHBEhvG2dECItfJPEkya3mept5
         NqQXkc0BKznBGivpL00n102SOZw4WDo+ihgKfnZwPr15roV8c9Wq9Wz0cPw0gDAii80v
         kOkdBDFW3QyuTnjTJ4hensDqVjs0U2xliVVOcvsxTJdXNJqmbGcoNO4vsGgrgRtxOSzf
         AQsirAf5UKgIyrH7xLdYClEpYV2/83gBH1SjKMO/kUs3zOYlFhqAS/USd4OEl3RY97cD
         OdegfvCrV+dAbyShpnFLDSKmHUwTV94RV/OJbcxNgJXpTc2KyS7/t45nv1Pks6rCbSZ6
         uewQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WjrNKWZy4qqYcworrBkysnGT86CRGtPdOxAeIcFioOM=;
        b=gunVKfADLSSYUt4lk8nuHktlOpYEX5yyEvQNrWfXqIyCjeByUlrMqzPnA7NV1d9hI7
         CVH1ZGBnZb3mInLvkqThCkYvQXEDt0yWgA/pUyi9VC+7QftGImmeixnNb6Z3sXLs4dpN
         P41DpvYOVI6ck7/UqVJKoT+45CUPms2S5m0X4YTj6uapY99PxSnvgNIxMrAKClOWeFSB
         jPDlwa1xIOzJuDAVYTfiObFNz+jCMqTj26LA+G4TvJHQAblqRPLMAd1GZ9fPe6vVTT0o
         x/qFSSEjebjIUdXDd4bz06Bu06blJzP5UHgUVr3ozWhe962+9iA/SPri4sqSn6S54But
         3iMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y138si1391627qkb.144.2019.03.25.07.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9F4CF308A968;
	Mon, 25 Mar 2019 14:40:17 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0ECB6100164A;
	Mon, 25 Mar 2019 14:40:16 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 04/11] mm/hmm: improve and rename hmm_vma_get_pfns() to hmm_range_snapshot() v2
Date: Mon, 25 Mar 2019 10:40:04 -0400
Message-Id: <20190325144011.10560-5-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-1-jglisse@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 25 Mar 2019 14:40:17 +0000 (UTC)
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
index 213b0beee8d3..91361aa74b8b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -698,23 +698,25 @@ static void hmm_pfns_special(struct hmm_range *range)
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
@@ -768,6 +770,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	hmm_vma_walk.fault = false;
 	hmm_vma_walk.range = range;
 	mm_walk.private = &hmm_vma_walk;
+	hmm_vma_walk.last = range->start;
 
 	mm_walk.vma = vma;
 	mm_walk.mm = vma->vm_mm;
@@ -784,9 +787,9 @@ int hmm_vma_get_pfns(struct hmm_range *range)
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

