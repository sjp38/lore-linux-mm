Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 9A4626B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 00:32:19 -0400 (EDT)
Received: by mail-bk0-f47.google.com with SMTP id jg9so51744bkc.6
        for <linux-mm@kvack.org>; Thu, 01 Aug 2013 21:32:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130801162012.GA23319@cmpxchg.org>
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
	<1375358407-10777-1-git-send-email-handai.szj@taobao.com>
	<20130801162012.GA23319@cmpxchg.org>
Date: Fri, 2 Aug 2013 12:32:17 +0800
Message-ID: <CAFj3OHUxir9kUXgHfOb1m6LDzO8HBG68CDi3MzV54sC0jdP=iQ@mail.gmail.com>
Subject: Re: [PATCH V5 7/8] memcg: don't account root memcg page stats if only
 root exists
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@taobao.com>

On Fri, Aug 2, 2013 at 12:20 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Thu, Aug 01, 2013 at 08:00:07PM +0800, Sha Zhengju wrote:
>> @@ -6303,6 +6360,49 @@ mem_cgroup_css_online(struct cgroup *cont)
>>       }
>>
>>       error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
>> +     if (!error) {
>> +             if (!mem_cgroup_in_use()) {
>> +                     /* I'm the first non-root memcg, move global stats to root memcg.
>> +                      * Memcg creating is serialized by cgroup locks(cgroup_mutex),
>> +                      * so the mem_cgroup_in_use() checking is safe.
>> +                      *
>> +                      * We use global_page_state() to get global page stats, but
>> +                      * because of the optimized inc/dec functions in SMP while
>> +                      * updating each zone's stats, We may lose some numbers
>> +                      * in a stock(zone->pageset->vm_stat_diff) which brings some
>> +                      * inaccuracy. But places where kernel use these page stats to
>> +                      * steer next decision e.g. dirty page throttling or writeback
>> +                      * also use global_page_state(), so here it's enough too.
>> +                      */
>> +                     spin_lock(&root_mem_cgroup->pcp_counter_lock);
>> +                     root_mem_cgroup->stats_base.count[MEM_CGROUP_STAT_FILE_MAPPED] =
>> +                                             global_page_state(NR_FILE_MAPPED);
>> +                     root_mem_cgroup->stats_base.count[MEM_CGROUP_STAT_FILE_DIRTY] =
>> +                                             global_page_state(NR_FILE_DIRTY);
>> +                     root_mem_cgroup->stats_base.count[MEM_CGROUP_STAT_WRITEBACK] =
>> +                                             global_page_state(NR_WRITEBACK);
>> +                     spin_unlock(&root_mem_cgroup->pcp_counter_lock);
>> +             }
>
> If inaccuracies in these counters are okay, why do we go through an
> elaborate locking scheme that sprinkles memcg callbacks everywhere
> just to be 100% reliable in the rare case somebody moves memory
> between cgroups?

IMO they are not the same thing. Moving between cgroups may happen
many times, if we ignore the inaccuracy between moving, then the
cumulative inaccuracies caused by this back and forth behavior can
become very large.

But the transferring above occurs only once since we do it only when
the first non-root memcg creating, so the error is at most
zone->pageset->stat_threshold. This threshold depends on the amount of
zone memory and  the number of processors, and its maximum value is
125, so I thought using global_page_state() is enough. Of course we
can add the stock to seek for greater perfection, but there are also
possibilities of inaccuracy because of racy.


-- 
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
