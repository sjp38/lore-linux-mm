Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33875C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:35:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0BD721773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:35:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="afbPPYk9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0BD721773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37ADE6B0287; Thu, 23 May 2019 11:34:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32C276B028A; Thu, 23 May 2019 11:34:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F6276B028B; Thu, 23 May 2019 11:34:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id ECF7E6B028A
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:45 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x68so5756740qka.6
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ncjASLGlHsj22sNocZs8CG3omWgokVRQnVtcSgoF4Do=;
        b=fHbCmyIqSsm5quP4FAkeHrTCyy+36/XVeelUxusRN7RfiCNyKsxtf+bTF1eq+AUili
         582uGNlCEczo9UppxYNAVaXSss5j2QRXWNdGBMaZy/G0lA3+fgkmwO870BpjoC3aa8na
         vpSpfXwbsU6PZJr5krElRT8a0ibr32SudmzLIhayCrCwgDVEXu2Nnk3WWl3cxfScuHHP
         WOwTgNtXZjeGJ/DhPuSxjear1RIUQHwg/XWGlnvePjX7S3ykAfuJmJmuqmU6dIwR6uL+
         4jV5ci6G7mLMW/U6S82SBOAfKrJeqETFNXy+/8Y4Q4f+DHbvQDf35WEsTRjgCAGVqGxN
         V+zQ==
X-Gm-Message-State: APjAAAU0rt8rOPKXo+qAJJltVEekHNz6e5h2ucJzUPnLToa36oqiRvQp
	HK/peO2an/O42t4NGU6jo3fVE5eQB230LvQwM1L0Hru46+6x/2nL4F83r1O11dDopf97AgrrN6r
	14aT0UuEY2OkXKLIvIT+Q5w3QkhaAdKlvtZPybdnCV9BRJFJJQqREAyEDdqauQPKcQw==
X-Received: by 2002:a05:620a:1362:: with SMTP id d2mr2676345qkl.40.1558625685700;
        Thu, 23 May 2019 08:34:45 -0700 (PDT)
X-Received: by 2002:a05:620a:1362:: with SMTP id d2mr2676285qkl.40.1558625684968;
        Thu, 23 May 2019 08:34:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625684; cv=none;
        d=google.com; s=arc-20160816;
        b=pMJHXcIKM7+oNeDKHzQvqckMYj8MAbzaTDOhZZRTcXXsvFSY+929Z0BL78FQhhxUQS
         HFmHQjVzwJN65DTDNY8Hd+g/moMMZ1ynpg65aZkIBxGsX0gBiA03h6e6IAMQvkRk4BSK
         nMORQIB520vahh7jtdx2+fHz62Qu0GU/cQQyqAtl7IjssQcsPejdD2IG762C8H5CMqfI
         B4v4PI7mPnvyDpKF0NAbi9hnTCvRFY2Fnlg6wSa0J5S5DPNF4IZrZEhilFwuUKes0foq
         G50nwYWxUoLnBSSs+AVbHLTiQTBmm6VcsrpF7jQ+EZWtD2gW2TlyakI806VQ202gbMtt
         fOgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ncjASLGlHsj22sNocZs8CG3omWgokVRQnVtcSgoF4Do=;
        b=tV9swozjP46Z0k0SL+FzLCnhmei2V4Q5KTMZM4Ogbp5Nnyy1BrvJNljm47jDibO4RF
         5RSKhI4H3swMXNZiD9XP1QhYNljnL9Asmrq8C+SkqWjQ4RiWVbyapBm/hJuJAd1ZZiAC
         DXGJQyu25uDSTv5WcsUvGcCei88a/I90/wbLkCYfxqgd9id6uah8hzDcllylolDR94oe
         GfmCBQtRx6DlbO8AB82lOynyf2VLpgCLuAUI/NwlUadavRjFB+EJM1qZEaYeoHEasMeH
         25WUlDArxx3A5i35HEOuXnuxJ9VUOFWbrsvkm4i35Gz9Mi7TqWt1uV0SgywRCuqro0Np
         ChIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=afbPPYk9;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u23sor18808426qtk.6.2019.05.23.08.34.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=afbPPYk9;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ncjASLGlHsj22sNocZs8CG3omWgokVRQnVtcSgoF4Do=;
        b=afbPPYk9gBj4SFUfupZZE4bCnA6gDZMhgy4+OgszgUI8N1f+l4L4QbGabEscrkzZio
         04dKwEZTY1ZZpMvvyuXHs/Zur4eepQiD1W+lZazrUaj4nn7/t4j1M+InHHRzuagZXcr8
         KKv520d1DP6I7X4/cfCmplGSWFB7qHZa/I9bvrzKq1ogoyjdw+q2JJfFWS8aPCq+8IpA
         qzget2M+jxJ0rPEHJZXgXf8cijcYlCmoGK6a41MkyHSp5f24D9rssOEcYPsQesCbV+n0
         ERLiPP7EiRneYQ5/ivup+VNYTXqW/BHKDFa3+vKYdV9zuvfZzb8dXYO7o2N+FXeqLQBm
         RkYA==
X-Google-Smtp-Source: APXvYqxAz8IO0yDJzMp5j01V0l+mHdFZgyUtfceu0FECv0lekCVZ9tSBPQKcxg2vezV1TSB8NGjW9g==
X-Received: by 2002:ac8:18b8:: with SMTP id s53mr76217225qtj.232.1558625684721;
        Thu, 23 May 2019 08:34:44 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id g65sm2686228qkb.1.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjq-0004zl-5F; Thu, 23 May 2019 12:34:38 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 07/11] mm/hmm: Delete hmm_mirror_mm_is_alive()
Date: Thu, 23 May 2019 12:34:32 -0300
Message-Id: <20190523153436.19102-8-jgg@ziepe.ca>
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

Now that it is clarified that callers to hmm_range_dma_map() must hold
the mmap_sem and thus the mmget, there is no purpose for this function.

It was the last user of dead, so delete it as well.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 include/linux/hmm.h | 27 ---------------------------
 mm/hmm.c            |  4 ----
 2 files changed, 31 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 7f3b751fcab1ce..6671643703a7ab 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -91,7 +91,6 @@
  * @mirrors_sem: read/write semaphore protecting the mirrors list
  * @wq: wait queue for user waiting on a range invalidation
  * @notifiers: count of active mmu notifiers
- * @dead: is the mm dead ?
  */
 struct hmm {
 	struct mm_struct	*mm;
@@ -104,7 +103,6 @@ struct hmm {
 	wait_queue_head_t	wq;
 	struct rcu_head		rcu;
 	long			notifiers;
-	bool			dead;
 };
 
 /*
@@ -466,31 +464,6 @@ struct hmm_mirror {
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
 
-/*
- * hmm_mirror_mm_is_alive() - test if mm is still alive
- * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
- * Returns: false if the mm is dead, true otherwise
- *
- * This is an optimization it will not accurately always return -EINVAL if the
- * mm is dead ie there can be false negative (process is being kill but HMM is
- * not yet inform of that). It is only intented to be use to optimize out case
- * where driver is about to do something time consuming and it would be better
- * to skip it if the mm is dead.
- */
-static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
-{
-	struct mm_struct *mm;
-
-	if (!mirror || !mirror->hmm)
-		return false;
-	mm = READ_ONCE(mirror->hmm->mm);
-	if (mirror->hmm->dead || !mm)
-		return false;
-
-	return true;
-}
-
-
 /*
  * Please see Documentation/vm/hmm.rst for how to use the range API.
  */
diff --git a/mm/hmm.c b/mm/hmm.c
index d97ec293336ea5..2695925c0c5927 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -80,7 +80,6 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	mutex_init(&hmm->lock);
 	kref_init(&hmm->kref);
 	hmm->notifiers = 0;
-	hmm->dead = false;
 	hmm->mm = mm;
 	mmgrab(hmm->mm);
 
@@ -130,9 +129,6 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	if (!kref_get_unless_zero(&hmm->kref))
 		return;
 
-	/* Report this HMM as dying. */
-	hmm->dead = true;
-
 	/* Wake-up everyone waiting on any range. */
 	mutex_lock(&hmm->lock);
 	list_for_each_entry(range, &hmm->ranges, list) {
-- 
2.21.0

