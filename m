Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id CCF5B6B002B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 02:55:46 -0500 (EST)
Message-ID: <50DAAD5D.9020505@parallels.com>
Date: Wed, 26 Dec 2012 11:55:09 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] sl[auo]b: retry allocation once in case of failure.
References: <1355925702-7537-1-git-send-email-glommer@parallels.com> <1355925702-7537-4-git-send-email-glommer@parallels.com> <50DA5DE3.9060809@jp.fujitsu.com>
In-Reply-To: <50DA5DE3.9060809@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

Hello Kame,
>> diff --git a/mm/slab.c b/mm/slab.c
>> index a98295f..7e82f99 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -3535,6 +3535,8 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
>>   	cache_alloc_debugcheck_before(cachep, flags);
>>   	local_irq_save(save_flags);
>>   	objp = __do_slab_alloc_node(cachep, flags, nodeid);
>> +	if (slab_should_retry(objp, flags))
>> +		objp = __do_slab_alloc_node(cachep, flags, nodeid);
> 
> 3 questions. 
> 
> 1. why can't we do retry in memcg's code (or kmem/memcg code) rather than slab.c ?
Due to two main reasons:
 a. this is not memcg/kmemcg specific. I used kmemcg to make the
container very small, therefore, more likely. But it can also happen in
non-constrained systems.

 b. memcg hooks into the page allocation. This patchset deals with cases
in which we can't, really, allocate a new page. However, we are
confident that we could allocate a new *object* should we retry.

> 2. It should be retries even if memory allocator returns NULL page ?

Yes, this is the whole point of this exercise. When we return a NULL
page, we are almost certain to have called reclaim. Reclaim will call
shrink_slab(), that may free objects within a page. So if we retry, we
may now find space within the page, even if we can't have a full page.

> 3. What's relationship with oom-killer ? The first __do_slab_alloc() will not
>    invoke oom-killer and returns NULL ?
> 
Good question. In all my testing, I've never seen the oom killer be
invoked for failed slab allocations, for either slab or slub. What I
usually see is just the allocator giving up and flooding the log with
failure messages. It seemed logical to me, so I never really asked
myself why wasn't the oom killer invoked. (It usually is invoked right
after if I fire a user memory hog). Perhaps someone can shed a light on
the subject?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
