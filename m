Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7252CC5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DD102146E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QJEmvFA0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DD102146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5377B8E0006; Mon,  1 Jul 2019 02:20:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49C336B000C; Mon,  1 Jul 2019 02:20:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C6B08E0006; Mon,  1 Jul 2019 02:20:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f207.google.com (mail-pg1-f207.google.com [209.85.215.207])
	by kanga.kvack.org (Postfix) with ESMTP id E059C6B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:44 -0400 (EDT)
Received: by mail-pg1-f207.google.com with SMTP id c18so7034902pgk.2
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6YVs6Gmoqc0otAH1cnOxSKX8bCa6JUPIlHPM9q8lNZk=;
        b=Pgzbwg4VNS29xyaTNaYk+HBXTDBK941ckKGxCkazQe0EbIg5d5KZ5xXgjjTqbgiBr3
         ddIZd5IpE4qy6IACL1Wc+Qct8ToV16TQqNeIk/ehNHaU3jQDOEC31bQA3RFkHpd1ms1U
         /VKGVoTn9Ine58hVu5BLRN1bDAtmlVG3pm+djleTtClLb7onEtZSF6lH1JRxgnRBCXNV
         mKu9TgFubSJ7RUwM20YgFj96E7/1rMpc54Z5UHB1S4ggGT+C71qOmuVl5GrRA/oLD3/m
         ui8QljTb8Fh3myIYK7TjSK7DVCybu9wAuY3EHBWhZ7VgxhVr0FP16m+wPWXacUPZxGky
         0onQ==
X-Gm-Message-State: APjAAAWes1A39pCfjiDKv0BEmr/+Qy54IA/h2QWuDWbn85asskPEiZWL
	O/4wKSiZWBdUbf0dQffw62F5blvtCLX6giCEpDOlTYX34hr3cGPXeclcDa4TAhSTj2xTacMYF11
	LNvfuEUiuu11Q5O/VgrC1IuQP/dlaYH4fIdq6NpQ8OD54ogUqBvqvlyL+WT/7bGI=
X-Received: by 2002:a17:902:aa95:: with SMTP id d21mr26074074plr.185.1561962044545;
        Sun, 30 Jun 2019 23:20:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5HBiHlVt/4RSGDNRPsSgzowluDy6Hj/iOWIjDS9M0AfFyYyRulPQN/SjMDcRpOaX+BpoH
X-Received: by 2002:a17:902:aa95:: with SMTP id d21mr26074020plr.185.1561962043763;
        Sun, 30 Jun 2019 23:20:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962043; cv=none;
        d=google.com; s=arc-20160816;
        b=vtDi/XkJgCoV90j4siUdREh4P9fu/dlu9cxgZnpM8ccQ7f583wKn08mDfR1SGPH3U5
         7Q5m7yqpEBCySOq+sX4YC/OdKa/CXGD/HzG3agvEF5T8oZ3ecQCFgn3OQfosfFFt7fVN
         gW/ttBFT2ZxMIBEXP6REV7BZ0optw5/pRq2NsKZXK/EHgP2pKHsyFUZt1dK2dd76tl/I
         FDbGpFyqFYx8SBf8QlIeBTw2TCkAd808A9YENtGv9+pLZuU/zMHtTU1acHRit0S3AYOn
         7iXsdhWnViEReXcEAtigcNdhTJ9hhjnUTjtrhOhbuFyeAjZ1m79MkUuMETaUhfkFcLe1
         uJlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6YVs6Gmoqc0otAH1cnOxSKX8bCa6JUPIlHPM9q8lNZk=;
        b=H7tDB095tsrTwASclwFrZvLYc980wt2Wj0sVKyz1X/JtWebs4SjLtjK8zXwWM/jK8x
         hm+1j60mGw/MRisF64ibl9RgUmSppNPUwSKR10gwxjDHrBJwk0DNTeD/bTboWwWtdorr
         TKTSTILs9X5tYtQ8IAemj9KoKQdmN7bHu31y3xsjaX7tHyjiQ+6Ei9bdFyz9V+ENmO8A
         r8GdYCZttt7zq7Y9hGpEHMkRcUoyUUS3iXQ1BSFUkLdtVRwSR3PbiJiqpHWModyTRyrn
         mfgCj8zuxjRKTo+9mqI2Uf49pnHjywqZILhCPMqZ3nYwGotCHcaeKj7DTX96IIQN1Miv
         9A+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QJEmvFA0;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x24si9486043pjt.88.2019.06.30.23.20.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QJEmvFA0;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:
	To:From:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=6YVs6Gmoqc0otAH1cnOxSKX8bCa6JUPIlHPM9q8lNZk=; b=QJEmvFA0ZXqEAKaJiHM/HXwFE
	BSDxo8D5Gtm1+W+1HqT50hAN9Vh8w++KZFTiCpoIRCsYVHvPKzZ98vwHICze2dMHHTu3MsptL1C6n
	O7g1pctaJ6PIxWWaR5gx83uyX1fdaWlJFe+20rb2/lZKp2kvGbX/hePtlJ+l1VRy9cv2q0Pl47sDG
	hujb0eQDbUAEB4ydfc/IjZP6MvWHN4HqpeTZB5VBq8IphPMfDVqZdFKemBiZSdAOokusox6fM/e83
	lBP6J/AanqzUQcGlT6hto+xPFgmHndkzmYuFM2q3Nj++ZQg8nkmgRFK6bl0H0cuLbH771Sx7SdPMa
	obMHsTfmg==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpg8-0002w7-AT; Mon, 01 Jul 2019 06:20:40 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH 08/22] mm/hmm: Hold a mmgrab from hmm to mm
Date: Mon,  1 Jul 2019 08:20:06 +0200
Message-Id: <20190701062020.19239-9-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

So long as a struct hmm pointer exists, so should the struct mm it is
linked too. Hold the mmgrab() as soon as a hmm is created, and mmdrop() it
once the hmm refcount goes to zero.

Since mmdrop() (ie a 0 kref on struct mm) is now impossible with a !NULL
mm->hmm delete the hmm_hmm_destroy().

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 include/linux/hmm.h |  3 ---
 kernel/fork.c       |  1 -
 mm/hmm.c            | 22 ++++------------------
 3 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 1fba6979adf4..1d97b6d62c5b 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -577,14 +577,11 @@ static inline int hmm_vma_fault(struct hmm_mirror *mirror,
 }
 
 /* Below are for HMM internal use only! Not to be used by device driver! */
-void hmm_mm_destroy(struct mm_struct *mm);
-
 static inline void hmm_mm_init(struct mm_struct *mm)
 {
 	mm->hmm = NULL;
 }
 #else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 75675b9bf6df..c704c3cedee7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -673,7 +673,6 @@ void __mmdrop(struct mm_struct *mm)
 	WARN_ON_ONCE(mm == current->active_mm);
 	mm_free_pgd(mm);
 	destroy_context(mm);
-	hmm_mm_destroy(mm);
 	mmu_notifier_mm_destroy(mm);
 	check_mm(mm);
 	put_user_ns(mm->user_ns);
diff --git a/mm/hmm.c b/mm/hmm.c
index 22a97ada108b..080b17a2e87e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -20,6 +20,7 @@
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
 #include <linux/memremap.h>
+#include <linux/sched/mm.h>
 #include <linux/jump_label.h>
 #include <linux/dma-mapping.h>
 #include <linux/mmu_notifier.h>
@@ -73,6 +74,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	hmm->notifiers = 0;
 	hmm->dead = false;
 	hmm->mm = mm;
+	mmgrab(hmm->mm);
 
 	spin_lock(&mm->page_table_lock);
 	if (!mm->hmm)
@@ -100,6 +102,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 error:
+	mmdrop(hmm->mm);
 	kfree(hmm);
 	return NULL;
 }
@@ -121,6 +124,7 @@ static void hmm_free(struct kref *kref)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 
+	mmdrop(hmm->mm);
 	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
 }
 
@@ -129,24 +133,6 @@ static inline void hmm_put(struct hmm *hmm)
 	kref_put(&hmm->kref, hmm_free);
 }
 
-void hmm_mm_destroy(struct mm_struct *mm)
-{
-	struct hmm *hmm;
-
-	spin_lock(&mm->page_table_lock);
-	hmm = mm_get_hmm(mm);
-	mm->hmm = NULL;
-	if (hmm) {
-		hmm->mm = NULL;
-		hmm->dead = true;
-		spin_unlock(&mm->page_table_lock);
-		hmm_put(hmm);
-		return;
-	}
-
-	spin_unlock(&mm->page_table_lock);
-}
-
 static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
-- 
2.20.1

