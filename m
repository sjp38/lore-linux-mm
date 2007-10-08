Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l98H2Skj018394
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 03:02:28 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l98H636I104866
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 03:06:03 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l98Gxax9007607
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 02:59:36 +1000
Message-ID: <470A6289.8000307@linux.vnet.ibm.com>
Date: Mon, 08 Oct 2007 22:32:01 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: VMA lookup with RCU
References: <46F01289.7040106@linux.vnet.ibm.com> <470509F5.4010902@linux.vnet.ibm.com> <1191518486.5574.24.camel@lappy> <200710071747.23252.nickpiggin@yahoo.com.au>
In-Reply-To: <200710071747.23252.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Peter Zijlstra <peterz@infradead.org>, Alexis Bruemmer <alexisb@us.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, Max Asbock <amax@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Bharata B Rao <bharata@in.ibm.com>
List-ID: <linux-mm.kvack.org>


Nick Piggin wrote:
> On Friday 05 October 2007 03:21, Peter Zijlstra wrote:
>> On Thu, 2007-10-04 at 21:12 +0530, Vaidyanathan Srinivasan wrote:
> 
>>> Per CPU last vma cache:  Currently we have the last vma referenced in a
>>> one entry cache in mm_struct.  Can we have this cache per CPU or per node
>>> so that a multi threaded application can have node/cpu local cache of
>>> last vma referenced.  This may reduce btree/rbtree traversal.  Let the
>>> hardware cache maintain the corresponding VMA object and its coherency.
>>>
>>> Please let me know your comment and thoughts.
>> Nick Piggin (and I think Eric Dumazet) had nice patches for this. I
>> think they were posted in the private futex thread.
> 
> All they need is testing and some results to show they help. I actually
> don't really have a realistic workload where vma lookup contention is
> a problem, since the malloc fixes and private futexes went in.

Hi Nick,

Just point me to the patch.  I will run them thru ebizzy with and without
oprofile on a large system and post the data.

> 
> Actually -- there is one thing, apparently oprofile does lots of find_vmas,
> which trashes the vma cache. Either it should have its own cache, or at
> least use a "nontemporal" lookup.
> 
> What I implemented was a per-thread cache. Per-CPU I guess would be
> equally possible and might be preferable in some cases (although worse
> in others). Still, the per-thread cache should be fine for basic performance
> testing.

Per-thread last vma cache is a good idea... much simpler to implement than
per CPU or per node cache I guess.  But still invalidating the caches my be
a slow path.  Lets check it out.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
