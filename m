Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 822646B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 03:24:15 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5503B3EE0BB
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:24:13 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C17245DE5C
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:24:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1345245DE54
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:24:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 034F0E08001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:24:13 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 91DB8E08004
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 17:24:12 +0900 (JST)
Message-ID: <50EE7A6B.7020005@jp.fujitsu.com>
Date: Thu, 10 Jan 2013 17:23:07 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com> <20130109142314.1ce04a96.akpm@linux-foundation.org> <50EE24A4.8020601@cn.fujitsu.com> <50EE6A48.7060307@parallels.com> <50EE6E50.3040609@jp.fujitsu.com> <50EE73DE.30208@parallels.com>
In-Reply-To: <50EE73DE.30208@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2013/01/10 16:55), Glauber Costa wrote:
> On 01/10/2013 11:31 AM, Kamezawa Hiroyuki wrote:
>> (2013/01/10 16:14), Glauber Costa wrote:
>>> On 01/10/2013 06:17 AM, Tang Chen wrote:
>>>>>> Note: if the memory provided by the memory device is used by the
>>>>>> kernel, it
>>>>>> can't be offlined. It is not a bug.
>>>>>
>>>>> Right.  But how often does this happen in testing?  In other words,
>>>>> please provide an overall description of how well memory hot-remove is
>>>>> presently operating.  Is it reliable?  What is the success rate in
>>>>> real-world situations?
>>>>
>>>> We test the hot-remove functionality mostly with movable_online used.
>>>> And the memory used by kernel is not allowed to be removed.
>>>
>>> Can you try doing this using cpusets configured to hardwall ?
>>> It is my understanding that the object allocators will try hard not to
>>> allocate anything outside the walls defined by cpuset. Which means that
>>> if you have one process per node, and they are hardwalled, your kernel
>>> memory will be spread evenly among the machine. With a big enough load,
>>> they should eventually be present in all blocks.
>>>
>>
>> I'm sorry I couldn't catch your point.
>> Do you want to confirm whether cpuset can work enough instead of
>> ZONE_MOVABLE ?
>> Or Do you want to confirm whether ZONE_MOVABLE will not work if it's
>> used with cpuset ?
>>
>>
> No, I am not proposing to use cpuset do tackle the problem. I am just
> wondering if you would still have high success rates with cpusets in use
> with hardwalls. This is just one example of a workload that would spread
> kernel memory around quite heavily.
>
> So this is just me trying to understand the limitations of the mechanism.
>

Hm, okay. In my undestanding, if the whole memory of a node is configured as
MOVABLE, no kernel memory will not be allocated in the node because zonelist
will not match. So, if cpuset is used with hardwalls, user will see -ENOMEM or OOM,
I guess. even fork() will fail if fallback-to-other-node is not allowed.

If it's configure as ZONE_NORMAL, you need to pray for offlining memory.

AFAIK, IBM's ppc? has 16MB section size. So, some of sections can be offlined
even if they are configured as ZONE_NORMAL. For them, placement of offlined
memory is not important because it's virtualized by LPAR, they don't try
to remove DIMM, they just want to increase/decrease amount of memory.
It's an another approach.

But here, we(fujitsu) tries to remove a system board/DIMM.
So, configuring the whole memory of a node as ZONE_MOVABLE and tries to guarantee
DIMM as removable.

>> IMHO, I don't think shrink_slab() can kill all objects in a node even
>> if they are some caches. We need more study for doing that.
>>
>
> Indeed, shrink_slab can only kill cached objects. They, however, are
> usually a very big part of kernel memory. I wonder though if in case of
> failure, it is worth it to try at least one shrink pass before you give up.
>

Yeah, now, his (our) approach is never allowing kernel memory on a node to be
hot-removed by ZONE_MOVABLE. So, shrink_slab()'s effect will not be seen.

If other brave guys tries to use ZONE_NORMAL for hot-pluggable DIMM, I see,
it's worth triying.

How about checking the target memsection is in NORMAL or in MOVABLE at
hot-removing ? If NORMAL, shrink_slab() will be worth to be called.

BTW, shrink_slab() is now node/zone aware ? If not, fixing that first will
be better direction I guess.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
