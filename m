Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7746B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 09:45:21 -0400 (EDT)
Received: by obbwr7 with SMTP id wr7so113387989obb.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:45:20 -0700 (PDT)
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com. [209.85.218.48])
        by mx.google.com with ESMTPS id e145si12364057oig.8.2015.08.24.06.45.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 06:45:19 -0700 (PDT)
Received: by oiev193 with SMTP id v193so80276525oie.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:45:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150824131557.GB7557@n2100.arm.linux.org.uk>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
	<CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
	<CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
	<CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
	<CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
	<CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>
	<55AE56DB.4040607@samsung.com>
	<CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>
	<20150824131557.GB7557@n2100.arm.linux.org.uk>
Date: Mon, 24 Aug 2015 15:45:18 +0200
Message-ID: <CACRpkdYwpucRiXM05y00RQY=gKv8W6YjCNspYFRMGaM605cU0w@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Linus Walleij <linus.walleij@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Alexander Potapenko <glider@google.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On Mon, Aug 24, 2015 at 3:15 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Tue, Jul 21, 2015 at 11:27:56PM +0200, Linus Walleij wrote:
>> On Tue, Jul 21, 2015 at 4:27 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>>
>> > I used vexpress. Anyway, it doesn't matter now, since I have an update
>> > with a lot of stuff fixed, and it works on hardware.
>> > I still need to do some work on it and tomorrow, probably, I will share.
>>
>> Ah awesome. I have a stash of ARM boards so I can test it on a
>> range of hardware once you feel it's ready.
>>
>> Sorry for pulling stuff out of your hands, people are excited about
>> KASan ARM32 as it turns out.
>
> People may be excited about it because it's a new feature, but we really
> need to consider whether gobbling up 512MB of userspace for it is a good
> idea or not.  There are programs around which like to map large amounts
> of memory into their process space, and the more we steal from them, the
> more likely these programs are to fail.

I looked at some different approaches over the last weeks for this
when playing around with KASan.

It seems since KASan was developed on 64bit systems, this was
not much of an issue for them as they could take their shadow
memory from the vmalloc space.

I think it is possible to actually just steal as much memory as is
needed to cover the kernel, and not 1/8 of the entire addressable
32bit space. So instead of covering all from 0x0-0xffffffff
at least just MODULES_VADDR thru 0xffffffff should be enough.
So if that is 0xbf000000-0xffffffff in most cases, 0x41000000
bytes, then 1/8 of that, 0x8200000, 130MB should be enough.
(Andrey need to say if this is possible.)

That will probably miss some usecases I'm not familiar with, where
the kernel is actually executing something below 0xbf000000...

I looked at taking memory from vmalloc instead, but ran into
problems since this is subject to the highmem split and KASan
need to have it's address offset at compile time. On
Ux500 I managed to remove all the static maps and steal memory
from the top of the vmalloc area instead of the beginning, but
that is probably not generally feasible.

I suspect you have better ideas than what I can come up
with though.

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
