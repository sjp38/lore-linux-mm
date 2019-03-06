Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97541C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:34:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2432A20840
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:34:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="igHAK3Ls"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2432A20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 975ED8E0003; Wed,  6 Mar 2019 13:34:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 926528E0002; Wed,  6 Mar 2019 13:34:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83CE78E0003; Wed,  6 Mar 2019 13:34:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 438918E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 13:34:18 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id a72so14437735pfj.19
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 10:34:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=yC7ehc6njw1E3SuHOt+SsTnUaysDvj7ZQ5vFInDjvDQ=;
        b=aAixAUhpWCpCHHMjbQ3L9/W9RNJjKrQKIJvYeTGVh0Z+HvuCZkgKglgpP0P5y0FPDH
         j5HfN4zeto8gL/wjYrGz084qI5gO/qicRml3YNOhjaNxk4IlbshNNX5YQU1dhqEET3q4
         BUXT4wCYgI5AMIp3ns26D9rom7O0Q+B5VBwm488T0netJvY/0g7EAfNM5i6mA9mYk/n5
         Ln2x+ipnx/GhNZ6ndVg+yMnPRc7qTObeaXiGz3oC5ipkOJxwpqNfBThR6xWw77u3xlgh
         BDjZEx03SLWsAqOycVXgAoNU/DmHx8r28AlStbDQJGJ/LFkGOG4TDmdJqI2KLxYRLeD5
         HQfA==
X-Gm-Message-State: APjAAAXm4x6oRXU6nAB+XqjqW1x1xM2/5PGoe7q6W6q4u1finM7zP7+H
	v3bg2SIcwcKBAhPqHoGjj5UDJBQ1sRZZEwCnCvBSHRbWyNPRv+xkcZdKIzFT/hgMDYXL7uCb21X
	CArwtBPb+52gFbaO5e0Mej++n7z9Z1wajkoIaBbko7+GqsbQM/bagMi9r8mTjWCerog==
X-Received: by 2002:aa7:854d:: with SMTP id y13mr8532840pfn.175.1551897257870;
        Wed, 06 Mar 2019 10:34:17 -0800 (PST)
X-Google-Smtp-Source: APXvYqwhlHB4ruZFsbiQcUaj0ztyJjRn2Fcmjr28jWJ/YwazC82MZ01eo5qenDVgtZcol9Rqj/mo
X-Received: by 2002:aa7:854d:: with SMTP id y13mr8532776pfn.175.1551897256944;
        Wed, 06 Mar 2019 10:34:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551897256; cv=none;
        d=google.com; s=arc-20160816;
        b=RmpwcMR3fczm/F3bjYyRJLKuKYLKdYj7npH1zb6BWi8dBEhUwz/a0e6rnPjbQ4rZzj
         iuEtAzmiJcfPncyu3hPostOIaMqIEBHZ5ugNkfADQvMyTO2ABJZSvgZ0VulbaSbGbGNn
         jtPhei01i8pQcb0w6CIRhbC/MexSSPyKIlPC5mJu/voWIu+AT75pbz1ae5JyIqVZ2chC
         RN7qQzcyN+Ny3PlMtt7kFZY47fBiDKajKmu6iKZYC2+wY5KDDkh+LkeGSkL/jJ28GQi2
         SEJ6Mq1/FBbh4ytSMMB/nB2R3OyLLXLwE6lBtea7RCBZm03D4US9FkAwbk2jqh5sgkd1
         ia7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=yC7ehc6njw1E3SuHOt+SsTnUaysDvj7ZQ5vFInDjvDQ=;
        b=BWKtlQmlrs55jIlocl2feWVFozNxoXGQnjuJ2TkK0OPaou+nOaAEyNqAtkL7miEVuv
         z+0cxKPVvyV6V+z6Nq8ItFgjSuMK7K8kToWgGEoFZ0NWeXs/46GbUV9U1B/EeD57MM2x
         s82pD0fkDGUr3QjjrFZra08pDEAxAqSid2mFxvRbcoO2HAbzJOPM9H+3AZTriHnyelSZ
         eKpJ9g/3flHyK/stsf8/F83RvXsppNrM6E3926th+ocuYvuBV0XzuYYjp0w1iAPoUm4K
         9qzII17tSBfFUYs+XDb31nVBW5NSI8E+mA8POgCxdO/ptnvvb0iSy0ZhFj1jemKCEKQT
         a9pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=igHAK3Ls;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id n78si2196332pfi.243.2019.03.06.10.34.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 10:34:16 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=igHAK3Ls;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c8012a90000>; Wed, 06 Mar 2019 10:34:17 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 06 Mar 2019 10:34:16 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 06 Mar 2019 10:34:16 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 6 Mar
 2019 18:34:15 +0000
Subject: Re: [PATCH] mm/hmm: fix unused variable warnings
To: Arnd Bergmann <arnd@arndb.de>
CC: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton
	<akpm@linux-foundation.org>, Ralph Campbell <rcampbell@nvidia.com>, Stephen
 Rothwell <sfr@canb.auug.org.au>, Dan Williams <dan.j.williams@intel.com>,
	Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>
References: <20190304200026.1140281-1-arnd@arndb.de>
 <bf509a99-604b-10a4-e71b-f4f8e61f00b3@nvidia.com>
 <CAK8P3a2no2gjWXTcgg_g1DJ9B-j8LfyaeOn+Ji18bWS5mQNZUA@mail.gmail.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <745a2366-23e2-0718-92f4-ccadad5ccf8a@nvidia.com>
Date: Wed, 6 Mar 2019 10:34:15 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CAK8P3a2no2gjWXTcgg_g1DJ9B-j8LfyaeOn+Ji18bWS5mQNZUA@mail.gmail.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551897257; bh=yC7ehc6njw1E3SuHOt+SsTnUaysDvj7ZQ5vFInDjvDQ=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=igHAK3LsZcVHxtB6N8VhpFMw/EuNTWHI744htYl3XE15CeIT1Ug4Ed+/Dc9MJCZLv
	 hC+wQSLEhsAEkb8W5zDLnHQO+iGSFNmMuzGIgULYUI9ibHBTGLoqYm+OBMZ3E+h9oo
	 zoKMC9Zdgivw0tsfs9sRSmtDZaKs/0rSgNua/BYdjA8RIsjZWgP+Fki/nHmbV6VjXR
	 NkoSKjdToyTTJg4g+wgzKPM3mIit+UF6w+84QOtvm6yNElnTnfC3eG1/OZKxMwfH/l
	 +FgjOY2bIZUIaaJ3JCs7csQTtHiwXNlN1eS7+Z+0RHFOBpoNap5AmysaLZR8LjFmms
	 EBB0miT/Cd8fA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/6/19 2:19 AM, Arnd Bergmann wrote:
> On Wed, Mar 6, 2019 at 12:51 AM John Hubbard <jhubbard@nvidia.com> wrote:
>>
>> With some Kconfig local hacks that removed all HUGE* support, while leav=
ing
>> HMM enabled, I was able to reproduce your results, and also to verify th=
e
>> fix. It also makes sense from reading it.
>=20
> Thanks for the confirmation.
>=20
>> Also, I ran into one more warning as well:
>>
>> mm/hmm.c: In function =E2=80=98hmm_vma_walk_pud=E2=80=99:
>> mm/hmm.c:764:25: warning: unused variable =E2=80=98vma=E2=80=99 [-Wunuse=
d-variable]
>>   struct vm_area_struct *vma =3D walk->vma;
>>                          ^~~
>>
>> ...which can be fixed like this:
>>
>> diff --git a/mm/hmm.c b/mm/hmm.c
>> index c4beb1628cad..c1cbe82d12b5 100644
>> --- a/mm/hmm.c
>> +++ b/mm/hmm.c
>> @@ -761,7 +761,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
>>  {
>>         struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
>>         struct hmm_range *range =3D hmm_vma_walk->range;
>> -       struct vm_area_struct *vma =3D walk->vma;
>>         unsigned long addr =3D start, next;
>>         pmd_t *pmdp;
>>         pud_t pud;
>> @@ -807,7 +806,7 @@ static int hmm_vma_walk_pud(pud_t *pudp,
>>                 return 0;
>>         }
>>
>> -       split_huge_pud(vma, pudp, addr);
>> +       split_huge_pud(walk->vma, pudp, addr);
>>         if (pud_none(*pudp))
>>                 goto again;
>>
>> ...so maybe you'd like to fold that into your patch?
>=20
> I also ran into this one last night during further randconfig testing,
> and came up with the same patch that you showed here. I'll
> send this one to Andrew and add a Reported-by line for you,
> since he already merged the first patch.
>=20
> I'll leave it up to Andrew to fold the fixes into one, or into the origin=
al
> patches if he thinks that makes sense.
>=20
>      Arnd
>=20

Sounds good!

thanks,
--=20
John Hubbard
NVIDIA

