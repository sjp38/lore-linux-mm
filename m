Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 7D4DF6B0002
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 08:48:46 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id ik5so1374236bkc.38
        for <linux-mm@kvack.org>; Fri, 01 Mar 2013 05:48:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <512F0E76.2020707@parallels.com>
References: <512F0E76.2020707@parallels.com>
Date: Fri, 1 Mar 2013 21:48:44 +0800
Message-ID: <CAFj3OHXJckvDPWSnq9R8nZ00Sb0Juxq9oCrGCBeO0UZmgH6OzQ@mail.gmail.com>
Subject: Re: per-cpu statistics
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Cgroups <cgroups@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Hi Glauber,

Forgive me, I'm replying not because I know the reason of current
per-cpu implementation but that I notice you're mentioning something
I'm also interested in. Below is the detail.

On Thu, Feb 28, 2013 at 3:59 PM, Glauber Costa <glommer@parallels.com> wrote:
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
>         get_online_cpus();
>         for_each_online_cpu(cpu)
>                 val += per_cpu(memcg->stat->count[idx], cpu);
> #ifdef CONFIG_HOTPLUG_CPU
>         spin_lock(&memcg->pcp_counter_lock);
>         val += memcg->nocpu_base.count[idx];
>         spin_unlock(&memcg->pcp_counter_lock);
> #endif
>         put_online_cpus();
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

I'm not sure I fully understand your points, root memcg now don't
charge page already and only do some page stat
accounting(CACHE/RSS/SWAP).  Now I'm also trying to do some
optimization specific to the overhead of root memcg stat accounting,
and the first attempt is posted here:
https://lkml.org/lkml/2013/1/2/71 . But it only covered
FILE_MAPPED/DIRTY/WRITEBACK(I've add the last two accounting in that
patchset) and Michal Hock accepted the approach (so did Kame) and
suggested I should handle all the stats in the same way including
CACHE/RSS. But I do not handle things related to memcg LRU where I
notice you have done some work.

It's possible that we may take different ways to bypass root memcg
stat accounting. The next round of the part will be sent out in
following few days(doing some tests now), and for myself any comments
and collaboration are welcome. (Glad to cc to you of course if you're
also interest in it. :) )

Many thanks!


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
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
