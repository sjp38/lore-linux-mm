Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id B78CC6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 04:42:03 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3AF823EE0C0
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:42:02 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F397445DE5B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:42:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C738445DE55
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:42:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B8CA11DB8056
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:42:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 647FE1DB8047
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:42:01 +0900 (JST)
Message-ID: <507D1DBC.8030805@jp.fujitsu.com>
Date: Tue, 16 Oct 2012 17:41:32 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 09/14] memcg: kmem accounting lifecycle management
References: <1349690780-15988-1-git-send-email-glommer@parallels.com> <1349690780-15988-10-git-send-email-glommer@parallels.com> <20121011131143.GF29295@dhcp22.suse.cz> <5077CB05.907@parallels.com> <20121012084100.GE10110@dhcp22.suse.cz>
In-Reply-To: <20121012084100.GE10110@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, devel@openvz.org, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

(2012/10/12 17:41), Michal Hocko wrote:
> On Fri 12-10-12 11:47:17, Glauber Costa wrote:
>> On 10/11/2012 05:11 PM, Michal Hocko wrote:
>>> On Mon 08-10-12 14:06:15, Glauber Costa wrote:
>>>> Because kmem charges can outlive the cgroup, we need to make sure that
>>>> we won't free the memcg structure while charges are still in flight.
>>>> For reviewing simplicity, the charge functions will issue
>>>> mem_cgroup_get() at every charge, and mem_cgroup_put() at every
>>>> uncharge.
>>>>
>>>> This can get expensive, however, and we can do better. mem_cgroup_get()
>>>> only really needs to be issued once: when the first limit is set. In the
>>>> same spirit, we only need to issue mem_cgroup_put() when the last charge
>>>> is gone.
>>>>
>>>> We'll need an extra bit in kmem_accounted for that: KMEM_ACCOUNTED_DEAD.
>>>> it will be set when the cgroup dies, if there are charges in the group.
>>>> If there aren't, we can proceed right away.
>>>>
>>>> Our uncharge function will have to test that bit every time the charges
>>>> drop to 0. Because that is not the likely output of
>>>> res_counter_uncharge, this should not impose a big hit on us: it is
>>>> certainly much better than a reference count decrease at every
>>>> operation.
>>>>
>>>> [ v3: merged all lifecycle related patches in one ]
>>>>
>>>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>>>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>> CC: Christoph Lameter <cl@linux.com>
>>>> CC: Pekka Enberg <penberg@cs.helsinki.fi>
>>>> CC: Michal Hocko <mhocko@suse.cz>
>>>> CC: Johannes Weiner <hannes@cmpxchg.org>
>>>> CC: Suleiman Souhlal <suleiman@google.com>
>>>
>>> OK, I like the optimization. I have just one comment to the
>>> memcg_kmem_dead naming but other than that
>>>
>>> Acked-by: Michal Hocko <mhocko@suse.cz>
>>>
>>> [...]
>>>> +static bool memcg_kmem_dead(struct mem_cgroup *memcg)
>>>
>>> The name is tricky because it doesn't tell you that it clears the flag
>>> which made me scratch my head when reading comment in kmem_cgroup_destroy
>>>
>> memcg_kmem_finally_kill_that_bastard() ?
>
> memcg_kmem_test_and_clear_dead? I know long but at least clear that the
> flag is cleared. Or just open code it.
>

I agree. Ack by me with that naming.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
