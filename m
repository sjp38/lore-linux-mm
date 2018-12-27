Return-Path: <SRS0=02aR=PE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF0F5C43612
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 15:21:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BECC2148D
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 15:21:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="o+lsZIVi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BECC2148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 194688E0019; Thu, 27 Dec 2018 10:21:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1431C8E0001; Thu, 27 Dec 2018 10:21:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 031048E0019; Thu, 27 Dec 2018 10:21:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5E5B8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 10:21:13 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v11so16452585ply.4
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 07:21:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=h2EGYq8XTKqDNlssItDJr1D7HvVzviICZgcJkBUhouQ=;
        b=eP3dxYrTAzcz6R6pzI7JMhKWMMybN+c01ovJnfazCMvXYXrCU34VctPpRhDqzrHtpg
         x+Ozzaisyv9uzSGF5D+Y6qevMnQeaW70LakBHU6lNuqUVfgdpPmcFniYNMEKfEY0bXeD
         QFDNNqRt29cp0hQ8KaDjjnPHUPAfRxEcCM5hCBpZl6ai5TgYiBVvtAZK8ZMTqpKEiWVG
         LMgjSmFYH9s9vCYvpQzP01CyXw3wXDOR9EgbO31Kc8KxcUFVWXxoxkmvkHDDC/kMjtpT
         36ujRBuf6Ch2avaG/zcXTQiaYUr93wfWsdQ+/F/PSrFNT23WYWk9CL6xb1NTFWTWsMpD
         Nh7A==
X-Gm-Message-State: AA+aEWYo14FIXHtXGFNlf1aefwb/BJIGuu2B42WfJY8oZXoj/Ij5lgB4
	F15Zd65mxqVbq8gq9d04T3h93tr7Bd6hmwkjB5oQFCjoamXMr0Lo8dAqukh+eXbWaKL3RAMXYu6
	81bQtnpG+zWOvE1aQzY//MV/drIf5CRBey91B+zcBj4f4uBjjGeuIPgarmhdqjWdxFcHZlnARt4
	yxQqRBQ9BE8poXXbVaijhJaw35CS4nM0lypHsADCvp/nsPIhCXOh4cbne/rs3E6MhMFNfi+XZAT
	KSXIFZyNCQjnk5EEuIZ0/Tx4v//iLs+tdoiH+5YGMpo5/LA21bmCxoKOrxZa2k4g7l5uMFOCSJo
	7T8FPirmJMqG3W+q4sQePO4Ovbnb5ck4S6ktLjSdlsiHvNQIvbRi6QMBIM2fHSq/2rBEgZ3SDnh
	j
X-Received: by 2002:aa7:87ce:: with SMTP id i14mr24468061pfo.20.1545924073289;
        Thu, 27 Dec 2018 07:21:13 -0800 (PST)
X-Received: by 2002:aa7:87ce:: with SMTP id i14mr24468007pfo.20.1545924072522;
        Thu, 27 Dec 2018 07:21:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545924072; cv=none;
        d=google.com; s=arc-20160816;
        b=kIVoJFrC0zoYF+fEzpO6FNmlpv5nH4GaNesK2ieC/oG84GO6vVgRuj5pq5hoPp1KTm
         qxhIV3P3oFhP/Y38NeUcZLcfcx3cYhneFwpcVrd5yqTbUGR0l2uw73H6JFlMWidEpojR
         75KSrke1eZOTzQJBiXzIw1c++5+6xcTuRRPG6+OAvxTaN4ytNPcDycf++P7EhjNdXRPk
         WZ49Rge28HdhCkE2Mcbary4IRmydq6j26jfw9SOOSdSPR7KMTTTLzhdEJjcIpdz+jq1F
         uYH91XvkU/JpD3+/z0naxsiwYNx3by3Xjp8+qvH5EAmkQF9aChu64Cbbw3D5nGm5J0Ec
         NUSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=h2EGYq8XTKqDNlssItDJr1D7HvVzviICZgcJkBUhouQ=;
        b=PtFrxQwhgbnkqBLcCGHnzTI11kpcljvCGdCInM0U/g5tmbfjmjNygWYsorXFP4BtxE
         n/xDhvu6Uhp+DEX2koalNZ6oD86g2acv28dIUaStAEa6549WLibGD0Tqi+9OQW8y20Ly
         Ts4jCo75M6V5yzMEvKOkQy9WQBSmASgIysskiUaFnrXw7T1mlg8m1CSw1TJJCjHyAvhb
         5QURapj3tAjOgxEvZ4xX2h4Lm9OzToZ8H9amVgYm5eySMBln1BdaKipKXQ29Nefu9nrH
         gcQCMIFtDPADLcY4Wn9/nnXJAjZUms6PfRZHK9dlHoevbr27pDqLgPxTmCG/S5IWYKRY
         PGiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=o+lsZIVi;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m8sor60345901pgv.85.2018.12.27.07.21.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Dec 2018 07:21:12 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=o+lsZIVi;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=h2EGYq8XTKqDNlssItDJr1D7HvVzviICZgcJkBUhouQ=;
        b=o+lsZIViOhVMBZaQmR9XX3L1dHn4EmbIWJalPCayhnKcnph0w5lZ/IAYbjQtdej+E1
         1Msmkxd9/iv3OtnGBCncNWYh/1FmvZrfnhmoETbKp1WhdfohCzcj6Tj04MDAxPmDj+Ll
         nm4steYkwKEhsT8KnAfiTssWcYV81zREG4S99JkH3bpyFNXGtHeEnV/4YpqOuyFj07N+
         aS1J+Tw6i+243o+B6sN7ixqhFJrRReVe8uIaLrK63g1hAR/dvZEzoesIV68JVtr2/YZl
         03lMrTpWc/m/O4KkXny6zjXaWjZNirxNs8i2AR5Jtc5Ju3o3moKPoFAgDkxnkqH4eNEI
         +teQ==
X-Google-Smtp-Source: ALg8bN6T8NvDJ2PBQQwHgBrKDWlnRFUo+0Y11//Bd7DA4F8zknOWe3sAFZQutsygcML14CuAp8P5ZBXhNq7w9Ap/5mU=
X-Received: by 2002:a63:9e58:: with SMTP id r24mr23625868pgo.264.1545924071964;
 Thu, 27 Dec 2018 07:21:11 -0800 (PST)
MIME-Version: 1.0
References: <20181226020550.63712-1-cai@lca.pw>
In-Reply-To: <20181226020550.63712-1-cai@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 27 Dec 2018 16:21:00 +0100
Message-ID:
 <CAAeHK+zj0LcjhcQFd4H9CfRbyzz8u+HuhA4-c-pjnDobkDGRJQ@mail.gmail.com>
Subject: Re: [PATCH -mmotm] arm64: skip kmemleak for KASAN again
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Dmitry Vyukov <dvyukov@google.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181227152100.okWAW3E_FPXQ-GXd3BrF2tze5Tev9h-cTpnxuC5bhEo@z>

On Wed, Dec 26, 2018 at 3:06 AM Qian Cai <cai@lca.pw> wrote:
>
> Due to 871ac3d540f (kasan: initialize shadow to 0xff for tag-based
> mode), kmemleak is broken again with KASAN. It needs a similar fix
> from e55058c2983 (mm/memblock.c: skip kmemleak for kasan_init()).
>
> Signed-off-by: Qian Cai <cai@lca.pw>

Hi Qian,

Sorry, didn't see your first kmemleak fix. I can merge this fix into
my series if I end up resending it.

In any case:

Acked-by: Andrey Konovalov <andreyknvl@google.com>

Thanks!

> ---
>  arch/arm64/mm/kasan_init.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> index 48d8f2fa0d14..4b55b15707a3 100644
> --- a/arch/arm64/mm/kasan_init.c
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -47,8 +47,7 @@ static phys_addr_t __init kasan_alloc_raw_page(int node)
>  {
>         void *p = memblock_alloc_try_nid_raw(PAGE_SIZE, PAGE_SIZE,
>                                                 __pa(MAX_DMA_ADDRESS),
> -                                               MEMBLOCK_ALLOC_ACCESSIBLE,
> -                                               node);
> +                                               MEMBLOCK_ALLOC_KASAN, node);
>         return __pa(p);
>  }
>
> --
> 2.17.2 (Apple Git-113)
>

