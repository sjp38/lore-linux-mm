Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58313C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 167782087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 167782087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 510886B0266; Mon, 25 Mar 2019 10:40:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D3BC6B0010; Mon, 25 Mar 2019 10:40:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07EA36B026A; Mon, 25 Mar 2019 10:40:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D339F6B0010
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:21 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 54so10343977qtn.15
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2sp6d/tamBRD55gqEYdNuviJE1ZEteUB7U7gWf01poQ=;
        b=N/rEKhSsq5UkCLaWaqaF4iQa/n/7GBKbys0vimn9WtzrqqV4wkBP6JTQ/ysYtvMuK7
         1vwTUSOIYyLbWyg2TkvUhj9tpZDW160pw/tAs9241qJtXHgcAbk2qlONyT0HnVLX4gtl
         Aw9Uz7YHWM1ZiIvqzUGcBq1crXbI1Ql2FaBs1wPryvemL5rQurZe5kvZ6TaKjqJr88Xq
         V/XQgXzxbnxbkGEulUDTK3PDj/xaEvIjfl6bHNilQ4BVwSXCXQFbcEfORpMGifdru1pZ
         i2rVifQwCc5iv35fddgEMYi+W3UZEn7RCDg2rYGQ6BAOEUDp5wAZhGklFN8d3OITUR2Q
         iA9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWLfwqWZgxJYeDSfDjis6dGwjmwjGWW99rXeRHSL5xFU1g2AM9t
	Kh7QAKLBwXAKrgpemwHl1pOGRUDDw5dJabCNmkeBkSK3cWd2pmxN5Z54KxPCFmztCJ9KXjcWrpV
	7vnQ3R0C3WToQ0wCjnl3/seQHnQdHd9ZRxcd/bF4xoYzN2pCYzCWxQiL1WHwRkLqSiA==
X-Received: by 2002:a0c:94d0:: with SMTP id k16mr21261936qvk.158.1553524821635;
        Mon, 25 Mar 2019 07:40:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyy3M/13KUuOfioONe7UjXgeI1M2oqwr516cfD9CsoEMnNATrOpsazJWjYAzVyu7RL5iDe
X-Received: by 2002:a0c:94d0:: with SMTP id k16mr21261894qvk.158.1553524821047;
        Mon, 25 Mar 2019 07:40:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524821; cv=none;
        d=google.com; s=arc-20160816;
        b=GPC9Cboi2lRjMfS/cFkurT5Lh+xvKUrSuKkHYgwexTetupILzgC6oVwHfQiCTuA/9W
         pNU3Cg5jZ+JP+QNiSmSoSQaCa2ynVQMUuKecO2dbIMuDphlOotIg06zHAYjA9NoIj6Z5
         Hq4JuP5w+l9FVL68o33O/Pi7e2im6I49SZqandQH74cHIzQHRfHCCfKgZIg7GKr6pUI7
         JVtJsb6WJ+3bbX5nL3lgyHLS+E6ng0ncVI4ZWWa2yXFW6BNSNHVLrWX1m5F70fB/I0HE
         DVinJhdMBZUkxG+rKdqzae4QjmNt0Gz1wmSJ/zjgRdIezjmOaKE6VWkgwqApE4cbWkll
         IHnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=2sp6d/tamBRD55gqEYdNuviJE1ZEteUB7U7gWf01poQ=;
        b=jJkQg2ca5aESlwVA8q2NHqTmbyPUbWYkSj4UQj7tS6v4GGEP7Mf8BHhyyJhMpnDB+4
         hWY2ORg8iPbEzsGNzyDV4lgw0sYuHX5JGeOXF9H2LugkBUt4p09ElXPCaqzyVxfX5bgy
         hGbKVYGMxjSrBMtUo0287rff4fGkNBTmEYByy9TVH30MVNpo5RlJOQsv8VaSVuSQuqCC
         3v0Tpcqw83jWrhhB2kda5Ifo0zkqZcRZc02w3yNJ0znvym/iZKldOL0OODCgFpbUvem5
         n2f1QpXkqzJCEbGXZRLTS8d/137/SvPDWgCMufQQ48MmYCnn5ZsWx+xXOMnH/H0XIEWO
         gyjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s43si446382qvc.88.2019.03.25.07.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 429C530832EA;
	Mon, 25 Mar 2019 14:40:20 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 920CD100164A;
	Mon, 25 Mar 2019 14:40:19 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the need to pre-fill pfns arrays.
Date: Mon, 25 Mar 2019 10:40:07 -0400
Message-Id: <20190325144011.10560-8-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-1-jglisse@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 25 Mar 2019 14:40:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

The HMM mirror API can be use in two fashions. The first one where the HMM
user coalesce multiple page faults into one request and set flags per pfns
for of those faults. The second one where the HMM user want to pre-fault a
range with specific flags. For the latter one it is a waste to have the user
pre-fill the pfn arrays with a default flags value.

This patch adds a default flags value allowing user to set them for a range
without having to pre-fill the pfn array.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/hmm.h |  7 +++++++
 mm/hmm.c            | 12 ++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 79671036cb5f..13bc2c72f791 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -165,6 +165,8 @@ enum hmm_pfn_value_e {
  * @pfns: array of pfns (big enough for the range)
  * @flags: pfn flags to match device driver page table
  * @values: pfn value for some special case (none, special, error, ...)
+ * @default_flags: default flags for the range (write, read, ...)
+ * @pfn_flags_mask: allows to mask pfn flags so that only default_flags matter
  * @pfn_shifts: pfn shift value (should be <= PAGE_SHIFT)
  * @valid: pfns array did not change since it has been fill by an HMM function
  */
@@ -177,6 +179,8 @@ struct hmm_range {
 	uint64_t		*pfns;
 	const uint64_t		*flags;
 	const uint64_t		*values;
+	uint64_t		default_flags;
+	uint64_t		pfn_flags_mask;
 	uint8_t			pfn_shift;
 	bool			valid;
 };
@@ -521,6 +525,9 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 {
 	long ret;
 
+	range->default_flags = 0;
+	range->pfn_flags_mask = -1UL;
+
 	ret = hmm_range_register(range, range->vma->vm_mm,
 				 range->start, range->end);
 	if (ret)
diff --git a/mm/hmm.c b/mm/hmm.c
index fa9498eeb9b6..4fe88a196d17 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -415,6 +415,18 @@ static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
 	if (!hmm_vma_walk->fault)
 		return;
 
+	/*
+	 * So we not only consider the individual per page request we also
+	 * consider the default flags requested for the range. The API can
+	 * be use in 2 fashions. The first one where the HMM user coalesce
+	 * multiple page fault into one request and set flags per pfns for
+	 * of those faults. The second one where the HMM user want to pre-
+	 * fault a range with specific flags. For the latter one it is a
+	 * waste to have the user pre-fill the pfn arrays with a default
+	 * flags value.
+	 */
+	pfns = (pfns & range->pfn_flags_mask) | range->default_flags;
+
 	/* We aren't ask to do anything ... */
 	if (!(pfns & range->flags[HMM_PFN_VALID]))
 		return;
-- 
2.17.2

