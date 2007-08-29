Subject: speeding up swapoff
From: Daniel Drake <ddrake@brontes3d.com>
Content-Type: text/plain
Date: Wed, 29 Aug 2007 09:29:32 -0400
Message-Id: <1188394172.22156.67.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

I've spent some time trying to understand why swapoff is such a slow
operation.

My experiments show that when there is not much free physical memory,
swapoff moves pages out of swap at a rate of approximately 5mb/sec. When
there is a lot of free physical memory, it is faster but still a slow
CPU-intensive operation, purging swap at about 20mb/sec.

I've read into the swap code and I have some understanding that this is
an expensive operation (and has to be). This page was very helpful and
also agrees:
http://kernel.org/doc/gorman/html/understand/understand014.html

After reading that, I have an idea for a possible optimization. If we
were to create a system call to disable ALL swap partitions (or modify
the existing one to accept NULL for that purpose), could this process be
signficantly less complex?

I'm thinking we could do something like this:
 1. Prevent any more pages from being swapped out from this point
 2. Iterate through all process page tables, paging all swapped
    pages back into physical memory and updating PTEs
 3. Clear all swap tables and caches

Due to only iterating through process page tables once, does this sound
like it would increase performance non-trivially? Is it feasible?

I'm happy to spend a few more hours looking into implementing this but
would greatly appreciate any advice from those in-the-know on if my
ideas are broken to start with...

Thanks!
-- 
Daniel Drake
Brontes Technologies, A 3M Company
http://www.brontes3d.com/opensource

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
