Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 181626B0005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 04:08:15 -0400 (EDT)
Message-ID: <515E8688.3000504@parallels.com>
Date: Fri, 5 Apr 2013 12:08:40 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/7] memcg: use css_get in sock_update_memcg()
References: <515BF233.6070308@huawei.com> <515BF249.50607@huawei.com> <515C2788.90907@parallels.com> <20130403152934.GL16471@dhcp22.suse.cz>
In-Reply-To: <20130403152934.GL16471@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 04/03/2013 07:29 PM, Michal Hocko wrote:
> On Wed 03-04-13 16:58:48, Glauber Costa wrote:
>> On 04/03/2013 01:11 PM, Li Zefan wrote:
>>> Use css_get/css_put instead of mem_cgroup_get/put.
>>>
>>> Note, if at the same time someone is moving @current to a different
>>> cgroup and removing the old cgroup, css_tryget() may return false,
>>> and sock->sk_cgrp won't be initialized.
>>>
>>> Signed-off-by: Li Zefan <lizefan@huawei.com>
>>> ---
>>>  mm/memcontrol.c | 8 ++++----
>>>  1 file changed, 4 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 23d0f6e..43ca91d 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -536,15 +536,15 @@ void sock_update_memcg(struct sock *sk)
>>>  		 */
>>>  		if (sk->sk_cgrp) {
>>>  			BUG_ON(mem_cgroup_is_root(sk->sk_cgrp->memcg));
>>> -			mem_cgroup_get(sk->sk_cgrp->memcg);
>>> +			css_get(&sk->sk_cgrp->memcg->css);
> 
> I am not sure I understand this one. So we have a goup here (which means
> that somebody already took a reference on it, right?) and we are taking
> another reference. If this is released by sock_release_memcg then who
> releases the previous one? It is not directly related to the patch
> because this has been done previously already. Could you clarify
> Glauber, please?

This should be documented in the commit that introduced this, and it was
one of the first bugs I've handled with this code.

Bottom line, we can create sockets normally, and those will have process
context. But we also can create sockets by cloning existing sockets. To
the best of my knowledge, this is done by things like accept().

Because those sockets are a clone of their ancestors, they also belong
to a workload that should be limited. Also note that because they have
cgroup context, we will eventually try to put them. So we need to grab
an extra reference.

socket_update_cgroup is always called at socket creation, and the
original structures are filled with zeroes. Therefore cloning is the
*only* path that takes us here with sk->sk_cgroup filled.

My comment right above this excerpt states:

                /* Socket cloning can throw us here with sk_cgrp already
                 * filled. It won't however, necessarily happen from
                 * process context. So the test for root memcg given
                 * the current task's memcg won't help us in this case.
                 *
                 * Respecting the original socket's memcg is a better
                 * decision in this case.
                 */

> 
>>>  			return;
>>>  		}
>>>  
>>>  		rcu_read_lock();
>>>  		memcg = mem_cgroup_from_task(current);
>>>  		cg_proto = sk->sk_prot->proto_cgroup(memcg);
>>> -		if (!mem_cgroup_is_root(memcg) && memcg_proto_active(cg_proto)) {
>>> -			mem_cgroup_get(memcg);
>>> +		if (!mem_cgroup_is_root(memcg) &&
>>> +		    memcg_proto_active(cg_proto) && css_tryget(&memcg->css)) {
>>>  			sk->sk_cgrp = cg_proto;
>>>  		}
>>
>> What happens if this tryget fails ? Won't we leak a reference here? We
>> will put regardless when the socket is released, and this may go
>> negative. No?
>  
> AFAICS sock_release_memcg releases the reference only if sk->sk_cgrp and
> that one wouldn't be set if css_tryget fails.
> 

Yes, this is totally fine. I was actually thinking of the same socket
cloning I mentioned above. We cannot fail that path because we already
have an "implicit" reference, we just need to officially mark it.

Failing here is indeed fine. Future cloned sockets from this socket will
have NULL cgroup context as well.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
