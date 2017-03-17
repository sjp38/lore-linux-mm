Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B63C6B0389
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 04:52:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c87so62410521pfl.6
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 01:52:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d71sor1809708pgc.5.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Mar 2017 01:52:55 -0700 (PDT)
Date: Fri, 17 Mar 2017 01:52:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] mm, swap: Try kzalloc before vzalloc
In-Reply-To: <20170317064635.12792-4-ying.huang@intel.com>
Message-ID: <alpine.DEB.2.10.1703170147030.15347@chino.kir.corp.google.com>
References: <20170317064635.12792-1-ying.huang@intel.com> <20170317064635.12792-4-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?Q?J=C3=A9r=C3=B4me_Glisse?= <jglisse@redhat.com>, Aaron Lu <aaron.lu@intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 17 Mar 2017, Huang, Ying wrote:

> From: Huang Ying <ying.huang@intel.com>
> 
> Now vzalloc() is used in swap code to allocate various data
> structures, such as swap cache, swap slots cache, cluster info, etc.
> Because the size may be too large on some system, so that normal
> kzalloc() may fail.  But using kzalloc() has some advantages, for
> example, less memory fragmentation, less TLB pressure, etc.  So change
> the data structure allocation in swap code to try to use kzalloc()
> firstly, and fallback to vzalloc() if kzalloc() failed.
> 

I'm concerned about preferring kzalloc() with __GFP_RECLAIM since the page 
allocator will try to do memory compaction for high-order allocations when 
the vzalloc() would have succeeded immediately.  Do we necessarily want to 
spend time doing memory compaction and direct reclaim for contiguous 
memory if it's not needed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
