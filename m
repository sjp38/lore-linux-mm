Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B85376B0089
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 10:46:06 -0500 (EST)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LCC002URH4RYM@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 23 Nov 2010 15:46:03 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LCC0075RH4RWW@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 23 Nov 2010 15:46:03 +0000 (GMT)
Date: Tue, 23 Nov 2010 16:46:03 +0100
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 0/4] big chunk memory allocator v4
In-reply-to: <20101122090431.4ff9c941.kamezawa.hiroyu@jp.fujitsu.com>
Message-id: <op.vmmre1vv7p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
 <20101119125653.16dd5452.akpm@linux-foundation.org>
 <20101122090431.4ff9c941.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, minchan.kim@gmail.com, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010 01:04:31 +0100, KAMEZAWA Hiroyuki <kamezawa.hiroyu@j=
p.fujitsu.com> wrote:

> On Fri, 19 Nov 2010 12:56:53 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Fri, 19 Nov 2010 17:10:33 +0900
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> > Hi, this is an updated version.
>> >
>> > No major changes from the last one except for page allocation funct=
ion.
>> > removed RFC.
>> >
>> > Order of patches is
>> >
>> > [1/4] move some functions from memory_hotplug.c to page_isolation.c=

>> > [2/4] search physically contiguous range suitable for big chunk all=
oc.
>> > [3/4] allocate big chunk memory based on memory hotplug(migration) =
technique
>> > [4/4] modify page allocation function.
>> >
>> > For what:
>> >
>> >   I hear there is requirements to allocate a chunk of page which is=
 larger than
>> >   MAX_ORDER. Now, some (embeded) device use a big memory chunk. To =
use memory,
>> >   they hide some memory range by boot option (mem=3D) and use hidde=
n memory
>> >   for its own purpose. But this seems a lack of feature in memory m=
anagement.
>> >
>> >   This patch adds
>> > 	alloc_contig_pages(start, end, nr_pages, gfp_mask)
>> >   to allocate a chunk of page whose length is nr_pages from [start,=
 end)
>> >   phys address. This uses similar logic of memory-unplug, which tri=
es to
>> >   offline [start, end) pages. By this, drivers can allocate 30M or =
128M or
>> >   much bigger memory chunk on demand. (I allocated 1G chunk in my t=
est).
>> >
>> >   But yes, because of fragmentation, this cannot guarantee 100% all=
oc.
>> >   If alloc_contig_pages() is called in system boot up or movable_zo=
ne is used,
>> >   this allocation succeeds at high rate.
>>
>> So this is an alternatve implementation for the functionality offered=

>> by Michal's "The Contiguous Memory Allocator framework".
>>
>
> Yes, this will be a backends for that kind of works.

As a matter of fact CMA's v6 tries to use code "borrowed" from the alloc=
_contig_pages()
patches.

The most important difference is that alloc_contig_pages() would look fo=
r a chunk
of memory that can be allocated and then perform migration whereas CMA a=
ssumes that
regions it controls are always "migratable".

Also, I've tried to remove the requirement for MAX_ORDER alignment.

> I think there are two ways to allocate contiguous pages larger than MA=
X_ORDER.
>
> 1) hide some memory at boot and add an another memory allocator.
> 2) support a range allocator as [start, end)
>
> This is an trial from 2). I used memory-hotplug technique because I kn=
ow some.
> This patch itself has no "map" and "management" function, so it should=
 be
> developped in another patch (but maybe it will be not my work.)

Yes, this is also a valid point.  From my use cases, the alloc_contig_pa=
ges()
would probably not be enough and require some management code to be adde=
d.

>> >   I tested this on x86-64, and it seems to work as expected. But fe=
edback from
>> >   embeded guys are appreciated because I think they are main user o=
f this
>> >   function.
>>
>> From where I sit, feedback from the embedded guys is *vital*, because=

>> they are indeed the main users.
>>
>> Michal, I haven't made a note of all the people who are interested in=

>> and who are potential users of this code.  Your patch series has a
>> billion cc's and is up to version 6.

Ah, yes...  I was thinking about shrinking the cc list but didn't want t=
o
seem rude or anything removing ppl who have shown interest in the previo=
us
posted version.

>> Could I ask that you review and
>> test this code, and also hunt down other people (probably at other
>> organisations) who can do likewise for us?  Because until we hear fro=
m
>> those people that this work satisfies their needs, we can't really
>> proceed much further.

A few things than:

1. As Felipe mentioned, on ARM it is often desired to have the memory
    mapped as non-cacheable, which most often mean that the memory never=

    reaches the page allocator.  This means, that alloc_contig_pages()
    would not be suitable for cases where one needs such memory.

    Or could this be overcome by adding the memory back as highmem?  But=

    then, it would force to compile in highmem support even if platform
    does not really need it.

2. Device drivers should not by themselves know what ranges of memory to=

    allocate memory from.  Moreover, some device drivers could require
    allocation different buffers from different ranges.  As such, this
    would require some management code on top of alloc_contig_pages().

3. When posting hwmem, Johan Mossberg mentioned that he'd like to see
    notion of "pinning" chunks (so that not-pinned chunks can be moved
    around when hardware does not use them to defragment memory).  This
    would again require some management code on top of
    alloc_contig_pages().

4. I might be mistaken here, but the way I understand ZONE_MOVABLE work
    is that it is cut of from the end of memory.  Or am I talking nonsen=
se?
    My concern is that at least one chip I'm working with requires
    allocations from different memory banks which would basically mean t=
hat
    there would have to be two movable zones, ie:

    +-------------------+-------------------+
    | Memory Bank #1    | Memory Bank #2    |
    +---------+---------+---------+---------+
    | normal  | movable | normal  | movable |
    +---------+---------+---------+---------+

So even though I'm personally somehow drawn by alloc_contig_pages()'s
simplicity (compared to CMA at least), those quick thoughts make me thin=
k
that alloc_contig_pages() would work rather as a backend (as Kamezawa
mentioned) for some, maybe even tiny but still present, management code
which would handle "marking memory fragments as ZONE_MOVABLE" (whatever
that would involve) and deciding which memory ranges drivers can allocat=
e
from.

I'm also wondering whether alloc_contig_pages()'s first-fit is suitable =
but
that probably cannot be judged without some benchmarks.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
