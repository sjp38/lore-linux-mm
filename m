Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id F328E6B0006
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 11:20:06 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id v63so3573521ota.12
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 08:20:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r52sor484235otc.57.2018.03.01.08.20.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 08:20:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180301152729.GM15057@dhcp22.suse.cz>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <20180301131033.GH15057@dhcp22.suse.cz> <CACjP9X-S=OgmUw-WyyH971_GREn1WzrG3aeGkKLyR1bO4_pWPA@mail.gmail.com>
 <20180301152729.GM15057@dhcp22.suse.cz>
From: Daniel Vacek <neelx@redhat.com>
Date: Thu, 1 Mar 2018 17:20:04 +0100
Message-ID: <CACjP9X8hFDhkKUHRu2K5WgEp9YFHh2=vMSyM6KkZ5UZtxs7k-w@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: fix memmap_init_zone pageblock alignment
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org

On Thu, Mar 1, 2018 at 4:27 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 01-03-18 16:09:35, Daniel Vacek wrote:
> [...]
>> $ grep 7b7ff000 /proc/iomem
>> 7b7ff000-7b7fffff : System RAM
> [...]
>> After commit b92df1de5d28 machine eventually crashes with:
>>
>> BUG at mm/page_alloc.c:1913
>>
>> >         VM_BUG_ON(page_zone(start_page) != page_zone(end_page));
>
> This is an important information that should be in the changelog.

And that's exactly what my seven very first words tried to express in
human readable form instead of mechanically pasting the source code. I
guess that's a matter of preference. Though I see grepping later can
be an issue here.

>> >From registers and stack I digged start_page points to
>> ffffe31d01ed8000 (note that this is
>> page ffffe31d01edffc0 aligned to pageblock) and I can see this in memory dump:
>>
>> crash> kmem -p 77fff000 78000000 7b5ff000 7b600000 7b7fe000 7b7ff000
>> 7b800000 7ffff000 80000000
>>       PAGE        PHYSICAL      MAPPING       INDEX CNT FLAGS
>> ffffe31d01e00000  78000000                0        0  0 0
>> ffffe31d01ed7fc0  7b5ff000                0        0  0 0
>> ffffe31d01ed8000  7b600000                0        0  0 0    <<<< note
>
> Are those ranges covered by the System RAM as well?
>
>> that nodeid and zonenr are encoded in top bits of page flags which are
>> not initialized here, hence the crash :-(
>> ffffe31d01edff80  7b7fe000                0        0  0 0
>> ffffe31d01edffc0  7b7ff000                0        0  1 1fffff00000000
>> ffffe31d01ee0000  7b800000                0        0  1 1fffff00000000
>> ffffe31d01ffffc0  7ffff000                0        0  1 1fffff00000000
>
> It is still not clear why not to do the alignment in
> memblock_next_valid_pfn rather than its caller.

As it's the mem init which needs it to be aligned. Other callers may
not, possibly?
Not that there are any other callers at the moment so it really does
not matter where it is placed. The only difference would be the end of
the loop with end_pfn vs aligned end_pfn. And it looks like the pure
(unaligned) end_pfn would be preferred here. Wanna me send a v2?

> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
