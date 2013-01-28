Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 8AA896B0002
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 10:58:34 -0500 (EST)
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
Subject: [PATCH] cfq: fix lock imbalance with failed allocations
Date: Mon, 28 Jan 2013 19:58:47 +0400
Message-Id: <1359388727-28147-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

From: Glauber Costa <glommer@parallels.com>

While stress-running very-small container scenarios with the Kernel
Memory Controller, I've run into a lockdep-detected lock imbalance in
cfq-iosched.c.

I'll apologize beforehand for not posting a backlog: I didn't anticipate
it would be so hard to reproduce, so I didn't save my serial output and
went directly on debugging. Turns out that it did not happen again in
more than 20 runs, making it a quite rare pattern.

But here is my analysis:

When we are in very low-memory situations, we will arrive at
cfq_find_alloc_queue and may not find a queue, having to resort to the
oom queue, in an rcu-locked condition:

  if (!cfqq || cfqq == &cfqd->oom_cfqq)
      [ ... ]

Next, we will release the rcu lock, and try to allocate a queue,
retrying if we succeed:

  rcu_read_unlock();
  spin_unlock_irq(cfqd->queue->queue_lock);
  new_cfqq = kmem_cache_alloc_node(cfq_pool,
                  gfp_mask | __GFP_ZERO,
                  cfqd->queue->node);
   spin_lock_irq(cfqd->queue->queue_lock);
   if (new_cfqq)
       goto retry;

We are unlocked at this point, but it should be fine, since we will
reacquire the rcu_read_lock when we retry.

Except of course, that we may not retry: the allocation may very well
fail and we'll keep on going through the flow:

The next branch is:

    if (cfqq) {
	[ ... ]
    } else
        cfqq = &cfqd->oom_cfqq;

And right before exiting, we'll issue rcu_read_unlock().

Being already unlocked, this is the likely source of our imbalance.
Since cfqq is either already NULL or made NULL in the first statement of
the outter branch, the only viable alternative here seems to be to
return the oom queue right away in case of allocation failure.

Please review the following patch and apply if you agree with my
analysis.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
---
 block/cfq-iosched.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index fb52df9..d52437a 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -3205,6 +3205,8 @@ retry:
 			spin_lock_irq(cfqd->queue->queue_lock);
 			if (new_cfqq)
 				goto retry;
+			else
+				return &cfqd->oom_cfqq;
 		} else {
 			cfqq = kmem_cache_alloc_node(cfq_pool,
 					gfp_mask | __GFP_ZERO,
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
