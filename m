Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id A8AC16B0007
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 05:30:51 -0500 (EST)
Message-ID: <511E0E36.3060206@parallels.com>
Date: Fri, 15 Feb 2013 14:30:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] vmscan: also shrink slab in memcg pressure
References: <1360328857-28070-1-git-send-email-glommer@parallels.com> <1360328857-28070-2-git-send-email-glommer@parallels.com> <511DF3CB.7020206@jp.fujitsu.com>
In-Reply-To: <511DF3CB.7020206@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

>> @@ -45,6 +48,7 @@ struct shrinker {
>>   
>>   	int seeks;	/* seeks to recreate an obj */
>>   	long batch;	/* reclaim batch size, 0 = default */
>> +	bool memcg_shrinker;
>>   
> 
> What is this boolean for ? When is this set ?
It is set when a subsystem declares that its shrinker is memcg capable.
Therefore, it won't be done until all infrastructure is in place. Take a
look at the super.c patches at the end of the series.


>>   static bool global_reclaim(struct scan_control *sc)
>>   {
>>   	return true;
>>   }
>> +
>> +static bool has_kmem_reclaim(struct scan_control *sc)
>> +{
>> +	return true;
>> +}
>> +
>> +static unsigned long
>> +zone_nr_reclaimable_pages(struct scan_control *sc, struct zone *zone)
>> +{
>> +	return zone_reclaimable_pages(zone);
>> +}
>>   #endif
> 
> Can't be in a devided patch ?
> 
if you prefer this way, sure, I can separate it.

>>   static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
>> @@ -221,6 +252,9 @@ unsigned long shrink_slab(struct shrink_control *sc,
>>   		long batch_size = shrinker->batch ? shrinker->batch
>>   						  : SHRINK_BATCH;
>>   
>> +		if (!shrinker->memcg_shrinker && sc->target_mem_cgroup)
>> +			continue;
>> +
> 
> What does this mean ?

It means that if target_mem_cgroup is set, we should skip all the
shrinkers that are not memcg capable. Maybe if I invert the order it
will be clearer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
