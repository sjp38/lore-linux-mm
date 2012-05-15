Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 628B76B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:06:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 610E53EE081
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:06:26 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B7D645DE56
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:06:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DAAD45DE50
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:06:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC5DF1DB8044
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:06:25 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F4861DB8042
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:06:25 +0900 (JST)
Message-ID: <4FB19D8D.9060803@jp.fujitsu.com>
Date: Tue, 15 May 2012 09:04:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/6] memcg: move charges to root cgroup if use_hierarchy=0.
References: <4FACDED0.3020400@jp.fujitsu.com> <4FACE0A2.30608@jp.fujitsu.com> <20120514201438.GI2366@google.com>
In-Reply-To: <20120514201438.GI2366@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

(2012/05/15 5:14), Tejun Heo wrote:

> On Fri, May 11, 2012 at 06:49:22PM +0900, KAMEZAWA Hiroyuki wrote:
>> @@ -3351,9 +3339,8 @@ int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
>>  	struct page_cgroup *pc;
>>  	int csize,  ret = 0;
>>  	struct res_counter *fail_res;
>> -	struct cgroup *pcgrp = cgroup->parent;
>> -	struct mem_cgroup *parent = mem_cgroup_from_cont(pcgrp);
>>  	struct mem_cgroup *memcg  = mem_cgroup_from_cont(cgroup);
>> +	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
>>  	struct res_counter *counter;
>>  
>>  	if (!get_page_unless_zero(page))
>> @@ -3366,13 +3353,11 @@ int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
>>  
>>  	csize = PAGE_SIZE << compound_order(page);
>>  	/* If parent->use_hierarchy == 0, we need to charge parent */
>> -	if (!parent->use_hierarchy) {
>> -		ret = res_counter_charge(&parent->hugepage[idx],
>> -					 csize, &fail_res);
>> -		if (ret) {
>> -			ret = -EBUSY;
>> -			goto err_out;
>> -		}
>> +	if (!parent) {
>> +		parent = root_mem_cgroup;
>> +		/* root has no limit */
>> +		res_counter_charge_nofail(&parent->hugepage[idx],
>> +				 csize, &fail_res);
>>  	}
>>  	counter = &memcg->hugepage[idx];
>>  	res_counter_uncharge_until(counter, counter->parent, csize);
> 
> This function can simply return 0 now, so no point in having int
> return.  Make it return void?
> 
> Also, follow-up patches to cleanup -ENOMEM failure handling in the
> callers would be nice.
> 
Sure, I'll check it.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
