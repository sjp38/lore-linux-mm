Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1986C468BE
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:59:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA0F4208C0
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:59:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="U7O6NbXB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA0F4208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB86E6B027A; Fri,  7 Jun 2019 23:59:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B41E86B027B; Fri,  7 Jun 2019 23:59:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96F766B027C; Fri,  7 Jun 2019 23:59:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56BDD6B027A
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 23:59:21 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so2533305pla.7
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 20:59:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=rJIAAqD1NAp4Th9vkRNxbBLJIPc3y8ChkLIZvf3dmAk=;
        b=LrTpWh+rKU9EdcrpBrDpz6376ziAyELQJILk2o9Mpmegc5HzrLA65LenlyUrZkg+XH
         izF32TBXmw4iuyizjJgsPlll47bWizf+OA4R7cF1iAvxrI6lL9RIr/kaR5o70r5d46Bm
         I9SLLkr9gQz1msaPMhoGdnznEgzr7LgwBOFYC7961fKDQGhWyUFl9FlFdSsFs+TPUCNA
         0ZdKhWx7OqC4+aAlttaM+6IihoELA6hqApaxJCWs/2bCQwmJLe09VB3uv0oAVHhcdFC6
         HyjXHodTFSJB17O6Ab+LDmzCQXBn7176WmU5/RY98tc9ncuKj37+foCzO/6nYBONwEZM
         l2gg==
X-Gm-Message-State: APjAAAWJCr9TBC/NM8K03fP2zClHmQ5J6ly4hT0NO52joeZuoDe11jAa
	ktD1IMFdReLTpeqQWhWxrq88ubrjwrH1QgNeOXlN5WKBGi3arXMjV9aCdI32GZjxAUY6HHMLLRG
	L0P/lIHtEv0BFFwJr4zlNmFEyKTYowegwkJ6hUCJ2NzR64dQXWk9/9HFCd8BnWnMkvA==
X-Received: by 2002:a17:902:2aa8:: with SMTP id j37mr18842768plb.316.1559966361036;
        Fri, 07 Jun 2019 20:59:21 -0700 (PDT)
X-Received: by 2002:a17:902:2aa8:: with SMTP id j37mr18842740plb.316.1559966360192;
        Fri, 07 Jun 2019 20:59:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559966360; cv=none;
        d=google.com; s=arc-20160816;
        b=wi4DxQrtN1soONsghfxb+Z9m1+5ClLsXyGu0RWkMEgP1/YDSw6VigUIJHpGP3X65M1
         ZkbWtaMvXWmE0JVSQhkD2l0LITFR5TYvDjJi41iwyTaK1NTKzgeqWakAd5LZIjeZWv9u
         o5f2lOMcMXVjYZAj1ATDcdjQxat3UFXKGJT1Y9i7VsRSYgjNFw+5jnhkszffPKLi9jRN
         IXRW3ZmO3YDn4Eh6zAntok405E1RfNhBIkAVnmpVIXjDw53hilgtfv+MuBl68RwYIN9q
         uyTJOqaeHWFq+sp0gNNWI1jb7uRUBwGGCsxnqJLippcC91y1QAtIn1HA8N8vp56lrf86
         VeaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=rJIAAqD1NAp4Th9vkRNxbBLJIPc3y8ChkLIZvf3dmAk=;
        b=Qhehvz986MZgtLG6ziMRaPA/otRnBLQjjFdkv4OrcBvBnljkO2pjdORk29TXeDGzNg
         4VYvrUgUK9DepPx1zkNOi/EOoEFHN1ZbNmIActZwidfFuHUFmedM8t/FKfIlX3gVIynV
         oZ6/DMFdtaDJ+lPHNUZLHPaRK7lnzaMEiDDyshozQgBYbIahJS/nJ21az7FB0hB+tH4y
         W7JXl7eQCn5B3NGnF5VTGDk8tKPCDYC89sqEP1zdlbEmRPnHeJGnoOQBbPiVSzRnZueR
         GqYScO6Y86mMGTj3o5NbEQoYfDnbGUzl+wWvsEx3CNKrkY4vpxBnzYi7pFJVp9XEUlE6
         T6pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=U7O6NbXB;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l38sor4761818pje.15.2019.06.07.20.59.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 20:59:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=U7O6NbXB;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=rJIAAqD1NAp4Th9vkRNxbBLJIPc3y8ChkLIZvf3dmAk=;
        b=U7O6NbXBNIeRlPVLj5xwiYB9yIq5HbXkmt1o7eZLIHcCi1sfFtD4pKc4GGOrbqMYRh
         sgIk+ERejfY1WzlSSBSK2Vn9ctskkWUfC7d9RXEYuV+TF3EleJl2nI9tZYJCJJbjZfXj
         ev4abqGBRmVAB5Xa6TnqWXyvladDJfFjes7a4=
X-Google-Smtp-Source: APXvYqwFvS5ZtgK4hv3bppgp+xNWkWaUdmJ6Dck4NUo25EMo4bji/jhdzX5h+4T1rhnDZmDRvB93qA==
X-Received: by 2002:a17:90a:aa85:: with SMTP id l5mr8851590pjq.69.1559966359909;
        Fri, 07 Jun 2019 20:59:19 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id o70sm4127428pfo.33.2019.06.07.20.59.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 20:59:19 -0700 (PDT)
Date: Fri, 7 Jun 2019 20:59:18 -0700
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
Subject: Re: [PATCH v16 06/16] mm, arm64: untag user pointers in mm/gup.c
Message-ID: <201906072059.7D80BA0@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <e1f6d268135f683fd70c2af27e75f694d7ffaf48.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e1f6d268135f683fd70c2af27e75f694d7ffaf48.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:08PM +0200, Andrey Konovalov wrote:
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
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

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
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

