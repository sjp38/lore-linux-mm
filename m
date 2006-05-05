Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k45JPfXW026998
	for <linux-mm@kvack.org>; Fri, 5 May 2006 15:25:41 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k45JPeN9187254
	for <linux-mm@kvack.org>; Fri, 5 May 2006 13:25:40 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k45JPeX3001281
	for <linux-mm@kvack.org>; Fri, 5 May 2006 13:25:40 -0600
Message-ID: <445BA6B2.4030807@us.ibm.com>
Date: Fri, 05 May 2006 14:25:38 -0500
From: Brian Twichell <tbrian@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2][RFC] New version of shared page tables
References: <1146671004.24422.20.camel@wildcat.int.mccr.org>
In-Reply-To: <1146671004.24422.20.camel@wildcat.int.mccr.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, slpratt@us.ibm.com
List-ID: <linux-mm.kvack.org>

Hi,

We reevaluated shared pagetables with recent patches from Dave.  As with 
our previous evaluation, a database transaction-processing workload was 
used.  This time our evaluation focused on a 4-way x86-64 configuration 
with 8 GB of memory.

In the case that the bufferpools were in small pages, shared pagetables 
provided a 27% improvement in transaction throughput.  The performance 
increase is attributable to multiple factors.  First, pagetable memory 
consumption was reduced from 1.65 GB to 51 MB, freeing up 20% of the 
system's memory.  This memory was devoted to enlarging the database 
bufferpools, which allowed more database data to be cached in memory.  
The effect of this was to reduce the number of disk I/O's per 
transaction by 23%, which contributed to a similar reduction in the 
context switch rate.  A second major component of the performance 
improvement is reduced TLB and cache miss rates, due to the smaller 
pagetable footprint.  To try to isolate this benefit, we performed an 
experiment where pagetables were shared, but the database bufferpools 
were not enlarged.  In this configuration, shared pagetables provided a 
9% increase in database transaction throughput.  Analysis of processor 
performance counters revealed the following benefits from pagetable sharing:

- ITLB and DTLB page walks were reduced by 27% and 26%, respectively.
- L1 and L2 cache misses were reduced by 5%.  This is due to fewer 
pagetable entries crowding the caches.
- Front-side bus traffic was reduced approximately 10%.

When the bufferpools were in hugepages, shared pagetables provided a 3% 
increase in database transaction throughput.  Some of the underlying 
benefits of pagetable sharing were as follows:

- Pagetable memory consumption was reduced from 53 MB to 37 MB.
- ITLB and DTLB page walks were reduced by 28% and 10%, respectively.
- L1 and L2 cache misses were reduced by 2% and 6.5%, respectively.
- Front-side bus traffic was reduced by approximately 4%.

The database transaction throughput achieved using small pages with 
shared pagetables (with bufferpools enlarged) was within 3% of the 
transaction throughput achieved using hugepages without shared 
pagetables.  Thus shared pagetables provided nearly all the benefit of 
hugepages, without the requirement of having to deal with limitations of 
hugepages.  We believe this would be a significant benefit to customers 
running these types of workloads.

We also measured the benefit of shared pagetables on our larger setups.  
On our 4-way x86-64 setup with 64 GB memory, using small pages for the 
bufferpools, shared pagetables provided a 33% increase in transaction 
throughput.  Using hugepages for the bufferpools, shared pagetables 
provided a 3% increase.  Performance with small pages and shared 
pagetables was within 4% of the performance using hugepages without 
shared pagetables.

On our ppc64 setups we used both Oracle and DB2 to evaluate the benefit 
of shared pagetables.  When database bufferpools were in small pages, 
shared pagetables provided an increase in database transaction 
throughput in the range of 60-65%, while in the hugepage case the 
improvement was up to 2.4%.

We thank Kshitij Doshi and Ken Chen from Intel for their assistance in 
analyzing the x86-64 data.

Cheers,
Brian


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
