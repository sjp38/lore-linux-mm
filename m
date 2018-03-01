Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 149AE6B0011
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 10:09:38 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id x85so3177852oix.8
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 07:09:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l21sor1648605oii.227.2018.03.01.07.09.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 07:09:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180301131033.GH15057@dhcp22.suse.cz>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com> <20180301131033.GH15057@dhcp22.suse.cz>
From: Daniel Vacek <neelx@redhat.com>
Date: Thu, 1 Mar 2018 16:09:35 +0100
Message-ID: <CACjP9X-S=OgmUw-WyyH971_GREn1WzrG3aeGkKLyR1bO4_pWPA@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: fix memmap_init_zone pageblock alignment
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org

ffffe31d01ed8000  7b600000                0        0  0 0
On Thu, Mar 1, 2018 at 2:10 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 01-03-18 13:47:45, Daniel Vacek wrote:
>> In move_freepages() a BUG_ON() can be triggered on uninitialized page structures
>> due to pageblock alignment. Aligning the skipped pfns in memmap_init_zone() the
>> same way as in move_freepages_block() simply fixes those crashes.
>
> This changelog doesn't describe how the fix works. Why doesn't
> memblock_next_valid_pfn return the first valid pfn as one would expect?

Actually it does. The point is it is not guaranteed to be pageblock
aligned. And we
actually want to initialize even those page structures which are
outside of the range.
Hence the alignment here.

For example from reproducer machine, memory map from e820/BIOS:

$ grep 7b7ff000 /proc/iomem
7b7ff000-7b7fffff : System RAM

Page structures before commit b92df1de5d28:

crash> kmem -p 77fff000 78000000 7b5ff000 7b600000 7b7fe000 7b7ff000
7b800000 7ffff000 80000000
      PAGE        PHYSICAL      MAPPING       INDEX CNT FLAGS
fffff73941e00000  78000000                0        0  1 1fffff00000000
fffff73941ed7fc0  7b5ff000                0        0  1 1fffff00000000
fffff73941ed8000  7b600000                0        0  1 1fffff00000000
fffff73941edff80  7b7fe000                0        0  1 1fffff00000000
fffff73941edffc0  7b7ff000 ffff8e67e04d3ae0     ad84  1 1fffff00020068
uptodate,lru,active,mappedtodisk    <<<< start of the range here
fffff73941ee0000  7b800000                0        0  1 1fffff00000000
fffff73941ffffc0  7ffff000                0        0  1 1fffff00000000

So far so good.

After commit b92df1de5d28 machine eventually crashes with:

BUG at mm/page_alloc.c:1913

>         VM_BUG_ON(page_zone(start_page) != page_zone(end_page));

>From registers and stack I digged start_page points to
ffffe31d01ed8000 (note that this is
page ffffe31d01edffc0 aligned to pageblock) and I can see this in memory dump:

crash> kmem -p 77fff000 78000000 7b5ff000 7b600000 7b7fe000 7b7ff000
7b800000 7ffff000 80000000
      PAGE        PHYSICAL      MAPPING       INDEX CNT FLAGS
ffffe31d01e00000  78000000                0        0  0 0
ffffe31d01ed7fc0  7b5ff000                0        0  0 0
ffffe31d01ed8000  7b600000                0        0  0 0    <<<< note
that nodeid and zonenr are encoded in top bits of page flags which are
not initialized here, hence the crash :-(
ffffe31d01edff80  7b7fe000                0        0  0 0
ffffe31d01edffc0  7b7ff000                0        0  1 1fffff00000000
ffffe31d01ee0000  7b800000                0        0  1 1fffff00000000
ffffe31d01ffffc0  7ffff000                0        0  1 1fffff00000000

With my fix applied:

crash> kmem -p 77fff000 78000000 7b5ff000 7b600000 7b7fe000 7b7ff000
7b800000 7ffff000 80000000
      PAGE        PHYSICAL      MAPPING       INDEX CNT FLAGS
ffffea0001e00000  78000000                0        0  0 0
ffffea0001e00000  7b5ff000                0        0  0 0
ffffea0001ed8000  7b600000                0        0  1 1fffff00000000
   <<<< vital data filled in here this time \o/
ffffea0001edff80  7b7fe000                0        0  1 1fffff00000000
ffffea0001edffc0  7b7ff000 ffff88017fb13720        8  2 1fffff00020068
uptodate,lru,active,mappedtodisk
ffffea0001ee0000  7b800000                0        0  1 1fffff00000000
ffffea0001ffffc0  7ffff000                0        0  1 1fffff00000000

We are not interested in the beginning of whole section. Just the
pages in the first
populated block where the range begins are important (actually just
the first one really, but...).


> It would be also good put the panic info in the changelog.

Of course I forgot to link the related bugzilla:

https://bugzilla.kernel.org/show_bug.cgi?id=196443

Though it is not very well explained there as well. I hope my notes
above make it clear.


>> Fixes: b92df1de5d28 ("[mm] page_alloc: skip over regions of invalid pfns where possible")
>> Signed-off-by: Daniel Vacek <neelx@redhat.com>
>> Cc: stable@vger.kernel.org
>> ---
>>  mm/page_alloc.c | 9 +++++++--
>>  1 file changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index cb416723538f..9edee36e6a74 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5359,9 +5359,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>                       /*
>>                        * Skip to the pfn preceding the next valid one (or
>>                        * end_pfn), such that we hit a valid pfn (or end_pfn)
>> -                      * on our next iteration of the loop.
>> +                      * on our next iteration of the loop. Note that it needs
>> +                      * to be pageblock aligned even when the region itself
>> +                      * is not as move_freepages_block() can shift ahead of
>> +                      * the valid region but still depends on correct page
>> +                      * metadata.
>>                        */
>> -                     pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
>> +                     pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
>> +                                             ~(pageblock_nr_pages-1)) - 1;
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
