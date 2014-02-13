Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 74FD56B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 10:58:06 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id c10so13080394igq.0
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 07:58:06 -0800 (PST)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id ix6si2960813icb.57.2014.02.13.07.58.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 07:58:05 -0800 (PST)
Received: by mail-ig0-f174.google.com with SMTP id hl1so13272477igb.1
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 07:58:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140213104231.GX6732@suse.de>
References: <20140213104231.GX6732@suse.de>
Date: Thu, 13 Feb 2014 23:58:05 +0800
Message-ID: <CAL1ERfNKX+o9dk5Qg77R3HQ_VLYiEL7mU0Tm_HqtSm9ixTW5fg@mail.gmail.com>
Subject: Re: [PATCH] mm: swap: Use swapfiles in priority order
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 13, 2014 at 6:42 PM, Mel Gorman <mgorman@suse.de> wrote:
> According to the swapon documentation
>
>         Swap  pages  are  allocated  from  areas  in priority order,
>         highest priority first.  For areas with different priorities, a
>         higher-priority area is exhausted before using a lower-priority area.
>
> A user reported that the reality is different. When multiple swap files
> are enabled and a memory consumer started, the swap files are consumed in
> pairs after the highest priority file is exhausted. Early in the lifetime
> of the test, swapfile consumptions looks like
>
> Filename                                Type            Size    Used    Priority
> /testswap1                              file            100004  100004  8
> /testswap2                              file            100004  23764   7
> /testswap3                              file            100004  23764   6
> /testswap4                              file            100004  0       5
> /testswap5                              file            100004  0       4
> /testswap6                              file            100004  0       3
> /testswap7                              file            100004  0       2
> /testswap8                              file            100004  0       1
>
> This patch fixes the swap_list search in get_swap_page to use the swap files
> in the correct order. When applied the swap file consumptions looks like
>
> Filename                                Type            Size    Used    Priority
> /testswap1                              file            100004  100004  8
> /testswap2                              file            100004  100004  7
> /testswap3                              file            100004  29372   6
> /testswap4                              file            100004  0       5
> /testswap5                              file            100004  0       4
> /testswap6                              file            100004  0       3
> /testswap7                              file            100004  0       2
> /testswap8                              file            100004  0       1
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/swapfile.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 4a7f7e6..6d0ac2b 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -651,7 +651,7 @@ swp_entry_t get_swap_page(void)
>                 goto noswap;
>         atomic_long_dec(&nr_swap_pages);
>
> -       for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
> +       for (type = swap_list.head; type >= 0 && wrapped < 2; type = next) {

Does it lead to a "schlemiel the painter's algorithm"?
(please forgive my rude words, but I can't find a precise word to describe it
because English is not my native language. My apologize.)

How about modify it like this?

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 4a7f7e6..d64aa55 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -676,7 +676,7 @@ swp_entry_t get_swap_page(void)
  next = si->next;
  if (next < 0 ||
     (!wrapped && si->prio != swap_info[next]->prio)) {
- next = swap_list.head;
+ next = type;
  wrapped++;
  }

>                 hp_index = atomic_xchg(&highest_priority_index, -1);
>                 /*
>                  * highest_priority_index records current highest priority swap
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
