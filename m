Subject: Re: [RFC] fsblock
References: <20070624014528.GA17609@wotan.suse.de>
From: Andi Kleen <andi@firstfloor.org>
Date: 24 Jun 2007 16:16:29 +0200
In-Reply-To: <20070624014528.GA17609@wotan.suse.de>
Message-ID: <p73lke95tfm.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:
> 
> - Structure packing. A page gets a number of buffer heads that are
>   allocated in a linked list. fsblocks are allocated contiguously, so
>   cacheline footprint is smaller in the above situation.

It would be interesting to test if that makes a difference for 
database benchmarks running over file systems. Databases
eat a lot of cache so in theory any cache improvements
in the kernel which often runs cache cold then should be beneficial. 

But I guess it would need at least ext2 to test; Minix is probably not
good enough.

In general have you benchmarked the CPU overhead of old vs new code? 
e.g. when we went to BIO scalability went up, but CPU costs
of a single request also went up. It would be nice to not continue
or better reverse that trend.

> - Large block support. I can mount and run an 8K block size minix3 fs on
>   my 4K page system and it didn't require anything special in the fs. We
>   can go up to about 32MB blocks now, and gigabyte+ blocks would only
>   require  one more bit in the fsblock flags. fsblock_superpage blocks
>   are > PAGE_CACHE_SIZE, midpage ==, and subpage <.

Can it be cleanly ifdefed or optimized away?  Unless the fragmentation
problem is not solved it would seem rather pointless to me. Also I personally
still think the right way to approach this is larger softpage size.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
