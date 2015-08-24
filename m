Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8246B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:44:33 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so76121395wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:44:33 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id db8si32765963wjc.63.2015.08.24.08.44.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Aug 2015 08:44:31 -0700 (PDT)
Message-ID: <55DB3BD3.7030202@arm.com>
Date: Mon, 24 Aug 2015 16:44:19 +0100
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>	<CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>	<CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>	<CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>	<CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>	<CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>	<55AE56DB.4040607@samsung.com>	<CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>	<20150824131557.GB7557@n2100.arm.linux.org.uk>	<CACRpkdYwpucRiXM05y00RQY=gKv8W6YjCNspYFRMGaM605cU0w@mail.gmail.com> <CAPAsAGwji7FpUJK9O=FWYN15-rJkYMQyOt9W9ncdY9uLybxkiA@mail.gmail.com>
In-Reply-To: <CAPAsAGwji7FpUJK9O=FWYN15-rJkYMQyOt9W9ncdY9uLybxkiA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linus Walleij <linus.walleij@linaro.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On 24/08/15 15:15, Andrey Ryabinin wrote:
> 2015-08-24 16:45 GMT+03:00 Linus Walleij <linus.walleij@linaro.org>:
>> On Mon, Aug 24, 2015 at 3:15 PM, Russell King - ARM Linux
>> <linux@arm.linux.org.uk> wrote:
>>> On Tue, Jul 21, 2015 at 11:27:56PM +0200, Linus Walleij wrote:
>>>> On Tue, Jul 21, 2015 at 4:27 PM, Andrey Ryabinin <a.ryabinin@samsung.c=
om> wrote:
>>>>
>>>>> I used vexpress. Anyway, it doesn't matter now, since I have an updat=
e
>>>>> with a lot of stuff fixed, and it works on hardware.
>>>>> I still need to do some work on it and tomorrow, probably, I will sha=
re.
>>>>
>>>> Ah awesome. I have a stash of ARM boards so I can test it on a
>>>> range of hardware once you feel it's ready.
>>>>
>>>> Sorry for pulling stuff out of your hands, people are excited about
>>>> KASan ARM32 as it turns out.
>>>
>>> People may be excited about it because it's a new feature, but we reall=
y
>>> need to consider whether gobbling up 512MB of userspace for it is a goo=
d
>>> idea or not.  There are programs around which like to map large amounts
>>> of memory into their process space, and the more we steal from them, th=
e
>>> more likely these programs are to fail.
>>
>> I looked at some different approaches over the last weeks for this
>> when playing around with KASan.
>>
>> It seems since KASan was developed on 64bit systems, this was
>> not much of an issue for them as they could take their shadow
>> memory from the vmalloc space.
>>
>> I think it is possible to actually just steal as much memory as is
>> needed to cover the kernel, and not 1/8 of the entire addressable
>> 32bit space. So instead of covering all from 0x0-0xffffffff
>> at least just MODULES_VADDR thru 0xffffffff should be enough.
>> So if that is 0xbf000000-0xffffffff in most cases, 0x41000000
>> bytes, then 1/8 of that, 0x8200000, 130MB should be enough.
>> (Andrey need to say if this is possible.)
>>
>=20
> Yes, ~130Mb (3G/1G split) should work. 512Mb shadow is optional.
> The only advantage of 512Mb shadow is better handling of user memory
> accesses bugs
> (access to user memory without copy_from_user/copy_to_user/strlen_user et=
c API).
> In case of 512Mb shadow we could to not map anything in shadow for
> user addresses, so such bug will
> guarantee  to crash the kernel.
> In case of 130Mb, the behavior will depend on memory layout of the
> current process.
> So, I think it's fine to keep shadow only for kernel addresses.

Another option would be having "sparse" shadow memory based on page
extension. I did play with that some time ago based on ideas from
original v1 KASan support for x86/arm - it is how 614be38 "irqchip:
gic-v3: Fix out of bounds access to cpu_logical_map" was caught.
It doesn't require any VA reservations, only some contiguous memory for
the page_ext itself, which serves as indirection level for the 0-order
shadow pages.
In theory such design can be reused by others 32-bit arches and, I
think, nommu too. Additionally, the shadow pages might be movable with
help of driver-page migration patch series [1].
The cost is obvious - performance drop, although I didn't bother
measuring it.

[1] https://lwn.net/Articles/650917/

Cheers
Vladimir

>=20
>> That will probably miss some usecases I'm not familiar with, where
>> the kernel is actually executing something below 0xbf000000...
>>
>> I looked at taking memory from vmalloc instead, but ran into
>> problems since this is subject to the highmem split and KASan
>> need to have it's address offset at compile time. On
>> Ux500 I managed to remove all the static maps and steal memory
>> from the top of the vmalloc area instead of the beginning, but
>> that is probably not generally feasible.
>>
>> I suspect you have better ideas than what I can come up
>> with though.
>>
>> Yours,
>> Linus Walleij
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
