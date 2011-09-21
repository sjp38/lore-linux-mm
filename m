Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCDF9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 15:00:40 -0400 (EDT)
Message-ID: <4E7A342B.5040608@parallels.com>
Date: Wed, 21 Sep 2011 15:59:55 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/7] socket: initial cgroup code.
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-3-git-send-email-glommer@parallels.com> <CAHH2K0YgkG2J_bO+U9zbZYhTTqSLvr6NtxKxN8dRtfHs=iB8iA@mail.gmail.com>
In-Reply-To: <CAHH2K0YgkG2J_bO+U9zbZYhTTqSLvr6NtxKxN8dRtfHs=iB8iA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On 09/21/2011 03:47 PM, Greg Thelen wrote:
> On Sun, Sep 18, 2011 at 5:56 PM, Glauber Costa<glommer@parallels.com>  wrote:
>> We aim to control the amount of kernel memory pinned at any
>> time by tcp sockets. To lay the foundations for this work,
>> this patch adds a pointer to the kmem_cgroup to the socket
>> structure.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
> ...
>> +void sock_update_memcg(struct sock *sk)
>> +{
>> +       /* right now a socket spends its whole life in the same cgroup */
>> +       BUG_ON(sk->sk_cgrp);
>> +
>> +       rcu_read_lock();
>> +       sk->sk_cgrp = mem_cgroup_from_task(current);
>> +
>> +       /*
>> +        * We don't need to protect against anything task-related, because
>> +        * we are basically stuck with the sock pointer that won't change,
>> +        * even if the task that originated the socket changes cgroups.
>> +        *
>> +        * What we do have to guarantee, is that the chain leading us to
>> +        * the top level won't change under our noses. Incrementing the
>> +        * reference count via cgroup_exclude_rmdir guarantees that.
>> +        */
>> +       cgroup_exclude_rmdir(mem_cgroup_css(sk->sk_cgrp));
>
> This grabs a css_get() reference, which prevents rmdir (will return
> -EBUSY).
Yes.

  How long is this reference held?
For the socket lifetime.

> I wonder about the case
> where a process creates a socket in memcg M1 and later is moved into
> memcg M2.  At that point an admin would expect to be able to 'rmdir
> M1'.  I think this rmdir would return -EBUSY and I suspect it would be
> difficult for the admin to understand why the rmdir of M1 failed.  It
> seems that to rmdir a memcg, an admin would have to kill all processes
> that allocated sockets while in M1.  Such processes may not still be
> in M1.
>
>> +       rcu_read_unlock();
>> +}
I agree. But also, don't see too much ways around it without 
implementing full task migration.

Right now I am working under the assumption that tasks are long lived 
inside the cgroup. Migration potentially introduces some nasty locking 
problems in the mem_schedule path.

Also, unless I am missing something, the memcg already has the policy of
not carrying charges around, probably because of this very same complexity.

True that at least it won't EBUSY you... But I think this is at least a 
way to guarantee that the cgroup under our nose won't disappear in the 
middle of our allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
