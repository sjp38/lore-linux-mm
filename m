Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C40626B0009
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:25:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e14so13093407pfi.9
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:25:04 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40124.outbound.protection.outlook.com. [40.107.4.124])
        by mx.google.com with ESMTPS id g9si11457402pgo.214.2018.04.24.05.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 05:25:03 -0700 (PDT)
Subject: Re: [PATCH v2 04/12] mm: Assign memcg-aware shrinkers bitmap to memcg
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
 <152399121146.3456.5459546288565589098.stgit@localhost.localdomain>
 <20180422175900.dsjmm7gt2nsqj3er@esperanza>
 <14ebcccf-3ea8-59f4-d7ea-793aaba632c0@virtuozzo.com>
 <20180424112844.626madzs4cwoz5gh@esperanza>
 <7bf5372d-7d9d-abee-27dd-5044da5ec489@virtuozzo.com>
 <20180424121516.ihn6lewpidc34ayl@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <402281e6-6fea-3541-1435-a2f81e705e2b@virtuozzo.com>
Date: Tue, 24 Apr 2018 15:24:53 +0300
MIME-Version: 1.0
In-Reply-To: <20180424121516.ihn6lewpidc34ayl@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On 24.04.2018 15:15, Vladimir Davydov wrote:
> On Tue, Apr 24, 2018 at 02:38:51PM +0300, Kirill Tkhai wrote:
>> On 24.04.2018 14:28, Vladimir Davydov wrote:
>>> On Mon, Apr 23, 2018 at 01:54:50PM +0300, Kirill Tkhai wrote:
>>>>>> @@ -1200,6 +1206,8 @@ extern int memcg_nr_cache_ids;
>>>>>>  void memcg_get_cache_ids(void);
>>>>>>  void memcg_put_cache_ids(void);
>>>>>>  
>>>>>> +extern int shrinkers_max_nr;
>>>>>> +
>>>>>
>>>>> memcg_shrinker_id_max?
>>>>
>>>> memcg_shrinker_id_max sounds like an includive value, doesn't it?
>>>> While shrinker->id < shrinker_max_nr.
>>>>
>>>> Let's better use memcg_shrinker_nr_max.
>>>
>>> or memcg_nr_shrinker_ids (to match memcg_nr_cache_ids), not sure...
>>>
>>> Come to think of it, this variable is kinda awkward: it is defined in
>>> vmscan.c but declared in memcontrol.h; it is used by vmscan.c for max
>>> shrinker id and by memcontrol.c for shrinker map capacity. Just a raw
>>> idea: what about splitting it in two: one is private to vmscan.c, used
>>> as max id, say we call it shrinker_id_max; the other is defined in
>>> memcontrol.c and is used for shrinker map capacity, say we call it
>>> memcg_shrinker_map_capacity. What do you think?
>>
>> I don't much like a duplication of the single variable...
> 
> Well, it's not really a duplication. For example, shrinker_id_max could
> decrease when a shrinker is unregistered while shrinker_map_capacity can
> only grow exponentially.
> 
>> Are there real problems, if it defined in memcontrol.{c,h} and use in
>> both of the places?
> 
> The code is more difficult to follow when variables are shared like that
> IMHO. I suggest you try it and see how it looks. May be, it will only
> get worse and we'll have to revert to what we have now. Difficult to say
> without seeing the code.
> 
>>  
>>>>>> +int expand_shrinker_maps(int old_nr, int nr)
>>>>>> +{
>>>>>> +	int id, size, old_size, node, ret;
>>>>>> +	struct mem_cgroup *memcg;
>>>>>> +
>>>>>> +	old_size = old_nr / BITS_PER_BYTE;
>>>>>> +	size = nr / BITS_PER_BYTE;
>>>>>> +
>>>>>> +	down_write(&shrinkers_max_nr_rwsem);
>>>>>> +	for_each_node(node) {
>>>>>
>>>>> Iterating over cgroups first, numa nodes second seems like a better idea
>>>>> to me. I think you should fold for_each_node in memcg_expand_maps.
>>>>>
>>>>>> +		idr_for_each_entry(&mem_cgroup_idr, memcg, id) {
>>>>>
>>>>> Iterating over mem_cgroup_idr looks strange. Why don't you use
>>>>> for_each_mem_cgroup?
>>>>
>>>> We want to allocate shrinkers maps in mem_cgroup_css_alloc(), since
>>>> mem_cgroup_css_online() mustn't fail (it's a requirement of currently
>>>> existing design of memcg_cgroup::id).
>>>>
>>>> A new memcg is added to parent's list between two of these calls:
>>>>
>>>> css_create()
>>>>   ss->css_alloc()
>>>>   list_add_tail_rcu(&css->sibling, &parent_css->children)
>>>>   ss->css_online()
>>>>
>>>> for_each_mem_cgroup() does not see allocated, but not linked children.
>>>
>>> Why don't we move shrinker map allocation to css_online then?
>>
>> Because the design of memcg_cgroup::id prohibits mem_cgroup_css_online() to fail.
>> This function can't fail.
> 
> I fail to understand why it is so. Could you please elaborate?

mem_cgroup::id is freed not in mem_cgroup_css_free(), but earlier. It's freed
between mem_cgroup_css_offline() and mem_cgroup_free(), after the last reference
is put.

In case of sometimes we want to free it in mem_cgroup_css_free(), this will
introduce assymmetric in the logic, which makes it more difficult. There is
already a bug, which I fixed in

"memcg: remove memcg_cgroup::id from IDR on mem_cgroup_css_alloc() failure"

new change will make this code completely not-modular and unreadable.
 
>>
>> I don't think it will be good to dive into reworking of this stuff for this patchset,
>> which is really already big. Also, it will be assymmetric to allocate one part of
>> data in css_alloc(), while another data in css_free(). This breaks cgroup design,
>> which specially introduces this two function to differ allocation and onlining.
>> Also, I've just move the allocation to alloc_mem_cgroup_per_node_info() like it was
>> suggested in comments to v1...
> 
> Yeah, but (ab)using mem_cgroup_idr for iterating over all allocated
> memory cgroups looks rather dubious to me...

But we have to iterate over all allocated memory cgroups in any way,
as all of them must have expanded maps. What is the problem?
It's rather simple method, and it faster then for_each_mem_cgroup()
cycle, since it does not have to play with get and put of refcounters.

Kirill
