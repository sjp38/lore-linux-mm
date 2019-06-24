Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3401C4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89ABC20665
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="oMvQEeOW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89ABC20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23EBA8E0005; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 156328E0007; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F135F8E0006; Mon, 24 Jun 2019 17:02:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2E928E0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:06 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id b14so6892206wrn.8
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MJQSyx5I9WQIuat3hBB7cHn44HQ02+T6fWrOLMHDIpE=;
        b=hLgcMB0gVuKIEZe/VllO3Qgu6ooGYO/qSNqWS+kTg97tQnkJpzxTS5MWoIvxvkRu9j
         ER1DDUq1EOvibCym3Guc6qv7jgvIIzkJ8RVDWIf55uu/rnFbUpbH2ReYb+C6A41QT+88
         p0lYuGkIoRehrrmKQLmwXvmblPbPoJIqVSUTkDvZi4UtPeiZgEQBPJTJ9SasC6Vf/Ppd
         d9IeoHRJ35Se0mpDVuJ697RjSd3dKwENDoFHA414i2kMPkCBxqt5jcOsJdXm6rqQ6fqE
         74+gWfEvqy7ZL84DZowKdC32OQ226CBbSM0hAdXG0GP7ebe1npp6+s4dMljlH2aKjB6K
         nvqQ==
X-Gm-Message-State: APjAAAU3Dn8p4PX2BRDoDINggDCs8C6z/eivzdueDBhJgnm+K86Mid3Q
	zc5sL19QNGZrWgoewT5g6CWCb6wLkaKhrd+TV4sqsbpelJ8DM9csilw05sgEDrBHBmx9m/X+Gn0
	QP9BsUIBP6wFntCSk3KKLxTpJ9asWA3MyRPwNC42j9MPu0cKGq5BbXWKYAf+kpWzGhQ==
X-Received: by 2002:adf:fd11:: with SMTP id e17mr42434333wrr.337.1561410126177;
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
X-Received: by 2002:adf:fd11:: with SMTP id e17mr42434297wrr.337.1561410125298;
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410125; cv=none;
        d=google.com; s=arc-20160816;
        b=g8y+ZeUnTMLHBlzXXgMqhikKXhPShHW/eAta3g7oaoUwX4bs/Xt5nlHd98oXwoQJFZ
         l6VrM1PzHr7gFYLAP4TTm2nScCVL6/QyffFU+D9xJHHSzEJBRTA+83t8+pijbuxzNkoY
         x5UzM7bt0y/t0T6WSMpa4MDBtmhJtpCGHnSCVON5zGTvWJoPJBOOmNbVz6MMB69CLWS1
         df/dTWfCQnYRjdfiyYwsLl0THDR1mI7ABreeukzO3oao+f5Fu+07F9/LmnMQlJ06Z+PN
         gBJvk+tNcAcRkXkk9BXsOwhgLuCqnhsCzZekvVV/avTUqiw+jE4vtEnDnl3MdwAuGBRu
         Ex4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MJQSyx5I9WQIuat3hBB7cHn44HQ02+T6fWrOLMHDIpE=;
        b=kdYu74tsSOqYAYRQ9lt1Zpns2Z9BIhhOSeYPCvpJ+aizWdiA0V5hLkpPmpIDGzdd6y
         hxbsAn0tFQCKUJOIeohWJVzaW5wtIWsyyq7eyyP7EdNe4ppKzcxlYAU8afE9TQcQq8+m
         tvJFwmWfFTmO5M2EBJx8UWuvc2IThGpdd13cDZMZXv9YtEYyHJLSFk0fDewwW9Wcu7Qn
         OhJJOtyQ9fgX0f18eP3k8pnNcejYAxGTzTEzgyUS0A2C44OFDtXa5Jsyda96gGV8co1U
         qbyMVF8E3+qcSJvFqQzDZl8PUz3YmP/1sZNt77yaaeYFfT4IHsGnK3A6P8HoYiwjpBom
         5fIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=oMvQEeOW;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c64sor361742wma.17.2019.06.24.14.02.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=oMvQEeOW;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=MJQSyx5I9WQIuat3hBB7cHn44HQ02+T6fWrOLMHDIpE=;
        b=oMvQEeOW3jlA/jInbebXvBiNOpipgFRfSGqcRm7zQTy9n0fBZhNWc+HqRdsBGvfoas
         9ZagIA6tsA27jF8jJhsuzXhsn1FXmqG0j5xv4shnb4nwTXoKwmM7oJ2k65yF3t5gXBSE
         xlXz3qHDEErdU0D2pMcseGextk7OdhnOkqInYbmQI1gUO7qrtJE1uX0pyvlz3YlLnknO
         sqCZVvuYR+lhn6UVq6Z9jO7x/rArDqufw9dwJ5VG1vfgusW9/rg/xQREUYZgy4+U1mqN
         JQUgexOwqWQrBjbYL4JVl6Alf5y/LhMUNGKdzg0+gQVKP467Kb+hNL89aBTa4xHO/0eq
         Mg5g==
X-Google-Smtp-Source: APXvYqy/o9BJkcVraqWn87goYHtDioMKUZC2UcYj3qjd4Ok68R0RasKDzib4jR1bwJteEjTWcnZR4g==
X-Received: by 2002:a05:600c:20c3:: with SMTP id y3mr17777867wmm.3.1561410124814;
        Mon, 24 Jun 2019 14:02:04 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id l8sm26977546wrg.40.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6C-0001MC-Qe; Mon, 24 Jun 2019 18:02:00 -0300
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
Subject: [PATCH v4 hmm 03/12] mm/hmm: Hold a mmgrab from hmm to mm
Date: Mon, 24 Jun 2019 18:01:01 -0300
Message-Id: <20190624210110.5098-4-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190624210110.5098-1-jgg@ziepe.ca>
References: <20190624210110.5098-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
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
v2:
 - Fix error unwind paths in hmm_get_or_create (Jerome/Jason)
---
 include/linux/hmm.h |  3 ---
 kernel/fork.c       |  1 -
 mm/hmm.c            | 22 ++++------------------
 3 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 1fba6979adf460..1d97b6d62c5bcf 100644
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
index 75675b9bf6dfd3..c704c3cedee78d 100644
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
index 22a97ada108b4e..080b17a2e87e2d 100644
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
2.22.0

