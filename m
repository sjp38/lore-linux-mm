Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1616B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 08:33:18 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id uq10so927804igb.0
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 05:33:18 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id cb10si6940249icc.139.2014.02.14.05.33.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 05:33:17 -0800 (PST)
Received: by mail-ig0-f177.google.com with SMTP id k19so826805igc.4
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 05:33:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140214101742.GY6732@suse.de>
References: <20140213104231.GX6732@suse.de>
	<CAL1ERfNKX+o9dk5Qg77R3HQ_VLYiEL7mU0Tm_HqtSm9ixTW5fg@mail.gmail.com>
	<20140214101742.GY6732@suse.de>
Date: Fri, 14 Feb 2014 21:33:17 +0800
Message-ID: <CAL1ERfMnN28X4wj-jS90kL3syPmup4VUMh45D_A=0WQq2xYO1A@mail.gmail.com>
Subject: Re: [PATCH] mm: swap: Use swapfiles in priority order
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Feb 14, 2014 at 6:17 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Thu, Feb 13, 2014 at 11:58:05PM +0800, Weijie Yang wrote:
>> On Thu, Feb 13, 2014 at 6:42 PM, Mel Gorman <mgorman@suse.de> wrote:
>> > According to the swapon documentation
>> >
>> >         Swap  pages  are  allocated  from  areas  in priority order,
>> >         highest priority first.  For areas with different priorities, a
>> >         higher-priority area is exhausted before using a lower-priority area.
>> >
>> > A user reported that the reality is different. When multiple swap files
>> > are enabled and a memory consumer started, the swap files are consumed in
>> > pairs after the highest priority file is exhausted. Early in the lifetime
>> > of the test, swapfile consumptions looks like
>> >
>> > Filename                                Type            Size    Used    Priority
>> > /testswap1                              file            100004  100004  8
>> > /testswap2                              file            100004  23764   7
>> > /testswap3                              file            100004  23764   6
>> > /testswap4                              file            100004  0       5
>> > /testswap5                              file            100004  0       4
>> > /testswap6                              file            100004  0       3
>> > /testswap7                              file            100004  0       2
>> > /testswap8                              file            100004  0       1
>> >
>> > This patch fixes the swap_list search in get_swap_page to use the swap files
>> > in the correct order. When applied the swap file consumptions looks like
>> >
>> > Filename                                Type            Size    Used    Priority
>> > /testswap1                              file            100004  100004  8
>> > /testswap2                              file            100004  100004  7
>> > /testswap3                              file            100004  29372   6
>> > /testswap4                              file            100004  0       5
>> > /testswap5                              file            100004  0       4
>> > /testswap6                              file            100004  0       3
>> > /testswap7                              file            100004  0       2
>> > /testswap8                              file            100004  0       1
>> >
>> > Signed-off-by: Mel Gorman <mgorman@suse.de>
>> > ---
>> >  mm/swapfile.c | 2 +-
>> >  1 file changed, 1 insertion(+), 1 deletion(-)
>> >
>> > diff --git a/mm/swapfile.c b/mm/swapfile.c
>> > index 4a7f7e6..6d0ac2b 100644
>> > --- a/mm/swapfile.c
>> > +++ b/mm/swapfile.c
>> > @@ -651,7 +651,7 @@ swp_entry_t get_swap_page(void)
>> >                 goto noswap;
>> >         atomic_long_dec(&nr_swap_pages);
>> >
>> > -       for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
>> > +       for (type = swap_list.head; type >= 0 && wrapped < 2; type = next) {
>>
>> Does it lead to a "schlemiel the painter's algorithm"?
>> (please forgive my rude words, but I can't find a precise word to describe it
>> because English is not my native language. My apologize.)
>>
>> How about modify it like this?
>>
>
> I blindly applied your version without review to see how it behaved and
> found it uses every second swapfile like this

I am sorry to waste your time, I should have tested it.
I will review the code more carefully, and send a tested patch if I find a
better way.
Apologize again.

> Filename                                Type            Size    Used    Priority
> /testswap1                              file            100004  100004  8
> /testswap2                              file            100004  16      7
> /testswap3                              file            100004  100004  6
> /testswap4                              file            100004  8       5
> /testswap5                              file            100004  100004  4
> /testswap6                              file            100004  8       3
> /testswap7                              file            100004  100004  2
> /testswap8                              file            100004  23504   1
>
> I admit I did not review the swap priority search algorithm in detail
> because the fix superficially looked straight forward but this
> alternative is not the answer either.
>
> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
