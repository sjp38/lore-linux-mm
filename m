Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 115036B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 09:55:18 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so523503eek.23
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 06:55:18 -0800 (PST)
Date: Thu, 19 Dec 2013 14:55:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/3] Change how we determine when to hand out THPs
Message-ID: <20131219145511.GO11295@suse.de>
References: <20131212180037.GA134240@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131212180037.GA134240@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org

On Thu, Dec 12, 2013 at 12:00:37PM -0600, Alex Thorlton wrote:
> This patch changes the way we decide whether or not to give out THPs to
> processes when they fault in pages.  The way things are right now,
> touching one byte in a 2M chunk where no pages have been faulted in
> results in a process being handed a 2M hugepage, which, in some cases,
> is undesirable.  The most common issue seems to arise when a process
> uses many cores to work on small portions of an allocated chunk of
> memory.
> 
> <SNIP>
> 
> As you can see there's a significant performance increase when running
> this test with THP off.  Here's a pointer to the test, for those who are
> interested:
> 
> http://oss.sgi.com/projects/memtests/thp_pthread.tar.gz
> 
> My proposed solution to the problem is to allow users to set a
> threshold at which THPs will be handed out.  The idea here is that, when
> a user faults in a page in an area where they would usually be handed a
> THP, we pull 512 pages off the free list, as we would with a regular
> THP, but we only fault in single pages from that chunk, until the user
> has faulted in enough pages to pass the threshold we've set. 

I have not read this thread yet so this is just me initial reaction to
just this part.

First, you say that the propose solution is to allow users to set a
threshold at which THPs will be handed out but you actually allocate all
the pages up front so it's not just that. There a few things in play

1. Deferred zeroing cost
2. Deferred THP set cost
3. Different TLB pressure
4. Alignment issues and NUMA

All are important. It is common for there to be fewer large TLB entries
than small ones. Workloads that sparsely reference data may suffer badly
when using large pages as the TLB gets trashed. Your workload could be
specifically testing for the TLB pressure (optimising point 3 above) in
which case the procesor used for benchmarking is a major factor and it's
not a universal win.

For example, your workload may optimise 3 but other workloads may suffer
because more faults are incurred until the threshold is reached, the
page tables must be walked to initialse the remaining pages and then the
THP setup and TLB flushed. 

Keep these details in mind when measuring your patches if at all possible.

Otherwise, on the face of it this is actually a similar proposal to "page
reservation" described one of the more important large page papers written
by Talluri (http://dl.acm.org/citation.cfm?id=195531). Right now you could
consider Linux to be reserving pages with a promotion threshold of 1 and
you're aiming to alter that threshold. Seems like a reasonable idea that
will eventually work out even though I have not seen the implementation yet.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
