Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62E1FC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 10:19:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19BAF20675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 10:19:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19BAF20675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEE068E0003; Wed,  6 Mar 2019 05:19:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9D538E0002; Wed,  6 Mar 2019 05:19:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B2D68E0003; Wed,  6 Mar 2019 05:19:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 728F78E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 05:19:31 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id f70so9365278qke.8
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 02:19:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=KDuqq3OQugnVi/sHGn4FIjHcj0fzu4Mo+4imtCZdOzM=;
        b=oSLDqkfvkugGwQdFf0p/W/tvtxaOSvgQLJvzlkK++MF9VfiHWbCsdTl7d5LOkbtQ4v
         E2koFSBMyu9OKZej1NzK1Y+qUjyEDVdP2kxsfIU1RnEZeHxrx2rHIHJU81u2zv1IBDkA
         vZOuDUSzpq5/+/3i13szy9WRy0cQfWRV7n7CAIsHjHE4sJDswRo1yU8METrNw8f3fb+g
         8FXEq2eXQfYDfh6+NZ9y1kCgNpolXZ0opbslHobv/rVw9H+EmSogHvlpJa+oET/oxu2h
         fMxXhaHx89qVPnBL8byFPe6L9md/JWKXvWAw3G0LQPQuJbq1JgJE5WMJfgnRPu0lfKYD
         buow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAXtM35/27ti5zI3oFXmQoa2NgiZrNX4vHoheUixEsyQ5aalzgSm
	+rZk70xNyCcx/ESYgvJktNxFDVMQVz0y5gdY+XjQUbyHmB9/jyMzovhzpvUPKhJ2SUNrECwsTtf
	7Gx85tGcpKVUP/NCDF1DCEJ7R3GR4Y4XkFMgxQUTOR8Odv6regk+xS37AnUvo3xaWy6b17Fc2F8
	OPQ0/qloFwiudruqm/iW6rCSZnWwkqtdUqweE79vowOaVTvcwaLLR2x/sFLox1NlWLgNa0nwTMI
	r0A13iX1wQQDpRFjqkSyC7s4ffqCQRjuKiU8mAF93TOOjiOGBO8uaMy+EbziNvsVuDvpVDG8Jc5
	jaLUJraP0/rVrOiBXExxO2TtsRMlBYxaSC27tGW3RpvSyxchY4DyGXhTRpEI1w2JGaV7E5eVeA=
	=
X-Received: by 2002:aed:27d6:: with SMTP id m22mr5217694qtg.374.1551867571243;
        Wed, 06 Mar 2019 02:19:31 -0800 (PST)
X-Received: by 2002:aed:27d6:: with SMTP id m22mr5217645qtg.374.1551867570499;
        Wed, 06 Mar 2019 02:19:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551867570; cv=none;
        d=google.com; s=arc-20160816;
        b=OPuKVOq2MZADcBRrJdKZMqBrLsNlEh0tI6/KQXwvAsaDf5Zr5LN9Zf1DNFEBuwQVfM
         9z9iIetGyOvMsPnb/xgY8h0kODy2Yb9Vy4/azSerk6/1xoj/vjcH3yOIgFVDXZ/HWzSM
         jrhEtdzGVa1/xZgRUVM1oOANQ95hw/s1Joofhwn3EXxLJKn/NFcX5SrZkr4xRzsnUN2O
         Aa//oXccUeolwun0r2YwsWEN7w1mWXazt6y9Km3c4SdhnUyRo3P5hZAy5f6mozvRrOa/
         pO9cb+d/rmnueCxQ89Y9G7DwKrrGMD0wbH5WUjfWQC2XSmF0xELgw1TIeYAmpgz6Sel0
         HZ4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version;
        bh=KDuqq3OQugnVi/sHGn4FIjHcj0fzu4Mo+4imtCZdOzM=;
        b=qqZX4Wo7z0eF45iztPYRaWu74aK9YVke35IY8vo/gxTm5ZYrPYN3ozGLFoKZcx4CHd
         etwJCzi4/9BM8koiC/EH4lZZSMQRU6m+fso/8PSEKWZoF7TdJ4Mpf7mzesHqfZoO3xHK
         RaqcjB8a3tG/FElxAEqczE/YyWHVGWf+XBmBnhWyWQmd0811XnvUYTCG73KPgqhHEI6z
         Q/PqiLJJApFqsHl2jnPHW8Wg3PF/r0hmiJL5Be/noXEZWToouoVAXNST0nY+iRxEIr53
         QQau1MNGo8t0ISNFup6l0UeBE0czeB9650XwXEtwOSoAHER7Jw60NANqg7BbK+rtflMG
         TG4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y16sor1218775qvh.62.2019.03.06.02.19.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 02:19:30 -0800 (PST)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqwlRefBtN7F0BSjmxiEhBo6nicOMU4ZZ22wsdOnFGndKuvhBT7TV6ri6KNFkjGqXGJxdr4OPG0fXMcEPCvYwSA=
X-Received: by 2002:a0c:b501:: with SMTP id d1mr5707775qve.115.1551867570098;
 Wed, 06 Mar 2019 02:19:30 -0800 (PST)
MIME-Version: 1.0
References: <20190304200026.1140281-1-arnd@arndb.de> <bf509a99-604b-10a4-e71b-f4f8e61f00b3@nvidia.com>
In-Reply-To: <bf509a99-604b-10a4-e71b-f4f8e61f00b3@nvidia.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 6 Mar 2019 11:19:13 +0100
Message-ID: <CAK8P3a2no2gjWXTcgg_g1DJ9B-j8LfyaeOn+Ji18bWS5mQNZUA@mail.gmail.com>
Subject: Re: [PATCH] mm/hmm: fix unused variable warnings
To: John Hubbard <jhubbard@nvidia.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Dan Williams <dan.j.williams@intel.com>, 
	Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 12:51 AM John Hubbard <jhubbard@nvidia.com> wrote:
>
> With some Kconfig local hacks that removed all HUGE* support, while leavi=
ng
> HMM enabled, I was able to reproduce your results, and also to verify the
> fix. It also makes sense from reading it.

Thanks for the confirmation.

> Also, I ran into one more warning as well:
>
> mm/hmm.c: In function =E2=80=98hmm_vma_walk_pud=E2=80=99:
> mm/hmm.c:764:25: warning: unused variable =E2=80=98vma=E2=80=99 [-Wunused=
-variable]
>   struct vm_area_struct *vma =3D walk->vma;
>                          ^~~
>
> ...which can be fixed like this:
>
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c4beb1628cad..c1cbe82d12b5 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -761,7 +761,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
>  {
>         struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
>         struct hmm_range *range =3D hmm_vma_walk->range;
> -       struct vm_area_struct *vma =3D walk->vma;
>         unsigned long addr =3D start, next;
>         pmd_t *pmdp;
>         pud_t pud;
> @@ -807,7 +806,7 @@ static int hmm_vma_walk_pud(pud_t *pudp,
>                 return 0;
>         }
>
> -       split_huge_pud(vma, pudp, addr);
> +       split_huge_pud(walk->vma, pudp, addr);
>         if (pud_none(*pudp))
>                 goto again;
>
> ...so maybe you'd like to fold that into your patch?

I also ran into this one last night during further randconfig testing,
and came up with the same patch that you showed here. I'll
send this one to Andrew and add a Reported-by line for you,
since he already merged the first patch.

I'll leave it up to Andrew to fold the fixes into one, or into the original
patches if he thinks that makes sense.

     Arnd

