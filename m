Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBA8D8E009D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 13:00:44 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id u17so4571351pgn.17
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 10:00:44 -0800 (PST)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id h6si69732143plk.231.2019.01.09.10.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 10:00:43 -0800 (PST)
Subject: Re: [v2 PATCH 3/5] mm: memcontrol: introduce wipe_on_offline
 interface
References: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com>
 <1546647560-40026-4-git-send-email-yang.shi@linux.alibaba.com>
 <CALvZod4ea4fR2n1EdZ3HwB3O3iWDHw5nXRnPLKbR6mAuDkWuQA@mail.gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <9bd898c7-4c23-7af4-8446-369865b70f3f@linux.alibaba.com>
Date: Wed, 9 Jan 2019 09:59:11 -0800
MIME-Version: 1.0
In-Reply-To: <CALvZod4ea4fR2n1EdZ3HwB3O3iWDHw5nXRnPLKbR6mAuDkWuQA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 1/4/19 4:47 PM, Shakeel Butt wrote:
> On Fri, Jan 4, 2019 at 4:21 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>> We have some usecases which create and remove memcgs very frequently,
>> and the tasks in the memcg may just access the files which are unlikely
>> accessed by anyone else.  So, we prefer force_empty the memcg before
>> rmdir'ing it to reclaim the page cache so that they don't get
>> accumulated to incur unnecessary memory pressure.  Since the memory
>> pressure may incur direct reclaim to harm some latency sensitive
>> applications.
>>
>> Force empty would help out such usecase, however force empty reclaims
>> memory synchronously when writing to memory.force_empty.  It may take
>> some time to return and the afterwards operations are blocked by it.
>> Although this can be done in background, some usecases may need create
>> new memcg with the same name right after the old one is deleted.  So,
>> the creation might get blocked by the before reclaim/remove operation.
>>
>> Delaying memory reclaim in cgroup offline for such usecase sounds
>> reasonable.  Introduced a new interface, called wipe_on_offline for both
>> default and legacy hierarchy, which does memory reclaim in css offline
>> kworker.
>>
>> Writing to 1 would enable it, writing 0 would disable it.
>>
>> Suggested-by: Michal Hocko <mhocko@suse.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   include/linux/memcontrol.h |  3 +++
>>   mm/memcontrol.c            | 49 ++++++++++++++++++++++++++++++++++++++++++++++
>>   2 files changed, 52 insertions(+)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 83ae11c..2f1258a 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -311,6 +311,9 @@ struct mem_cgroup {
>>          struct list_head event_list;
>>          spinlock_t event_list_lock;
>>
>> +       /* Reclaim as much as possible memory in offline kworker */
>> +       bool wipe_on_offline;
>> +
>>          struct mem_cgroup_per_node *nodeinfo[0];
>>          /* WARNING: nodeinfo must be the last member here */
>>   };
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 75208a2..5a13c6b 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2918,6 +2918,35 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
>>          return mem_cgroup_force_empty(memcg) ?: nbytes;
>>   }
>>
>> +static int wipe_on_offline_show(struct seq_file *m, void *v)
>> +{
>> +       struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
>> +
>> +       seq_printf(m, "%lu\n", (unsigned long)memcg->wipe_on_offline);
>> +
>> +       return 0;
>> +}
>> +
>> +static int wipe_on_offline_write(struct cgroup_subsys_state *css,
>> +                                struct cftype *cft, u64 val)
>> +{
>> +       int ret = 0;
>> +
>> +       struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>> +
>> +       if (mem_cgroup_is_root(memcg))
>> +               return -EINVAL;
>> +
>> +       if (val == 0)
>> +               memcg->wipe_on_offline = false;
>> +       else if (val == 1)
>> +               memcg->wipe_on_offline = true;
>> +       else
>> +               ret = -EINVAL;
>> +
>> +       return ret;
>> +}
>> +
>>   static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
>>                                       struct cftype *cft)
>>   {
>> @@ -4283,6 +4312,11 @@ static ssize_t memcg_write_event_control(struct kernfs_open_file *of,
>>                  .write = mem_cgroup_reset,
>>                  .read_u64 = mem_cgroup_read_u64,
>>          },
>> +       {
>> +               .name = "wipe_on_offline",
> What about "force_empty_on_offline"?

Actually, I don't have preference to the name of the knob. However, 
wipe_on_offline looks shorter.

>
>> +               .seq_show = wipe_on_offline_show,
>> +               .write_u64 = wipe_on_offline_write,
>> +       },
>>          { },    /* terminate */
>>   };
>>
>> @@ -4569,6 +4603,15 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>>          page_counter_set_min(&memcg->memory, 0);
>>          page_counter_set_low(&memcg->memory, 0);
>>
>> +       /*
>> +        * Reclaim as much as possible memory when offlining.
>> +        *
>> +        * Do it after min/low is reset otherwise some memory might
>> +        * be protected by min/low.
>> +        */
>> +       if (memcg->wipe_on_offline)
>> +               mem_cgroup_force_empty(memcg);
>> +
> mem_cgroup_force_empty() also does drain_all_stock(), so, move
> drain_all_stock() in mem_cgroup_css_offline() to the else of 'if
> (memcg->wipe_on_offline)'.

Sure.

Thanks,
Yang

>
>>          memcg_offline_kmem(memcg);
>>          wb_memcg_offline(memcg);
>>
>> @@ -5694,6 +5737,12 @@ static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
>>                  .seq_show = memory_oom_group_show,
>>                  .write = memory_oom_group_write,
>>          },
>> +       {
>> +               .name = "wipe_on_offline",
>> +               .flags = CFTYPE_NOT_ON_ROOT,
>> +               .seq_show = wipe_on_offline_show,
>> +               .write_u64 = wipe_on_offline_write,
>> +       },
>>          { }     /* terminate */
>>   };
>>
>> --
>> 1.8.3.1
>>
