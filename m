Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 317016B0145
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 17:44:05 -0400 (EDT)
Message-ID: <51803B4B.5080809@parallels.com>
Date: Wed, 1 May 2013 01:44:43 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 11/31] list_lru: per-node list infrastructure
References: <1367018367-11278-1-git-send-email-glommer@openvz.org> <1367018367-11278-12-git-send-email-glommer@openvz.org> <20130430163317.GK6415@suse.de>
In-Reply-To: <20130430163317.GK6415@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On 04/30/2013 08:33 PM, Mel Gorman wrote:
> On Sat, Apr 27, 2013 at 03:19:07AM +0400, Glauber Costa wrote:
>> From: Dave Chinner <dchinner@redhat.com>
>>
>> Now that we have an LRU list API, we can start to enhance the
>> implementation.  This splits the single LRU list into per-node lists
>> and locks to enhance scalability. Items are placed on lists
>> according to the node the memory belongs to. To make scanning the
>> lists efficient, also track whether the per-node lists have entries
>> in them in a active nodemask.
>>
>> [ glommer: fixed warnings ]
>> Signed-off-by: Dave Chinner <dchinner@redhat.com>
>> Signed-off-by: Glauber Costa <glommer@openvz.org>
>> Reviewed-by: Greg Thelen <gthelen@google.com>
>> ---
>>  include/linux/list_lru.h |  14 ++--
>>  lib/list_lru.c           | 162 +++++++++++++++++++++++++++++++++++------------
>>  2 files changed, 130 insertions(+), 46 deletions(-)
>>
>> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
>> index c0b796d..c422782 100644
>> --- a/include/linux/list_lru.h
>> +++ b/include/linux/list_lru.h
>> @@ -8,6 +8,7 @@
>>  #define _LRU_LIST_H
>>  
>>  #include <linux/list.h>
>> +#include <linux/nodemask.h>
>>  
>>  enum lru_status {
>>  	LRU_REMOVED,		/* item removed from list */
>> @@ -17,20 +18,21 @@ enum lru_status {
>>  				   internally, but has to return locked. */
>>  };
>>  
>> -struct list_lru {
>> +struct list_lru_node {
>>  	spinlock_t		lock;
>>  	struct list_head	list;
>>  	long			nr_items;
>> +} ____cacheline_aligned_in_smp;
>> +
>> +struct list_lru {
>> +	struct list_lru_node	node[MAX_NUMNODES];
>> +	nodemask_t		active_nodes;
>>  };
> 
> struct list_lru is going to be large. 64K just for the list_lru_nodes on a
> distribution configuration that has NODES_SHIFT==10. On most machines it'll
> be mostly unused space. How big is super_block now with two of these things?
> xfs_buftarg? They are rarely allocated structures but it would be a little
> embarassing if we failed to mount a usb stick because kmalloc() of some
> large buffer failed on a laptop.

If you take a look at the memcg patches, because they are dynamic by
nature, I am using nr_node_ids instead of MAX_NUMNODES. There is some
care to be taken, for instance, now we always have to filter a complete
nodemask against present nodes. But I do that for memcg, and could bring
the code earlier in the series.

The main disadvantage that I see for it, is that a lot of the LRUs are
statically defined. Since nr_node_ids is a runtime constant, we would
have to allocate them all and let them live outside the structure that
contains them. We can size the structure itself, but then we need to go
with the standard trickery of forcing it to be the last element, etc.
May not always work for such a generic construct.

So maybe it should wait to see if there is ever a problem? I tend to run
my VMs with 300Mb run, with even smaller memcgs, particularly to stress
low memory situation easily. I don't recall ever seeing a problem like
that, although of course we would always want to keep memory consumption
low if we can...

> 
> You may need to convert "list_lru_node node" to be an array of MAX_NUMNODES
> pointers to list_lru_nodes. It'd need a lookup helper for list_lru_add
> and list_lru_del that lazily allocates the list_lru_nodes on first usage
> in case of node hot-add. You could allocate the online nodes at
> list_lru_init.
> 
> It'd be awkward but avoid the need for a large kmalloc at runtime just
> because someone plugged in a USB stick.
> 
> Otherwise I didn't spot a major problem. There are now per-node lists to
> walk but the overall size of the LRU for walkers should be similar and
> the additional overhead in list_lru_count is hardly going to be
> noticable. I liked the use of active_mask.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
