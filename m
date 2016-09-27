Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA3276B02AC
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:53:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so32855012pfb.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:53:26 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id uf7si3049948pab.103.2016.09.27.07.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 07:53:25 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id my20so814526pab.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:53:25 -0700 (PDT)
Date: Wed, 28 Sep 2016 00:53:18 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160928005318.2f474a70@roar.ozlabs.ibm.com>
In-Reply-To: <20160927083104.GC2838@techsingularity.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
	<20160927083104.GC2838@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, 27 Sep 2016 09:31:04 +0100
Mel Gorman <mgorman@techsingularity.net> wrote:

> Hi Linus,
> 
> On Mon, Sep 26, 2016 at 01:58:00PM -0700, Linus Torvalds wrote:
> > So I've been doing some profiling of the git "make test" load, which
> > is interesting because it's just a lot of small scripts, and it shows
> > our fork/execve/exit costs.
> > 
> > Some of the top offenders are pretty understandable: we have long had
> > unmap_page_range() show up at the top on these loads, because the
> > zap_pte_range() function ends up touching each page as it unmaps
> > things (it does it to check whether it's an anonymous page, but then
> > also for the page map count update etc), and that's a disaster from a
> > cache standpoint. That single function is something between 3-4% of
> > CPU time, and the one instruction that accesses "struct page" the
> > first time is a large portion of that. Yes, a single instruction is
> > blamed for about 1% of all CPU time on a fork/exec/exit workload.
> >   
> 
> It was found at one point that the fault-around made these costs worse as
> there were simply more pages to tear down. However, this only applied to
> fork/exit microbenchmarks.  Matt Fleming prototyped an unreleased patch
> that tried to be clever about this but the cost was never worthwhile. A
> plain revert helped a microbenchmark but hurt workloads like the git
> testsuite which was shell intensive.
> 
> It got filed under "we're not fixing a fork/exit microbenchmark at the
> expense of "real" workloads like git checkout and git testsuite".
> 
> > <SNIP>
> >
> > #5 and #6 on my profile are user space (_int_malloc in glibc, and
> > do_lookup_x in the loader - I think user space should probably start
> > thinking more about doing static libraries for the really core basic
> > things, but whatever. Not a kernel issue.
> >   
> 
> Recent problems have been fixed with _int_malloc in glibc, particularly as it
> applies to threads but no fix springs to mind that might impact "make test".
> 
> > #7 is in the kernel again. And that one struck me as really odd. It's
> > "unlock_page()", while #9 is __wake_up_bit(). WTF? There's no IO in
> > this load, it's all cached, why do we use 3% of the time (1.7% and
> > 1.4% respectively) on unlocking a page. And why can't I see the
> > locking part?
> > 
> > It turns out that I *can* see the locking part, but it's pretty cheap.
> > It's inside of filemap_map_pages(), which does a trylock, and it shows
> > up as about 1/6th of the cost of that function. Still, it's much less
> > than the unlocking side. Why is unlocking so expensive?
> > 
> > Yeah, unlocking is expensive because of the nasty __wake_up_bit()
> > code. In fact, even inside "unlock_page()" itself, most of the costs
> > aren't even the atomic bit clearing (like you'd expect), it's the
> > inlined part of wake_up_bit(). Which does some really nasty crud.
> > 
> > Why is the page_waitqueue() handling so expensive? Let me count the ways:
> >   
> 
> page_waitqueue() has been a hazard for years. I think the last attempt to
> fix it was back in 2014 http://www.spinics.net/lists/linux-mm/msg73207.html
> 
> The patch is heavily derived from work by Nick Piggin who noticed the years
> before that. I think that was the last version I posted and the changelog
> includes profile data. I don't have an exact reference why it was rejected
> but a consistent piece of feedback was that it was very complex for the
> level of impact it had.

Huh, I was just wondering about this again the other day. Powerpc has
some interesting issues with atomic ops and barriers (not to mention
random cache misses that hurt everybody).

It actually wasn't for big Altix machines (at least not when I wrote it),
but it came from some effort to optimize page reclaim performance on an
opteron with a lot (back then) of cores per node.

And it's not only for scalability, it's a single threaded performance
optimisation as much as anything.

By the way I think that patch linked is taking the wrong approach. Better
to put all the complexity of maintaining the waiters bit into the sleep/wake
functions. The fastpath simply tests the bit in no less racy a manner than
the unlocked waitqueue_active() test. Really incomplete patch attached for
reference.

The part where we hack the wait code into maintaining the extra bit for us
is pretty mechanical and boring so long as it's under the waitqueue lock.

The more interesting is the ability to avoid the barrier between fastpath
clearing a bit and testing for waiters.

unlock():                        lock() (slowpath):
clear_bit(PG_locked)             set_bit(PG_waiter)
test_bit(PG_waiter)              test_bit(PG_locked)

If this was memory ops to different words, it would require smp_mb each
side.. Being the same word, can we avoid them? ISTR Linus you were worried
about stores being forwarded to loads before it is visible to the other CPU.
I think that should be okay because the stores will be ordered, and the load
can't move earlier than the store on the same CPU. Maybe I completely
misremember it.


Subject: [PATCH] blah

---
 include/linux/pagemap.h | 10 +++---
 mm/filemap.c            | 92 +++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 87 insertions(+), 15 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 66a1260..a536df9 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -479,10 +479,11 @@ static inline int wait_on_page_locked_killable(struct page *page)
 	return wait_on_page_bit_killable(compound_head(page), PG_locked);
 }
 
-extern wait_queue_head_t *page_waitqueue(struct page *page);
 static inline void wake_up_page(struct page *page, int bit)
 {
-	__wake_up_bit(page_waitqueue(page), &page->flags, bit);
+	if (!PageWaiters(page))
+		return;
+	wake_up_page_bit(page, bit);
 }
 
 /* 
@@ -494,8 +495,9 @@ static inline void wake_up_page(struct page *page, int bit)
  */
 static inline void wait_on_page_locked(struct page *page)
 {
-	if (PageLocked(page))
-		wait_on_page_bit(compound_head(page), PG_locked);
+	if (!PageLocked(page))
+		return 0;
+	wait_on_page_bit(compound_head(page), PG_locked);
 }
 
 /* 
diff --git a/mm/filemap.c b/mm/filemap.c
index 8a287df..09bca8a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -775,24 +775,98 @@ EXPORT_SYMBOL(__page_cache_alloc);
  * at a cost of "thundering herd" phenomena during rare hash
  * collisions.
  */
-wait_queue_head_t *page_waitqueue(struct page *page)
+static wait_queue_head_t *page_waitqueue(struct page *page)
 {
 	const struct zone *zone = page_zone(page);
 
 	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
 }
-EXPORT_SYMBOL(page_waitqueue);
+
+struct wait_page_key {
+	struct page *page;
+	int bit_nr;
+	int page_match;
+};
+
+struct wait_page_queue {
+	struct wait_page_key key;
+	wait_queue_t wait;
+};
+
+static int wake_page_function(wait_queue_t *wait, unsigned mode, int sync, void *arg)
+{
+	struct wait_page_queue *wait = container_of(wait, struct wait_page_queue, wait);
+	struct wait_page_key *key = arg;
+	int ret;
+
+	if (wait->key.page != key->page)
+	       return 0;
+	key->page_match = 1;
+	if (wait->key.bit_nr != key->bit_nr ||
+			test_bit(key->bit_nr, &key->page->flags))
+		return 0;
+
+	ret = try_to_wake_up(wait->wait.private, mode, sync);
+	if (ret)
+		list_del_init(&wait->task_list);
+	return ret;
+}
 
 void wait_on_page_bit(struct page *page, int bit_nr)
 {
-	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+	wait_queue_head_t *wq = page_waitqueue(page);
+	struct wait_page_queue wait;
 
-	if (test_bit(bit_nr, &page->flags))
-		__wait_on_bit(page_waitqueue(page), &wait, bit_wait_io,
-							TASK_UNINTERRUPTIBLE);
+	init_wait(&wait.wait);
+	wait.wait.func = wake_page_function;
+	wait.key.page = page;
+	wait.key.bit_nr = bit_nr;
+	/* wait.key.page_match unused */
+
+	wait.flags &= ~WQ_FLAG_EXCLUSIVE;
+
+again:
+	spin_lock_irq(&wq->lock);
+	if (unlikely(!test_bit(bit_nr, &page->flags))) {
+		spin_unlock_irq(&wq->lock);
+		return;
+	}
+
+	if (list_empty(&wait->task_list)) {
+		__add_wait_queue(wq, &wait);
+		if (!PageWaiters(page))
+			SetPageWaiters(page);
+	}
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	spin_unlock_irq(&wq->lock);
+
+	io_schedule();
+
+	if (!test_bit(bit_nr, &page->flags))
+		goto again;
+
+	finish_wait(wq, &wait);
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
+void wake_up_page_bit(struct page *page, int bit_nr)
+{
+	wait_queue_head_t *wq;
+	struct wait_page_key key;
+	unsigned long flags;
+
+	key.page = page;
+	key.bit_nr = bit_nr;
+	key.page_match = 0;
+
+	wq = page_waitqueue(page);
+	spin_lock_irqsave(&wq->lock, flags);
+	__wake_up_locked_key(wq, TASK_NORMAL, &key);
+	if (!waitqueue_active(wq) || !key.page_match)
+		ClearPageWaiters(page);
+	spin_unlock_irqrestore(&wq->lock, flags);
+}
+
 int wait_on_page_bit_killable(struct page *page, int bit_nr)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
@@ -852,7 +926,6 @@ void unlock_page(struct page *page)
 	page = compound_head(page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	clear_bit_unlock(PG_locked, &page->flags);
-	smp_mb__after_atomic();
 	wake_up_page(page, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
@@ -875,10 +948,7 @@ void end_page_writeback(struct page *page)
 		rotate_reclaimable_page(page);
 	}
 
-	if (!test_clear_page_writeback(page))
-		BUG();
-
-	smp_mb__after_atomic();
+	clear_bit_unlock(PG_writeback, &page->flags);
 	wake_up_page(page, PG_writeback);
 }
 EXPORT_SYMBOL(end_page_writeback);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
