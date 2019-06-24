Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74309C4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CD2A20656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="oRmOk0Zj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CD2A20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A583D8E0002; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0BB68E0009; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FFCE8E0002; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 120018E000A
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id l11so6937842wrv.9
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Xvvvfm/iICt6EAx3A7hygYXF1jRJFUeMrawdTwOi4ns=;
        b=VE9wrLonYLVYhGcNza3Xd82/AOSVblYF41ASbAN+88YceWGY81mY55GRWBaXrYixlA
         oAoP0qJT01H5svtj22PQxUH29fgatQM91XpEQ5tLV7TMGpCutrwaT5CXKD1qWWKDW2+8
         PO3FYeat94KmVvOWDZMpoHzNlMvf7DvNDkeYyqh1vzFaOdd5s8PisgjoKcz4M/DtWtoF
         Rg7OCd+LLGT2um6e4u58vKyiJ+xnUhGmsubgeiM55dhg0QHlhKh/z3NEPQ4G5w3ASW5L
         bDcHXXwrSF1II6+mpxmXCCY9Xo7CuKrNZJGQr6UXlTFs6NyfR9EzM6a+JEo32AKTJ3NP
         nGWA==
X-Gm-Message-State: APjAAAV4+fuYwsB7MPMB7m997dxRpO7EYlsPeE/Z4jTDZ3ZnY4Js7t2r
	PzFFo75ms1zFWmI8nfu/7tVJonUGv8DNAnk/9oO41vGvtZtL371RRvSFbLmmZmM/joYxXFtKn7E
	L4c0yr1xN6z0RMMJXbvK+/ikNGVP+oFI4r15jlkiP4U0wF0hyzpHFl2jpL81C9NC+ag==
X-Received: by 2002:adf:c654:: with SMTP id u20mr26984336wrg.271.1561410127605;
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
X-Received: by 2002:adf:c654:: with SMTP id u20mr26984304wrg.271.1561410126747;
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410126; cv=none;
        d=google.com; s=arc-20160816;
        b=nAUCL1Pi8cWgQGNLVtLXRovrmp8/kuBH4PI6gPUK5G8E0fvLkdHWy4enaMrCSsIHqc
         tbRSGsfxUtsjwt9Arxo2X/PkWq/ykAfNEECBgqDyyRV2fFKRMXfWbS1HlxTvnrhOMOWn
         2BO3q6Eq7f+5itZmj4yYzmvDv/BcHA/hS3PnjHKME4mGupzjP0T770bAmQHweTh38jh3
         pv00G1zwFXloIJcfcE+xNnruNIRkwD5j+DW0dbZpz9TeQDiIXSzFXlXqBXUExEPzblLO
         I6V7Prv/0ggSrCkMiUhpH7FaqipXFOtsgzQo1e4YW39itde88T5800kIhzLoo8NLuCPa
         YG7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Xvvvfm/iICt6EAx3A7hygYXF1jRJFUeMrawdTwOi4ns=;
        b=TrffeMSxZJg+kGWWfQTb1NZBJvb59819VWvQoXG0gxYk2sQrPZ7hactsLskMjb+lS1
         5rw7oYcxAi2SXFd97A5d6K0PjwBeVt2Y57FMIblBqtlHyV9RMay9xfTOnX1ZnZ1M7+UI
         p7glr7xQdWHgaeeBFR5P1jM9bSdxVr4tTn1dyp3SefMPJ8Kt7rlgV+N4LCtFrCzhb7k3
         +G4X5Lxm6Ata6zFO6m2gJz09il6k8itFpP1TDrdnUKqImEICtFg4vm4Q2m60TjylhJil
         vHpELJiSAg6DDsykNQ6YHBmSmSJUx/6BFZW/K1VUY62RKZQkbsCMAqlrKrGKzI6ocHly
         3T2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=oRmOk0Zj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t16sor7104312wrn.0.2019.06.24.14.02.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=oRmOk0Zj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Xvvvfm/iICt6EAx3A7hygYXF1jRJFUeMrawdTwOi4ns=;
        b=oRmOk0Zjj6i+pMHvCNnVsb1wjfONs2JBTQnEE3rglcDcUQoG84gXWTDhq9ll76MAqu
         NbvHm5LXP2Mk44izNVB3slQr8uyWefSSkQB31EfSp+uwq/HLZh/BdNDnY90d603FucOz
         AC8Ce8Oh4o0dEDF5pq+h9XhIOGQHW9OrQOCgPMR6XEU0ePQEDlF6JmUB9j6v51IImlni
         0CRtVjdLLAq8G7uZWcwboxDMUZIuPWUPunZLZVkEDI1o2Eb0mtkYKg08tRTwS/QFWzk2
         3v3z9wVq/LNXCzMnbVfsewXyPw+o1BeCYz8bMIx9Jd6EvXRVTZY/u0AkUUg08yGiPfXO
         xJgA==
X-Google-Smtp-Source: APXvYqxEB08pD22xw7z431fz4zoGHVSBNwMRdaiB40BUYEvmuPcR/sYQyqDcLZPR3XganfuFLHNJMQ==
X-Received: by 2002:a5d:5283:: with SMTP id c3mr28666603wrv.268.1561410126403;
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id j7sm16820277wru.54.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6C-0001MM-Sw; Mon, 24 Jun 2019 18:02:00 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v4 hmm 05/12] mm/hmm: Remove duplicate condition test before wait_event_timeout
Date: Mon, 24 Jun 2019 18:01:03 -0300
Message-Id: <20190624210110.5098-6-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190624210110.5098-1-jgg@ziepe.ca>
References: <20190624210110.5098-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

The wait_event_timeout macro already tests the condition as its first
action, so there is no reason to open code another version of this, all
that does is skip the might_sleep() debugging in common cases, which is
not helpful.

Further, based on prior patches, we can now simplify the required condition
test:
 - If range is valid memory then so is range->hmm
 - If hmm_release() has run then range->valid is set to false
   at the same time as dead, so no reason to check both.
 - A valid hmm has a valid hmm->mm.

Allowing the return value of wait_event_timeout() (along with its internal
barriers) to compute the result of the function.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v3
- Simplify the wait_event_timeout to not check valid
---
 include/linux/hmm.h | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 1d97b6d62c5bcf..26e7c477490c4e 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -209,17 +209,8 @@ static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
 static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
 					      unsigned long timeout)
 {
-	/* Check if mm is dead ? */
-	if (range->hmm == NULL || range->hmm->dead || range->hmm->mm == NULL) {
-		range->valid = false;
-		return false;
-	}
-	if (range->valid)
-		return true;
-	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
-			   msecs_to_jiffies(timeout));
-	/* Return current valid status just in case we get lucky */
-	return range->valid;
+	return wait_event_timeout(range->hmm->wq, range->valid,
+				  msecs_to_jiffies(timeout)) != 0;
 }
 
 /*
-- 
2.22.0

