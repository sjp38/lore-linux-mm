Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D839C10F0E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47367214AF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47367214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C56586B026D; Wed,  3 Apr 2019 15:33:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A83516B0274; Wed,  3 Apr 2019 15:33:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 680EB6B0271; Wed,  3 Apr 2019 15:33:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39E5C6B026F
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:39 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o135so159280qke.11
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=seuyMvHcnjUrsqyohmlvNEeaYKNbox69Y4Nl803gldo=;
        b=SPkNwd1ZMr4a12xssedSOg67sTlza+YYlUI9myGpD8V6oddyvCG51+qpwbDhnu020j
         MJsRipWLAxX3AqSFtqkH/fVyT6lNEeWqtvdcRy8DkGWRlkC2OvitrXrxZZAgQPfFt9Zq
         6x/WCEaZ1TA5EwH6SLK89SSaJWyt2LGbpUukGfM02lzO0Avo+yk7HPl8O1XKrgZdaD3k
         BTr5E/O44ME0xxgH51SLXxXseT7avdBcKD1ORQpdPI/v/lEGBv/HEzuMXcy9UlxyM5eV
         xobZPmrSIiPHL2tIBmapG5fl4nq9zOswVhUw2mBBdvoqCBXcs251ukfuQs/fTGPHjH81
         Rz8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWRGv7rewetp+MPNLv3M1TfWzdpHYFjjwcS9hgOMDXobOXVuXB0
	SkjKBOATFhgZ6VI4iMhYOBzQQUAi7NXUFiZlRUcHOpxW7HgCxKUtt7/SiExHRSVG+oHSJZr4/mY
	E/gIMFzriew1c3qELoI9W5hS+bX86NzFrnXbYco40xdsHlokprDAzs1NJG9NTjRovNA==
X-Received: by 2002:ac8:3687:: with SMTP id a7mr1667042qtc.284.1554320018983;
        Wed, 03 Apr 2019 12:33:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhi+BPO0Ap3CW5gV7SCXx1DOqXxZBupDcX7gRdXEzn2zESLhPIFLnlt5wAbb4F+/5fSbD9
X-Received: by 2002:ac8:3687:: with SMTP id a7mr1666980qtc.284.1554320018178;
        Wed, 03 Apr 2019 12:33:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320018; cv=none;
        d=google.com; s=arc-20160816;
        b=dEXj9QL1M+tWqBJncJ44jZX29j+5hHuHtVpHALUVZmId+lPckCSfArUqOBV16Np5jX
         +VdpUnHkOiiHW3Io0O77Pi3qDosvlOKDkS8LRY12eqYZGs32L6k1LTfjkf043XH4U4CB
         KRir262vWIMhqmrrgD63IfZ1Gvo+LK9YS3Ep6FeU1YJBfQepVCLUL52KP3qZy0dOWvpB
         KTfcUWbUutHb1NVWGxuJ17CQ5PSIdM48dG16WOowyW053RBIbB9XeKL/mGSFrHW2Mokp
         vzEoFVxwxa5kzIZEImh/jQx/fWrr/yNPuUc6YwHuuf3J0NYNpBnUaBdtw7YW3XZuCmvj
         fj1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=seuyMvHcnjUrsqyohmlvNEeaYKNbox69Y4Nl803gldo=;
        b=TIv/O5DwvZ0NCi8H0TN6qbMGalYHXvfborNfPxJVDVP2b/bjs6PVaolmRPOuh4YMXm
         JHIbh7RnTEOJ6L/2P+zM8pATHHTGvs5Zf9q2yUZTi4kw7NojjFdAQ9+q+CQ0TbsqLGKY
         qWQ68+cp6ObXbiSyeHlOeN4cLofs9zRPg2Nu1wAwZ/GJqurCLVWm8i3wlnRGAHv5cfzR
         grLSv94tqyJpT7oJ7xzSdU01yoX2ihNzx9iuyhlaomYktO0+2U+XRwn3iizAuGB6mpSd
         SzNRjUfRNo+yCxN5ZLv6Q1eHn++ZRnKoGQPZV0LZAhAF38q6Xb76EIcvjFSXTrMUprEV
         /s0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w28si2521044qtk.21.2019.04.03.12.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 63F8230842B1;
	Wed,  3 Apr 2019 19:33:37 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7D2C86012C;
	Wed,  3 Apr 2019 19:33:36 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v3 07/12] mm/hmm: add default fault flags to avoid the need to pre-fill pfns arrays v2
Date: Wed,  3 Apr 2019 15:33:13 -0400
Message-Id: <20190403193318.16478-8-jglisse@redhat.com>
In-Reply-To: <20190403193318.16478-1-jglisse@redhat.com>
References: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 03 Apr 2019 19:33:37 +0000 (UTC)
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

Changes since v1:
    - Added documentation.
    - Added comments in the old API wrapper to explain what is going on.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 Documentation/vm/hmm.rst | 35 +++++++++++++++++++++++++++++++++++
 include/linux/hmm.h      | 13 +++++++++++++
 mm/hmm.c                 | 12 ++++++++++++
 3 files changed, 60 insertions(+)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index 945d5fb6d14a..ec1efa32af3c 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -276,6 +276,41 @@ report commands as executed is serialized (there is no point in doing this
 concurrently).
 
 
+Leverage default_flags and pfn_flags_mask
+=========================================
+
+The hmm_range struct has 2 fields default_flags and pfn_flags_mask that allows
+to set fault or snapshot policy for a whole range instead of having to set them
+for each entries in the range.
+
+For instance if the device flags for device entries are:
+    VALID (1 << 63)
+    WRITE (1 << 62)
+
+Now let say that device driver wants to fault with at least read a range then
+it does set:
+    range->default_flags = (1 << 63)
+    range->pfn_flags_mask = 0;
+
+and calls hmm_range_fault() as described above. This will fill fault all page
+in the range with at least read permission.
+
+Now let say driver wants to do the same except for one page in the range for
+which its want to have write. Now driver set:
+    range->default_flags = (1 << 63);
+    range->pfn_flags_mask = (1 << 62);
+    range->pfns[index_of_write] = (1 << 62);
+
+With this HMM will fault in all page with at least read (ie valid) and for the
+address == range->start + (index_of_write << PAGE_SHIFT) it will fault with
+write permission ie if the CPU pte does not have write permission set then HMM
+will call handle_mm_fault().
+
+Note that HMM will populate the pfns array with write permission for any entry
+that have write permission within the CPU pte no matter what are the values set
+in default_flags or pfn_flags_mask.
+
+
 Represent and manage device memory from core kernel point of view
 =================================================================
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index ec4bfa91648f..dee2f8953b2e 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -165,6 +165,8 @@ enum hmm_pfn_value_e {
  * @pfns: array of pfns (big enough for the range)
  * @flags: pfn flags to match device driver page table
  * @values: pfn value for some special case (none, special, error, ...)
+ * @default_flags: default flags for the range (write, read, ... see hmm doc)
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
@@ -448,6 +452,15 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 {
 	long ret;
 
+	/*
+	 * With the old API the driver must set each individual entries with
+	 * the requested flags (valid, write, ...). So here we set the mask to
+	 * keep intact the entries provided by the driver and zero out the
+	 * default_flags.
+	 */
+	range->default_flags = 0;
+	range->pfn_flags_mask = -1UL;
+
 	ret = hmm_range_register(range, range->vma->vm_mm,
 				 range->start, range->end);
 	if (ret)
diff --git a/mm/hmm.c b/mm/hmm.c
index 3e07f32b94f8..0e21d3594ab6 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -419,6 +419,18 @@ static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
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

