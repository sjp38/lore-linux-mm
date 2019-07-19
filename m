Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C656C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 03:58:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 330E6218A6
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 03:58:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="CVecVRKO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 330E6218A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A4EC6B0005; Thu, 18 Jul 2019 23:58:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9574E8E0003; Thu, 18 Jul 2019 23:58:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F8888E0001; Thu, 18 Jul 2019 23:58:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45FBA6B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 23:58:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 191so17899145pfy.20
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 20:58:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GkSloBiHfepZ/So3+4LopxRoeSBU3PfOUimBWkkUVHE=;
        b=KfcC8v8hAA+qjARQxHFNVtnY0DSiWRBpzqNB6CCsoqeYhiAIgZWKwpwptQiBojvrXR
         OEVMh0duItPEeyuGYtGM3ZqEPVmdZXIBQi1lJWdKPHF/nySkNlepMcHRKfGcIMOm+8jC
         yCvLepnEp03ugsq2LTUXPJt2K3K7qs76vZV7hYf5uHrnQLup1NQeJQYjOZndJVcseXct
         /klid+izofSVbPCwsZbSPffFxVmLKuYA8bW4u+xltXHgnMpnWH89aY+b++IYpKLFNkqA
         04QK6YgxiCuFOiDn3YHq/zXFXm28htT5b23lZLe+Q8eKiydFLb66vsvvUfVeltZZOrmi
         VK0Q==
X-Gm-Message-State: APjAAAWQQerIcNIVHDdJLoKlMLf2cgZhOZVXqN/wvbHgyz7kJhKKYBEs
	PzwgQevzCkZSTqUJxMUas14MQeEZAMIMbMxTZF7mSnneOuQvGzeHQCRwVhPCT2Ftd2iivZX/lW4
	4lhLIhwx5fa/FgQHMGb/8dJcYQmlGRjTKaWfHE5YSJKDqAjb+AFr57RaJGS59AmDY2w==
X-Received: by 2002:a17:902:9f81:: with SMTP id g1mr53291772plq.17.1563508708871;
        Thu, 18 Jul 2019 20:58:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzecS6YEtuobd53bGc19aDJnFT15j4VDEEqy/osjGewKD6LqVAWJI0tTdbDXh+2jyHybn71
X-Received: by 2002:a17:902:9f81:: with SMTP id g1mr53291722plq.17.1563508707991;
        Thu, 18 Jul 2019 20:58:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563508707; cv=none;
        d=google.com; s=arc-20160816;
        b=wA7OAQqL1+8BTahMRXZ5bXGwPAnXbdcU251gv1QgJpsD6RDnhPXzmzmqz5mOziAhHe
         iD86ueJy5DKGKy2qFZ9RPrKBsgFKmH1yjteipAu8ONOoQj0wamyWZ6Vg3J+fRzmc4Pf1
         ncwNUy97KSf1aXAXxpG9jSjKCIBBTZryhijeZxJwjicAcHmPh6L8WrBfab2W8Q5cjaVv
         EM3kC1iWNF8bZGl4gof+svv5IgUlWI5jJpfoY9rm29jp2JG9mkL8Q8LQhQANCLYMWvYL
         qdYHQXVYOFgJS5mQ5xlChPSLYUh0JZaX7FjSklc/qDb3F9cRMKDP9Yu1DzSsHONeaRla
         rvrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GkSloBiHfepZ/So3+4LopxRoeSBU3PfOUimBWkkUVHE=;
        b=JvRckYOWYVebxMI1qGQ4icmkGqTZeV++YtRb+a77eJaZW1v7LBCVur7mXVc2JytDLW
         VbcGXX+WO846kYA6UTJlvVQtlj0DqrwHu9exb5bUYmxaBehPLaNJxJdwzi/37OYHd9up
         5g/VcFTii51d7JSf9XiajgWSS33rrx2Iz1W2wOaG3GzUXCkIqAkvMtDJ7Qj0NvowXfwJ
         hNOS5KfSAXYGO8lTBDCz5Z7adUhQaZEktp+dyJ8hp3lf4f+Kr1P+DBNeD0lUso9XHErZ
         OfHEcWMO/OBOkbXUdhqWXVr17b/6IGNNgBxnwzHIC4k8WwxUM+3yz1YofeEupefVnAU3
         q+zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=CVecVRKO;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i32si111408pje.44.2019.07.18.20.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 20:58:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=CVecVRKO;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 94ADB21874;
	Fri, 19 Jul 2019 03:58:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563508707;
	bh=3wayALKAbyaZVeZbjCrY015C06CrT6gtffI83ybrmsg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=CVecVRKOfUR7f0tq5XuS7ktArKsKrNh32YMPWgHFnXwgqWMwF5R5gdlYUn6mI9JJN
	 3ICAZXsVxp1iCSvJ8I1vkoz0ai5bbJsxODOp97pe8foxzCww9rgy28kY8JK96WwKCq
	 VtYrfI4pcJzUACTuCoVOigInBJhQOU6kcMQwtoAs=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Jason Gunthorpe <jgg@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 045/171] mm/hmm: fix use after free with struct hmm in the mmu notifiers
Date: Thu, 18 Jul 2019 23:54:36 -0400
Message-Id: <20190719035643.14300-45-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719035643.14300-1-sashal@kernel.org>
References: <20190719035643.14300-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

[ Upstream commit 6d7c3cde93c1d9ac0b37f78ec3f2ff052159a242 ]

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
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/linux/hmm.h |  1 +
 mm/hmm.c            | 23 +++++++++++++++++------
 2 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 044a36d7c3f8..89508dc0795f 100644
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
index f702a3895d05..4c405dfbd2b3 100644
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
@@ -239,9 +249,10 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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

