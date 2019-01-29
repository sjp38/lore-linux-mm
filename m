Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB2FEC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82B5920989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82B5920989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6A1C8E0005; Tue, 29 Jan 2019 11:54:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC60C8E0001; Tue, 29 Jan 2019 11:54:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3F588E0005; Tue, 29 Jan 2019 11:54:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD738E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:43 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q3so25449989qtq.15
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=n2/nkvHycDGkjXSl6PLGynhqbyvPV8LWO6aSFBVE884=;
        b=ecCF6zJ2fwv/1FkGorbez2vCKSWCWTC5Gdmn0JpXuNwsvC2RzJvyKwUq4Zq0jd1kma
         SnqJWiyPtAtQgaq3Ch1eiwGnfR0+HEq5C9MTzWnQZ8tZpGkzbD2DOxhkFmTX52M6cVYG
         p3AYleKgDms9d4lKaCfejwKGEaZ7ozDY5i8Eb6puaGmXutHFXjHE2EUZpD5KsqGRiZZT
         o8pQeHF63/Dmf5YYjXI6JqnwO0G7nQ5wkclCKkGqpi7AazRqG8JaMNz8rpl9fcNTuzip
         cyKX9Ju3n0uZGl6/YAGL4sgaFSAo0UHi2AJfrKUvzjDwrvZDJHgZTSvzpKPTL81q64Kr
         RMXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeeE8InFKbzrOSyMib4IfACAt6aNjY5o5Imv3OCRaGXp6o92IF0
	xUV3zN0eGEdFi1OxxU6zLZXxIieXpVF5E6aom8BzPW5AUWsSlKX6OheKN6j4YWPC0Ilo7rAXGm4
	guQyN8HPt+W+DK89GuvWV/d8Bued5lxuQMqxAfU+OiBMYu+mRCkrWOZCbYCvgAEDsPw==
X-Received: by 2002:aed:2c22:: with SMTP id f31mr27008064qtd.154.1548780883332;
        Tue, 29 Jan 2019 08:54:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6XsYmo1VGTq7T0LcJFyfgcjH97aU3K8UY7HtbMfzrUTyC9NoPbZ4gFmBfF+ZJMBrWfFzet
X-Received: by 2002:aed:2c22:: with SMTP id f31mr27008035qtd.154.1548780882870;
        Tue, 29 Jan 2019 08:54:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780882; cv=none;
        d=google.com; s=arc-20160816;
        b=OUwWtP1xWVFeGxTa82zj9BT8xSglESTRGs6SKDMgPhQYeKCAqv+UkAo6KDxrz4K9eq
         x4gFPWmGCNE+jpZ9MXptJwgtNzZgbaXzzrAjIxSAcYTI2F0wKZnGYOK0IvII21q2136P
         XtDMKTgXdIyAmOhvfoToa+RyMiVLnDhtksGQOlF/ahqPZevuJfuvXzvVkwLfA4PL0z9W
         AqdkXFtzP2GeDsz6YsdIdqiEjfdoJAqibH3f5Utj8rE+jkZ1lo9QIefEIj2Vc8Ly8QQ+
         uDcb6sxqhHHlamnxlBmpegPzquYEpDmSZiDjFWHMffyxQkQuvS6ZrIadeMePTjlbtqwe
         3wmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=n2/nkvHycDGkjXSl6PLGynhqbyvPV8LWO6aSFBVE884=;
        b=DYbWxXt1kzgqrNiTyPAyR7WNTCN2TBHdeC2VQkLoZPeGidov4lflOL9kDQRPZdqBLr
         LR4eOUA0ZKv57TbKBtWQIcU/LTISU6+WKsUBxJuvdc9TOKgpNoOM1mlda8fYdDx1mpW9
         4LAG/8F07jebhy+XPSzjjiqDejbpFH+Z4/aQKg3mu91ltL5YuUethWTyVpR/uD5vZqse
         DdI2pUXCX2qSvlsGkkIsCCtFdPEQ++tIRaR2audKb2LuN9tZhRQgZX9DTYAt6lNoYkw8
         nBw9dc14prP5tN5a1kIx09MccnDPskJ2uONnV8jYSpbLt/I2wGi6Io+R4tUpnjOlVbyW
         87Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 44si2123991qtp.70.2019.01.29.08.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:42 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EDFC43DE0E;
	Tue, 29 Jan 2019 16:54:41 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E1FCA103BAB6;
	Tue, 29 Jan 2019 16:54:40 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 03/10] mm/hmm: improve and rename hmm_vma_get_pfns() to hmm_range_snapshot()
Date: Tue, 29 Jan 2019 11:54:21 -0500
Message-Id: <20190129165428.3931-4-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 29 Jan 2019 16:54:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Rename for consistency between code, comments and documentation. Also
improves the comments on all the possible returns values. Improve the
function by returning the number of populated entries in pfns array.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h |  4 ++--
 mm/hmm.c            | 23 ++++++++++-------------
 2 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index bd6e058597a6..ddf49c1b1f5e 100644
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
index 74d69812d6be..0d9ecd3337e5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -706,23 +706,19 @@ static void hmm_pfns_special(struct hmm_range *range)
 }
 
 /*
- * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual addresses
- * @range: range being snapshotted
+ * hmm_range_snapshot() - snapshot CPU page table for a range
+ * @range: range
  * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
- *          vma permission, 0 success
+ *          permission (for instance asking for write and range is read only),
+ *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no valid
+ *          vma or it is illegal to access that range), number of valid pages
+ *          in range->pfns[] (from range start address).
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
@@ -776,6 +772,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	hmm_vma_walk.fault = false;
 	hmm_vma_walk.range = range;
 	mm_walk.private = &hmm_vma_walk;
+	hmm_vma_walk.last = range->start;
 
 	mm_walk.vma = vma;
 	mm_walk.mm = vma->vm_mm;
@@ -792,9 +789,9 @@ int hmm_vma_get_pfns(struct hmm_range *range)
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

