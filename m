Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D79856B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 09:04:10 -0400 (EDT)
Message-ID: <4E676B7C.4030904@parallels.com>
Date: Wed, 7 Sep 2011 10:02:52 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 6/9] per-cgroup tcp buffers control
References: <1315369399-3073-1-git-send-email-glommer@parallels.com> <1315369399-3073-7-git-send-email-glommer@parallels.com> <4E671E1F.4040804@cn.fujitsu.com>
In-Reply-To: <4E671E1F.4040804@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, xemul@parallels.com, netdev@vger.kernel.org, linux-mm@kvack.org, "Eric W. Biederman" <ebiederm@xmission.com>, containers@lists.osdl.org, "David S. Miller" <davem@davemloft.net>

On 09/07/2011 04:32 AM, Li Zefan wrote:
>> +#ifdef CONFIG_INET
>> +#include<net/sock.h>
>> +static inline void sock_update_kmem_cgrp(struct sock *sk)
>> +{
>> +#ifdef CONFIG_CGROUP_KMEM
>> +	sk->sk_cgrp = kcg_from_task(current);
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
>> +	cgroup_exclude_rmdir(&sk->sk_cgrp->css);
>> +#endif
>
> must be protected by rcu_read_lock.

Ok.

>> +}
>> +
>> +static inline void sock_release_kmem_cgrp(struct sock *sk)
>> +{
>> +#ifdef CONFIG_CGROUP_KMEM
>> +	cgroup_release_and_wakeup_rmdir(&sk->sk_cgrp->css);
>> +#endif
>> +}
>
> Ugly. Just use the way you define kcg_from_task().
Disagree.
This releases the pointer from the socket, not the task.
Actually, one of the assumptions I am making here, is that the cgroup
of the socket won't change, even if the task do change cgroups. Getting
the pointer from the task, breaks this. Without this, the code would
be much more complicated, since we'd have to unbill the memory accounted
every time we migrate tasks, and bill again to the new cgroup.


>
>> +
>> +#endif /* CONFIG_INET */
>>   #endif /* _LINUX_KMEM_CGROUP_H */
>>
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 8e4062f..709382f 100644
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
>> +	struct kmem_cgroup	*sk_cgrp;
>>   	void			(*sk_state_change)(struct sock *sk);
>>   	void			(*sk_data_ready)(struct sock *sk, int bytes);
>>   	void			(*sk_write_space)(struct sock *sk);
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 3449df8..7109864 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1139,6 +1139,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
>>   		atomic_set(&sk->sk_wmem_alloc, 1);
>>
>>   		sock_update_classid(sk);
>> +		sock_update_kmem_cgrp(sk);
>>   	}
>>
>>   	return sk;
>> @@ -1170,6 +1171,7 @@ static void __sk_free(struct sock *sk)
>>   		put_cred(sk->sk_peer_cred);
>>   	put_pid(sk->sk_peer_pid);
>>   	put_net(sock_net(sk));
>> +	sock_release_kmem_cgrp(sk);
>>   	sk_prot_free(sk->sk_prot_creator, sk);
>>   }
>>
>> @@ -2252,9 +2254,6 @@ void sk_common_release(struct sock *sk)
>>   }
>>   EXPORT_SYMBOL(sk_common_release);
>>
>> -static DEFINE_RWLOCK(proto_list_lock);
>> -static LIST_HEAD(proto_list);
>> -
>
> compile error.
>
> you should do compile test after each single patch.
Oops, thanks for spotting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
