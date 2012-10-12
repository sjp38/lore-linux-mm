Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 6D8BB6B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 03:48:06 -0400 (EDT)
Message-ID: <5077CB29.2000505@parallels.com>
Date: Fri, 12 Oct 2012 11:47:53 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 10/14] memcg: use static branches when code not in
 use
References: <1349690780-15988-1-git-send-email-glommer@parallels.com> <1349690780-15988-11-git-send-email-glommer@parallels.com> <20121011134028.GH29295@dhcp22.suse.cz>
In-Reply-To: <20121011134028.GH29295@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, devel@openvz.org, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 10/11/2012 05:40 PM, Michal Hocko wrote:
> On Mon 08-10-12 14:06:16, Glauber Costa wrote:
>> We can use static branches to patch the code in or out when not used.
>>
>> Because the _ACTIVE bit on kmem_accounted is only set after the
>> increment is done, we guarantee that the root memcg will always be
>> selected for kmem charges until all call sites are patched (see
>> memcg_kmem_enabled).  This guarantees that no mischarges are applied.
>>
>> static branch decrement happens when the last reference count from the
>> kmem accounting in memcg dies. This will only happen when the charges
>> drop down to 0.
>>
>> When that happen, we need to disable the static branch only on those
>> memcgs that enabled it. To achieve this, we would be forced to
>> complicate the code by keeping track of which memcgs were the ones
>> that actually enabled limits, and which ones got it from its parents.
>>
>> It is a lot simpler just to do static_key_slow_inc() on every child
>> that is accounted.
>>
>> [ v4: adapted this patch to the changes in kmem_accounted ]
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Christoph Lameter <cl@linux.com>
>> CC: Pekka Enberg <penberg@cs.helsinki.fi>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Suleiman Souhlal <suleiman@google.com>
> 
> Looks reasonable to me
> Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> Just a little nit.
> 
> [...]
> 
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 634c7b5..724a08b 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -344,11 +344,15 @@ struct mem_cgroup {
>>  /* internal only representation about the status of kmem accounting. */
>>  enum {
>>  	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
>> +	KMEM_ACCOUNTED_ACTIVATED, /* static key enabled. */
>>  	KMEM_ACCOUNTED_DEAD, /* dead memcg, pending kmem charges */
>>  };
>>  
>> -/* first bit */
>> -#define KMEM_ACCOUNTED_MASK 0x1
>> +/*
>> + * first two bits. We account when limit is on, but only after
>> + * call sites are patched
>> + */
>> +#define KMEM_ACCOUNTED_MASK 0x3
> 
> The names are long but why not use KMEM_ACCOUNTED_ACTIVE*
> #define KMEM_ACCOUNTED_MASK 1<<KMEM_ACCOUNTED_ACTIVE | 1<<KMEM_ACCOUNTED_ACTIVATED
> 
Because the names are long! =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
