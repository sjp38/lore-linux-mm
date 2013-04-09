Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 3BCCE6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 21:29:07 -0400 (EDT)
Message-ID: <51636EAC.10307@huawei.com>
Date: Tue, 9 Apr 2013 09:28:12 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/12] memcg: don't need memcg->memcg_name
References: <5162648B.9070802@huawei.com> <51626584.7050405@huawei.com> <20130408142503.GH17178@dhcp22.suse.cz>
In-Reply-To: <20130408142503.GH17178@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 2013/4/8 22:25, Michal Hocko wrote:
> On Mon 08-04-13 14:36:52, Li Zefan wrote:
> [...]
>> @@ -5188,12 +5154,28 @@ static int mem_cgroup_dangling_read(struct cgroup *cont, struct cftype *cft,
>>  					struct seq_file *m)
>>  {
>>  	struct mem_cgroup *memcg;
>> +	char *memcg_name;
>> +	int ret;
> 
> The interface is only for debugging, all right, but that doesn't mean we
> should allocate a buffer for each read. Why cannot we simply use
> cgroup_path for seq_printf directly? Can we still race with the group
> rename?

because cgroup_path() requires the caller pass a buffer to it.

> 
>> +
>> +	/*
>> +	 * cgroup.c will do page-sized allocations most of the time,
>> +	 * so we'll just follow the pattern. Also, __get_free_pages
>> +	 * is a better interface than kmalloc for us here, because
>> +	 * we'd like this memory to be always billed to the root cgroup,
>> +	 * not to the process removing the memcg. While kmalloc would
>> +	 * require us to wrap it into memcg_stop/resume_kmem_account,
>> +	 * with __get_free_pages we just don't pass the memcg flag.
>> +	 */
>> +	memcg_name = (char *)__get_free_pages(GFP_KERNEL, 0);
>> +	if (!memcg_name)
>> +		return -ENOMEM;
>>  
>>  	mutex_lock(&dangling_memcgs_mutex);
>>  
>>  	list_for_each_entry(memcg, &dangling_memcgs, dead) {
>> -		if (memcg->memcg_name)
>> -			seq_printf(m, "%s:\n", memcg->memcg_name);
>> +		ret = cgroup_path(memcg->css.cgroup, memcg_name, PAGE_SIZE);
>> +		if (!ret)
>> +			seq_printf(m, "%s:\n", memcg_name);
>>  		else
>>  			seq_printf(m, "%p (name lost):\n", memcg);
>>  
>> @@ -5203,6 +5185,7 @@ static int mem_cgroup_dangling_read(struct cgroup *cont, struct cftype *cft,
>>  	}
>>  
>>  	mutex_unlock(&dangling_memcgs_mutex);
>> +	free_pages((unsigned long)memcg_name, 0);
>>  	return 0;
>>  }
>>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
