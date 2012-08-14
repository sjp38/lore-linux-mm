Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 6CFB76B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 07:04:03 -0400 (EDT)
Message-ID: <502A2FE5.4060809@parallels.com>
Date: Tue, 14 Aug 2012 15:00:53 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 06/11] memcg: kmem controller infrastructure
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-7-git-send-email-glommer@parallels.com> <50254475.4000201@jp.fujitsu.com>
In-Reply-To: <50254475.4000201@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On 08/10/2012 09:27 PM, Kamezawa Hiroyuki wrote:
>> +bool __memcg_kmem_new_page(gfp_t gfp, void *_handle, int order)
>> > +{
>> > +	struct mem_cgroup *memcg;
>> > +	struct mem_cgroup **handle = (struct mem_cgroup **)_handle;
>> > +	bool ret = true;
>> > +	size_t size;
>> > +	struct task_struct *p;
>> > +
>> > +	*handle = NULL;
>> > +	rcu_read_lock();
>> > +	p = rcu_dereference(current->mm->owner);
>> > +	memcg = mem_cgroup_from_task(p);
>> > +	if (!memcg_kmem_enabled(memcg))
>> > +		goto out;
>> > +
>> > +	mem_cgroup_get(memcg);
>> > +
> This mem_cgroup_get() will be a potentioal performance problem.
> Don't you have good idea to avoid accessing atomic counter here ?
> I think some kind of percpu counter or a feature to disable "move task"
> will be a help.
> 
> 

I have just sent out a proposal to deal with this. I tried the trick of
marking only the first charge and last uncharge, and it works quite
alright at the cost of a bit test on most calls to memcg_kmem_charge.

Please let me know what you think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
