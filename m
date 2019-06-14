Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF781C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:04:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7295521537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:04:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="d7bdApJp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7295521537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11B098E0002; Thu, 13 Jun 2019 21:04:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CD4D6B026A; Thu, 13 Jun 2019 21:04:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFBA58E0002; Thu, 13 Jun 2019 21:04:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAFC86B0266
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 21:04:04 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n77so671467qke.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 18:04:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8awC9I57ul4Ehs65t7/5PNP0ULl1lssVMkwIyYI5A4o=;
        b=kS/l0YsfmLZWtm68oZ6+WMDf5dyng02KlawbUtgxJJug3ckdr1ijynoBFE/VD6mQUT
         1PD8+Ng+FZB8aZAT/nh10fvqdtKRIYG1+E+bMYgxOu9rZSPL/komw1WWCv8nEkvC6IN5
         jqh++BoRYlILdRMcB36Ryo2R4UtGNljiWpEwIeibPBn2BcXbiGxpwbTA/aoh+NDgUJzn
         CrDBhJCGsxb/BavjTmZewMGE6q27ietoyzhim7qWeX1NNnzfjTaFmCQJb6jLWpobwd/5
         PyBq5n3C3M7ZGjczcvrP+SyjeS+34gUT2C2Kq13jX8QZgSYbOS7rSbDz6pMLhzLeZQtZ
         0kvw==
X-Gm-Message-State: APjAAAWYgRfknQyF+uqZuP36AHAoqsv/18b3GV9gVqEsoxLfBp793u34
	tzC1b5MWTGJuv0pAgsqBBpSrO4hJbYxJrWf35xMvO+1WPOhK57Bl7D+gqR/EPzpU5xgyPsbsaYN
	UzSD+eVqPoOHtP9/iuvYqrIqA5kXKshxVk+SUpuTuCS88864KQS1Rx/kr5cHpzWwbJQ==
X-Received: by 2002:ac8:2cfc:: with SMTP id 57mr76808158qtx.194.1560474244594;
        Thu, 13 Jun 2019 18:04:04 -0700 (PDT)
X-Received: by 2002:ac8:2cfc:: with SMTP id 57mr76808112qtx.194.1560474244015;
        Thu, 13 Jun 2019 18:04:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560474244; cv=none;
        d=google.com; s=arc-20160816;
        b=IIOUgWutTT5df44up0Be/AoeawL+S5ddpxtnhHs4n7q7a4xR5qAUAo2YVv5QxZDMQd
         vx2i5awW/++vbLUoot+utu9TQQ5JNtrDBKtIwSyjRWg4RdUANnuKR8chbSM29HOZbU7R
         2EgIOVnlr7M4tL+rPxy+eRZTUNp4MEKGWDqysO48rfIRzCmWvp6cfc8OZwlVMEJRvqp3
         6duHHOPDQ/2BdZbSKpii/CdnyFq02KTr7kTHhOk1HFWkK8nZlQq84CttP9weQTq0kM4k
         2QsuS81IRgb6HcbfL9TpU8w7qj2HPdqdoT7ZKOYIWuPpwb0/A6QGYf1PoZRbTcg2/Is3
         7G3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8awC9I57ul4Ehs65t7/5PNP0ULl1lssVMkwIyYI5A4o=;
        b=S0+2xZ7zQ/HnGKbEaexCdR52RxAYsp4xyvzql+AWECVrTI3lHiWqAh4Aocc1tFG89X
         QnvDUOzmwGb1uDVfeRqL/Ck9K9hXbbqfdXXQgvS4enq8OKym08jB+6Tim1yyZjqD+HGa
         0n0IwwOZsgCyDaMlFJNUi/sws85OxRsJgQ5xUce5Pht242vfr2dDy3ED2n1Q5ZutJ6zS
         jpDemnBRXjZ1cy7nfAUt5brqGgYWXQysuI+tHN+lfrX6fYkymxFZvg3NiB0EwbfTDhwm
         TOaeUWQvWDMJ0feDPTlz4t+fHofpLzNrqfWn/eJrbtFJIPCXtkh7+LNgEHFMJJmRHkBr
         xQ6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=d7bdApJp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x3sor1094210qkf.22.2019.06.13.18.04.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 18:04:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=d7bdApJp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=8awC9I57ul4Ehs65t7/5PNP0ULl1lssVMkwIyYI5A4o=;
        b=d7bdApJpYLjcmtg3xYRxybVOfz2KS93AC0fzZ1fW4XyHVqwL3OM+gFQej1Ln9qn0DE
         xz1SgRMDXyVjAJ/iauLJS09acThOE7zN7n1V63w1pV4dNLuGqG3b8zAuTr/PFa4b30o3
         fbxyk9MLPAGnMTt8pryVLuPSPpy6jxJkRiEUy1WphR9OOkegUcdTJ5BDKJnvCM2Hh4yW
         n+3I8FhRNhZAxdrmmWxLdwqvz0zePJfQiNoLHWaFUtjNaqK8MbBX+kIYlUs31nGnJC6k
         xIJaEsma2lTn79hWn1/ETECrmvNZum8sX2V88MjB1tGUFrF/ZbWZmNodexZOS8frzOdP
         2fhg==
X-Google-Smtp-Source: APXvYqxXIo3h4su+d4IRSr2dLrSynk5yL3SLa1bT6tdawPdbOlK3JH39LvD6Y28mBndOcMefOVTFTQ==
X-Received: by 2002:a05:620a:5ad:: with SMTP id q13mr19545434qkq.154.1560474243703;
        Thu, 13 Jun 2019 18:04:03 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id g53sm699466qtk.65.2019.06.13.18.04.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 18:04:03 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKs-0005KW-2y; Thu, 13 Jun 2019 21:44:54 -0300
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
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH v3 hmm 11/12] mm/hmm: Remove confusing comment and logic from hmm_release
Date: Thu, 13 Jun 2019 21:44:49 -0300
Message-Id: <20190614004450.20252-12-jgg@ziepe.ca>
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

hmm_release() is called exactly once per hmm. ops->release() cannot
accidentally trigger any action that would recurse back onto
hmm->mirrors_sem.

This fixes a use after-free race of the form:

       CPU0                                   CPU1
                                           hmm_release()
                                             up_write(&hmm->mirrors_sem);
 hmm_mirror_unregister(mirror)
  down_write(&hmm->mirrors_sem);
  up_write(&hmm->mirrors_sem);
  kfree(mirror)
                                             mirror->ops->release(mirror)

The only user we have today for ops->release is an empty function, so this
is unambiguously safe.

As a consequence of plugging this race drivers are not allowed to
register/unregister mirrors from within a release op.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 28 +++++++++-------------------
 1 file changed, 9 insertions(+), 19 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 26af511cbdd075..c0d43302fd6b2f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -137,26 +137,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	WARN_ON(!list_empty(&hmm->ranges));
 	mutex_unlock(&hmm->lock);
 
-	down_write(&hmm->mirrors_sem);
-	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
-					  list);
-	while (mirror) {
-		list_del_init(&mirror->list);
-		if (mirror->ops->release) {
-			/*
-			 * Drop mirrors_sem so the release callback can wait
-			 * on any pending work that might itself trigger a
-			 * mmu_notifier callback and thus would deadlock with
-			 * us.
-			 */
-			up_write(&hmm->mirrors_sem);
+	down_read(&hmm->mirrors_sem);
+	list_for_each_entry(mirror, &hmm->mirrors, list) {
+		/*
+		 * Note: The driver is not allowed to trigger
+		 * hmm_mirror_unregister() from this thread.
+		 */
+		if (mirror->ops->release)
 			mirror->ops->release(mirror);
-			down_write(&hmm->mirrors_sem);
-		}
-		mirror = list_first_entry_or_null(&hmm->mirrors,
-						  struct hmm_mirror, list);
 	}
-	up_write(&hmm->mirrors_sem);
+	up_read(&hmm->mirrors_sem);
 
 	hmm_put(hmm);
 }
@@ -286,7 +276,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 	struct hmm *hmm = mirror->hmm;
 
 	down_write(&hmm->mirrors_sem);
-	list_del_init(&mirror->list);
+	list_del(&mirror->list);
 	up_write(&hmm->mirrors_sem);
 	hmm_put(hmm);
 	memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
-- 
2.21.0

