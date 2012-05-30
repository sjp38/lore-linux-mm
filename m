Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 8AD2F6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 08:40:59 -0400 (EDT)
Message-ID: <4FC614CF.5000906@parallels.com>
Date: Wed, 30 May 2012 16:38:39 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 16/28] memcg: kmem controller charge/uncharge infrastructure
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-17-git-send-email-glommer@parallels.com> <20120530123406.GC25094@somewhere.redhat.com>
In-Reply-To: <20120530123406.GC25094@somewhere.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/30/2012 04:34 PM, Frederic Weisbecker wrote:
> On Fri, May 25, 2012 at 05:03:36PM +0400, Glauber Costa wrote:
>> +bool __mem_cgroup_new_kmem_page(struct page *page, gfp_t gfp)
>> +{
>> +	struct mem_cgroup *memcg;
>> +	struct page_cgroup *pc;
>> +	bool ret = true;
>> +	size_t size;
>> +	struct task_struct *p;
>> +
>> +	if (!current->mm || in_interrupt())
>> +		return true;
>> +
>> +	rcu_read_lock();
>> +	p = rcu_dereference(current->mm->owner);
>> +	memcg = mem_cgroup_from_task(p);
>
> So this takes the memcg of the group owner rather than the
> task? I understand why we want this for user memory, but for
> kernel?

That was already discussed when this first came up in my last submission
If I recall correctly, Kame pointed out that this would be needed for 
proper OOM-scoring and killing.

Now of course we won't oom kernel threads or anything like that. But 
since this is also accounted towards memcg, it should at least be 
consistent with each memcg it accounts to.

We can't account kmem for the thread's memcg, and mem to the process'.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
