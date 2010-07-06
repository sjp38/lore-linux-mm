Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 989916B01AC
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 06:48:17 -0400 (EDT)
Received: by vws1 with SMTP id 1so8378866vws.14
        for <linux-mm@kvack.org>; Tue, 06 Jul 2010 03:48:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTik9TlLYbG4GE6TV1wF7SOXz7v7gQ1BR531HGyNx@mail.gmail.com>
References: <AANLkTil6go0otCsBkG_detjptXX_i_mNkkCMawLVIz82@mail.gmail.com>
	<AANLkTik9TlLYbG4GE6TV1wF7SOXz7v7gQ1BR531HGyNx@mail.gmail.com>
Date: Tue, 6 Jul 2010 16:18:15 +0530
Message-ID: <AANLkTin8JIdtSFR-E1J8FwVR2WTivShmZrEoeJWjCd1j@mail.gmail.com>
Subject: Re: Need some help in understanding sparsemem.
From: naren.mehra@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Kame for your elaborate response, I got a lot of pointers on
where to look for in the code.
Kim, thanks for pointing out memmap_init_zone.
So basically those sections which contains holes in them, the mem_map
in those sections skip the entry for the invalid pages (holes).
This happens in memmap_init_zone().
1) So it means that all the sections get the initial allocation of
mem_map and in memmap_init_zone we decide whether or not it requires
any mem_map entry. Correct ??

2) Both of you mentioned that
> "If a section contains both of valid pages and
> holes, the section itself is marked as SECTION_MARKED_PRESENT."
> "It just mark _bank_ which has memory with SECTION_MARKED_PRESENT.
> Otherwise, Hole."

which happens in memory_present(). In memory_present() code, I am not
able to find anything where we are doing this classification of valid
section/bank ? To me it looks that memory_present marks, all the
sections as present and doesnt verify whether any section contains any
valid pages or not. Correct ??

void __init memory_present(int nid, unsigned long start, unsigned long end)
{
        unsigned long pfn;

        start &=3D PAGE_SECTION_MASK;
        mminit_validate_memmodel_limits(&start, &end);
        for (pfn =3D start; pfn < end; pfn +=3D PAGES_PER_SECTION) {
                unsigned long section =3D pfn_to_section_nr(pfn);
          <--- find out the section no. of the given pfn
                struct mem_section *ms;

                sparse_index_init(section, nid);
                     <---- allocate a new section pointer to the
mem_section array
                set_section_nid(section, nid);
                      <---- store the node id for the particular page.

                ms =3D __nr_to_section(section);
                     <---- get the pointer to the mem_section
                if (!ms->section_mem_map)
                     <--- mark present, if not already marked.
                        ms->section_mem_map =3D sparse_encode_early_nid(nid=
) |
                                                        SECTION_MARKED_PRES=
ENT;
        }
}

I know, I am missing something very simple... pls point it out. if possible=
.

Regards,
Naren

On Tue, Jul 6, 2010 at 1:06 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Tue, Jul 6, 2010 at 2:11 PM, =A0<naren.mehra@gmail.com> wrote:
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
>> e.g. from arch specific code, we call memory_present() =A0to prepare a
>> list of sections in a particular node. but unable to find where
>> exactly some sections are marked invalid because they contain a hole.
>
> On ARM's sparsememory,
>
> static void arm_memory_present(struct meminfo *mi)
> {
> =A0 =A0 =A0 =A0int i;
> =A0 =A0 =A0 =A0for_each_bank(i, mi) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct membank *bank =3D &mi->bank[i];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memory_present(0, bank_pfn_start(bank), ba=
nk_pfn_end(bank));
> =A0 =A0 =A0 =A0}
> }
>
> It just mark _bank_ which has memory with SECTION_MARKED_PRESENT.
> Otherwise, Hole.
>
>>
>> Can somebody tell me where in the code are we identifying sections as
>> invalid and where we are marking pages as reserved.
>
> Do you mean memmap_init_zone?
>
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
