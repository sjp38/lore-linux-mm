Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id CF86F6B006C
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 05:37:20 -0500 (EST)
Message-ID: <50AF51D1.6040702@parallels.com>
Date: Fri, 23 Nov 2012 14:37:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: debugging facility to access dangling memcgs.
References: <1353580190-14721-1-git-send-email-glommer@parallels.com> <1353580190-14721-3-git-send-email-glommer@parallels.com> <20121123092010.GD24698@dhcp22.suse.cz> <50AF42F0.6040407@parallels.com> <20121123103307.GH24698@dhcp22.suse.cz>
In-Reply-To: <20121123103307.GH24698@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On 11/23/2012 02:33 PM, Michal Hocko wrote:
> On Fri 23-11-12 13:33:36, Glauber Costa wrote:
>> On 11/23/2012 01:20 PM, Michal Hocko wrote:
>>> On Thu 22-11-12 14:29:50, Glauber Costa wrote:
>>> [...]
>>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>>> index 05b87aa..46f7cfb 100644
>>>> --- a/mm/memcontrol.c
>>>> +++ b/mm/memcontrol.c
>>> [...]
>>>> @@ -349,6 +366,33 @@ struct mem_cgroup {
>>>>  #endif
>>>>  };
>>>>  
>>>> +#if defined(CONFIG_MEMCG_KMEM) || defined(CONFIG_MEMCG_SWAP)
>>>
>>> Can we have a common config for this something like CONFIG_MEMCG_ASYNC_DESTROY
>>> which would be selected if either of the two (or potentially others)
>>> would be selected.
>>> Also you are saying that the feature is only for debugging purposes so
>>> it shouldn't be on by default probably.
>>>
>>
>> I personally wouldn't mind. But the big value I see from it is basically
>> being able to turn it off. For all the rest, we would have to wrap it
>> under one of those config options anyway...
> 
> Sure you would need to habe mem_cgroup_dangling_FOO wrapped by the
> correct one anyway but that still need to live inside a bigger ifdef and
> naming all the FOO is awkward. Besides that one
> CONFIG_MEMCG_ASYNC_DESTROY_DEBUG could have a Kconfig entry and so be
> enabled separately.
> 

How about a more general memcg debug option like CONFIG_MEMCG_DEBUG?
Do you foresee more facilities we could enable under this?



> Ohh, you are right you are using kmem_cache name for those. Sorry for
> the confusion
>  
>>> And finally it would be really nice if you described what is the
>>> exported information good for. Can I somehow change the current state
>>> (e.g. force freeing those objects so that the memcg can finally pass out
>>> in piece)?
>>>
>> I am open, but I would personally like to have this as a view-only
>> interface,
> 
> And I was not proposing to make it RW. I am just missing a description
> that would explain: "Ohh well, the file says there are some dangling
> memcgs. Should I report a bug or sue somebody or just have a coffee and
> wait some more?"
> 

People should pay me beer if the number of pending caches is odd, and
pay you beer if the number is even. If the number is 0, we both get it.

>> just so we suspect a leak occurs, we can easily see what is
>> the dead memcg contribution to it. It shows you where the data come
>> from, and if you want to free it, you go search for subsystem-specific
>> ways to force a free should you want.
> 
> Yes, I can imagine its usefulness for developers but I do not see much
> of an use for admins yet. So I am a bit hesitant for this being on by
> default.
> 
Fully agreed. I am implementing this because Kame suggested. I promptly
agreed because I remembered how many times I asked myself "Who is
holding this?" and had to go put some printks all over...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
