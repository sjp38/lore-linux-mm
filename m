Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 4AD3A6B0002
	for <linux-mm@kvack.org>; Sun,  3 Mar 2013 19:55:57 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5022244DD81
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 09:55:54 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 39AF645DE4E
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 09:55:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 16BFD45DE4D
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 09:55:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 08752E08001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 09:55:54 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B5EF61DB802C
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 09:55:53 +0900 (JST)
Message-ID: <5133F0FD.3040501@jp.fujitsu.com>
Date: Mon, 04 Mar 2013 09:55:25 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: per-cpu statistics
References: <512F0E76.2020707@parallels.com>
In-Reply-To: <512F0E76.2020707@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Cgroups <cgroups@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

(2013/02/28 16:59), Glauber Costa wrote:
> Hi guys
>
> Please enlighten me regarding some historic aspect of memcg before I go
> changing something I shouldn't...
>
> Regarding memcg stats, is there any reason for us to use the current
> per-cpu implementation we have instead of a percpu_counter?
>
> We are doing something like this:
>
>          get_online_cpus();
>          for_each_online_cpu(cpu)
>                  val += per_cpu(memcg->stat->count[idx], cpu);
> #ifdef CONFIG_HOTPLUG_CPU
>          spin_lock(&memcg->pcp_counter_lock);
>          val += memcg->nocpu_base.count[idx];
>          spin_unlock(&memcg->pcp_counter_lock);
> #endif
>          put_online_cpus();
>
> It seems to me that we are just re-implementing whatever percpu_counters
> already do, handling the complication ourselves.
>
> It surely is an array, and this keeps the fields together. But does it
> really matter? Did it come from some measurable result?
>
> I wouldn't touch it if it wouldn't be bothering me. But the reason I
> ask, is that I am resurrecting the patches to bypass the root cgroup
> charges when it is the only group in the system. For that, I would like
> to transfer charges from global, to our memcg equivalents.
>
> Things like MM_ANONPAGES are not percpu, though, and when I add it to
> the memcg percpu structures, I would have to somehow distribute them
> around. When we uncharge, that can become negative.
>
> percpu_counters already handle all that, and then can cope well with
> temporary negative charges in the percpu data, that is later on
> withdrawn from the main base counter.
>
> We are counting pages, so the fact that we're restricted to only half of
> the 64-bit range in percpu counters doesn't seem to be that much of a
> problem.
>
> If this is just a historic leftover, I can replace them all with
> percpu_counters. Any words on that ?
>

An reason I didn't like percpu_counter *was* its memory layout.

==
struct percpu_counter {
         raw_spinlock_t lock;
         s64 count;
#ifdef CONFIG_HOTPLUG_CPU
         struct list_head list;  /* All percpu_counters are on a list */
#endif
         s32 __percpu *counters;
};
==

Assume we have counters in an array, then, we'll have

    lock
    count
    list
    pointer
    lock
    count
    list
    pointer
    ....

An counter's lock ops will invalidate pointers in the array.
We tend to update several counters at once.

If you measure performance on enough large SMP and it looks good,
I think it's ok to go with lib/percpu_counter.c.

Thanks,
-Kame
















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
