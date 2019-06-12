Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43819C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E947020866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="l++ZaaCo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E947020866
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F0EB6B026D; Wed, 12 Jun 2019 07:44:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C8B16B026E; Wed, 12 Jun 2019 07:44:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E0EA6B026F; Wed, 12 Jun 2019 07:44:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E728E6B026D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:44:21 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v80so13531069qkb.19
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:44:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=dC40GuuRrFkQnjrApJXQmFxRiKKrkesKJBcqRTZL8Hw=;
        b=BESYZ+BpxULbs7EXGtRZkNu/ntqeedNLHIxVAzT5Xj2DbEc+tbmr93mn6nkv61Dvwc
         FKaGehpwERzinmAgoYid8nudb9C95Y9MZHSXYXkrUBac0r5lo+dRHOiin7c0zKWDg9FZ
         H8gtw2M9Zg+IwWldlOI7StSoHyEjPx8J0YgBqotJ0NRc9LyPS/gFr2K6u6h+C7/G1CuR
         Yp7XF0OA1k2J0zKMFmhTW5hWgqZrVDxsy6fIibIn3v3qtVIYc7mN2aNI6yYjsgHjlJik
         15J733troBX2f6Yom3xJ9EKcxKOgc6+0Z8ZACKPtQyDVap6IIFhSeRCJax4w16ZOiMPc
         LWfw==
X-Gm-Message-State: APjAAAVa9nJzVgCINz62yJ8GSA+DuHZIKTTOm+1Jly1/pAMCbXBbq6vp
	itreLnWsmQxhxcDOZwrAokZ3EmzDHqSwt8ML1ZrzL+oRaN0WpDKsrgQZCZ5UKPYeFaM+oqGgRtD
	QVV7vCfWB13a9NvCQLueBriOZ4L28mBOKyVtJcynNjYcGgJJcThvuqXdBhp+XGQhFwQ==
X-Received: by 2002:ac8:2e14:: with SMTP id r20mr11753826qta.241.1560339861734;
        Wed, 12 Jun 2019 04:44:21 -0700 (PDT)
X-Received: by 2002:ac8:2e14:: with SMTP id r20mr11753790qta.241.1560339861172;
        Wed, 12 Jun 2019 04:44:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339861; cv=none;
        d=google.com; s=arc-20160816;
        b=X/CFLaOx20s+XK1XRB9kKq1e7x9L3thBbpPafVbtCXzbmruMfT7PXBcO2slsAVcjwV
         OFS4ULmSRxpAeYU7dQQIPBd4yZakn9A5AgZPGcMlsF4H8giPYDufJdC9SSUhXFp+ZVKQ
         1OqlB9cNl9idIcdv1T7JAZvcUdzt7jHDgimPrZKxC4V/ZzuWdem98X7hc/ELSOi5N+IB
         TO1UDfjbbPjbMKrHBByQ7hzSdFSQcIwWZMTZq4RWdPOb7Z1a9L07cTRAWf7VNrj+B2SN
         4848urjGbw0QY5WII9XSDkWn9cYumaAoaUjHPk8vWrfmbCikprKv/M84pblVGLRIYQV1
         J3xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=dC40GuuRrFkQnjrApJXQmFxRiKKrkesKJBcqRTZL8Hw=;
        b=s8wxemWA+JKfCmExZrkxxTXAeJbgGmBvPZp3NGAubX/MamobhsPprenJ9xSjSh3JCj
         GhpoOSUPTw9M6OcB4g+Yf8SFywrDZvEhLk2PlF9FyhYV9RmMnhkv24UxlTrJ98SeSusd
         abCMdgnS3cWqme35aFf2VqaQXr5+lMsgqzL+m7uGxNT7V7onD7W8YO29y5c9pVt4Sc/W
         1d7YK/ceB8koS1//iFdWP+xjz2KjrcpwsXJbqfE/i4yEkP1GxtSNEJIynFsFq/4dEy3N
         EUVUrARiXmk8AhnO2obUKZfUg5JhB4D5Uh1OIWIP0g6RIhRuuJpDdaOm1tJ2RTTJTHu1
         EKAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=l++ZaaCo;
       spf=pass (google.com: domain of 3louaxqokcfet6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3lOUAXQoKCFEt6wAxH36E4z77z4x.v75416DG-553Etv3.7Az@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d20sor21739073qta.29.2019.06.12.04.44.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:44:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3louaxqokcfet6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=l++ZaaCo;
       spf=pass (google.com: domain of 3louaxqokcfet6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3lOUAXQoKCFEt6wAxH36E4z77z4x.v75416DG-553Etv3.7Az@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=dC40GuuRrFkQnjrApJXQmFxRiKKrkesKJBcqRTZL8Hw=;
        b=l++ZaaCoh/Va878Z1RknZZDdHUxfk157JnrRAUHz0jkL8fnv4FiiLmIp7Mk+/+dj5Z
         udFWoFOVhW7criNi8EMt8LBSnQaHvMhhUZ7BDvFNW7/H/rP4O9cpUiWmbFdx7WqJb0YL
         NYshnqAqHIeJqfZE1jL/Or9LTpuDIXYOfI1A2lvZRf82GFgwU4vOl8q53aA7Al9b8vAL
         /40xfjd6Br1Z56pIH7ZQuk9+yAf8Fr4GxAKL+l48BRvqpFH3utDdPvwMyQ57y2D4Zbcd
         AbEKWCBEQKFZuNPc6Vhcbi8LrlZtqOM5E/akcRiPUbRsuxCCoPgb7uahyTdqK4vvCrOk
         BhgQ==
X-Google-Smtp-Source: APXvYqwZjeFH8QvU8JlQ9TXNVd73FVhiQa5kjrzjuBPKvVuXz62UTyjAI0ty22a00jJqk9SVHlzrZWd7SRmSPg0y
X-Received: by 2002:ac8:30c4:: with SMTP id w4mr67672128qta.314.1560339860763;
 Wed, 12 Jun 2019 04:44:20 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:31 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <e86d8cd6bd0ade9cce6304594bcaf0c8e7f788b0.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 14/15] vfio/type1, arm64: untag user pointers in vaddr_get_pfn
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

vaddr_get_pfn() uses provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in this function.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/vfio/vfio_iommu_type1.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 3ddc375e7063..528e39a1c2dd 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -384,6 +384,8 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 
 	down_read(&mm->mmap_sem);
 
+	vaddr = untagged_addr(vaddr);
+
 	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
 
 	if (vma && vma->vm_flags & VM_PFNMAP) {
-- 
2.22.0.rc2.383.gf4fbbf30c2-goog

