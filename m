Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 2D00C6B0102
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 16:13:10 -0400 (EDT)
Message-ID: <4F9AFD60.4050103@parallels.com>
Date: Fri, 27 Apr 2012 17:11:12 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/7 v2] memcg: use res_counter_uncharge_until in
 move_parent
References: <4F9A327A.6050409@jp.fujitsu.com> <4F9A34B2.8080103@jp.fujitsu.com> <4F9AD455.9030306@parallels.com> <CALWz4izAxDacXrHMbQh=q_WAcs6QeSuaRuma_dymuTvyk+VDSg@mail.gmail.com>
In-Reply-To: <CALWz4izAxDacXrHMbQh=q_WAcs6QeSuaRuma_dymuTvyk+VDSg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com


>>
>>> +/*
>>>     * A helper function to get mem_cgroup from ID. must be called under
>>>     * rcu_read_lock(). The caller must check css_is_removed() or some if
>>>     * it's concern. (dropping refcnt from swap can be called against removed
>>> @@ -2677,16 +2695,28 @@ static int mem_cgroup_move_parent(struct page *page,
>>>        nr_pages = hpage_nr_pages(page);
>>>
>>>        parent = mem_cgroup_from_cont(pcg);
>>> -     ret = __mem_cgroup_try_charge(NULL, gfp_mask, nr_pages,&parent, false);
>>> -     if (ret)
>>> -             goto put_back;
>>> +     if (!parent->use_hierarchy) {
>> Can we avoid testing for use hierarchy ?
>> Specially given this might go away.
>>
>> parent_mem_cgroup() already bundles this information. So maybe we can
>> test for parent_mem_cgroup(parent) == NULL. It is the same thing after all.
>>> +             ret = __mem_cgroup_try_charge(NULL,
>>> +                                     gfp_mask, nr_pages,&parent, false);
>>> +             if (ret)
>>> +                     goto put_back;
>>> +     }
>>
>> Why? If we are not hierarchical, we should not charge the parent, right?
>
> This is how it is implemented today and I think he changed that to
> move to root on the next patch.

Yeah, I was under the impression that that was the idea, but I might 
have missed one of the patches

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
