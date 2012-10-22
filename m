Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id B1CA76B006E
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 09:56:34 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so4575186ied.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 06:56:34 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20121022133534.GR16230@one.firstfloor.org>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
 <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com>
 <20121022132733.GQ16230@one.firstfloor.org> <20121022133534.GR16230@one.firstfloor.org>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Mon, 22 Oct 2012 15:56:13 +0200
Message-ID: <CAKgNAkgQ6JZdwOsCAQ4Ak_gVXtav=TzgzW2tbk5jMUwxtMqOAg@mail.gmail.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v6
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Oct 22, 2012 at 3:35 PM, Andi Kleen <andi@firstfloor.org> wrote:
> On Mon, Oct 22, 2012 at 03:27:33PM +0200, Andi Kleen wrote:
>> > Maybe I am missing something obvious, but does this not conflict with
>> > include/uapi/asm-generic/mman-common.h:
>> >
>> > #ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
>> > # define MAP_UNINITIALIZED 0x4000000
>> > ...
>> >
>> > 0x4000000 == (1 << 26
>> >
>>
>> You're right. Someone added that since I wrote the patch originally.
>> I owned them when originally submitted @) Thanks for catching.
>>
>> Have to move my bits two up, which will still work, but limit the
>
> Two up won't work, need one up.
>
> 32..28 = 16  is too small for 2^30 = 1GB pages
> 32..27 = 32  max 4GB pages

Not sure of your notation there. I assume 31..27 means 5 bits (32
through to 28 inclusive, 27 excluded). That gives you just 2^31 ==
2GB, not 4GB (unless your planning to always add 1 to the value in
those bits, since a value of zero has little meaning).

But there seems an obvious solution here: given your value in those
bits (call it 'n'), the why not apply a multiplier. I mean, certainly
you never want a value <= 12 for n, and I suspect that the reasonable
minimum could be much larger (e.g., 2^16). Call that minimum M. Then
you could interpret the value in your bits as meaning a page size of

    (2^n) * M

> So this will use up all remaining flag bits now.

On the other hand, that seems really bad. It looks like that kills the
ability to further extend the mmap() API with new flags in the future.
It doesn't sound like we should be doing that.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
