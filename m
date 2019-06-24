Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7E50C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DC88208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="R52F0Fd2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DC88208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9FE08E0013; Mon, 24 Jun 2019 10:33:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4EC78E0002; Mon, 24 Jun 2019 10:33:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3CE68E0013; Mon, 24 Jun 2019 10:33:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5608E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:45 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id b85so6431571vke.22
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=v2NimiCS5k+CASkvLG6PtbLfdsWbdfRiVRoN94NNZxk=;
        b=G2oXq+Y7gGhqQyPj8JDhOSzXg/bj4fQfWhA70JHzVO/u4U7gy9LezgoGQh8IARFeYz
         kYC3iF0drLpjXjEqleR4+p16EHN7CfLYDM4KwVGingGaLkOLiFNySYTdSSOm0HmGP80X
         ++DBsDDpTNqdIJzbEHTyqe1zuRox/qXc1c0sFYfOUSc+cGuvThPW2pYAXMHUv0mSf8Tq
         PeXeYZIDloe1lsGyzXI+eXkNkgT1rpQUuAUG1h+z9Goer693kQPmPvInNZf9VqQTR2lW
         trddblm51yFZqSSafd0d8AvVQdCTr8ME9uUBm62I1pZcZcmqoKuOu3ni/Q6P11FHg5iK
         6hMA==
X-Gm-Message-State: APjAAAUfug8d4beNoFTRdiatULwfqvX5gp2W1TCWIe1DXTm/bhKPsxsx
	3Jx4qV9t5+SHNqN4allsGgVaFh7ewMMoRrN7qWpRkb4ElP6g0gXR8RIhFPNBHqdB8l39ZwRU2fs
	HSED0q33w1ICzCMa7pdUI2tavsZkTH26MFYOQXnCAFAkEjzFkoft3ca1eQEIah5Ml9Q==
X-Received: by 2002:a67:8e0a:: with SMTP id q10mr13655920vsd.215.1561386825388;
        Mon, 24 Jun 2019 07:33:45 -0700 (PDT)
X-Received: by 2002:a67:8e0a:: with SMTP id q10mr13655880vsd.215.1561386824792;
        Mon, 24 Jun 2019 07:33:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386824; cv=none;
        d=google.com; s=arc-20160816;
        b=wKgfrwjDaAe9n7BT+lxlRnQ0j8Qq6S5/hhucSEsb/cw4LVmpMr1k1u++VwthQkE/fv
         ul39TrFwMdpqPpwglpfo2g94YAcjLgR4vuI8O5gq1fJR9FhbEwDRZzN8SxjcI7SSOSLq
         n6mbrn4v7St4HyYmzcVonvniLN9Zf0kqgAhJ/v358Ge/2FBDwqXewvXejp3NcjN5opzJ
         /ZopVWu+0qvo88am973/gN4cu3V8ZPqEaQiEAb+d9p06dXsS253M4C7uA9rZvDJ6UgOf
         fvGvVFHY+3n8Mo+ZcpkH3+AOcmpOLJNf4GB+BaKAr+C5woJznGdMSlBnYtbJKoBil2iL
         2eSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=v2NimiCS5k+CASkvLG6PtbLfdsWbdfRiVRoN94NNZxk=;
        b=bcZ8pV6vQcqwjDZTxHVGhm0ieAFJA3VGTe1eoCj7nNJU1osIb3wtVZu5J7IDIZBvdD
         dqBXzAFQX5aJLtBw/IsT4u35pMoMF+l13jxko1XgehLHyydsnUsnMkZE7e7ddpvDHdqw
         qRZ4O4+NKNqpVBtI1mz7pFdkc6ssq2vAhHv7kA3p+sIuS5OU3Ichp1pbGVQEb3dqfYSh
         p3BlleCTZM2WiLPrWCzUc2cCxB1Zvfhtom15IQhgaZJjgHLNAOyZb+C0jvlww8Oy4LyY
         Ytd0PGVQE8tbxiu3s83WfFQ0gp1N+8M+miDxB7PfbsKm2zuDFGPN2FJD4JvXLGtoTev6
         7YdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R52F0Fd2;
       spf=pass (google.com: domain of 3sn8qxqokcdkviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3SN8QXQoKCDkViYmZtfiqgbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f2sor3552013vkb.32.2019.06.24.07.33.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3sn8qxqokcdkviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R52F0Fd2;
       spf=pass (google.com: domain of 3sn8qxqokcdkviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3SN8QXQoKCDkViYmZtfiqgbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=v2NimiCS5k+CASkvLG6PtbLfdsWbdfRiVRoN94NNZxk=;
        b=R52F0Fd2shfIFR4q0bGdXx41jOC2qnPJSQkzVjeQeg54HgHR1/LLyouZcbT5pvU9ph
         IHRux4iRMn4iYjvIDENfWOq45LSEDCPbYqCOQOQrImK8uyieit/JhMM59l/PH48sLiy7
         OI6R5A3fMrdUIOLYn31VebhgCxKDAeunCFpurDmVgRp0CrVsEJYad0EcCQYYY+TsPx7Q
         wTuXqrZzi+DWvrwVhM13ZxkTrFcZ7WmDz7dFzgsP/AanzslvHIEdFMM6FuW5iowuC8jA
         iMOcgKpuXLtNG/lXst1VUVtGfDLMhPKtSnYwCtLyaY9LkXb2nkdEdjD68Dx6hEKz0c54
         IyJQ==
X-Google-Smtp-Source: APXvYqzc7XeUiJjoodFNDUni2Tg0W5zegM0Bn90vNeBUMt6R6CtCKJP3h/iCRJwisxZh4IB/OpGm7X901/iCtFh1
X-Received: by 2002:a1f:ccc4:: with SMTP id c187mr4785454vkg.56.1561386824379;
 Mon, 24 Jun 2019 07:33:44 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:57 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <f28f0374a8ed0985d045ce1959855c1e35dc138a.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 12/15] media/v4l2-core: untag user pointers in videobuf_dma_contig_user_get
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

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

videobuf_dma_contig_user_get() uses provided user pointers for vma
lookups, which can only by done with untagged pointers.

Untag the pointers in this function.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/media/v4l2-core/videobuf-dma-contig.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
index 0491122b03c4..ec554eff29b9 100644
--- a/drivers/media/v4l2-core/videobuf-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
@@ -157,6 +157,7 @@ static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
 static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 					struct videobuf_buffer *vb)
 {
+	unsigned long untagged_baddr = untagged_addr(vb->baddr);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long prev_pfn, this_pfn;
@@ -164,22 +165,22 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
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
2.22.0.410.gd8fdbe21b5-goog

