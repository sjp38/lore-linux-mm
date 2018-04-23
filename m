Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 389156B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 23:30:19 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id m18-v6so2948762lfj.1
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 20:30:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x144-v6sor2549140lff.48.2018.04.22.20.30.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 20:30:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com> <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com>
From: Chunyu Hu <chuhu.ncepu@gmail.com>
Date: Mon, 23 Apr 2018 11:30:16 +0800
Message-ID: <CABATaM7bLKsz1jRW4O39mpG-ae2LyASitvddXB4765HsYtXK+w@mail.gmail.com>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Chunyu Hu <chuhu@redhat.com>, mhocko@suse.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>

On 21 April 2018 at 01:50, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Sat, Apr 21, 2018 at 12:58:33AM +0800, Chunyu Hu wrote:
>> __GFP_NORETRY and  __GFP_NOFAIL are combined in gfp_kmemleak_mask now.
>> But it's a wrong combination. As __GFP_NOFAIL is blockable, but
>> __GFP_NORETY is not blockable, make it self-contradiction.
>>
>> __GFP_NOFAIL means 'The VM implementation _must_ retry infinitely'. But
>> it's not the real intention, as kmemleak allow alloc failure happen in
>> memory pressure, in that case kmemleak just disables itself.
>
> Good point. The __GFP_NOFAIL flag was added by commit d9570ee3bd1d
> ("kmemleak: allow to coexist with fault injection") to keep kmemleak
> usable under fault injection.

oops. I did not notice this.  so this is for skipping fault injection.
>
>> commit 9a67f6488eca ("mm: consolidate GFP_NOFAIL checks in the allocator
>> slowpath") documented that what user wants here should use GFP_NOWAIT, and
>> the WARN in __alloc_pages_slowpath caught this weird usage.

>>
>>  <snip>
>>  WARNING: CPU: 3 PID: 64 at mm/page_alloc.c:4261 __alloc_pages_slowpath+0x1cc3/0x2780
> [...]
>> Replace the __GFP_NOFAIL with GFP_NOWAIT in gfp_kmemleak_mask, __GFP_NORETRY
>> and GFP_NOWAIT are in the gfp_kmemleak_mask. So kmemleak object allocaion
>> is no blockable and no reclaim, making kmemleak less disruptive to user
>> processes in pressure.
>
> It doesn't solve the fault injection problem for kmemleak (unless we
> change __should_failslab() somehow, not sure yet). An option would be to
> replace __GFP_NORETRY with __GFP_NOFAIL in kmemleak when fault injection
> is enabled.
>
> BTW, does the combination of NOWAIT and NORETRY make kmemleak
> allocations more likely to fail?

this NOWAIT added here seems won't make it more likely to fail, as it its
defined as, which make kswapd woke in pressure.  But this replacement
indeed will make fault injection in kmemleak got back.

#define GFP_NOWAIT  (__GFP_KSWAPD_RECLAIM)

>
> Cc'ing Dmitry as well.
>
>> Signed-off-by: Chunyu Hu <chuhu@redhat.com>
>> CC: Michal Hocko <mhocko@suse.com>
>> ---
>>  mm/kmemleak.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>> index 9a085d5..4ea07e4 100644
>> --- a/mm/kmemleak.c
>> +++ b/mm/kmemleak.c
>> @@ -126,7 +126,7 @@
>>  /* GFP bitmask for kmemleak internal allocations */
>>  #define gfp_kmemleak_mask(gfp)       (((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
>>                                __GFP_NORETRY | __GFP_NOMEMALLOC | \
>> -                              __GFP_NOWARN | __GFP_NOFAIL)
>> +                              __GFP_NOWARN | GFP_NOWAIT)
>>
>>  /* scanning area inside a memory block */
>>  struct kmemleak_scan_area {
>> --
>> 1.8.3.1
