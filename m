Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id D48886B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 01:47:56 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id d4so8896266plr.8
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 22:47:56 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d13si12709873pfb.56.2017.12.19.22.47.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 22:47:55 -0800 (PST)
Subject: Re: [PATCH v2 2/5] mm: Extends local cpu counter vm_diff_nodestat
 from s8 to s16
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
 <1513665566-4465-3-git-send-email-kemi.wang@intel.com>
 <alpine.DEB.2.20.1712191004420.17324@nuc-kabylake>
 <20171219162029.GD2787@dhcp22.suse.cz>
 <alpine.DEB.2.20.1712191116370.18938@nuc-kabylake>
From: kemi <kemi.wang@intel.com>
Message-ID: <cc5c715f-2525-38e6-054e-500a95b12dff@intel.com>
Date: Wed, 20 Dec 2017 14:45:52 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1712191116370.18938@nuc-kabylake>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'12ae??20ae?JPY 01:21, Christopher Lameter wrote:
> On Tue, 19 Dec 2017, Michal Hocko wrote:
> 
>>> Well the reason for s8 was to keep the data structures small so that they
>>> fit in the higher level cpu caches. The large these structures become the
>>> more cachelines are used by the counters and the larger the performance
>>> influence on the code that should not be impacted by the overhead.
>>
>> I am not sure I understand. We usually do not access more counters in
>> the single code path (well, PGALLOC and NUMA counteres is more of an
>> exception). So it is rarely an advantage that the whole array is in the
>> same cache line. Besides that this is allocated by the percpu allocator
>> aligns to the type size rather than cache lines AFAICS.
> 
> I thought we are talking about NUMA counters here?
> 
> Regardless: A typical fault, system call or OS action will access multiple
> zone and node counters when allocating or freeing memory. Enlarging the
> fields will increase the number of cachelines touched.
> 

Yes, we add one more cache line footprint access theoretically.
But I don't think it would be a problem.
1) Not all the counters need to be accessed in fast path of page allocation,
the counters covered in a single cache line usually is enough for that, we
probably don't need to access one more cache line. I tend to agree Michal's
argument.
Besides, in some slow path in which code is protected by zone lock or lru lock,
access one more cache line would be a big problem since many other cache lines 
are also be accessed.

2) Enlarging vm_node_stat_diff from s8 to s16 gives an opportunity to keep
more number in local cpus that provides the possibility of reducing the global
counter update frequency. Thus, we can gain the benefit by reducing expensive 
cache bouncing.  

Well, if you still have some concerns, I can post some data for will-it-scale.page_fault1.
What the benchmark does is: it forks nr_cpu processes and then each
process does the following:
    1 mmap() 128M anonymous space;
    2 writes to each page there to trigger actual page allocation;
    3 munmap() it.
in a loop.
https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault1.c

Or you can provide some other benchmarks on which you want to see performance 
impact.

>> Maybe it used to be all different back then when the code has been added
>> but arguing about cache lines seems to be a bit problematic here. Maybe
>> you have some specific workloads which can prove me wrong?
> 
> Run a workload that does some page faults? Heavy allocation and freeing of
> memory?
> 
> Maybe that is no longer relevant since the number of the counters is
> large that the accesses are so sparse that each action pulls in a whole
> cacheline. That would be something we tried to avoid when implementing
> the differentials.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
