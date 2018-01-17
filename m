Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB27A6B0271
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 16:51:54 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id p144so8319507itc.9
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 13:51:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r132sor2625918itd.53.2018.01.17.13.51.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 13:51:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFw_itrZGTkDPL41DtwCBEBHmxXsucp5HUbNDX9hwOFddw@mail.gmail.com>
References: <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
 <201801160115.w0G1FOIG057203@www262.sakura.ne.jp> <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp> <CA+55aFw_itrZGTkDPL41DtwCBEBHmxXsucp5HUbNDX9hwOFddw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Jan 2018 13:51:53 -0800
Message-ID: <CA+55aFySaBgxmNA3f_u4ebBEdD7Smq68s0qjMCntzuzP3c_gqQ@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Wed, Jan 17, 2018 at 1:39 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> In fact, the whole
>
>    pfn_valid_within(buddy_pfn)
>
> test looks very odd. Maybe the pfn of the buddy is valid, but it's not
> in the same zone? Then we'd combine the two pages in two different
> zones into one combined page.

It might also be the same allocation zone, but if the pfn's are in
different sparsemem sections that would also be problematic.

But I hope/assume that all sparsemem sections are always aligned to
(PAGE_SIZE << MAXORDER).

In contrast, the ZONE_HIGHMEM limit really does seems to be
potentially not aligned to anything, ie

 arch/x86/include/asm/pgtable_32_types.h:
     #define MAXMEM  (VMALLOC_END - PAGE_OFFSET - __VMALLOC_RESERVE)

which I have no idea what the alignment is, but VMALLOC_END at least
does not seem to have any MAXORDER alignment.

So it really does look like the zone for two page orders that would
otherwise be buddies might actually be different.

Interesting if this really is the case. Because afaik, if that
WARN_ON_ONCE actually triggers, it does seem like this bug could go
back pretty much forever.

In fact, it seems to be such a fundamental bug that I suspect I'm
entirely wrong, and full of shit. So it's an interesting and not
_obviously_ incorrect theory, but I suspect I must be missing
something.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
