Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAF5CC31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70C2F20850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Z24AVcLX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70C2F20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B51ED6B026C; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A53816B0272; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 747C36B026F; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 39EA36B026D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n77so636166qke.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4TWMeUG5gYhJoHE/SGg4kXx8gam66v1Nu5XHiuhyFtI=;
        b=aAGVhIgz+IcWOGL0epYA1EkItPBK52iyXTxof7vEkm/YyCOLuJBIexio2ODmMoF9zW
         ktRc1lga8sQna/vcGfIsXoOPYSBfoXZFSzz7vQa3A1zMzOV7oPUDXKcqMRf1CbQgBxnl
         g9oHg/ToVjM4JB4TMdF3RQr6gKjug9nP7WD+bbruUl7qsxJND0t1w910lm0fxaVmM7Ae
         wTfaudTSkKMNfRT7pq2AIjSEwR0+VXOeSkTkcOXQD+ruR/NDka4Go4LPq71Uzx/uWFuk
         R3Ch3ssb5zRbXGSXiCMJmZMrvRdc/xiprR1bZ9W12ihwB3amgj+Btn2giZG+tgH/PMFk
         2XNw==
X-Gm-Message-State: APjAAAX+DPRB/EtdtrjOj+xT+6Kkrh/Mx0GrtakXGorrAd5PzYLkhjnu
	A7051rJYHKjagIlYDXL7sE6GIKZPIsRSGzauHbpc1aG69YyPgsuHOwZxi4hdbl1JTZvkN/yzMbJ
	b6xQjSfLjaBR0YIzSZbgKk/+jXfpolOFqQXl7CqSFuq+hMq6w19k28yNXTKqEMMdfVw==
X-Received: by 2002:a37:64cb:: with SMTP id y194mr64936778qkb.197.1560473098006;
        Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
X-Received: by 2002:a37:64cb:: with SMTP id y194mr64936750qkb.197.1560473097399;
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473097; cv=none;
        d=google.com; s=arc-20160816;
        b=l0Ekqo1oK1qcwKEzJjUE399g0kFuYGJVnU7fr2ibbSFKqpSgOE7fiVFjeY3LxmKJx4
         tWAb/waPFCeLa4ETt+/s7rZNDI4fbOuujN8oZ/RfAi+Bi6sEaJecNotBTsjZZwlkLDwk
         5hl8ldQ839QKHnuP1oR8yngMsVbxbBkY9cg7ggenlSbeewOstDyfwV9sPCGSksKgqhLX
         Oeref9xHYkobFXPrTHC+S0uUNwTa2UsfJ/TM2fai9/2qo3JVMOi48oBPMzlEuR8noek6
         HDfDjAOwzeXMHDT77BNO6+9Y64oMvT0Rl1XydU8Fo/vyRdub8ZzYQKUQotib752hMRUA
         dcIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4TWMeUG5gYhJoHE/SGg4kXx8gam66v1Nu5XHiuhyFtI=;
        b=ydbVizKxLN/HPtCYqVwFJLqlO+LehaqT555B6S0jdyG3eeu6/Li3Rf9SzN+DESGVP3
         PnMGPbm/jo3PWVpmMLYWTRDu9DJgsbzK/W3WzyEe81F9eEIFn/kYEWqB5+n47AHZTh0o
         u9uTfFBOkcDjIZK7KkX9fclfeQk+9UuBwBtZVJqmXMiCLcc0eyjqTMfCGk9bMF4tlPw0
         61gBsX2xyOA0IsvWGayfKDg4pyaY/k+Y/9FMVN7Spu0EALRrem83HA3P/0JaR7u3Wb28
         B18mvY67dDxska1vCC/Z8E6BvLLVtBqft+DkmM3dkppZps5dIEDc7YaqkYSjBlpP0xFZ
         0uiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Z24AVcLX;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z26sor2385488qta.30.2019.06.13.17.44.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Z24AVcLX;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=4TWMeUG5gYhJoHE/SGg4kXx8gam66v1Nu5XHiuhyFtI=;
        b=Z24AVcLXtS9fjUgk7s4+KXtzjE1aMT2PBcEb07xw67SglUSd3OzuNg62oNcMTOdCCO
         tuaeQKOzQsp5HbqBLHd8K7YGNauURpRUKgNdhJfNe96/SZel8ZB2rP2x8NzbogFeDlIr
         +yZSWZUazmveTBDnu7n84ZdABGyatv0J9NLBsDYYL9OXjABLlvao0fEL2KwxuHwW8PZp
         /+vezcHxEC4oBD4j7w/eFErEFwQXwCtbfqwi4hyrQWWNYY2o77J7tHghIjFCTg3ZdCds
         UZ2dBkr9KXBNBNjxQciAe4xHvlePPQaKw/4isjgNYaLJ9hRnWkLaIVZIqWtqd6dVzykM
         qQrQ==
X-Google-Smtp-Source: APXvYqwqGlFwoXSFqE9WKQZMugVvrqSYWsVu7EvQI2b+rocz25JrwetUsVc8pOMWgciELT4SKnPuKA==
X-Received: by 2002:ac8:3014:: with SMTP id f20mr78276048qte.69.1560473097168;
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id g53sm678695qtk.65.2019.06.13.17.44.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKr-0005Jw-Px; Thu, 13 Jun 2019 21:44:53 -0300
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
	Jason Gunthorpe <jgg@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH v3 hmm 05/12] mm/hmm: Remove duplicate condition test before wait_event_timeout
Date: Thu, 13 Jun 2019 21:44:43 -0300
Message-Id: <20190614004450.20252-6-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190614004450.20252-1-jgg@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
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
2.21.0

