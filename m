Message-ID: <44505B59.1060308@yahoo.com.au>
Date: Thu, 27 Apr 2006 15:49:13 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Lockless page cache test results
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426111054.2b4f1736.akpm@osdl.org> <Pine.LNX.4.64.0604261144290.3701@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0604261144290.3701@g5.osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Jens Axboe <axboe@suse.de>, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:

> The question, of course, is whether the part that remains (the actual page 
> lookup) is important enough to matter, once it is part of a bigger chain 
> in a real application.

It can be. If one applies a rough estimate, reading only 512MB/s
from the same file from pagecache on each CPU simply cannot scale
past about 16 CPUs before it becomes tree_lock bound (depending
on what sort of lock transfer latency numbers one plugs into the
model).

> And the "reading from the same file in multiple threads" _is_ a real load. 
> It may sound stupid, but it would happen for any server that has a lot of 
> locality across clients (and that's very much true for web-servers, for 
> example).

I think something like postgresql, which uses a WAL via pagecache, things
that use shared memory (which is more important now that fork got lazier.


And it isn't even reading from the same file in multiple threads (although
that's obviously my poster child).

If one has F files in cache, and N CPUs each accessing a random file, the
number of files whos tree_lock a CPU last touched is F/N. The chance of a
CPU next hitting one of these is (F/N) / F = 1/N -> 0 pretty quickly.
include/ perhaps.

Now this won't be so bad as everyone piling up on a single cacheline, but
it will still hurt, especially on systems with fsb bus, broadcast snoop
(Opteron, POWER) etc.

Nor will it only be the read side which is significant. Consider a single
CPU reading a very large file, and each node's kswapd running on other CPUs
to reclaim pagecache (which needs to take the write lock).

> 
> That said, under most real loads, the page cach elookup is obviously 
> always going to be just a tiny tiny part (as shown by the fact that Jens 
> quotes 35 GB/s throughput - possible only because splice to /dev/null 
> doesn't need to actually ever even _touch_ the data).
> 
> The fact that it drops to "just" 3GB/s for four clients is somewhat 
> interesting, though, since that does put a limit on how well we can serve 
> the same file (of course, 3GB/s is still a lot faster than any modern 
> network will ever be able to push things around, but it's getting closer 
> to the possibilities for real hardware (ie IB over PCI-X should be able to 
> do about 1GB/s in "real life")
> 
> So the fact that basically just lookup/locking overhead can limit things 
> to 3GB/s is absolutely not totally uninteresting. Even if in practice 
> there are other limits that would probably hit us much earlier.
> 
> It would be interesting to see where doing gang-lookup moves the target, 
> but on the other hand, with smaller files (and small files are still 
> common), gang lookup isn't going to help as much.
> 
> Of course, with small files, the actual filename lookup is likely to be 
> the real limiter.

Although that's lockless so it scales. find_get_page will overtake it
at some point.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
