Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30B02C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE48A27425
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sT3L0ZTG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE48A27425
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B1176B0277; Mon,  3 Jun 2019 12:56:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35DB66B0278; Mon,  3 Jun 2019 12:56:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2022F6B0279; Mon,  3 Jun 2019 12:56:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB1FE6B0277
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:56:13 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c54so8088261qtc.14
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:56:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=i5cRHHCicMsppSSBbFWeJPgqhQ8FMrYjuCKfr4hxLgs=;
        b=npPbK+KvitGD39XFjYKO5VvSPYvG0KRGdjJeQTVUHx4YFv00FLFOO91/WP9xwsITel
         /TYpUmAqNVT+H1wA5h43SF90AaprbOMiauzAxTyAeIlVKf6jeTtj2rOiu9VFkyuNZRDm
         rYvxo06NZ1AI08y5p8drh8Kpk160FByZDc4jNCNDiV+TSvoAZON202eT893EKMS0KFRg
         +iWu2rI3th0eRgdbNlE6DMr6K9637mcHG2PWlH81BLV55ZM/0v3aO+4fEqMkMZcSI9wO
         BIul03P+MDZa3Eikj64BRkOqcc7p7hYGqVyfsmPcyPYdUIwxvAjMJDpRnrEWZaQScNN1
         8qdA==
X-Gm-Message-State: APjAAAXnVRU92GVBEcZfN5Cje+tOIMnNFI4K7rj6EqJSGapvfvUfTMAr
	L7iDYsGAiWj2vFockFPh546/74Hl3paHGsblghO1oEbujqRc4qje0DZppH8J3mAy8HmDtoTjCl2
	DCgiUyDhFjl2evVGmJBVvXyU27ul1D1clKBI3D9YhBg28kyjbTlj02+dmyn1j2+XOxQ==
X-Received: by 2002:a0c:ae54:: with SMTP id z20mr8780884qvc.227.1559580973630;
        Mon, 03 Jun 2019 09:56:13 -0700 (PDT)
X-Received: by 2002:a0c:ae54:: with SMTP id z20mr8780852qvc.227.1559580973196;
        Mon, 03 Jun 2019 09:56:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580973; cv=none;
        d=google.com; s=arc-20160816;
        b=M8eR0R/YPNvYUluBn5Pyl3RT4LAO0dUqLFT2H2f+k2yyT/0kvgEEp3muJYdTD8da5G
         KKwSjY9Fm7VEUMkLUZspotYmwkZ7bo3lGceycIdqsCp2u/ipW5ljHvS0p/A7hVjMqLq0
         CzAcltjhUSO8yD+VUI+iKwhEd0lG/kOSRjpuJmr97YxVNdYri7iTsV7weos07stIRlCh
         XIh0+GkRWJu90gka4hF4DMuuIGnA+2M7qp+iYcUczTL+LmqSjA59t3fDgcGqTf/Y9q+s
         /ASq1f1MbCsoLnofig51zdDCDSgE2EYLaRayZYJwi8RmCnrtNsXYcDjFkEhMHEd9pHgT
         DCfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=i5cRHHCicMsppSSBbFWeJPgqhQ8FMrYjuCKfr4hxLgs=;
        b=S3pYEZCrmDj6hoAMRObtOSdx4kYYnk0j4A3RzWk5PifJav6wz8Tn5Rhg2Hh6ABWJzu
         j9fMyRvVt08JXrwlGDbm0Ou1SlJ2vGd7tqdRHjHOYxIm+8l254bl9QLcb42JDZWPZ8Gy
         r+sge6dSyuyjcyRjNvkWoIMD6rghouaqeEupL2QqbzLco2c+AxFney+pA4DdyfNVtgex
         m2nosrZtoct1vTEgzTWE02M4dDCnhoBry1ZkwWPFyXj8W08JrR0U06OqyJqVbTJBE/xP
         BJlO+kx/NdUwHifQCyXhx98X0UoYqY1DraTmPJExuqEe4oGXJ+6LVLx1Y92AvHIXBwGn
         yAWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sT3L0ZTG;
       spf=pass (google.com: domain of 3lfh1xaokcjev8yczj58g619916z.x97638fi-775gvx5.9c1@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3LFH1XAoKCJEv8yCzJ58G619916z.x97638FI-775Gvx5.9C1@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id u39sor2788947qte.45.2019.06.03.09.56.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:56:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3lfh1xaokcjev8yczj58g619916z.x97638fi-775gvx5.9c1@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sT3L0ZTG;
       spf=pass (google.com: domain of 3lfh1xaokcjev8yczj58g619916z.x97638fi-775gvx5.9c1@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3LFH1XAoKCJEv8yCzJ58G619916z.x97638FI-775Gvx5.9C1@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=i5cRHHCicMsppSSBbFWeJPgqhQ8FMrYjuCKfr4hxLgs=;
        b=sT3L0ZTGkrRVM9BsAKw3Is1YEd5yvotnvZZfNxBe7skB1Imy3yNX3RzPcWZ3L4hBJj
         Ir4PWq35E8DDBUgoDYzLkuASMa2VdGiH7s1U8yAi9EYUyTsOvvYIL5k/dOIxx+s0hJjp
         ivARA7eJCU7WpCZIyl+ggUCauMPneV4kiO9mITdC3bmCRoqBY9+znI9pjppaD8UIqueE
         q8SkWjwj6UsZy3S43cNZjsMLUMGx3YCtYO4jYJeCvlUuA0j/KAAmJ8e05Wl5fyvRzmAY
         H4Wc9GjlHrhbudDD44rVO5eJTf6U73Fu89LC7maXdjap9rfTt5/4PxbL/ZJXa8oMOVpN
         Mbbw==
X-Google-Smtp-Source: APXvYqxlndJ8+4ezg3WqxZgwPuj7croHV+8pOSI6UJilulRqZobP0HRc/RuNHVT76apRYIt7gunvINxeeY21hcHq
X-Received: by 2002:ac8:2817:: with SMTP id 23mr23534732qtq.174.1559580972876;
 Mon, 03 Jun 2019 09:56:12 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:17 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <c529e1eeea7700beff197c4456da6a882ce2efb7.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 15/16] vfio/type1, arm64: untag user pointers in vaddr_get_pfn
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
2.22.0.rc1.311.g5d7573a151-goog

