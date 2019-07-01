Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16E2FC5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0FB52146E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gSbk2W6E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0FB52146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 907C38E0007; Mon,  1 Jul 2019 02:20:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 892516B000C; Mon,  1 Jul 2019 02:20:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E3C68E0007; Mon,  1 Jul 2019 02:20:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f208.google.com (mail-pl1-f208.google.com [209.85.214.208])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB676B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:47 -0400 (EDT)
Received: by mail-pl1-f208.google.com with SMTP id u10so6739188plq.21
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=APKBQWkk9iHwyQHEt2C0MEBOgtO6KbM8T5bZXthkZZI=;
        b=ZaoL+buQGrZ/Q9DjMqwd1TI/6MPpgrMVHI1Lb31Cbx3XobM2Oiw76AgrmHdk8qH2Gn
         aQWbRptWavdOnIcrtqiTmJPgDE9Mo9kveoXAVe0htC57Uj85ZRI0p9MYlurKI/vpA8qH
         HzNh1kodYmggBUMRw0W/mYZiUfonrr+XkQV+02HOpNJxMUpQr4NR/+/BTpXcDJfwDiVn
         +lfEK+2p0wa7wiFTrO+7ow0HN5LYeeGNhqyuPfqJyb3gRQLyHoMCHDklXvd5mU1HHKCM
         vbPgsKKyEkaG7oC/GVfPs8LjCoCJy5qrVOTUY4NWdFf1CSyWTXKmJ7WyYoYvRh6We6Zk
         3Pbg==
X-Gm-Message-State: APjAAAVAhRGm0ne3I6KPKC8DMlcbBTkELhs2jW+ukzAWYJqtebH4nEE5
	jjk1TH+y7klkFxu5WP+ETCgicpozlcXGPzVVTKuZrTIVY+0TPeLj1GhANTkqcAzTPN1OxFMyDcQ
	gy6cscZI/OstzzVu2nhOOlvikDFNSyy9a5NqLPIxlNF8Nwx7jyucnXazJHN/21R4=
X-Received: by 2002:a65:43cd:: with SMTP id n13mr23783214pgp.208.1561962046615;
        Sun, 30 Jun 2019 23:20:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUY5uuQWc8z+K8+kTs/nbafTmOr6qFDb4bGgBY39wNSIZ/40pP8VJUn7IaWt6AKyN0dG5b
X-Received: by 2002:a65:43cd:: with SMTP id n13mr23783155pgp.208.1561962045731;
        Sun, 30 Jun 2019 23:20:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962045; cv=none;
        d=google.com; s=arc-20160816;
        b=NUbDcQ2VVb+8ty/2VFNWBskgaSALho+8ZRy3WXFwKS1utLVifkw9VUSMsyj6+SBkAF
         SGO0Z2GzzggAK8QVSeC0HYtgiYfEI5eDfjtgrc0aoaCgz9xy25KSa5GGBMM99dry/bAT
         OJC2xPzfF1n/Ce9vhBN9iIXZoFkolazEYNzv8SrafSZvY1eSANaAc0cMMUn2E95F6sit
         dilrAOgY3xsxl+Y/e2bziWnNVrKbSL6Hj7MYRM3Hydld7+jl0caGYsaAr3R3Km49OOlZ
         DnpPUscXL7NhFtFEZvqu24FgUgQOVruBYoGrharCMS1ATGAeVxaCCXopQF2D6Ym3TelP
         5pZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=APKBQWkk9iHwyQHEt2C0MEBOgtO6KbM8T5bZXthkZZI=;
        b=0RJEE67zHyw5/0lYKgMbONXNFfryUtBBXlbMrPIf12o+JW+478Er/0TjmcH/UupEUr
         kFKkA/qytkIwsLMUrmm6hbNhExub0TBwSwdeltz7KMaNQ7DW7biRLkPVYhnIqK2hqTES
         uWByccEG5hOSkvIXEFkmXG0OX8zCVarJJotsTAZ4XM+b6V9E5oQjFaU+BYBR8hv2pIeR
         ebezzmjIzO7v/ESE/T42Me6tMz0G6yLTuUXZuTZ0WsGPk1ySaYnj1GXzKlcR1f1KSmNs
         X+5hgPqN7fg0xB+4q3I89SAI5GYihzF/B0qI8U5X6X5tuBIRLcfx/9qTGE2lv3Q6HUNd
         lLvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gSbk2W6E;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c7si5400871pjo.88.2019.06.30.23.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gSbk2W6E;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=APKBQWkk9iHwyQHEt2C0MEBOgtO6KbM8T5bZXthkZZI=; b=gSbk2W6E84lf5FtDNmA7UbJzV8
	/YpjENtceLBi7lcdSkKI3hddigiEEfPq448QumXbzCmOvF+HQ4eGiOVwzgEgTxo59mprNYGLlbRal
	pFad60P91vtTjcQCJM33sMokpMT0eR115j8oJP1AFdexcCZJzIE+KPqTW59nqSqC58f1njztm+KLt
	nDzWjqQ54DQdSWM+FGXGX7f9sA7DlL6G91SyOHzqRMJtGs2Vw3Ec9RA8nXlpy5RPimyAnOMxTBWv8
	scgz4P+mEmSq7QkjP1YKS3IDhkGZzrRmUCpak5IqWHEFnT7ZLMR6eXSwhpA9HpzzWOMtkhjLVW6wl
	FwufaIVQ==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgA-0002y7-L6; Mon, 01 Jul 2019 06:20:43 +0000
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
Subject: [PATCH 09/22] mm/hmm: Simplify hmm_get_or_create and make it reliable
Date: Mon,  1 Jul 2019 08:20:07 +0200
Message-Id: <20190701062020.19239-10-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
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
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 77 ++++++++++++++++++++++----------------------------------
 1 file changed, 30 insertions(+), 47 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 080b17a2e87e..0423f4ca3a7e 100644
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
2.20.1

