Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDEF8E009D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:58:05 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so5759661pfr.6
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:58:05 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id 61si19814262plz.117.2019.01.09.09.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 09:58:04 -0800 (PST)
Subject: Re: [v2 PATCH 2/5] mm: memcontrol: do not try to do swap when force
 empty
References: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com>
 <1546647560-40026-3-git-send-email-yang.shi@linux.alibaba.com>
 <CALvZod5Fh0K-JKGPH90c+ONBSTdwo7Z8fUyyAMen=ZDzPqTAXQ@mail.gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <c5ff6d71-8c7a-7876-984f-c96907a453aa@linux.alibaba.com>
Date: Wed, 9 Jan 2019 09:55:34 -0800
MIME-Version: 1.0
In-Reply-To: <CALvZod5Fh0K-JKGPH90c+ONBSTdwo7Z8fUyyAMen=ZDzPqTAXQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 1/4/19 4:43 PM, Shakeel Butt wrote:
> On Fri, Jan 4, 2019 at 4:21 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>> The typical usecase of force empty is to try to reclaim as much as
>> possible memory before offlining a memcg.  Since there should be no
>> attached tasks to offlining memcg, the tasks anonymous pages would have
>> already been freed or uncharged.  Even though anonymous pages get
>> swapped out, but they still get charged to swap space.  So, it sounds
>> pointless to do swap for force empty.
>>
>> I tried to dig into the history of this, it was introduced by
>> commit 8c7c6e34a125 ("memcg: mem+swap controller core"), but there is
>> not any clue about why it was done so at the first place.
>>
>> The below simple test script shows slight file cache reclaim improvement
>> when swap is on.
>>
>> echo 3 > /proc/sys/vm/drop_caches
>> mkdir /sys/fs/cgroup/memory/test
>> echo 30 > /sys/fs/cgroup/memory/test/memory.swappiness
>> echo $$ >/sys/fs/cgroup/memory/test/cgroup.procs
>> cat /proc/meminfo | grep ^Cached|awk -F" " '{print $2}'
>> dd if=/dev/zero of=/mnt/test bs=1M count=1024
>> ping localhost > /dev/null &
>> echo 1 > /sys/fs/cgroup/memory/test/memory.force_empty
>> killall ping
>> echo $$ >/sys/fs/cgroup/memory/cgroup.procs
>> cat /proc/meminfo | grep ^Cached|awk -F" " '{print $2}'
>> rmdir /sys/fs/cgroup/memory/test
>> cat /proc/meminfo | grep ^Cached|awk -F" " '{print $2}'
>>
>> The number of page cache is:
>>                          w/o             w/
>> before force empty    1088792        1088784
>> after force empty     41492          39428
>> reclaimed             1047300        1049356
>>
>> Without doing swap, force empty can reclaim 2MB more memory in 1GB page
>> cache.
>>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   mm/memcontrol.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index af7f18b..75208a2 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2895,7 +2895,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>>                          return -EINTR;
>>
>>                  progress = try_to_free_mem_cgroup_pages(memcg, 1,
>> -                                                       GFP_KERNEL, true);
>> +                                                       GFP_KERNEL, false);
> I think we agreed not to change the behavior of force_empty. You can
> customize 'force_empty on wipe_on_offline' to not swapout.

OK, will keep force_empty intact.

Thanks,
Yang

>
>>                  if (!progress) {
>>                          nr_retries--;
>>                          /* maybe some writeback is necessary */
>> --
>> 1.8.3.1
>>
