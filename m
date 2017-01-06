Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32B446B025E
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 15:34:45 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a190so1493641320pgc.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 12:34:45 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u75si80560066pgc.144.2017.01.06.12.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 12:34:44 -0800 (PST)
Message-ID: <1483734874.2833.25.camel@linux.intel.com>
Subject: [LSF/MM TOPIC] Optimizations for swap sub-system
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Fri, 06 Jan 2017 12:34:34 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Shaohua Li <shli@fb.com>, "Huang, Ying" <ying.huang@intel.com>

We have some swap related topics we'll like to discuss
at mm summit. A We'll like to get everyone's opinionsA 
to guide future swap related work that we have in mind.

1. DAX swap -A 
For swap space on very fast solid state block devices, the swappedA 
pages can be accessed directly using DAX mechanism withoutA 
incurring the overhead to allocate a page in RAM and swap themA 
in.A A The direct access swap space should speed things up inA 
many cases.A A One remaining issue is if the pages are accessedA 
frequently, we may still need to promote them back to RAM.A A Wea??llA 
like to discuss several possible approaches and their pros andA 
cons to see what is the most viable:A 
A  (i) Using performance monitoring unit to measure the access frequencyA 
A  (ii) Extend the LRU list to such DAX swap spaceA 
A  (iii) A page scanning daemon

2. Improving Swap Read Ahead -A 
The current swap read ahead is done in the same order that theA 
pages are swapped out.A A However, the order of page access mayA 
have no relations with the order that the pages are accessed,A 
especially for sequential memory access.A A Wea??ll like to discussA 
detection mechanism for sequential memory access and using a VMAA 
based read ahead for such case.

3. Improving Swap out path -A 
Optimization of the swap out paths by reducing the contentionsA 
on the locks on swap device, radix tree by introducing finerA 
grained lock on cluster, splitting up the radix tree and gettingA 
swap pages and releasing swap pages in batches. A We'll like to
address any issues if our proposed patchset has not been
merged by the time of mm summit.

4. Huge Page Swapping -A 
Now, the transparent huge page (THP) will be split before swappingA 
out and collapsed back to THP after swapping in.A A This will wasteA 
CPU cycles and reduce effectiveness (utilization) of THP.A A To resolveA 
these issue, we propose to avoid splitting THP during swap out/in.A A 
At the same time, this give us the opportunity to further optimizeA 
the performance of THP swap out/in with large read/write size andA 
reduced TLB flushing etc. to take advantage of the new high speedA 
storage device.

Thanks.

Ying Huang & Tim Chen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
