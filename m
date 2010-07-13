Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 43BB06B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 00:11:16 -0400 (EDT)
Received: by iwn2 with SMTP id 2so6345226iwn.14
        for <linux-mm@kvack.org>; Mon, 12 Jul 2010 21:11:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100713121947.612bd656.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713121947.612bd656.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 13 Jul 2010 13:11:14 +0900
Message-ID: <AANLkTiny7dz8ssDknI7y4JFcVP9SV1aNM7f0YMUxafv7@mail.gmail.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 12:19 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 13 Jul 2010 00:53:48 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Kukjin, Could you test below patch?
>> I don't have any sparsemem system. Sorry.
>>
>> -- CUT DOWN HERE --
>>
>> Kukjin reported oops happen while he change min_free_kbytes
>> http://www.spinics.net/lists/arm-kernel/msg92894.html
>> It happen by memory map on sparsemem.
>>
>> The system has a memory map following as.
>> =A0 =A0 =A0section 0 =A0 =A0 =A0 =A0 =A0 =A0 section 1 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0section 2
>> 0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
>> SECTION_SIZE_BITS 28(256M)
>>
>> It means section 0 is an incompletely filled section.
>> Nontheless, current pfn_valid of sparsemem checks pfn loosely.
>>
>> It checks only mem_section's validation.
>> So in above case, pfn on 0x25000000 can pass pfn_valid's validation chec=
k.
>> It's not what we want.
>>
>> The Following patch adds check valid pfn range check on pfn_valid of spa=
rsemem.
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Reported-by: Kukjin Kim <kgene.kim@samsung.com>
>>
>> P.S)
>> It is just RFC. If we agree with this, I will make the patch on mmotm.
>>
>> --
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index b4d109e..6c2147a 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -979,6 +979,8 @@ struct mem_section {
>> =A0 =A0 =A0 =A0 struct page_cgroup *page_cgroup;
>> =A0 =A0 =A0 =A0 unsigned long pad;
>> =A0#endif
>> + =A0 =A0 =A0 unsigned long start_pfn;
>> + =A0 =A0 =A0 unsigned long end_pfn;
>> =A0};
>>
>
> I have 2 concerns.
> =A01. This makes mem_section twice. Wasting too much memory and not good =
for cache.
> =A0 =A0But yes, you can put this under some CONFIG which has small number=
 of mem_section[].
>

I think memory usage isn't a big deal. but for cache, we can move
fields into just after section_mem_map.

> =A02. This can't be help for a case where a section has multiple small ho=
les.

I agree. But this(not punched hole but not filled section problem)
isn't such case. But it would be better to handle it altogether. :)

>
> Then, my proposal for HOLES_IN_MEMMAP sparsemem is below.
> =3D=3D
> Some architectures unmap memmap[] for memory holes even with SPARSEMEM.
> To handle that, pfn_valid() should check there are really memmap or not.
> For that purpose, __get_user() can be used.

Look at free_unused_memmap. We don't unmap pte of hole memmap.
Is __get_use effective, still?




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
