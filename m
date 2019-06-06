Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37167C28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F00C420868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="EJVyVO6o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F00C420868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50C6C6B027E; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 496A56B0282; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04E036B027E; Thu,  6 Jun 2019 14:44:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAFCC6B027E
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:48 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q13so2869984qtj.15
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bW6W0dzfTSD+G2qWpxSPnT6FDkRgs6qYralNDwCWWpM=;
        b=T3bmauwurK43ci2hK7odx/4S4nG6/m0vC62BQe4K/94VfZ/TbgzmeYeqaunjsmjm8z
         PiDomoC0LyTLNjUZH/W7B22KmWjN5spalVbSrRIbmK0FZCMuH/WkDi3BZ6MnlKWZfKd8
         UxV3RyDIo73krIr2BQ5+0PPjR6p0QGtzgfDFO3x3nAbBtl1wEgPe5qs6zb3JCkwhdR1n
         9FR7AHX0IjKm0YJshgBev+vVzpF/tB9J8EF/NZ9XoFK5Qu3kSMJ1yJEhFLoR9CjbZFEd
         wgghTk3GB6SKCyrTtiJ/CUHx1c96wG5nY+kNwSiFGi26LED9aDys32R/ZkOjuusb4gpf
         BvxA==
X-Gm-Message-State: APjAAAXyQuNRtGmYzlUB8U3T9b/OwACks6JDPO0JtyhSz61yMmEmsRDm
	pSEnEJUK6B4h7RyombPbw1CqlxaHfxfIte+DZBSPi+tyRZDr9E4+ePg4UkdYsbpUQNIIjm2r1jw
	hYWS7GFA4EZHIXLHZwkCcQqbffO4/RxFdkp8dnZBAaVB7Lks3mg2ShjTXMmCU51aLpA==
X-Received: by 2002:ac8:2bd4:: with SMTP id n20mr32689931qtn.131.1559846688575;
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
X-Received: by 2002:ac8:2bd4:: with SMTP id n20mr32689889qtn.131.1559846687783;
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846687; cv=none;
        d=google.com; s=arc-20160816;
        b=n0XeLZJ83GEugy9vT1WT7tupNRcRAhUWdfWm+k/icZqJHo2MmDxXfkXHr4UP1F2vy3
         HDuQCZqA08BhV3NecNJa26nKn1E1W0rU7fvGlZhdriSYNjCBjbGXmzUGFxcIukufVpFA
         eKOub/UXFOQv7fydkiHMzhZRNX0gQVuB4DNo7FmZdMR8uIWhOmhahBs0XQm7/pKM0vx/
         BjzfEpGXPdzsY9JPjV/6MlOXSxzJNnqHzpuvDj2v6oG6dYTzXS5S8Q/XOKijqbOA55xY
         U0HcqB6mJPR/EAU5m6mIXFngCcK7RB2dcYwmMqC0y/JYJkby7nw1WcFEziGo1qh2qn5L
         6Kiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bW6W0dzfTSD+G2qWpxSPnT6FDkRgs6qYralNDwCWWpM=;
        b=GIl8tJYT6IxK6uplRXo0QZaWbScIGI9/vi+Px0JqBp0nva+0rgXzBNaQ93QgOQgiCC
         VULES9rSkqZAWOh+sVn4XH/dgPSuL0dVKLL/6cnDRtaee/ho2X2BHq9hf4/WF5B8VTEB
         kDDtLeWS08M18rtcu0sO/+qFvcrosiTIazedawACwexrQX3ZEx+FvCRp+NE9tULEv2fC
         p+FOCl5UKgRvUd0wai5B2Y9wuv4OYNKlMPTNiwsfe6Kv+cLjCnwTs9AGOa+H/qeqN7Va
         GhSA5hjDVi+/8FYjFyvEovk+UZMlWl4jn7v/7HifFetM29doCF9tKflKj9ga2HjFXFi0
         ky6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EJVyVO6o;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u39sor3150870qte.45.2019.06.06.11.44.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EJVyVO6o;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bW6W0dzfTSD+G2qWpxSPnT6FDkRgs6qYralNDwCWWpM=;
        b=EJVyVO6oJlvHu7MqG8ir6ye0d2E52VzdqGkXefNtzJsbNH/e2vUDKVO4zKcSXAEFek
         RGTHSuR2YRZ1JntKN58PGjvSeSfQolEl6TZyDu5mOklbvcsTapHOZDax5t2QrdVtX4to
         S11U99ZURLmGhJncgXoMHt954BFGp+lQHi/nCQ/NGsZzpVCFFG4kyutLM4kf1TOb9nOO
         tio0c5Uz+BelXNUYQJIQjh7rB+6spPYFY8/2kbAPv75GMFedDdWbqiZJxGEeE5bGDsyy
         mjVC0gpMoewb2qe/MbOH7NBFg26yQBOwn3DW+fWWa28YBIKRIyCP/q4ODTS6P3lKmvV+
         taYA==
X-Google-Smtp-Source: APXvYqzZrmfOR3muOAR1prnBDkAE4ixgQwkLWPMt0LNdVl4lLNKXUZcw+vPND9ViR47fQ9OlYet1CA==
X-Received: by 2002:aed:2a43:: with SMTP id k3mr42504564qtf.301.1559846687527;
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c5sm1192064qtj.27.2019.06.06.11.44.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008IH-HE; Thu, 06 Jun 2019 15:44:45 -0300
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
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v2 hmm 03/11] mm/hmm: Hold a mmgrab from hmm to mm
Date: Thu,  6 Jun 2019 15:44:30 -0300
Message-Id: <20190606184438.31646-4-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190606184438.31646-1-jgg@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

So long a a struct hmm pointer exists, so should the struct mm it is
linked too. Hold the mmgrab() as soon as a hmm is created, and mmdrop() it
once the hmm refcount goes to zero.

Since mmdrop() (ie a 0 kref on struct mm) is now impossible with a !NULL
mm->hmm delete the hmm_hmm_destroy().

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
---
v2:
 - Fix error unwind paths in hmm_get_or_create (Jerome/Jason)
---
 include/linux/hmm.h |  3 ---
 kernel/fork.c       |  1 -
 mm/hmm.c            | 22 ++++------------------
 3 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 2d519797cb134a..4ee3acabe5ed22 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -586,14 +586,11 @@ static inline int hmm_vma_fault(struct hmm_mirror *mirror,
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
index b2b87d450b80b5..588c768ae72451 100644
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
index 8796447299023c..cc7c26fda3300e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -29,6 +29,7 @@
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
 #include <linux/memremap.h>
+#include <linux/sched/mm.h>
 #include <linux/jump_label.h>
 #include <linux/dma-mapping.h>
 #include <linux/mmu_notifier.h>
@@ -82,6 +83,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	hmm->notifiers = 0;
 	hmm->dead = false;
 	hmm->mm = mm;
+	mmgrab(hmm->mm);
 
 	spin_lock(&mm->page_table_lock);
 	if (!mm->hmm)
@@ -109,6 +111,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 error:
+	mmdrop(hmm->mm);
 	kfree(hmm);
 	return NULL;
 }
@@ -130,6 +133,7 @@ static void hmm_free(struct kref *kref)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 
+	mmdrop(hmm->mm);
 	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
 }
 
@@ -138,24 +142,6 @@ static inline void hmm_put(struct hmm *hmm)
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
2.21.0

