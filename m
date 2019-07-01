Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85D79C06510
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FE112146E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VeakI5P9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FE112146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3BD68E0003; Mon,  1 Jul 2019 02:20:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D72AB6B000C; Mon,  1 Jul 2019 02:20:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C17DC8E0003; Mon,  1 Jul 2019 02:20:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f206.google.com (mail-pl1-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id 7D69E6B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:40 -0400 (EDT)
Received: by mail-pl1-f206.google.com with SMTP id 91so6750164pla.7
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jmOMWk7PIhlkuWmnGeQ5B09Y2pWhYhYuU69m57P7xOY=;
        b=kJ8A/GJPy/2whpuOTdYGPJk3nsZ8X42vptx32qg29FDsF4nl5TrFcHouJ0d/79pxsg
         fGNUBLRLXPNR6jY9Skmap6SMesJjd5ntHUFHlE+T2evnalVzBGvEpE/57oAoEfqEZb/w
         jZPQKesotvXEDRxW47QN3lVr5RlpL9kAH3W4Jl/BiM66IRyjx2nLIbdzGhY064tjUh2v
         ofNw+awpq7hi5Q452yqVrm9hleWZNB7mAajP8LlfruneTAlTt4jgYSieaRbvCPak1bkl
         HGAkASoOiFLDuajQclRqwhvs8zm03QTj99O48pJvJaWAAXcNuUM9tqKQEZH8Darw4bfl
         fDhg==
X-Gm-Message-State: APjAAAVkLYXqTNsX2URPGOltNiTxQfvcqpGU7p2I/BgqSl55+dpqf9E7
	QL4GeBF7Gl484HVcBd42HpOYjdo4uy075HmgPPCqC8JwEwEkAYGDcbjbQ+aeAOMSJNwzu/LL5/u
	rfIJht7MspBgmOnU//JHN4MMPrYgWWdcOQUDPxqM7exIALZlTxDgbS3L5i4zqGUA=
X-Received: by 2002:a17:902:684:: with SMTP id 4mr27135835plh.138.1561962040116;
        Sun, 30 Jun 2019 23:20:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRIu+Uz2yHNXE4HHyiTlqM8P1b1bTNhaini7Nhhz89H8UvG8+5wCo3k/LN2JdsZ74hXOPD
X-Received: by 2002:a17:902:684:: with SMTP id 4mr27135774plh.138.1561962039358;
        Sun, 30 Jun 2019 23:20:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962039; cv=none;
        d=google.com; s=arc-20160816;
        b=dSXt5hGFDULT1awjHU+pxRfkq6eQJFjUUavo6DQxvKNHOMuaOGiHN20cITzoYD6nkQ
         Ggg029dIs+E0DI8aTv9f5gTrf3pZDsBtrKtaZjw6d7cTzsm4sILrSF8pBpYxP01hoDbS
         60qVVv5YNMloqkL7jNj9vZSZS6jAAjzz9HNbHCufk/UJg3QLTQdYGck1nlt2ZFLjBl64
         /AWCUiWyqV4pWLKAZA9QUu2KWVhKRB77xuAn8drmhdiK4HQN8zt0JEL2z2RD+YwjhNUr
         kRqRJ4Fl+v/4Jde2t2GZrjBu0y2nS613RDu2R+VciCqwg2YVzXQZKPF9hK2l7MxDLYKI
         UvXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=jmOMWk7PIhlkuWmnGeQ5B09Y2pWhYhYuU69m57P7xOY=;
        b=FpoRCd8z0IcCIGqDfRODZ4p5noc5IxCgqiqRiGwLRK/dnNWhpRUaA/TiLxA4IN5RJ1
         3+yWe2e/sySYP+60YHXBTtAtsq+vHQYepMDLWiEaHkbr1NfwIpcDtCxz1g7PS3cL27X3
         wX+VevkoSk7zNP1A09h74zqMajm812iJJblA87U3BuVYDbQTqzDXR7TuUTbhw5c29Ja6
         xowlxN+spY5HZI7TADkNODrvuNGQSTicqsBxZcomfutpcsofDiGdh/WQQHEeg18LOkpR
         8LICUPzXUx58xZTZgc5hD5z4PdN7T2AZMi14jx5OSGUXqbs3z2dnwyEDuUZQ4q4l5dxC
         6V0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VeakI5P9;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r1si9958528plb.147.2019.06.30.23.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VeakI5P9;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=jmOMWk7PIhlkuWmnGeQ5B09Y2pWhYhYuU69m57P7xOY=; b=VeakI5P9w+GmafWP63j4toaMHW
	VtQ719iF507yMzRYvJH0O7ViWtHiRqxBzk4XV1VWHJuDRmKATRqv5uGO1bPQ/HjcmlnGj7Hmo8iiO
	1Jaor2NciDsSBC5DuE2m4oqWrc6z9Q0LAYh8TJTLsIGN6X/B4UbOGhJ+wyuNhBwFIbIedO/YeaHx+
	+7FXU5AlPz98ULQTY91XtdepAVFhjM6WLqNvX1tjPU1WEnad36P3axRqnJ94+cx8eGn3NV1QCwU4H
	CUo3rFW7bBw/VsDVLa9ixH7iz3Sd/EzrpcPBK027xnR2Ky3UcG4pmQOE9WaaDPVU5IIK0HRwIAjrl
	Dky3elEw==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpg3-0002uL-My; Mon, 01 Jul 2019 06:20:36 +0000
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
Subject: [PATCH 06/22] mm/hmm: fix use after free with struct hmm in the mmu notifiers
Date: Mon,  1 Jul 2019 08:20:04 +0200
Message-Id: <20190701062020.19239-7-hch@lst.de>
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
 include/linux/hmm.h |  1 +
 mm/hmm.c            | 23 +++++++++++++++++------
 2 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 7007123842ba..cb01cf1fa3c0 100644
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
index 826816ab2377..f6956d78e3cb 100644
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
2.20.1

