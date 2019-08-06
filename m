Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3006C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57F4C20C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lO1sgfmm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57F4C20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 563106B0006; Tue,  6 Aug 2019 19:16:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 514DF6B0008; Tue,  6 Aug 2019 19:16:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 321D86B000C; Tue,  6 Aug 2019 19:16:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id F21C96B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:16:16 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x17so77400111qkf.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:16:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zMCnJFSOouEfBlilBoskv+IiaZaXJbwxtFCutX/1ZbM=;
        b=KWI1DnXDAu5XfKeiceaIqGfSqPph/cIBFHLihmaq8D1iQ+3l0e2Lz0b+HWFJwIke7r
         xa5tW7gJjulnuYHmvyc6IXVr6egEg1J6EI3r1mvg2kIjYo3Lo7pdrudtTtx23j1w8k6L
         3niP/4E0k9VDa+mA97ru3jAHagJJdY1rrhdffRQaz25FxVuMTL2AZXb/g5QWQXOkHOtN
         joh71AgTuCaDS8s4KmTSDwvNdDGrw4dRBUF+lGZ5X0AWYUY4PyTF4DELKOlYQR9JQezl
         R7NU7Y1MJixJwxGX1NDTTXkULHCl0N+dqNJoE0Jt6JWnSOPWAqOjzTEZoajvnaG4dB06
         C6cQ==
X-Gm-Message-State: APjAAAWA8GDp9iSK9JU+vRz67uNdPlTufp5jCbBpdia+CPiIpvPF7wgf
	H5umswlnNkyh6CD0qPxwNt3ImUGLpLYAqZ9IWaqgqqqOT5CP+52o9wvaxsCQEyDhLdlmyGdrF/l
	ikzXgBa733nuDPdCjOAJSun6IQ/CZh+3rq6DnVrnLsI3UropnunRo7za2eZprIaVj3A==
X-Received: by 2002:a05:620a:1039:: with SMTP id a25mr5523157qkk.233.1565133376686;
        Tue, 06 Aug 2019 16:16:16 -0700 (PDT)
X-Received: by 2002:a05:620a:1039:: with SMTP id a25mr5523100qkk.233.1565133375557;
        Tue, 06 Aug 2019 16:16:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565133375; cv=none;
        d=google.com; s=arc-20160816;
        b=HDZpgGfnfFG6KCblLkWOdmSOUw4fG+Su02/BC8F3kxSvFFdGANpVdgJHD/Nudy0kXS
         a4Nhi7ZGjRHHimLudZHli9lnBrzBmnSCcYhmIfCkLH/hydMLNH4YGukyEBZ3PqRMKIA1
         3EURA4uzueCZflg+sA08Bm2P1dfSwFchVpPXycmOQgxLrY2fDmYFFdbzQq7+c+Lja5+r
         Iv2r/9lbuDy2TENXnjd+fFEA6PRMg78cstw5GQZDsOPlEMhRYpKrU3jULZ6EClsgiqMl
         cP3CuaKoz3UkD3XdjZPjeGuzAhivfQu7WVjwHkqw3HvQcUxqONND3o9TJzhrlaee0Af7
         5Ohw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zMCnJFSOouEfBlilBoskv+IiaZaXJbwxtFCutX/1ZbM=;
        b=Fprc73C9Uu6TREoPkJTvn/m9iI4k99O1vl0aeTEkRWkJgJrFIpCwvARxt7HToHR+ib
         cQQ0hCEJZM/TcOYciEavzdVwrScbSYLPKGXyUTYBL+lvN7v87J9+Eqfe2JmjMHQ5c6A+
         LsMOP5QZkuDJYVI8VV/P74lmk7vk4O6xGdhbF5Jwpm9ErAK627k3b6xB9g2jCstV8ab1
         w9ztNNGoWiCBa6CV9rsrkYw1IVTLxK4sA80qUTu1qe+/oIU0YXC60rqbl3/1Iu6MrV06
         aHIs0ZMMvViK4WmrH3Q/QLThhfYbNXnjzUIkedVSC+AKFU1HKa0wESe/Sr6Rm4NXJUyI
         amdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lO1sgfmm;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i38sor75731302qvd.21.2019.08.06.16.16.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 16:16:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lO1sgfmm;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=zMCnJFSOouEfBlilBoskv+IiaZaXJbwxtFCutX/1ZbM=;
        b=lO1sgfmmxfGlNqAPOvqLT1SGqrTemHFJclBTTUaP/JdfZebfYNEmZx12KN2d9x+t1K
         lII9WK9gYfQZPyWgyPFTPCoEGHZt8F0M7jQCLkLSlFxnaHHwQXPyY3CcqvQ580SczZfN
         qAhsOYwXpYzFayOyEW24oPZpEQGwPISo/iiZPCSocZqmP49DBEnHdgl5cijvZU770sK2
         rst5KmBjQuunoLWsnmCgllUhFH26FxYZrBl8qIJPrLLJfK3/2D+8ShVoV4s+9VzUPpPr
         JMuDt8hth2BUVJE2B6xnVe4lowU/3I7TBYPiS33xCwbY2pskYzWJYZAzDEPq+ODY5GTM
         Yhuw==
X-Google-Smtp-Source: APXvYqxMVRT0WflMzTw7hoNYehDw3sJ1fV7g1I1BCJ9PGgwnJ2UQq4JSqfd/nXhEpMBqp4lLxDXVKg==
X-Received: by 2002:a0c:9e27:: with SMTP id p39mr5387552qve.151.1565133375135;
        Tue, 06 Aug 2019 16:16:15 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id d9sm38947489qke.136.2019.08.06.16.16.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 16:16:14 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv8gg-0006eZ-5J; Tue, 06 Aug 2019 20:16:14 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v3 hmm 04/11] misc/sgi-gru: use mmu_notifier_get/put for struct gru_mm_struct
Date: Tue,  6 Aug 2019 20:15:41 -0300
Message-Id: <20190806231548.25242-5-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190806231548.25242-1-jgg@ziepe.ca>
References: <20190806231548.25242-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

GRU is already using almost the same algorithm as get/put, it even
helpfully has a 10 year old comment to make this algorithm common, which
is finally happening.

There are a few differences and fixes from this conversion:
- GRU used rcu not srcu to read the hlist
- Unclear how the locking worked to prevent gru_register_mmu_notifier()
  from running concurrently with gru_drop_mmu_notifier() - this version is
  safe
- GRU had a release function which only set a variable without any locking
  that skiped the synchronize_srcu during unregister which looks racey,
  but this makes it reliable via the integrated call_srcu().
- It is unclear if the mmap_sem is actually held when
  __mmu_notifier_register() was called, lockdep will now warn if this is
  wrong

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/misc/sgi-gru/grufile.c     |  1 +
 drivers/misc/sgi-gru/grutables.h   |  2 -
 drivers/misc/sgi-gru/grutlbpurge.c | 84 +++++++++---------------------
 3 files changed, 25 insertions(+), 62 deletions(-)

diff --git a/drivers/misc/sgi-gru/grufile.c b/drivers/misc/sgi-gru/grufile.c
index a2a142ae087bfa..9d042310214ff9 100644
--- a/drivers/misc/sgi-gru/grufile.c
+++ b/drivers/misc/sgi-gru/grufile.c
@@ -573,6 +573,7 @@ static void __exit gru_exit(void)
 	gru_free_tables();
 	misc_deregister(&gru_miscdev);
 	gru_proc_exit();
+	mmu_notifier_synchronize();
 }
 
 static const struct file_operations gru_fops = {
diff --git a/drivers/misc/sgi-gru/grutables.h b/drivers/misc/sgi-gru/grutables.h
index 438191c220570c..a7e44b2eb413f6 100644
--- a/drivers/misc/sgi-gru/grutables.h
+++ b/drivers/misc/sgi-gru/grutables.h
@@ -307,10 +307,8 @@ struct gru_mm_tracker {				/* pack to reduce size */
 
 struct gru_mm_struct {
 	struct mmu_notifier	ms_notifier;
-	atomic_t		ms_refcnt;
 	spinlock_t		ms_asid_lock;	/* protects ASID assignment */
 	atomic_t		ms_range_active;/* num range_invals active */
-	char			ms_released;
 	wait_queue_head_t	ms_wait_queue;
 	DECLARE_BITMAP(ms_asidmap, GRU_MAX_GRUS);
 	struct gru_mm_tracker	ms_asids[GRU_MAX_GRUS];
diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
index 59ba0adf23cee4..10921cd2608dfa 100644
--- a/drivers/misc/sgi-gru/grutlbpurge.c
+++ b/drivers/misc/sgi-gru/grutlbpurge.c
@@ -235,83 +235,47 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
 		gms, range->start, range->end);
 }
 
-static void gru_release(struct mmu_notifier *mn, struct mm_struct *mm)
+static struct mmu_notifier *gru_alloc_notifier(struct mm_struct *mm)
 {
-	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
-						 ms_notifier);
+	struct gru_mm_struct *gms;
+
+	gms = kzalloc(sizeof(*gms), GFP_KERNEL);
+	if (!gms)
+		return ERR_PTR(-ENOMEM);
+	STAT(gms_alloc);
+	spin_lock_init(&gms->ms_asid_lock);
+	init_waitqueue_head(&gms->ms_wait_queue);
 
-	gms->ms_released = 1;
-	gru_dbg(grudev, "gms %p\n", gms);
+	return &gms->ms_notifier;
 }
 
+static void gru_free_notifier(struct mmu_notifier *mn)
+{
+	kfree(container_of(mn, struct gru_mm_struct, ms_notifier));
+	STAT(gms_free);
+}
 
 static const struct mmu_notifier_ops gru_mmuops = {
 	.invalidate_range_start	= gru_invalidate_range_start,
 	.invalidate_range_end	= gru_invalidate_range_end,
-	.release		= gru_release,
+	.alloc_notifier		= gru_alloc_notifier,
+	.free_notifier		= gru_free_notifier,
 };
 
-/* Move this to the basic mmu_notifier file. But for now... */
-static struct mmu_notifier *mmu_find_ops(struct mm_struct *mm,
-			const struct mmu_notifier_ops *ops)
-{
-	struct mmu_notifier *mn, *gru_mn = NULL;
-
-	if (mm->mmu_notifier_mm) {
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list,
-					 hlist)
-		    if (mn->ops == ops) {
-			gru_mn = mn;
-			break;
-		}
-		rcu_read_unlock();
-	}
-	return gru_mn;
-}
-
 struct gru_mm_struct *gru_register_mmu_notifier(void)
 {
-	struct gru_mm_struct *gms;
 	struct mmu_notifier *mn;
-	int err;
-
-	mn = mmu_find_ops(current->mm, &gru_mmuops);
-	if (mn) {
-		gms = container_of(mn, struct gru_mm_struct, ms_notifier);
-		atomic_inc(&gms->ms_refcnt);
-	} else {
-		gms = kzalloc(sizeof(*gms), GFP_KERNEL);
-		if (!gms)
-			return ERR_PTR(-ENOMEM);
-		STAT(gms_alloc);
-		spin_lock_init(&gms->ms_asid_lock);
-		gms->ms_notifier.ops = &gru_mmuops;
-		atomic_set(&gms->ms_refcnt, 1);
-		init_waitqueue_head(&gms->ms_wait_queue);
-		err = __mmu_notifier_register(&gms->ms_notifier, current->mm);
-		if (err)
-			goto error;
-	}
-	if (gms)
-		gru_dbg(grudev, "gms %p, refcnt %d\n", gms,
-			atomic_read(&gms->ms_refcnt));
-	return gms;
-error:
-	kfree(gms);
-	return ERR_PTR(err);
+
+	mn = mmu_notifier_get_locked(&gru_mmuops, current->mm);
+	if (IS_ERR(mn))
+		return ERR_CAST(mn);
+
+	return container_of(mn, struct gru_mm_struct, ms_notifier);
 }
 
 void gru_drop_mmu_notifier(struct gru_mm_struct *gms)
 {
-	gru_dbg(grudev, "gms %p, refcnt %d, released %d\n", gms,
-		atomic_read(&gms->ms_refcnt), gms->ms_released);
-	if (atomic_dec_return(&gms->ms_refcnt) == 0) {
-		if (!gms->ms_released)
-			mmu_notifier_unregister(&gms->ms_notifier, current->mm);
-		kfree(gms);
-		STAT(gms_free);
-	}
+	mmu_notifier_put(&gms->ms_notifier);
 }
 
 /*
-- 
2.22.0

