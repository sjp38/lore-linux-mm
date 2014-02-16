Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id CF7006B003D
	for <linux-mm@kvack.org>; Sat, 15 Feb 2014 21:59:11 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id y1so10260891lam.36
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 18:59:11 -0800 (PST)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id my6si16529657lbb.172.2014.02.15.18.59.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Feb 2014 18:59:08 -0800 (PST)
Received: by mail-la0-f53.google.com with SMTP id e16so10187101lan.40
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 18:59:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <loom.20140214T135753-812@post.gmane.org>
References: <20140213104231.GX6732@suse.de>
	<CAL1ERfNKX+o9dk5Qg77R3HQ_VLYiEL7mU0Tm_HqtSm9ixTW5fg@mail.gmail.com>
	<loom.20140214T135753-812@post.gmane.org>
Date: Sun, 16 Feb 2014 10:59:06 +0800
Message-ID: <CABdxLJHS5kw0rpD=+77iQtc6PMeRXoWnh-nh5VzjjfGHJ5wLGQ@mail.gmail.com>
Subject: Re: [PATCH] mm: swap: Use swapfiles in priority order
From: Weijie Yang <weijieut@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

 On Fri, Feb 14, 2014 at 9:10 PM, Christian Ehrhardt
<ehrhardt@linux.vnet.ibm.com> wrote:
> Weijie Yang <weijie.yang.kh <at> gmail.com> writes:
>
>>
>> On Thu, Feb 13, 2014 at 6:42 PM, Mel Gorman <mgorman <at> suse.de> wrote:
> [...]
>> > -       for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
>> > +       for (type = swap_list.head; type >= 0 && wrapped < 2; type = next) {
>>
> [...]
>> Does it lead to a "schlemiel the painter's algorithm"?
>> (please forgive my rude words, but I can't find a precise word to describe it
>>
>> How about modify it like this?
>>
> [...]
>> - next = swap_list.head;
>> + next = type;
> [...]
>
> Hi,
> unfortunately withou studying the code more thoroughly I'm not even sure if
> you meant you code to extend or replace Mels patch.
>
> To be sure about your intention.  You refered to algorithm scaling because
> you were afraid the new code would scan the full list all the time right ?
>
> But simply letting the machines give a try for both options I can now
> qualify both.
>
> Just your patch creates a behaviour of jumping over priorities (see the
> following example), so I hope you meant combining both patches.
> With that in mind the patch I eventually tested the combined patch looking
> like this:

Hi Christian,

My patch is not appropriate, so there is no need to combine it with Mel's patch.

What I worried about Mel's patch is not only the search efficiency,
actually it has
negligible impact on system, but also the following scenario:

If two swapfiles have the same priority, in ordinary semantic, they
should be used
in balance. But with Mel's patch, it will always get the free
swap_entry from the
swap_list.head in priority order, I worry it could break the balance.

I think you can test this scenario if you have available test machines.

Appreciate for your done.

> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 612a7c9..53a3873 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -650,7 +650,7 @@ swp_entry_t get_swap_page(void)
>                 goto noswap;
>         atomic_long_dec(&nr_swap_pages);
>
> -       for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
> +       for (type = swap_list.head; type >= 0 && wrapped < 2; type = next) {
>                 hp_index = atomic_xchg(&highest_priority_index, -1);
>                 /*
>                  * highest_priority_index records current highest priority swap
> @@ -675,7 +675,7 @@ swp_entry_t get_swap_page(void)
>                 next = si->next;
>                 if (next < 0 ||
>                     (!wrapped && si->prio != swap_info[next]->prio)) {
> -                       next = swap_list.head;
> +                       next = type;
>                         wrapped++;
>                 }
>
>
> At least for the two different cases we identified to fix with it the new
> code works as well:
> I) incrementing swap now in proper priority order
> Filename                                Type            Size    Used    Priority
> /testswap1                              file            100004  100004  8
> /testswap2                              file            100004  100004  7
> /testswap3                              file            100004  100004  6
> /testswap4                              file            100004  100004  5
> /testswap5                              file            100004  100004  4
> /testswap6                              file            100004  68764   3
> /testswap7                              file            100004  0       2
> /testswap8                              file            100004  0       1
>
> II) comparing a memory based block device "as one" vs "split into 8 pieces"
> as swap target(s).
> Like with Mels patch alone I'm able to achieve 1.5G/s TP on the
> overcommitted memory no matter how much swap targets I split it into.
>
> So while I can't speak for the logical correctness of your addition to the
> patch at least in terms of effectiveness it seems fine.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
