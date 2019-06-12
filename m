Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E5C0C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:33:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2344C2082C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:33:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2344C2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5BEB6B000D; Wed, 12 Jun 2019 10:33:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE5286B000E; Wed, 12 Jun 2019 10:33:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A85126B0010; Wed, 12 Jun 2019 10:33:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7B36B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:33:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k22so26209272ede.0
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:33:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=eQY+hXskG9MfrsSCk8NQ023zNMoKAQxNRyn6p8EG3ks=;
        b=K6LHxdsIhd1L59svH32c+SNI75RLCbyeSRs/4YtKQNIWBo73brNDvy1qttcGO8bK81
         3CKMMhXvRqNQnRRiYRuhwekOItHXvP5r81ptN/S3favvyXp0UfK7eZFFILtgLc3CNttH
         hTOm+cWzViLeuPaT5Je4PK7K+HHQk0xSdWIr/VKFYaTFkx7Z/i4WVn33auoqFiS9Tbur
         Qw4OOLtk460DrA6hiCshbGjAnulKSmM0pZa6QEffyiuaFt8TpastgeU3PtUMlfxdX0vs
         g3aFGEz5yYBO3DyuBwqd73ygH6IXyNEt/GkqaK1ZcpfpZw1lUv6ACkI7GAKeX7XWmqSy
         4v3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAXrj1MRcl+CukGuEzT0VvGr8rWya63aTuAki8pMICpfcsw+av/i
	w1QsCMNe+7O0edyQT3Lx7yMUmvZAc3AHkY7CvOCm5o40VYIPZEdQQ7YaGjAiqULqg6dK4VmQFCi
	QZw/Qe9NSjoW6l6BTYXYYTomWbEXIShtAqlHKWmMdavbfF5gwPnp9/h+D2Je5Mdj6uA==
X-Received: by 2002:a50:cb04:: with SMTP id g4mr76723977edi.181.1560350026926;
        Wed, 12 Jun 2019 07:33:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXdG5LaJJ84QML2Wl4qhPK3Zks2K2S9cPuYUXuNvADnQTQNBgh9lxwW2wxBgAr6Kl+8/x6
X-Received: by 2002:a50:cb04:: with SMTP id g4mr76723900edi.181.1560350026235;
        Wed, 12 Jun 2019 07:33:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560350026; cv=none;
        d=google.com; s=arc-20160816;
        b=IybslSAMfi1CAkAH68musSpGzeOhH1BBDDjaqycBKIN2w3WVXe4HNhmNRt7UHdH6NO
         NKbXDKD+/1dXI4U8sH+91x77se8/iUPw/gPoMEc/ZSAjG650x0X/qqrHoIh3HIJujBxv
         EeqOrg8zEN3cMq/JENeUp2+ExCvluocXdMzksDOddPnBeQlsfUeGW8akmBranaDem9oh
         Xbv9y2teB4jKxdlb0GT74gSgI/h4B7a1LvPvFvNKlSNwi7GBF1bvd7nRZm6FHKBdwsp+
         o6InG3Iy/+jGeCoHEVZIKfGOMcnnjSz+V/VK+j2UhQNQjBTH7CB07HKNlDh2L+X6Xdsu
         d8hQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=eQY+hXskG9MfrsSCk8NQ023zNMoKAQxNRyn6p8EG3ks=;
        b=Do6NTxaPeaoMrw7ydkgrg5/bWGXtRkueFby4eNCsAQlCHMRDIEK7rpSp8CWhUFIg/S
         i58e7uIk2F4l3WN/hcgGwmtznvgZJ2YD2CdBqiQ8AVyZA55GKkeCX+iTHP2csCvgyBBt
         iHC+ur+BrGKHoSQsbuUDCPCcfiWge1dtrUfMECcaHYWhD1H/sPJDEfxzZKS2dWpHj7UO
         Z+IrpxjCo63m8NwVImr1dyd95bQdVYwuTId/2uxojxR/TWC+MiwoiQEpW5hbi87kT4gs
         70EJUm4Z3Djmj3YxVIfi6aqx3DPLmp2ivOWGM5NFwBs0jwkc8IVIfIbEDM6JUnHjGF/S
         dGCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id a14si72555ejr.135.2019.06.12.07.33.45
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:33:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 38A462B;
	Wed, 12 Jun 2019 07:33:45 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C1F953F557;
	Wed, 12 Jun 2019 07:33:39 -0700 (PDT)
Subject: Re: [PATCH v17 05/15] mm, arm64: untag user pointers in mm/gup.c
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
 <8f65548bef8544d49980a92d221b74440d544c1e.1560339705.git.andreyknvl@google.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <8b74a24e-4fe0-3fdd-e66a-d04c359b6104@arm.com>
Date: Wed, 12 Jun 2019 15:33:38 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <8f65548bef8544d49980a92d221b74440d544c1e.1560339705.git.andreyknvl@google.com>
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
> mm/gup.c provides a kernel interface that accepts user addresses and
> manipulates user pages directly (for example get_user_pages, that is used
> by the futex syscall). Since a user can provided tagged addresses, we need
> to handle this case.
> 
> Add untagging to gup.c functions that use user addresses for vma lookups.
> 
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

> ---
>  mm/gup.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097cf9e4..c37df3d455a2 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -802,6 +802,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  	if (!nr_pages)
>  		return 0;
>  
> +	start = untagged_addr(start);
> +
>  	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
>  
>  	/*
> @@ -964,6 +966,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>  	struct vm_area_struct *vma;
>  	vm_fault_t ret, major = 0;
>  
> +	address = untagged_addr(address);
> +
>  	if (unlocked)
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
>  
> 

-- 
Regards,
Vincenzo

