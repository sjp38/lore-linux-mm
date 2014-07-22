Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 54EAF6B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:46:10 -0400 (EDT)
Received: by mail-oa0-f44.google.com with SMTP id eb12so227353oac.3
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:46:10 -0700 (PDT)
Received: from mail-oa0-x233.google.com (mail-oa0-x233.google.com [2607:f8b0:4003:c02::233])
        by mx.google.com with ESMTPS id cg2si144064obc.30.2014.07.22.12.46.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 12:46:09 -0700 (PDT)
Received: by mail-oa0-f51.google.com with SMTP id o6so219855oag.24
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:46:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53CEBCF3.9010208@imgtec.com>
References: <1406055673-10100-1-git-send-email-jcmvbkbc@gmail.com>
	<1406055673-10100-7-git-send-email-jcmvbkbc@gmail.com>
	<53CEBCF3.9010208@imgtec.com>
Date: Tue, 22 Jul 2014 23:46:09 +0400
Message-ID: <CAMo8BfJgBvJAXuqexRn0WWXinafCY-fX5q9pwvn-e+n-RphP8A@mail.gmail.com>
Subject: Re: [PATCH 6/8] mm/highmem: make kmap cache coloring aware
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux/MIPS Mailing List <linux-mips@linux-mips.org>, David Rientjes <rientjes@google.com>

On Tue, Jul 22, 2014 at 11:35 PM, Leonid Yegoshin
<Leonid.Yegoshin@imgtec.com> wrote:
> On 07/22/2014 12:01 PM, Max Filippov wrote:
>>
>> From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
>>
>> Provide hooks that allow architectures with aliasing cache to align
>> mapping address of high pages according to their color. Such architectures
>> may enforce similar coloring of low- and high-memory page mappings and
>> reuse existing cache management functions to support highmem.
>>
>> Cc: linux-mm@kvack.org
>> Cc: linux-arch@vger.kernel.org
>> Cc: linux-mips@linux-mips.org
>> Cc: David Rientjes <rientjes@google.com>
>> Signed-off-by: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
>> [ Max: extract architecture-independent part of the original patch, clean
>>    up checkpatch and build warnings. ]
>> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
>> ---
>> Changes since the initial version:
>> - define set_pkmap_color(pg, cl) as do { } while (0) instead of /* */;
>> - rename is_no_more_pkmaps to no_more_pkmaps;
>> - change 'if (count > 0)' to 'if (count)' to better match the original
>>    code behavior;
>>
>>   mm/highmem.c | 19 ++++++++++++++++---
>>   1 file changed, 16 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/highmem.c b/mm/highmem.c
>> index b32b70c..88fb62e 100644
>> --- a/mm/highmem.c
>> +++ b/mm/highmem.c
>> @@ -44,6 +44,14 @@ DEFINE_PER_CPU(int, __kmap_atomic_idx);
>>    */
>>   #ifdef CONFIG_HIGHMEM
>>   +#ifndef ARCH_PKMAP_COLORING
>> +#define set_pkmap_color(pg, cl)                do { } while (0)
>> +#define get_last_pkmap_nr(p, cl)       (p)
>> +#define get_next_pkmap_nr(p, cl)       (((p) + 1) & LAST_PKMAP_MASK)
>> +#define no_more_pkmaps(p, cl)          (!(p))
>> +#define get_next_pkmap_counter(c, cl)  ((c) - 1)
>> +#endif
>> +
>>   unsigned long totalhigh_pages __read_mostly;
>>   EXPORT_SYMBOL(totalhigh_pages);
>>   @@ -161,19 +169,24 @@ static inline unsigned long map_new_virtual(struct
>> page *page)
>>   {
>>         unsigned long vaddr;
>>         int count;
>> +       int color __maybe_unused;
>> +
>> +       set_pkmap_color(page, color);
>> +       last_pkmap_nr = get_last_pkmap_nr(last_pkmap_nr, color);
>>     start:
>>         count = LAST_PKMAP;
>>         /* Find an empty entry */
>>         for (;;) {
>> -               last_pkmap_nr = (last_pkmap_nr + 1) & LAST_PKMAP_MASK;
>> -               if (!last_pkmap_nr) {
>> +               last_pkmap_nr = get_next_pkmap_nr(last_pkmap_nr, color);
>> +               if (no_more_pkmaps(last_pkmap_nr, color)) {
>>                         flush_all_zero_pkmaps();
>>                         count = LAST_PKMAP;
>>                 }
>>                 if (!pkmap_count[last_pkmap_nr])
>>                         break;  /* Found a usable entry */
>> -               if (--count)
>> +               count = get_next_pkmap_counter(count, color);
>> +               if (count)
>>                         continue;
>>                 /*
>
> I would like to return back to "if (count >0)".
>
> The reason is in easy way to jump through the same coloured pages - next
> element is calculated via decrementing by non "1" value of colours and it
> can easy become negative on last page available:
>
> #define     get_next_pkmap_counter(c,cl)    (c - FIX_N_COLOURS)
>
> where FIX_N_COLOURS is a max number of page colours.

Initial value of c (i.e. LAST_PKMAP) should be a multiple of FIX_N_COLOURS,
so that should not be a problem.

> Besides that it is a good practice in stopping cycle.

But I agree with that.

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
