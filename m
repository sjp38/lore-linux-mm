Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 338F26B0038
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 16:39:51 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id n19so3001095iob.7
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 13:39:51 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i5sor2672641ioe.107.2018.01.17.13.39.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 13:39:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
References: <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
 <201801160115.w0G1FOIG057203@www262.sakura.ne.jp> <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com> <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Jan 2018 13:39:48 -0800
Message-ID: <CA+55aFw_itrZGTkDPL41DtwCBEBHmxXsucp5HUbNDX9hwOFddw@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Wed, Jan 17, 2018 at 3:08 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> I needed to bisect between 4.10 and 4.11, and I got plausible culprit.
> [...]
> git bisect bad b4fb8f66f1ae2e167d06c12d018025a8d4d3ba7e
> # first bad commit: [b4fb8f66f1ae2e167d06c12d018025a8d4d3ba7e] mm, page_alloc: Add missing check for memory holes

Ok, that is indeed much more likely, and very much matches the whole
"this problem only happens with sparsemem" issue.

In fact, the whole

   pfn_valid_within(buddy_pfn)

test looks very odd. Maybe the pfn of the buddy is valid, but it's not
in the same zone? Then we'd combine the two pages in two different
zones into one combined page.

Maybe that's why HIGHMEM matters? The low DMA zone is obviously
aligned in the whole PAGE_ORDER range. But the highmem zone might not
be. I used to know the highmem code, but I've happily forgotten
everything. But I think we end up deciding on some random non-aligned
number in the 900MB range as being the limit between the regular zone
and the HIGHMEM zone.

So maybe something like this to test the theory?

    diff --git a/mm/page_alloc.c b/mm/page_alloc.c
    index 76c9688b6a0a..f919a5548943 100644
    --- a/mm/page_alloc.c
    +++ b/mm/page_alloc.c
    @@ -756,6 +756,8 @@ static inline void rmv_page_order(struct page *page)
     static inline int page_is_buddy(struct page *page, struct page *buddy,
                                                            unsigned int order)
     {
    +       if (WARN_ON_ONCE(page_zone(page) != page_zone(buddy)))
    +               return 0;
            if (page_is_guard(buddy) && page_order(buddy) == order) {
                    if (page_zone_id(page) != page_zone_id(buddy))
                            return 0;

I don't know. Does that warning trigger for you?

The above is completely untested. It might not compile. If it compiles
it might not work. And even if it "works", it might not matter,
because perhaps the boundary between regular memory and HIGHMEM is
already sufficiently aligned.

Comments?

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
