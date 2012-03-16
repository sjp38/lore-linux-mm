Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 0D5FC6B0044
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 06:23:06 -0400 (EDT)
Message-ID: <4F63141E.8070709@parallels.com>
Date: Fri, 16 Mar 2012 14:21:18 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC REPOST] cgroup: removing css reference drain wait during
 cgroup removal
References: <20120312213155.GE23255@google.com> <20120312213343.GF23255@google.com> <20120313151148.f8004a00.kamezawa.hiroyu@jp.fujitsu.com> <20120313163914.GD7349@google.com> <20120314092828.3321731c.kamezawa.hiroyu@jp.fujitsu.com> <4F6068F4.4090909@parallels.com> <4F6134E1.5090601@jp.fujitsu.com> <4F61D167.4000402@parallels.com> <4F62830F.4060303@jp.fujitsu.com>
In-Reply-To: <4F62830F.4060303@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, gthelen@google.com, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, Jens Axboe <axboe@kernel.dk>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>


>>>
>>> I thought of this a little yesterday. Current my idea is applying following
>>> rule for res_counter.
>>>
>>> 1. All res_counter is hierarchical. But behavior should be optimized.
>>>
>>> 2. If parent res_counter has UNLIMITED limit, 'usage' will not be propagated
>>>     to its parent at _charge_.
>>
>> That doesn't seem to make much sense. If you are unlimited, but your
>> parent is limited,
>> he has a lot more interest to know about the charge than you do.
>
>
> Sorry, I should write "If all ancestors are umlimited'.
> If parent is limited, the children should be treated as limited.
>
>> So the
>> logic should rather be the opposite: Don't go around getting locks and
>> all that if you are unlimited. Your parent might, though.
>>
>> I am trying to experiment a bit with billing to percpu counters for
>> unlimited res_counters. But their inexact nature is giving me quite a
>> headache.
>>
>
>
> Personally, I think percpu counter is not the best one. Yes, it will work but...
> Because of its nature of error range, it has scalability problem. Considering
> to have a tree like
>
> 	/A/B/Guest0/tasks
>               Guest1/tasks
>               Guest2/tasks
>               Guest4/tasks
>               Guest5/tasks
>               ......
>
> percpu res_counter may work scarable in GuestX level but will conflict in level B.
> And I don't want to think what happens in 256 cpu system. Error in B will be
> very big.

Usually the recommendation in this case is to follow 
percpu_counter_read() with percpu_counter_sum()

If we additionally wrap the updaters in rcu_read_lock(), we can sum it 
up when needed with relative confidence. It does have performance 
scalability problems in big systems, but no bigger than we have today.

The advantage of percpu counters, is that we don't need to think in 
terms of "unlimited", but rather, in terms of "close enough to the limit".

Here is an excerpt of a patch I am experimenting with

1:      usage = percpu_counter_read(&c->usage_pcp);

         if (percpu_counter_read(&c->usage_pcp) + val <
             c->limit + num_online_cpus() * percpu_counter_batch) {
5:              percpu_counter_add(&c->usage_pcp, val);
                 rcu_read_unlock();
                 return 0;
         }
         rcu_read_unlock();
10:
         raw_spin_lock(&c->usage_pcp.lock);
         usage = __percpu_counter_sum_locked(&c->usage_pcp);

         if (usage + val > c->limit) {
5:              c->failcnt++;
                 ret = -ENOMEM;
                 goto out;
         }

20:      usage += val;
         c->usage_pcp.count = usage;
         if (usage > c->usage_pcp.max)
                 c->usage_pcp.max = usage;

25: out:
         raw_spin_unlock(&c->usage_pcp.lock);
         return ret;


So we probe the current counter, and if we are unlimited, or not close 
to the limits, we update it per-cpu, and let it go.

If we believe we're in a suspicious area, we take the lock (as a quick 
hack, I am holding the percpu lock directly), and then proceed 
everything under the lock.

In the unlimited case, we'll always be writing to the percpu storage.

Note, also, that this is always either under a spinlock, or rcu marked area.

This can also possibly be improved by an unfrequent slow-path update in 
which once we start reading from percpu_counter_sum, we flip a 
res_counter bit to mark that, and then we start dealing with the 
usage_pcp.count directly, without any percpu. This would work exactly 
like the res_counters today, so it is kind of a fallback mode.

For readers, a combination of synchronize_rcu() + spin_lock() on the 
reader side should be enough to guarantee that the result of 
percpu_counter_sum() is reliable enough.

Also please note, that our read-side these days is not that good as 
well: because the way we do caching in memcg, we can end up with the 
*exact* situation as this proposal. If the same memcg is being updated 
in all cpus, we can have up to 32 * nr_cpus() pages in the cache, that 
are not really used by memcg.

I actually have patches to force a drain_all_caches_sync() before reads, 
but I am holding them waiting for something to happen in this discussion.


>
> Another idea is to borrow a resource from memcg to the tasks. i.e.having per-task
> caching of charges. But it has two problems that draining unused resource is difficult
> and precise usage is unknown.
>
> IMHO, hard-limited resource counter itself may be a problem ;)
Yes, it is.

Indeed, if percpu charging as I described above is still not acceptable, 
our way out of this may be heavier caching. Maybe we need per-level 
cache, or something like that.
Per-task may get tricky, specially when we start having charges that 
can't be directly related to a task, like slab objects.

> So, an idea, 'if all ancestors are unlimited, don't propagate charges.'
> comes to my mind. With this, people use resource in FLAT (but has hierarchical cgroup
> tree) will not see any performance problem.
>
>
>
>>> 3. If a res_counter has UNLIMITED limit, at reading usage, it must visit
>>>      all children and returns a sum of them.
>>>
>>> Then,
>>> 	/cgroup/
>>> 		memory/                       (unlimited)
>>> 			libivirt/             (unlimited)
>>> 				 qeumu/       (unlimited)
>>> 				        guest/(limited)
>>>
>>> All dir can show hierarchical usage and the guest will not have
>>> any lock contention at runtime.
>>
>> If we are okay with summing it up at read time, we may as well
>> keep everything in percpu counters at all times.
>>
>
>
> If all ancestors are unlimited, we don't need to propagate usage upwards
> at charging. If one of ancestors are limited, we need to propagate and
> check usage at charging.

The only problem is that "one of ancestors is limited" is expected to be 
quite a common case. So by optimizing for unlimited, I think we're 
tricking ourselves into believing we're solving anything, when in 
reality we're not.

>
>>
>>
>>>    - memory.use_hierarchy should be obsolete ?
>> If we're going fully hierarchical, yes.
>>
>
> Another big problem is 'when' we should do this change..
> Maybe this 'hierarchical' problem will be good topic in MM summit.

we're in no shortage of topics! =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
