Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id F0B876B005A
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 11:54:05 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so4837896ied.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 08:54:05 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20121022153633.GK2095@tassilo.jf.intel.com>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
 <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com>
 <20121022132733.GQ16230@one.firstfloor.org> <20121022133534.GR16230@one.firstfloor.org>
 <CAKgNAkgQ6JZdwOsCAQ4Ak_gVXtav=TzgzW2tbk5jMUwxtMqOAg@mail.gmail.com> <20121022153633.GK2095@tassilo.jf.intel.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Mon, 22 Oct 2012 17:53:45 +0200
Message-ID: <CAKgNAki=AL+KdYDdYnE8ZhjK-tUf5cZ163BWPe6GRM0rpi-z7w@mail.gmail.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v6
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>

On Mon, Oct 22, 2012 at 5:36 PM, Andi Kleen <ak@linux.intel.com> wrote:
>> Not sure of your notation there. I assume 31..27 means 5 bits (32
>> through to 28 inclusive, 27 excluded). That gives you just 2^31 ==
> [27...31]

(Hmm -- sleeping as I wrote that, but I at least got the end point right.)

> You're right it's only 5 bits, so just 2GB.
>
> Thinking about it more PowerPC has a 16GB page, so we probably
> need to move this to prot.
>
> However I'm not sure if any architectures use let's say the high
> 8 bits of prot.

This is all seems to make an awful muck of the API...

I'm not sure whether anything is using the high 8 bits of prot, bun
passing I note that there seems to be no check that the unused bits
are zeroed so there's a small chance  existing apps are passing random
garbage there. (Of course, mmap() is hardly the only API to have that
fault, and it hasn't stopped us from reusing bits in those APIs,
though sometimes we've gotten bitten by apps that did pass in random
garbage).

>> But there seems an obvious solution here: given your value in those
>> bits (call it 'n'), the why not apply a multiplier. I mean, certainly
>> you never want a value <= 12 for n, and I suspect that the reasonable
>> minimum could be much larger (e.g., 2^16). Call that minimum M. Then
>> you could interpret the value in your bits as meaning a page size of
>>
>>     (2^n) * M
>
> I considered that, but it would seem ugly and does not add that
> many bits.
>
>>
>> > So this will use up all remaining flag bits now.
>>
>> On the other hand, that seems really bad. It looks like that kills the
>> ability to further extend the mmap() API with new flags in the future.
>> It doesn't sound like we should be doing that.
>
> You can always add flags to PROT or add a mmap3(). Has been done before.
> Or just don't do any new MAP_SECURITY_HOLEs

There seems to be a reasonable argument here for an mmap3() with a
64-bit flags argument...

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
