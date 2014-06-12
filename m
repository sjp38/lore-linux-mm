Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id C1B586B00E2
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 08:00:58 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id wn1so1194351obc.9
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 05:00:58 -0700 (PDT)
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
        by mx.google.com with ESMTPS id il8si997414obc.41.2014.06.12.05.00.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 05:00:57 -0700 (PDT)
Received: by mail-ob0-f170.google.com with SMTP id uz6so1164327obc.15
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 05:00:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJe8K3LDhhPWbtdaWt23mY+2vnw5p05+eyk2D8fovOxC10cgA@mail.gmail.com>
References: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com>
	<20140611173851.GA5556@MacBook-Pro.local>
	<CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com>
	<B01EB0A1-992B-49F4-93AE-71E4BA707795@arm.com>
	<CAOJe8K3LDhhPWbtdaWt23mY+2vnw5p05+eyk2D8fovOxC10cgA@mail.gmail.com>
Date: Thu, 12 Jun 2014 16:00:57 +0400
Message-ID: <CAOJe8K2WaJUP9_buwgKw89fxGe56mGP1Mn8rDUO9W48KZzmybA@mail.gmail.com>
Subject: Re: kmemleak: Unable to handle kernel paging request
From: Denis Kirjanov <kda@linux-powerpc.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 6/12/14, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> On 6/12/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
>> On 11 Jun 2014, at 21:04, Denis Kirjanov <kda@linux-powerpc.org> wrote:
>>> On 6/11/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
>>>> On Wed, Jun 11, 2014 at 04:13:07PM +0400, Denis Kirjanov wrote:
>>>>> I got a trace while running 3.15.0-08556-gdfb9454:
>>>>>
>>>>> [  104.534026] Unable to handle kernel paging request for data at
>>>>> address 0xc00000007f000000
>>>>
>>>> Were there any kmemleak messages prior to this, like "kmemleak
>>>> disabled"? There could be a race when kmemleak is disabled because of
>>>> some fatal (for kmemleak) error while the scanning is taking place
>>>> (which needs some more thinking to fix properly).
>>>
>>> No. I checked for the similar problem and didn't find anything relevant=
.
>>> I'll try to bisect it.
>>
>> Does this happen soon after boot? I guess it=E2=80=99s the first scan
>> (scheduled at around 1min after boot). Something seems to be telling
>> kmemleak that there is a valid memory block at 0xc00000007f000000.
>
> Yeah, it happens after a while with a booted system so that's the
> first kmemleak scan.
>
>> Catalin
>

I've bisected to this commit: d4c54919ed86302094c0ca7d48a8cbd4ee753e92
"mm: add !pte_present() check on existing hugetlb_entry callbacks".
Reverting the commit fixes the issue

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
