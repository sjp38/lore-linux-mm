Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E77B36B0069
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 20:42:31 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j3so3133261pfh.16
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 17:42:31 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id z123si2108729pgb.114.2017.12.13.17.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 17:42:30 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
 <20171129121740.f6drkbktc43l5ib6@dhcp22.suse.cz>
 <4b840074-cb5f-3c10-d65b-916bc02fb1ee@intel.com>
 <20171130085322.tyys6xbzzvui7ogz@dhcp22.suse.cz>
 <0f039a89-5500-1bf5-c013-d39ba3bf62bd@intel.com>
 <20171130094523.vvcljyfqjpbloe5e@dhcp22.suse.cz>
 <9cd6cc9f-252a-3c6f-2f1f-e39d4ec0457b@intel.com>
 <20171208084755.GS20234@dhcp22.suse.cz>
 <f082f521-44a2-0585-3435-63dab24efbb7@intel.com>
 <20171212081126.GK4779@dhcp22.suse.cz>
From: kemi <kemi.wang@intel.com>
Message-ID: <d48b89f4-34d2-f3c8-f20a-b799f4878901@intel.com>
Date: Thu, 14 Dec 2017 09:40:32 +0800
MIME-Version: 1.0
In-Reply-To: <20171212081126.GK4779@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'12ae??12ae?JPY 16:11, Michal Hocko wrote:
> On Tue 12-12-17 10:05:26, kemi wrote:
>>
>>
>> On 2017a1'12ae??08ae?JPY 16:47, Michal Hocko wrote:
>>> On Fri 08-12-17 16:38:46, kemi wrote:
>>>>
>>>>
>>>> On 2017a1'11ae??30ae?JPY 17:45, Michal Hocko wrote:
>>>>> On Thu 30-11-17 17:32:08, kemi wrote:
>>>>
>>>> After thinking about how to optimize our per-node stats more gracefully, 
>>>> we may add u64 vm_numa_stat_diff[] in struct per_cpu_nodestat, thus,
>>>> we can keep everything in per cpu counter and sum them up when read /proc
>>>> or /sys for numa stats. 
>>>> What's your idea for that? thanks
>>>
>>> I would like to see a strong argument why we cannot make it a _standard_
>>> node counter.
>>>
>>
>> all right. 
>> This issue is first reported and discussed in 2017 MM summit, referred to
>> the topic "Provoking and fixing memory bottlenecks -Focused on the page 
>> allocator presentation" presented by Jesper.
>>
>> http://people.netfilter.org/hawk/presentations/MM-summit2017/MM-summit
>> 2017-JesperBrouer.pdf (slide 15/16)
>>
>> As you know, page allocator is too slow and has becomes a bottleneck
>> in high-speed network.
>> Jesper also showed some data in that presentation: with micro benchmark 
>> stresses order-0 fast path(per CPU pages), *32%* extra CPU cycles cost 
>> (143->97) comes from CONFIG_NUMA. 
>>
>> When I took a look at this issue, I reproduced this issue and got a
>> similar result to Jesper's. Furthermore, with the help from Jesper, 
>> the overhead is root caused and the real cause of this overhead comes
>> from an extra level of function calls such as zone_statistics() (*10%*,
>> nearly 1/3, including __inc_numa_state), policy_zonelist, get_task_policy(),
>> policy_nodemask and etc (perf profiling cpu cycles).  zone_statistics() 
>> is the biggest one introduced by CONFIG_NUMA in fast path that we can 
>> do something for optimizing page allocator. Plus, the overhead of 
>> zone_statistics() significantly increase with more and more cpu 
>> cores and nodes due to cache bouncing.
>>
>> Therefore, we submitted a patch before to mitigate the overhead of 
>> zone_statistics() by reducing global NUMA counter update frequency 
>> (enlarge threshold size, as suggested by Dave Hansen). I also would
>> like to have an implementation of a "_standard_node counter" for NUMA
>> stats, but I wonder how we can keep the performance gain at the
>> same time.
> 
> I understand all that. But we do have a way to put all that overhead
> away by disabling the stats altogether. I presume that CPU cycle
> sensitive workloads would simply use that option because the stats are
> quite limited in their usefulness anyway IMHO. So we are back to: Do
> normal workloads care all that much to have 3rd way to account for
> events? I haven't heard a sound argument for that.
> 

I'm not a fan of adding code that nobody(or 0.001%) cares.
We can't depend on that tunable interface too much, because our customers 
or even kernel hacker may not know that new added interface, or sometimes 
NUMA stats can't be disabled in their environments. That's the reason
why we spent time to do that optimization other than simply adding a runtime
configuration interface.

Furthermore, the code we optimized for is the core area of kernel that can
benefit most of kernel actions, more or less I think.

All right, let's think about it in another way, does a u64 percpu array per-node
for NUMA stats really make code too much complicated and hard to maintain?
I'm afraid not IMHO.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
