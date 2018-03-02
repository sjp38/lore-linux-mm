Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24EDD6B0007
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 10:27:25 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id k18so4490357otj.10
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 07:27:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t33sor2623829otb.304.2018.03.02.07.27.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 07:27:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180302130052.GN15057@dhcp22.suse.cz>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <20180301131033.GH15057@dhcp22.suse.cz> <CACjP9X-S=OgmUw-WyyH971_GREn1WzrG3aeGkKLyR1bO4_pWPA@mail.gmail.com>
 <20180301152729.GM15057@dhcp22.suse.cz> <CACjP9X8hFDhkKUHRu2K5WgEp9YFHh2=vMSyM6KkZ5UZtxs7k-w@mail.gmail.com>
 <20180302130052.GN15057@dhcp22.suse.cz>
From: Daniel Vacek <neelx@redhat.com>
Date: Fri, 2 Mar 2018 16:27:23 +0100
Message-ID: <CACjP9X-Ew1mcTOCmfB+eTap0dZV2HVk9pZxuhbpuVPkQVd2nhA@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: fix memmap_init_zone pageblock alignment
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org

On Fri, Mar 2, 2018 at 2:01 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 01-03-18 17:20:04, Daniel Vacek wrote:
>> On Thu, Mar 1, 2018 at 4:27 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Thu 01-03-18 16:09:35, Daniel Vacek wrote:
>> > [...]
>> >> $ grep 7b7ff000 /proc/iomem
>> >> 7b7ff000-7b7fffff : System RAM
>> > [...]
>> >> After commit b92df1de5d28 machine eventually crashes with:
>> >>
>> >> BUG at mm/page_alloc.c:1913
>> >>
>> >> >         VM_BUG_ON(page_zone(start_page) != page_zone(end_page));
>> >
>> > This is an important information that should be in the changelog.
>>
>> And that's exactly what my seven very first words tried to express in
>> human readable form instead of mechanically pasting the source code. I
>> guess that's a matter of preference. Though I see grepping later can
>> be an issue here.
>
> Do not get me wrong I do not want to nag just for fun of it. The
> changelog should be really clear about the problem. What might be clear
> to you based on the debugging might not be so clear to others. And the
> struct page initialization code is far from trivial especially when we
> have different alignment requirements by the memory model and the page
> allocator.

I get it. I didn't mean to be rude or something. I just thought I
covered all the relevant details..

> Therefore being as clear as possible is really valuable. So I would
> really love to see the changelog to contain.
> - What is going on - VM_BUG_ON in move_freepages along with the crash
>   report

I'll put more details there.

> - memory ranges exported by BIOS/FW

They were not mentioned as they are not really relevant. Any e820 map
can have issues. Now I only saw reports on few selected machines,
mostly LENOVO System x3650 M5, some FUJITSU, some Cisco blades. But
the map is always fairly normal. IIUC, the bug only happens if the
range which is not pageblock aligned happens to be the first one in a
zone or following after an not-populated section.

Again, nothing of that is really relevant. What is is that the commit
b92df1de5d28 changes the way page structures are initialized so that
for some perfectly fine maps from BIOS kernel now can crash as a
result. And my fix tries to keep at least the bare minimum of the
original behavior needed to keep kernel stable.

> - explain why is the pageblock alignment the proper one. How does the
>   range look from the memory section POV (with SPARSEMEM).

The commit message explains that. "the same way as in
move_freepages_block()" to quote myself. The alignment in this
function is the one causing the crash as the VM_BUG_ON() assert in
subsequential move_freepages() is checking the (now) uninitialized
structure. If we follow this alignment the initialization will not get
skipped for that structure. Again, this is partially restoring the
original behavior rather than rewriting move_freepages{,_block} to not
crash with some data it was not designed for.

I'll try to explain this more transparently in commit message.

Alternatively you can just revert the b92df1de5d28. That will fix the
crashes as well.

> - What about those unaligned pages which are not backed by any memory?
>   Are they reserved so that they will never get used?

They are handled the same way as it used to be before b92df1de5d28.
This patch does not change or touch anything with this regards. Or am
I wrong?

> And just to be clear. I am not saying your patch is wrong. It just

You better not. My patch it totally correct :p
(I hope)

> raises more questions than answers and I suspect it just papers over
> some more fundamental problem. I might be clearly wrong and I cannot

I see. Thank you for looking into it. It's appreciated. I would not
call it a fundamental problem, rather a design of
move_freepages{,_block} which I'd vote for keeping for now. Hopefully
I explained it above.

> deserve this more time for the next week because I will be offline

Enjoy your time off.

> but I would _really_ appreciate if this all got explained.

I'll do my best.

> Thanks!
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
