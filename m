Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 1C4A36B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 20:09:03 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id c11so4253068ieb.15
        for <linux-mm@kvack.org>; Thu, 21 Mar 2013 17:09:02 -0700 (PDT)
Message-ID: <514BA118.5000305@gmail.com>
Date: Fri, 22 Mar 2013 08:08:56 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd reclaims
 at each priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-2-git-send-email-mgorman@suse.de> <20130320161847.GD27375@dhcp22.suse.cz> <514A59CD.3040108@redhat.com>
In-Reply-To: <514A59CD.3040108@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

Hi Rik,
On 03/21/2013 08:52 AM, Rik van Riel wrote:
> On 03/20/2013 12:18 PM, Michal Hocko wrote:
>> On Sun 17-03-13 13:04:07, Mel Gorman wrote:
>> [...]
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index 88c5fed..4835a7a 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -2593,6 +2593,32 @@ static bool prepare_kswapd_sleep(pg_data_t 
>>> *pgdat, int order, long remaining,
>>>   }
>>>
>>>   /*
>>> + * kswapd shrinks the zone by the number of pages required to reach
>>> + * the high watermark.
>>> + */
>>> +static void kswapd_shrink_zone(struct zone *zone,
>>> +                   struct scan_control *sc,
>>> +                   unsigned long lru_pages)
>>> +{
>>> +    unsigned long nr_slab;
>>> +    struct reclaim_state *reclaim_state = current->reclaim_state;
>>> +    struct shrink_control shrink = {
>>> +        .gfp_mask = sc->gfp_mask,
>>> +    };
>>> +
>>> +    /* Reclaim above the high watermark. */
>>> +    sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
>>
>> OK, so the cap is at high watermark which sounds OK to me, although I
>> would expect balance_gap being considered here. Is it not used
>> intentionally or you just wanted to have a reasonable upper bound?
>>
>> I am not objecting to that it just hit my eyes.
>
> This is the maximum number of pages to reclaim, not the point
> at which to stop reclaiming.

What's the difference between the maximum number of pages to reclaim and 
the point at which to stop reclaiming?

>
> I assume Mel chose this value because it guarantees that enough
> pages will have been freed, while also making sure that the value
> is scaled according to zone size (keeping pressure between zones
> roughly equal).
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
