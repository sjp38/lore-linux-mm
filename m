Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73443C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:33:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25E4E217F5
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:33:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="IO2DxLoL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25E4E217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1F706B000A; Tue,  6 Aug 2019 17:33:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F5F96B000C; Tue,  6 Aug 2019 17:33:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90B386B000D; Tue,  6 Aug 2019 17:33:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0586B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:33:34 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 65so49061514plf.16
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:33:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iDYJ7U3nkVgsQNyTJOd+SzW5VeEmpFyQjCRy1sAmQDA=;
        b=U/HrKf7vpJtk7/t74/q29sJg6OqQsRHj4fb2aiTlStBJVKfZ37yMD0O6+udG8wbVwx
         GOARcRnSLOBB5RYDmliwn8XHEpdUlc2UVXxrrpjjf5Z5IMdYOsC2xTwkCsJXtI5My8uD
         QgKJNK9HWqpE+W4rawUgXJ3OVheCDCeBuJ9KHq5VMWDoGNyVHuivtJzfwidIOYBVs4Q9
         90gLxRhSGjPbxTCF+4gP2k+vNlCVYwxXWwXbn4NxtneKaZhhsm8RVZ5AGSC5Yh4+cK9R
         YOdX9IuuO/rgtKfoBmdgDNzQDvBBoyKqCWph0VrLS4yMvSyLP35NXv2HdCjI2Er07r0W
         rkVg==
X-Gm-Message-State: APjAAAUbsOsnklGQaD1g4XlIf0/tF4tX2izf7TkmLILWy6I0/QaVInBx
	o7nsv0OVV8VUqdD0KPgYxPgAX7912wLNzAU2NdkG20FvLxn07mQk749wfXRVUiqmUCVTo9vU7tG
	m+PUA+bdSkO3ZCTthhI/FVPqNY2Lh+yzN2aHSkMp2wH59gJugRNC7wFMaWg7CJzQ1ag==
X-Received: by 2002:aa7:9514:: with SMTP id b20mr5923031pfp.223.1565127213971;
        Tue, 06 Aug 2019 14:33:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynttEK9AFGdl1xvLwhaoF+6KshMkUp2RmGpj5gFSoVJbvgFEC9kSz/BufMVuV9HdfNg2Jd
X-Received: by 2002:aa7:9514:: with SMTP id b20mr5922972pfp.223.1565127213133;
        Tue, 06 Aug 2019 14:33:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565127213; cv=none;
        d=google.com; s=arc-20160816;
        b=eKCTAbL2+p1C4BvuZOwn6c/E5hwhhjL66N3HxlV09Tp6pq191s5a4rD8Y+ETOh076q
         do976xz8Bvx9D904uKrAKjG1BE/Rw4EqF7/mCf2RDf0uUIOuPCnqAOV2iVTM21atSmit
         44cs0uOnLSq+A8HZXkYvx7rQsBHVsZ5PHFqHOa4y1YkgfG7J9Yn7jJr6t/AtClU997le
         EEr9J9xg1aGHGR9e3DuY/ubGD91+e6HdrgZruRJoxOQ4ESkVyns++uq76f8yWHG6BD4A
         rZOQjR7Won4i2EjDNnwik4oFfDZKAeJthj6hyzERRCQ4cn/sy3i2rwx6ikzorrnxWi3R
         4uSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=iDYJ7U3nkVgsQNyTJOd+SzW5VeEmpFyQjCRy1sAmQDA=;
        b=Tv2nzdHUsMpXdHGZoDfxAfQdNSARkKiIWbRbhMkkk2q6owKur/uXtUP/LFYE7qMOdX
         XcUGr3y0QKKtNukfxi8guwXRI6R55P4wgfx5AluMrNQreCGGgdoz7FqoyDj2aAbsmGj2
         Z+CDph5k3vn1tMJLPBI4/HFe6kZ3nVakQIQel9DW6zGbYLFnQK6wXzsOD5Uj74jZAzzD
         fxcdbPvegiaa2qtx0bjWGLGKsc+9V6i5eCnebjDLO9yxfy1ihEBGofMfkcNuYlVEp/Wz
         H31k/T1uXarMQEZwBr1mJXF6TvPAQRlWKctBZaxbjcJXP2wS0tIYLWkuu1ySdeCPLTEf
         tzOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IO2DxLoL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u9si32906083pgf.198.2019.08.06.14.33.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 14:33:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IO2DxLoL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C973A21743;
	Tue,  6 Aug 2019 21:33:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565127212;
	bh=TN/yZ7FjGl5BN0jJpt8bZnFuEvxtK5gvDFA4qWawSi8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=IO2DxLoLP2XBTcG6DKhj+LtbEryyetM83hLNmJuHMzuRKI1DKItYI61T3Y9eWyOTY
	 /WdZgZ1Jo2dpipEoIzfC557ZT7OgPUEwDvZfoguzUH6oEDsrLLk91pDrEHNz1nronB
	 shkGE3xB2I3bz6k9TSoERWwkMIU5rIxQeJSWY5CM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Christoph Hellwig <hch@lst.de>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org,
	linux-doc@vger.kernel.org
Subject: [PATCH AUTOSEL 5.2 10/59] mm/hmm: always return EBUSY for invalid ranges in hmm_range_{fault,snapshot}
Date: Tue,  6 Aug 2019 17:32:30 -0400
Message-Id: <20190806213319.19203-10-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806213319.19203-1-sashal@kernel.org>
References: <20190806213319.19203-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Christoph Hellwig <hch@lst.de>

[ Upstream commit 2bcbeaefde2f0384d6ad351c151b1a9fe7791a0a ]

We should not have two different error codes for the same
condition. EAGAIN must be reserved for the FAULT_FLAG_ALLOW_RETRY retry
case and signals to the caller that the mmap_sem has been unlocked.

Use EBUSY for the !valid case so that callers can get the locking right.

Link: https://lore.kernel.org/r/20190724065258.16603-2-hch@lst.de
Tested-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
[jgg: elaborated commit message]
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 Documentation/vm/hmm.rst |  2 +-
 mm/hmm.c                 | 10 ++++------
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index 7cdf7282e0229..65b6c1109cc81 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -231,7 +231,7 @@ respect in order to keep things properly synchronized. The usage pattern is::
       ret = hmm_range_snapshot(&range);
       if (ret) {
           up_read(&mm->mmap_sem);
-          if (ret == -EAGAIN) {
+          if (ret == -EBUSY) {
             /*
              * No need to check hmm_range_wait_until_valid() return value
              * on retry we will get proper error with hmm_range_snapshot()
diff --git a/mm/hmm.c b/mm/hmm.c
index 4c405dfbd2b3d..27dd9a8816272 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -995,7 +995,7 @@ EXPORT_SYMBOL(hmm_range_unregister);
  * @range: range
  * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
  *          permission (for instance asking for write and range is read only),
- *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no valid
+ *          -EBUSY if you need to retry, -EFAULT invalid (ie either no valid
  *          vma or it is illegal to access that range), number of valid pages
  *          in range->pfns[] (from range start address).
  *
@@ -1019,7 +1019,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 	do {
 		/* If range is no longer valid force retry. */
 		if (!range->valid)
-			return -EAGAIN;
+			return -EBUSY;
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
@@ -1117,10 +1117,8 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 
 	do {
 		/* If range is no longer valid force retry. */
-		if (!range->valid) {
-			up_read(&hmm->mm->mmap_sem);
-			return -EAGAIN;
-		}
+		if (!range->valid)
+			return -EBUSY;
 
 		vma = find_vma(hmm->mm, start);
 		if (vma == NULL || (vma->vm_flags & device_vma))
-- 
2.20.1

