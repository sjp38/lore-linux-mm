Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4EF9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 21:54:14 -0400 (EDT)
Message-ID: <4E812C81.9020909@parallels.com>
Date: Mon, 26 Sep 2011 22:53:05 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/7] per-cgroup tcp buffers control
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-5-git-send-email-glommer@parallels.com> <20110926195906.f1f5831c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110926195906.f1f5831c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On 09/26/2011 07:59 AM, KAMEZAWA Hiroyuki wrote:
> On Sun, 18 Sep 2011 21:56:42 -0300
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> With all the infrastructure in place, this patch implements
>> per-cgroup control for tcp memory pressure handling.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>
> a comment below.
>
>> +int tcp_init_cgroup(struct proto *prot, struct cgroup *cgrp,
>> +		    struct cgroup_subsys *ss)
>> +{
>> +	struct mem_cgroup *cg = mem_cgroup_from_cont(cgrp);
>> +	unsigned long limit;
>> +
>> +	cg->tcp_memory_pressure = 0;
>> +	atomic_long_set(&cg->tcp_memory_allocated, 0);
>> +	percpu_counter_init(&cg->tcp_sockets_allocated, 0);
>> +
>> +	limit = nr_free_buffer_pages() / 8;
>> +	limit = max(limit, 128UL);
>> +
>> +	cg->tcp_prot_mem[0] = sysctl_tcp_mem[0];
>> +	cg->tcp_prot_mem[1] = sysctl_tcp_mem[1];
>> +	cg->tcp_prot_mem[2] = sysctl_tcp_mem[2];
>> +
>
> Then, the parameter doesn't inherit parent's one ?
>
> I think sockets_populate should pass 'parent' and
>
>
> I think you should have a function
>
>      mem_cgroup_should_inherit_parent_settings(parent)
>
> (This is because you made this feature as a part of memcg.
>   please provide expected behavior.)
>
> Thanks,
> -Kame

Kame: Another look into this:

sysctl_tcp_mem is a global value, unless you have different namespaces.
So it is either global anyway, or should come from the namespace, not 
the parent.

Now, the goal here is to set the maximum possible value for those 
fields. That, indeed, should come from the parent.

That's my understanding...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
