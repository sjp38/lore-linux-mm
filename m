From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Date: Thu, 19 Apr 2001 19:32:51 +0100
Message-ID: <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com>
References: <l03130303b704a08b5dde@[192.168.239.105]> <7370000.987704745@baldur>
In-Reply-To: <7370000.987704745@baldur>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmc@austin.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001 13:25:45 -0500, you wrote:

>--On Thursday, April 19, 2001 15:03:28 +0100 Jonathan Morton 
><chromi@cyberspace.org> wrote:
>
>> My proposal is to introduce a better approximation to LRU in the VM,
>> solely for the purpose of determining the working set.  No alterations to
>> the page replacement policy are needed per se, except to honour the
>> "allowed working set" for each process as calculated below.
>>
>> (...)
>>
>> - Calculate the total physical quota for all processes as the sum of all
>> working sets (plus unswappable memory such as kernel, mlock(), plus a
>> small chunk to handle buffers, cache, etc.)
>> - If this total is within the physical memory of the system, the physical
>> quota for each process is the same as it's working set.  (fast common
>> case) - Otherwise, locate the process with the largest quota and remove
>> it from the total quota.  Add in "a few" pages to ensure this process
>> always has *some* memory to work in.  Repeat this step until the physical
>> quota is within physical memory or no processes remain.
>> - Any remaining processes after this step get their full working set as
>> physical quota.  Processes removed from the list get equal share of
>> (remaining physical memory, minus the chunk for buffers, cache and so on).
>
>It appears to me that the end result of all this is about the same as 
>suspending a few selected processes.  Under your algorithm the processes 
>that have no guaranteed working set make no real progress and the others 
>get to run.  It seems like a significant amount of additional overhead to 
>end up with the same result.  Additionally, those processes will be 
>generating large numbers of page faults as they fight over the scrap of 
>memory they have.  Using the suspension algorithm they'll be removed 
>entirely from running, this freeing up resources for the remaining 
>processes.

That's my suspicion too: The "strangled" processes eat up system
resources and still get nowhere (no win there: might as well suspend
them until they can run properly!) and you are wasting resources which
could be put to good use by other processes.

More to the point, though, what about the worst case, where every
process is thrashing? With my approach, some processes get suspended,
others run to completion freeing up resources for others. With this
approach, every process will still thrash indefinitely: perhaps the
effects on other processes will be reduced, but you don't actually get
out of the hole you're in!


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
