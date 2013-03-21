Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id C69006B0005
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 20:52:40 -0400 (EDT)
Message-ID: <514A59CD.3040108@redhat.com>
Date: Wed, 20 Mar 2013 20:52:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd reclaims
 at each priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-2-git-send-email-mgorman@suse.de> <20130320161847.GD27375@dhcp22.suse.cz>
In-Reply-To: <20130320161847.GD27375@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On 03/20/2013 12:18 PM, Michal Hocko wrote:
> On Sun 17-03-13 13:04:07, Mel Gorman wrote:
> [...]
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 88c5fed..4835a7a 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2593,6 +2593,32 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
>>   }
>>
>>   /*
>> + * kswapd shrinks the zone by the number of pages required to reach
>> + * the high watermark.
>> + */
>> +static void kswapd_shrink_zone(struct zone *zone,
>> +			       struct scan_control *sc,
>> +			       unsigned long lru_pages)
>> +{
>> +	unsigned long nr_slab;
>> +	struct reclaim_state *reclaim_state = current->reclaim_state;
>> +	struct shrink_control shrink = {
>> +		.gfp_mask = sc->gfp_mask,
>> +	};
>> +
>> +	/* Reclaim above the high watermark. */
>> +	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
>
> OK, so the cap is at high watermark which sounds OK to me, although I
> would expect balance_gap being considered here. Is it not used
> intentionally or you just wanted to have a reasonable upper bound?
>
> I am not objecting to that it just hit my eyes.

This is the maximum number of pages to reclaim, not the point
at which to stop reclaiming.

I assume Mel chose this value because it guarantees that enough
pages will have been freed, while also making sure that the value
is scaled according to zone size (keeping pressure between zones
roughly equal).

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
