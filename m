Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 413D16B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 11:19:30 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id ne4so11374341lbc.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 08:19:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ri9si57609996wjb.209.2016.06.01.08.19.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 08:19:29 -0700 (PDT)
Subject: Re: [PATCH v2 18/18] mm, vmscan: use proper classzone_idx in
 should_continue_reclaim()
References: <20160531130818.28724-1-vbabka@suse.cz>
 <20160531130818.28724-19-vbabka@suse.cz>
 <20160601142138.GX26601@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <574EFCFE.1000903@suse.cz>
Date: Wed, 1 Jun 2016 17:19:26 +0200
MIME-Version: 1.0
In-Reply-To: <20160601142138.GX26601@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 06/01/2016 04:21 PM, Michal Hocko wrote:
> On Tue 31-05-16 15:08:18, Vlastimil Babka wrote:
> [...]
>> @@ -2364,11 +2350,12 @@ static inline bool should_continue_reclaim(struct zone *zone,
>>  }
>>  
>>  static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>> -			bool is_classzone)
>> +			int classzone_idx)
>>  {
>>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>>  	unsigned long nr_reclaimed, nr_scanned;
>>  	bool reclaimable = false;
>> +	bool is_classzone = (classzone_idx == zone_idx(zone));
>>  
>>  	do {
>>  		struct mem_cgroup *root = sc->target_mem_cgroup;
>> @@ -2450,7 +2437,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>>  			reclaimable = true;
>>  
>>  	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
>> -					 sc->nr_scanned - nr_scanned, sc));
>> +			 sc->nr_scanned - nr_scanned, sc, classzone_idx));
>>  
>>  	return reclaimable;
>>  }
>> @@ -2580,7 +2567,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>>  			/* need some check for avoid more shrink_zone() */
>>  		}
>>  
>> -		shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
>> +		shrink_zone(zone, sc, classzone_idx);
> 
> this should be is_classzone, right?

No, this is shrink_zones() context, not shrink_zone().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
