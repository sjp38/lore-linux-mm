Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E095D6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 12:50:24 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 77so298746469pgc.5
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 09:50:24 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id z17si11876863pgi.387.2017.03.13.09.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 09:50:24 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id v190so71477012pfb.1
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 09:50:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170313154627.GU31518@dhcp22.suse.cz>
References: <20170310194620.5021-1-shakeelb@google.com> <20170313090206.GC31518@dhcp22.suse.cz>
 <CALvZod4sxxhj4f8pmg1s+07c2pJfHwD2T7wh7vP9sD5PRcme-A@mail.gmail.com> <20170313154627.GU31518@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 13 Mar 2017 09:50:22 -0700
Message-ID: <CALvZod4uKErf06PaTc136JD-Yznda1fqj8UoSL7vWKzPHEYXPA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix condition for throttle_direct_reclaim
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 13, 2017 at 8:46 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 13-03-17 08:07:15, Shakeel Butt wrote:
>> On Mon, Mar 13, 2017 at 2:02 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Fri 10-03-17 11:46:20, Shakeel Butt wrote:
>> >> Recently kswapd has been modified to give up after MAX_RECLAIM_RETRIES
>> >> number of unsucessful iterations. Before going to sleep, kswapd thread
>> >> will unconditionally wakeup all threads sleeping on pfmemalloc_wait.
>> >> However the awoken threads will recheck the watermarks and wake the
>> >> kswapd thread and sleep again on pfmemalloc_wait. There is a chance
>> >> of continuous back and forth between kswapd and direct reclaiming
>> >> threads if the kswapd keep failing and thus defeat the purpose of
>> >> adding backoff mechanism to kswapd. So, add kswapd_failures check
>> >> on the throttle_direct_reclaim condition.
>> >
>> > I have to say I really do not like this. kswapd_failures shouldn't
>> > really be checked outside of the kswapd context. The
>> > pfmemalloc_watermark_ok/throttle_direct_reclaim is quite complex even
>> > without putting another variable into it. I wish we rather replace this
>> > throttling by something else. Johannes had an idea to throttle by the
>> > number of reclaimers.
>> >
>>
>> Do you suspect race in accessing kswapd_failures in non-kswapd
>> context?
>
> No, this is not about race conditions. It is more about the logic of the
> code. kswapd_failures is the private thing to the kswapd daemon. Direct
> reclaimers shouldn't have any business in it - well except resetting it.
>
>> Please do let me know more about replacing this throttling.
>
> The idea behind a different throttling would be to not allow too many
> direct reclaimers on the same set of nodes/zones. Johannes would tell
> you more.
>
>> > Anyway, I am wondering whether we can hit this issue in
>> > practice? Have you seen it happening or is this a result of the code
>> > review? I would assume that that !zone_reclaimable_pages check in
>> > pfmemalloc_watermark_ok should help to some degree.
>> >
>> Yes, I have seen this issue going on for more than one hour on my
>> test. It was a simple test where the number of processes, in the
>> presence of swap, try to allocate memory more than RAM.
>
> this is an anonymous memory, right?
>
Yes.

>> The number of
>> processes are equal to the number of cores and are pinned to each
>> individual core. I am suspecting that !zone_reclaimable_pages() check
>> did not help.
>
> Hmm, interesting! I would expect the OOM killer triggering but I guess
> I see what is going on. kswapd couldn't reclaim a single page and ran
> out of its kswapd_failures attempts while no direct reclaimers could
> reclaim a single page either until we reached the throttling point when
> we are basically livelocked because neither kswapd nor _all_ direct
> reclaimers can make a forward progress. Although this sounds quite
> unlikely I think it is quite possible to happen. So we cannot really
> throttle _all_ direct reclaimers when the kswapd is out of game which I
> haven't fully realized when reviewing "mm: fix 100% CPU kswapd busyloop
> on unreclaimable nodes".
>
> The simplest thing to do would be something like you have proposed and
> do not throttle if kswapd is out of game.
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bae698484e8e..d34b1afc781a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2791,6 +2791,9 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
>         int i;
>         bool wmark_ok;
>
> +       if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES)
> +               return true;
> +
>         for (i = 0; i <= ZONE_NORMAL; i++) {
>                 zone = &pgdat->node_zones[i];
>                 if (!managed_zone(zone))
>
> I do not like this as I've already said but it would allow to merge
> "mm: fix 100% CPU kswapd busyloop on unreclaimable nodes" without too
> many additional changes.
>
> Another option would be to cap the waiting time same as we do for
> GFP_NOFS. Not ideal either because I suspect we would just get herds
> of direct reclaimers that way.
>
> The best option would be to rethink the throttling and move it out of
> the direct reclaim path somehow.
>
Agreed.

> Thanks and sorry for not spotting the potential lockup previously.
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
