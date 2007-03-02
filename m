Message-ID: <45E8624E.2080001@redhat.com>
Date: Fri, 02 Mar 2007 12:43:42 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie>	<20070301160915.6da876c5.akpm@linux-foundation.org>	<45E842F6.5010105@redhat.com>	<20070302085838.bcf9099e.akpm@linux-foundation.org>	<Pine.LNX.4.64.0703020919350.16719@schroedinger.engr.sgi.com> <20070302093501.34c6ef2a.akpm@linux-foundation.org>
In-Reply-To: <20070302093501.34c6ef2a.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 2 Mar 2007 09:23:49 -0800 (PST) Christoph Lameter <clameter@engr.sgi.com> wrote:
> 
>> On Fri, 2 Mar 2007, Andrew Morton wrote:
>>
>>>> Linux is *not* happy on 256GB systems.  Even on some 32GB systems
>>>> the swappiness setting *needs* to be tweaked before Linux will even
>>>> run in a reasonable way.
>>> Please send testcases.
>> It is not happy if you put 256GB into one zone.
> 
> Oh come on.  What's the workload?  What happens?  system time?  user time?
> kernel profiles?

I can't share all the details, since a lot of the problems are customer
workloads.

One particular case is a 32GB system with a database that takes most
of memory.  The amount of actually freeable page cache memory is in
the hundreds of MB.   With swappiness at the default level of 60, kswapd
ends up eating most of a CPU, and other tasks also dive into the pageout
code.  Even with swappiness as high as 98, that system still has
problems with the CPU use in the pageout code!

Another typical problem is that people want to back up their database
servers.  During the backup, parts of the working set get evicted from
the VM and performance is horrible.

A third scenario is where a system has way more RAM than swap, and not
a whole lot of freeable page cache.  In this case, the VM ends up
spending WAY too much CPU time scanning and shuffling around essentially
unswappable anonymous memory and tmpfs files.

I have briefly characterized some of these working sets on:

http://linux-mm.org/ProblemWorkloads

One thing I do not yet have are easily runnable test cases.  I know
the problems that happen because customers run into them, but it is
not as easy to reproduce on test systems...

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
