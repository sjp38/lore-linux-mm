Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 075618D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:49:01 -0500 (EST)
Received: by yxl31 with SMTP id 31so283329yxl.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 09:49:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=nsAOtLPK75Wy5Rm8pfWob8xTP5259DyYuxR9J@mail.gmail.com>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
	<1295544047.9039.609.camel@nimitz>
	<AANLkTi=nsAOtLPK75Wy5Rm8pfWob8xTP5259DyYuxR9J@mail.gmail.com>
Date: Fri, 21 Jan 2011 02:48:59 +0900
Message-ID: <AANLkTinLLYYUXe=ZYKKGXgKU_p5RHv2COX_L1zCk8Ba+@mail.gmail.com>
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
From: KyongHo Cho <pullip.linux@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Linux ARM Kernel <linux-arm-kernel@lists.infradead.org>
Cc: KyongHo Cho <pullip.cho@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene.kim@samsung.com>, Ilho Lee <ilho215.lee@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 2:20 AM, Dave Hansen <dave@linux.vnet.ibm.com> wrot=
e:
> On Thu, 2011-01-20 at 18:45 +0900, KyongHo Cho wrote:
>> Sparsemem allows that a bank of memory spans over several adjacent
>> sections if the start address and the end address of the bank
>> belong to different sections.
>> When gathering statictics of physical memory in mem_init() and
>> show_mem(), this possiblity was not considered.
>>
>> This patch guarantees that simple increasing the pointer to page
>> descriptors does not exceed the boundary of a section
> ...
>> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
>> index 57c4c5c..6ccecbe 100644
>> --- a/arch/arm/mm/init.c
>> +++ b/arch/arm/mm/init.c
>> @@ -93,24 +93,38 @@ void show_mem(void)
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn1 =3D bank_pfn_start(bank);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn2 =3D bank_pfn_end(bank);
>> -
>> +#ifndef CONFIG_SPARSEMEM
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D pfn_to_page(pfn1);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =A0=3D pfn_to_page(pfn2 - 1) + 1;
>> -
>> +#else
>> + =A0 =A0 =A0 =A0 =A0 =A0 pfn2--;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageReserved(page))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reserved++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (PageSwapCache(page))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cached++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (PageSlab(page))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slab++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (!page_count(page))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shared +=3D pa=
ge_count(page) - 1;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 } while (page < end);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D pfn_to_page(pfn1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pfn_to_section_nr(pfn1) < =
pfn_to_section_nr(pfn2)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn1 +=3D PAGE=
S_PER_SECTION;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn1 &=3D PAGE=
_SECTION_MASK;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn1 =3D pfn2;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D pfn_to_page(pfn1) + 1;
>> +#endif
>
> This problem actually exists without sparsemem, too. =A0Discontigmem (at
> least) does it as well.
>

Actually, as long as a bank in meminfo only resides in a pgdat, no
problem happens
because there is no restriction of size of area in a pgdat.
That's why I just considered about sparsemem.

> The x86 version of show_mem() actually manages to do this without any
> #ifdefs, and works for a ton of configuration options. =A0It uses
> pfn_valid() to tell whether it can touch a given pfn.
>
> Long-term, it might be a good idea to convert arm's show_mem() over to
> use pgdat's like everything else. =A0But, for now, you should just be abl=
e
> to do something roughly like this:
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D pfn_to_page(pfn1);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =A0=3D pfn_to_page(pfn2 - 1) + 1;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (pfn =3D pfn1; pfn < pfn2; pfn++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pfn_valid(pfn))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D pfn_to_page(pfn);
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (PageReserved(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reserved++=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else if (PageSwapCache(pag=
e))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cached++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else if (PageSlab(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slab++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else if (!page_count(page)=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shared +=
=3D page_count(page) - 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (page < end);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> That should work for sparsemem, or any other crazy memory models that we
> come up with. =A0pfn_to_page() is pretty quick, especially when doing it
> in a tight loop like that.
>

That's true.
I worried that pfn_to_page() in sparsemem is a bit slower than that in flat=
mem.
Moreover, the previous one didn't use pfn_to_page() but page++ for the
performance.
Nevertheless, I also think that pfn_to_page() make the code neat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
