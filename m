Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id D6F996B0027
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 03:13:32 -0400 (EDT)
Message-ID: <51496194.7020508@parallels.com>
Date: Wed, 20 Mar 2013 11:13:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/5] memcg: make it suck faster
References: <1362489058-3455-1-git-send-email-glommer@parallels.com> <1362489058-3455-4-git-send-email-glommer@parallels.com> <CAFj3OHU6f3o5GmbFyUsqtSWqHruSS4Yyodx=s=Vh8mO7GfTE8w@mail.gmail.com>
In-Reply-To: <CAFj3OHU6f3o5GmbFyUsqtSWqHruSS4Yyodx=s=Vh8mO7GfTE8w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On 03/13/2013 12:08 PM, Sha Zhengju wrote:
>> +static void memcg_update_root_statistics(void)
>> > +{
>> > +       int cpu;
>> > +       u64 pgin, pgout, faults, mjfaults;
>> > +
>> > +       pgin = pgout = faults = mjfaults = 0;
>> > +       for_each_online_cpu(cpu) {
>> > +               struct vm_event_state *ev = &per_cpu(vm_event_states, cpu);
>> > +               struct mem_cgroup_stat_cpu *memcg_stat;
>> > +
>> > +               memcg_stat = per_cpu_ptr(root_mem_cgroup->stat, cpu);
>> > +
>> > +               memcg_stat->events[MEM_CGROUP_EVENTS_PGPGIN] =
>> > +                                                       ev->event[PGPGIN];
>> > +               memcg_stat->events[MEM_CGROUP_EVENTS_PGPGOUT] =
>> > +                                                       ev->event[PGPGOUT];
> ev->event[PGPGIN/PGPGOUT] is counted in block layer(submit_bio()) and
> represents the exactly number of pagein/pageout, but memcg
> PGPGIN/PGPGOUT events only count it as an event and ignore the page
> size. So here we can't straightforward take the ev->events for use.
> 
You are right about that. Although I can't think of a straightforward
way to handle this. Well, except for the obvious of adding another
global statistic.

>> > +               memcg_stat->events[MEM_CGROUP_EVENTS_PGFAULT] =
>> > +                                                       ev->event[PGFAULT];
>> > +               memcg_stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT] =
>> > +                                                       ev->event[PGMAJFAULT];
>> > +
>> > +               memcg_stat->nr_page_events = ev->event[PGPGIN] +
>> > +                                            ev->event[PGPGOUT];
> There's no valid memcg->nr_page_events until now, so the threshold
> notifier, but some people may use it even only root memcg exists.
> Moreover, using PGPGIN + PGPGOUT(exactly number of pagein + pageout)
> as nr_page_events is also inaccurate IMHO.
> 
Humm, I believe I can zero out this. Looking at the code again, this is
not imported to userspace. It is just used to activate the thresholds
and the delta of nr_page_events is a lot more important than nr_page_events.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
