Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 591B46B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 10:45:22 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 13so1077180lba.2
        for <linux-mm@kvack.org>; Fri, 07 Jun 2013 07:45:20 -0700 (PDT)
Message-ID: <51B1F1FD.7000002@gmail.com>
Date: Fri, 07 Jun 2013 18:45:17 +0400
From: Glauber Costa <glommer@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: do not account memory used for cache creation
References: <1370355059-24968-1-git-send-email-glommer@openvz.org> <20130607092132.GE8117@dhcp22.suse.cz> <51B1B1E9.1020701@parallels.com> <20130607141204.GG8117@dhcp22.suse.cz>
In-Reply-To: <20130607141204.GG8117@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On 06/07/2013 06:12 PM, Michal Hocko wrote:
> On Fri 07-06-13 14:11:53, Glauber Costa wrote:
>> On 06/07/2013 01:21 PM, Michal Hocko wrote:
>>> On Tue 04-06-13 18:10:59, Glauber Costa wrote:
>>>> The memory we used to hold the memcg arrays is currently accounted to
>>>> the current memcg.
>>>
>>> Maybe I have missed a train but I thought that only some caches are
>>> tracked and those have to be enabled explicitly by using __GFP_KMEMCG in
>>> gfp flags.
>>
>> No, all caches are tracked. This was set a long time ago, and only a
>> very few initial versions differed from this. This barely changed over
>> the lifetime of the memcg patchset.
>>
>> You probably got confused, due to the fact that only some *allocations*
>
> OK, I was really imprecise. Of course any type of cache might be tracked
> should the allocation (which takes gfp) say so. What I have missed is
> that not only stack allocations say so but also kmalloc itself enforces
> that rather than the actual caller of kmalloc. This is definitely new
> to me. And it is quite confusing that the flag is set only for large
> allocations (kmalloc_order) or am I just missing other parts where
> __GFP_KMEMCG is set unconditionally?
>
> I really have to go and dive into the code.
>

Here is where you are getting your confusion: we don't track caches, we 
track *pages*.

Everytime you pass GFP_KMEMCG to a *page* allocation, it gets tracked.
Every memcg cache - IOW, a memcg copy of a slab cache, sets GFP_KMEMCG 
for all its allocations.

Now, the slub - and this is really an implementation detail - doesn't 
have caches for high order kmalloc caches. Instead, it gets pages 
directly from the page allocator. So we have to mark them explicitly. 
(they are a cache, they are just not implemented as such)

The slab doesn't do that, so all kmalloc caches are just normal caches.

Also note that kmalloc is a *kind* of cache, but not *the caches*. Here 
we are talking dentries, inodes, everything. We track *pages* allocated 
for all those caches.


>> are tracked, but in particular, all cache + stack ones are. All child
>> caches that are created set the __GFP_KMEMCG flag, because those pages
>> should all belong to a cgroup.
>>
>>>
>>> But d79923fa "sl[au]b: allocate objects from memcg cache" seems to be
>>> setting gfp unconditionally for large caches. The changelog doesn't
>>> explain why, though? This is really confusing.
>> For all caches.
>>
>> Again, not all *allocations* are market, but all cache allocations are.
>> All pages that belong to a memcg cache should obviously be accounted.
>
> What is memcg cache?
>

A memcg-local copy of a slab cache.

> Sorry about the offtopic question but why only large allocations are
> marked for tracking? The changelog doesn't mention that.
>

Don't worry about the question. As for the large allocations, I hope the 
answer I provided below addresses it. If you are still not getting it, 
let me know.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
