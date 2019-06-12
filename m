Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0663C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:42:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B50B72175B
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:42:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B50B72175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 417416B000E; Wed, 12 Jun 2019 10:42:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A1096B0266; Wed, 12 Jun 2019 10:42:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 242F86B0269; Wed, 12 Jun 2019 10:42:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C77A96B000E
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:42:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so16861823edx.12
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:42:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cD6bUbI/xOI4iE5t5pXwplAQU26tFZFxthYZ1bWs1VI=;
        b=HX0whck6C6vELPR2nOHr9RLM0+L2F72ejGNpOA/w48RR3veTmJGPYDzeqc07S109cX
         PHYVPvRvsx+WcFwlf5f8PKTfnJNKKlNIaddnNe+R3i5QGd6i+suclzHs99tg4Eiim2v6
         WiXodGaTKiImej8oRvJnL7zkbaKFgmFvbM/VQO8qPW9niyU4J3tJIp/Caq8l/PquRNHZ
         ikunFkxrJBg1KgMD+mijPA7dpfFmq5pMeOk5SgXTPuu+K+xVCjTtWAH+FcWqOp45DIod
         15YiW5syz1NRa31thFBZSv61OTTABleqIrvgT0Yi0c2DVrixhOVks0IXDKkDjvm3K9WN
         4Kaw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAUHyMwuHy42pOdUpUrlgy+0+Fj4mzQ94Bn8lrDQRevGGHUTtVn/
	hcfakt3dVoxfEzOE8spc6mnAmD9Yeo3Q0EhnGhxeOLuzHEBVQyZwX4bvi51InankEe3KmGS6FaV
	MM/wPfHC0dmDPdW6fcUG1DMgrcbs4eGVbxMZXeW+3orsBouaZZxHfmLzqXVqWzGv7Dg==
X-Received: by 2002:a17:906:724c:: with SMTP id n12mr69464916ejk.164.1560350526255;
        Wed, 12 Jun 2019 07:42:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7QFmxuedXhdYxEJqpELat4XxbRJCKG/ySrZJOYPiHpJgKEU77EUR4ZvYTxlAhbzfUDjiR
X-Received: by 2002:a17:906:724c:: with SMTP id n12mr69464831ejk.164.1560350525240;
        Wed, 12 Jun 2019 07:42:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560350525; cv=none;
        d=google.com; s=arc-20160816;
        b=ffY4Srm0a5vlltPRsFlElncpJSa+liI/+EhmdjM1P71+zIRlblq7pfe1ZW2valGa/f
         jN0tVkjNYfRy9BDvNLI1S0xCV6zI+VYnxy4KImw0WV68IYBYrMgcWxI+BkQqRsQ4+xAL
         FZzj7/LMd6P2N24XHiMD16bm4LK9PliMEW/MIXKaMsz16R9iHBaMk2rPgtImpm3AbB7s
         ZVVR7CVq8ou9BwfYJ/DljC+VY25EIny9BlczCIEnooBF/HlIJ/N2nBjY/HtgXzQq8mOd
         umUjW360UI0aiGz3zeEHQXyoz//2+Ka4n6h1BgzZduCaZgBKTGzZzsaXCbK2BzwaMqrE
         mkgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cD6bUbI/xOI4iE5t5pXwplAQU26tFZFxthYZ1bWs1VI=;
        b=foKwG85lbiOch+93vDXSQmO20LkVfAKH1c7CcIFOxokXUWMq1IDe/L/a0phDCdMBgY
         41L2IihpczDtBQiBCaMBpGZyUxiQ/HcXazvGoEUvRzN3K32mBstxR51ye2FxpoT8zMFM
         v0j13SJyY6jdYrdSPqm5FOJ/1l51FmA0vmmOSbfyDCy5a4pVz62bkpXSv3dju0mHleSj
         uajNZTWy7QZbY2GOmP+g254Ff/VY+gbu7YBWzPgYpYrkkDE5u7mUIU9+XfAp7qCpCoh5
         uKl5z2qOe/KfzlDlz806bY/i2YZ7qZuPyHKzRmoDFUR+Zv/jNnbzuVVc15vcgpxpvxuC
         4tyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b26si4597709edw.334.2019.06.12.07.42.04
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:42:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6763C2B;
	Wed, 12 Jun 2019 07:42:04 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EF8A33F557;
	Wed, 12 Jun 2019 07:41:58 -0700 (PDT)
Subject: Re: [PATCH v17 14/15] vfio/type1, arm64: untag user pointers in
 vaddr_get_pfn
To: Andrey Konovalov <andreyknvl@google.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
 linux-media@vger.kernel.org, kvm@vger.kernel.org,
 linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
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
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <b7408e72-aa18-21ef-aa80-76b65cbac7cb@arm.com>
Date: Wed, 12 Jun 2019 15:41:57 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <e86d8cd6bd0ade9cce6304594bcaf0c8e7f788b0.1560339705.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/06/2019 12:43, Andrey Konovalov wrote:
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

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

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

-- 
Regards,
Vincenzo

