Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF098C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 878AE20656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Dfnwj7SR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 878AE20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 701B28E000B; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E8FA8E0009; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43BEC8E0002; Mon, 24 Jun 2019 17:02:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC7B18E0009
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id c190so68070wme.8
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hG9eEbhO9ZvVI+JAJ4Kr5jKBUZBlX9y3IyF9CExVuM8=;
        b=BBaowxP7AnSF33PF5fvcTZr5iinA4QdWFKfvNwjFsGai2rAoj6702zcUSEERhUIItJ
         4VMnusHREgqy9EGGVs/BT9QfSFrHmteJMgbhN9+vavrYPP8uLicH0Qct92dymd7rhV4O
         rb9PXC3KNgmu37M5Fm8/ptzmpTRg+N3LWBUheH2o4kM9NXrd89KAH4Mt1IOcEUrGqJWM
         +Da8+ZrKfrlb0fiDuJbZZJXeDrhBd52V3wr9suk+ykLuA/Pt1uEaarhPcxZaIopjXdTv
         77eTfkGPC51ymHnsZKBOM4Sjm6mF4M8QlG49paN/5+b5OhOvP4ClNr/s0+XGZz1dVoq0
         ONLA==
X-Gm-Message-State: APjAAAU9wz8PrU96JRpDkjhK3ANaNEE+swtG3/8xh2R/qN/i4UfOmJeE
	/xnznvAZmmnPLPQp8Jsq4QT44f+xC17nF7DxQ7UPEnAmXE6kWivm+y41SrQYMOkpaW656OHddfK
	JesTDZSNWokG2NIGrxBat97tdRO/FgUtrJKM6k6Ey2yIq3Q8MFoAXFUc/PoJGQqWWrg==
X-Received: by 2002:a1c:a842:: with SMTP id r63mr17029916wme.117.1561410127456;
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
X-Received: by 2002:a1c:a842:: with SMTP id r63mr17029877wme.117.1561410126497;
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410126; cv=none;
        d=google.com; s=arc-20160816;
        b=EulV0Tu9SmSRIVR/9IMocSWbzn4lLHVODaR3Dlk8yQBkrgg1lLVrdOhO5PJzjXXD5G
         2n4EzpknNdEUoLgQZ30O+OM/dDyyo2Wb9POGR/G+3p6qAzS0ZF6KbLStTmOCdKB0Fz67
         JkKER71KJWXRLl4c8FXVjTZ9K8BeIeInL4LTePmrfjOs+Fso1jPQWkESsCxVQX001WxD
         BuYfQWs2RXUfhJwUfDAorhp0QZXMJEZu5riuo6tW0F0QqdEs4UbgzrHMZKnt+KnY5gQR
         QjZuFAlDoVdL4LGq77YqpzEY23eTP3/5iUWJiceQaQ7nv1l/6ic+U8n1M2yf5whgy+MZ
         5MRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hG9eEbhO9ZvVI+JAJ4Kr5jKBUZBlX9y3IyF9CExVuM8=;
        b=Ypf58MvyPaN54UdYdL1U6f8FIYjhW9neip4Y6LIw54Skx1qTGHTrKyl0tloFrx+nsZ
         G8gC0dJvqUso+nmfXKCZ01AKeIsUSehBIsXURmBVvCjNyGJptI8KuYY7MF4IL1jRgFVn
         sshMPCHVBWneCEnZTdQgNsiwREkIkkj5uj9D2xGYB1mhXdZ4PPIBheUwydwLNjadAtSV
         eD/eDuk7L0XigtwHGLVXZ5MIwRuRGayGEMe33Ke8mOKs1OwbSGAJXL4glaL/pBrY9tGS
         fxQr9WhtLIah++BEhjjzg89xYU4QZFNh8IiiuKe/JfXBvS8oBJR1gmvDUeIuAz5xtYvS
         LkfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Dfnwj7SR;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u17sor7241966wrr.4.2019.06.24.14.02.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Dfnwj7SR;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=hG9eEbhO9ZvVI+JAJ4Kr5jKBUZBlX9y3IyF9CExVuM8=;
        b=Dfnwj7SRwV2PMmn2U0d+WODdclNP+8MKrJJpQxHP3JU1uHDlj7Em+GRbnOVlGf37aZ
         x/iFL81waqsH2R/ZDnogOEsWqssPFpPx6ng2iVzd42Ph8pxRGkGdeHnQFn7WXHxychn7
         qhcCnDDKKA2XJlL0t9jgEmXK5iD+LSA9ISspJalIOTaGOUy2P3iEqUcWHAlRfr10A2Zi
         sVektpaLu8hOSGiRgUg+86mxYZntLzr5JZQnXIkn15UuhOjzFImdCeWJqoAaOquAmGLI
         hpzcweH8Q2CBVObvgPXPT94/km2oYbyVknkNINwL80SwNwAFFuHpdFRRunzkNVq5yivf
         2PaQ==
X-Google-Smtp-Source: APXvYqxAEk4qQsJeqyqINse+yHJkRouINtL91JL0sEIFqMM29cMWXWeCvzOgl6HwO/QEFlzvN+y93Q==
X-Received: by 2002:adf:f186:: with SMTP id h6mr21080937wro.274.1561410126128;
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id b71sm446129wmb.7.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6C-0001M2-OO; Mon, 24 Jun 2019 18:02:00 -0300
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
Subject: [PATCH v4 hmm 01/12] mm/hmm: fix use after free with struct hmm in the mmu notifiers
Date: Mon, 24 Jun 2019 18:00:59 -0300
Message-Id: <20190624210110.5098-2-jgg@ziepe.ca>
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

mmu_notifier_unregister_no_release() is not a fence and the mmu_notifier
system will continue to reference hmm->mn until the srcu grace period
expires.

Resulting in use after free races like this:

         CPU0                                     CPU1
                                               __mmu_notifier_invalidate_range_start()
                                                 srcu_read_lock
                                                 hlist_for_each ()
                                                   // mn == hmm->mn
hmm_mirror_unregister()
  hmm_put()
    hmm_free()
      mmu_notifier_unregister_no_release()
         hlist_del_init_rcu(hmm-mn->list)
			                           mn->ops->invalidate_range_start(mn, range);
					             mm_get_hmm()
      mm->hmm = NULL;
      kfree(hmm)
                                                     mutex_lock(&hmm->lock);

Use SRCU to kfree the hmm memory so that the notifiers can rely on hmm
existing. Get the now-safe hmm struct through container_of and directly
check kref_get_unless_zero to lock it against free.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2:
- Spell 'free' properly (Jerome/Ralph)
v3:
- Have only one clearer comment about kref_get_unless_zero (John)
---
 include/linux/hmm.h |  1 +
 mm/hmm.c            | 23 +++++++++++++++++------
 2 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 7007123842ba76..cb01cf1fa3c08b 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -93,6 +93,7 @@ struct hmm {
 	struct mmu_notifier	mmu_notifier;
 	struct rw_semaphore	mirrors_sem;
 	wait_queue_head_t	wq;
+	struct rcu_head		rcu;
 	long			notifiers;
 	bool			dead;
 };
diff --git a/mm/hmm.c b/mm/hmm.c
index 826816ab237799..f6956d78e3cb25 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -104,6 +104,11 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	return NULL;
 }
 
+static void hmm_free_rcu(struct rcu_head *rcu)
+{
+	kfree(container_of(rcu, struct hmm, rcu));
+}
+
 static void hmm_free(struct kref *kref)
 {
 	struct hmm *hmm = container_of(kref, struct hmm, kref);
@@ -116,7 +121,7 @@ static void hmm_free(struct kref *kref)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 
-	kfree(hmm);
+	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
 }
 
 static inline void hmm_put(struct hmm *hmm)
@@ -144,10 +149,14 @@ void hmm_mm_destroy(struct mm_struct *mm)
 
 static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	struct hmm *hmm = mm_get_hmm(mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
 	struct hmm_range *range;
 
+	/* Bail out if hmm is in the process of being freed */
+	if (!kref_get_unless_zero(&hmm->kref))
+		return;
+
 	/* Report this HMM as dying. */
 	hmm->dead = true;
 
@@ -185,13 +194,14 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
-	struct hmm *hmm = mm_get_hmm(nrange->mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
 	struct hmm_update update;
 	struct hmm_range *range;
 	int ret = 0;
 
-	VM_BUG_ON(!hmm);
+	if (!kref_get_unless_zero(&hmm->kref))
+		return 0;
 
 	update.start = nrange->start;
 	update.end = nrange->end;
@@ -236,9 +246,10 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
-	struct hmm *hmm = mm_get_hmm(nrange->mm);
+	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 
-	VM_BUG_ON(!hmm);
+	if (!kref_get_unless_zero(&hmm->kref))
+		return;
 
 	mutex_lock(&hmm->lock);
 	hmm->notifiers--;
-- 
2.22.0

