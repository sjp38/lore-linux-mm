Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C07A8C46477
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:29:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74F6220850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:29:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="X/rImEl3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74F6220850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39FB96B000D; Thu, 13 Jun 2019 21:29:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 350D56B000E; Thu, 13 Jun 2019 21:29:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23FE06B0266; Thu, 13 Jun 2019 21:29:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0231D6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 21:29:53 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id t11so790105qtc.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 18:29:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=H/vGo7QOX7QpyBvTXnkYe2yXFtuFZ4oDrsLjFnJuZHg=;
        b=t/seD3kM8MnbLkM7a06OQLrKvmjzWWo6O+RswRACeFKzgClAl/58+u5Yx1MexpJWwJ
         ZE6lrFwUcRnkhrpSMbOhOjf0Tva5W30bXHX9zp2K2d4g1WD7ZtCpqU2q+pTm2unWTt1x
         Tk4nrt1XxrjArhyxDEPiki5urST7atZEs/7A7LNkt6Ji+JzuwFZzcXL8Qu/9lN/9KMgd
         jwptaxt+wRIc0FeAASUpG85c2Ht/giessHtZ5F0CTru0ULyENnIIfR7YmbAEBGRhiU1U
         YGo1xlz+Gt+qkC0Rq9PWCv76aLbdymbH6o7aNCrf/FqlLbWwb81DQV5++OzW6cd0Uc34
         P6Lw==
X-Gm-Message-State: APjAAAW7JPSRqj+52JBhUdxnuQjMDqJ9hEV3Lzi9EXr6KqJ4dNUR93Pa
	/o5iqLjlZhO/Uy82LgaJrwwf20y79UjlUo1e0CBRg8T0E1vgexL375NWJ/j65n7QanCUOETfomv
	zlGPMqdMTs9/+nQwf7Th3/RybPnAoaJkcgF412yI2yE1k/p/1794FJn2ddmc7ka9TPw==
X-Received: by 2002:a37:47d1:: with SMTP id u200mr39719006qka.21.1560475792758;
        Thu, 13 Jun 2019 18:29:52 -0700 (PDT)
X-Received: by 2002:a37:47d1:: with SMTP id u200mr39718967qka.21.1560475791997;
        Thu, 13 Jun 2019 18:29:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560475791; cv=none;
        d=google.com; s=arc-20160816;
        b=LQ/6LLLyHK5fBJxBilZWD0n5bjz1+O6NqFeayzFXh90Z3tSMr3a6UBzwj1CiDJtLuO
         FE63l9t109ZgVervQfWackPhP6S7z6wUF05YuNkV6K36eOxpKZpe9j8ZOCAPukzjc2Uj
         fQZSfPNmVZGjWSBrhzBgdpXUiifgfNRNRMwNI/L8LKNV+dvLlbqCTw4gkKn1TtisofuV
         vXBfk30Fy1QD83hG1xezNAIlf2J4G2x57ozlDd0PRoEBdAMvVvy5RcTjJO4vFA6pt2Ki
         6W3PYUhI25uf965Swwwb1xsNoCQUFmHUibLxljWl15Wre8ZhnehQXF6vso9tcXJ5q57A
         lXnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=H/vGo7QOX7QpyBvTXnkYe2yXFtuFZ4oDrsLjFnJuZHg=;
        b=zKUkUkIL83jDV1ohv16PFXodBwD9qDLGqwKU4cJTW/h4D5DmZ5uou9tJkzUJkbkTaX
         gknrQZeeNgiPDYCmbpgP7tXu6udYRQh+0ubr5VqV7ldZIT124aw28DLH2gMdOV+GlZg7
         JUQERkNvrx+1FMJN4Q3AlyvK4WqEOMvnO6wa+4ueelwuG4maObL0usyEv8p02jmstEph
         gTqcBIOVyUzPadUfaznT1Q7n+Af/Kw/moKtXsuWOmrezZ5llnKiiUgmY6n5bpZO7/NSA
         lKJ+DRHjSaG7Nl+1OUTsjm+V6upI39puPtOOhYUhbPCutYJFI1NGNF0nbpSWkIXRMsz6
         TXVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="X/rImEl3";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b34sor2446291qta.71.2019.06.13.18.29.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 18:29:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="X/rImEl3";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=H/vGo7QOX7QpyBvTXnkYe2yXFtuFZ4oDrsLjFnJuZHg=;
        b=X/rImEl35Oahiwt5WAxEWA8Ooo/G4IiYNzGx8xpFy37/bV7Flvr0QAhLOOeL3AIVhe
         1y5BPOVnUXFBusIUYg+P/JgavbyK7hDqOMseShNlrlKt4yCBWBuF7QF2NhCO2fLl7Grp
         XVrPbS7WwMx08WovV2pWAPIELN4ixJE3dAaHd28TpHdjICAU73ZZtl1VaQTSZOZmeCL4
         Wh1LZNu7mpVKSGU/q9ahdI7e+6IdYyWtI0lwXvn1zcFGm6KxDM2Ne4y9PfsdRu1JugCT
         cFKMEZ06sRt1hukQT/dZW0GBtWsbE9sFzkmXFK4x86+/DUWVmixJ+DCO4b1q5L/mVsRr
         PTSg==
X-Google-Smtp-Source: APXvYqzKfvNHJxoWJ3SyH77lNcIGaU1SSr4XDrqiAHxdxp7pu79pATBF5ERe9UWmUqjToIz4L9GqOg==
X-Received: by 2002:ac8:7a73:: with SMTP id w19mr57545290qtt.292.1560475791653;
        Thu, 13 Jun 2019 18:29:51 -0700 (PDT)
Received: from qians-mbp.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id g5sm1068845qta.77.2019.06.13.18.29.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 18:29:51 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
From: Qian Cai <cai@lca.pw>
In-Reply-To: <CAPcyv4hYfDtRHF-i0dNzo=ffQk6qnrasRwkVfAVnwgWj0PJ4jg@mail.gmail.com>
Date: Thu, 13 Jun 2019 21:29:50 -0400
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Oscar Salvador <osalvador@suse.de>,
 Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <0EB9D196-7552-43DF-A273-875EA6729EF9@lca.pw>
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
 <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <1560451362.5154.14.camel@lca.pw>
 <CAPcyv4hYfDtRHF-i0dNzo=ffQk6qnrasRwkVfAVnwgWj0PJ4jg@mail.gmail.com>
To: Dan Williams <dan.j.williams@intel.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 13, 2019, at 9:17 PM, Dan Williams <dan.j.williams@intel.com> =
wrote:
>=20
> On Thu, Jun 13, 2019 at 11:42 AM Qian Cai <cai@lca.pw> wrote:
>>=20
>> On Wed, 2019-06-12 at 12:37 -0700, Dan Williams wrote:
>>> On Wed, Jun 12, 2019 at 12:16 PM Qian Cai <cai@lca.pw> wrote:
>>>>=20
>>>> The linux-next commit "mm/sparsemem: Add helpers track active =
portions
>>>> of a section at boot" [1] causes a crash below when the first =
kmemleak
>>>> scan kthread kicks in. This is because kmemleak_scan() calls
>>>> pfn_to_online_page(() which calls pfn_valid_within() instead of
>>>> pfn_valid() on x86 due to CONFIG_HOLES_IN_ZONE=3Dn.
>>>>=20
>>>> The commit [1] did add an additional check of pfn_section_valid() =
in
>>>> pfn_valid(), but forgot to add it in the above code path.
>>>>=20
>>>> page:ffffea0002748000 is uninitialized and poisoned
>>>> raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff =
ffffffffffffffff
>>>> raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff =
ffffffffffffffff
>>>> page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>>>> ------------[ cut here ]------------
>>>> kernel BUG at include/linux/mm.h:1084!
>>>> invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
>>>> CPU: 5 PID: 332 Comm: kmemleak Not tainted 5.2.0-rc4-next-20190612+ =
#6
>>>> Hardware name: Lenovo ThinkSystem SR530 =
-[7X07RCZ000]-/-[7X07RCZ000]-,
>>>> BIOS -[TEE113T-1.00]- 07/07/2017
>>>> RIP: 0010:kmemleak_scan+0x6df/0xad0
>>>> Call Trace:
>>>> kmemleak_scan_thread+0x9f/0xc7
>>>> kthread+0x1d2/0x1f0
>>>> ret_from_fork+0x35/0x4
>>>>=20
>>>> [1] https://patchwork.kernel.org/patch/10977957/
>>>>=20
>>>> Signed-off-by: Qian Cai <cai@lca.pw>
>>>> ---
>>>> include/linux/memory_hotplug.h | 1 +
>>>> 1 file changed, 1 insertion(+)
>>>>=20
>>>> diff --git a/include/linux/memory_hotplug.h =
b/include/linux/memory_hotplug.h
>>>> index 0b8a5e5ef2da..f02be86077e3 100644
>>>> --- a/include/linux/memory_hotplug.h
>>>> +++ b/include/linux/memory_hotplug.h
>>>> @@ -28,6 +28,7 @@
>>>>        unsigned long ___nr =3D pfn_to_section_nr(___pfn);           =
\
>>>>                                                                   \
>>>>        if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr) && \
>>>> +           pfn_section_valid(__nr_to_section(___nr), pfn) &&      =
\
>>>>            pfn_valid_within(___pfn))                              \
>>>>                ___page =3D pfn_to_page(___pfn);                     =
\
>>>>        ___page;                                                   \
>>>=20
>>> Looks ok to me:
>>>=20
>>> Acked-by: Dan Williams <dan.j.williams@intel.com>
>>>=20
>>> ...but why is pfn_to_online_page() a multi-line macro instead of a
>>> static inline like all the helper routines it invokes?
>>=20
>> Sigh, probably because it is a mess over there.
>>=20
>> memory_hotplug.h and mmzone.h are included each other. Converted it =
directly to
>> a static inline triggers compilation errors because mmzone.h was =
included
>> somewhere else and found pfn_to_online_page() needs things like
>> pfn_valid_within() and online_section_nr() etc which are only defined =
later in
>> mmzone.h.
>=20
> Ok, makes sense I had I assumed it was something horrible like that.
>=20
> Qian, can you send more details on the reproduction steps for the
> failures you are seeing? Like configs and platforms you're testing.
> I've tried enabling kmemleak and offlining memory and have yet to
> trigger these failures. I also have a couple people willing to help me
> out with tracking down the PowerPC issue, but I assume they need some
> help with the reproduction as well.

https://github.com/cailca/linux-mm

You can see the configs for each arch there. It was reproduced on =
several x86 NUMA bare-metal machines HPE, Lenovo etc either Intel or =
AMD. Check the =E2=80=9Ctest.sh=E2=80=9D, there is a part to do =
offline/online will reproduce it.

The powerpc is IBM 8335-GTC (ibm,witherspoon) POWER9 which is a NUMA =
PowerNV platform.=

