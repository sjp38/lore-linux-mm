From: Mark_H_Johnson.RTS@raytheon.com
Message-ID: <852568CD.0057D4FC.00@raylex-gh01.eo.ray.com>
Date: Wed, 26 Apr 2000 11:03:58 -0500
Subject: Re: 2.3.x mem balancing
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, riel@nl.linux.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>


Some of what's been discussed here about NUMA has me concerned. You can't treat
a system with NUMA the same as a regular shared memory system. Let me take a
moment to describe some of the issues I have w/ NUMA & see if this changes the
way you interpret what needs to be done with memory balancing.... I'll let
someone else comment on the other issues.

NUMA - Non Uniform Memory Access means what it says - access to memory is not
uniform. To the user of a system [not the kernel developer], NUMA works similar
to cache memory. If the memory you access is "local" to where the processing is
taking place, the access is much faster than if the memory is "far away". The
difference in performance can be over 10:1 in terms of latency.

Let's use a specific shared memory vs. NUMA example to illustrate. Many years
ago, SGI produced the Challenge product line with a high speed backplane
connecting CPU's and shared memory (a traditional shared memory system). More
recently, SGI developed "cache coherent NUMA" as part of the Origin 2000 product
line. We have been considering the Origin platform and its successors as an
upgrade path for existing Challenge XL systems (24 CPU's, 2G shared memory).

To us, the main difference between a Challenge and Origin is that the Origin
performance range is much better than on the Challenge.  However, access to the
memory is equally fast across the entire memory range on the Challenge and "non
uniform" [faster & slower] on the Origin. Some reported numbers on the Origin
indicate a maximum latency of 200 nsec to 700 nsec with systems with 16 to 32
processors. More processors makes the effect somewhat worse with the "absolute
worst case" around 1 microsecond (1000 nsec). To me, these kind of numbers make
the cost of a cache miss staggering when compared to the cycle times of new
processors.

Our concern with NUMA basically is that the structure of our application must be
changed to account for that latency. NUMA works best when you can put the data
and the processing in the same area. However, our current implementation for
exchanging information between processes is through a large shared memory area.
That area will only be "close" to a few processors - the rest will be accessing
it remotely. Yes, the connections are very fast, but I worry about the latency
[and resulting execution stalls] much more. To us, it means that we must arrange
to have the information sent across those fast interfaces before we expect to
need it at the destination. Those extra "memory copies" are something we didn't
have to worry about before. I see similar problems in the kernel.

In the context of "memory balancing" - all processors and all memory is NOT
equal in a NUMA system. To get the best performance from the hardware, you
prefer to put "all" of the memory for each process into a single memory unit -
then run that process from a processor "near" that memory unit. This seemingly
simple principle has a lot of problems behind it. What about...
 - shared read only memory (e.g., libraries) [to clone or not?]
 - shared read/write memory [how to schedule work to be done when load >> "local
capacity"]
 - when memory is low, which pages should I remove?
 - when I start a new job, even when there is lots of free memory, where should
I load the job?
These are issues that need to be addressed if you expect to use this high cost
hardware effectively. Please don't implement a solution for virtual memory that
does not have the ability to scale to solve the problems with NUMA. Thanks.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


|--------+----------------------->
|        |          Andrea       |
|        |          Arcangeli    |
|        |          <andrea@suse.|
|        |          de>          |
|        |                       |
|        |          04/26/00     |
|        |          09:19 AM     |
|        |                       |
|--------+----------------------->
  >----------------------------------------------------------------------------|
  |                                                                            |
  |       To:     riel@nl.linux.org                                            |
  |       cc:     Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, |
  |       (bcc: Mark H Johnson/RTS/Raytheon/US)                                |
  |       Subject:     Re: 2.3.x mem balancing                                 |
  >----------------------------------------------------------------------------|



On Tue, 25 Apr 2000, Rik van Riel wrote:

>On Wed, 26 Apr 2000, Andrea Arcangeli wrote:
>> On Tue, 25 Apr 2000, Linus Torvalds wrote:
>>
>> >On Tue, 25 Apr 2000, Andrea Arcangeli wrote:
>> >>
>> >> The design I'm using is infact that each zone know about each other, each
>> >> zone have a free_pages and a classzone_free_pages. The additional
>> >> classzone_free_pages gives us the information about the free pages on the
>> >> classzone and it's also inclusve of the free_pages of all the lower zones.
>> >
>> >AND WHAT ABOUT SETUPS WHERE THERE ISNO INCLUSION?
>>
>> They're simpler. The classzone for them matches with the zone.
>
>It doesn't. Think NUMA.

NUMA is irrelevant. If there's no inclusion the classzone matches with the
zone.
[snip]





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
