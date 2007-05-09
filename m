Date: Wed, 9 May 2007 20:33:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] optimise unlock_page
In-Reply-To: <20070508225012.GF20174@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com>
References: <20070508113709.GA19294@wotan.suse.de> <20070508114003.GB19294@wotan.suse.de>
 <1178659827.14928.85.camel@localhost.localdomain> <20070508224124.GD20174@wotan.suse.de>
 <20070508225012.GF20174@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Nick Piggin wrote:
> On Wed, May 09, 2007 at 12:41:24AM +0200, Nick Piggin wrote:
> > On Wed, May 09, 2007 at 07:30:27AM +1000, Benjamin Herrenschmidt wrote:
> > > 
> > > Waking them all would fix it but at the risk of causing other
> > > problems... Maybe PG_waiters need to actually be a counter but if that
> > > is the case, then it complicates things even more.
> > 
> > It will wake up 1 exclusive waiter, but no limit on non exclusive waiters.
> > Hmm, but it won't wake up waiters behind the exclusive guy... maybe the
> > wake up code can check whether the waitqueue is still active after the
> > wakeup, and set PG_waiters again in that case?
> 
> Hm, I don't know if we can do that without a race either...
> 
> OTOH, waking all non exclusive waiters may not be a really bad idea.

Not good enough, I'm afraid.  It looks like Ben's right and you need
a count - and counts in the page struct are a lot harder to add than
page flags.

I've now played around with the hangs on my three 4CPU machines
(all of them in io_schedule below __lock_page, waiting on pages
which were neither PG_locked nor PG_waiters when I looked).

Seeing Ben's mail, I thought the answer would be just to remove
the "_exclusive" from your three prepare_to_wait_exclusive()s.
That helped, but it didn't eliminate the hangs.

After fiddling around with different ideas for some while, I came
to realize that the ClearPageWaiters (in very misleadingly named
__unlock_page) is hopeless.  It's just so easy for it to clear the
PG_waiters that a third task relies upon for wakeup (and which
cannot loop around to set it again, because it simply won't be
woken by unlock_page/__unlock_page without it already being set).

Below is the patch I've applied to see some tests actually running
with your patches, but it's just a joke: absurdly racy and
presumptuous in itself (the "3" stands for us and the cache and one
waiter; I deleted the neighbouring mb and comment, not because I
disagree, but because it's ridiculous to pay so much attention to
such unlikely races when there's much worse nearby).  Though I've
not checked: if I've got the counting wrong, then maybe all my
pages are left marked PG_waiters by now.

(I did imagine we could go back to prepare_to_wait_exclusive
once I'd put in the page_count test before ClearPageWaiters;
but apparently not, that still hung.)

My intention had been to apply the patches to what I tested before
with lmbench, to get comparative numbers; but I don't think this
is worth the time, it's too far from being a real solution.

I was puzzled as to how you came up with any performance numbers
yourself, when I could hardly boot.  I see you mentioned 2CPU G5,
I guess you need a CPU or two more; or maybe it's that you didn't
watch what happened as it booted, often those hangs recover later.

Hugh

--- a/mm/filemap.c	2007-05-08 20:17:31.000000000 +0100
+++ b/mm/filemap.c	2007-05-09 19:14:03.000000000 +0100
@@ -517,13 +517,8 @@ EXPORT_SYMBOL(wait_on_page_bit);
  */
 void fastcall __unlock_page(struct page *page)
 {
-	ClearPageWaiters(page);
- 	/*
-	 * The mb is necessary to enforce ordering between the clear_bit and
-	 * the read of the waitqueue (to avoid SMP races with a parallel
-	 * wait_on_page_locked()
-	 */
-	smp_mb__after_clear_bit();
+	if (page_count(page) <= 3 + page_has_buffers(page)+page_mapcount(page))
+		ClearPageWaiters(page);
 	wake_up_page(page, PG_locked);
 }
 EXPORT_SYMBOL(__unlock_page);
@@ -558,7 +553,7 @@ void fastcall __lock_page(struct page *p
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
 	do {
-		prepare_to_wait_exclusive(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
 		SetPageWaiters(page);
 		if (likely(PageLocked(page)))
 			sync_page(page);
@@ -577,7 +572,7 @@ void fastcall __lock_page_nosync(struct 
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
 	do {
-		prepare_to_wait_exclusive(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
 		SetPageWaiters(page);
 		if (likely(PageLocked(page)))
 			io_schedule();
@@ -591,7 +586,7 @@ void fastcall __wait_on_page_locked(stru
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
 	do {
-		prepare_to_wait_exclusive(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
 		SetPageWaiters(page);
 		if (likely(PageLocked(page)))
 			sync_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
