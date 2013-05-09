Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 49E8D6B0034
	for <linux-mm@kvack.org>; Thu,  9 May 2013 07:27:27 -0400 (EDT)
Message-ID: <518B884C.9090704@parallels.com>
Date: Thu, 9 May 2013 15:28:12 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 02/31] vmscan: take at least one pass with shrinkers
References: <1368079608-5611-1-git-send-email-glommer@openvz.org> <1368079608-5611-3-git-send-email-glommer@openvz.org> <20130509111226.GR11497@suse.de>
In-Reply-To: <20130509111226.GR11497@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On 05/09/2013 03:12 PM, Mel Gorman wrote:
> On Thu, May 09, 2013 at 10:06:19AM +0400, Glauber Costa wrote:
>> In very low free kernel memory situations, it may be the case that we
>> have less objects to free than our initial batch size. If this is the
>> case, it is better to shrink those, and open space for the new workload
>> then to keep them and fail the new allocations. For the purpose of
>> defining what "very low memory" means, we will purposefuly exclude
>> kswapd runs.
>>
>> More specifically, this happens because we encode this in a loop with
>> the condition: "while (total_scan >= batch_size)". So if we are in such
>> a case, we'll not even enter the loop.
>>
>> This patch modifies turns it into a do () while {} loop, that will
>> guarantee that we scan it at least once, while keeping the behaviour
>> exactly the same for the cases in which total_scan > batch_size.
>>
>> [ v5: differentiate no-scan case, don't do this for kswapd ]
>>
>> Signed-off-by: Glauber Costa <glommer@openvz.org>
>> Reviewed-by: Dave Chinner <david@fromorbit.com>
>> Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
>> CC: "Theodore Ts'o" <tytso@mit.edu>
>> CC: Al Viro <viro@zeniv.linux.org.uk>
>> ---
>>  mm/vmscan.c | 24 +++++++++++++++++++++---
>>  1 file changed, 21 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index fa6a853..49691da 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -281,12 +281,30 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>>  					nr_pages_scanned, lru_pages,
>>  					max_pass, delta, total_scan);
>>  
>> -		while (total_scan >= batch_size) {
>> +		do {
>>  			int nr_before;
>>  
>> +			/*
>> +			 * When we are kswapd, there is no need for us to go
>> +			 * desperate and try to reclaim any number of objects
>> +			 * regardless of batch size. Direct reclaim, OTOH, may
>> +			 * benefit from freeing objects in any quantities. If
>> +			 * the workload is actually stressing those objects,
>> +			 * this may be the difference between succeeding or
>> +			 * failing an allocation.
>> +			 */
>> +			if ((total_scan < batch_size) && current_is_kswapd())
>> +				break;
>> +			/*
>> +			 * Differentiate between "few objects" and "no objects"
>> +			 * as returned by the count step.
>> +			 */
>> +			if (!total_scan)
>> +				break;
>> +
> 
> To reduce the risk of slab reclaiming the world in the reasonable cases
> I outlined after the leader mail, I would go further than this and either
> limit it to memcg after shrinkers are memcg aware or only do the full scan
> if direct reclaim and priority == 0.
> 
> What do you think?
> 
I of course understand your worries, but I myself believe makes things
less memcg specific is a long term win. There is a reason for memcg
needing this, and it might be helpful in other situations as well (maybe
very low memory in small systems, or a small zone, etc). All that, if
possible of course. As a last resort, I am obviously fine with
making it memcg specific if needed.

>From the options you outlined above, I personally would prefer to add
the priority check test (since the direct reclaim part is implicit by
the current_is_kswapd test)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
