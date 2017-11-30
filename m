Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8201A6B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 19:27:49 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c3so2937636wrd.0
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:27:49 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a6sor908157wma.78.2017.11.29.16.27.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 16:27:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <137a49f9-8286-8bf4-91c5-37b5f6b5a842@virtuozzo.com>
References: <150583358557.26700.8490036563698102569.stgit@localhost.localdomain>
 <20170927141530.25286286fb92a2573c4b548f@linux-foundation.org>
 <fbb67bef-c13f-7fcb-fa6a-e3a7f6e5c82b@virtuozzo.com> <20170928140230.a9a0cd44a09eae9441a83bdc@linux-foundation.org>
 <137a49f9-8286-8bf4-91c5-37b5f6b5a842@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 29 Nov 2017 16:27:45 -0800
Message-ID: <CALvZod5AC-iRBRgP2O-4x6b6iSdTpVRPFu1kma9fh20yxJY7Xw@mail.gmail.com>
Subject: Re: [PATCH] mm: Make count list_lru_one::nr_items lockless
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, apolyakov@beget.ru, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Fri, Sep 29, 2017 at 1:15 AM, Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> On 29.09.2017 00:02, Andrew Morton wrote:
>> On Thu, 28 Sep 2017 10:48:55 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>
>>>>> This patch aims to make super_cache_count() (and other functions,
>>>>> which count LRU nr_items) more effective.
>>>>> It allows list_lru_node::memcg_lrus to be RCU-accessed, and makes
>>>>> __list_lru_count_one() count nr_items lockless to minimize
>>>>> overhead introduced by locking operation, and to make parallel
>>>>> reclaims more scalable.
>>>>
>>>> And...  what were the effects of the patch?  Did you not run the same
>>>> performance tests after applying it?
>>>
>>> I've just detected the such high usage of shrink slab on production node. It's rather
>>> difficult to make it use another kernel, than it uses, only kpatches are possible.
>>> So, I haven't estimated how it acts on node's performance.
>>> On test node I see, that the patch obviously removes raw_spin_lock from perf profile.
>>> So, it's a little bit untested in this way.
>>
>> Well that's a problem.  The patch increases list_lru.o text size by a
>> lot (4800->5696) which will have a cost.  And we don't have proof that
>> any benefit is worth that cost.  It shouldn't be too hard to cook up a
>> synthetic test to trigger memcg slab reclaim and then run a
>> before-n-after benchmark?
>
> Ok, then, please, ignore this for a while, I'll try to do it a little bit later.
>

I rebased this patch on linus tree (replacing kfree_rcu with call_rcu
as there is no kvfree_rcu) and did some experiments. I think the patch
is worth to be included.

Setup: running a fork-bomb in a memcg of 200MiB on a 8GiB and 4 vcpu
VM and recording the trace with 'perf record -g -a'.

The trace without the patch:

+  34.19%     fb.sh  [kernel.kallsyms]  [k] queued_spin_lock_slowpath
+  30.77%     fb.sh  [kernel.kallsyms]  [k] _raw_spin_lock
+   3.53%     fb.sh  [kernel.kallsyms]  [k] list_lru_count_one
+   2.26%     fb.sh  [kernel.kallsyms]  [k] super_cache_count
+   1.68%     fb.sh  [kernel.kallsyms]  [k] shrink_slab
+   0.59%     fb.sh  [kernel.kallsyms]  [k] down_read_trylock
+   0.48%     fb.sh  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrestore
+   0.38%     fb.sh  [kernel.kallsyms]  [k] shrink_node_memcg
+   0.32%     fb.sh  [kernel.kallsyms]  [k] queue_work_on
+   0.26%     fb.sh  [kernel.kallsyms]  [k] count_shadow_nodes

With the patch:

+   0.16%     swapper  [kernel.kallsyms]    [k] default_idle
+   0.13%     oom_reaper  [kernel.kallsyms]    [k] mutex_spin_on_owner
+   0.05%     perf  [kernel.kallsyms]    [k] copy_user_generic_string
+   0.05%     init.real  [kernel.kallsyms]    [k] wait_consider_task
+   0.05%     kworker/0:0  [kernel.kallsyms]    [k] finish_task_switch
+   0.04%     kworker/2:1  [kernel.kallsyms]    [k] finish_task_switch
+   0.04%     kworker/3:1  [kernel.kallsyms]    [k] finish_task_switch
+   0.04%     kworker/1:0  [kernel.kallsyms]    [k] finish_task_switch
+   0.03%     binary  [kernel.kallsyms]    [k] copy_page


Kirill, can you resend your patch with this info or do you want me
send the rebased patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
