Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50B68C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1411021773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="UscylUyC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1411021773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C089D6B027C; Thu, 23 May 2019 11:34:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8FFC6B0280; Thu, 23 May 2019 11:34:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7FE56B0281; Thu, 23 May 2019 11:34:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3AE6B027C
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:43 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id a12so5783017qkb.3
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DCPTNx8CjmJ5EZR4Q7fEVnlEGDk6XaLfhfnTJM/xZQM=;
        b=P/33Fn9Cdk4MN/r2nAcFOxKXdEg2yN18SPYWaRMc2hL6RhHvlBnogVAnk0bxKixJPC
         h9iP3lU/z70E3r+uaBsrcYS6srhllGAo1MNYYplZZGUZHHYiZr7awJBF0sAZ82QVuBlq
         YUVlgQlE4XYrU7WFCodjL60BCTpx861cFhwQrYbqFjXGc3snHIX70Qtki8L1vvCV8TCI
         GcRttHcyWwOpP2iNBpFu2p8Hm/9idgFfHsOq25XHknalKxQR729JI6yUJ9xHhaNNQ8Zx
         mBqaFae0iCbCgNf7Oq8lfEVBEo7JYa8MeQcY1ceC40DekSRM894LWs3hkO9Pz0vqU6BC
         meKQ==
X-Gm-Message-State: APjAAAU8Jwaj9cz2V0q8hqsi08Eig0agsxeWqEyT1WsFxMf1CvIr5zi8
	nEsx/IdTe2cDF/DjGhwkd4Y9TOKeY0kDPqspotvOfW1QMhHQjE5XM5540nEUgA4j5yO8X6Sk1sx
	5UaS++dDWlR1Lzq4idCv5gPdb4hYpflTDlui2/VkIICCmq0kLuuUqITpGDeah1sJvkQ==
X-Received: by 2002:a0c:984b:: with SMTP id e11mr14604964qvd.174.1558625683155;
        Thu, 23 May 2019 08:34:43 -0700 (PDT)
X-Received: by 2002:a0c:984b:: with SMTP id e11mr14604896qvd.174.1558625682468;
        Thu, 23 May 2019 08:34:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625682; cv=none;
        d=google.com; s=arc-20160816;
        b=izb/5uzrqdIWh9Js+lyUrwXRpQvgGGQG1Xg0mcokNYlbbD3X5AKsV3HTo4zuC9xD1S
         vCV/QkPi11NSyM2RKWF6Jdh9bJkO1LikgHVjXzu7n3rVuUij8m4UuUxcPqFswAW9Dl8z
         r8Sd/MriRmYa9SFwk86+Gx9TZHqdY08OCHSiyCHQ6cf6mhSh/xDd4tMyWsID/8v+T9e0
         cyB8e4sZPBLkObvBIqwGxefaFEK2TQHtSi2VO262ORzCrTQZbDIWwMk8GhC4Dk3BPp6/
         FdEtcOIISeN0fW0I1TJpQC9w5f1HKkqTsJX/r1Nh6+aaoU65PeOnKbrOtr0LmcMo71J4
         unvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=DCPTNx8CjmJ5EZR4Q7fEVnlEGDk6XaLfhfnTJM/xZQM=;
        b=GHi6ZsC3ozU6w0dOVzLPm6bd71Htd/JEkFBDjN1rPle/cDeHCcP4awBR9OahQnuak1
         eFVc8uQiZT/h7jAchwEUH8nTFYsZBLZtlonu+6uskQ2WLAnkqs0jEIu87m+Bvw2gojlE
         8ZV7cg9soeqDsY12wJ8TlR1QmSrxf9EZx4j2k6bVwKCmQGAWv8pTpP0pw1YrbjwR1lDZ
         a4bFczOAK42+KTSpItSHXoXVgVVvUFJCj7aMLVo+VlaQXPy8sC8LeT3eb4Hk0l/wxCet
         atsN83xqmxDLcoRqBC8TGJqpALvpIBvrTVEd9CS31ZhK6IGpH/uAkim++8bqgzc0qix5
         s6rA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UscylUyC;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k31sor35753559qta.27.2019.05.23.08.34.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UscylUyC;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=DCPTNx8CjmJ5EZR4Q7fEVnlEGDk6XaLfhfnTJM/xZQM=;
        b=UscylUyC/LbE+hmwHcoTPty0rCYV8C9l6BH2lAPjaiQ8KCpQHYGVFqbwt9qHDAXr8/
         0k3qTMBhSJf3S42PRZfbrX9UEI/6LGFwoDjvFpmqQlcDDdNyD6dTDJrchuLLNc489jB7
         Y/rZmj+WB81MnhoL6YnHiAQeUu1bwtK84oY4YfOfklhLOiyLAZUJPzOkPy0cRE3mZC87
         G/yVQEsPneUO8B683OG8mQMLHQ79F1URNwp0dMjSHeuCd7ZWZGchFIcBB3L628nY5y71
         wweFi2dQmZAt9lY8+eQpEay8IdpvBecKhqsuVKkK81+YslCO9og21vt7HuyZ/YQvqfFx
         2JDg==
X-Google-Smtp-Source: APXvYqxlKr/De7Ph6kX9Z/iOmfGCPd6u0UkBZ6roajbjLbPCO1l9qWnchzPbSB+6YXzx7C5cfiG9rg==
X-Received: by 2002:ac8:28ac:: with SMTP id i41mr57963862qti.388.1558625682235;
        Thu, 23 May 2019 08:34:42 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id a51sm17403701qta.85.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjq-0004zf-3t; Thu, 23 May 2019 12:34:38 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 06/11] mm/hmm: Remove duplicate condition test before wait_event_timeout
Date: Thu, 23 May 2019 12:34:31 -0300
Message-Id: <20190523153436.19102-7-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
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

Further, based on prior patches, we can no simplify the required condition
test:
 - If range is valid memory then so is range->hmm
 - If hmm_release() has run then range->valid is set to false
   at the same time as dead, so no reason to check both.
 - A valid hmm has a valid hmm->mm.

Also, add the READ_ONCE for range->valid as there is no lock held here.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 include/linux/hmm.h | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 2a7346384ead13..7f3b751fcab1ce 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -216,17 +216,9 @@ static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
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
+	wait_event_timeout(range->hmm->wq, range->valid,
 			   msecs_to_jiffies(timeout));
-	/* Return current valid status just in case we get lucky */
-	return range->valid;
+	return READ_ONCE(range->valid);
 }
 
 /*
-- 
2.21.0

