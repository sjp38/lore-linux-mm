Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 45C0A6B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 21:17:06 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p9C11a7s025512
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 21:01:36 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9C1GxBh3047588
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 21:16:59 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9C1GwZt026411
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 21:16:58 -0400
References: <20111010071119.GE6418@suse.de> <20111010150038.ac161977.akpm@linux-foundation.org> <20111010232403.GA30513@kroah.com> <20111010162813.7a470ae4.akpm@linux-foundation.org> <20111011072406.GA2503@suse.de>
In-Reply-To: <20111011072406.GA2503@suse.de>
Mime-Version: 1.0 (iPhone Mail 8L1)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <707482D3-5341-4A8D-B488-A3540E5AAFF7@austin.ibm.com>
From: IBM <nfont@austin.ibm.com>
Subject: Re: [PATCH] mm: memory hotplug: Check if pages are correctly reserved on a per-section basis
Date: Tue, 11 Oct 2011 20:16:53 -0500
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "nfont@linux.vnet.ibm.com" <nfont@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "rientjes@google.com" <rientjes@google.com>

On Oct 11, 2011, at 2:27 AM, Mel Gorman <mgorman@suse.de> wrote:

> On Mon, Oct 10, 2011 at 04:28:13PM -0700, Andrew Morton wrote:
>> On Mon, 10 Oct 2011 16:24:03 -0700
>> Greg KH <greg@kroah.com> wrote:
>>=20
>>> On Mon, Oct 10, 2011 at 03:00:38PM -0700, Andrew Morton wrote:
>>>> On Mon, 10 Oct 2011 08:11:19 +0100
>>>> Mel Gorman <mgorman@suse.de> wrote:
>>>>=20
>>>>> It is expected that memory being brought online is PageReserved
>>>>> similar to what happens when the page allocator is being brought up.
>>>>> Memory is onlined in "memory blocks" which consist of one or more
>>>>> sections. Unfortunately, the code that verifies PageReserved is
>>>>> currently assuming that the memmap backing all these pages is virtuall=
y
>>>>> contiguous which is only the case when CONFIG_SPARSEMEM_VMEMMAP is set=
.
>>>>> As a result, memory hot-add is failing on !VMEMMAP configurations
>>>>> with the message;
>>>>>=20
>>>>> kernel: section number XXX page number 256 not reserved, was it alread=
y online?
>>>>>=20
>>>>> This patch updates the PageReserved check to lookup struct page once
>>>>> per section to guarantee the correct struct page is being checked.
>>>>>=20
>>>>=20
>>>> Nathan's earlier version of this patch is already in linux-next, via
>>>> Greg.  We should drop the old version and get the new one merged
>>>> instead.
>>>=20
>>> Ok, care to send me what exactly needs to be reverted and what needs to
>>> be added?
>>=20
>> Drop
>>=20
>> commit 54f23eb7ba7619de85d8edca6e5336bc33072dbd
>> Author: Nathan Fontenot <nfont@austin.ibm.com>
>> Date:   Mon Sep 26 10:22:33 2011 -0500
>>=20
>>    memory hotplug: Correct page reservation checking
>>=20
>> and replace it with start-of-this-thread.
>>=20
>> That's assuming that Mel's update passes Nathan's review and testing :)
>=20
> It passed review and testing with IBM based on a SUSE bug. I thought
> Nathan's patch had been lost as it was posted to linuxppc-dev instead
> of linux-mm. This rework was to improve the changelog and readability.
>=20
> David correctly pointed out a bug that passed testing because it was
> still checking one page per section. As long as that page was reserved,
> memory hot-add would go ahead. Here is a corrected version.
>=20
Updated patch has been tested.

-Nathan

> Thanks
>=20
> =3D=3D=3D=3D CUT HERE =3D=3D=3D=3D
> mm: memory hotplug: Check if pages are correctly reserved on a per-section=
 basis
>=20
> It is expected that memory being brought online is PageReserved
> similar to what happens when the page allocator is being brought up.
> Memory is onlined in "memory blocks" which consist of one or more
> sections. Unfortunately, the code that verifies PageReserved is
> currently assuming that the memmap backing all these pages is virtually
> contiguous which is only the case when CONFIG_SPARSEMEM_VMEMMAP is set.
> As a result, memory hot-add is failing on those configurations with
> the message;
>=20
> kernel: section number XXX page number 256 not reserved, was it already on=
line?
>=20
> This patch updates the PageReserved check to lookup struct page once
> per section to guarantee the correct struct page is being checked.
>=20
> [Check pages within sections properly: rientjes@google.com]
> [original patch by: nfont@linux.vnet.ibm.com]
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
> drivers/base/memory.c |   58 +++++++++++++++++++++++++++++++++------------=
---
> 1 files changed, 40 insertions(+), 18 deletions(-)
>=20
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 2840ed4..ffb69cd 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -224,13 +224,48 @@ int memory_isolate_notify(unsigned long val, void *v=
)
> }
>=20
> /*
> + * The probe routines leave the pages reserved, just as the bootmem code d=
oes.
> + * Make sure they're still that way.
> + */
> +static bool pages_correctly_reserved(unsigned long start_pfn,
> +                    unsigned long nr_pages)
> +{
> +    int i, j;
> +    struct page *page;
> +    unsigned long pfn =3D start_pfn;
> +
> +    /*
> +     * memmap between sections is not contiguous except with
> +     * SPARSEMEM_VMEMMAP. We lookup the page once per section
> +     * and assume memmap is contiguous within each section
> +     */
> +    for (i =3D 0; i < sections_per_block; i++, pfn +=3D PAGES_PER_SECTION=
) {
> +        if (WARN_ON_ONCE(!pfn_valid(pfn)))
> +            return false;
> +        page =3D pfn_to_page(pfn);
> +
> +        for (j =3D 0; j < PAGES_PER_SECTION; j++) {
> +            if (PageReserved(page + j))
> +                continue;
> +
> +            printk(KERN_WARNING "section number %ld page number %d "
> +                "not reserved, was it already online?\n",
> +                pfn_to_section_nr(pfn), j);
> +
> +            return false;
> +        }
> +    }
> +
> +    return true;
> +}
> +
> +/*
>  * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
>  * OK to have direct references to sparsemem variables in here.
>  */
> static int
> memory_block_action(unsigned long phys_index, unsigned long action)
> {
> -    int i;
>    unsigned long start_pfn, start_paddr;
>    unsigned long nr_pages =3D PAGES_PER_SECTION * sections_per_block;
>    struct page *first_page;
> @@ -238,26 +273,13 @@ memory_block_action(unsigned long phys_index, unsign=
ed long action)
>=20
>    first_page =3D pfn_to_page(phys_index << PFN_SECTION_SHIFT);
>=20
> -    /*
> -     * The probe routines leave the pages reserved, just
> -     * as the bootmem code does.  Make sure they're still
> -     * that way.
> -     */
> -    if (action =3D=3D MEM_ONLINE) {
> -        for (i =3D 0; i < nr_pages; i++) {
> -            if (PageReserved(first_page+i))
> -                continue;
> -
> -            printk(KERN_WARNING "section number %ld page number %d "
> -                "not reserved, was it already online?\n",
> -                phys_index, i);
> -            return -EBUSY;
> -        }
> -    }
> -
>    switch (action) {
>        case MEM_ONLINE:
>            start_pfn =3D page_to_pfn(first_page);
> +
> +            if (!pages_correctly_reserved(start_pfn, nr_pages))
> +                return -EBUSY;
> +
>            ret =3D online_pages(start_pfn, nr_pages);
>            break;
>        case MEM_OFFLINE:
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
