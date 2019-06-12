Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4948C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:34:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 614C3208CA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:34:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 614C3208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E9596B0266; Wed, 12 Jun 2019 10:34:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0741C6B0269; Wed, 12 Jun 2019 10:34:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E57386B026A; Wed, 12 Jun 2019 10:34:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9790F6B0266
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:34:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l53so26179809edc.7
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:34:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ZrowROO0/vp+tGSfSzUoDcdEpBKwFomIWw/fQYusVvI=;
        b=R77n/mfgovln1LfQTInEe6+N/Ck192NcC++mRs8V6kRc3hfpjdnWaRWrQPCnOjrw7F
         eYdwG2aajddRuOBiAEvHN5T5JZ/JDlZCEd1u+OlQZ1H+GwMHMc9yN1aXZ6dawGymItRF
         idQEEYwrRAqFuq5tw+eWOBu7dAMINrMf5e079z33U1nCmyLUSfhaiQ/02ec+vV9+MTCn
         CrMbbX6T6ZOA/YgDET3scgBtCxqyO/vb40rA3jSTxedIOm3J1kRZMF6hnYkiyZHjEjB2
         XzhZGMWXgsz6satLSrY9IfbMOMtodYBBybPWdEdzYpST5wyEacHjxzSiBWiGr6cylVRX
         1NAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAVeiD7+cBUA9MS+m/WsxNZSgG7VA6mCiE36ypkgzWN9TtH71oeC
	6PVcRCNIwBBPxOTP3aMFi8l7TM8ZRXfxrDy7YINyvenCoKI95PKBcFT+hl/fs8L59M354r0Zith
	uUdH0bleMLpbtzyRYORX4x1jy1elquN4KzOCdx9TbqmABldEVeETIou5ls0yLuDUVuQ==
X-Received: by 2002:a17:906:7801:: with SMTP id u1mr32487974ejm.250.1560350080196;
        Wed, 12 Jun 2019 07:34:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYssrFnMLJQnYfWueBfjEFgQRBp8Zhq7OUwMnihDgBQSEWvtEbiL249ZBOyVGazlM8LGtv
X-Received: by 2002:a17:906:7801:: with SMTP id u1mr32487902ejm.250.1560350079276;
        Wed, 12 Jun 2019 07:34:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560350079; cv=none;
        d=google.com; s=arc-20160816;
        b=RSB4Ud5LG7KkMduIac909g6YvpN0o3aVK3+bFIgWWZ1BtvPbetledSuUNzkEiC22zQ
         u7JCf5/ZPgBX1hCeU1p98KpbDeL7OWQdrE8B4x2/6q0tbvFENbIyGTRnm4MlNR1XVjAU
         Mn12D0J5DbCYULohaFo/O6kmrnioy6WCo1ZbIuuD4VMk7pHz3it9EAo4iGqTJpjd3mfn
         JrmOHzQf080fX9Df+434g45ayLB1m6Zw2JYPMJ0TY2LR+/04N9DuTB/J13uPzXAcp80X
         ND39qcaSMOCZ2T3aCSIKQG54mYBEtJNd/Cbc1YF9K2MZsUc/g/r0qFbBtYTVbj3bB/Yd
         1R1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ZrowROO0/vp+tGSfSzUoDcdEpBKwFomIWw/fQYusVvI=;
        b=Wc5jJuXesdZox7NAptahfYtSxhB/XQzI3T3tUYVHmV1TNoeY+Qs7033elFuusigFVI
         0vFEnVA7wk/Vvmx1Q+m/EMur24yk6o6MYb6uKdNVSdkG5Jricn2dy1cmIbmye0OWXuag
         8Jxz9QVH7XK/QGEe5Cy5+g/ipNHi3/6dz2PmF09jUPGA7siS6hfejxCV6oCTd6IkJJHv
         KjYfXhd4UrFj36jNCaDCkMwbiDdcoKcsmrScYcd9cb71P3bEf4h9Hrz9MJakxa5ak6Pj
         1eNVmTvYvxTw2eNgEVV4iaA5NgzfoXnkcKyL4u8rRwvfNpXEWdGWBuUMpy2TtA9vOhqv
         sMng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e44si2174025edd.352.2019.06.12.07.34.39
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:34:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 74C632B;
	Wed, 12 Jun 2019 07:34:38 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D68633F557;
	Wed, 12 Jun 2019 07:34:32 -0700 (PDT)
Subject: Re: [PATCH v17 06/15] mm, arm64: untag user pointers in
 get_vaddr_frames
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
 <4c0b9a258e794437a1c6cec97585b4b5bd2d3bba.1560339705.git.andreyknvl@google.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <89b0c166-9a83-ba09-42e1-4fa478417b3d@arm.com>
Date: Wed, 12 Jun 2019 15:34:31 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <4c0b9a258e794437a1c6cec97585b4b5bd2d3bba.1560339705.git.andreyknvl@google.com>
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
> get_vaddr_frames uses provided user pointers for vma lookups, which can
> only by done with untagged pointers. Instead of locating and changing
> all callers of this function, perform untagging in it.
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

> ---
>  mm/frame_vector.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/frame_vector.c b/mm/frame_vector.c
> index c64dca6e27c2..c431ca81dad5 100644
> --- a/mm/frame_vector.c
> +++ b/mm/frame_vector.c
> @@ -46,6 +46,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
>  	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
>  		nr_frames = vec->nr_allocated;
>  
> +	start = untagged_addr(start);
> +
>  	down_read(&mm->mmap_sem);
>  	locked = 1;
>  	vma = find_vma_intersection(mm, start, start + 1);
> 

-- 
Regards,
Vincenzo

