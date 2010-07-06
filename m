Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7AF196B01AC
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 03:06:17 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5448389iwn.14
        for <linux-mm@kvack.org>; Tue, 06 Jul 2010 00:06:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100706150746.bc3daa86.kamezawa.hiroyu@jp.fujitsu.com>
References: <AANLkTil6go0otCsBkG_detjptXX_i_mNkkCMawLVIz82@mail.gmail.com>
	<20100706150746.bc3daa86.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 6 Jul 2010 16:06:12 +0900
Message-ID: <AANLkTimNWwuy1M72rgbm77a2R65bss1hFhLB9JLAMt4C@mail.gmail.com>
Subject: Re: Need some help in understanding sparsemem.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: naren.mehra@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 6, 2010 at 3:07 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 6 Jul 2010 10:41:06 +0530
> naren.mehra@gmail.com wrote:
>
>> Hi,
>>
>> I am trying to understand the sparsemem implementation in linux for
>> NUMA/multiple node systems.
>>
>> From the available documentation and the sparsemem patches, I am able
>> to make out that sparsemem divides memory into different sections and
>> if the whole section contains a hole then its marked as invalid
>> section and if some pages in a section form a hole then those pages
>> are marked reserved. My issue is that this classification, I am not
>> able to map it to the code.
>>
>> e.g. from arch specific code, we call memory_present() =C2=A0to prepare =
a
>> list of sections in a particular node. but unable to find where
>> exactly some sections are marked invalid because they contain a hole.
>>
>> Can somebody tell me where in the code are we identifying sections as
>> invalid and where we are marking pages as reserved.
>>
>
> As you wrote, memory_present() is just for setting flags
> "SECTION_MARKED_PRESENT". If a section contains both of valid pages and
> holes, the section itself is marked as SECTION_MARKED_PRESENT.
>
> This memory_present() is called in very early stage. The function which a=
llocates
> mem_map(array of struct page) is sparse_init(). It's called somewhere aft=
er
> memory_present().
> (In x86, it's called by paging_init(), in ARM, it's called by bootmem_ini=
t()).
>
> After sparse_init(), mem_maps are allocated. (depends on config..plz see =
codes.)
> But, here, mem_map is not initialized.
> This is because initialization logic of memmap doesn't depend on
> FLATMEM/DISCONTIGMEM/SPARSEMEM.
>
> After sprase_init(), mem_map is allocated. It's not encouraged to detect =
a section
> is valid or invalid but you can use pfn_valid() to check there are memmap=
 or not.
> (*) pfn_valid(pfn) is not for detecting there is memory but for detecting
> =C2=A0 =C2=A0there is memmap.
>
> Initializing mem_map is done by free_area_init_node(). This function init=
ializes
> memory range regitered by add_active_range() (see mm/page_alloc.c)
> (*)There are architecutures which doesn't use add_active_range(), but thi=
s function
> =C2=A0 is for generic use.
>
> After free_area_init_node(), all mem_map are initialized as PG_reserved a=
nd
> NODE_DATA(nid)->star_pfn, etc..are available.
>
> When PG_reserved is cleared is at free_all_bootmem(). If you want to keep=
 pages
> as Reserved (because of holes), OR, don't register memory hole as bootmem=
.
> Then, pages will be kept as Reserved.
>
> clarification:
> =C2=A0memory_present().... prepare for section[] and mark up PRESENT.
> =C2=A0sparse_init() =C2=A0 .... allocates mem_map. but just allocates it.
> =C2=A0free_area_init_node() .... initizalize mem_map at el.
> =C2=A0free_all_bootmem() .... make pages available and put into buddy all=
ocator.
>
> =C2=A0pfn_valid() ... useful for checking there are mem_map.

Kame explained greatly.
I want to elaborate on pfn_valid but it's off-topic. ;)

The pfn_valid isn't enough on ARM if you walk whole memmap.
That's because ARM frees memmap on hole to save the memory by
free_unused_memmap_node.

In such case, you have to use memmap_valid_within.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
