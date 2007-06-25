Message-ID: <467F6BC6.60209@yahoo.com.au>
Date: Mon, 25 Jun 2007 17:16:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] fsblock
References: <20070624014528.GA17609@wotan.suse.de> <p73lke95tfm.fsf@bingen.suse.de>
In-Reply-To: <p73lke95tfm.fsf@bingen.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> Nick Piggin <npiggin@suse.de> writes:
> 
>>- Structure packing. A page gets a number of buffer heads that are
>>  allocated in a linked list. fsblocks are allocated contiguously, so
>>  cacheline footprint is smaller in the above situation.
> 
> 
> It would be interesting to test if that makes a difference for 
> database benchmarks running over file systems. Databases
> eat a lot of cache so in theory any cache improvements
> in the kernel which often runs cache cold then should be beneficial. 
> 
> But I guess it would need at least ext2 to test; Minix is probably not
> good enough.

Yeah, you are right. ext2 would be cool to port as it would be
a reasonable platform for basic performance testing and comparisons.


> In general have you benchmarked the CPU overhead of old vs new code? 
> e.g. when we went to BIO scalability went up, but CPU costs
> of a single request also went up. It would be nice to not continue
> or better reverse that trend.

At the moment there are still a few silly things in the code, such
as always calling the insert_mapping indirect function (which is
the get_block equivalent). And it does a bit more RMWing than it
should still.

Also, it always goes to the pagecache radix-tree to find fsblocks,
wheras the buffer layer has a per-CPU cache front-end... so in
that regard, fsblock is really designed with lockless pagecache
in mind, where find_get_page is much faster even in the serial case
(though fsblock shouldn't exactly be slow with the current pagecache).

However, I don't think there are any fundamental performance
problems with fsblock. It even uses one less layer of locking to
do regular IO compared with buffer.c, so in theory it might even
have some advantage.

Single threaded performance of request submission is something I
will definitely try to keep optimal.


>>- Large block support. I can mount and run an 8K block size minix3 fs on
>>  my 4K page system and it didn't require anything special in the fs. We
>>  can go up to about 32MB blocks now, and gigabyte+ blocks would only
>>  require  one more bit in the fsblock flags. fsblock_superpage blocks
>>  are > PAGE_CACHE_SIZE, midpage ==, and subpage <.
> 
> 
> Can it be cleanly ifdefed or optimized away?

Yeah, it pretty well stays out of the way when using <= PAGE_CACHE_SIZE
size blocks, generally just a single test and branch of an already-used
cacheline. It can be optimised away completely by commenting out
#define BLOCK_SUPERPAGE_SUPPORT from fsblock.h.


> Unless the fragmentation
> problem is not solved it would seem rather pointless to me. Also I personally
> still think the right way to approach this is larger softpage size.

It does not suffer from a fragmentation problem. It will do scatter
gather IO if the pagecache of that block is not contiguous. My naming
may be a little confusing: fsblock_superpage (which is a function that
returns true if the given fsblock is larger than PAGE_CACHE_SIZE) is
just named as to whether the fsblock is larger than a page, rather than
having a connection to VM superpages.

Don't get me wrong, I think soft page size is a good idea for other
reasons as well (less page metadata and page operations), and that
8 or 16K would probably be a good sweet spot for today's x86 systems.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
