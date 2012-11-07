Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 912186B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 02:05:23 -0500 (EST)
Message-ID: <509A0826.1030708@parallels.com>
Date: Wed, 7 Nov 2012 08:05:10 +0100
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 18/29] Allocate memory for memcg caches whenever a
 new memcg appears
References: <1351771665-11076-1-git-send-email-glommer@parallels.com> <1351771665-11076-19-git-send-email-glommer@parallels.com> <20121105162330.4aa629f8.akpm@linux-foundation.org>
In-Reply-To: <20121105162330.4aa629f8.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 11/06/2012 01:23 AM, Andrew Morton wrote:
> On Thu,  1 Nov 2012 16:07:34 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>> Every cache that is considered a root cache (basically the "original" caches,
>> tied to the root memcg/no-memcg) will have an array that should be large enough
>> to store a cache pointer per each memcg in the system.
>>
>> Theoreticaly, this is as high as 1 << sizeof(css_id), which is currently in the
>> 64k pointers range. Most of the time, we won't be using that much.
>>
>> What goes in this patch, is a simple scheme to dynamically allocate such an
>> array, in order to minimize memory usage for memcg caches. Because we would
>> also like to avoid allocations all the time, at least for now, the array will
>> only grow. It will tend to be big enough to hold the maximum number of
>> kmem-limited memcgs ever achieved.
>>
>> We'll allocate it to be a minimum of 64 kmem-limited memcgs. When we have more
>> than that, we'll start doubling the size of this array every time the limit is
>> reached.
>>
>> Because we are only considering kmem limited memcgs, a natural point for this
>> to happen is when we write to the limit. At that point, we already have
>> set_limit_mutex held, so that will become our natural synchronization
>> mechanism.
>>
>> ...
>>
>> +static struct ida kmem_limited_groups;
> 
> Could use DEFINE_IDA() here
> 
>>
>> ...
>>
>>  static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>>  {
>> +	int ret;
>> +
>>  	memcg->kmemcg_id = -1;
>> -	memcg_propagate_kmem(memcg);
>> +	ret = memcg_propagate_kmem(memcg);
>> +	if (ret)
>> +		return ret;
>> +
>> +	if (mem_cgroup_is_root(memcg))
>> +		ida_init(&kmem_limited_groups);
> 
> and zap this?
> 

Ok.

I am starting to go over your replies now, and general question:
Since you have already included this in mm, would you like me to
resubmit the series changing things according to your feedback, or
should I send incremental patches?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
