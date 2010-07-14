Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F090B6B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 03:35:24 -0400 (EDT)
Received: by iwn2 with SMTP id 2so7871257iwn.14
        for <linux-mm@kvack.org>; Wed, 14 Jul 2010 00:35:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100714161045.ef028769.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713093006.GB14504@cmpxchg.org>
	<20100713154335.GB2815@barrios-desktop>
	<1279038933.10995.9.camel@nimitz>
	<20100713164423.GC2815@barrios-desktop>
	<20100714092301.69e7e628.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTin8tdw4VmfCPHE0TR3f-l7ao8ngQJcepTDPpMAC@mail.gmail.com>
	<20100714161045.ef028769.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 14 Jul 2010 16:35:22 +0900
Message-ID: <AANLkTilVVKdLNC0OJfVv5N5GGXL9bwXJfOLC5NHE-Qc4@mail.gmail.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 14, 2010 at 4:10 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 14 Jul 2010 15:44:41 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi, Kame.
>>
>> On Wed, Jul 14, 2010 at 9:23 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Wed, 14 Jul 2010 01:44:23 +0900
>> > Minchan Kim <minchan.kim@gmail.com> wrote:
>> >
>> >> > If you _really_ can't make the section size smaller, and the vast
>> >> > majority of the sections are fully populated, you could hack someth=
ing
>> >> > in. =A0We could, for instance, have a global list that's mostly rea=
donly
>> >> > which tells you which sections need to be have their sizes closely
>> >> > inspected. =A0That would work OK if, for instance, you only needed =
to
>> >> > check a couple of memory sections in the system. =A0It'll start to =
suck if
>> >> > you made the lists very long.
>> >>
>> >> Thanks for advise. As I say, I hope Russell accept 16M section.
>> >>
>> >
>> > It seems what I needed was good sleep....
>> > How about this if 16M section is not acceptable ?
>> >
>> > =3D=3D NOT TESTED AT ALL, EVEN NOT COMPILED =3D=3D
>> >
>> > register address of mem_section to memmap itself's page struct's pg->p=
rivate field.
>> > This means the page is used for memmap of the section.
>> > Otherwise, the page is used for other purpose and memmap has a hole.
>>
>> It's a very good idea. :)
>> But can this handle case that a page on memmap pages have struct page
>> descriptor of hole?
>> I mean one page can include 128 page descriptor(4096 / 32).
> yes.
>
>> In there, 64 page descriptor is valid but remain 64 page descriptor is o=
n hole.
>> In this case, free_memmap doesn't free the page.
>
> yes. but in that case, there are valid page decriptor for 64pages of hole=
s.
> pfn_valid() should return true but PG_reserved is set.
> (This is usual behavior.)
>
> My intention is that
>
> =A0- When all 128 page descriptors are unused, free_memmap() will free it=
.
> =A0 In that case, clear page->private of a page for freed page descriptor=
s.
>
> =A0- When some of page descriptors are used, free_memmap() can't free it
> =A0 and page->private points to &mem_section. We may have memmap for memo=
ry
> =A0 hole but pfn_valid() is a function to check there is memmap or not.
> =A0 The bahavior of pfn_valid() is valid.
> =A0 Anyway, you can't free only half of page.

Okay. I missed PageReserved.
Your idea seems to be good. :)

I looked at pagetypeinfo_showblockcount_print.
It doesn't check PageReserved. Instead of it, it does ugly memmap_valid_wit=
hin.
Can't we remove it and change it with PageReserved?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
