Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBNMxlWC028409
	for <linux-mm@kvack.org>; Sun, 23 Dec 2007 17:59:47 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBNMxlfq122878
	for <linux-mm@kvack.org>; Sun, 23 Dec 2007 15:59:47 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBNMxlB3008962
	for <linux-mm@kvack.org>; Sun, 23 Dec 2007 15:59:47 -0700
Message-ID: <476EE858.202@linux.vnet.ibm.com>
Date: Mon, 24 Dec 2007 04:29:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [patch 00/20] VM pageout scalability improvements
References: <20071218211539.250334036@redhat.com> <476D7334.4010301@linux.vnet.ibm.com> <20071222192119.030f32d5@bree.surriel.com>
In-Reply-To: <20071222192119.030f32d5@bree.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Sun, 23 Dec 2007 01:57:32 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> Rik van Riel wrote:
>>> On large memory systems, the VM can spend way too much time scanning
>>> through pages that it cannot (or should not) evict from memory. Not
>>> only does it use up CPU time, but it also provokes lock contention
>>> and can leave large systems under memory presure in a catatonic state.
>> I remember you mentioning that by large memory systems you mean systems
>> with at-least 128GB, does this definition still hold?
> 
> It depends on the workload.  Certain test cases can wedge the
> VM with as little as 16GB of RAM.  Other workloads cause trouble
> at 32 or 64GB, with the system sometimes hanging for several
> minutes, all the CPUs in the pageout code and no actual swap IO.
> 

Interesting, I have not run into it so far. But I have smaller machines,
typically 4-8GB.

> On systems of 128GB and more, we have seen systems hang in the
> pageout code overnight, without deciding what to swap out.
> 
>>> This patch series improves VM scalability by:
>>>
>>> 1) making the locking a little more scalable
>>>
>>> 2) putting filesystem backed, swap backed and non-reclaimable pages
>>>    onto their own LRUs, so the system only scans the pages that it
>>>    can/should evict from memory
>>>
>>> 3) switching to SEQ replacement for the anonymous LRUs, so the
>>>    number of pages that need to be scanned when the system
>>>    starts swapping is bound to a reasonable number
>>>
>>> The noreclaim patches come verbatim from Lee Schermerhorn and
>>> Nick Piggin.  I have not taken a detailed look at them yet and
>>> all I have done is fix the rejects against the latest -mm kernel.
>> Is there a consolidate patch available, it makes it easier to test.
> 
> I will make a big patch available with the next version.  I have
> to upgrade my patch set to newer noreclaim patches from Lee and
> add a few small cleanups elsewhere.
> 

That would be nice. I'll try and help out by testing the patches and
running them

>>> I am posting this series now because I would like to get more
>>> feedback, while I am studying and improving the noreclaim patches
>>> myself.
>> What kind of tests show the problem? I'll try and review and test the code.
> 
> The easiest test possible simply allocates a ton of memory and
> then touches it all.  Enough memory that the system needs to go
> into swap.
> 
> Once memory is full, you will see the VM scan like mad, with a
> big CPU spike (clearing the referenced bits off all pages) before
> it starts swapping out anything.  That big CPU spike should be
> gone or greatly reduced with my patches.
> 
> On really huge systems, that big CPU spike can be enough for one
> CPU to spend so much time in the VM that all the other CPUs join
> it, and the system goes under in a big lock contention fest.
> 
> Besides, even single threadedly clearing the referenced bits on
> 1TB worth of memory can't result in acceptable latencies :)
> 
> In the real world, users with large JVMs on their servers, which
> sometimes go a little into swap, can trigger this system.  All of
> the CPUs end up scanning the active list, and all pages have the
> referenced bit set.  Even if the system eventually recovers, it
> might as well have been dead.
> 
> Going into swap a little should only take a little bit of time.
> 

Very fascinating, so we need to scale better with larger memory.
I suspect part of the answer will lie with using large/huge pages.



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
