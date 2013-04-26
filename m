Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E368F6B0002
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 03:37:50 -0400 (EDT)
Message-ID: <517A2EF7.8020607@parallels.com>
Date: Fri, 26 Apr 2013 11:38:31 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: reap dead memcgs under pressure
References: <1366705329-9426-1-git-send-email-glommer@openvz.org> <1366705329-9426-3-git-send-email-glommer@openvz.org> <51792686.50009@huawei.com>
In-Reply-To: <51792686.50009@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 04/25/2013 04:50 PM, Li Zefan wrote:
>> +static void memcg_vmpressure_shrink_dead(void)
>> +{
>> +	struct memcg_cache_params *params, *tmp;
>> +	struct kmem_cache *cachep;
>> +	struct mem_cgroup *memcg;
>> +
>> +	mutex_lock(&dangling_memcgs_mutex);
>> +	list_for_each_entry(memcg, &dangling_memcgs, dead) {
>> +
>> +		mem_cgroup_get(memcg);
> 
> This mem_cgroup_get() looks redundant to me, because you're iterating the list
> and never release dangling_memcgs_mutex in the middle.
> 
You are right. We will never go all the way through free because
memcg_dangling_free is called before free, and needs the mutex.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
