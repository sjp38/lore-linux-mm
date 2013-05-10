Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 10FBD6B0034
	for <linux-mm@kvack.org>; Fri, 10 May 2013 05:55:43 -0400 (EDT)
Message-ID: <518CC44D.1020409@parallels.com>
Date: Fri, 10 May 2013 13:56:29 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 08/31] list: add a new LRU list type
References: <1368079608-5611-1-git-send-email-glommer@openvz.org> <1368079608-5611-9-git-send-email-glommer@openvz.org> <20130509133742.GW11497@suse.de> <518C0ECF.8010302@parallels.com> <20130510092105.GK11497@suse.de>
In-Reply-To: <20130510092105.GK11497@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On 05/10/2013 01:21 PM, Mel Gorman wrote:
> On Fri, May 10, 2013 at 01:02:07AM +0400, Glauber Costa wrote:
>> On 05/09/2013 05:37 PM, Mel Gorman wrote:
>>> On Thu, May 09, 2013 at 10:06:25AM +0400, Glauber Costa wrote:
>>>> From: Dave Chinner <dchinner@redhat.com>
>>>>
>>>> Several subsystems use the same construct for LRU lists - a list
>>>> head, a spin lock and and item count. They also use exactly the same
>>>> code for adding and removing items from the LRU. Create a generic
>>>> type for these LRU lists.
>>>>
>>>> This is the beginning of generic, node aware LRUs for shrinkers to
>>>> work with.
>>>>
>>>> [ glommer: enum defined constants for lru. Suggested by gthelen,
>>>>   don't relock over retry ]
>>>> Signed-off-by: Dave Chinner <dchinner@redhat.com>
>>>> Signed-off-by: Glauber Costa <glommer@openvz.org>
>>>> Reviewed-by: Greg Thelen <gthelen@google.com>
>>>>>
>>>>> <SNIP>
>>>>>
>>>> +
>>>> +unsigned long
>>>> +list_lru_walk(
>>>> +	struct list_lru *lru,
>>>> +	list_lru_walk_cb isolate,
>>>> +	void		*cb_arg,
>>>> +	long		nr_to_walk)
>>>> +{
>>>> +	struct list_head *item, *n;
>>>> +	unsigned long removed = 0;
>>>> +
>>>> +	spin_lock(&lru->lock);
>>>> +restart:
>>>> +	list_for_each_safe(item, n, &lru->list) {
>>>> +		enum lru_status ret;
>>>> +
>>>> +		if (nr_to_walk-- < 0)
>>>> +			break;
>>>> +
>>>> +		ret = isolate(item, &lru->lock, cb_arg);
>>>> +		switch (ret) {
>>>> +		case LRU_REMOVED:
>>>> +			lru->nr_items--;
>>>> +			removed++;
>>>> +			break;
>>>> +		case LRU_ROTATE:
>>>> +			list_move_tail(item, &lru->list);
>>>> +			break;
>>>> +		case LRU_SKIP:
>>>> +			break;
>>>> +		case LRU_RETRY:
>>>> +			goto restart;
>>>> +		default:
>>>> +			BUG();
>>>> +		}
>>>> +	}
>>>
>>> What happened your suggestion to only retry once for each object to
>>> avoid any possibility of infinite looping or stalling for prolonged
>>> periods of time waiting on XFS to do something?
>>>
>>
>> Sorry. It wasn't clear for me if you were just trying to make sure we
>> had a way out in case it proves to be a problem, or actually wanted a
>> change.
>>
> 
> Either. If you are sure there is a way out for XFS using LRU_RETRY without
> prolonged stalls then it's fine. If it is not certain then I would be much
> more comfortable with a retry-once and then moving onto the next LRU node.
> 
>> In any case, I cannot claim to be as knowledgeable as Dave in the
>> subtleties of such things in the final behavior of the shrinker. Dave,
>> can you give us your input here?
>>
>> I also have another recent observation on this:
>>
>> The main difference between LRU_SKIP and LRU_RETRY is that LRU_RETRY
>> will go back to the beginning of the list, and start scanning it again.
>>
> 
> Only sortof true. Lets say we had a list of 8 LRU nodes. Nodes 1-3 get
> isolated. Node 4 returns LRU_RETRY so we goto restart. The first item on
> the list is now potentially LRU_RETRY which it must handle before
> reaching Nodes 5-8
> 
> LRU_SKIP is different. If Node 4 returned LRU_SKIP then Node 5-8 are
> ignored entirely. Actually..... why is that? LRU_SKIP is documented to
> "item cannot be locked, skip" but what it actually does it "item cannot
> be locked, abort the walk". It's documented behaviour LRU_SKIP implies
> continue, not break.
> 
> 	case LRU_SKIP:
> 		continue;
> 

but we are only breaking the switch statement, so this is a de facto
continue.

>> This is *not* the same behavior we had before, where we used to read:
>>
>>         for (nr_scanned = nr_to_scan; nr_scanned >= 0; nr_scanned--) {
>>                 struct inode *inode;
>>                 [ ... ]
>>
>>                 if (inode_has_buffers(inode) || inode->i_data.nrpages) {
>>                         __iget(inode);
>>                         [ ... ]
>>                         iput(inode);
>>                         spin_lock(&sb->s_inode_lru_lock);
>>
>>                         if (inode != list_entry(sb->s_inode_lru.next,
>>                                                 struct inode, i_lru))
>>                                 continue; <=====
>>                         /* avoid lock inversions with trylock */
>>                         if (!spin_trylock(&inode->i_lock))
>>                                 continue; <=====
>>                         if (!can_unuse(inode)) {
>>                                 spin_unlock(&inode->i_lock);
>>                                 continue; <=====
>>                         }
>>                 }
>>
>> It is my interpretation that we in here, we won't really reset the
>> search, but just skip this inode.
>>
>> Another problem is that by restarting the search the way we are doing
>> now, we actually decrement nr_to_walk twice in case of a retry. By doing
>> a retry-once test, we can actually move nr_to_walk to the end of the
>> switch statement, which has the good side effect of getting rid of the
>> reason we had to allow it to go negative.
>>
>> How about we fold the following attached patch to this one? (I would
>> still have to give it a round of testing)
>>
> 
>> diff --git a/lib/list_lru.c b/lib/list_lru.c
>> index da9b837..4aa069b 100644
>> --- a/lib/list_lru.c
>> +++ b/lib/list_lru.c
>> @@ -195,12 +195,10 @@ list_lru_walk_node(
>>  	unsigned long isolated = 0;
>>  
>>  	spin_lock(&nlru->lock);
>> -restart:
>>  	list_for_each_safe(item, n, &nlru->list) {
>> +		bool first_pass = true;
>>  		enum lru_status ret;
>> -
>> -		if ((*nr_to_walk)-- < 0)
>> -			break;
>> +restart:
>>  
>>  		ret = isolate(item, &nlru->lock, cb_arg);
>>  		switch (ret) {
>> @@ -217,10 +215,17 @@ restart:
>>  		case LRU_SKIP:
>>  			break;
>>  		case LRU_RETRY:
>> +			if (!first_pass)
>> +				break;
>> +			first_pass = true;
>>  			goto restart;
> 
> I think this is generally much safer and less likely to report bugs
> about occasional long stalls during slab shrink.
>

Ok, I plan to fold it to the patch unless Dave opposes.
Right now I am rebasing the whole series on top of -next, and my next
post will already included this change.

> Similar to LRU_SKIP comment above, should this be continue though to
> actually skip the LRU node instead of aborting the LRU walk?
> 
We do. This is a break to the switch statement only, so we will go on
with the list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
