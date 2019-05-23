Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A736C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5034121773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="LV2mKDWl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5034121773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8E2D6B027A; Thu, 23 May 2019 11:34:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE62F6B027D; Thu, 23 May 2019 11:34:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EA086B027B; Thu, 23 May 2019 11:34:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7486B027A
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:42 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x68so5756569qka.6
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1UYOs1b1m4kqMa2Hcebr2aPMxfP9lZp6i0AyhspLKIc=;
        b=oSgJdJxDqzT6VTZl9fwiSNBAovSQo+iftNGjPASxLDlBE7Ixg+xlEwtn8dFayyZ59f
         Hm1hom46p+ZZocmTs3Hr2ManxdWSx1gTL1zlx3+phUaonNe1bCsWOQTe1EBNM7fQaoRS
         IIDBiqEXVUvKZa53jZO/kooIKoQqMpzCjgVWzqHcuDThosV9qw6XL9a1dBfCDUfH4yJy
         rAfKaUKtDOQa3+zejUVl27ZYEVF0lAj8j1rBf6tfk3CZUBbwPbmlaIFAEj4zWLzdf/fi
         BU65qEDW79eV+3SNRmgYutVQt/Ue0yraAswxjk+5a4opPJM4NF7/ETvgTEhePQlKdcWr
         Qc4A==
X-Gm-Message-State: APjAAAUoeY+iF2E2ijA8jyma5XHWhtwomM0aD0k11/WD5Bu6x5x45y7w
	6zTzJzfAbOjEqPMdfYUJjYGzLeUwfTQu22E9FVr1Odv+SSCRiOVQcih8FfpaiDIkyPdtsfQG9fW
	UTn3znYY2AXfp/teDqPE94n/0+y779R8qLO8sBMKJU3+7NEnU1UtugH+M3qf3bj3IAw==
X-Received: by 2002:ac8:7313:: with SMTP id x19mr14949946qto.185.1558625682077;
        Thu, 23 May 2019 08:34:42 -0700 (PDT)
X-Received: by 2002:ac8:7313:: with SMTP id x19mr14949859qto.185.1558625681210;
        Thu, 23 May 2019 08:34:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625681; cv=none;
        d=google.com; s=arc-20160816;
        b=D4/s1pP80Kx1BEzzeXRBGtHdIJ9kduc89WFcmMI7Ad4jBgotrMWNzjo2h4LoJE1Flu
         a4b2FzhqgL7wyHcmDSReajRU+sT4oUaZ9yfwxPVTBxvGHceWd310+NGIUw/Ld5bWWQca
         bAlOfEhPLlYyXiAHnfiBz0QZ9JVyQnB3sCzMQakrsDwsXgTvcuaCopSwPpohjCpCPPtF
         Texzt3MiLCML/u4S8vVnCW0AObrATIE0lj5sWHpm7jZjBk3l4FO6oZvwo73zazdiWw4v
         PzmL+bJlkdzh5F/J5IAQVsjf7kJkmenAh2PNzsuaCcZuZdjsf/HBOnfTjJqiOl3OBye/
         VzQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1UYOs1b1m4kqMa2Hcebr2aPMxfP9lZp6i0AyhspLKIc=;
        b=axkUymxY7bAh9f3zFpj4PUbZl78RvDYxGy+zCvpv1W/3VdVMdC27o9i4EbomPT3gfu
         DyTfB7WZFzZfJakU/sHZkYGWvgfGM5lr0oHP1E8IJ8W/Ji2le3oDV5hJj5TlZ2MZEyJy
         z0mPsry1tq/E4eFJMfVwy8bHTzXVDLO7fCtM71CPiew9nmzGkMOl4nOB+4tNagEhJ5T+
         Lpk+K7AVQhNCtfj6YV0QY7/8d5cvPkN0JAMUbJbdTPYQMYDRbB5kGc7wNU6Uknugn3X5
         ML83dricoKfT6XZdoVLILq2VqvH554hKOht52qbWRqq8HVDhKQ+CQZ06mnngrVsb1uYn
         U5Rw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=LV2mKDWl;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10sor22147912qvf.18.2019.05.23.08.34.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=LV2mKDWl;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1UYOs1b1m4kqMa2Hcebr2aPMxfP9lZp6i0AyhspLKIc=;
        b=LV2mKDWl6z86EAVgXFrAKp9hIarl1v5CuBTZz0h3rmucixSlFycPZyRubUjCdCgxLA
         AtK7gRpiNk4P4k7v2McacqOVxWDzHDj1SIjoKD7Ak5PnFKzLI5rh/G1hioQExJlxX/qo
         1aRAcCTHLzYgrrxhfgpVo6ETGueE0agyf8qN0BMT7WPG19ZYlmnMrra6KUdEXX3cEkGG
         BDEIIdpCyEyvvS0QDao0w2v4CajWdmWOKQIXYRhlqugAFNyeY4ReYthg9OXsCqyFabSi
         X0vD7hp+cgUvC8GCSciZF5t9Od7M9Jbnz3qcwMPWB1g/F6XF9aS65QgPOkraL59krHZQ
         OSog==
X-Google-Smtp-Source: APXvYqx4TikclVwMPUpuo7NFKA6Xd+Jq88ZLLLLwtvyEZvxo6rVnUXsWNS36lZk+68Gag43lw4B0JA==
X-Received: by 2002:a0c:ad85:: with SMTP id w5mr8251178qvc.242.1558625680953;
        Thu, 23 May 2019 08:34:40 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id k53sm13877244qtb.65.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjq-0004zT-1F; Thu, 23 May 2019 12:34:38 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 04/11] mm/hmm: Simplify hmm_get_or_create and make it reliable
Date: Thu, 23 May 2019 12:34:29 -0300
Message-Id: <20190523153436.19102-5-jgg@ziepe.ca>
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

As coded this function can false-fail in various racy situations. Make it
reliable by running only under the write side of the mmap_sem and avoiding
the false-failing compare/exchange pattern.

Also make the locking very easy to understand by only ever reading or
writing mm->hmm while holding the write side of the mmap_sem.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 75 ++++++++++++++++++++------------------------------------
 1 file changed, 27 insertions(+), 48 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index e27058e92508b9..ec54be54d81135 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -40,16 +40,6 @@
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
-static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
-{
-	struct hmm *hmm = READ_ONCE(mm->hmm);
-
-	if (hmm && kref_get_unless_zero(&hmm->kref))
-		return hmm;
-
-	return NULL;
-}
-
 /**
  * hmm_get_or_create - register HMM against an mm (HMM internal)
  *
@@ -64,11 +54,20 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
  */
 static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 {
-	struct hmm *hmm = mm_get_hmm(mm);
-	bool cleanup = false;
+	struct hmm *hmm;
 
-	if (hmm)
-		return hmm;
+	lockdep_assert_held_exclusive(mm->mmap_sem);
+
+	if (mm->hmm) {
+		if (kref_get_unless_zero(&mm->hmm->kref))
+			return mm->hmm;
+		/*
+		 * The hmm is being freed by some other CPU and is pending a
+		 * RCU grace period, but this CPU can NULL now it since we
+		 * have the mmap_sem.
+		 */
+		mm->hmm = NULL;
+	}
 
 	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
 	if (!hmm)
@@ -85,54 +84,34 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	hmm->mm = mm;
 	mmgrab(hmm->mm);
 
-	spin_lock(&mm->page_table_lock);
-	if (!mm->hmm)
-		mm->hmm = hmm;
-	else
-		cleanup = true;
-	spin_unlock(&mm->page_table_lock);
-
-	if (cleanup)
-		goto error;
-
-	/*
-	 * We should only get here if hold the mmap_sem in write mode ie on
-	 * registration of first mirror through hmm_mirror_register()
-	 */
 	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
-	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
-		goto error_mm;
+	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
+		kfree(hmm);
+		return NULL;
+	}
 
+	mm->hmm = hmm;
 	return hmm;
-
-error_mm:
-	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
-	spin_unlock(&mm->page_table_lock);
-error:
-	kfree(hmm);
-	return NULL;
 }
 
 static void hmm_fee_rcu(struct rcu_head *rcu)
 {
+	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
+
+	down_write(&hmm->mm->mmap_sem);
+	if (hmm->mm->hmm == hmm)
+		hmm->mm->hmm = NULL;
+	up_write(&hmm->mm->mmap_sem);
+	mmdrop(hmm->mm);
+
 	kfree(container_of(rcu, struct hmm, rcu));
 }
 
 static void hmm_free(struct kref *kref)
 {
 	struct hmm *hmm = container_of(kref, struct hmm, kref);
-	struct mm_struct *mm = hmm->mm;
-
-	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
 
-	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
-	spin_unlock(&mm->page_table_lock);
-
-	mmdrop(hmm->mm);
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
 	mmu_notifier_call_srcu(&hmm->rcu, hmm_fee_rcu);
 }
 
-- 
2.21.0

