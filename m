Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B00EC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F86320B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Aqt2P6wk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F86320B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9849A6B000A; Tue,  6 Aug 2019 19:16:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 934AC6B000E; Tue,  6 Aug 2019 19:16:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AE976B0010; Tue,  6 Aug 2019 19:16:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43BD86B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:16:18 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 41so74634930qtm.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mjtpPFkSq3UiLsyLXzaYFfxy47hSUzru4mJ5ITxeLVU=;
        b=XWuIficMIRLJ01IPjvlZm8Pr0wbiUkQWKWFkpuHFYnX+M3B/xneLSeHX55OafCOtZi
         ouc+/d2E2xlTkCr7GgztsPgUK2CN0GUcjLdQfVmSQs7/U0KOLQb/wvbjPLJ3fF8rVrMV
         vjFo3MIqQ008RXyDMaFo5PwCd87MKprgaCeeixOzcaQxMJAsOd048MBd68TPI3qi7OBt
         NCAj6yAZCi8RS6xhzvuy9o0DSlphQYsJOHP48+Sf6NiF9yJqa1ge6yqPBKwtw6YptRZt
         fOSRbLegbIjrB3ylw0GYzcozJYa+CCyMtBodl6IUBsgdHjcZ9hTLnsRDgI9/g4Loth7h
         HN5w==
X-Gm-Message-State: APjAAAWrDJuibgC0beqKsOT8EzXYUPSyWjV+1vKeL8pMrJ956miQKjnr
	bPxIabEcoY7+vPyc7LTkoTan6Qxl4N963QpPXruhbp5EEgNEbnxnHF4jV9mYEkX4fJ6YlvGbZsZ
	yupc+W2RGjUXgpDODB+NDzwDlkKqaIoBDDPekuxkigQ96YdI1wyd12sRn3dThUt+jhg==
X-Received: by 2002:a0c:b758:: with SMTP id q24mr5480432qve.45.1565133378068;
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
X-Received: by 2002:a0c:b758:: with SMTP id q24mr5480373qve.45.1565133377012;
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565133377; cv=none;
        d=google.com; s=arc-20160816;
        b=tEFL2UHfdhP4irVQTS4lk27XWXFHPG08nT+kXeRw0IF5toCaSJ9YwU5pM0y1cH8XNs
         ZnKLxvXzJXfnOQTbg9r+bmuRx7Fm0vnWZlrZC5XxxLDHLrt5be3+lEZTsD+VLEBxMCy0
         q+Ys/OOn8x2dZkAUV5LJa68WZCmQZLlYlK4D+X41Nwy1E+5mwQnk64K9r4huzHcYwmfe
         QZqWgKwLhqSfZIfCAtTfUuViNB5jX6Pzsg2ebWtMGGCrPVpqkKUy4NVtRBDpWBro8njb
         TaGqRM+wH+srpKZzagvtFzzDChUEcrAbxNbNhbnKT5FPG80uFMmNbkZBHncY9D2RYuy+
         NYWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=mjtpPFkSq3UiLsyLXzaYFfxy47hSUzru4mJ5ITxeLVU=;
        b=ug7+kxoksDrxImSTDPQLV3/A8/0Ty+ZboQRYwGLn89A96zf9lJ1CG5spdXz3v87n3C
         qcB7PXpsHmcpZJjlVMnq6BIHWWkmuq+L8H4wrOyM8246z7il+iHin3q3bJRXrqoQHy/l
         rjBCiCtCApmbPeQBg0MaUU4PJYOtTPLczEsvfPi90skCkyWEPndWLwkESbv9djLwfkqX
         xoWuOtZMOUJj8ISwOTRl4BGhc+aIYdhROWT7xlFiaXhGB87qtunaFD2VPFULg/PHxRX+
         KfuEQhzoUYSYRRs68bz5T+S1EBKDldSXbV5QigmzGlBr+fhV3D/mQYN2qFFjcgYHkZW/
         Jbgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Aqt2P6wk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f4sor114378526qti.68.2019.08.06.16.16.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Aqt2P6wk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=mjtpPFkSq3UiLsyLXzaYFfxy47hSUzru4mJ5ITxeLVU=;
        b=Aqt2P6wkNDk7Ey4zJ/R2dr20/+p+3YhHJwj0w4amgSQKlEOzS7bH+L1Oepqzsr46++
         aqXCSW5qQ+ZwByqVsAB+aLiCdaOPYHZoHMNlOBje6tt/3/uvpiTCTJbTvN+WthemRndl
         /kJKQxc7MJH2ISRonRwzYob3+PusKHZyNLKSSWfe24VwuwxIhBYqxbeduEP8ekflzqn+
         3yA1G3kjs09AVnNH83BdYQtbyyY6PmgYHmcfgbvOmvx4hl79v7MqlTCtxlX6HMoPt34s
         F8GhD+KbHjGiBPnxWQSt/UpHQqEubqay3aXPCjsT8vtbafoNOzsV5GtwtBxXRIkev7JZ
         fWtQ==
X-Google-Smtp-Source: APXvYqz63tweA2E8MzBrzK5yWz5htOs/6XLwX1oleep4fUjPNFszgc4r2awnmY97Q4W0cA2HokN6fA==
X-Received: by 2002:aed:2435:: with SMTP id r50mr1433667qtc.43.1565133376646;
        Tue, 06 Aug 2019 16:16:16 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id x206sm40603751qkb.127.2019.08.06.16.16.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 16:16:14 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv8gg-0006es-Bw; Tue, 06 Aug 2019 20:16:14 -0300
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
Subject: [PATCH v3 hmm 07/11] RDMA/odp: remove ib_ucontext from ib_umem
Date: Tue,  6 Aug 2019 20:15:44 -0300
Message-Id: <20190806231548.25242-8-jgg@ziepe.ca>
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

At this point the ucontext is only being stored to access the ib_device,
so just store the ib_device directly instead. This is more natural and
logical as the umem has nothing to do with the ucontext.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/infiniband/core/umem.c     |  4 ++--
 drivers/infiniband/core/umem_odp.c | 13 ++++++-------
 include/rdma/ib_umem.h             |  2 +-
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index c59aa57d36510f..5ab9165ffbef0a 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -242,7 +242,7 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
 			return ERR_PTR(-ENOMEM);
 	}
 
-	umem->context    = context;
+	umem->ibdev = context->device;
 	umem->length     = size;
 	umem->address    = addr;
 	umem->writable   = ib_access_writable(access);
@@ -370,7 +370,7 @@ void ib_umem_release(struct ib_umem *umem)
 		return;
 	}
 
-	__ib_umem_release(umem->context->device, umem, 1);
+	__ib_umem_release(umem->ibdev, umem, 1);
 
 	atomic64_sub(ib_umem_num_pages(umem), &umem->owning_mm->pinned_vm);
 	__ib_umem_release_tail(umem);
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index a02e6e3d7b72fb..da72318e17592f 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -103,7 +103,7 @@ static void ib_umem_notifier_release(struct mmu_notifier *mn,
 		 */
 		smp_wmb();
 		complete_all(&umem_odp->notifier_completion);
-		umem_odp->umem.context->device->ops.invalidate_range(
+		umem_odp->umem.ibdev->ops.invalidate_range(
 			umem_odp, ib_umem_start(umem_odp),
 			ib_umem_end(umem_odp));
 	}
@@ -116,7 +116,7 @@ static int invalidate_range_start_trampoline(struct ib_umem_odp *item,
 					     u64 start, u64 end, void *cookie)
 {
 	ib_umem_notifier_start_account(item);
-	item->umem.context->device->ops.invalidate_range(item, start, end);
+	item->umem.ibdev->ops.invalidate_range(item, start, end);
 	return 0;
 }
 
@@ -319,7 +319,7 @@ struct ib_umem_odp *ib_umem_odp_alloc_implicit(struct ib_udata *udata,
 	if (!umem_odp)
 		return ERR_PTR(-ENOMEM);
 	umem = &umem_odp->umem;
-	umem->context = context;
+	umem->ibdev = context->device;
 	umem->writable = ib_access_writable(access);
 	umem->owning_mm = current->mm;
 	umem_odp->is_implicit_odp = 1;
@@ -364,7 +364,7 @@ struct ib_umem_odp *ib_umem_odp_alloc_child(struct ib_umem_odp *root,
 	if (!odp_data)
 		return ERR_PTR(-ENOMEM);
 	umem = &odp_data->umem;
-	umem->context    = root->umem.context;
+	umem->ibdev = root->umem.ibdev;
 	umem->length     = size;
 	umem->address    = addr;
 	umem->writable   = root->umem.writable;
@@ -477,8 +477,7 @@ static int ib_umem_odp_map_dma_single_page(
 		u64 access_mask,
 		unsigned long current_seq)
 {
-	struct ib_ucontext *context = umem_odp->umem.context;
-	struct ib_device *dev = context->device;
+	struct ib_device *dev = umem_odp->umem.ibdev;
 	dma_addr_t dma_addr;
 	int remove_existing_mapping = 0;
 	int ret = 0;
@@ -691,7 +690,7 @@ void ib_umem_odp_unmap_dma_pages(struct ib_umem_odp *umem_odp, u64 virt,
 {
 	int idx;
 	u64 addr;
-	struct ib_device *dev = umem_odp->umem.context->device;
+	struct ib_device *dev = umem_odp->umem.ibdev;
 
 	virt = max_t(u64, virt, ib_umem_start(umem_odp));
 	bound = min_t(u64, bound, ib_umem_end(umem_odp));
diff --git a/include/rdma/ib_umem.h b/include/rdma/ib_umem.h
index 1052d0d62be7d2..a91b2af64ec47b 100644
--- a/include/rdma/ib_umem.h
+++ b/include/rdma/ib_umem.h
@@ -42,7 +42,7 @@ struct ib_ucontext;
 struct ib_umem_odp;
 
 struct ib_umem {
-	struct ib_ucontext     *context;
+	struct ib_device       *ibdev;
 	struct mm_struct       *owning_mm;
 	size_t			length;
 	unsigned long		address;
-- 
2.22.0

