Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14BEB9000BD
	for <linux-mm@kvack.org>; Sat, 17 Sep 2011 23:33:16 -0400 (EDT)
Message-ID: <4E75664B.9070605@parallels.com>
Date: Sun, 18 Sep 2011 00:32:27 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/7] socket: initial cgroup code.
References: <1316051175-17780-1-git-send-email-glommer@parallels.com> <1316051175-17780-3-git-send-email-glommer@parallels.com> <20110917175207.GB1658@shutemov.name>
In-Reply-To: <20110917175207.GB1658@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org

On 09/17/2011 02:52 PM, Kirill A. Shutemov wrote:
> On Wed, Sep 14, 2011 at 10:46:10PM -0300, Glauber Costa wrote:
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
>>   include/linux/memcontrol.h |   38 ++++++++++++++++++++++++++++++++++++++
>>   include/net/sock.h         |    2 ++
>>   net/core/sock.c            |    3 +++
>>   3 files changed, 43 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 3b535db..be457ce 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -395,5 +395,43 @@ mem_cgroup_print_bad_page(struct page *page)
>>   }
>>   #endif
>>
>> +#ifdef CONFIG_INET
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +#include<net/sock.h>
>> +static inline void sock_update_memcg(struct sock *sk)
>> +{
>> +	/* right now a socket spends its whole life in the same cgroup */
>> +	BUG_ON(sk->sk_cgrp);
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
>> +
>> +static inline void sock_release_memcg(struct sock *sk)
>> +{
>> +	cgroup_release_and_wakeup_rmdir(mem_cgroup_css(sk->sk_cgrp));
>> +}
>
> Do we really need to have these functions in the header?
>
No, I can move it to memcontrol.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
