Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D355C468BD
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E7372146F
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:58:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="C5Gjab6o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E7372146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D18856B0278; Fri,  7 Jun 2019 23:58:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC8A36B0279; Fri,  7 Jun 2019 23:58:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B422A6B027A; Fri,  7 Jun 2019 23:58:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4536B0278
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 23:58:08 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q2so2524829plr.19
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 20:58:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=l14jgAawlsDS1VZ8WGmfB4MOY8oLSSKNbX7PpDlwP4w=;
        b=UTINRYlaG0ruSOqUuf+lkwmaTkXtkaVIboAngmPHZ1oWojABFQ/xCLOknzhmh4yOqC
         PzeAu5PeYCWWaJlhIaz+lz2KCXIBElvlgqrz/qtPZRGF1FC/4zLQGgHxWEZP+IilTj8X
         z/EAnsyGQZJidu+NU4cWaHQy2LHPNX7q4+f4PHRKUnes7E3zhscDpS+MAjXsliunJA3m
         O6uLdy00M+fkC64HBEZGoP+c4SSYRCCFDVbN+2IFPaYtr7bYBRGTXPuyytoPW38w9YyW
         wvBE9ERpGbUVzutEbJedyq3+Eu39PMV2IYu2AFHEVwB2aVOeo3mVv7m1nyGvEhdHxthX
         IUCw==
X-Gm-Message-State: APjAAAUklzcSv/6klzzs/U89vYZnLavWVRVvF/NhnBNQCwb75R8PFCWe
	LKB0cPb8Q5Vm4Vu0Tm2RnpJmfPxAQsKZ15OO/UzwwzmEQv/MShTXpLIEUcUfYfFK0jKx0n2rkEN
	evojAPCGbMQan49JZAx3JmjkvczrRQOKFPyuPzmAvzdnlwOrQm80plRROhGoF+K1aFw==
X-Received: by 2002:a65:5202:: with SMTP id o2mr5433025pgp.199.1559966288108;
        Fri, 07 Jun 2019 20:58:08 -0700 (PDT)
X-Received: by 2002:a65:5202:: with SMTP id o2mr5433006pgp.199.1559966287455;
        Fri, 07 Jun 2019 20:58:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559966287; cv=none;
        d=google.com; s=arc-20160816;
        b=IOpEAQ6KrRK5LKTY05vYQnVzH6n3HL81E3xDG8AuEnuaLUfkEH6/dlK17/TymsS0dS
         gASBCkjZRuvdwZ2covLiu2pmkgibaaMfAmx/luekXU8N/+ucHBExNiJdoJ67vM1WS3ow
         MmZbApeI1P5SBVaTtPvSFicSlHNMl2Uip9ojH4O7n3HpZpttdl39WOGiTqx+ejeWij/t
         N0010ndQOD7aOlx4U91/+cng/VkU2UCcluORbDP9b0qU9VTBkN0JzDjaEg8s3nYkQYZB
         SzvyTXToeupOSfd9z8CBV7CyiHvJ4v7U7LDGrok4BM8im+uPHSBZfYqr6v0s0CUDL4xK
         wvkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=l14jgAawlsDS1VZ8WGmfB4MOY8oLSSKNbX7PpDlwP4w=;
        b=mbh5tAbtrxhWTYN8W5Co9YasQNbZEk+qJ7GwlWqK7kwG1FQUizJQWHNElSBoH7jdVh
         9CfrQl5Hy4lYL04BRAu/oFYQPIQ0wlkb2vjjeRZ+9onTQeqCF/tXa5JTGUobGeXaBg5d
         rxQPu9VMjg9tUCfh/XCf2ZAlqXLaVVO2Exy/Yoiqqt7GlNru5JKybfya0c45nSES4iVr
         Bol6a7y4waibc0cP6f6/IvI/a5VLDWusS+zd3qRrs3Jka1TXo5EeqZkgjThFcWSMv7ms
         FKvFPvlU+KjYnlCytvY3hapLxQmZCogN31MGxoiMTeAvG4h7edQMiWckSUhhqb6djxTa
         S+vA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=C5Gjab6o;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j17sor3553255pgb.86.2019.06.07.20.58.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 20:58:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=C5Gjab6o;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=l14jgAawlsDS1VZ8WGmfB4MOY8oLSSKNbX7PpDlwP4w=;
        b=C5Gjab6oABNd7uWOUXVxMun2EBOiIN1zQFBFmz4oVz6alLd7w4ZDoA104BjgrPqBY8
         M11UcHeF2K3I4znphl64bBg5eiZ8uh03AO1nktwVISAdyYWU8VZro1t6U3J4ibUtkAgv
         yam4Xd5rREh0IexVfq4tELDc0YZWvN5ZcS9CQ=
X-Google-Smtp-Source: APXvYqxfp4HEsqQlOvNH04bl9SHArYk4hyQYoSWfdJS+DhwTyJyuL+IfwdxORVSQ19uSVN9pTMHd5w==
X-Received: by 2002:a63:1657:: with SMTP id 23mr5550367pgw.98.1559966287061;
        Fri, 07 Jun 2019 20:58:07 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id l2sm246111pgs.33.2019.06.07.20.58.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 20:58:06 -0700 (PDT)
Date: Fri, 7 Jun 2019 20:58:05 -0700
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 15/16] vfio/type1, arm64: untag user pointers in
 vaddr_get_pfn
Message-ID: <201906072058.BB57EFA@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <c529e1eeea7700beff197c4456da6a882ce2efb7.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c529e1eeea7700beff197c4456da6a882ce2efb7.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:17PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> vaddr_get_pfn() uses provided user pointers for vma lookups, which can
> only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  drivers/vfio/vfio_iommu_type1.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> index 3ddc375e7063..528e39a1c2dd 100644
> --- a/drivers/vfio/vfio_iommu_type1.c
> +++ b/drivers/vfio/vfio_iommu_type1.c
> @@ -384,6 +384,8 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
>  
>  	down_read(&mm->mmap_sem);
>  
> +	vaddr = untagged_addr(vaddr);
> +
>  	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
>  
>  	if (vma && vma->vm_flags & VM_PFNMAP) {
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

