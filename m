Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 7B3106B0008
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 05:46:04 -0500 (EST)
Message-ID: <511E11FD.9050102@parallels.com>
Date: Fri, 15 Feb 2013 14:46:21 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] vmscan: also shrink slab in memcg pressure
References: <1360328857-28070-1-git-send-email-glommer@parallels.com> <1360328857-28070-2-git-send-email-glommer@parallels.com> <xr93mwv6nz7p.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93mwv6nz7p.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

>>  
>> @@ -384,6 +387,11 @@ static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
>>  				struct page *newpage)
>>  {
>>  }
>> +
>> +static inline unsigned long
>> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
>> +{
> 
> 	return 0;
> 
ok

>> +bool memcg_kmem_is_active(struct mem_cgroup *memcg)
>>  {
>>  	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>>  }
>> @@ -991,6 +991,15 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
>>  	return ret;
>>  }
>>  
>> +unsigned long
>> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
>> +{
>> +	int nid = zone_to_nid(zone);
>> +	int zid = zone_idx(zone);
>> +
>> +	return mem_cgroup_zone_nr_lru_pages(memcg, nid, zid, LRU_ALL);
> 
> Without swap enabled it seems like LRU_ALL_FILE is more appropriate.
> Maybe something like test_mem_cgroup_node_reclaimable().
> 

You are right, I will look into it.

>> +}
>> +
>>  static unsigned long
>>  mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
>>  			int nid, unsigned int lru_mask)
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 6d96280..8af0e2b 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -138,11 +138,42 @@ static bool global_reclaim(struct scan_control *sc)
>>  {
>>  	return !sc->target_mem_cgroup;
>>  }
>> +
>> +/*
>> + * kmem reclaim should usually not be triggered when we are doing targetted
>> + * reclaim. It is only valid when global reclaim is triggered, or when the
>> + * underlying memcg has kmem objects.
>> + */
>> +static bool has_kmem_reclaim(struct scan_control *sc)
>> +{
>> +	return !sc->target_mem_cgroup ||
>> +	(sc->target_mem_cgroup && memcg_kmem_is_active(sc->target_mem_cgroup));
> 
> Isn't this the same as:
> 	return !sc->target_mem_cgroup ||
> 		memcg_kmem_is_active(sc->target_mem_cgroup);
> 

Yes, it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
