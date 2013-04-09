Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 49F196B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 23:19:23 -0400 (EDT)
Message-ID: <5163887D.1040809@huawei.com>
Date: Tue, 9 Apr 2013 11:18:21 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/12] memcg: don't need memcg->memcg_name
References: <5162648B.9070802@huawei.com> <51626584.7050405@huawei.com> <5163868B.3020905@jp.fujitsu.com>
In-Reply-To: <5163868B.3020905@jp.fujitsu.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

>> @@ -5188,12 +5154,28 @@ static int mem_cgroup_dangling_read(struct cgroup *cont, struct cftype *cft,
>>   					struct seq_file *m)
>>   {
>>   	struct mem_cgroup *memcg;
>> +	char *memcg_name;
>> +	int ret;
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
>>   	mutex_lock(&dangling_memcgs_mutex);
>>   
>>   	list_for_each_entry(memcg, &dangling_memcgs, dead) {
>> -		if (memcg->memcg_name)
>> -			seq_printf(m, "%s:\n", memcg->memcg_name);
>> +		ret = cgroup_path(memcg->css.cgroup, memcg_name, PAGE_SIZE);
>> +		if (!ret)
>> +			seq_printf(m, "%s:\n", memcg_name);
>>   		else
>>   			seq_printf(m, "%p (name lost):\n", memcg);
>>   
> 
> I'm sorry for dawm question ...when this error happens ?
> We may get ENAMETOOLONG even with PAGE_SIZE(>=4096bytes) buffer ?
> 

It does no harm to check the return value, and we don't have to
worry about if cgroup_path() will be changed to return some other
errno like ENOMEM in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
