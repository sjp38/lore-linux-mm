Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D674A6B0062
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 03:37:51 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so6058587ied.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 00:37:51 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20121023022844.GQ2095@tassilo.jf.intel.com>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
 <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com>
 <20121022132733.GQ16230@one.firstfloor.org> <20121022133534.GR16230@one.firstfloor.org>
 <CAKgNAkgQ6JZdwOsCAQ4Ak_gVXtav=TzgzW2tbk5jMUwxtMqOAg@mail.gmail.com>
 <20121022153633.GK2095@tassilo.jf.intel.com> <CAKgNAki=AL+KdYDdYnE8ZhjK-tUf5cZ163BWPe6GRM0rpi-z7w@mail.gmail.com>
 <1350956664.2728.19.camel@pasglop> <20121023022844.GQ2095@tassilo.jf.intel.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Tue, 23 Oct 2012 09:37:30 +0200
Message-ID: <CAKgNAkh-OxXbc_s0yvF_SEce0JoTQhyPpGHwZikj9NpOjkJT4w@mail.gmail.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v6
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>

On Tue, Oct 23, 2012 at 4:28 AM, Andi Kleen <ak@linux.intel.com> wrote:
> On Tue, Oct 23, 2012 at 12:44:24PM +1100, Benjamin Herrenschmidt wrote:
>> On Mon, 2012-10-22 at 17:53 +0200, Michael Kerrisk (man-pages) wrote:
>>
>> > This is all seems to make an awful muck of the API...
>>
>>  .../...
>>
>> > There seems to be a reasonable argument here for an mmap3() with a
>> > 64-bit flags argument...
>>
>> I tend to agree. There's a similar issue happening when we try to shovel
>
> Could you comment on the expect range of page sizes on PPC?
>
> I looked at this again and I don't think we have anywhere near true 28 flags
> so far.  The man page currently only lists 16 (including MAP_UNUS^INITIALIZED)

As we know, man-pages are seldom complete ;:-}

> So I don't see why I can't have 6 bits from that.
>
> I have no idea why the MAP_UNINITIALIZED flag was put into this strange
> location anyways instead of directly after the existing flags or just
> into one of the unused slots.

The reason why you perhaps can't have six bits from that is quite
likely the same as the why MAP_UNINITIALIZED went to a strange place.
It's the unfortunate  smearing of individual MAP_* values across
different bits on different architectures:

$ grep 'MAP_'  $(find /home/mtk/linux-3.7-rc1 | grep mman) | awk -F':'
'{print $2}' |
    grep '[0-9]' | grep -v MAP_TYPE | grep ' MAP_' | grep define |
    sed 's/ *# *define *//' | sed 's/[        ]*\/\*.*//' | sort -k1 |
    awk '$2 != "0" && $2 != "0x0"' | tr '\011' ' '| sed 's/  */ /;
s/0x0*/0x/' | sort -u
MAP_32BIT 0x40
MAP_ANONYMOUS 0x10
MAP_ANONYMOUS 0x20
MAP_ANONYMOUS 0x800
MAP_AUTOGROW 0x40
MAP_AUTORSRV 0x100
MAP_DENYWRITE 0x2000
MAP_DENYWRITE 0x800
MAP_EXECUTABLE 0x1000
MAP_EXECUTABLE 0x4000
MAP_FIXED 0x10
MAP_FIXED 0x100
MAP_FIXED 0x4
MAP_GROWSDOWN 0x100
MAP_GROWSDOWN 0x1000
MAP_GROWSDOWN 0x200
MAP_GROWSDOWN 0x8000
MAP_GROWSUP 0x200
MAP_HUGETLB 0x100000
MAP_HUGETLB 0x4000
MAP_HUGETLB 0x40000
MAP_HUGETLB 0x80000
MAP_INHERIT 0x80
MAP_LOCAL 0x80
MAP_LOCKED 0x100
MAP_LOCKED 0x200
MAP_LOCKED 0x2000
MAP_LOCKED 0x80
MAP_LOCKED 0x8000
MAP_NONBLOCK 0x10000
MAP_NONBLOCK 0x20000
MAP_NONBLOCK 0x40000
MAP_NONBLOCK 0x80
MAP_NORESERVE 0x10000
MAP_NORESERVE 0x40
MAP_NORESERVE 0x400
MAP_NORESERVE 0x4000
MAP_POPULATE 0x10000
MAP_POPULATE 0x20000
MAP_POPULATE 0x40
MAP_POPULATE 0x8000
MAP_PRIVATE 0x2
MAP_RENAME 0x20
MAP_SHARED 0x1
MAP_STACK 0x20000
MAP_STACK 0x40000
MAP_STACK 0x80000
MAP_UNINITIALIZED 0x4000000

> I suppose I could put my bits before it, there's plenty of space.

Only on x86...

> Existing flags on x86:
>
> #define MAP_SHARED      0x01            /* Share changes */
> #define MAP_PRIVATE     0x02            /* Changes are private */
>
> 4 unused
> 8 unused
>
> #define MAP_FIXED       0x10            /* Interpret addr exactly */
> #define MAP_ANONYMOUS   0x20            /* don't use a file */
>
> 0x40 unused
>
> #define MAP_GROWSDOWN   0x0100          /* stack-like segment */
>
> 0x200 unused
> 0x400 unused
>
> #define MAP_DENYWRITE   0x0800          /* ETXTBSY */
> #define MAP_EXECUTABLE  0x1000          /* mark it as an executable */
> #define MAP_LOCKED      0x2000          /* pages are locked */
> #define MAP_NORESERVE   0x4000          /* don't check for reservations */
> #define MAP_POPULATE    0x8000          /* populate (prefault) pagetables */
> #define MAP_NONBLOCK    0x10000         /* do not block on IO */
> #define MAP_STACK       0x20000         /* give out an address that is best suited for process/thread stacks */
> #define MAP_HUGETLB     0x40000         /* create a huge page mapping */
>
> /* all free here: 6 bits for me? 0x80000..0x1000000 */
>
> # define MAP_UNINITIALIZED 0x4000000    /* For anonymous mmap, memory could be uninitialized */
>
> /* more free bits. */
>
> Overall it seems there's no real shortage of bits.

Across architectures, there is, unless you plan to just further
increase the mess...

Out of the mess shown above, the free bits across all architectures look to be
0xfbe00008 === 11111011111000000000000000001000
(Note: no 6 adjacent bits.)

Now, my scripting above may not have captured all of the bits, and
some of the MAP_* constants may actually be completely unused, so the
above may not be completely accurate, so don't rely on it. Anyway, the
point is, there are not so many spare bits, really.

>> things into protection bits, like we do with SAO (strong access
>> ordering) and want to do with per-page endian on embedded.
>
> mprotect already does this.
>
> Unless someone finds a good reason why this can't work I'll just move
> the range to 0x80000..0x1000000.

IMO, the output of the script above is a plausible reason not to do this.

The mmap2() API has become a crufty mess. *Maybe* you can do what you
want, at the cost of further extending the cruft (i.e., by finding
different groups of 6 bits on different architectures). But at some
point the mess is going to be bad enough that someone will need to do
mmap3(), and consuming 6 bits of the bit-space is bringing us a big
step closer to that point.

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
