Received: from abertzale.sgn.cornell.edu (abertzale.sgn.cornell.edu [132.236.157.101])
	by cornell.edu (8.9.3p2/8.9.3) with ESMTP id MAA15054
	for <linux-mm@kvack.org>; Sun, 22 Jun 2003 12:46:49 -0400 (EDT)
Subject: kswapd consumes CPU
From: Koni <mhw6@cornell.edu>
Content-Type: text/plain
Message-Id: <1056300434.29768.206.camel@localhost.localdomain>
Mime-Version: 1.0
Date: 22 Jun 2003 12:47:15 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Folks,

I've observed kswapd reach some kind of singularity on one of my
systems, I wonder if someone can help me understand how to fix it/tweak
it or suggest a newer kernel version.

The system is a 2 CPU 1GHz Pentium III, 2G RAM, running a stock redhat
kernel "2.4.18-24.7.xsmp #1" -- distributed as an update for redhat-7.2

What happens:

When I use "dump" to do a level 0 dump of a large filesystem (100+ GB)
to tape, kswapd starts eating 99.9% of one CPU and dump's performance
begins to crawl. Nothing else is actively running, and nearly all 2G of
memory is allocated to cache. 

My guess is that dump is aggressively reading the disk and kswapd is
wasting time trying to intelligently figure out which page of cache to
forget to make space for the next block read by dump, but everything in
memory has roughly the same frequency and time of use,  generating a
worst case scenario for a sort or something for an lru or lfu policy.

If I run a program which allocates and writes to memory, a page at time,
gobbling up the fs cache, let it eat up nearly 2G, and kill it, kswapd
goes back to sleep, dump returns to its normal performance. 

Dump is not the only program which can cause this response from the
system, but it does so quite reliably. Unfortunately, there is no longer
a buffermem or freepages file in my /proc/sys/vm -- I don't understand
the files which are there or how to control the file caching of the
system. Can someone offer any advice? RTM comments welcome...

I don't know if my guess at the problem above is even close to the real
problem, but I'd prefer a stupid kswapd, which just defenestrates a page
a random rather than have a computational latency which exceeds the disk
latency. Perhaps this is just a bug in the kernel I am using. It's just
strange, the vm is effectively thrashing but the working set is probably
only a couple hundred kilobytes, less than one tenth one percent of the
RAM. 

Any comments or suggestions for trying different kernels (rmap? 2.5-mm?)
would be greatly appreciated.

Cheers,
Koni 

-- 
mhw6@cornell.edu
Koni (Mark Wright)
238B Emerson Hall - Cornell University
Solanaceae Genome Network	http://www.sgn.cornell.edu/
Lightlink Internet		http://www.lightlink.com/

"There are 3 kinds of people - those who can count and those who can't"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
