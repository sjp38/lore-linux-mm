Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 978D1C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:59:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C94721019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:59:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C94721019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00DDF6B0008; Wed, 12 Jun 2019 11:59:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDA2A6B000A; Wed, 12 Jun 2019 11:59:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA12A6B000D; Wed, 12 Jun 2019 11:59:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B43D76B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:59:29 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id h198so14111501qke.1
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:59:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1QDczLT6DRcR/MuK3UFTEBWWw+z2O29evyvt58HX17Q=;
        b=Rcsg6Rbq61bn1+O451/J+HAJVf3bKAwzSzpwlkMXg5jN80Gn12RSfb4U9ACyi2FqH3
         QiSqFOZoWRYQ0WCjGUN2bQ7uj7p6gO2sDLpn7jxk3j/OPPFi/sjJhUYqkmBIlgQdFfYB
         5bzEtWHc8tIOAvnvmYPGZrd2Ux8uoF6/uiO/OvVRBq1+pN2GEpIcK2u1ewGm3hfgSyVI
         AmYsd4jWx9eL6rvvYuCYlqQFTcVnLnLY3ZI7uyVddNo6gBvGNFQmoM0PlL3bvpJNGEbY
         C7n15SnrVIVQus3VHRvNLemmF/ZwAtecqgQTdpZUzMfVOADXnUnt22QR/M1HhsaARYFq
         NE7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of eric.auger@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=eric.auger@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXERkuJldtrrf7ju6v/pyj9wOP965iESoMwPRj/BQtjHl2wvdX3
	zOrqbl35Ucz1iw761UYC38IBRnI71E5/hWj+x7kC6lQ4FE0lEiawh6wu3kdi4mGAod7mzzMBQAG
	XQeIiR1294COFWNUjno1MSOKJR93lBfEOleYp/kCfwvu/OfJkFZ3DD2ls0CNJzMgGDA==
X-Received: by 2002:a37:2748:: with SMTP id n69mr16426680qkn.275.1560355169499;
        Wed, 12 Jun 2019 08:59:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJEQ7UT3qEEUoUUjXKkgWYRXre43QUZgTdZC/L0ecljxGIC6Gr63/+hh8Ch1/sOUh1GPYI
X-Received: by 2002:a37:2748:: with SMTP id n69mr16426614qkn.275.1560355168814;
        Wed, 12 Jun 2019 08:59:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560355168; cv=none;
        d=google.com; s=arc-20160816;
        b=bNJ+fpIvGuXSe9bduR9Fz3SfyhE7LC3zdRLyiTU1vpxjTlb6/x5OCqTWoWa6/lqqb+
         dZnhpr2ETDva+GMTbN/0FSzRvYoUJRMZJZGCbvPAC3AlDz+Fvy9Ik265a3D+3TtnScLR
         lEOpAsGUQ/Vh5C0UT4nkSmPcjj0pxCbZcdvlgmz64TMjiiLI+BUAw3BeSFWBW+b4yOQR
         Uv92kaXm/AgpLWXHBnzP8nNy0U1Q2z7CTMWlp+E1bp/OmvYD4y31UMYOU9aJR4gYDkMR
         tnvAU7VsJc1opsSE4GusS42SU0Ru4eQhKdWBuW/E8AWdMj3DE1O9SBUCbpOzinUwiapA
         tdfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1QDczLT6DRcR/MuK3UFTEBWWw+z2O29evyvt58HX17Q=;
        b=ZK62cPewVreK/d66OZ6rEZIur68/ss6TNS3QnAfAmOOKDkajreNjZ0kxB7lzTCyFJz
         YfTWHJ0DAOn4Mx73FJsRfT8l00suLcZMnXsekiiCNgBLyKcfyFt+pgd0MHhy0VlG0INw
         e6Ogi4OdT0YNjqbGtBTfXOoJ9LjJ2zodpk4sn5BUDDVLJHFbrmyX0D1vwRgd8OV+KKNP
         MpuIjbNNtjmEuluwBKuBI3R9r6STP82F0YS7mHaMxcwPN2m8P8a8mc4H7AenawZBAGDn
         bhreJuMhDIYHlC7capC0SoghVE1jdbfDiBPxaTXgf6mRuudqYAEnPqSp0g94AL0m5TQI
         OGaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of eric.auger@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=eric.auger@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c25si221265qta.234.2019.06.12.08.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 08:59:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of eric.auger@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of eric.auger@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=eric.auger@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B96E4223882;
	Wed, 12 Jun 2019 15:59:17 +0000 (UTC)
Received: from [10.36.116.67] (ovpn-116-67.ams2.redhat.com [10.36.116.67])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7B463183FD;
	Wed, 12 Jun 2019 15:59:01 +0000 (UTC)
Subject: Re: [PATCH v17 14/15] vfio/type1, arm64: untag user pointers in
 vaddr_get_pfn
To: Andrey Konovalov <andreyknvl@google.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
 linux-media@vger.kernel.org, kvm@vger.kernel.org,
 linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
 Vincenzo Frascino <vincenzo.frascino@arm.com>,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 Alexander Deucher <Alexander.Deucher@amd.com>,
 Christian Koenig <Christian.Koenig@amd.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>,
 Jens Wiklander <jens.wiklander@linaro.org>,
 Alex Williamson <alex.williamson@redhat.com>,
 Leon Romanovsky <leon@kernel.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>,
 enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>,
 Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>,
 Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <e86d8cd6bd0ade9cce6304594bcaf0c8e7f788b0.1560339705.git.andreyknvl@google.com>
From: Auger Eric <eric.auger@redhat.com>
Message-ID: <ac482b04-94b1-ab29-97cc-3232fc44b3d1@redhat.com>
Date: Wed, 12 Jun 2019 17:58:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <e86d8cd6bd0ade9cce6304594bcaf0c8e7f788b0.1560339705.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 12 Jun 2019 15:59:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrey,

On 6/12/19 1:43 PM, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> vaddr_get_pfn() uses provided user pointers for vma lookups, which can
> only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Reviewed-by: Eric Auger <eric.auger@redhat.com>

Thanks

Eric
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
> 

