Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 511F66B02D5
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 04:13:15 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7F00GF3YTZ9V90@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Aug 2010 09:13:11 +0100 (BST)
Received: from localhost ([10.89.8.241])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7F00M3QYQ1XH@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Aug 2010 09:13:11 +0100 (BST)
Date: Fri, 20 Aug 2010 10:10:45 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv3 0/6] The Contiguous Memory Allocator framework
In-reply-to: <20100820155617S.fujita.tomonori@lab.ntt.co.jp>
Message-id: <op.vhp7rxz77p4s8u@localhost>
Content-transfer-encoding: Quoted-Printable
References: <op.vhppgaxq7p4s8u@localhost>
 <20100820121124Z.fujita.tomonori@lab.ntt.co.jp> <op.vhp4pws27p4s8u@localhost>
 <20100820155617S.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: hverkuil@xs4all.nl, dwalker@codeaurora.org, linux@arm.linux.org.uk, corbet@lwn.net, p.osciak@samsung.com, broonie@opensource.wolfsonmicro.com, linux-kernel@vger.kernel.org, hvaibhav@ti.com, linux-mm@kvack.org, kyungmin.park@samsung.com, kgene.kim@samsung.com, zpfeffer@codeaurora.org, jaeryul.oh@samsung.com, m.szyprowski@samsung.com, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 08:57:51 +0200, FUJITA Tomonori <fujita.tomonori@lab=
.ntt.co.jp> wrote:

> On Fri, 20 Aug 2010 08:38:10 +0200
> **UNKNOWN CHARSET** <m.nazarewicz@samsung.com> wrote:
>
>> On Fri, 20 Aug 2010 05:12:50 +0200, FUJITA Tomonori <fujita.tomonori@=
lab.ntt.co.jp> wrote:
>> >> 1. Integration on API level meaning that some kind of existing API=
 is used
>> >>     instead of new cma_*() calls.  CMA adds notion of devices and =
memory
>> >>     types which is new to all the other APIs (coherent has notion =
of devices
>> >>     but that's not enough).  This basically means that no existing=
 API can be
>> >>     used for CMA.  On the other hand, removing notion of devices a=
nd memory
>> >>     types would defeat the whole purpose of CMA thus destroying th=
e solution
>> >>     that CMA provides.
>> >
>> > You can create something similar to the existing API for memory
>> > allocator.
>>
>> That may be tricky.  cma_alloc() takes four parameters each of which =
is
>> required for CMA.  No other existing set of API uses all those argume=
nts.
>> This means, CMA needs it's own, somehow unique API.  I don't quite se=
e
>> how the APIs may be unified or "made similar".  Of course, I'm gladly=

>> accepting suggestions.
>
> Have you even tried to search 'blk_kmalloc' on google?

I have and I haven't seen any way how

   void *()(struct request_queue *q, unsigned size, gfp_t gfp);

prototype could be applied to CMA.  I admit that I haven't read the whol=
e
discussion of the patch and maybe I'm missing something about Andi's pat=
ches
but I don't see how CMA could but from what I've understood blk_kmalloc(=
) is
dissimilar to CMA.  I'll be glad if you could show me where I'm wrong.

> I wrote "similar to the existing API', not "reuse the existing API".

Yes, but I don't really know what you have in mind.  CMA is similar to v=
arious
APIs in various ways: it's similar to any allocator since it takes size =
in bytes,
it's similar to coherent since it takes device, it's similar to bootmem/=
memblock/etc
since it takes alignment.  I would appreciate if you could give some exa=
mples of what
you mean by similar and ideas haw CMA's API may be improved.

>> >> 2. Reuse of memory pools meaning that memory reserved by CMA can t=
hen be
>> >>     used by other allocation mechanisms.  This is of course possib=
le.  For
>> >>     instance coherent could easily be implemented as a wrapper to =
CMA.
>> >>     This is doable and can be done in the future after CMA gets mo=
re
>> >>     recognition.
>> >>
>> >> 3. Reuse of algorithms meaning that allocation algorithms used by =
other
>> >>     allocators will be used with CMA regions.  This is doable as w=
ell and
>> >>     can be done in the future.
>> >
>> > Well, why can't we do the above before the inclusion?
>>
>> Because it's quite a bit of work and instead of diverting my attentio=
n I'd
>> prefer to make CMA as good as possible and then integrate it with oth=
er
>> subsystems.  Also, adding the integration would change the patch from=
 being
>> 4k lines to being like 40k lines.
>
> 4k to 40k? I'm not sure. But If I see something like the following, I
> suspect that there is a better way to integrate this into the existing=

> infrastructure.
>
> mm/cma-best-fit.c                   |  407 +++++++++++++++

Ah, sorry.  I misunderstood you.  I thought you were replying to both 2.=
 and 3.
above.

If we only take allocating algorithm then you're right.  Reusing existin=
g one
should not increase the patch size plus it would be probably a better so=
lution.

No matter, I would rather first work and core CMA without worrying about=
 reusing
kmalloc()/coherent/etc. code especially since providing a plugable alloc=
ator API
integration with existing allocating algorithms can be made later on.  T=
o put it
short I want first to make it work and then improve it.

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
