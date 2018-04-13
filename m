Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 783C66B0009
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:29:19 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id i39so7225351iod.12
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 04:29:19 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0116.outbound.protection.outlook.com. [104.47.1.116])
        by mx.google.com with ESMTPS id p69-v6si99572itc.61.2018.04.13.04.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 04:29:17 -0700 (PDT)
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
References: <152354470916.22460.14397070748001974638.stgit@localhost.localdomain>
 <20180413085553.GF17484@dhcp22.suse.cz>
 <ed75d18c-f516-2feb-53a8-6d2836e1da59@virtuozzo.com>
 <20180413110200.GG17484@dhcp22.suse.cz>
 <06931a83-91d2-3dcf-31cf-0b98d82e957f@virtuozzo.com>
 <20180413112036.GH17484@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <6dbc33bb-f3d5-1a46-b454-13c6f5865fcd@virtuozzo.com>
Date: Fri, 13 Apr 2018 14:29:11 +0300
MIME-Version: 1.0
In-Reply-To: <20180413112036.GH17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 13.04.2018 14:20, Michal Hocko wrote:
> On Fri 13-04-18 14:06:40, Kirill Tkhai wrote:
>> On 13.04.2018 14:02, Michal Hocko wrote:
>>> On Fri 13-04-18 12:35:22, Kirill Tkhai wrote:
>>>> On 13.04.2018 11:55, Michal Hocko wrote:
>>>>> On Thu 12-04-18 17:52:04, Kirill Tkhai wrote:
>>>>> [...]
>>>>>> @@ -4471,6 +4477,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>>>>>>  
>>>>>>  	return &memcg->css;
>>>>>>  fail:
>>>>>> +	mem_cgroup_id_remove(memcg);
>>>>>>  	mem_cgroup_free(memcg);
>>>>>>  	return ERR_PTR(-ENOMEM);
>>>>>>  }
>>>>>
>>>>> The only path which jumps to fail: here (in the current mmotm tree) is 
>>>>> 	error = memcg_online_kmem(memcg);
>>>>> 	if (error)
>>>>> 		goto fail;
>>>>>
>>>>> AFAICS and the only failure path in memcg_online_kmem
>>>>> 	memcg_id = memcg_alloc_cache_id();
>>>>> 	if (memcg_id < 0)
>>>>> 		return memcg_id;
>>>>>
>>>>> I am not entirely clear on memcg_alloc_cache_id but it seems we do clean
>>>>> up properly. Or am I missing something?
>>>>
>>>> memcg_alloc_cache_id() may allocate a lot of memory, in case of the system reached
>>>> memcg_nr_cache_ids cgroups. In this case it iterates over all LRU lists, and double
>>>> size of every of them. In case of memory pressure it can fail. If this occurs,
>>>> mem_cgroup::id is not unhashed from IDR and we leak this id.
>>>
>>> OK, my bad I was looking at the bad code path. So you want to clean up
>>> after mem_cgroup_alloc not memcg_online_kmem. Now it makes much more
>>> sense. Sorry for the confusion on my end.
>>>
>>> Anyway, shouldn't we do the thing in mem_cgroup_free() to be symmetric
>>> to mem_cgroup_alloc?
>>
>> We can't, since it's called from mem_cgroup_css_free(), which doesn't have a deal
>> with idr freeing. All the asymmetry, we see, is because of the trick to unhash ID
>> earlier, then from mem_cgroup_css_free().
> 
> Are you sure. It's been some time since I've looked at the quite complex
> cgroup tear down code but from what I remember, css_free is called on
> the css release (aka when the reference count drops to zero). mem_cgroup_id_put_many
> seems to unpin the css reference so we should have idr_remove by the
> time when css_free is called. Or am I still wrong and should go over the
> brain hurting cgroup removal code again?

mem_cgroup_id_put_many() unpins css, but this may be not the last reference to the css.
Thus, we release ID earlier, then all references to css are freed.

You may look at the commit 73f576c04b94, and it describes the reason we do that earlier:

Author: Johannes Weiner <hannes@cmpxchg.org>
Date:   Wed Jul 20 15:44:57 2016 -0700

    mm: memcontrol: fix cgroup creation failure after many small jobs
    
    The memory controller has quite a bit of state that usually outlives the
    cgroup and pins its CSS until said state disappears.  At the same time
    it imposes a 16-bit limit on the CSS ID space to economically store IDs
    in the wild.  Consequently, when we use cgroups to contain frequent but
    small and short-lived jobs that leave behind some page cache, we quickly
    run into the 64k limitations of outstanding CSSs.  Creating a new cgroup
    fails with -ENOSPC while there are only a few, or even no user-visible
    cgroups in existence.
    ...

Kirill
