Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 786726B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 02:44:43 -0400 (EDT)
Received: by iwn2 with SMTP id 2so7832330iwn.14
        for <linux-mm@kvack.org>; Tue, 13 Jul 2010 23:44:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100714092301.69e7e628.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713093006.GB14504@cmpxchg.org>
	<20100713154335.GB2815@barrios-desktop>
	<1279038933.10995.9.camel@nimitz>
	<20100713164423.GC2815@barrios-desktop>
	<20100714092301.69e7e628.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 14 Jul 2010 15:44:41 +0900
Message-ID: <AANLkTin8tdw4VmfCPHE0TR3f-l7ao8ngQJcepTDPpMAC@mail.gmail.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi, Kame.

On Wed, Jul 14, 2010 at 9:23 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 14 Jul 2010 01:44:23 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> > If you _really_ can't make the section size smaller, and the vast
>> > majority of the sections are fully populated, you could hack something
>> > in. =A0We could, for instance, have a global list that's mostly readon=
ly
>> > which tells you which sections need to be have their sizes closely
>> > inspected. =A0That would work OK if, for instance, you only needed to
>> > check a couple of memory sections in the system. =A0It'll start to suc=
k if
>> > you made the lists very long.
>>
>> Thanks for advise. As I say, I hope Russell accept 16M section.
>>
>
> It seems what I needed was good sleep....
> How about this if 16M section is not acceptable ?
>
> =3D=3D NOT TESTED AT ALL, EVEN NOT COMPILED =3D=3D
>
> register address of mem_section to memmap itself's page struct's pg->priv=
ate field.
> This means the page is used for memmap of the section.
> Otherwise, the page is used for other purpose and memmap has a hole.

It's a very good idea. :)
But can this handle case that a page on memmap pages have struct page
descriptor of hole?
I mean one page can include 128 page descriptor(4096 / 32).
In there, 64 page descriptor is valid but remain 64 page descriptor is on h=
ole.
In this case, free_memmap doesn't free the page.

I think most of system will have aligned memory of 512K(4K * 128).
But I am not sure.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
