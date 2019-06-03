Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4C2AC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CE3627425
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eFK1jtlE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CE3627425
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33B416B0274; Mon,  3 Jun 2019 12:56:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29D666B0276; Mon,  3 Jun 2019 12:56:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D3B06B0274; Mon,  3 Jun 2019 12:56:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC8856B0274
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:56:07 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id q13so4520824vke.2
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:56:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Y8tRh8UuVncP1ncRA8ZfIPgOhX9+nAfsBu2vnbYNOEE=;
        b=ub2ThZ4tTms3Gs7+ByaS7+yYNvKw0YI6wvLZTQPwidp1XQN5FQi4k0YO3UmQIr+ILL
         BBJgX+zFqNN37TDPodydr6UyRwKvTBAMqLyIHSBaNBhUjh5ff5TkQDIAa4jriLT8TZig
         gaWqMyGclKP/SNrMyCC7F7aCdpG0pk9a5+WTO9wTjK/Rq/JszPLn4jLWTBOOqexoXg22
         y7UdySt/Xaw7moLEtQw+yqotHV704oBlX03/UAHIyDyNthIJ15RLJRouVXdKPXraMfWw
         1PYMTUUNnNWHHysNGg4cjoGb9ox/kMQDZe4gNWw90DI6w5z0SQxpS7Ufoh7dNijLKx4s
         4H1w==
X-Gm-Message-State: APjAAAUPWokmZInH3a9vEfLNgXqr57ntoDl07lfAoPDrX+TDRyEYxgz/
	QRo1+ZyVvuzCLPaNUyhcFa6g/vnb/nxLB/GobW5jrhUT6GowMiU0OP4Cc2NOSSLvUaFSv1bbYyt
	M+gPxPubt34BsOLmSVtNAMAIgNxHXKb2CyJlSrNkfO7g6wMHZwP7mroVZQj91hSbmVA==
X-Received: by 2002:a1f:be51:: with SMTP id o78mr2671125vkf.66.1559580967419;
        Mon, 03 Jun 2019 09:56:07 -0700 (PDT)
X-Received: by 2002:a1f:be51:: with SMTP id o78mr2671103vkf.66.1559580966772;
        Mon, 03 Jun 2019 09:56:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580966; cv=none;
        d=google.com; s=arc-20160816;
        b=vafUckVMf7j837GlAl3a+/4iVJZKAwYKsoncfaepKV4NVWuXsos8nYCzsj0ZkxPoHK
         GIV3hyfkGG1A0Q+t25QApOQlHKgGxT9WSElReE8thdG1MAuTSNEVbFHXBsEK5DK6sxjt
         RsjZxgJ1bdNZmiA1Iz1jzhEJiCLgzMtavV+Da6yKS3MtlFKTpy0JjTkVd/mQiYHi6sNs
         UuyXlMVWw+yC3ASgiS3WwKF4pN2Boj8wLGedp6nI+cPdU43Q+S22+AkwB7JvAH9kdeOW
         Pxz1LpfKRqnCX5JOVpGCdVPvuQyWwM7nHFVjfLucP18Ef08AMOgt4dyQ26cDU2My/26O
         /WIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Y8tRh8UuVncP1ncRA8ZfIPgOhX9+nAfsBu2vnbYNOEE=;
        b=QeTsKHTiqDMuRfRV2q862tMQL7UJcDxqKVZ02XkEFq/ws+vo8hdhfvK+MdC3QwifQG
         dEmqsKn6i/sbnfZZQo77hpnysxwyNnHn4ANnStgBuR9Wz/359xaf8ii4fHMGQp0/Yw84
         qwyQ1JX8Hdsud+inySrLBHsMo4Q4yDE8OuOIgqp7F5Y5NkEr71ovZuN4KSTPNbkrWo/l
         K+QnahUMyu+UEFaGep50iLW9nMAdWbpC9guXYSSHIjky/WjekHFFn4cMWwsBsPWrBkAU
         X7/P99AwBnlsU0awk2EoE/Wd+UGmepi0vdxa1M0qTpBVZ4SnEIO9GRsPcaa/2kFVNHLh
         xvVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eFK1jtlE;
       spf=pass (google.com: domain of 3jlh1xaokcisp2s6tdz2a0v33v0t.r310x29c-11zaprz.36v@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3JlH1XAoKCIsp2s6tDz2A0v33v0t.r310x29C-11zAprz.36v@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w18sor1222590uaq.45.2019.06.03.09.56.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:56:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3jlh1xaokcisp2s6tdz2a0v33v0t.r310x29c-11zaprz.36v@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eFK1jtlE;
       spf=pass (google.com: domain of 3jlh1xaokcisp2s6tdz2a0v33v0t.r310x29c-11zaprz.36v@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3JlH1XAoKCIsp2s6tDz2A0v33v0t.r310x29C-11zAprz.36v@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Y8tRh8UuVncP1ncRA8ZfIPgOhX9+nAfsBu2vnbYNOEE=;
        b=eFK1jtlEFrS3m2V50O3J5bSuSe+f8SF2oOEJcYGOiFDh2Xi4MGaW9nDUncCGVcGUyN
         tYL5ptbIsLBKOxSfh5JEibNl8mgQflxa8qzQZCZGbKOMu+ue4btTZbmvk6Kxh+WcG+Wv
         fn/kF4y9wQfMzaBiS9+LkicOpt8tKnLL/K7iTnBUbTxgKs5dHlS/ncUSuv8GobYsG6Cu
         6qM+L38/9FABz5BxD3BPgItX9XL5QdXg0jsVIbHzcM5qVU0wJRygy73ep5mkhIvjeckb
         fTT0sIEfasP+T2Y6+uUP2P0imGCc2+QNF2QVC0kVT6BdFDtQ0zPTYlADXVtguKUh5EC4
         AB9A==
X-Google-Smtp-Source: APXvYqzz/ntPC10OZ0frdLABrSNi7hvZ/ytx4Ex3aaENCq428cafLYJMM+5BmbKZZkSR6QrCbMGhJA3iBNJvNJC5
X-Received: by 2002:a9f:25c6:: with SMTP id 64mr157298uaf.36.1559580966349;
 Mon, 03 Jun 2019 09:56:06 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:15 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <31821f3538ddacb7e57e0248e86a3d28f9789d2f.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 13/16] media/v4l2-core, arm64: untag user pointers in videobuf_dma_contig_user_get
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
	Andrey Konovalov <andreyknvl@google.com>, Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

videobuf_dma_contig_user_get() uses provided user pointers for vma
lookups, which can only by done with untagged pointers.

Untag the pointers in this function.

Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/media/v4l2-core/videobuf-dma-contig.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
index e1bf50df4c70..8a1ddd146b17 100644
--- a/drivers/media/v4l2-core/videobuf-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
@@ -160,6 +160,7 @@ static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
 static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 					struct videobuf_buffer *vb)
 {
+	unsigned long untagged_baddr = untagged_addr(vb->baddr);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long prev_pfn, this_pfn;
@@ -167,22 +168,22 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	unsigned int offset;
 	int ret;
 
-	offset = vb->baddr & ~PAGE_MASK;
+	offset = untagged_baddr & ~PAGE_MASK;
 	mem->size = PAGE_ALIGN(vb->size + offset);
 	ret = -EINVAL;
 
 	down_read(&mm->mmap_sem);
 
-	vma = find_vma(mm, vb->baddr);
+	vma = find_vma(mm, untagged_baddr);
 	if (!vma)
 		goto out_up;
 
-	if ((vb->baddr + mem->size) > vma->vm_end)
+	if ((untagged_baddr + mem->size) > vma->vm_end)
 		goto out_up;
 
 	pages_done = 0;
 	prev_pfn = 0; /* kill warning */
-	user_address = vb->baddr;
+	user_address = untagged_baddr;
 
 	while (pages_done < (mem->size >> PAGE_SHIFT)) {
 		ret = follow_pfn(vma, user_address, &this_pfn);
-- 
2.22.0.rc1.311.g5d7573a151-goog

