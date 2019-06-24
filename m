Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13150C4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDAE220656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="QHyBSbia"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDAE220656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3B878E0007; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC5428E0002; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB1048E0007; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91D608E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b6so6885759wrp.21
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5QRiWs/DQbjPzNp3Mmcykk+AEBHTNlfm8mEd5w/KsEk=;
        b=UZwzdgmmtXWmI+7RIsx1ijbxY8slI96URmOwe+N9Geml6Wywtr+s3IhzN3ydELyAha
         1Qe8sEXkZduS6SoZoJv10tPudEesIZWFsixvHDnYjw4wdBYaJoeC9hEuwSojtRVeMHoE
         QH6rMSOzzgy5wShOf20AEhvpAP2wUkYcudHi5/X9AP44idaDGQl6R6k/8W+mZrr6b2iV
         2kjK1fBVZ193G6yvlZkxIZLpruaEDnxSbpC+3SaVIUuee0yRlhaWOTI0I4gG/XwEoswm
         LxMrLEFFVVurQmARgPwzLgqhkJbrFzibTsw1UwjDbA0Ry1C8L65Sq5THgsEaHxQGuyap
         27hw==
X-Gm-Message-State: APjAAAUMZO/TKhMxT0G0NDGAf3/drZblj3CWM8mtuUh7ZU/Aku75/jtP
	pK4NgGbQqhduyQKKAVEoAx6a1Nb4jP0iPTU5oCpDromC9y1CKEzaMeArnl+FILI1nK1Gbs0TMTJ
	UaDFO87FhhZw/vKCeVgf1pUz2Os0VMEOuxY6jbUTCaNJ8yZ4WxN2xErRhw5fZ2bYpyA==
X-Received: by 2002:a05:600c:114f:: with SMTP id z15mr16868279wmz.131.1561410127148;
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
X-Received: by 2002:a05:600c:114f:: with SMTP id z15mr16868246wmz.131.1561410126202;
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410126; cv=none;
        d=google.com; s=arc-20160816;
        b=nBtQ2qQhLdQ3jHuLvW3RpYhtZ22Xy2hKYXmbJY1S21/FzD/dOifSwFdNy9ttJX/H8A
         nEMEW4HFHGmWPemdDJFbS+I+jvCgHO8Z+12tp4YtlhYrMKQoXf3QjCLFRtdRIwWbIs0/
         iI0MsCYnsIiJqSMOT/eu5K+GMYHTFzSIEYOPEP9qnjXNfjo9wfnMaq6PWabFgNRSuz+a
         xfSlcl/T2izZmAYBuzA8DWifgkRJnclgHU5sNpM6Lm+LnG66QP2TNyGuXGtZF7vCijKc
         LOqWtQ6+f8ZbCAr3QsdtBCMy96zshLVIOpzxI/KTcAByeuo+BTyQgvQXhb/Rh/J778sK
         r4Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5QRiWs/DQbjPzNp3Mmcykk+AEBHTNlfm8mEd5w/KsEk=;
        b=uBFjwjbef+nYtoXH2zKuK8Di9x9VIwQQXGGb8LZVS9STTGrTb+1Bp2n440+YbE0Kbk
         DK94wSUpPF+/N0a3/fcBIvhVwCxt47A7JgfQCs7YlPdq1XH5+QkzIQ3yP+gQgV3Sk6TR
         NidcF98C47VML8cfT+zNsZa3j8oN7rXurs/LxNcH/XDdq2JaGHkSb8MG3Fax5b5DCEMf
         BqPPDXrYVv0LBDpYWNdCtnvuwicwRlgmJz29xuSra27ITx+YxOUGbTMjissnEy/1kYZU
         tMIPPUrno43z13PuglUpO2K9Fpn7XAvrkgDncaPkg1LRTUR3k8+zsGhe0kegcsRpq2GS
         p9iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=QHyBSbia;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b202sor368630wmd.20.2019.06.24.14.02.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=QHyBSbia;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=5QRiWs/DQbjPzNp3Mmcykk+AEBHTNlfm8mEd5w/KsEk=;
        b=QHyBSbiaOkKGu/MxsSMUiXu2VTSCzVLYMxWwINOB/2Q6vPwGK/3fpuJ8DeqVV/RHuy
         PlWt0PKGF2DxILefQKepmvvAs9zfo0sJ/4JuHPb0QB5wuqyBLoHp42kHvsETulBVPEc1
         nqIqqhYShDyfMHcp9pog0fds+dL+EL98KHWdrqc1jzmg4ngIMYHE16t7uPvX3+VkB4vI
         bsZkTMXkFYDGzt6JPUksZtjhk0vmx/AJejbnSzHMAh8/EfzJ0wiL46ukX5ePRnoNGE/1
         nJ7mvYjHCVInsefIPkoIGcN7Hka7i1yS3Hv0kHKhgEn2UJ3p9gHquSgDjpsddvKgWt95
         ZSwg==
X-Google-Smtp-Source: APXvYqyUO9q1BVm7bVuWFkSD3xUfLwXJTWFUz+E3q3pTmFAgmdWwYSJRzm7jgl6xIMlY4/wE2Sy8yg==
X-Received: by 2002:a1c:2311:: with SMTP id j17mr9036341wmj.84.1561410125783;
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id d5sm10927937wrc.17.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6C-0001MH-Rm; Mon, 24 Jun 2019 18:02:00 -0300
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
Subject: [PATCH v4 hmm 04/12] mm/hmm: Simplify hmm_get_or_create and make it reliable
Date: Mon, 24 Jun 2019 18:01:02 -0300
Message-Id: <20190624210110.5098-5-jgg@ziepe.ca>
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

As coded this function can false-fail in various racy situations. Make it
reliable and simpler by running under the write side of the mmap_sem and
avoiding the false-failing compare/exchange pattern. Due to the mmap_sem
this no longer has to avoid racing with a 2nd parallel
hmm_get_or_create().

Unfortunately this still has to use the page_table_lock as the
non-sleeping lock protecting mm->hmm, since the contexts where we free the
hmm are incompatible with mmap_sem.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2:
- Fix error unwind of mmgrab (Jerome)
- Use hmm local instead of 2nd container_of (Jerome)
v3:
- Can't use mmap_sem in the SRCU callback, keep using the
  page_table_lock (Philip)
v4:
- Put the mm->hmm = NULL in the kref release, reduce LOC
  in hmm_get_or_create() (Christoph)
---
 mm/hmm.c | 77 ++++++++++++++++++++++----------------------------------
 1 file changed, 30 insertions(+), 47 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 080b17a2e87e2d..0423f4ca3a7e09 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -31,16 +31,6 @@
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
@@ -55,11 +45,16 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
  */
 static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 {
-	struct hmm *hmm = mm_get_hmm(mm);
-	bool cleanup = false;
+	struct hmm *hmm;
+
+	lockdep_assert_held_exclusive(&mm->mmap_sem);
 
-	if (hmm)
-		return hmm;
+	/* Abuse the page_table_lock to also protect mm->hmm. */
+	spin_lock(&mm->page_table_lock);
+	hmm = mm->hmm;
+	if (mm->hmm && kref_get_unless_zero(&mm->hmm->kref))
+		goto out_unlock;
+	spin_unlock(&mm->page_table_lock);
 
 	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
 	if (!hmm)
@@ -74,57 +69,45 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	hmm->notifiers = 0;
 	hmm->dead = false;
 	hmm->mm = mm;
-	mmgrab(hmm->mm);
 
-	spin_lock(&mm->page_table_lock);
-	if (!mm->hmm)
-		mm->hmm = hmm;
-	else
-		cleanup = true;
-	spin_unlock(&mm->page_table_lock);
+	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
+	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
+		kfree(hmm);
+		return NULL;
+	}
 
-	if (cleanup)
-		goto error;
+	mmgrab(hmm->mm);
 
 	/*
-	 * We should only get here if hold the mmap_sem in write mode ie on
-	 * registration of first mirror through hmm_mirror_register()
+	 * We hold the exclusive mmap_sem here so we know that mm->hmm is
+	 * still NULL or 0 kref, and is safe to update.
 	 */
-	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
-	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
-		goto error_mm;
-
-	return hmm;
-
-error_mm:
 	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
+	mm->hmm = hmm;
+
+out_unlock:
 	spin_unlock(&mm->page_table_lock);
-error:
-	mmdrop(hmm->mm);
-	kfree(hmm);
-	return NULL;
+	return hmm;
 }
 
 static void hmm_free_rcu(struct rcu_head *rcu)
 {
-	kfree(container_of(rcu, struct hmm, rcu));
+	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
+
+	mmdrop(hmm->mm);
+	kfree(hmm);
 }
 
 static void hmm_free(struct kref *kref)
 {
 	struct hmm *hmm = container_of(kref, struct hmm, kref);
-	struct mm_struct *mm = hmm->mm;
 
-	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
+	spin_lock(&hmm->mm->page_table_lock);
+	if (hmm->mm->hmm == hmm)
+		hmm->mm->hmm = NULL;
+	spin_unlock(&hmm->mm->page_table_lock);
 
-	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
-	spin_unlock(&mm->page_table_lock);
-
-	mmdrop(hmm->mm);
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
 	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
 }
 
-- 
2.22.0

