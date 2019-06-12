Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFBA3C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AD2E21744
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="l/pAL0pY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AD2E21744
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B4356B026B; Wed, 12 Jun 2019 07:44:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 363C76B026C; Wed, 12 Jun 2019 07:44:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27BB16B026D; Wed, 12 Jun 2019 07:44:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 045F66B026B
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:44:16 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id y205so16943726ywy.19
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:44:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=OMWTVS19S/O2L7wjAg8YO34JfVmTuzDlFYDWpvnlfdc=;
        b=T9Wy11RcJ5MaYUY6udvxX/37pdKEW+fna/Am6BV1l46uu2VCXy171+5dZmK/jA0yez
         OLMr0loUiYxXvfflGYTmJiv2lzA+5qwj51HOAKkQqhqcnGaYfpqV8Fps68kQqpSMUBIt
         vhT6+ACslzdqc4X7ZtUmjYvQR6v4gaXrPY7yx4H1jLVWYQXPRs9tM0D3p3KWxQDPE1hx
         xSX7G7XLH1bN/wKczeD2p1OBZJfjQ7SjNL340xUzv7rFx9sp04vZetAAuQBmrPqmkQS0
         7n349sAB/WTfw7oFoRC64s/7VcJcTudwU4f0zbC5gmAQVAmrI0A+up+XJvVMUnQ1mxJ+
         keOg==
X-Gm-Message-State: APjAAAXAzs7b8bGNXUOaiG+PnwRCL7n7khUy14IfUZWWTD1isYzft7tL
	QJy+1dNQBpVHfN/xD098aHxgNqEbVfz0nDr1/5mwVWUt5tnc5ggFbeXyKLGpD/oBOcwOWvWd58h
	33K2EVOxmNVVOm/d5d1V87/0osFuWu517x1XGdnH7xuUvKqUT2y+NgYCyOddq/5cRBQ==
X-Received: by 2002:a25:d4c5:: with SMTP id m188mr39154078ybf.60.1560339855763;
        Wed, 12 Jun 2019 04:44:15 -0700 (PDT)
X-Received: by 2002:a25:d4c5:: with SMTP id m188mr39154048ybf.60.1560339855090;
        Wed, 12 Jun 2019 04:44:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339855; cv=none;
        d=google.com; s=arc-20160816;
        b=N7XC8aoRVTuFo+vb5LDxNAiuly+QNnTRw6zPCeWlMN5MNKL25Z+eGB54aelXgd85Vk
         14Gr+L7mq2XHaPblmFxQ4sWhnl9qra7ybnomcW4iRpqXp3zEP2WANYv15nWs9U7J8XoK
         NSCmwYStwEbLhZU9IDgaJo5NLn3zwYVFcbGZ20as/YsCVhzIYPXBxwnigtjOEVFPsDc2
         acCwRX3fIYD4AHf27MDqtBVap82SGDwUJ3vdL/jPjDahHp1CF3HtzxUAD/hbIRaCwUuP
         COwzMjU2Se+QzBs0oqnaYySow3sevfjhnjbCV1RIsZ74YBAEgdZY8l+Z+GuS5cG4Dbfr
         kXKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=OMWTVS19S/O2L7wjAg8YO34JfVmTuzDlFYDWpvnlfdc=;
        b=dSVPdLDsH0f5P3V1Y3KmiKLA8EHeAYJyXXwh4r8/7VSrH9Kq+ssEWXJ+U6T0yEwOSm
         vQmRLnQRgOcRlkGdRNk0JEsetwAq/P0w42vweAfazTTSIUpi8RUKqUKfqUDFA7pH94oI
         sem/lO/67s/5rDXmOse4PoWTJ9JwO2z/XOB8f4LqxOh+CZUJca1r7xATqn0NphgTxywq
         jD6S+vEj1TRqSbnXEWrZA/u1JCpYVE5UuI7Hz730E9MamAAkyhdGq+TxvMZ4BoefroM+
         d4lB+GB/NO0pxUdSX+ueW46mk/Jb/AXiNuPoSouYltWDEOxAXPB/OBRL+UlkkoVclZWl
         YJ7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="l/pAL0pY";
       spf=pass (google.com: domain of 3juuaxqokcesn0q4rbx08yt11tyr.p1zyv07a-zzx8npx.14t@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3juUAXQoKCEsn0q4rBx08yt11tyr.p1zyv07A-zzx8npx.14t@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id k63sor8086281ybb.163.2019.06.12.04.44.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:44:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3juuaxqokcesn0q4rbx08yt11tyr.p1zyv07a-zzx8npx.14t@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="l/pAL0pY";
       spf=pass (google.com: domain of 3juuaxqokcesn0q4rbx08yt11tyr.p1zyv07a-zzx8npx.14t@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3juUAXQoKCEsn0q4rBx08yt11tyr.p1zyv07A-zzx8npx.14t@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=OMWTVS19S/O2L7wjAg8YO34JfVmTuzDlFYDWpvnlfdc=;
        b=l/pAL0pYNwxIjhI4A5Di3+u8zRy7KDPlydIoJClA3OuILFZkNAGW7KJJpakHJKu6oE
         BOdwx+v3Y6mB0EaDg1WhpBGkC44sbC2cWM9OPunZvHIIMbKjR7+B/dGr9AjLsLmz2Olt
         nLMYnF0Wzf15zXWsTdJBm9qmaTa4PXWly/FRd7uizPU6BFseaNjpN6LtFlJq58pOQv7T
         WsZKhldlre+UFCD7WiBxmS6BBO31lObcc7zusnLdA80L2jwrzKGvI3ypNGCThs2lIqG6
         VybQ3v2ZWx5KHhiRN49MNNAagP8G3S94nC+koOMwbLACD7/N8Wf3tprbj1wNC/YGyAaz
         DFPw==
X-Google-Smtp-Source: APXvYqwTs0S91VLJ1vEb2xUG3SN6RjfUTygp4K8Hjte1QQ8AktyAJh0LJ+M6BJ5qwoi87JfKLCpvnOyNNEEmSEtd
X-Received: by 2002:a25:aab0:: with SMTP id t45mr38754945ybi.201.1560339854764;
 Wed, 12 Jun 2019 04:44:14 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:29 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <7fbcdbe16a2bd99e92eb4541248469738d89a122.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 12/15] media/v4l2-core, arm64: untag user pointers in videobuf_dma_contig_user_get
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

Reviewed-by: Kees Cook <keescook@chromium.org>
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
2.22.0.rc2.383.gf4fbbf30c2-goog

