Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16B0FC32751
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3DE220B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="EO1RyLd4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3DE220B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8CB46B0010; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE7BB6B026C; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58B036B0266; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1E36B0269
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id v68so3425563qkc.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:16:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pkHeCt/hoSJAt//UHPk0X0I7hZeOiqjMeNu5wqmOhVU=;
        b=Zcm96D7HlMaeFnzdL1alVnEd3CErhAVOSBv0Ma+QnaspdLoOpG+b5yH1I8EIENCFb3
         BnI0XL+AKAi9FodzlllSxVs/J56Z3DZmIKUW7xb8GjhFPgaaKeb2/6EILaJTlCto5G+H
         vp+9+YrSuWs447kl72qKTdJE+HKFCVzEHKW0eJKJUb4Cktdd6mx4DVI8CB1Tu/f+LH1h
         p4AFwrtpb9P47uVXa0l5bbJepdYSLe5/uZis9FxjP5+dZApKvlsOgHW41+kRiWmkExgw
         cq4NvctZskl3bZN34wAhv34sToh8RfR5SWPfjR74EZXJU4QIhYgV5qUwRlEUrFYSE8la
         4RmQ==
X-Gm-Message-State: APjAAAXEyth3N9WotiN03M1/0Gh0Z+42L6ChdYvov7g+NM1jNcpfE3JX
	6d5g21Us2OW8bRKQnqXMPZ3UW+ZSpB5oU3nQvT2GQScWbcXQyFQ2g3aEx4BNlB7c7NP7lVK7vlA
	aILhgQGer8OeaOvixuQ5AxpbWGxGynQl6bR2H1yq4vhdDA7H4vYxwFHZTdysyyqxLJQ==
X-Received: by 2002:ac8:3118:: with SMTP id g24mr5474265qtb.390.1565133378925;
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
X-Received: by 2002:ac8:3118:: with SMTP id g24mr5474209qtb.390.1565133378003;
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565133377; cv=none;
        d=google.com; s=arc-20160816;
        b=nmV0juFwbl9lZl9mISg565RPA/jh9Kvk0hkz1LNev2WBE4WYKrfgkxbi64MH8mOq9s
         6liV199/shxZWbsv+AL0c/owNZz5fwu5DuXQjSRX/1Kv+vUlQ24t1Ep4mVH7V2B4jQAb
         vXJjTfGvq/GXAIDEgWoM1kSLG/9PTeco6S2fFiAusg/JOip0mnY9bCpG9CM3/6DHje7v
         hLChIaFEEFlV4RRRGuYMUlITOHDCnxnp/q4YW3AUFC9/xZAtDf5AtXED80wwrRUitoRU
         UMtDHVDAN8HBr6HMd7ayyuC+BYJivhbwMfpttZIo1RQYC1PiifEsldXo9AP7WXCVKZWG
         PGoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pkHeCt/hoSJAt//UHPk0X0I7hZeOiqjMeNu5wqmOhVU=;
        b=AO67JpGa4S+R79lH6AHNyK6Fa1vh/JCJVKY1Q8k0Dm+QPiab0jG1PU1QSBxpmJbe9f
         huuN390XFqokzCxo8SfbbGCrciKiF2R+4U092hQOt7Mu/2/nnB3FrYZNlrJ/ch9ycXDF
         mGaXGUnLWO0iM3bRMWvxveA0KiFDk//AW01bA16S0Kl7g9EHAL0Xe6Lrope7VQchZM5i
         J2aqncqGwcYb9Jv1991cUEEnYDYcDNOWP1pG3MQsd9mtNu30mn1iNcqRnrFajg/8oOIS
         6zZoMaFbaSCtO368cp+8XFPnkzVvUQ2+DWJKFFb8m9SDG1ZATDOA1OyMEyQyhUPoqLHn
         6n/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EO1RyLd4;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u9sor114030169qth.4.2019.08.06.16.16.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EO1RyLd4;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=pkHeCt/hoSJAt//UHPk0X0I7hZeOiqjMeNu5wqmOhVU=;
        b=EO1RyLd4d0AnXDRqElYRzxtyKz38WeGeNBRIkYdo+3VFgs/T0oIQs20Zy/5GKhTnqI
         UfyYPmrt29HX9vdxZVEwKEX/vOCaV33r4IcvjjLv+dvBVpY91WnTDcNJXzjaMgjBsFFt
         FdxAfV5Xk74BDXvs4obq2oP6Eu9zK7wtAWH8j4mJyF0Ged8Qf759ly97ojGQOxxLbF+m
         EBz8VKm2ELuy2OvTFchRCVHhBVH+J3NM3xKbJA1b+9RKe4syO0dO8Tpu7jcVbUS84W+G
         X1zRmwp67vSBaYZNs5bfg6X3fWLEdZzDSXoP+HJcr6VhTvigDkmOWFIoLfep3TCPpIME
         lbKg==
X-Google-Smtp-Source: APXvYqy6Nsusk0wHFyYvRxTipEB7NphBo9CKaHBj+WOx7SnMsQAhKID5TREjs8PZo1+pA73I5XbxVg==
X-Received: by 2002:ac8:2b01:: with SMTP id 1mr5497725qtu.177.1565133377682;
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r14sm36816958qkm.100.2019.08.06.16.16.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv8gg-0006fG-Jc; Tue, 06 Aug 2019 20:16:14 -0300
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
Subject: [PATCH v3 hmm 11/11] mm/mmu_notifiers: remove unregister_no_release
Date: Tue,  6 Aug 2019 20:15:48 -0300
Message-Id: <20190806231548.25242-12-jgg@ziepe.ca>
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

mmu_notifier_unregister_no_release() and mmu_notifier_call_srcu() no
longer have any users, they have all been converted to use
mmu_notifier_put().

So delete this difficult to use interface.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 include/linux/mmu_notifier.h |  5 -----
 mm/mmu_notifier.c            | 31 -------------------------------
 2 files changed, 36 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 31aa971315a142..52929e5ef70826 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -271,8 +271,6 @@ extern int __mmu_notifier_register(struct mmu_notifier *mn,
 				   struct mm_struct *mm);
 extern void mmu_notifier_unregister(struct mmu_notifier *mn,
 				    struct mm_struct *mm);
-extern void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
-					       struct mm_struct *mm);
 extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
@@ -513,9 +511,6 @@ static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
 	set_pte_at(___mm, ___address, __ptep, ___pte);			\
 })
 
-extern void mmu_notifier_call_srcu(struct rcu_head *rcu,
-				   void (*func)(struct rcu_head *rcu));
-
 #else /* CONFIG_MMU_NOTIFIER */
 
 struct mmu_notifier_range {
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 4a770b5211b71d..2ec48f8ba9e288 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -21,18 +21,6 @@
 /* global SRCU for all MMs */
 DEFINE_STATIC_SRCU(srcu);
 
-/*
- * This function allows mmu_notifier::release callback to delay a call to
- * a function that will free appropriate resources. The function must be
- * quick and must not block.
- */
-void mmu_notifier_call_srcu(struct rcu_head *rcu,
-			    void (*func)(struct rcu_head *rcu))
-{
-	call_srcu(&srcu, rcu, func);
-}
-EXPORT_SYMBOL_GPL(mmu_notifier_call_srcu);
-
 /*
  * This function can't run concurrently against mmu_notifier_register
  * because mm->mm_users > 0 during mmu_notifier_register and exit_mmap
@@ -453,25 +441,6 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
 
-/*
- * Same as mmu_notifier_unregister but no callback and no srcu synchronization.
- */
-void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
-					struct mm_struct *mm)
-{
-	spin_lock(&mm->mmu_notifier_mm->lock);
-	/*
-	 * Can not use list_del_rcu() since __mmu_notifier_release
-	 * can delete it before we hold the lock.
-	 */
-	hlist_del_init_rcu(&mn->hlist);
-	spin_unlock(&mm->mmu_notifier_mm->lock);
-
-	BUG_ON(atomic_read(&mm->mm_count) <= 0);
-	mmdrop(mm);
-}
-EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
-
 static void mmu_notifier_free_rcu(struct rcu_head *rcu)
 {
 	struct mmu_notifier *mn = container_of(rcu, struct mmu_notifier, rcu);
-- 
2.22.0

