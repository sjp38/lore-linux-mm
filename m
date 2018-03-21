Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id C313A6B0010
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 17:37:06 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id w43-v6so3679546otd.1
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:37:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j125sor1909752oia.237.2018.03.21.14.37.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 14:37:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170510071511.GA31466@dhcp22.suse.cz>
References: <20170510065328.9215-1-nick.desaulniers@gmail.com> <20170510071511.GA31466@dhcp22.suse.cz>
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Date: Wed, 21 Mar 2018 14:37:04 -0700
Message-ID: <CAH7mPvh0qG2R30ToKV=dX3YNc+0BQtnCH3cQUANJWmVdbn6sXw@mail.gmail.com>
Subject: Re: [PATCH] mm/vmscan: fix unsequenced modification and access warning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, paullawrence@google.com

Sorry to dig up an old thread but a coworker was asking about this
patch. This is essentially the code that landed in commit
f2f43e566a02a3bdde0a65e6a2e88d707c212a29 "mm/vmscan.c: fix unsequenced
modification and access warning".

Is .reclaim_idx still correct in the case of try_to_free_pages()?  It
looks like reclaim_idx is based on the original gfp_mask in
__node_reclaim(), but in try_to_free_pages() it looks like it may have
been based on current_gfp_context()? (The sequencing is kind of
ambiguous, thus fixed in my patch)

Was there a bug in the original try_to_free_pages() pre commit
f2f43e566a0, or is .reclaim_idx supposed to be different between
try_to_free_pages() and __node_reclaim()?

On Wed, May 10, 2017 at 12:15 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 09-05-17 23:53:28, Nick Desaulniers wrote:
>> Clang flags this file with the -Wunsequenced error that GCC does not
>> have.
>>
>> unsequenced modification and access to 'gfp_mask'
>>
>> It seems that gfp_mask is both read and written without a sequence point
>> in between, which is undefined behavior.
>
> Hmm. This is rather news to me. I thought that a = foo(a) is perfectly
> valid. Same as a = b = c where c = foo(b) or is the problem in the
> following .reclaim_idx = gfp_zone(gfp_mask) initialization? If that is
> the case then the current code is OKish because gfp_zone doesn't depend
> on the gfp_mask modification. It is messy, right, but works as expected.
>
> Anyway, we have a similar construct __node_reclaim
>
> If you really want to change this code, and I would agree it would be
> slightly less tricky, then I would suggest doing something like the
> following instead
> ---
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5ebf468c5429..ba4b695e810e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2965,7 +2965,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>         unsigned long nr_reclaimed;
>         struct scan_control sc = {
>                 .nr_to_reclaim = SWAP_CLUSTER_MAX,
> -               .gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
> +               .gfp_mask = current_gfp_context(gfp_mask),
>                 .reclaim_idx = gfp_zone(gfp_mask),
>                 .order = order,
>                 .nodemask = nodemask,
> @@ -2980,12 +2980,12 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>          * 1 is returned so that the page allocator does not OOM kill at this
>          * point.
>          */
> -       if (throttle_direct_reclaim(gfp_mask, zonelist, nodemask))
> +       if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
>                 return 1;
>
>         trace_mm_vmscan_direct_reclaim_begin(order,
>                                 sc.may_writepage,
> -                               gfp_mask,
> +                               sc.gfp_mask,
>                                 sc.reclaim_idx);
>
>         nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> @@ -3772,17 +3772,16 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>         const unsigned long nr_pages = 1 << order;
>         struct task_struct *p = current;
>         struct reclaim_state reclaim_state;
> -       int classzone_idx = gfp_zone(gfp_mask);
>         unsigned int noreclaim_flag;
>         struct scan_control sc = {
>                 .nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
> -               .gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
> +               .gfp_mask = current_gfp_context(gfp_mask),
>                 .order = order,
>                 .priority = NODE_RECLAIM_PRIORITY,
>                 .may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
>                 .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
>                 .may_swap = 1,
> -               .reclaim_idx = classzone_idx,
> +               .reclaim_idx = gfp_znoe(gfp_mask),
>         };
>
>         cond_resched();
> @@ -3793,7 +3792,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>          */
>         noreclaim_flag = memalloc_noreclaim_save();
>         p->flags |= PF_SWAPWRITE;
> -       lockdep_set_current_reclaim_state(gfp_mask);
> +       lockdep_set_current_reclaim_state(sc.gfp_mask);
>         reclaim_state.reclaimed_slab = 0;
>         p->reclaim_state = &reclaim_state;
>
> --
> Michal Hocko
> SUSE Labs
