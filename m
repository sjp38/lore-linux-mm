Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id C7F8E6B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 04:28:25 -0400 (EDT)
Message-ID: <5159454F.10105@parallels.com>
Date: Mon, 1 Apr 2013 12:29:03 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 23/28] lru: add an element to a memcg list
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-24-git-send-email-glommer@parallels.com> <515942D8.1070301@jp.fujitsu.com>
In-Reply-To: <515942D8.1070301@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On 04/01/2013 12:18 PM, Kamezawa Hiroyuki wrote:
> (2013/03/29 18:14), Glauber Costa wrote:
>> With the infrastructure we now have, we can add an element to a memcg
>> LRU list instead of the global list. The memcg lists are still
>> per-node.
>>
>> Technically, we will never trigger per-node shrinking in the memcg is
>> short of memory. Therefore an alternative to this would be to add the
>> element to *both* a single-node memcg array and a per-node global array.
>>
> 
> per-node shrinking by memcg pressure is not imporant, I think.
> 
No, it is not. And this is precisely what I've stated: "we will never
trigger per-node shrinking in the memcg is short of memory."

This is to clarify that this design decision does not come from the need
to do that, which we don't have, but rather to save memory. Keeping
memcg objects per-node is less memory-expensive than adding an extra LRU
to the dentries and inodes. Therefore I do that, and when global
pressure kicks in I will scan all memcgs that belong to that node.

This will break global LRU order, but will help maintain fairness among
different memcgs.

>>   
>>   struct list_lru {
>>   	struct list_lru_node	node[MAX_NUMNODES];
>> +	atomic_long_t		node_totals[MAX_NUMNODES];
> 
> some comments will be helpful. 
> 
Yes, they will!

>> +
>> +static inline struct list_lru_node *
>> +lru_node_of_index(struct list_lru *lru, int index, int nid)
>> +{
>> +	BUG_ON(index < 0); /* index != -1 with !MEMCG_KMEM. Impossible */
>> +	return &lru->node[nid];
>> +}
>>   #endif
> 
> I'm sorry ...what "lru_node_of_index" means ? What is the "index" ?

There is extensive documentation for this above the macro
for_each_memcg_lru_index, so I didn't bother rewriting it here. But I
can add pointers like "see more at for_each..."

Basically, this will be either the memcg index if we want memcg reclaim,
or -1 for the global LRU. This is not 100 % the memcg index, so I called
it just "index".

IOW, it is the index in the memcg array if index >= 0, or the global
array if index < 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
