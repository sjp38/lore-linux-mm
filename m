Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C057BC282D1
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86FED20989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86FED20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C661D8E0001; Tue, 29 Jan 2019 11:54:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2BFA8E0008; Tue, 29 Jan 2019 11:54:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92F6F8E0001; Tue, 29 Jan 2019 11:54:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 603D78E0008
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:48 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w185so22504642qka.9
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PI7GUp8ZvA3zxJ+GcKn6vnogCxLfh9GqOCOpMvvb278=;
        b=CVVNfuwOxG4ly1CMsjF7FCanmhmTbsCIYXCAIl0VV5mq2b8lHJWTbDfr9xkD2zkBUs
         2akZE3ccHbhmr7IAOx88cHGKwlfq9Undr75cltlMqz6HKSfUXnc1yVv/8SqSqTT6lSTY
         Xe9mgvpV5SuQVqYBtk+3GP7i+B4ETLGxHmHA4vLLJw27P/VTOaiSq1gLSmgbejUVycba
         9EJGT68siWlYDq4h5eL5yxijwgzYjnDct+DRltW+egHOojb3UB5uAX9UByRKvzM3Ur6G
         ZV/Us6y2ea/mHWTnF1HVvVmm9m0y0bg+FXGA/VNWG55qbzBnPP9NM+QpUYEp92WooE7L
         PXxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUuke9A1v6wE1Xc+9Kc5dyNfIhVE3k11YZaLjmgoVtSw4ZmMGLqDzk
	ueUYt3bl3xhacXwmi03B/YFV/K3KlMQgWxN47djSDO8autYI6S76u2cWYJNFfhrgAPpUxEQjPgv
	ma1HKYVVEVjlaY7n+DGqvNQmLSJfF/FeyjCW9z6l0aPOHVLWC5JvncJEHf6a8CH7yxw==
X-Received: by 2002:a0c:fb4c:: with SMTP id b12mr24780051qvq.177.1548780888153;
        Tue, 29 Jan 2019 08:54:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5kVcyFshSqooJSSkoC8fqn4mCpgffHbDbZ5OTxC0rwEhduhH0W/vMKldCDs3KAxldmMNR+
X-Received: by 2002:a0c:fb4c:: with SMTP id b12mr24780017qvq.177.1548780887676;
        Tue, 29 Jan 2019 08:54:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780887; cv=none;
        d=google.com; s=arc-20160816;
        b=QIO5Fc3VUML9VM5yLE29XeXPhzg92V+dJXbJd6tjY6pbFllUqMI5IBz3GXSIe0WXLB
         BcmnfyiBorjPwT8vp0uTbhvUsmmry8tmyf344QxOR3+UQn+C8dupqgoVIrTmhbCMyosu
         DGF4u2acr8ej0P3P4TWoN0rSI2IeO/S7uJuD0w9zG9z6rHnc7aaePhww/YHH2WS+ZozI
         dAOceIT6mQ+j72weqO0dAz2OJTUsgh6DZMTnCYPJmPy0kF7DsomFDV4rORW78XctKXIC
         2taoDI1NbhStYcodVk+NerXmRnXnZaPKMPZ3LzI1fEJtDyo7hVXrcZCmstUeXseA+2Ym
         9FLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PI7GUp8ZvA3zxJ+GcKn6vnogCxLfh9GqOCOpMvvb278=;
        b=v0qEH9M9Uy5dg8MbfSGAQSZs6+ioy43DivXycqZ5zexFOdxV10KpCFtrHi2FLleviU
         Ep+FCbeppdOYJX1tYdZcY2xwK6IEdC9LJVbCfhYSGzsCWDp+avwz/J7NVs9iPHJJuryE
         iNeMlk8piDXJRwJKcA17OpYyYkuq4Mr++8FA0oo5jPZ1GFsipDAa/rvBfhC3q4a6oJRJ
         vvuuOd42ozyRg42COX3GwCnO/vWIpcnQXHWScU6LKaHXBODfJL8k7NzNaKRj9p8lHAA9
         n4p36fJZiTjnmmrJS7f/qz8/ztolyRTp+qNMjCDvcRZ+Gk3U/bt0yUGGh0ZbAgZd7df2
         Ioqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 51si1142969qvt.60.2019.01.29.08.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:47 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C76D680F79;
	Tue, 29 Jan 2019 16:54:46 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C1EC4102BCEB;
	Tue, 29 Jan 2019 16:54:45 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 06/10] mm/hmm: add default fault flags to avoid the need to pre-fill pfns arrays.
Date: Tue, 29 Jan 2019 11:54:24 -0500
Message-Id: <20190129165428.3931-7-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 29 Jan 2019 16:54:46 +0000 (UTC)
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
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h |  7 +++++++
 mm/hmm.c            | 12 ++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 93dc88edc293..4263f8fb32e5 100644
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
index 860ebe5d4b07..0a4ff31e9d7a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -423,6 +423,18 @@ static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
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

