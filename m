Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 356C49000F0
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 06:48:56 -0400 (EDT)
Message-ID: <4E8992EF.30001@parallels.com>
Date: Mon, 3 Oct 2011 14:48:15 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/8] socket: initial cgroup code.
References: <1317637123-18306-1-git-send-email-glommer@parallels.com> <1317637123-18306-3-git-send-email-glommer@parallels.com> <20111003104733.GB29312@shutemov.name>
In-Reply-To: <20111003104733.GB29312@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, avagin@parallels.com

On 10/03/2011 02:47 PM, Kirill A. Shutemov wrote:
> On Mon, Oct 03, 2011 at 02:18:37PM +0400, Glauber Costa wrote:
>> We aim to control the amount of kernel memory pinned at any
>> time by tcp sockets. To lay the foundations for this work,
>> this patch adds a pointer to the kmem_cgroup to the socket
>> structure.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>> ---
>>   include/linux/memcontrol.h |   15 +++++++++++++++
>>   include/net/sock.h         |    2 ++
>>   mm/memcontrol.c            |   33 +++++++++++++++++++++++++++++++++
>>   net/core/sock.c            |    3 +++
>>   4 files changed, 53 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 3b535db..2cb9226 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -395,5 +395,20 @@ mem_cgroup_print_bad_page(struct page *page)
>>   }
>>   #endif
>>
>> +#ifdef CONFIG_INET
>> +struct sock;
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +void sock_update_memcg(struct sock *sk);
>> +void sock_release_memcg(struct sock *sk);
>> +
>> +#else
>> +static inline void sock_update_memcg(struct sock *sk)
>> +{
>> +}
>> +static inline void sock_release_memcg(struct sock *sk)
>> +{
>> +}
>> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>> +#endif /* CONFIG_INET */
>>   #endif /* _LINUX_MEMCONTROL_H */
>>
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 8e4062f..afe1467 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -228,6 +228,7 @@ struct sock_common {
>>     *	@sk_security: used by security modules
>>     *	@sk_mark: generic packet mark
>>     *	@sk_classid: this socket's cgroup classid
>> +  *	@sk_cgrp: this socket's kernel memory (kmem) cgroup
>>     *	@sk_write_pending: a write to stream socket waits to start
>>     *	@sk_state_change: callback to indicate change in the state of the sock
>>     *	@sk_data_ready: callback to indicate there is data to be processed
>> @@ -339,6 +340,7 @@ struct sock {
>>   #endif
>>   	__u32			sk_mark;
>>   	u32			sk_classid;
>> +	struct mem_cgroup	*sk_cgrp;
>>   	void			(*sk_state_change)(struct sock *sk);
>>   	void			(*sk_data_ready)(struct sock *sk, int bytes);
>>   	void			(*sk_write_space)(struct sock *sk);
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 8aaf4ce..08a520e 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -339,6 +339,39 @@ struct mem_cgroup {
>>   	spinlock_t pcp_counter_lock;
>>   };
>>
>> +/* Writing them here to avoid exposing memcg's inner layout */
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +#ifdef CONFIG_INET
>> +#include<net/sock.h>
>> +
>> +void sock_update_memcg(struct sock *sk)
>> +{
>> +	/* right now a socket spends its whole life in the same cgroup */
>> +	BUG_ON(sk->sk_cgrp);
>
> Do we really want to panic in this case?
>
> What about WARN() + return?

Kirill,

I am keeping this code just to have something workable in between.
If you take a look at the last patch, this hunk is going away anyway.

So if you don't oppose it, I'll just keep it to avoid rebasing it.

> Otherwise: Acked-by: Kirill A. Shutemov<kirill@shutemov.name>
>
>> +
>> +	rcu_read_lock();
>> +	sk->sk_cgrp = mem_cgroup_from_task(current);
>> +
>> +	/*
>> +	 * We don't need to protect against anything task-related, because
>> +	 * we are basically stuck with the sock pointer that won't change,
>> +	 * even if the task that originated the socket changes cgroups.
>> +	 *
>> +	 * What we do have to guarantee, is that the chain leading us to
>> +	 * the top level won't change under our noses. Incrementing the
>> +	 * reference count via cgroup_exclude_rmdir guarantees that.
>> +	 */
>> +	cgroup_exclude_rmdir(mem_cgroup_css(sk->sk_cgrp));
>> +	rcu_read_unlock();
>> +}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
