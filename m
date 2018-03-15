Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4586B0009
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 21:30:44 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id a23-v6so2817274otf.4
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 18:30:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q51sor1596117otb.263.2018.03.14.18.30.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 18:30:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180314141727.GE23100@dhcp22.suse.cz>
References: <20180313224240.25295-1-neelx@redhat.com> <20180314141727.GE23100@dhcp22.suse.cz>
From: Daniel Vacek <neelx@redhat.com>
Date: Thu, 15 Mar 2018 02:30:41 +0100
Message-ID: <CACjP9X8u8Q2Jwp3CqYGJZhUdf0ivv4qGe+ZRB4A6+Z=z0vTLNQ@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: fix boot hang in memmap_init_zone
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Naresh Kamboju <naresh.kamboju@linaro.org>, Sudeep Holla <sudeep.holla@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Paul Burton <paul.burton@imgtec.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>

On Wed, Mar 14, 2018 at 3:17 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 13-03-18 23:42:40, Daniel Vacek wrote:
>> On some architectures (reported on arm64) commit 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
>> causes a boot hang. This patch fixes the hang making sure the alignment
>> never steps back.
>
> I am sorry to be complaining again, but the code is so obscure that I

No worries, I'm glad for any review. Which code exactly you do find
obscure? This patch or my former fix or the original commit
introducing memblock_next_valid_pfn()? Coz I'd agree the original
commit looks pretty obscure...

> would _really_ appreciate some more information about what is going
> on here. memblock_next_valid_pfn will most likely return a pfn within
> the same memblock and the alignment will move it before the old pfn
> which is not valid - so the block has some holes. Is that correct?

I do not understand what you mean by 'pfn within the same memblock'?
And by 'the block has some holes'?

memblock has types 'memory' (as usable memory) and 'reserved' (for
unusable mem), if I understand correctly. Both of them have an array
of regions (as an equivalent or kind of abstraction of ranges, IIUC).
memblock is a global symbol which contains all of this. So one could
say all pfns are within the same memblock. Did you mean the same
memory region perhaps? A region is solid by definition, I believe. So
there should be no holes within a single region _by_definition_
anyways. Or am I wrong here?

Now, memblock_next_valid_pfn(pfn) is called only conditionally when
the old pfn is already 'invalid' in the first place. Here the meaning
of this 'invalid' is arch/config dependent. With my former fix based
on x86_64 config I was working with assumption that the semantics of
'invalid' means the memsection does not have memmap:

early_pfn_valid(pfn)
  pfn_valid(pfn)
    valid_section(__nr_to_section(pfn_to_section_nr(pfn)))
      return (section && (section->section_mem_map & SECTION_HAS_MEM_MAP))

>From this I implied that when memblock_next_valid_pfn(pfn) is called
this pfn is the first in a section (ie. section aligned) and this
whole section is going to be skipped. So that the returned pfn will
gonna be at least one full section away from the old pfn. That's also
exactly what I can see in the memory dumps from bugreports resulting
in my former fix.
Note that with next_pfn being at least a full section away from old
pfn, there is no need to check whether it steps back or not. Even when
pageblock aligned. That's why I did not include the hunk in this patch
in my former fix.

Now I have no idea why above said does not hold true for arm64 or what
config was used there. I did not have a chance nor time to get my
hands on any arm hardware where it broke. The same way as I did not
test any architecture but x86_64 where I had original reports of
crashes before applying my former fix.
Also I am not deeply experienced with mm details and internals and how
everything works on every architecture. And even less when we speak
about early boot init. I mostly only considered the algorithm
abstractions. I bisected and reviewed the patch which regressed
x86_64. It clearly skips some pfns based on memblock memory ranges (if
available) and the skipped pages are not initialized, causing the
crash. This is clearly visible in the memory dumps I got from reports
and hopefully I already clearly explained that. I fixed this by
applying the alignment to keep at least the bare minimum of pages
initialized (so skipping a bit less than to the beginning of the next
usable range in case that range is not
section/memblock/pageblock/whatever aligned - with the pageblock
alignment being the significant one here). Since the next pfn will
always be from different section on x86_64 (at least with the
configurations I checked and my limited knowledge of this stuff), this
patch was not originally applied as it seemed redundant to me at that
time. It was only theoretically possible the algo can start looping if
the next pfn would fall under the original one but it seemed this is
impossible to happen. Since this is generic code and not arch
specific, I expected other arches to behave in a similar manner.
Though it seems arm has it's own view of pfn_valid() based on memblock
instead of mem sections:

neelx@metal:~/nX/src/linux$ global -g CONFIG_HAVE_ARCH_PFN_VALID
arch/arm/include/asm/page.h
arch/arm/mm/init.c
arch/arm64/include/asm/page.h
arch/arm64/mm/init.c
include/linux/mmzone.h
neelx@metal:~/nX/src/linux$ sed '287,293!d' arch/arm64/mm/init.c
#ifdef CONFIG_HAVE_ARCH_PFN_VALID
int pfn_valid(unsigned long pfn)
{
    return memblock_is_map_memory(pfn << PAGE_SHIFT);
}
EXPORT_SYMBOL(pfn_valid);
#endif
neelx@metal:~/nX/src/linux$


ARM seems to be a bit unique here and that's what I missed and that's
why my former fix broke arm. I was simply not expecting this. And
that's why this patch is needed (exclusively for arm it seems).

Now we can start discussing if pfn_valid() based on mem sections is
fundamentally broken or if pfn_valid() on arm based on memblock when
CONFIG_HAVE_ARCH_PFN_VALID is enabled is broken. Personally I do not
like the double meaning of it.


Ard, Naresh, Sudeep> Is CONFIG_HAVE_ARCH_PFN_VALID actually enabled
for your builds?

--nX

> If yes then please put it into the changelog. Maybe reuse data provided
> by Arnd http://lkml.kernel.org/r/20180314134431.13241-1-ard.biesheuvel@linaro.org
>
>> Link: http://lkml.kernel.org/r/0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com
>> Fixes: 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
>> Signed-off-by: Daniel Vacek <neelx@redhat.com>
>> Tested-by: Sudeep Holla <sudeep.holla@arm.com>
>> Tested-by: Naresh Kamboju <naresh.kamboju@linaro.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Paul Burton <paul.burton@imgtec.com>
>> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: <stable@vger.kernel.org>
>> ---
>>  mm/page_alloc.c | 7 ++++++-
>>  1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3d974cb2a1a1..e033a6895c6f 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5364,9 +5364,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>                        * is not. move_freepages_block() can shift ahead of
>>                        * the valid region but still depends on correct page
>>                        * metadata.
>> +                      * Also make sure we never step back.
>>                        */
>> -                     pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
>> +                     unsigned long next_pfn;
>> +
>> +                     next_pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
>>                                       ~(pageblock_nr_pages-1)) - 1;
>> +                     if (next_pfn > pfn)
>> +                             pfn = next_pfn;
>>  #endif
>>                       continue;
>>               }
>> --
>> 2.16.2
>>
>
> --
> Michal Hocko
> SUSE Labs
