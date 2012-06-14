Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 6461B6B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:47:11 -0400 (EDT)
Received: by yenr5 with SMTP id r5so1294096yen.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 08:47:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120614152537.GR27397@tiehlicka.suse.cz>
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com> <20120614152537.GR27397@tiehlicka.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 14 Jun 2012 11:46:47 -0400
Message-ID: <CAHGf_=rcOox0qhn1WhUau4jpg+U4eNQLTrQYU5sLmp825jP+dQ@mail.gmail.com>
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Nick Piggin <npiggin@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jun 14, 2012 at 11:25 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Thu 14-06-12 04:13:12, kosaki.motohiro@gmail.com wrote:
>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>
>> Currently, do_try_to_free_pages() can enter livelock. Because of,
>> now vmscan has two conflicted policies.
>>
>> 1) kswapd sleep when it couldn't reclaim any page when reaching
>> =A0 =A0priority 0. This is because to avoid kswapd() infinite
>> =A0 =A0loop. That said, kswapd assume direct reclaim makes enough
>> =A0 =A0free pages to use either regular page reclaim or oom-killer.
>> =A0 =A0This logic makes kswapd -> direct-reclaim dependency.
>> 2) direct reclaim continue to reclaim without oom-killer until
>> =A0 =A0kswapd turn on zone->all_unreclaimble. This is because
>> =A0 =A0to avoid too early oom-kill.
>> =A0 =A0This logic makes direct-reclaim -> kswapd dependency.
>>
>> In worst case, direct-reclaim may continue to page reclaim forever
>> when kswapd sleeps forever.
>>
>> We can't turn on zone->all_unreclaimable from direct reclaim path
>> because direct reclaim path don't take any lock and this way is racy.
>>
>> Thus this patch removes zone->all_unreclaimable field completely and
>> recalculates zone reclaimable state every time.
>>
>> Note: we can't take the idea that direct-reclaim see zone->pages_scanned
>> directly and kswapd continue to use zone->all_unreclaimable. Because, it
>> is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
>> zone->all_unreclaimable as a name) describes the detail.
>>
>> Reported-by: Aaditya Kumar <aaditya.kumar.30@gmail.com>
>> Reported-by: Ying Han <yinghan@google.com>
>> Cc: Nick Piggin <npiggin@gmail.com>
>> Acked-by: Rik van Riel <riel@redhat.com>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> Looks good, just one comment bellow:
>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
> [...]
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index eeb3bc9..033671c 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
> [...]
>> @@ -1936,8 +1936,8 @@ static bool shrink_zones(struct zonelist *zonelist=
, struct scan_control *sc)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (global_reclaim(sc)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cpuset_zone_allowed_har=
dwall(zone, GFP_KERNEL))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone->all_unreclaimable &&
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 sc->priority !=3D DEF_PRIORITY)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_reclaimable(zone) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->priority !=3D DEF_=
PRIORITY)
>
> Not exactly a hot path but still would be nice to test the priority
> first as the test is cheaper (maybe compiler is clever enough to reorder
> this, as both expressions are independent and without any side-effects
> but...).

ok, will fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
