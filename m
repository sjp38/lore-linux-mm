Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C716C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 13:14:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3F7521773
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 13:14:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bUkJxWW2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3F7521773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B0196B0006; Fri, 24 May 2019 09:14:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 661546B0007; Fri, 24 May 2019 09:14:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 550E06B0008; Fri, 24 May 2019 09:14:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0AABF6B0006
	for <linux-mm@kvack.org>; Fri, 24 May 2019 09:14:05 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r7so4465221wrn.8
        for <linux-mm@kvack.org>; Fri, 24 May 2019 06:14:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/n51XGtaWTFL2kzn79WHLkkiSbCnRxm63xReP9D+Qhg=;
        b=Wup46yAVONiRuyTToYJ6+hvWZuf5nM7Cpvr57vqEYM9r+MpYCzI1KmloNcN6DgNq/9
         jYEkjcWP0/TsT6A3XMfmxVLn1UGpPNjuCXoxO1wO89NhpqmqSX3qKv0Pzayv5ltPcykz
         dm7Nl38kInOAyjaiamq0rhXtLj482NSplj7DJtJMxBJBmK4dwZgX0tEEVARzRxEWVq75
         kaDnXhmdaAgmze3Zss+WW95pZNHRaDpCiAanNzZyvyEXzf/IGeropK0uMICFqCHiS48H
         tfbQ3YTNnwjYER6feDW/uGP60XX16Q45qKkHzyqiJKiK7FftDgBIuLZlYL3e+XILx8ok
         ODtw==
X-Gm-Message-State: APjAAAVxYsP0G8F4MRHDOgEfUvFZx0Sso1Wm2Tx7zB9ct+hZCjxQ8lm5
	k1jC8N+Mi75RSujm/Ks0+Fo9dHagCgcRPMLZ7f8JsU3yxarOIMq/dW0obZikFjIYDsjp0Bts45Q
	QfYnm6tZmA3zTMd12DlltOSkk1BfvJ9FsHmC6HtGCpOLLmlrLiOev1rfed777lvE=
X-Received: by 2002:adf:e301:: with SMTP id b1mr32795429wrj.304.1558703644534;
        Fri, 24 May 2019 06:14:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyf4mgLCCKoJ/OYK1+rpJ9lt5y9RbGBrhjyZutRye7C1TTLkHUHuavZqb+TH4QI5NOI3jRz
X-Received: by 2002:adf:e301:: with SMTP id b1mr32795376wrj.304.1558703643794;
        Fri, 24 May 2019 06:14:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558703643; cv=none;
        d=google.com; s=arc-20160816;
        b=N7UA7v/9KgA8FQ5hmOJLRNGCeUTQxUrUuXWLV5wL1fN3fEbk6s4KfBFvOxoAVH4gJ0
         c/kQuDenKwK3gk7W+OZsj4Pk1nLUvq1EavtqfjbvIJGVB9t0ac1tDl/bMOOBSebP6mgd
         5tQD8ET02werc2MvPJY8xj5X4smdgpeZnJpRDpmNADDtfDWXsEZhHLubXGEfl6oYJVGX
         8ZipQKLcUVOBl9TJHg/D2f9Bfe9/tdLkS2cguQ4FjVMER/u5BsD8lRzaWigYhqgzYCy/
         cXDLv+nkWI2mEu/Duh5Q6VfidEOBLDJJ7X5EvhYtKbfZnsuKktykXLTVJExgGAblNoCJ
         6jWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/n51XGtaWTFL2kzn79WHLkkiSbCnRxm63xReP9D+Qhg=;
        b=hz7C9bJbz3l54SfkucICBnO817kb5YcBDcMsv9qkSK57pCCq0JMzyUdZrEmL6CuYyP
         xbzopsJNnMo4+1V6dlntlsBfVj3n6IaIY86rswsjqkTpBvhkkz3pzZ7Mpe7OwhS6BTFd
         TvHt9a4S6ipXdSDYbkRbvFnJfFZlj5TFCz+KgYyh1qWi/mKfzGVRm2qrhEd7tKO3FLVZ
         kfRRSWhoH89UpECcmt+oaqItYSf39SbUaCLlINWOcvWq2l3oAPZl7VC1DH+ywpzqdmI5
         w+KzPsr9K8YUV0CwPGe9755FkAr7IxvfdUHYKG45nhSYhEJelkqkpzrwjA2r4aexWvS6
         50zA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=casper.20170209 header.b=bUkJxWW2;
       spf=softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 2001:8b0:10b:1236::1 as permitted sender) smtp.mailfrom=mchehab+samsung@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id u18si2156823wro.31.2019.05.24.06.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 06:14:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 2001:8b0:10b:1236::1 as permitted sender) client-ip=2001:8b0:10b:1236::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=casper.20170209 header.b=bUkJxWW2;
       spf=softfail (google.com: domain of transitioning mchehab+samsung@kernel.org does not designate 2001:8b0:10b:1236::1 as permitted sender) smtp.mailfrom=mchehab+samsung@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:References:In-Reply-To:Message-ID:Subject:Cc:To:From:Date:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=/n51XGtaWTFL2kzn79WHLkkiSbCnRxm63xReP9D+Qhg=; b=bUkJxWW27UUn0amoOcX30OMJrj
	ZKVRSd1fLa7wKAL02nzw4IuOiQA4rzgr054ftsu9MviuEbu9mlGcvkuzEzVnirDZFWPfHjMMLLRk3
	ZsW9iClnPD6BeArzI/irNnfgAKRVNaTgvodZ4TtoBZwoHm+HpL855LvNq4JvaGdw7aEGxArIj4/ar
	bjQ2iBjNGlyPTpQSCWDE80zIQI9EXYMUp8RizSkmI+AmxIKaaD96lVlDCETopHnXFcxZVFNsAuFYn
	eLi0l7CIdF+p1i1kh/+U5yW0qGVeRM/1NgoUENimwmZJ/qxCwebQt5wRW4slq4faCCWf2/ok2eNHJ
	OcM7Zp+w==;
Received: from 177.97.63.247.dynamic.adsl.gvt.net.br ([177.97.63.247] helo=coco.lan)
	by casper.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUA1G-0007UW-C4; Fri, 24 May 2019 13:13:58 +0000
Date: Fri, 24 May 2019 10:13:45 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
 linux-media@vger.kernel.org, kvm@vger.kernel.org,
 linux-kselftest@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>,
 Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon
 <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton
 <akpm@linux-foundation.org>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, Yishai
 Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>,
 Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig
 <Christian.Koenig@amd.com>, Jens Wiklander <jens.wiklander@linaro.org>,
 Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky
 <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany
 <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith
 <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan
 <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, Luc Van
 Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin
 <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy
 <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 14/17] media/v4l2-core, arm64: untag user pointers
 in videobuf_dma_contig_user_get
Message-ID: <20190524101345.67c425fa@coco.lan>
In-Reply-To: <b7999d13af54eb3ed8d7b0192397c7cde3df0b28.1557160186.git.andreyknvl@google.com>
References: <cover.1557160186.git.andreyknvl@google.com>
	<b7999d13af54eb3ed8d7b0192397c7cde3df0b28.1557160186.git.andreyknvl@google.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Em Mon,  6 May 2019 18:31:00 +0200
Andrey Konovalov <andreyknvl@google.com> escreveu:

> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> videobuf_dma_contig_user_get() uses provided user pointers for vma
> lookups, which can only by done with untagged pointers.
> 
> Untag the pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>

> ---
>  drivers/media/v4l2-core/videobuf-dma-contig.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
> index e1bf50df4c70..8a1ddd146b17 100644
> --- a/drivers/media/v4l2-core/videobuf-dma-contig.c
> +++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
> @@ -160,6 +160,7 @@ static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
>  static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
>  					struct videobuf_buffer *vb)
>  {
> +	unsigned long untagged_baddr = untagged_addr(vb->baddr);
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma;
>  	unsigned long prev_pfn, this_pfn;
> @@ -167,22 +168,22 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
>  	unsigned int offset;
>  	int ret;
>  
> -	offset = vb->baddr & ~PAGE_MASK;
> +	offset = untagged_baddr & ~PAGE_MASK;
>  	mem->size = PAGE_ALIGN(vb->size + offset);
>  	ret = -EINVAL;
>  
>  	down_read(&mm->mmap_sem);
>  
> -	vma = find_vma(mm, vb->baddr);
> +	vma = find_vma(mm, untagged_baddr);
>  	if (!vma)
>  		goto out_up;
>  
> -	if ((vb->baddr + mem->size) > vma->vm_end)
> +	if ((untagged_baddr + mem->size) > vma->vm_end)
>  		goto out_up;
>  
>  	pages_done = 0;
>  	prev_pfn = 0; /* kill warning */
> -	user_address = vb->baddr;
> +	user_address = untagged_baddr;
>  
>  	while (pages_done < (mem->size >> PAGE_SHIFT)) {
>  		ret = follow_pfn(vma, user_address, &this_pfn);



Thanks,
Mauro

