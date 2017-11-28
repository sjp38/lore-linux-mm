Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5DCD6B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 17:54:25 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k126so546133wmd.5
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 14:54:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z13si542635edl.354.2017.11.28.14.54.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 14:54:24 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
 <9b4d5612-24eb-4bea-7164-49e42dc76f30@suse.cz>
 <87o9nmjlfv.fsf@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <de8e028e-a90d-548f-4c66-96b4b32dcc79@suse.cz>
Date: Tue, 28 Nov 2017 23:52:56 +0100
MIME-Version: 1.0
In-Reply-To: <87o9nmjlfv.fsf@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Kemi Wang <kemi.wang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 11/28/2017 07:40 PM, Andi Kleen wrote:
> Vlastimil Babka <vbabka@suse.cz> writes:
>>
>> I'm worried about the "for_each_possible..." approach here and elsewhere
>> in the patch as it can be rather excessive compared to the online number
>> of cpus (we've seen BIOSes report large numbers of possible CPU's). IIRC
> 
> Even if they report a few hundred extra reading some more shared cache lines
> is very cheap. The prefetcher usually quickly figures out such a pattern
> and reads it all in parallel.

Hmm, prefetcher AFAIK works within page bounday and here IIUC we are
iterating between pcpu areas in the inner loop, which are futher apart
than that? And their number may exhausts the simultaneous prefetch
stream. And the outer loops repeats that for each counter. We might be
either evicting quite a bit of cache, or perhaps the distance between
pcpu areas is such that it will cause collision misses, so we'll be
always cache cold and not even benefit from multiple counters fitting
into single cache line.

> I doubt it will be noticeable, especially not in a slow path
> like reading something from proc/sys.
> 
>> the general approach with vmstat is to query just online cpu's / nodes,
>> and if they go offline, transfer their accumulated stats to some other
>> "victim"?
> 
> That's very complicated, and unlikely to be worth it.

vm_events_fold_cpu() doesn't look that complicated

> 
> -Andi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
