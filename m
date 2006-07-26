Message-ID: <44C702AF.7080705@yahoo.com.au>
Date: Wed, 26 Jul 2006 15:50:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: lockless pagecache followups
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Paul McKenney <paul.mckenney@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, James Bottomley <James.Bottomley@SteelEye.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I'm going to submit my lockless pagecache patch to -mm. So I should
clarify a few questions I didn't have time or thought capacity to
answer in my OLS presentation when they were asked:

- The numbers in the presentation were with !CONFIG_PREEMPT kernels.

- I believe the speculative reference retry mechanism *could* use a
   seqlock rather than PG_nonewrefs + pagecache recheck. So that was a
   good question :) However, this doesn't fix the "all pages have an
   unstable refcount" problem.

   Also, it means readers will contend cachelines with writers in
   different parts of the file, and does make a finer grained write
   side possibly more difficult in some parts. So I prefer the
   custom locking protocol.

- The flush_dcache_mmap_lock AFAIKS(?) is logically a different lock
   from the pagecache tree_lock. I guess it just uses tree_lock
   because it can. So that path should be sped up with the rwlock
   -> spinlock conversion, and reduced contention from find_get_page.

   If there are any problems in this area, I'd like to know what
   they are.

- Comments have been improved.

- I still can't see how the lockless gang lookup could deadlock. If the
   radix-tree lookup finds 0 candidates, find_get_pages will return. The
   only time it retries is when the radix-tree lookup has found at least
   1 page, and the first page found has been moved.

- One question I would have liked asked is "why not use RCU for
   freeing the pages", although maybe that's obvious ;) It would solve
   the unstable refcount, and the atomic_inc_not_zero problems, however
   I think RCU would be too much burden on the pagecache freeing side.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
