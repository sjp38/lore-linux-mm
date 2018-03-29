Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF636B0005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 15:16:46 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id r1so4409684uae.6
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 12:16:46 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x12si2634471uac.249.2018.03.29.12.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 12:16:43 -0700 (PDT)
Subject: Re: [RFC PATCH v2 3/4] mm/rmqueue_bulk: alloc without touching
 individual page structure
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <20180320085452.24641-4-aaron.lu@intel.com>
 <12a89171-27b8-af4f-450e-41e5775683c5@suse.cz>
 <20180321150140.GA1838@intel.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <1df1e702-98bb-8785-206b-d0a44bcc0ec0@oracle.com>
Date: Thu, 29 Mar 2018 15:16:12 -0400
MIME-Version: 1.0
In-Reply-To: <20180321150140.GA1838@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On 03/21/2018 11:01 AM, Aaron Lu wrote:
>> I'm sorry, but I feel the added complexity here is simply too large to
>> justify the change. Especially if the motivation seems to be just the
>> microbenchmark. It would be better if this was motivated by a real
>> workload where zone lock contention was identified as the main issue,
>> and we would see the improvements on the workload. We could also e.g.
>> find out that the problem can be avoided at a different level.
> 
> One thing I'm aware of is there is some app that consumes a ton of
> memory and when it misbehaves or crashes, it takes some 10-20 minutes to
> have it exit(munmap() takes a long time to free all those consumed
> memory).
> 
> THP could help a lot, but it's beyond my understanding why they didn't
> use it.

One of our apps has the same issue with taking a long time to exit.  The 
time is in the kernel's munmap/exit path.

Also, Vlastimil, to your point about real workloads, I've seen 
zone->lock and lru_lock heavily contended in a decision support 
benchmark.  Setting the pcp list sizes artificially high with 
percpu_pagelist_fraction didn't make it go any faster, but given that 
Aaron and I have seen the contention shift to lru_lock in this case, I'm 
curious what will happen to the benchmark when both locks are no longer 
contended.  Will report back once this experiment is done.
