Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2ED16B0003
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 04:47:05 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w6-v6so8698296plp.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 01:47:05 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0099.outbound.protection.outlook.com. [104.47.0.99])
        by mx.google.com with ESMTPS id 3-v6si34745858plc.415.2018.06.09.01.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 09 Jun 2018 01:47:04 -0700 (PDT)
Subject: Re: [PATCH v7 15/17] mm: Generalize shrink_slab() calls in
 shrink_node()
References: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
 <152698379298.3393.3040399931339145602.stgit@localhost.localdomain>
 <CALvZod4zzw0f_q4a1HpMHWjhjfK9OcegRkAQb5ZSyfjAYpAfJw@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <c9f0cf2a-5628-6d8f-662f-a381876208c1@virtuozzo.com>
Date: Sat, 9 Jun 2018 11:46:51 +0300
MIME-Version: 1.0
In-Reply-To: <CALvZod4zzw0f_q4a1HpMHWjhjfK9OcegRkAQb5ZSyfjAYpAfJw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, stummala@codeaurora.org, gregkh@linuxfoundation.org, Stephen Rothwell <sfr@canb.auug.org.au>, Roman Gushchin <guro@fb.com>, mka@chromium.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Chris Wilson <chris@chris-wilson.co.uk>, longman@redhat.com, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, jbacik@fb.com, Guenter Roeck <linux@roeck-us.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, lirongqing@baidu.com, Andrey Ryabinin <aryabinin@virtuozzo.com>

Hi, Shakeel.

On 08.06.2018 22:21, Shakeel Butt wrote:
> On Tue, May 22, 2018 at 3:09 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>
>> From: Vladimir Davydov <vdavydov.dev@gmail.com>
>>
>> The patch makes shrink_slab() be called for root_mem_cgroup
>> in the same way as it's called for the rest of cgroups.
>> This simplifies the logic and improves the readability.
>>
>> Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
>> ktkhai: Description written.
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  mm/vmscan.c |   21 ++++++---------------
>>  1 file changed, 6 insertions(+), 15 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index f26ca1e00efb..6dbc659db120 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -628,10 +628,8 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
>>   * @nid is passed along to shrinkers with SHRINKER_NUMA_AWARE set,
>>   * unaware shrinkers will receive a node id of 0 instead.
>>   *
>> - * @memcg specifies the memory cgroup to target. If it is not NULL,
>> - * only shrinkers with SHRINKER_MEMCG_AWARE set will be called to scan
>> - * objects from the memory cgroup specified. Otherwise, only unaware
>> - * shrinkers are called.
>> + * @memcg specifies the memory cgroup to target. Unaware shrinkers
>> + * are called only if it is the root cgroup.
>>   *
>>   * @priority is sc->priority, we take the number of objects and >> by priority
>>   * in order to get the scan target.
>> @@ -645,7 +643,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>>         struct shrinker *shrinker;
>>         unsigned long freed = 0;
>>
> 
> Shouldn't there be a VM_BUG_ON(!memcg) here?

memcg can be NULL here in case of memory controller is disabled at boot parameters
and in case of it's a global reclaim. So, such the check we can't add here.

Thanks,
Kirill
