Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 97B8B6B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 08:35:28 -0500 (EST)
Received: by yx-out-1718.google.com with SMTP id 36so314015yxh.26
        for <linux-mm@kvack.org>; Fri, 06 Feb 2009 05:35:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090206122417.GB1580@cmpxchg.org>
References: <20090206122129.79CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090206044907.GA18467@cmpxchg.org>
	 <20090206135302.628E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090206122417.GB1580@cmpxchg.org>
Date: Fri, 6 Feb 2009 22:35:26 +0900
Message-ID: <28c262360902060535g22facdd0tf082ca0abaec3f80@mail.gmail.com>
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for kind explaining and good discussion, Hannes and Kosaki-san.
Always, I learn lots of thing with such good discussion. :)

On Fri, Feb 6, 2009 at 9:24 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Fri, Feb 06, 2009 at 02:59:35PM +0900, KOSAKI Motohiro wrote:
>> Hi
>>
>> > > if we think suspend performance, we should consider swap device and file-backed device
>> > > are different block device.
>> > > the interleave of file-backed page out and swap out can improve total write out performce.
>> >
>> > Hm, good point.  We could probably improve that but I don't think it's
>> > too pressing because at least on my test boxen, actual shrinking time
>> > is really short compared to the total of suspending to disk.
>>
>> ok.
>> only remain problem is mesurement result posting :)
>>
>>
>> > > if we think resume performance, we shold how think the on-disk contenious of the swap consist
>> > > process's virtual address contenious.
>> > > it cause to reduce unnecessary seek.
>> > > but your patch doesn't this.
>> > >
>> > > Could you explain this patch benefit?
>> >
>> > The patch tries to shrink those pages first that are most unlikely to
>> > be needed again after resume.  It assumes that active anon pages are
>> > immediately needed after resume while inactive file pages are not.  So
>> > it defers shrinking anon pages after file cache.
>>
>> hmm, I'm confusing.
>> I agree active anon is important than inactive file.
>> but I don't understand why scanning order at suspend change resume order.
>
> This is the problem: on suspend, we can only save about 50% of memory
> through the suspend image because of the snapshotting.  So we have to
> shrink memory before suspend.  Since you probably always have more RAM
> used than 50%, you always have to shrink.  And the image is always the
> same size.
>
> After restoring the image, resuming processes want to continue their
> work immediately and the user wants to use the applications again as
> soon as possible.
>
> Everything that is saved in the suspend image is restored and back in
> memory when the processes resume their work.
>
> Everything that is NOT saved in the suspend image is still on swap or
> not yet in the page page when the processes resume their work.
>
> So if we shrink the memory in the wrong order, after restoring the
> image we have page cache in memory that is not needed and those anon
> pages that are needed are swapped out.

It make sense.

> And the goal is that after restoring the image we have as much of the
> working set back in memory and those pages in swap and on disk-only
> that are unlikely to be used immediately by the resumed processes, so
> they can continue their work without much disk io.
>

Your intention is good to me.

>> > But I just noticed that the old behaviour defers it as well, because
>> > even if it does scan anon pages from the beginning, it allows writing
>> > only starting from pass 3.
>>
>> Ah, I see.
>> it's obiously wrong.
>>
>> > I couldn't quite understand what you wrote about on-disk
>> > contiguousness, but that claim still stands: faulting in contiguous
>> > pages from swap can be much slower than faulting file pages.  And my
>> > patch prefers mapped file pages over anon pages.  This is probably
>> > where I have seen the improvements after resume in my tests.
>>
>> sorry, I don't understand yet.
>> Why "prefers mapped file pages over anon pages" makes large improvement?
>
> Because contigously mapped file pages are faster to read in than a
> group of anon pages.  Or at least that is my claim.

It make sense if general resume process happens fault which have
locality pattern
so, you should prove this.

>
> And if we have to evict some of the working set just because the
> working set is bigger than 50% of memory, then it's better to evict
> those pages that are cheaper to refault.
>
> Does that make sense?

Indeed!

>> > Yes, I'm still thinking about ideas how to quantify it properly.  I
>> > have not yet found a reliable way to check for whether the working set
>> > is intact besides seeing whether the resumed applications are
>> > responsive right away or if they first have to swap in their pages
>> > again.
>>
>> thanks.
>> I'm looking for this :)
>
> Thanks to YOU, also for for reviewing!
>
>> > > > @@ -2134,17 +2144,17 @@ unsigned long shrink_all_memory(unsigned
>> > > >
>> > > >         /*
>> > > >          * We try to shrink LRUs in 5 passes:
>> > > > -        * 0 = Reclaim from inactive_list only
>> > > > -        * 1 = Reclaim from active list but don't reclaim mapped
>> > > > -        * 2 = 2nd pass of type 1
>> > > > -        * 3 = Reclaim mapped (normal reclaim)
>> > > > -        * 4 = 2nd pass of type 3
>> > > > +        * 0 = Reclaim unmapped inactive file pages
>> > > > +        * 1 = Reclaim unmapped file pages
>> > >
>> > > I think your patch reclaim mapped file at priority 0 and 1 too.
>> >
>> > Doesn't the following check in shrink_page_list prevent this:
>> >
>> >                 if (!sc->may_swap && page_mapped(page))
>> >                         goto keep_locked;
>> >
>> > ?
>>
>> Grr, you are right.
>> I agree, currently may_swap doesn't control swap out or not.
>> so I think we should change it correct name ;)
>
> Agreed.  What do you think about the following patch?

As for me, I can't agree with you.
There are two kinds of file-mapped pages.

1. file-mapped and dirty page.
2. file-mapped and no-dirty page

Both pages are not swapped.
File-mapped and dirty page is synced with original file
File-mapped and no-dirty page is just discarded with viewpoint of reclaim.

So, may_swap is just related to anon-pages
Thus, I think may_swap is reasonable.
How about you ?

>
> ---
> Subject: vmscan: rename may_swap scan control knob
>
> may_swap applies not only to anon pages but to mapped file pages as
> well.  Rename it to may_unmap which is the actual meaning.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9a27c44..2523600 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -60,8 +60,8 @@ struct scan_control {
>
>        int may_writepage;
>
> -       /* Can pages be swapped as part of reclaim? */
> -       int may_swap;
> +       /* Reclaim mapped pages */
> +       int may_unmap;
>
>        /* This context's SWAP_CLUSTER_MAX. If freeing memory for
>         * suspend, we effectively ignore SWAP_CLUSTER_MAX.
> @@ -606,7 +606,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                if (unlikely(!page_evictable(page, NULL)))
>                        goto cull_mlocked;
>
> -               if (!sc->may_swap && page_mapped(page))
> +               if (!sc->may_unmap && page_mapped(page))
>                        goto keep_locked;
>
>                /* Double the slab pressure for mapped and swapcache pages */
> @@ -1694,7 +1694,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>                .gfp_mask = gfp_mask,
>                .may_writepage = !laptop_mode,
>                .swap_cluster_max = SWAP_CLUSTER_MAX,
> -               .may_swap = 1,
> +               .may_unmap = 1,
>                .swappiness = vm_swappiness,
>                .order = order,
>                .mem_cgroup = NULL,
> @@ -1713,7 +1713,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  {
>        struct scan_control sc = {
>                .may_writepage = !laptop_mode,
> -               .may_swap = 1,
> +               .may_unmap = 1,
>                .swap_cluster_max = SWAP_CLUSTER_MAX,
>                .swappiness = swappiness,
>                .order = 0,
> @@ -1723,7 +1723,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>        struct zonelist *zonelist;
>
>        if (noswap)
> -               sc.may_swap = 0;
> +               sc.may_unmap = 0;
>
>        sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>                        (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> @@ -1762,7 +1762,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
>        struct reclaim_state *reclaim_state = current->reclaim_state;
>        struct scan_control sc = {
>                .gfp_mask = GFP_KERNEL,
> -               .may_swap = 1,
> +               .may_unmap = 1,
>                .swap_cluster_max = SWAP_CLUSTER_MAX,
>                .swappiness = vm_swappiness,
>                .order = order,
> @@ -2109,7 +2109,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
>        struct reclaim_state reclaim_state;
>        struct scan_control sc = {
>                .gfp_mask = GFP_KERNEL,
> -               .may_swap = 0,
> +               .may_unmap = 0,
>                .swap_cluster_max = nr_pages,
>                .may_writepage = 1,
>                .swappiness = vm_swappiness,
> @@ -2147,7 +2147,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
>
>                /* Force reclaiming mapped pages in the passes #3 and #4 */
>                if (pass > 2) {
> -                       sc.may_swap = 1;
> +                       sc.may_unmap = 1;
>                        sc.swappiness = 100;
>                }
>
> @@ -2292,7 +2292,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>        int priority;
>        struct scan_control sc = {
>                .may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> -               .may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> +               .may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
>                .swap_cluster_max = max_t(unsigned long, nr_pages,
>                                        SWAP_CLUSTER_MAX),
>                .gfp_mask = gfp_mask,
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
