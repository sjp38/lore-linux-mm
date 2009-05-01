Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9D2AC6B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 19:05:41 -0400 (EDT)
Message-ID: <49FB8031.8000602@redhat.com>
Date: Fri, 01 May 2009 19:05:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: evict use-once pages first (v3)
References: <20090428044426.GA5035@eskimo.com>	<20090428192907.556f3a34@bree.surriel.com>	<1240987349.4512.18.camel@laptop>	<20090429114708.66114c03@cuia.bos.redhat.com>	<2f11576a0904290907g48e94e74ye97aae593f6ac519@mail.gmail.com>	<20090429131436.640f09ab@cuia.bos.redhat.com> <20090501153255.0f412420.akpm@linux-foundation.org>
In-Reply-To: <20090501153255.0f412420.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, peterz@infradead.org, elladan@eskimo.com, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 29 Apr 2009 13:14:36 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
>> When the file LRU lists are dominated by streaming IO pages,
>> evict those pages first, before considering evicting other
>> pages.
>>
>> This should be safe from deadlocks or performance problems
>> because only three things can happen to an inactive file page:
>> 1) referenced twice and promoted to the active list
>> 2) evicted by the pageout code
>> 3) under IO, after which it will get evicted or promoted
>>
>> The pages freed in this way can either be reused for streaming
>> IO, or allocated for something else. If the pages are used for
>> streaming IO, this pageout pattern continues. Otherwise, we will
>> fall back to the normal pageout pattern.
>>
>> ..
>>
>> +int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
>> +{
>> +	unsigned long active;
>> +	unsigned long inactive;
>> +
>> +	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
>> +	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
>> +
>> +	return (active > inactive);
>> +}
> 
> This function could trivially be made significantly more efficient by
> changing it to do a single pass over all the zones of all the nodes,
> rather than two passes.

How would I do that in a clean way?

The function mem_cgroup_inactive_anon_is_low and
the global versions all do the same.  It would be
nice to make all four of them go fast :)

If there is no standardized infrastructure for
getting multiple statistics yet, I can probably
whip something up.

>>  static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>>  	struct zone *zone, struct scan_control *sc, int priority)
>>  {
>>  	int file = is_file_lru(lru);
>>  
>> -	if (lru == LRU_ACTIVE_FILE) {
>> +	if (lru == LRU_ACTIVE_FILE && inactive_file_is_low(zone, sc)) {
>>  		shrink_active_list(nr_to_scan, zone, sc, priority, file);
>>  		return 0;
>>  	}
> 
> And it does get called rather often.

Same as inactive_anon_is_low.

Optimizing them might make sense if it turns out to
use a significant amount of CPU.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
