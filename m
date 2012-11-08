Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A20566B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 02:01:22 -0500 (EST)
Message-ID: <509B5953.4000608@redhat.com>
Date: Thu, 08 Nov 2012 15:03:47 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/19] Foundation for automatic NUMA balancing
References: <1352193295-26815-1-git-send-email-mgorman@suse.de> <509A2970.9000408@redhat.com> <20121107152558.GZ8218@suse.de> <509B533B.7090907@redhat.com> <CAOHXNFG=T63dmc3smkJ2juE7HpxTv6qbavBXycRsXiLBzAwMGw@mail.gmail.com>
In-Reply-To: <CAOHXNFG=T63dmc3smkJ2juE7HpxTv6qbavBXycRsXiLBzAwMGw@mail.gmail.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?GB2312?B?0e7W8Q==?= <richardyangr@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, CAI Qian <caiqian@redhat.com>

On 11/08/2012 02:39 PM, NiOn wrote:
> Hi all:
>           I got a problemGBPo
>           1. on intel cpu xeon E5000 family which support xapic GBP!one NIC
> irq  can share on the CPUs basic on smp_affinity.
>           2. but on intel cpu xeon E5-2600 family which support x2apic, one
> NIC irq only on CPU0 whatever  i set the smp_affinfiy like as "aa"; "55";
> "ff".
>          My OS is CentOS 6.2  x32 GBP!i test 4 cpus!GBP the result is which only
> support apic can share one irq to all cpusGBP!which support x2apic only make
> the irq to one cpu!GBP

richard, I'm not sure whether your problem is occurred with the
patch-set or not,
if it's not related to the patches, you should report it on a *new* subject.

Thanks,
Zhouping

>
>
> want help me
>
>                                                              richard
>
>
> 2012/11/8 Zhouping Liu <zliu@redhat.com>
>
>> On 11/07/2012 11:25 PM, Mel Gorman wrote:
>>
>>> On Wed, Nov 07, 2012 at 05:27:12PM +0800, Zhouping Liu wrote:
>>>
>>>> Hello Mel,
>>>>
>>>> my 2 nodes machine hit a panic fault after applied the patch
>>>> set(based on kernel-3.7.0-rc4), please review it:
>>>>
>>>> <SNIP>
>>>>
>>> Early initialisation problem by the looks of things. Try this please
>>>
>> Tested the patch, and the issue is gone.
>>
>>
>>> ---8<---
>>> mm: numa: Check that preferred_node_policy is initialised
>>>
>>> Zhouping Liu reported the following
>>>
>>> [ 0.000000] ------------[ cut here ]------------
>>> [ 0.000000] kernel BUG at mm/mempolicy.c:1785!
>>> [ 0.000000] invalid opcode: 0000 [#1] SMP
>>> [ 0.000000] Modules linked in:
>>> [ 0.000000] CPU 0
>>> ....
>>> [    0.000000] Call Trace:
>>> [    0.000000] [<ffffffff81176966>] alloc_pages_current+0xa6/0x170
>>> [    0.000000] [<ffffffff81137a44>] __get_free_pages+0x14/0x50
>>> [    0.000000] [<ffffffff819efd9b>] kmem_cache_init+0x53/0x2d2
>>> [    0.000000] [<ffffffff819caa53>] start_kernel+0x1e0/0x3c7
>>>
>>> Problem is that early in boot preferred_nod_policy and SLUB
>>> initialisation trips up. Check it is initialised.
>>>
>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>>
>> Tested-by: Zhouping Liu <zliu@redhat.com>
>>
>> Thanks,
>> Zhouping
>>
>>  ---
>>>   mm/mempolicy.c |    4 ++++
>>>   1 file changed, 4 insertions(+)
>>>
>>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>>> index 11d4b6b..8cfa6dc 100644
>>> --- a/mm/mempolicy.c
>>> +++ b/mm/mempolicy.c
>>> @@ -129,6 +129,10 @@ static struct mempolicy *get_task_policy(struct
>>> task_struct *p)
>>>                 node = numa_node_id();
>>>                 if (node != -1)
>>>                         pol = &preferred_node_policy[node];
>>> +
>>> +               /* preferred_node_policy is not initialised early in boot
>>> */
>>> +               if (!pol->mode)
>>> +                       pol = NULL;
>>>         }
>>>         return pol;
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/**majordomo-info.html<http://vger.kernel.org/majordomo-info.html>
>> Please read the FAQ at  http://www.tux.org/lkml/
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
