Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15679C48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:34:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C263A2133F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:34:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ql48XStL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C263A2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DECD8E0015; Mon, 24 Jun 2019 10:33:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18F4E8E0002; Mon, 24 Jun 2019 10:33:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A43F8E0015; Mon, 24 Jun 2019 10:33:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD4D08E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:51 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id d14so6447961vka.6
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/YALAWfXM1Ec4B1lOAT/D+NA+cyFiVncn64tZ/r98OM=;
        b=cWDxb5BfnERv/znrWJeyJ3ouCzUlgcxpNCpdteMjzVPP3+BXDZ6FbZ4nTRzTgVi7DZ
         U0Nre2DKE7rS5bBt6OuR1uXHvURhj6txz8hztU4OBZFpajMBFmcq6d6Yt943OTfkx4Tn
         bKGVA+ZLZgdd0y6s/yr7KTxt/WuU2zwcN0hyceUAx0WnwDGP5vnION5w+HqnmdpAqkPR
         UrLIp8LSmnHF8AFe4eTwLQz0kM8DGjZ1dBqpIf9LeSxCcPoJzT5GCzA4++M3bc1GXTOs
         250IjbJySbG1o4UZ+CcJFpzuvN4dLO/v2nUrv21KViFAMfKQmPsmu+lQSfqRacIful2l
         SJ5g==
X-Gm-Message-State: APjAAAVgsYuiZgpbmmm0UQ/ab24TVeC5ezEpbhRbVYhplWnJZ2ouIDC5
	myqnvn5cCKxuNxw87RehoHtAXAXgwOxXsHY8b/n0/JfPbmRHViLKYP6EVReV+QhZoZDZCZEa8Um
	4no54ZQCn9tC/1YBMM6/Fj9WF4uFOQ0+ogLbqdJSxeCI8gEFskIlQWvpEXScgN4cfWg==
X-Received: by 2002:ab0:6788:: with SMTP id v8mr4548940uar.48.1561386831620;
        Mon, 24 Jun 2019 07:33:51 -0700 (PDT)
X-Received: by 2002:ab0:6788:: with SMTP id v8mr4548913uar.48.1561386831013;
        Mon, 24 Jun 2019 07:33:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386831; cv=none;
        d=google.com; s=arc-20160816;
        b=GoS/wKdSpiOLvZqa6oLzVElIalDXzuxMrUm83rihclwOAAeDH3aWohEeNAPP/lSS/a
         YA26qfwdVf8eyCzmOFFRP4c8yU8Ze/J37Q1IdC1DH5r0BIh3gYvwNKkp2/Wxem7fc4bx
         P6X9RD/YK84pdtLKo9PSt6ibU2O1hm/S99tbN7g6TB+JIgT6DQFthhvsI06xVbPqfeND
         +LX50LbXDfEPSzv8BvFE8DhFkb4/TwEtPCk6Og9J0XyKWTDocxhbotBziib1GyPJ2TbY
         pZZ6vzqbXD00YMHLA/3HtJQf5Z2mwTEXf63ab7ASoTD2vs5sNbQ/V7VBCpzgBViQyWMy
         BuaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/YALAWfXM1Ec4B1lOAT/D+NA+cyFiVncn64tZ/r98OM=;
        b=HDqRp1s8Fa/23JZp+XXmfwIfwuCXAxpOvVnOhasrZ3rWYL+G/IltOeQA0UxJ7VVTFq
         CwrUP5JgAmsGaV4Tkm1f6VEP9+TNhTm12T3kvUUS55lx7BCsYzTrAlSuu8tTb0Q/QQqw
         kVx8jEBJFg9cRO6/Wu8R7Po8rvikpHBI4YQiZzMHlarbxp379SYP9F6y+ryQiHdvE5uS
         jjcsm2u1SF8PInuHCLk8kuG/TLhd79sdUblL7oc5fg3m9J920QZQ81pHn4jxx5Ogjcl4
         UO0lx1DQ8cU4VRgpCH1vsiwFlsyKXq50/Cx/peCELl0mxNUqxAOBThvLRs5npEUAjKii
         dm/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ql48XStL;
       spf=pass (google.com: domain of 3tt8qxqokcd8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Tt8QXQoKCD8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l64sor3412285vkg.23.2019.06.24.07.33.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tt8qxqokcd8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ql48XStL;
       spf=pass (google.com: domain of 3tt8qxqokcd8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Tt8QXQoKCD8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/YALAWfXM1Ec4B1lOAT/D+NA+cyFiVncn64tZ/r98OM=;
        b=Ql48XStLri/shxEZnh2m2bPKZuWW0LbLVZb7Ke39XzoW6tnlHJqvY/w3tAOiQXd+HY
         +m0w0vy4Nc92IOCtwaAefDtVWKaMPae0qEokqCFh/15Etg3mPj9l+0y/QojMsq+32GDL
         FCc4x1guuctj7Dh9w2rpqoJJMnqXSJhRdYAnuBaH1m5ApCPzHjNZOJsEgqVYOMqcq1IK
         z4bmcgqikB0YNciNmYj3+oZnFq+Z3IRAKc7+MbjrKJ0m2yo/N7qQZlR4Wduu+I3SYaAM
         An3oELmPbKJBGAW9gnsznPT0Ku3QQIngN9+ygpAFQEEHuUfYflrAf46HUzwiWP0xvwhX
         EWWA==
X-Google-Smtp-Source: APXvYqzcPL+MfuI0G9Nd/HSZW5720Hxob5Qe3sb32I8/yavc0Ub0kNUbvXmDnUxRuwL2tRyo+O0TaelZxw+BF2mv
X-Received: by 2002:a1f:7dc2:: with SMTP id y185mr1688822vkc.51.1561386830607;
 Mon, 24 Jun 2019 07:33:50 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:59 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <125994bfab8f29da8f58c8fcd0d94ef4bf55b3ea.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 14/15] vfio/type1: untag user pointers in vaddr_get_pfn
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
	Andrey Konovalov <andreyknvl@google.com>, Eric Auger <eric.auger@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

vaddr_get_pfn() uses provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in this function.

Reviewed-by: Eric Auger <eric.auger@redhat.com>
Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/vfio/vfio_iommu_type1.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index add34adfadc7..7b8283e33d10 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -381,6 +381,8 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 
 	down_read(&mm->mmap_sem);
 
+	vaddr = untagged_addr(vaddr);
+
 	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
 
 	if (vma && vma->vm_flags & VM_PFNMAP) {
-- 
2.22.0.410.gd8fdbe21b5-goog

