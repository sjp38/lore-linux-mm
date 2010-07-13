Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2059C6B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 04:06:58 -0400 (EDT)
Received: by iwn2 with SMTP id 2so6537603iwn.14
        for <linux-mm@kvack.org>; Tue, 13 Jul 2010 01:06:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100713154025.7c60c76b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713121947.612bd656.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTiny7dz8ssDknI7y4JFcVP9SV1aNM7f0YMUxafv7@mail.gmail.com>
	<20100713132312.a7dfb100.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinVwmo5pemz86nXaQT3V_ujaPLOsyNeQIFhL0Vu@mail.gmail.com>
	<20100713154025.7c60c76b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 13 Jul 2010 17:06:56 +0900
Message-ID: <AANLkTinxTojeckJpfLh9eMM4odK61-VzE2A0G9E3nRuQ@mail.gmail.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 3:40 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 13 Jul 2010 15:04:00 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> >> > =A02. This can't be help for a case where a section has multiple sm=
all holes.
>> >>
>> >> I agree. But this(not punched hole but not filled section problem)
>> >> isn't such case. But it would be better to handle it altogether. :)
>> >>
>> >> >
>> >> > Then, my proposal for HOLES_IN_MEMMAP sparsemem is below.
>> >> > =3D=3D
>> >> > Some architectures unmap memmap[] for memory holes even with SPARSE=
MEM.
>> >> > To handle that, pfn_valid() should check there are really memmap or=
 not.
>> >> > For that purpose, __get_user() can be used.
>> >>
>> >> Look at free_unused_memmap. We don't unmap pte of hole memmap.
>> >> Is __get_use effective, still?
>> >>
>> > __get_user() works with TLB and page table, the vaddr is really mapped=
 or not.
>> > If you got SEGV, __get_user() returns -EFAULT. It works per page granu=
le.
>>
>> I mean following as.
>> For example, there is a struct page in on 0x20000000.
>>
>> int pfn_valid_mapped(unsigned long pfn)
>> {
>> =A0 =A0 =A0 =A0struct page *page =3D pfn_to_page(pfn); /* hole page is 0=
x2000000 */
>> =A0 =A0 =A0 =A0char *lastbyte =3D (char *)(page+1)-1; =A0/* lastbyte is =
0x2000001f */
>> =A0 =A0 =A0 =A0char byte;
>>
>> =A0 =A0 =A0 =A0/* We pass this test since free_unused_memmap doesn't unm=
ap pte */
>> =A0 =A0 =A0 =A0if(__get_user(byte, page) !=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> why ? When the page size is 4096 byte.
>
> =A0 =A0 =A00x1ffff000 - 0x1ffffffff
> =A0 =A0 =A00x20000000 - 0x200000fff are on the same page. And memory is m=
apped per page.

sizeof(struct page) is 32 byte.
So lastbyte is address of struct page + 32 byte - 1.

> What we access by above __get_user() is a byte at [0x20000000, 0x20000001=
)

Right.

> and it's unmapped if 0x20000000 is unmapped.

free_unused_memmap doesn't unmap pte although it returns the page to
free list of buddy.

>
> Thanks,
> -Kame
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
