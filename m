Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 5CA0D6B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 02:01:04 -0400 (EDT)
Message-ID: <51610B78.7080001@huawei.com>
Date: Sun, 7 Apr 2013 14:00:24 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/7] memcg: make memcg's life cycle the same as cgroup
References: <515BF233.6070308@huawei.com> <20130404120049.GI29911@dhcp22.suse.cz>
In-Reply-To: <20130404120049.GI29911@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 2013/4/4 20:00, Michal Hocko wrote:
> On Wed 03-04-13 17:11:15, Li Zefan wrote:
>> (I'll be off from my office soon, and I won't be responsive in the following
>> 3 days.)
>>
>> I'm working on converting memcg to use cgroup->id, and then we can kill css_id.
>>
>> Now memcg has its own refcnt, so when a cgroup is destroyed, the memcg can
>> still be alive. This patchset converts memcg to always use css_get/put, so
>> memcg will have the same life cycle as its corresponding cgroup, and then
>> it's always safe for memcg to use cgroup->id.
>>
>> The historical reason that memcg didn't use css_get in some cases, is that
>> cgroup couldn't be removed if there're still css refs. The situation has
>> changed so that rmdir a cgroup will succeed regardless css refs, but won't
>> be freed until css refs goes down to 0.
>>
>> This is an early post, and it's NOT TESTED. I just want to see if the changes
>> are fine in general.
> 
> yes, I like the approach and it looks correct as well (some minor things
> mentioned in the patches). Thanks a lot Li! This will make our lifes much
> easier. The separate ref counting was PITA especially after
> introduction of kmem accounting which made its usage even more trickier.
> 
>> btw, after this patchset I think we don't need to free memcg via RCU, because
>> cgroup is already freed in RCU callback.
> 
> But this depends on changes waiting in for-3.10 branch, right?

What changes? memcg changes or cgroup core changes? I don't think this depends
on anything in cgroup 3.10 branch.

> Anyway, I think we should be safe with the workqueue based releasing as
> well once mem_cgroup_{get,put} are gone, right?
> 

cgroup calls mem_cgroup_css_free() in a work function, so seems memcg doesn't
need to use RCU or workqueue in mem_cgroup_css_free().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
