Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 8C67F6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 23:47:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 10B3F3EE0BD
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:47:12 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E2A2445DE53
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:47:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CA01045DE4D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:47:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC9A7E08001
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:47:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 703E71DB8040
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:47:11 +0900 (JST)
Message-ID: <51638F2B.3000800@jp.fujitsu.com>
Date: Tue, 09 Apr 2013 12:46:51 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/12] memcg: don't need memcg->memcg_name
References: <5162648B.9070802@huawei.com> <51626584.7050405@huawei.com> <5163868B.3020905@jp.fujitsu.com> <5163887D.1040809@huawei.com>
In-Reply-To: <5163887D.1040809@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2013/04/09 12:18), Li Zefan wrote:
>>> @@ -5188,12 +5154,28 @@ static int mem_cgroup_dangling_read(struct cgroup *cont, struct cftype *cft,
>>>    					struct seq_file *m)
>>>    {
>>>    	struct mem_cgroup *memcg;
>>> +	char *memcg_name;
>>> +	int ret;
>>> +
>>> +	/*
>>> +	 * cgroup.c will do page-sized allocations most of the time,
>>> +	 * so we'll just follow the pattern. Also, __get_free_pages
>>> +	 * is a better interface than kmalloc for us here, because
>>> +	 * we'd like this memory to be always billed to the root cgroup,
>>> +	 * not to the process removing the memcg. While kmalloc would
>>> +	 * require us to wrap it into memcg_stop/resume_kmem_account,
>>> +	 * with __get_free_pages we just don't pass the memcg flag.
>>> +	 */
>>> +	memcg_name = (char *)__get_free_pages(GFP_KERNEL, 0);
>>> +	if (!memcg_name)
>>> +		return -ENOMEM;
>>>    
>>>    	mutex_lock(&dangling_memcgs_mutex);
>>>    
>>>    	list_for_each_entry(memcg, &dangling_memcgs, dead) {
>>> -		if (memcg->memcg_name)
>>> -			seq_printf(m, "%s:\n", memcg->memcg_name);
>>> +		ret = cgroup_path(memcg->css.cgroup, memcg_name, PAGE_SIZE);
>>> +		if (!ret)
>>> +			seq_printf(m, "%s:\n", memcg_name);
>>>    		else
>>>    			seq_printf(m, "%p (name lost):\n", memcg);
>>>    
>>
>> I'm sorry for dawm question ...when this error happens ?
>> We may get ENAMETOOLONG even with PAGE_SIZE(>=4096bytes) buffer ?
>>
> 
> It does no harm to check the return value, and we don't have to
> worry about if cgroup_path() will be changed to return some other
> errno like ENOMEM in the future.
> 
Hmm. but the name is not lost, right ?
How about returning error rather than making a mixture of lines in different formats ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
