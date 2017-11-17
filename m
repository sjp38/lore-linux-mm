Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D123E6B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 01:41:48 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b5so2258890itc.7
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 22:41:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a15sor2124206itj.4.2017.11.16.22.41.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Nov 2017 22:41:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALvZod7AY=J3i0NL-VuWWOxjdVmWh7VnpcQhdx7+Jt-Hnqrk+g@mail.gmail.com>
References: <1510888199-5886-1-git-send-email-laoar.shao@gmail.com> <CALvZod7AY=J3i0NL-VuWWOxjdVmWh7VnpcQhdx7+Jt-Hnqrk+g@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 17 Nov 2017 14:41:46 +0800
Message-ID: <CALOAHbC2v-QD3bDbZDNvBG6th6MHQyCxHLWyuAF2BxNoXz-_DA@mail.gmail.com>
Subject: Re: [PATCH] mm/shmem: set default tmpfs size according to memcg limit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, khlebnikov@yandex-team.ru, mka@chromium.org, Hugh Dickins <hughd@google.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2017-11-17 12:43 GMT+08:00 Shakeel Butt <shakeelb@google.com>:
> On Thu, Nov 16, 2017 at 7:09 PM, Yafang Shao <laoar.shao@gmail.com> wrote:
>> Currently the default tmpfs size is totalram_pages / 2 if mount tmpfs
>> without "-o size=XXX".
>> When we mount tmpfs in a container(i.e. docker), it is also
>> totalram_pages / 2 regardless of the memory limit on this container.
>> That may easily cause OOM if tmpfs occupied too much memory when swap is
>> off.
>> So when we mount tmpfs in a memcg, the default size should be limited by
>> the memcg memory.limit.
>>
>
> The pages of the tmpfs files are charged to the memcg of allocators
> which can be in memcg different from the memcg in which the mount
> operation happened.

Yes.
But the issue is tmpfs files contributed to memory.usage_in_bytes
should be limited.
Let me take an example.
The physical memory size is 1G, and we create a memory cgroup then set the
memory.limit_in_bytes of it to 256M.
Then in this memory cgroup we do bellow test:
     1. mount -t tmpfs tmpfs /mount
         the size of which will be 1G / 2 by default.
      2. write files into this tmpfs
         as the limit of this memory cgroup is 256M while the size of
tmpfs is 512M,
         these files will occupy the while memory in this cgroup and
finally out of memory.


> So, tying the size of a tmpfs mount where it was
> mounted does not make much sense.
>
> Also mount operation which requires CAP_SYS_ADMIN, is usually
> performed by node controller (or job loader) which don't necessarily
> run in the memcg of the actual job.
>
>> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>> ---
>>  include/linux/memcontrol.h |  1 +
>>  mm/memcontrol.c            |  2 +-
>>  mm/shmem.c                 | 20 +++++++++++++++++++-
>>  3 files changed, 21 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 69966c4..79c6709 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -265,6 +265,7 @@ struct mem_cgroup {
>>         /* WARNING: nodeinfo must be the last member here */
>>  };
>>
>> +extern struct mutex memcg_limit_mutex;
>>  extern struct mem_cgroup *root_mem_cgroup;
>>
>>  static inline bool mem_cgroup_disabled(void)
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 661f046..ad32f3c 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2464,7 +2464,7 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
>>  }
>>  #endif
>>
>> -static DEFINE_MUTEX(memcg_limit_mutex);
>> +DEFINE_MUTEX(memcg_limit_mutex);
>
> This mutex is only needed for updating the limit.
>

Thanks for explaination :)

>>
>>  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>>                                    unsigned long limit)
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 07a1d22..1c320dd 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -35,6 +35,7 @@
>>  #include <linux/uio.h>
>>  #include <linux/khugepaged.h>
>>  #include <linux/hugetlb.h>
>> +#include <linux/memcontrol.h>
>>
>>  #include <asm/tlbflush.h> /* for arch/microblaze update_mmu_cache() */
>>
>> @@ -108,7 +109,24 @@ struct shmem_falloc {
>>  #ifdef CONFIG_TMPFS
>>  static unsigned long shmem_default_max_blocks(void)
>>  {
>> -       return totalram_pages / 2;
>> +       unsigned long size;
>> +
>> +#ifdef CONFIG_MEMCG
>> +       struct mem_cgroup *memcg = mem_cgroup_from_task(current);
>> +
>> +       if (memcg == NULL || memcg == root_mem_cgroup)
>> +               size = totalram_pages / 2;
>> +       else {
>> +               mutex_lock(&memcg_limit_mutex);
>> +               size = memcg->memory.limit > totalram_pages ?
>> +                                totalram_pages / 2 : memcg->memory.limit / 2;
>> +               mutex_unlock(&memcg_limit_mutex);
>> +       }
>> +#else
>> +       size = totalram_pages / 2;
>> +#endif
>> +
>> +       return size;
>>  }
>>
>>  static unsigned long shmem_default_max_inodes(void)
>> --
>> 1.8.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe cgroups" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
