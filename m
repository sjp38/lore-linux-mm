Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id BD3096B000E
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 05:56:50 -0500 (EST)
Message-ID: <511E1485.5080109@parallels.com>
Date: Fri, 15 Feb 2013 14:57:09 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] lru: add an element to a memcg list
References: <1360328857-28070-1-git-send-email-glommer@parallels.com> <1360328857-28070-4-git-send-email-glommer@parallels.com> <xr93txpemkeo.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93txpemkeo.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On 02/15/2013 05:32 AM, Greg Thelen wrote:
> On Fri, Feb 08 2013, Glauber Costa wrote:
> 
>> With the infrastructure we now have, we can add an element to a memcg
>> LRU list instead of the global list. The memcg lists are still
>> per-node.
> 
> [...]
> 
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index b9e1941..bfb4b5b 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3319,6 +3319,36 @@ static inline void memcg_resume_kmem_account(void)
>>  	current->memcg_kmem_skip_account--;
>>  }
>>  
>> +static struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page)
>> +{
>> +	struct page_cgroup *pc;
>> +	struct mem_cgroup *memcg = NULL;
>> +
>> +	pc = lookup_page_cgroup(page);
>> +	if (!PageCgroupUsed(pc))
>> +		return NULL;
>> +
>> +	lock_page_cgroup(pc);
>> +	if (PageCgroupUsed(pc))
>> +		memcg = pc->mem_cgroup;
>> +	unlock_page_cgroup(pc);
> 
> Once we drop the lock, is there anything that needs protection
> (e.g. PageCgroupUsed)?  If there's no problem, then what's the point of
> taking the lock?
> 

This is the same pattern already used in the rest of memcg, and I just
transposing it here. From my understanding, we need to make sure that if
the Used bit is not set, we don't rely on the memcg information. So we
take the lock to guarantee that the big is not cleared in the meantime.
But after that, we should be fine.

Kame, you have any input?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
