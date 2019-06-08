Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66CE0C468BC
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:52:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 212F2212F5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:52:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="jSdD6RhF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 212F2212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD1D46B0276; Fri,  7 Jun 2019 23:52:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A829F6B0279; Fri,  7 Jun 2019 23:52:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 922C26B027A; Fri,  7 Jun 2019 23:52:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0116B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 23:52:48 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w14so2532153plp.4
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 20:52:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=FvOvhN7lAMb05Jgucbn4i/kkfk6C+xm00bozwGUiDHE=;
        b=XRnRxjNtNU9oaQDWjoBABU/eBIeWBWa2mBIfQ1XV4w9M3QF1PqkUTXsgG+LYdoECPc
         Iz0w7jsGuh0tsmbAZYXvnfudS2HjBbiT0oSy8z/+5XWAgx2XjgUxjT3U+quOOUZJI7wx
         suEaMbsNoFDR7H2ZQlkmi2xS8VVh6hKE5n4yMZBxptlr9J+kZu0/lM01W6l2VytqiyiO
         YIU5AaVXDcl7KWLYqSu0vGfEfNg6Wukitt9IANXKy72HIOB8/hxGXSm29c/13Jb7XDgh
         Yy5j3OYsARJd++Pbz0XWb2w7VygRLK1TMKDR8ZmVMTFVoR6WUtLaV1KUlgenLy75EaCB
         2D9Q==
X-Gm-Message-State: APjAAAWI4fMOZdsFrPJdp5fRqy3Agf7r6MDIm0uD8FW896rVPzz2KyQM
	hbcjcZbFLuTkjyAGHWQgLNk/4UcBIRwSEtQBgjxtwYfdO6IoRTMfcZ++14iAnOlWZrifOVvyhIC
	bSOvlg6cWk0M9kzqa8JmYPMvSrFqNigkbhnx1uwfInL6PBOx1HBbdtMf7GBCeQHGz/g==
X-Received: by 2002:a63:52:: with SMTP id 79mr5801959pga.381.1559965967992;
        Fri, 07 Jun 2019 20:52:47 -0700 (PDT)
X-Received: by 2002:a63:52:: with SMTP id 79mr5801930pga.381.1559965967257;
        Fri, 07 Jun 2019 20:52:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559965967; cv=none;
        d=google.com; s=arc-20160816;
        b=e5tMm9C++2uqxtFR4+LqjkaKLdI37Bc1lM1vZH3ggiRMAj3VY39Ds56HU61j+0Ywvq
         TjuaV7gieXDW84yYO4pnwL3yh90g3Lbck5Hei2GGTmurkOgbDlH6l+3v0pnSWNYy5HO9
         O/EpYJpvz/yXQC8AeYOn7UkJ41OrGY6jCEYXwKp3stWO7axIISgvL2a6cltyXrg481kF
         8Zq83304FFHXdXcbaOnPF8v+p63VxmZWDmmnTA6oP+s/2aok7cfMF1eKr7oelStNanQd
         ZtYs7yGcxzX0LMoKZtZ/6vgYolJzd/bPwAYAoXoFWYKbqmZ0r/2/oTDqTOdUqjSUTtTI
         HVTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=FvOvhN7lAMb05Jgucbn4i/kkfk6C+xm00bozwGUiDHE=;
        b=t+8HC4l2IfnWyzqjYdzjqA+5h8HROBi/IzfMmLroR491WkK6CHwvcTpSfoRYwparl3
         9qUzcY/RzirRK7OUrJTl4hAd7jq8LMxUY8z9pbJd6q2mtXGpv75o4XedwwlZCiACVg3a
         AYlYpqpfn5xUqzL9DFDZXxXU7WUVSc+NeCEx6tsPxBBaczfsAJDHvdbw5aWahmtHYXZC
         +378eWQmDOyMcOemhi8cWMVopPiCtiqbAMCryOKjRo7hoowox7KnPMwwSsLiS4zvkAFN
         W8aZ2f2WZbyfDngTovI4nd5qiiVWzBXQSU5so7F75/5dCoXlT6uy9h/AEmcLWsEIajxl
         Ud2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=jSdD6RhF;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t9sor3437640pjo.16.2019.06.07.20.52.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 20:52:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=jSdD6RhF;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=FvOvhN7lAMb05Jgucbn4i/kkfk6C+xm00bozwGUiDHE=;
        b=jSdD6RhFfZkeqgS8TcayMIER7Pkkx++KxJ0VlFLn9BvHk82PjgIJ2PrdItWwSzYW05
         NLhWR71M5RDwErf/bBmmALg5hWrf7JykHz8MqC0HoRPvtnrf7wJZvYnVmInDaDa0hprb
         7Wa5xVFo7VF+cw+RSx/ka7MEiF5SaHkm3s0FY=
X-Google-Smtp-Source: APXvYqwjIf2RUpKbV2HVLPuystSV0iOPs0w3Y10dXMrzubhjEtN6FPReOOA3bdEKg814UJFukvJHYg==
X-Received: by 2002:a17:90a:37c8:: with SMTP id v66mr9429258pjb.33.1559965966947;
        Fri, 07 Jun 2019 20:52:46 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id l1sm3510268pgj.67.2019.06.07.20.52.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 20:52:46 -0700 (PDT)
Date: Fri, 7 Jun 2019 20:52:45 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Subject: Re: [PATCH v16 13/16] media/v4l2-core, arm64: untag user pointers in
 videobuf_dma_contig_user_get
Message-ID: <201906072052.077135B@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <31821f3538ddacb7e57e0248e86a3d28f9789d2f.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <31821f3538ddacb7e57e0248e86a3d28f9789d2f.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:15PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> videobuf_dma_contig_user_get() uses provided user pointers for vma
> lookups, which can only by done with untagged pointers.
> 
> Untag the pointers in this function.
> 
> Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

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
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

