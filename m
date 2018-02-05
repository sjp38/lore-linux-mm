Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 360466B0007
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 17:17:21 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id h5so20803584pgv.21
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 14:17:21 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id e3si3744928pga.1.2018.02.05.14.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 14:17:20 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] __free_one_page: skip merge for order-0 page
 unless compaction is in progress
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180205053013.GB16980@intel.com> <20180205053139.GC16980@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57fd532f-8fb7-33c4-914a-fb816db47ea9@intel.com>
Date: Mon, 5 Feb 2018 14:17:18 -0800
MIME-Version: 1.0
In-Reply-To: <20180205053139.GC16980@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Daniel Jordan <daniel.m.jordan@oracle.com>

On 02/04/2018 09:31 PM, Aaron Lu wrote:
> Running will-it-scale/page_fault1 process mode workload on a 2 sockets
> Intel Skylake server showed severe lock contention of zone->lock, as
> high as about 80%(43% on allocation path and 38% on free path) CPU
> cycles are burnt spinning. With perf, the most time consuming part inside
> that lock on free path is cache missing on page structures, mostly on
> the to-be-freed page's buddy due to merging.
> 
> One way to avoid this overhead is not do any merging at all for order-0
> pages and leave the need for high order pages to compaction.

I think the RFC here is: we *know* this hurts high-order allocations and
Aaron demonstrated that it does make the latency worse.  But,
unexpectedly, it didn't totally crater them.

So, is the harm to large allocations worth the performance benefit
afforded to smaller ones by this patch?  How would we make a decision on
something like that?

If nothing else, this would make a nice companion topic to Daniel
Jordan's "lru_lock scalability" proposal for LSF/MM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
