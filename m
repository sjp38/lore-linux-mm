Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 10F186B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 04:43:55 -0400 (EDT)
Message-ID: <51B04BFC.5090506@parallels.com>
Date: Thu, 6 Jun 2013 12:44:44 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 27/35] lru: add an element to a memcg list
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <1370287804-3481-28-git-send-email-glommer@openvz.org> <20130605160832.93f3f62e42321d920b2adb31@linux-foundation.org>
In-Reply-To: <20130605160832.93f3f62e42321d920b2adb31@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>


>> ...
>>
>> @@ -53,12 +53,23 @@ struct list_lru {
>>  	 * structure, we may very well fail.
>>  	 */
>>  	struct list_lru_node	node[MAX_NUMNODES];
>> +	atomic_long_t		node_totals[MAX_NUMNODES];
>>  	nodemask_t		active_nodes;
>>  #ifdef CONFIG_MEMCG_KMEM
>>  	/* All memcg-aware LRUs will be chained in the lrus list */
>>  	struct list_head	lrus;
>>  	/* M x N matrix as described above */
>>  	struct list_lru_array	**memcg_lrus;
>> +	/*
>> +	 * The memcg_lrus is RCU protected
> 
> It is?  I don't recall seeing that in the earlier patches.  Is some
> description missing?
> 

Yes, it is.

memcg_update_lrus will do synchronize_rcu(), and lru_node_of_index will
do the read locking.

>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 3442eb9..50f199f 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -24,6 +24,7 @@
>>  #include <linux/hardirq.h>
>>  #include <linux/jump_label.h>
>>  #include <linux/list_lru.h>
>> +#include <linux/mm.h>
> 
> erk.  There's a good chance that mm.h already includes memcontrol.h, or
> vice versa, by some circuitous path.  Expect problems from this.
> 
> afaict the include is only needed for struct page?  If so, simply
> adding a forward declaration for that would be prudent.
> 
In fact, Rothwell had just already complained about this.
Funny, I have been running this with multiple configs for a while on 2
machines + kbot.

> 
>> +	 * impossible situation: it would mean we are trying to add to a list
>> +	 * belonging to a memcg that does not exist. Either wasn't created or
> 
> "it wasn't created or it"
> 
>> +	 * has been already freed. In both cases it should no longer have
>> +	 * objects. BUG_ON to avoid a NULL dereference.
> 
> Well.  We could jsut permit the NULL reference - that provides the same
> info.  But an explicit BUG_ON does show that it has been thought through!
> 
Actually this is one of the bugs I have to fix. *right now* this code is
correct, but later on is not. When we are unmounting for instance, we
loop through all indexes. I have updated this in the patch that does the
loop, but to avoid generating more mental effort than it is due, I can
just move it right here.

>> +	 */
>> +	BUG_ON(!lru->memcg_lrus[index]);
>> +	nlru = &lru->memcg_lrus[index]->node[nid];
>> +	rcu_read_unlock();
>> +	return nlru;
>> +#else
>> +	BUG_ON(index >= 0); /* nobody should be passing index < 0 with !KMEM */
>> +	return &lru->node[nid];
>> +#endif
>> +}
>> +
>>
>> ...
>>
>>  int
>>  list_lru_add(
>>  	struct list_lru	*lru,
>>  	struct list_head *item)
>>  {
>> -	int nid = page_to_nid(virt_to_page(item));
>> -	struct list_lru_node *nlru = &lru->node[nid];
>> +	struct page *page = virt_to_page(item);
>> +	struct list_lru_node *nlru;
>> +	int nid = page_to_nid(page);
>> +
>> +	nlru = memcg_kmem_lru_of_page(lru, page);
>>  
>>  	spin_lock(&nlru->lock);
>>  	BUG_ON(nlru->nr_items < 0);
>>  	if (list_empty(item)) {
>>  		list_add_tail(item, &nlru->list);
>> -		if (nlru->nr_items++ == 0)
>> +		nlru->nr_items++;
>> +		/*
>> +		 * We only consider a node active or inactive based on the
>> +		 * total figure for all involved children.
> 
> Is "children" an appropriate term in this context?  Where would one go
> to understand the overall object hierarchy here?
> 
children is always an appropriate term. Every time one mentions it
people go sentimental and are more likely to be helpful.

But that aside, I believe this could be changed to something else.

>> +		 */
>> +		if (atomic_long_add_return(1, &lru->node_totals[nid]) == 1)
>>  			node_set(nid, lru->active_nodes);
>>  		spin_unlock(&nlru->lock);
>>  		return 1;
>>
>> ...
>>
>> +	/*
>> +	 * Even if we were to use call_rcu, we still have to keep the old array
>> +	 * pointer somewhere. It is easier for us to just synchronize rcu here
>> +	 * since we are in a fine context. Now we guarantee that there are no
>> +	 * more users of old_array, and proceed freeing it for all LRUs
> 
> "a fine context" is a fine term, but it's unclear what is meant by it ;)
> 
fine!

I mean a synchronize_rcu friendly context (can sleep, etc)


>> +	 */
>> +	synchronize_rcu();
>> +	list_for_each_entry(lru, &all_memcg_lrus, lrus) {
>> +		kfree(lru->old_array);
>> +		lru->old_array = NULL;
>> +	}
>>  	mutex_unlock(&all_memcg_lrus_mutex);
>>  	return ret;
>>  }
>>

Here is the answer to your "is this really RCU protected?? " btw.

>> ...
>>
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3162,19 +3162,22 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
>>  	 */
>>  	memcg_kmem_set_activated(memcg);
>>  
>> -	ret = memcg_update_all_caches(num+1);
>> -	if (ret)
>> -		goto out;
>> -
>>  	/*
>> -	 * We should make sure that the array size is not updated until we are
>> -	 * done; otherwise we have no easy way to know whether or not we should
>> -	 * grow the array.
>> +	 * We have to make absolutely sure that we update the LRUs before we
>> +	 * update the caches. Once the caches are updated, they will be able to
>> +	 * start hosting objects. If a cache is created very quickly, and and
> 
> s/and/an/
> 
>> +	 * element is used and disposed to the LRU quickly as well, we may end
>> +	 * up with a NULL pointer in list_lru_add because the lists are not yet
>> +	 * ready.
>>  	 */
>>  	ret = memcg_update_all_lrus(num + 1);
>>  	if (ret)
>>  		goto out;
>>  
>> +	ret = memcg_update_all_caches(num+1);
>> +	if (ret)
>> +		goto out;
>> +
>>  	memcg->kmemcg_id = num;
>>  
>>  	memcg_update_array_size(num + 1);
>>
>> ...
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
