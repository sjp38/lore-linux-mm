Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 403B3C43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 16:51:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF7792081C
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 16:51:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF7792081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 896AD6B0005; Fri,  3 May 2019 12:51:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81FBC6B0006; Fri,  3 May 2019 12:51:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C0516B0007; Fri,  3 May 2019 12:51:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF2F6B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 12:51:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x16so4323376edm.16
        for <linux-mm@kvack.org>; Fri, 03 May 2019 09:51:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9o74ZDse/0sbePMPNqDRpflNx5zwoBAyG4ZxPwTos+M=;
        b=Nx/RCqNmizb9/dFNmMyr2tZSRzA1TZvEsgq4YpSsqvj5oHkQa/z5LjefKpQ1u+TQUD
         j90D1u1bqkSnqxBI509yP+jMNHAL8lojxM83+CvnA3gXeHdedSxIFZaspIRnY9vMnz1q
         L7DUUrwImtCFoSHyhAGeOAMKjr9xRQa6MQknCbrAxpJlDjrVFQ7tUQedQjrATPZoCS7S
         nlKVPAQyNqU4LTYqGNaltF9KXXrXoaTNyT4DV1+Nmt7WuXkLfzY2C5zvpT0J6r7E+o8c
         KeuBAELkxP6+3VsqdfnRwnSdV0BDjyqDqP4bDmZSw3fyWqI24zVlaYqVV90o9oWsQ+Qo
         A4gQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUXUewa16DcYP29vCqNaMXYwVfCfJabEllybq1JJECvgcVghmSy
	Oz3Npr0gLf8Hhmqv6hm9yBYZAww89tO1cWXKmARww6ipoH9FkfURqze2v4pIor0iNtgLsxGdpcb
	6c3BfYvcvHzn6w7BRz2Bi/01NAsgMff7qFgfA5L+BZEMZBvU3NRBaSsTGvr6bQt23YQ==
X-Received: by 2002:a05:6402:1612:: with SMTP id f18mr9611627edv.295.1556902284590;
        Fri, 03 May 2019 09:51:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCVgC9pURUPG1nSx2lAc9f1x6sye5HeImaY3nuwbH+YL4MIZ6duVrNBUJlLhRcG59vLpuB
X-Received: by 2002:a05:6402:1612:: with SMTP id f18mr9611536edv.295.1556902283628;
        Fri, 03 May 2019 09:51:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556902283; cv=none;
        d=google.com; s=arc-20160816;
        b=XcLU0spiYv6LyjElHHUBJ8Lk/PtQ3O97bbb0hsrjpZZ1steOVOC2NkpqVkBQV/CHz5
         AO1MoHAi/Qny6lnK4VpOUuR8VL40NE++kD04B3JpGqProUDrJ7wB/cOQfpo3BXo2HDuZ
         HfhlLYuCSzi84xTEl1I+3NJ8bc9ERbbU/Wpisl3uUIeoUi9dD8hdWZKQrsAIWufK/xN8
         dJJRQ1mlLz2ShS6tso8cpffAWQza/ZTqrGzPrurlSMlrqratqYXFKeiSn2sNC3v4E5e/
         IWu/MRs+3sqWdPt6x9SVrPaRxlOzDMRF6S+x+zV+xjsTh/RQrgz3gSwnlAEScEQGQOxi
         yBfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9o74ZDse/0sbePMPNqDRpflNx5zwoBAyG4ZxPwTos+M=;
        b=cT+1nlqTcVNDoBDrJgshuUEj9G7Z0UH5uXGmyEvpw1gbd20f1d4oVThiHKOfalRi+l
         XBZZCtxViN82PIWaNypIMuS8j/I47yyh8TxLiE3EpiLvU6+hhmComeL+TXe/luPsvet3
         1nCmIpcHJppVohc7j7SD6mLrfog8PofQ5v8FwzcmlmSPQb19v9LXD9ym9jGuEaiwHZeB
         xvYNKvjcytig8MDRLqkjZ2/ZyFMDKxRGYCYymu+BtxwoNZGTNPcI1No2tMiCq5jUv+F9
         d/GP/NH94Jagj1AAxdWa17jXAynlhEGtcl5QHnI08zH9O9LcO7arMAv2w04CALEfHJOv
         LPFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y19si2118843edc.147.2019.05.03.09.51.23
        for <linux-mm@kvack.org>;
        Fri, 03 May 2019 09:51:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8229A15A2;
	Fri,  3 May 2019 09:51:22 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1C9913F557;
	Fri,  3 May 2019 09:51:15 -0700 (PDT)
Date: Fri, 3 May 2019 17:51:13 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com,
	Felix <Felix.Kuehling@amd.com>, Deucher@google.com,
	Alexander <Alexander.Deucher@amd.com>, Koenig@google.com,
	Christian <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v14 08/17] mm, arm64: untag user pointers in
 get_vaddr_frames
Message-ID: <20190503165113.GJ55449@arrakis.emea.arm.com>
References: <cover.1556630205.git.andreyknvl@google.com>
 <8e20df035de677029b3f970744ba2d35e2df1db3.1556630205.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8e20df035de677029b3f970744ba2d35e2df1db3.1556630205.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 03:25:04PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> get_vaddr_frames uses provided user pointers for vma lookups, which can
> only by done with untagged pointers. Instead of locating and changing
> all callers of this function, perform untagging in it.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
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

Is this some buffer that the user may have malloc'ed? I got lost when
trying to track down the provenience of this buffer.

-- 
Catalin

