Message-ID: <3D2540CE.89A1688E@zip.com.au>
Date: Thu, 04 Jul 2002 23:46:38 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: vm lock contention reduction
References: <3D2530B9.8BC0C0AE@zip.com.au> <Pine.LNX.4.44.0207042237130.7465-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Thu, 4 Jul 2002, Andrew Morton wrote:
> > >
> > > Get away from this "minimum wait" thing, because it is WRONG.
> >
> > Well yes, we do want to batch work up.  And a crude way of doing that
> > is "each time 64 pages have come clean, wake up one waiter".
> 
> That would probably work, but we also need to be careful that we don't get
> into some strange situations (ie we have 50 waiters that all needed memory
> at the same time, and less than 50*64 pages that caused us to be in
> trouble, so we only wake up the 46 first waiters and the last 4 waiters
> get stuck until the next batch even though we now have _lots_ of pages
> free).
> 
> Dont't laugh - things like this has actually happened at times with some
> of our balancing work with HIGHMEM/NORMAL. Basically, the logic would go:
> "everybody who ends up having to wait for an allocation should free at
> least N pages", but then you would end up with 50*N pages total that the
> system thought it "needed" to free up, and that could be a big number that
> would cause the VM to want to free up stuff long after it was really done.

Well we'd certainly need to make direct caller-reclaims the normal
mode of operation.  Avoid context switches in the page allocator.

However it occurs to me that we could easily get in the situation
where a page allocator find a PageDirty or PageWriteback page on
the tail of the LRU and waits on it, but there are plenty of
reclaimable pages further along in the LRU.

In this situation it would better to just tag the page as "wait on
it next time around" and then just skip it.  This is basically what
the PageLaunder/BH_Launder logic was doing.  I think.  For a long
time it wasn't very effective because it wasn't able to wait on
page/buffers which were written by someone else.  Andrea finally
sorted that by setting BH_Launder in submit_bh.

All those deadlock problems have gone away now and we can
(re)implement this much more simply.

But what I don't like about it is that it's dumb.  The kernel ends
up doing these enormous list scans and not achieving very much, 
whereas we could achieve the same effect by doing a bit of page motion
at interrupt time.  It's a polled-versus-interrupt thing.

And right now, that dumbness is multiplied by the CPU count because
it happens under pagemap_lru_lock.  But with the bustup of that, at
least we can be scalably dumb ;)


> > Or
> > "as soon as the number of reclaimable pages exceeds zone->pages_min".
> > Some logic would also be needed to prevent new page allocators from
> > jumping the queue, of course.
> 
> Yeah, the unfairness is the thing that really can be nasty.
> 
> On the other hand, some unfairness is ok too - and can improve throughput.
> So jumping the queue is fine, you just must not be able to _consistently_
> jump the queue.
> 
> (In fact, jumping the queue is inevitable to some degree - not allowing
> any queue jumping at all would imply that any time _anybody_ starts
> waiting, every single allocation afterwards will have to wait until the
> waiter got woken up. Which we have actually tried before at times, but
> which causes really really bad behaviour and horribly bad "pausing")
> 
> You probably want the occasional allocator able to jump the queue, but the
> "big spenders" to be caught eventually. "Fairness" really doesn't mean
> that "everybody should wait equally much", it really means "people should
> wait roughly relative to how much as they 'spend' memory".

Right.  And that implies heuristics to divine which tasks are
heavy page allocators.  uh-oh.  But as a first-order approximation:
if a task is currently allocating pages from within generic_file_write(),
then whack it hard.


Here's PageLaunder-for-2.5.  (Not tested enough - don't apply ;))
It seems to help vmstat somewhat, but it still gets stuck in
shrink_cache->get_request_wait() a lot.

 include/linux/page-flags.h |    7 +++++++
 mm/filemap.c               |    1 +
 mm/vmscan.c                |    2 +-
 3 files changed, 9 insertions(+), 1 deletion(-)

--- 2.5.24/mm/vmscan.c~second-chance-throttle	Thu Jul  4 23:17:14 2002
+++ 2.5.24-akpm/mm/vmscan.c	Thu Jul  4 23:18:40 2002
@@ -443,7 +443,7 @@ shrink_cache(int nr_pages, zone_t *class
 		 * IO in progress? Leave it at the back of the list.
 		 */
 		if (unlikely(PageWriteback(page))) {
-			if (may_enter_fs) {
+			if (may_enter_fs && TestSetPageThrottle(page)) {
 				page_cache_get(page);
 				spin_unlock(&pagemap_lru_lock);
 				wait_on_page_writeback(page);
--- 2.5.24/include/linux/page-flags.h~second-chance-throttle	Thu Jul  4 23:18:35 2002
+++ 2.5.24-akpm/include/linux/page-flags.h	Thu Jul  4 23:20:02 2002
@@ -65,6 +65,7 @@
 #define PG_private		12	/* Has something at ->private */
 #define PG_writeback		13	/* Page is under writeback */
 #define PG_nosave		15	/* Used for system suspend/resume */
+#define PG_throttle		16	/* page allocator should throttle */
 
 /*
  * Global page accounting.  One instance per CPU.
@@ -216,6 +217,12 @@ extern void get_page_state(struct page_s
 #define ClearPageNosave(page)		clear_bit(PG_nosave, &(page)->flags)
 #define TestClearPageNosave(page)	test_and_clear_bit(PG_nosave, &(page)->flags)
 
+#define PageThrottle(page)	test_bit(PG_throttle, &(page)->flags)
+#define SetPageThrottle(page)	set_bit(PG_throttle, &(page)->flags)
+#define TestSetPageThrottle(page) test_and_set_bit(PG_throttle, &(page)->flags)
+#define ClearPageThrottle(page)	clear_bit(PG_throttle, &(page)->flags)
+#define TestClearPageThrottle(page) test_and_clear_bit(PG_throttle, &(page)->flags)
+
 /*
  * The PageSwapCache predicate doesn't use a PG_flag at this time,
  * but it may again do so one day.
--- 2.5.24/mm/filemap.c~second-chance-throttle	Thu Jul  4 23:20:08 2002
+++ 2.5.24-akpm/mm/filemap.c	Thu Jul  4 23:20:23 2002
@@ -682,6 +682,7 @@ void end_page_writeback(struct page *pag
 {
 	wait_queue_head_t *waitqueue = page_waitqueue(page);
 	smp_mb__before_clear_bit();
+	ClearPageThrottle(page);
 	if (!TestClearPageWriteback(page))
 		BUG();
 	smp_mb__after_clear_bit(); 

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
