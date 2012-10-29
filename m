Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 9F8FD6B006E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:09:44 -0400 (EDT)
Message-ID: <508E9C28.1000308@parallels.com>
Date: Mon, 29 Oct 2012 19:09:28 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 3/6] memcg: Simplify mem_cgroup_force_empty_list error
 handling
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz> <1351251453-6140-4-git-send-email-mhocko@suse.cz> <508E8B95.406@parallels.com> <20121029141534.GB20757@dhcp22.suse.cz>
In-Reply-To: <20121029141534.GB20757@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

>>> + * move charges to its parent or the root cgroup if the group has no
>>> + * parent (aka use_hierarchy==0).
>>> + * Although this might fail (get_page_unless_zero, isolate_lru_page or
>>> + * mem_cgroup_move_account fails) the failure is always temporary and
>>> + * it signals a race with a page removal/uncharge or migration. In the
>>> + * first case the page is on the way out and it will vanish from the LRU
>>> + * on the next attempt and the call should be retried later.
>>> + * Isolation from the LRU fails only if page has been isolated from
>>> + * the LRU since we looked at it and that usually means either global
>>> + * reclaim or migration going on. The page will either get back to the
>>> + * LRU or vanish.
>>
>> I just wonder for how long can it go in the worst case?
>  
> That's a good question and to be honest I have no idea. The point is
> that it will terminate eventually and that the group is on the way out
> so the time to complete the removal is not a big deal IMHO. We had
> basically similar situation previously when we would need to repeat
> rmdir loop on EBUSY. The only change is that we do not have to retry
> anymore.
> 
> So the key point is to check whether my assumption about temporarily is
> correct and that we cannot block the rest of the kernel/userspace to
> proceed even though we are waiting for finalization. I believe this is
> true but... (last famous words?)
> 
At least for me, it seems that this will hold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
