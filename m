Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 27EF16B0098
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 06:18:55 -0400 (EDT)
Message-ID: <515EA532.4050706@parallels.com>
Date: Fri, 5 Apr 2013 14:19:30 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/7] memcg: use css_get/put when charging/uncharging
 kmem
References: <515BF233.6070308@huawei.com> <515BF284.7060401@huawei.com> <20130404094333.GE29911@dhcp22.suse.cz>
In-Reply-To: <20130404094333.GE29911@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>


> 	 * __mem_cgroup_free will issue static_key_slow_dec because this
> 	 * memcg is active already. If the later initialization fails
> 	 * then the cgroup core triggers the cleanup so we do not have
> 	 * to do it here.
> 	 */
>> -	mem_cgroup_get(memcg);
>>  	static_key_slow_inc(&memcg_kmem_enabled_key);
>>  
>>  	mutex_lock(&set_limit_mutex);
>> @@ -5823,23 +5814,33 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>>  	return mem_cgroup_sockets_init(memcg, ss);
>>  };
>>  
>> -static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
>> +static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
>>  {
>> -	mem_cgroup_sockets_destroy(memcg);
>> +	/*
>> +	 * kmem charges can outlive the cgroup. In the case of slab
>> +	 * pages, for instance, a page contain objects from various
>> +	 * processes, so it is unfeasible to migrate them away. We
>> +	 * need to reference count the memcg because of that.
>> +	 */
> 
> I would prefer if we could merge all three comments in this function
> into a single one. What about something like the following?
> 	/*
> 	 * kmem charges can outlive the cgroup. In the case of slab
> 	 * pages, for instance, a page contain objects from various
> 	 * processes. As we prevent from taking a reference for every
> 	 * such allocation we have to be careful when doing uncharge
> 	 * (see memcg_uncharge_kmem) and here during offlining.
> 	 * The idea is that that only the _last_ uncharge which sees
> 	 * the dead memcg will drop the last reference. An additional
> 	 * reference is taken here before the group is marked dead
> 	 * which is then paired with css_put during uncharge resp. here.
> 	 * Although this might sound strange as this path is called when
> 	 * the reference has already dropped down to 0 and shouldn't be
> 	 * incremented anymore (css_tryget would fail) we do not have
> 	 * other options because of the kmem allocations lifetime.
> 	 */
>> +	css_get(&memcg->css);
> 
> I think that you need a write memory barrier here because css_get
> nor memcg_kmem_mark_dead implies it. memcg_uncharge_kmem uses
> memcg_kmem_test_and_clear_dead which imply a full memory barrier but it
> should see the elevated reference count. No?
> 

We don't use barriers for any other kind of reference counting. What is
different here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
