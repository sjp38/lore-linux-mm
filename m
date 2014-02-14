Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 875E36B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 05:17:47 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id cc10so301559wib.10
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 02:17:46 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iy12si729502wic.81.2014.02.14.02.17.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 02:17:45 -0800 (PST)
Date: Fri, 14 Feb 2014 10:17:42 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: swap: Use swapfiles in priority order
Message-ID: <20140214101742.GY6732@suse.de>
References: <20140213104231.GX6732@suse.de>
 <CAL1ERfNKX+o9dk5Qg77R3HQ_VLYiEL7mU0Tm_HqtSm9ixTW5fg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAL1ERfNKX+o9dk5Qg77R3HQ_VLYiEL7mU0Tm_HqtSm9ixTW5fg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 13, 2014 at 11:58:05PM +0800, Weijie Yang wrote:
> On Thu, Feb 13, 2014 at 6:42 PM, Mel Gorman <mgorman@suse.de> wrote:
> > According to the swapon documentation
> >
> >         Swap  pages  are  allocated  from  areas  in priority order,
> >         highest priority first.  For areas with different priorities, a
> >         higher-priority area is exhausted before using a lower-priority area.
> >
> > A user reported that the reality is different. When multiple swap files
> > are enabled and a memory consumer started, the swap files are consumed in
> > pairs after the highest priority file is exhausted. Early in the lifetime
> > of the test, swapfile consumptions looks like
> >
> > Filename                                Type            Size    Used    Priority
> > /testswap1                              file            100004  100004  8
> > /testswap2                              file            100004  23764   7
> > /testswap3                              file            100004  23764   6
> > /testswap4                              file            100004  0       5
> > /testswap5                              file            100004  0       4
> > /testswap6                              file            100004  0       3
> > /testswap7                              file            100004  0       2
> > /testswap8                              file            100004  0       1
> >
> > This patch fixes the swap_list search in get_swap_page to use the swap files
> > in the correct order. When applied the swap file consumptions looks like
> >
> > Filename                                Type            Size    Used    Priority
> > /testswap1                              file            100004  100004  8
> > /testswap2                              file            100004  100004  7
> > /testswap3                              file            100004  29372   6
> > /testswap4                              file            100004  0       5
> > /testswap5                              file            100004  0       4
> > /testswap6                              file            100004  0       3
> > /testswap7                              file            100004  0       2
> > /testswap8                              file            100004  0       1
> >
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/swapfile.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index 4a7f7e6..6d0ac2b 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -651,7 +651,7 @@ swp_entry_t get_swap_page(void)
> >                 goto noswap;
> >         atomic_long_dec(&nr_swap_pages);
> >
> > -       for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
> > +       for (type = swap_list.head; type >= 0 && wrapped < 2; type = next) {
> 
> Does it lead to a "schlemiel the painter's algorithm"?
> (please forgive my rude words, but I can't find a precise word to describe it
> because English is not my native language. My apologize.)
> 
> How about modify it like this?
> 

I blindly applied your version without review to see how it behaved and
found it uses every second swapfile like this

Filename                                Type            Size    Used    Priority
/testswap1                              file            100004  100004  8
/testswap2                              file            100004  16      7
/testswap3                              file            100004  100004  6
/testswap4                              file            100004  8       5
/testswap5                              file            100004  100004  4
/testswap6                              file            100004  8       3
/testswap7                              file            100004  100004  2
/testswap8                              file            100004  23504   1

I admit I did not review the swap priority search algorithm in detail
because the fix superficially looked straight forward but this
alternative is not the answer either.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
