Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C82366B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 00:58:12 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id g13so2287254pln.20
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 21:58:12 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w15si2469997pgc.761.2017.11.29.21.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 21:58:11 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
 <20171129121740.f6drkbktc43l5ib6@dhcp22.suse.cz>
From: kemi <kemi.wang@intel.com>
Message-ID: <4b840074-cb5f-3c10-d65b-916bc02fb1ee@intel.com>
Date: Thu, 30 Nov 2017 13:56:13 +0800
MIME-Version: 1.0
In-Reply-To: <20171129121740.f6drkbktc43l5ib6@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'11ae??29ae?JPY 20:17, Michal Hocko wrote:
> On Tue 28-11-17 14:00:23, Kemi Wang wrote:
>> The existed implementation of NUMA counters is per logical CPU along with
>> zone->vm_numa_stat[] separated by zone, plus a global numa counter array
>> vm_numa_stat[]. However, unlike the other vmstat counters, numa stats don't
>> effect system's decision and are only read from /proc and /sys, it is a
>> slow path operation and likely tolerate higher overhead. Additionally,
>> usually nodes only have a single zone, except for node 0. And there isn't
>> really any use where you need these hits counts separated by zone.
>>
>> Therefore, we can migrate the implementation of numa stats from per-zone to
>> per-node, and get rid of these global numa counters. It's good enough to
>> keep everything in a per cpu ptr of type u64, and sum them up when need, as
>> suggested by Andi Kleen. That's helpful for code cleanup and enhancement
>> (e.g. save more than 130+ lines code).
> 
> I agree. Having these stats per zone is a bit of overcomplication. The
> only consumer is /proc/zoneinfo and I would argue this doesn't justify
> the additional complexity. Who does really need to know per zone broken
> out numbers?
> 
> Anyway, I haven't checked your implementation too deeply but why don't
> you simply define static percpu array for each numa node?

To be honest, there are another two ways I can think of listed below. but I don't
think they are simpler than my current implementation. Maybe you have better idea.

static u64 __percpu vm_stat_numa[num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS];
But it's not correct.

Or we can add an u64 percpu array with size of NR_VM_NUMA_STAT_ITEMS in struct pglist_data.

My current implementation is quite straightforward by combining all of local counters
together, only one percpu array with size of num_possible_nodes()*NR_VM_NUMA_STAT_ITEMS 
is enough for that.
		
> [...]
>> +extern u64 __percpu *vm_numa_stat;
> [...]
>> +#ifdef CONFIG_NUMA
>> +	size = sizeof(u64) * num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS;
>> +	align = __alignof__(u64[num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS]);
>> +	vm_numa_stat = (u64 __percpu *)__alloc_percpu(size, align);
>> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
