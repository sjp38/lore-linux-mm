Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 93CEC6B025F
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 21:18:38 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j124so26628871ith.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 18:18:38 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id n66si23873452itb.124.2016.07.26.18.18.36
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 18:18:37 -0700 (PDT)
Subject: Re: [PATCH v9 0/7] Make cpuid <-> nodeid mapping persistent
References: <1469435749-19582-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <20160725162022.e90e9c6c74a5d147e39e5945@linux-foundation.org>
 <34809745-7e48-29d3-f31b-826414ccdef3@cn.fujitsu.com>
 <122491145.6BHBUIrED6@vostro.rjw.lan>
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Message-ID: <bf54b057-0d97-4614-f88e-f95b9a8eb88a@cn.fujitsu.com>
Date: Wed, 27 Jul 2016 09:18:19 +0800
MIME-Version: 1.0
In-Reply-To: <122491145.6BHBUIrED6@vostro.rjw.lan>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi, RJ

a?? 2016a1'07ae??26ae?JPY 19:53, Rafael J. Wysocki a??e??:
> On Tuesday, July 26, 2016 11:59:38 AM Dou Liyang wrote:
>>
>> a?? 2016a1'07ae??26ae?JPY 07:20, Andrew Morton a??e??:
>>> On Mon, 25 Jul 2016 16:35:42 +0800 Dou Liyang <douly.fnst@cn.fujitsu.com> wrote:
>>>
>>>> [Problem]
>>>>
>>>> cpuid <-> nodeid mapping is firstly established at boot time. And workqueue caches
>>>> the mapping in wq_numa_possible_cpumask in wq_numa_init() at boot time.
>>>>
>>>> When doing node online/offline, cpuid <-> nodeid mapping is established/destroyed,
>>>> which means, cpuid <-> nodeid mapping will change if node hotplug happens. But
>>>> workqueue does not update wq_numa_possible_cpumask.
>>>>
>>>> So here is the problem:
>>>>
>>>> Assume we have the following cpuid <-> nodeid in the beginning:
>>>>
>>>>   Node | CPU
>>>> ------------------------
>>>> node 0 |  0-14, 60-74
>>>> node 1 | 15-29, 75-89
>>>> node 2 | 30-44, 90-104
>>>> node 3 | 45-59, 105-119
>>>>
>>>> and we hot-remove node2 and node3, it becomes:
>>>>
>>>>   Node | CPU
>>>> ------------------------
>>>> node 0 |  0-14, 60-74
>>>> node 1 | 15-29, 75-89
>>>>
>>>> and we hot-add node4 and node5, it becomes:
>>>>
>>>>   Node | CPU
>>>> ------------------------
>>>> node 0 |  0-14, 60-74
>>>> node 1 | 15-29, 75-89
>>>> node 4 | 30-59
>>>> node 5 | 90-119
>>>>
>>>> But in wq_numa_possible_cpumask, cpu30 is still mapped to node2, and the like.
>>>>
>>>> When a pool workqueue is initialized, if its cpumask belongs to a node, its
>>>> pool->node will be mapped to that node. And memory used by this workqueue will
>>>> also be allocated on that node.
>>>
>>> Plan B is to hunt down and fix up all the workqueue structures at
>>> hotplug-time.  Has that option been evaluated?
>>>
>>
>> Yes, the option has been evaluate in this patch:
>> http://www.gossamer-threads.com/lists/linux/kernel/2116748
>>
>>>
>>> Your fix is x86-only and this bug presumably affects other
>>> architectures, yes?I think a "Plan B" would fix all architectures?
>>>
>>
>> Yes, the bug may presumably affect few architectures which support CPU
>> hotplug and NUMA.
>>
>> We have sent the "Plan B" in our community and got a lot of advice and
>> ideas. Based on these suggestions, We carefully balance that two plan.
>> Then we choice the first.
>>
>>>
>>> Thirdly, what is the merge path for these patches?  Is an x86
>>> or ACPI maintainer working with you on them?
>>
>> Yes, we get a lot of guidance and help from RJ who is an ACPI maintainer.
>
> FWIW, the patches are fine by me from the ACPI perspective.
>
> If you want me to apply them, though, ACKs from the x86 and mm maintainers
> will be necessary.
>

I will continue to investigate this bug and wait for maintainers's 	advices.

> Thanks,
> Rafael
>
>
>

Thanks.
Dou


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
