Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E99E86B0003
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 05:54:52 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id m133so4614654oig.12
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 02:54:52 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n57sor2690685otd.155.2018.03.02.02.54.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 02:54:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACjP9X8hFDhkKUHRu2K5WgEp9YFHh2=vMSyM6KkZ5UZtxs7k-w@mail.gmail.com>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <20180301131033.GH15057@dhcp22.suse.cz> <CACjP9X-S=OgmUw-WyyH971_GREn1WzrG3aeGkKLyR1bO4_pWPA@mail.gmail.com>
 <20180301152729.GM15057@dhcp22.suse.cz> <CACjP9X8hFDhkKUHRu2K5WgEp9YFHh2=vMSyM6KkZ5UZtxs7k-w@mail.gmail.com>
From: Daniel Vacek <neelx@redhat.com>
Date: Fri, 2 Mar 2018 11:54:51 +0100
Message-ID: <CACjP9X9BVmr0wkrS5=oruQJFEs0ip7VFvD8rdWSZFcoYyiYB5A@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: fix memmap_init_zone pageblock alignment
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Paul Burton <paul.burton@imgtec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, stable@vger.kernel.org

On Thu, Mar 1, 2018 at 5:20 PM, Daniel Vacek <neelx@redhat.com> wrote:
> On Thu, Mar 1, 2018 at 4:27 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> It is still not clear why not to do the alignment in
>> memblock_next_valid_pfn rather than its caller.
>
> As it's the mem init which needs it to be aligned. Other callers may
> not, possibly?
> Not that there are any other callers at the moment so it really does
> not matter where it is placed. The only difference would be the end of
> the loop with end_pfn vs aligned end_pfn. And it looks like the pure
> (unaligned) end_pfn would be preferred here. Wanna me send a v2?

Thinking about it again memblock has nothing to do with pageblock. And
the function name suggests one shall get a next valid pfn, not
something totally unrelated to memblock. So that's what it returns.
It's the mem init which needs to align this and hence mem init aligns
it for it's purposes. I'd call this the correct design.

To deal with the end_pfn special case I'd actually get rid of it
completely and hardcode -1UL as max pfn instead (rather than 0).
Caller should handle max pfn as an error or end of the loop as here in
this case.

I'll send a v2 with this implemented.

Paul> Why is it based on memblock actually? Wouldn't a generic
mem_section solution work satisfiable for you? That would be natively
aligned with whole section (doing a bit more work as a result in the
end) and also independent of CONFIG_HAVE_MEMBLOCK_NODE_MAP
availability.

>> --
>> Michal Hocko
>> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
