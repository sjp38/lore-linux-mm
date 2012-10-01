Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id F1E966B006E
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 07:54:57 -0400 (EDT)
Message-ID: <506983B8.8010805@parallels.com>
Date: Mon, 1 Oct 2012 15:51:20 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 06/13] memcg: kmem controller infrastructure
References: <1347977050-29476-1-git-send-email-glommer@parallels.com> <1347977050-29476-7-git-send-email-glommer@parallels.com> <20120926155108.GE15801@dhcp22.suse.cz> <5064392D.5040707@parallels.com> <20120927134432.GE29104@dhcp22.suse.cz> <50658B3B.9020303@parallels.com> <20121001094846.GC8622@dhcp22.suse.cz> <50696BC5.8040808@parallels.com> <20121001115157.GE8622@dhcp22.suse.cz>
In-Reply-To: <20121001115157.GE8622@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Johannes Weiner <hannes@cmpxchg.org>

On 10/01/2012 03:51 PM, Michal Hocko wrote:
> On Mon 01-10-12 14:09:09, Glauber Costa wrote:
>> On 10/01/2012 01:48 PM, Michal Hocko wrote:
>>> On Fri 28-09-12 15:34:19, Glauber Costa wrote:
>>>> On 09/27/2012 05:44 PM, Michal Hocko wrote:
>>>>>>> the reference count aquired by mem_cgroup_get will still prevent the
>>>>>>> memcg from going away, no?
>>>>> Yes but you are outside of the rcu now and we usually do css_get before
>>>>> we rcu_unlock. mem_cgroup_get just makes sure the group doesn't get
>>>>> deallocated but it could be gone before you call it. Or I am just
>>>>> confused - these 2 levels of ref counting is really not nice.
>>>>>
>>>>> Anyway, I have just noticed that __mem_cgroup_try_charge does
>>>>> VM_BUG_ON(css_is_removed(&memcg->css)) on a given memcg so you should
>>>>> keep css ref count up as well.
>>>>>
>>>>
>>>> IIRC, css_get will prevent the cgroup directory from being removed.
>>>> Because some allocations are expected to outlive the cgroup, we
>>>> specifically don't want that.
>>>
>>> Yes, but how do you guarantee that the above VM_BUG_ON doesn't trigger?
>>> Task could have been moved to another group between mem_cgroup_from_task
>>> and mem_cgroup_get, no?
>>>
>>
>> Ok, after reading this again (and again), you seem to be right. It
>> concerns me, however, that simply getting the css would lead us to a
>> double get/put pair, since try_charge will have to do it anyway.
> 
> That happens only for !*ptr case and you provide a memcg here, don't
> you.
> 

        if (*ptr) { /* css should be a valid one */
                memcg = *ptr;
                VM_BUG_ON(css_is_removed(&memcg->css));
                if (mem_cgroup_is_root(memcg))
                        goto done;
                if (consume_stock(memcg, nr_pages))
                        goto done;
                css_get(&memcg->css);


The way I read this, this will still issue a css_get here, unless
consume_stock suceeds (assuming non-root)

So we'd still have to have a wrapping get/put pair outside the charge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
