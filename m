Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A8B878D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 05:18:19 -0400 (EDT)
Received: from eu_spt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LB100CCJOIG8O@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 29 Oct 2010 10:18:16 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LB1005Q4OIF28@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 29 Oct 2010 10:18:16 +0100 (BST)
Date: Fri, 29 Oct 2010 11:20:40 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [RFC][PATCH 0/3] big chunk memory allocator v2
In-reply-to: <AANLkTim4fFXQKqmFCeR8pvi0SZPXpjDqyOkbV6PYJYkR@mail.gmail.com>
Message-id: <op.vlbywq137p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTim4fFXQKqmFCeR8pvi0SZPXpjDqyOkbV6PYJYkR@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, andi.kleen@intel.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, fujita.tomonori@lab.ntt.co.jp, felipe.contreras@gmail.com, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Russell King <linux@arm.linux.org.uk>, Pawel Osciak <pawel@osciak.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

> On Tue, Oct 26, 2010 at 7:00 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> I only did small test and it seems to work (but I think there will be=
 bug...)
>> I post this now just because I'll be out of office 10/31-11/15 with k=
summit and
>> a private trip.
>>
>> Any comments are welcome but please see the interface is enough for u=
se cases or
>> not.  For example) If MAX_ORDER alignment is too bad, I need to rewri=
te almost
>> all code.

On Thu, 28 Oct 2010 01:22:38 +0200, Minchan Kim <minchan.kim@gmail.com> =
wrote:
> First of all, thanks for the endless your effort to embedded system.
> It's time for statkeholders to review this.
> Cced some guys. Maybe many people of them have to attend KS.
> So I hope SAMSUNG guys review this.
>
> Maybe they can't test this since ARM doesn't support movable zone now.=

> (I will look into this).
> As Kame said, please, review this patch whether this patch have enough=

> interface and meet your requirement.
> I think this can't meet _all_ of your requirements(ex, latency and
> making sure getting big contiguous memory) but I believe it can meet
> NOT CRITICAL many cases, I guess.

I'm currently working on a framework (the CMA framework some may be awar=
e of) which
in principle is meant for the same purpose: allocating physically contig=
uous blocks
of memory.  I'm hoping to help with latency, remove the need for MAX_ORD=
ER alignment
as well as help with fragmentation by letting different drivers allocate=
 memory from
different memory range.

When I was posting CMA, it had been suggested to create a new migration =
type
dedicated to contiguous allocations.  I think I already did that and tha=
nks to
this new migration type we have (i) an area of memory that only accepts =
movable
and reclaimable pages and (ii) is used only if all other (non-reserved) =
pages have
been allocated.

I'm currently working on migration so that those movable and reclaimable=
 pages
allocated in area dedicated for CMA are freed and Kame's work is quite h=
elpful
in this regard as I have something to base my work on. :)

Nonetheless, it's a conference time now (ELC, PLC; interestingly both ar=
e in
Cambridge :P) so I guess we, here at SPRC, will look into it more after =
PLC.

>> Now interface is:
>>
>> struct page *__alloc_contig_pages(unsigned long base, unsigned long e=
nd,
>>                        unsigned long nr_pages, int align_order,
>>                        int node, gfp_t gfpflag, nodemask_t *mask)
>>
>>  * @base: the lowest pfn which caller wants.
>>  * @end:  the highest pfn which caller wants.
>>  * @nr_pages: the length of a chunk of pages to be allocated.
>>  * @align_order: alignment of start address of returned chunk in orde=
r.
>>  *   Returned' page's order will be aligned to (1 << align_order).If =
smaller
>>  *   than MAX_ORDER, it's raised to MAX_ORDER.
>>  * @node: allocate near memory to the node, If -1, current node is us=
ed


PS. Please note that Pawel's new address is <pawel@osciak.com>.  Fixing =
in Cc.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
