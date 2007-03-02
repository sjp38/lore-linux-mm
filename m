Message-ID: <45E86BA0.50508@redhat.com>
Date: Fri, 02 Mar 2007 13:23:28 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <45E842F6.5010105@redhat.com> <20070302085838.bcf9099e.akpm@linux-foundation.org> <Pine.LNX.4.64.0703020919350.16719@schroedinger.engr.sgi.com> <20070302093501.34c6ef2a.akpm@linux-foundation.org> <45E8624E.2080001@redhat.com> <20070302100619.cec06d6a.akpm@linux-foundation.org> <Pine.LNX.4.64.0703021012170.17676@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0703021012170.17676@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 2 Mar 2007, Andrew Morton wrote:
> 
>>> One particular case is a 32GB system with a database that takes most
>>> of memory.  The amount of actually freeable page cache memory is in
>>> the hundreds of MB.
>> Where's the rest of the memory? tmpfs?  mlocked?  hugetlb?
> 
> The memory is likely in use but there is enough memory free in unmapped 
> clean pagecache pages so that we occasionally are able to free pages. Then 
> the app is reading more from disk replenishing that ...
> Thus we are forever cycling through the LRU lists moving pages between 
> the lists aging etc etc. Can lead to a livelock.

In this particular case, the system even has swap free.

The kernel just chooses not to use it until it has scanned
some memory, due to the way the swappiness algorithm works.

With 32 CPUs diving into the page reclaim simultaneously,
each trying to scan a fraction of memory, this is disastrous
for performance.  A 256GB system should be even worse.

>>> A third scenario is where a system has way more RAM than swap, and not
>>> a whole lot of freeable page cache.  In this case, the VM ends up
>>> spending WAY too much CPU time scanning and shuffling around essentially
>>> unswappable anonymous memory and tmpfs files.
>> Well we've allegedly fixed that, but it isn't going anywhere without
>> testing.
> 
> We have fixed the case in which we compile the kernel without swap. Then 
> anonymous pages behave like mlocked pages. Did we do more than that?

Not AFAIK.

I would like to see separate pageout selection queues
for anonymous/tmpfs and page cache backed pages.  That
way we can simply scan only that what we want to scan.

There are several ways available to balance pressure
between both sets of lists.

Splitting them out will also make it possible to do
proper use-once replacement for the page cache pages.
Ie. leaving the really active page cache pages on the
page cache active list, instead of deactivating them
because they're lower priority than anonymous pages.

That way we can do a backup without losting the page
cache working set.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
