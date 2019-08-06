Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74102C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27FC320B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="LfRTCxlq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27FC320B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BD5B6B026E; Tue,  6 Aug 2019 19:16:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14C616B026C; Tue,  6 Aug 2019 19:16:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF4C56B026D; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 858066B026A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 5so77403890qki.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:16:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6NUFqlMBKMBn5vDhbmYDSPrCJfAHH+vuZmJm73vmPZ4=;
        b=Fb52Rs0GaZLcPOZZyOwlnlpsdMEfhINzA2g8uWLghF244SUOdG0KAbHEid3qwOpF5D
         cLWeBirg7JTSvI4LYxgA+PrAidaqzKaOqU5HC5NDdEIqkHV6HlXTzchi3pAX0Fk6LUiN
         sxckY4sA4yLHX2ivQR0Um5syF2EEKTdL++VTfop4x6uPbFqPw3dD/RpAJuhSwM4xTcCU
         EWN/lgsSVsSNzt47f4j/G017VHXYQ0sy/d+cKFBxzoSH0JGOSUIteMoCMQihRPkeFmU6
         PPgNytkK52JQeKI82bhxWW34vPecyiFfvOYaRqAo89ZEyhuwBfyVXcSUZzw8UHI11piY
         0LaQ==
X-Gm-Message-State: APjAAAXspGVjVlFE2WGT8Bk4BpgTDLaH5wLfblrvSEF1oLhDHlc5i/75
	FbAe+/kGlaUEnjQhzE6mqRQa7t4QssZiR4j969vMJK26FMZ+3PEHjZaza7Fmy0y+LU67Kr7t1+0
	80132J7NS08zJQIN+VYIlzrlEwATpyXb997v0c4lPmodWarPKRIgLpG9qk8RZGDL/2g==
X-Received: by 2002:ae9:e504:: with SMTP id w4mr5729162qkf.296.1565133379338;
        Tue, 06 Aug 2019 16:16:19 -0700 (PDT)
X-Received: by 2002:ae9:e504:: with SMTP id w4mr5729114qkf.296.1565133378301;
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565133378; cv=none;
        d=google.com; s=arc-20160816;
        b=mWqnsrXdz2gYoGCHN/kHghmYZ9G7+fHqGpL9ZAosgJ8mo32Qj82Rs+0MbzMMWE1VxS
         sZ0DpdpVddpsIp7fP3cDHM+9liit/68hxW7vr1krTBORPWLFtRFJ5O6TZrC3slo+91Ch
         uXOPFJKWBJDNTB/E4TLZPFfluNvt7RM/hhyrILJSWqJyuBi+0xS3kuR35Ed/K/yTP8bM
         B44od7+clzPVtvZxgaZX1Yh1QnF8u1oSg2WFKmRyRnsLkONLsRrbZ4I5UVqwmFIQDHVe
         Ub8VQm3YctbJbErqKJJAhJpKAhAI+pU5b0YKju131BIQ11FqY2Rw31EV6ZeMeVuQgpXW
         AHuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6NUFqlMBKMBn5vDhbmYDSPrCJfAHH+vuZmJm73vmPZ4=;
        b=w4HWpNUvvSQrKbenoK8nwvhNnvVsXt2Hg+MFXixPmV+m4x6YpT4s2fxrAFj8tZNU/z
         IROxRnZ+LHMJaKAqta8VIPDlx1ToTvqQWRZkQebmGJJyiDnvIIUs7r3s0wmriClH2v3c
         zwEf5RITvdrmzzsFFdPB90rDfWhFr0fNGdZZun3Z1+B/voV4I2JK5YI8NzrQhTx3Oute
         qvmTNjXBsJ8BDnSkwmcep3Pihjhc6jEMqGoAcCAnA8Zub8YWqiZgmqsrJTg3m+KN4DP2
         FV9eVDw9WvHAoG+rmtNvgQ+yafUb682xreeIswk5usmQ+Y0HYLDiXPt2XEp7HFAhmbny
         vZ5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=LfRTCxlq;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t28sor115799849qtj.18.2019.08.06.16.16.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=LfRTCxlq;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6NUFqlMBKMBn5vDhbmYDSPrCJfAHH+vuZmJm73vmPZ4=;
        b=LfRTCxlqNIR4uH7LAgvFKd3/HUW6EIX8oEHk8vRJZDXfu+MODxUjSc0mwQLjdlj1r5
         TdBQZiQ/h32bzsTmZvXIlzRhFHn0mmy0idj25YbeDts1A24fsEifBIe3NP5hqVvkvhrR
         nWWVKtWYfgjQk2Um2/MKR8gMUgvqui+DvGzyTcwS1oxYmThfLcGfOjUwJchzx5IQFtkm
         39y5spX//3k4QzhKIKnxJHNlnrtBxmpACeuwQvwhJuooM9+kRZCHN9wt4AYFAx6mZGXI
         dWzRId28bdIuuoDxYm8FkG1fzostiVkDLyxOWPmcJ25bAgDrnqB6r/Lbc3/r/c8WbtlX
         CAIw==
X-Google-Smtp-Source: APXvYqzyRI5TBbiUa5tyo3mkBzAmzYq9JR3/ocS4Z9Tm5ZTYPwm7qYeGZqLl/Ddc4+CKmoOUg5XVtQ==
X-Received: by 2002:ac8:270e:: with SMTP id g14mr5557862qtg.65.1565133377937;
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id y9sm37771754qki.116.2019.08.06.16.16.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv8gg-0006fA-Hu; Tue, 06 Aug 2019 20:16:14 -0300
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
Subject: [PATCH v3 hmm 10/11] drm/amdkfd: use mmu_notifier_put
Date: Tue,  6 Aug 2019 20:15:47 -0300
Message-Id: <20190806231548.25242-11-jgg@ziepe.ca>
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

The sequence of mmu_notifier_unregister_no_release(),
mmu_notifier_call_srcu() is identical to mmu_notifier_put() with the
free_notifier callback.

As this is the last user of those APIs, converting it means we can drop
them.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/amd/amdkfd/kfd_priv.h    |  3 ---
 drivers/gpu/drm/amd/amdkfd/kfd_process.c | 10 ++++------
 2 files changed, 4 insertions(+), 9 deletions(-)

I'm really not sure what this is doing, but it is very strange to have a
release with no other callback. It would be good if this would change to use
get as well.

diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_priv.h b/drivers/gpu/drm/amd/amdkfd/kfd_priv.h
index 3933fb6a371efb..9450e20d17093b 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_priv.h
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_priv.h
@@ -686,9 +686,6 @@ struct kfd_process {
 	/* We want to receive a notification when the mm_struct is destroyed */
 	struct mmu_notifier mmu_notifier;
 
-	/* Use for delayed freeing of kfd_process structure */
-	struct rcu_head	rcu;
-
 	unsigned int pasid;
 	unsigned int doorbell_index;
 
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_process.c b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
index c06e6190f21ffa..e5e326f2f2675e 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_process.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
@@ -486,11 +486,9 @@ static void kfd_process_ref_release(struct kref *ref)
 	queue_work(kfd_process_wq, &p->release_work);
 }
 
-static void kfd_process_destroy_delayed(struct rcu_head *rcu)
+static void kfd_process_free_notifier(struct mmu_notifier *mn)
 {
-	struct kfd_process *p = container_of(rcu, struct kfd_process, rcu);
-
-	kfd_unref_process(p);
+	kfd_unref_process(container_of(mn, struct kfd_process, mmu_notifier));
 }
 
 static void kfd_process_notifier_release(struct mmu_notifier *mn,
@@ -542,12 +540,12 @@ static void kfd_process_notifier_release(struct mmu_notifier *mn,
 
 	mutex_unlock(&p->mutex);
 
-	mmu_notifier_unregister_no_release(&p->mmu_notifier, mm);
-	mmu_notifier_call_srcu(&p->rcu, &kfd_process_destroy_delayed);
+	mmu_notifier_put(&p->mmu_notifier);
 }
 
 static const struct mmu_notifier_ops kfd_process_mmu_notifier_ops = {
 	.release = kfd_process_notifier_release,
+	.free_notifier = kfd_process_free_notifier,
 };
 
 static int kfd_process_init_cwsr_apu(struct kfd_process *p, struct file *filep)
-- 
2.22.0

