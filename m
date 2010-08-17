Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 97A896B01F0
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 22:26:08 -0400 (EDT)
Received: by vws16 with SMTP id 16so4784634vws.14
        for <linux-mm@kvack.org>; Mon, 16 Aug 2010 19:26:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100816160623.GB15103@cmpxchg.org>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
	<1281951733-29466-3-git-send-email-mel@csn.ul.ie>
	<20100816094350.GH19797@csn.ul.ie>
	<20100816160623.GB15103@cmpxchg.org>
Date: Tue, 17 Aug 2010 11:26:05 +0900
Message-ID: <AANLkTikWzkUkkghJcPBcuPsquyw-CodbH5z1DLbOiWP9@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 2010 at 1:06 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> [npiggin@suse.de bounces, switched to yahoo address]
>
> On Mon, Aug 16, 2010 at 10:43:50AM +0100, Mel Gorman wrote:

<snip>

>> + =A0 =A0 =A0* potentially causing a live-lock. While kswapd is awake an=
d
>> + =A0 =A0 =A0* free pages are low, get a better estimate for free pages
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (nr_free_pages < zone->percpu_drift_mark &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !waitqueue_active(&zone->zone_=
pgdat->kswapd_wait)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 int cpu;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct per_cpu_pageset *pset;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pset =3D per_cpu_ptr(zone->pag=
eset, cpu);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_free_pages +=3D pset->vm_st=
at_diff[NR_FREE_PAGES];

We need to consider CONFIG_SMP.

>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return nr_free_pages;
>> +}
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index c2407a4..67a2ed0 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1462,7 +1462,7 @@ int zone_watermark_ok(struct zone *z, int order, u=
nsigned long mark,
>> =A0{
>> =A0 =A0 =A0 /* free_pages my go negative - that's OK */
>> =A0 =A0 =A0 long min =3D mark;
>> - =A0 =A0 long free_pages =3D zone_page_state(z, NR_FREE_PAGES) - (1 << =
order) + 1;
>> + =A0 =A0 long free_pages =3D zone_nr_free_pages(z) - (1 << order) + 1;
>> =A0 =A0 =A0 int o;
>>
>> =A0 =A0 =A0 if (alloc_flags & ALLOC_HIGH)
>> @@ -2413,7 +2413,7 @@ void show_free_areas(void)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " all_unreclaimable? %s"
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "\n",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->name,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 K(zone_page_state(zone, NR_FRE=
E_PAGES)),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 K(zone_nr_free_pages(zone)),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 K(min_wmark_pages(zone)),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 K(low_wmark_pages(zone)),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 K(high_wmark_pages(zone)),
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 7759941..c95a159 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -143,6 +143,9 @@ static void refresh_zone_stat_thresholds(void)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 per_cpu_ptr(zone->pageset, c=
pu)->stat_threshold
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D threshold;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 zone->percpu_drift_mark =3D high_wmark_pages(z=
one) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 num_online_cpus() * threshold;
>> =A0 =A0 =A0 }
>> =A0}
>
> Hm, this one I don't quite get (might be the jetlag, though): we have
> _at least_ NR_FREE_PAGES free pages, there may just be more lurking in

We can't make sure it.
As I said previous mail, current allocation path decreases
NR_FREE_PAGES after it removes pages from buddy list.

> the pcp counters.
>
> So shouldn't we only collect the pcp deltas in case the high watermark
> is breached? =A0Above this point, we should be fine or better, no?

If we don't consider allocation path, I agree on Hannes's opinion.
At least, we need to listen why Mel determine the threshold. :)



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
