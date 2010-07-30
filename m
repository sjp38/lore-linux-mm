Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D8B7B6B02A7
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 05:43:59 -0400 (EDT)
Received: by gwj16 with SMTP id 16so694890gwj.14
        for <linux-mm@kvack.org>; Fri, 30 Jul 2010 02:43:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1280450338.16922.11735.camel@nimitz>
References: <20100728155617.GA5401@barrios-desktop>
	<alpine.DEB.2.00.1007281158150.21717@router.home>
	<20100728225756.GA6108@barrios-desktop>
	<alpine.DEB.2.00.1007291038100.16510@router.home>
	<20100729161856.GA16420@barrios-desktop>
	<alpine.DEB.2.00.1007291132210.17734@router.home>
	<20100729170313.GB16420@barrios-desktop>
	<alpine.DEB.2.00.1007291222410.17734@router.home>
	<20100729183320.GH18923@n2100.arm.linux.org.uk>
	<1280436919.16922.11246.camel@nimitz>
	<20100729221426.GA28699@n2100.arm.linux.org.uk>
	<1280450338.16922.11735.camel@nimitz>
Date: Fri, 30 Jul 2010 18:43:58 +0900
Message-ID: <AANLkTimY6CKzY-BjOq9wn21WjGWZ8fGAttHtmss30P6o@mail.gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 9:38 AM, Dave Hansen <dave@linux.vnet.ibm.com> wrot=
e:
> On Thu, 2010-07-29 at 23:14 +0100, Russell King - ARM Linux wrote:
>> What we need is something which allows us to handle memory scattered
>> in several regions of the physical memory map, each bank being a
>> variable size.
>
> Russell, it does sound like you have a pretty pathological case here. :)
> It's not one that we've really attempted to address on any other
> architectures.
>
> Just to spell it out, if you have 4GB of physical address space, with
> 512k sections, you need 8192 sections, which means 8192*8 bytes, so it'd
> eat 64k of memory. =A0That's the normal SPARSEMEM case.
>
> SPARSEMEM_EXTREME would be a bit different. =A0It's a 2-level lookup.
> You'd have 16 "section roots", each representing 256MB of address space.
> Each time we put memory under one of those roots, we'd fill in a
> 512-section second-level table, which is designed to always fit into one
> page. =A0If you start at 256MB, you won't waste all those entries.
>
> The disadvantage of SPARSEMEM_EXTREME is that it costs you the extra
> level in the lookup. =A0The space loss in arm's case would only be 16
> pointers, which would more than be made up for by the other gains.
>
> The other case where it really makes no sense is when you're populating
> a single (or small number) of sections, evenly across the address space.
> For instance, let's say you have 16 512k banks, evenly spaced at 256MB
> intervals:
>
> =A0 =A0 =A0 =A0512k@0x00000000
> =A0 =A0 =A0 =A0512k@0x10000000
> =A0 =A0 =A0 =A0512k@0x20000000
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0512k@0xF0000000
>
> If you use SPARSEMEM_EXTREME on that it will degenerate to having the
> same memory consumption as classic SPARSEMEM, along with the extra
> lookup of EXTREME. =A0But, I haven't heard you say that you have this kin=
d
> of configuration, yet. :)
>
> SPARSEMEM_EXTREME is really easy to test. =A0You just have to set it in
> your .config. =A0To get much use out of it, you'd also need to make the
> SECTION_SIZE, like the 512k we were talking about.
>

Thanks for good explanation.
When this problem happened, I suggested to use section size 16M.
The space isn't a big cost but failed since Russell doesn't like it.

So I tried to enhance sparsemem to support hole but you guys doesn't like i=
t.
Frankly speaking myself don't like this approach but I think whoever
have to care of the problem.

Hmm, Is it better to give up Samsung's good embedded board?
It depends on Russell's opinion.

I will hold this patch until reaching the conclusion of controversial
discussion.
Thanks, Dave.

> -- Dave
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
