Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DCA1C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 15:08:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D91172238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 15:08:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="qRC1ruUX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D91172238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D5C28E0003; Thu, 25 Jul 2019 11:08:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95FE58E0002; Thu, 25 Jul 2019 11:08:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 828308E0003; Thu, 25 Jul 2019 11:08:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 483198E0002
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:08:24 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g21so31061075pfb.13
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 08:08:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=83mWQew2TppWX0X+agKs+C2fhodByufyMhvIxXXCS2s=;
        b=XfioQji6Y9iL2PTxYvtR6rzYAhHYKcC2VMK/UTR71qEyhToLMYzMYUgiTdCFEhsBMp
         NNwKmhK7V2SGLrd5Pqo333YgWkO4Vym1idXtXq77UqdSpMurGYhqbKBuEk6lduVNfXvx
         I9e5lxcqSwlNjUQPiQiVfboJPloKZAE3khu7dUQ1fx3qgXqjphmhDBhhWoBxY9KGsvbI
         7aIi/b6Kse+sw+Ps9BUiCJYbUi3qrn+hAX9GIm/G7fgb2eY3kUWb/oHZvAvMBq+U+mUr
         zE8m7ksPFMZ1cEApPFk+tleeWQD937YfkjVe2sSEBoQAJzKaADRYm0z6Q0cVEd+9bs3f
         RMVg==
X-Gm-Message-State: APjAAAWAyibZJ36wphO9XslgnH1KR9aXNfAgmzTnt5DD1m86Ska/kHR3
	g3xpodVRFOic15GbAdZMEIOdiWOQR4Yf7jN3qYfFkhWt3KEB2gy0Kz7suuI1plngP5xkH3WjM6k
	7EqDM0Qo9ph1+bgqH/DUX455nC+AGT0pWpo5ea/puHVY7qFQWTV4WmCzM2nYenuC3EQ==
X-Received: by 2002:a17:90b:8d8:: with SMTP id ds24mr17399564pjb.135.1564067303945;
        Thu, 25 Jul 2019 08:08:23 -0700 (PDT)
X-Received: by 2002:a17:90b:8d8:: with SMTP id ds24mr17399503pjb.135.1564067303119;
        Thu, 25 Jul 2019 08:08:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564067303; cv=none;
        d=google.com; s=arc-20160816;
        b=GylEWcyZasuvrG9sRqH8qg/UaikscmLi4rZlu2ruln7T+uwR2z8XaNpWg1NW8uilVv
         tjKD2CrU+efwWAL1JYCofkXtN1LjFOwB8hkBFKxQS6juQKkurGRo9eDbKmTNYF2lGBPk
         L4oJBIVjW62davckF2QP1cZvNQUxgFYjG7WSMXTWZwlrR7OsJxaObFX3udDClqWoF/wT
         UA+9vrqKu8QdPybOuf1c1nQ/uzjaCucw4/scp3PCAWbn+i2lkzoVQfkB9v/6M3gdy4zs
         xvBI9Wi/c0mb9yLB2oROixtBdbf7fZhYdhbDFypCT/9d3YpFUEYZy+yGEPzNlOJ9I/gl
         T2gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=83mWQew2TppWX0X+agKs+C2fhodByufyMhvIxXXCS2s=;
        b=xG+sVw+EFs8QSompjWdAAYZdwK230qv7aH3LPJjw/re/qfFIvFJkk6jFDesBhs/5xL
         GSYMWwVN/WFKhZFyRJm673bD0lCVhhrh1p3B6vXT6ESu3m/MCpMxNh/S0J3letMmmaw/
         gn4yhyWI+/g7VSQMVO8zagIiMMpFA3J8JOjoD8kbO6k+8C8c/RJA7aQtpF7bHvIj8A5B
         dh1NvG5mFbXcY0hihpy2s45tqmcz1e8GW3fgPo0g40tQH6df57n3W5wtUhIxmeoAXB2B
         +/MgcnktuxJmu6GyIz9rc4lcrQROCg+dCE47RpyYQqn+RbtgWd4s92rchd7ViuusAtjq
         sJVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=qRC1ruUX;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor29670809pgm.23.2019.07.25.08.08.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 08:08:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=qRC1ruUX;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=83mWQew2TppWX0X+agKs+C2fhodByufyMhvIxXXCS2s=;
        b=qRC1ruUXpbHRSCiiFqwgQ33N/vui1Nxcdsp/0Vf804vOKN7yDHVWNJR47cKIm2zjtx
         x+MJ1gYODmhRtd2ORE4ywMyVLJ3BzgB9iwOJnT8ueem9LxVk++sW7T2l9wsfbQYUkeWX
         HU4lP+8HhuJNo/IEmEUYEjh+9EPS05XXVb+WuIahqSagQwtRQgHoJLC3cg1nsUX5NCyy
         27qCk8zX3dB/5DaaDSlLpA24UvDc6OUrq7kDmQJbqfOVOLDbeOm9fyxdOGSoK5Ywt16k
         9ZJaaekHpbc8ALr2ElAZVvHIAI3FYOTL0OUxADY8Z8RYjmFj7jLvo/58hZcZICaQYNCk
         G9Jw==
X-Google-Smtp-Source: APXvYqzDXVgnjtvLoDsC0zg7c0ZhLKAOQMogSv8RHjCL97uHUdNbrrOeQTiKhnk0UOpI25fDn0diKw==
X-Received: by 2002:a63:6c7:: with SMTP id 190mr85625071pgg.7.1564067302595;
        Thu, 25 Jul 2019 08:08:22 -0700 (PDT)
Received: from ?IPv6:2601:646:c200:1ef2:2d12:dd93:21e:b639? ([2601:646:c200:1ef2:2d12:dd93:21e:b639])
        by smtp.gmail.com with ESMTPSA id v138sm57834072pfc.15.2019.07.25.08.08.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 08:08:20 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 3/3] x86/kasan: support KASAN_VMALLOC
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <CACT4Y+aOvGqJEE5Mzqxusd2+hyX1OUEAFjJTvVED6ujgsASYrQ@mail.gmail.com>
Date: Thu, 25 Jul 2019 08:08:19 -0700
Cc: Daniel Axtens <dja@axtens.net>, kasan-dev <kasan-dev@googlegroups.com>,
 Linux-MM <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <D7AC2D28-596F-4B9E-B4AD-B03D8485E9F1@amacapital.net>
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-4-dja@axtens.net> <CACT4Y+aOvGqJEE5Mzqxusd2+hyX1OUEAFjJTvVED6ujgsASYrQ@mail.gmail.com>
To: Dmitry Vyukov <dvyukov@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 25, 2019, at 12:49 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>=20
>> On Thu, Jul 25, 2019 at 7:55 AM Daniel Axtens <dja@axtens.net> wrote:
>>=20
>> In the case where KASAN directly allocates memory to back vmalloc
>> space, don't map the early shadow page over it.
>>=20
>> Not mapping the early shadow page over the whole shadow space means
>> that there are some pgds that are not populated on boot. Allow the
>> vmalloc fault handler to also fault in vmalloc shadow as needed.
>>=20
>> Signed-off-by: Daniel Axtens <dja@axtens.net>
>=20
>=20
> Would it make things simpler if we pre-populate the top level page
> tables for the whole vmalloc region? That would be
> (16<<40)/4096/512/512*8 =3D 131072 bytes?
> The check in vmalloc_fault in not really a big burden, so I am not
> sure. Just brining as an option.

I prefer pre-populating them. In particular, I have already spent far too mu=
ch time debugging the awful explosions when the stack doesn=E2=80=99t have K=
ASAN backing, and the vmap stack code is very careful to pre-populate the st=
ack pgds =E2=80=94 vmalloc_fault fundamentally can=E2=80=99t recover when th=
e stack itself isn=E2=80=99t mapped.

So the vmalloc_fault code, if it stays, needs some careful analysis to make s=
ure it will actually survive all the various context switch cases.  Or you c=
an pre-populate it.

>=20
> Acked-by: Dmitry Vyukov <dvyukov@google.com>
>=20
>> ---
>> arch/x86/Kconfig            |  1 +
>> arch/x86/mm/fault.c         | 13 +++++++++++++
>> arch/x86/mm/kasan_init_64.c | 10 ++++++++++
>> 3 files changed, 24 insertions(+)
>>=20
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index 222855cc0158..40562cc3771f 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -134,6 +134,7 @@ config X86
>>        select HAVE_ARCH_JUMP_LABEL
>>        select HAVE_ARCH_JUMP_LABEL_RELATIVE
>>        select HAVE_ARCH_KASAN                  if X86_64
>> +       select HAVE_ARCH_KASAN_VMALLOC          if X86_64
>>        select HAVE_ARCH_KGDB
>>        select HAVE_ARCH_MMAP_RND_BITS          if MMU
>>        select HAVE_ARCH_MMAP_RND_COMPAT_BITS   if MMU && COMPAT
>> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
>> index 6c46095cd0d9..d722230121c3 100644
>> --- a/arch/x86/mm/fault.c
>> +++ b/arch/x86/mm/fault.c
>> @@ -340,8 +340,21 @@ static noinline int vmalloc_fault(unsigned long addr=
ess)
>>        pte_t *pte;
>>=20
>>        /* Make sure we are in vmalloc area: */
>> +#ifndef CONFIG_KASAN_VMALLOC
>>        if (!(address >=3D VMALLOC_START && address < VMALLOC_END))
>>                return -1;
>> +#else
>> +       /*
>> +        * Some of the shadow mapping for the vmalloc area lives outside t=
he
>> +        * pgds populated by kasan init. They are created dynamically and=
 so
>> +        * we may need to fault them in.
>> +        *
>> +        * You can observe this with test_vmalloc's align_shift_alloc_tes=
t
>> +        */
>> +       if (!((address >=3D VMALLOC_START && address < VMALLOC_END) ||
>> +             (address >=3D KASAN_SHADOW_START && address < KASAN_SHADOW_=
END)))
>> +               return -1;
>> +#endif
>>=20
>>        /*
>>         * Copy kernel mappings over when needed. This can also
>> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
>> index 296da58f3013..e2fe1c1b805c 100644
>> --- a/arch/x86/mm/kasan_init_64.c
>> +++ b/arch/x86/mm/kasan_init_64.c
>> @@ -352,9 +352,19 @@ void __init kasan_init(void)
>>        shadow_cpu_entry_end =3D (void *)round_up(
>>                        (unsigned long)shadow_cpu_entry_end, PAGE_SIZE);
>>=20
>> +       /*
>> +        * If we're in full vmalloc mode, don't back vmalloc space with e=
arly
>> +        * shadow pages.
>> +        */
>> +#ifdef CONFIG_KASAN_VMALLOC
>> +       kasan_populate_early_shadow(
>> +               kasan_mem_to_shadow((void *)VMALLOC_END+1),
>> +               shadow_cpu_entry_begin);
>> +#else
>>        kasan_populate_early_shadow(
>>                kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
>>                shadow_cpu_entry_begin);
>> +#endif
>>=20
>>        kasan_populate_shadow((unsigned long)shadow_cpu_entry_begin,
>>                              (unsigned long)shadow_cpu_entry_end, 0);
>> --
>> 2.20.1
>>=20
>> --
>> You received this message because you are subscribed to the Google Groups=
 "kasan-dev" group.
>> To unsubscribe from this group and stop receiving emails from it, send an=
 email to kasan-dev+unsubscribe@googlegroups.com.
>> To view this discussion on the web visit https://groups.google.com/d/msgi=
d/kasan-dev/20190725055503.19507-4-dja%40axtens.net.

