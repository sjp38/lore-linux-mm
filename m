Date: Wed, 15 Aug 2001 13:45:09 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.21.0108152049100.973-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[ cc'd to linux-mm and Marcelo, as this was kind of interesting ]

On Wed, 15 Aug 2001, Hugh Dickins wrote:
>
> Exactly as you predict.  A batch of the printks at the usual point,
> then it recovers and proceeds happily on its way.  Same again each
> time (except first time clean as usual).  I should be pleased, but
> I feel dissatisfied.  I guess it's right for create_buffers() to
> try harder, but I'm surprised it got into that state at all.
> I'll try to understand it better.

Ok, then I understand the schenario.

This could _possibly_ be triggered by other things than swapoff too, but
it would probably be much harder. What happens is:

 - we have tons of free memory - so much that both inactive_shortage() and
   free_shortage() are happy as clams, and kswapd or anybody else won't
   ever try to balance out the fact that we have unusually low counts of
   inactive data while having a high "inactive_target".

   The only strange thing is that _despite_ having tons of memory, we are
   really short on inactive pages, because swapoff() really ate them all
   up.

   This part is fine. We're doing the right thing - if we have tons of
   memory, we shouldn't care. I'm just saying that it's unusual to be both
   short on some things and extremely well off on others.

 - Because we have lots of memory, we can easily allocate that free memory
   to user pages etc, and nobody will start checking the VM balance
   because the allocations themselves work out really well and never even
   feel that they have to wake up kswapd. So we quickly deplete the free
   pages that used to hide the imbalance.

   Now we're in a situation where we're low on memory, but we're _also_ in
   the unusual situation that we have almost no inactive pages, while at
   the same time having a high inactive target.

So fairly suddenly _everybody_ goes from "oh, we have tons of memory" to
"uhhuh, we're several thousand pages short of our inactive target".

Now, this is really not much of a problem normally. because normal
applications will just loop on try_to_free_pages() until they're happy
again. So for normal allocations, the worst that can happen is that
because of the sudden shift in balance, we'll get a lot of queue activity.
Not a big deal - in fact that's exactly what we want.

Not a big deal _except_ for GFP_NOFS (ie buffer) allocations and in
particular kswapd. Because those are special-cased, and return NULL
earlier (GFP_NOFS because __GFP_FS isn't set, and kswapd because
PF_MEMALLOC is set).

Which is _exactly_ why refill_freelist() will do it's extra song-and-dance
number.

And guess what? create_buffers() for the "struct page" case doesn't do
that. It just yields and hopes the situation goes away. And as that is the
thing that we want to use for writing out swap etc, we get the situation
where one of the most probable yielders in this case is kswapd. And the
situation never improves, surprise surprise. Most everybody will be in
PF_MEMALLOC and not make any progress.

This is why when you do the full song-and-dance in the create_buffers()
case too, the problem just goes away. Instead of waiting for things to
improve, we will actively try to improve them, and sure as hell, we have
lots of pages that we can evict if we just try. So instead of getting a
comatose machine, you get one that says a few times "I had trouble getting
memory", and then it continues happily.

Case solved.

Moral of the story: don't just hope things will improve. Do something
about it.

Other moral of the story: this "let's hope things improve" problem was
probably hidden by previously having refill_inactive() scan forever until
it hit its target. Or rather - I suspect that code was written exactly
because Rik or somebody _did_ hit this, and made refill_inactive() work
that way to make up for the simple fact that fs/buffer.c was broken.

And finally: It's not a good idea to try to make the VM make up for broken
kernel code.

Btw, the whole comment around the fs/buffer.c braindamage is telling:

        /* We're _really_ low on memory. Now we just
         * wait for old buffer heads to become free due to
         * finishing IO.  Since this is an async request and
         * the reserve list is empty, we're sure there are
         * async buffer heads in use.
         */
        run_task_queue(&tq_disk);

        current->policy |= SCHED_YIELD;
        __set_current_state(TASK_RUNNING);
        schedule();
        goto try_again;

It used to be correct, say about a few years ago. It's simply not true any
more: yes, we obviously have async buffer heads in use, but they don't
just free up when IO completes. They are the buffer heads that we've
allocated to a "struct page" in order to push it out - and they'll be
free'd only by page_launder(). Not by IO completion.

In short: we do have freeable memory. But it won't just come back to us.

So I'd suggest:
 - the one I already suggested: instead of just yielding, do the same
   thing refill_freelist() does.
 - also apply the one-liner patch which Marcelo already suggested some
   time ago, to just make 0-order allocations of GFP_NOFS loop inside the
   memory allocator until happy, because they _will_ eventually make
   progress.

(The one-liner in itself will probably already help us balance things much
faster and make it harder to hit the problem spot - but the "don't just
yield" thing is probably worth it anyway because when you get into this
situation many page allocators tend to be of the PF_MEMALLOC type, and
they will want to avoid recursion in try_to_free_pages() and will not
trigger the one-liner)

So something like the appended (UNTESTED!) should be better. How does it
work for you?

		Linus

-----
diff -u --recursive --new-file pre4/linux/mm/page_alloc.c linux/mm/page_alloc.c
--- pre4/linux/mm/page_alloc.c	Wed Aug 15 02:39:44 2001
+++ linux/mm/page_alloc.c	Wed Aug 15 13:35:02 2001
@@ -450,7 +450,7 @@
 		if (gfp_mask & __GFP_WAIT) {
 			if (!order || free_shortage()) {
 				int progress = try_to_free_pages(gfp_mask);
-				if (progress || (gfp_mask & __GFP_FS))
+				if (progress || (gfp_mask & __GFP_IO))
 					goto try_again;
 				/*
 				 * Fail in case no progress was made and the
diff -u --recursive --new-file pre4/linux/mm/vmscan.c linux/mm/vmscan.c
--- pre4/linux/mm/vmscan.c	Wed Aug 15 02:39:44 2001
+++ linux/mm/vmscan.c	Wed Aug 15 02:37:07 2001
@@ -788,6 +788,9 @@
 			zone_t *zone = pgdat->node_zones + i;
 			unsigned int inactive;

+			if (!zone->size)
+				continue;
+
 			inactive  = zone->inactive_dirty_pages;
 			inactive += zone->inactive_clean_pages;
 			inactive += zone->free_pages;
diff -u --recursive --new-file pre4/linux/fs/buffer.c linux/fs/buffer.c
--- pre4/linux/fs/buffer.c	Wed Aug 15 02:39:41 2001
+++ linux/fs/buffer.c	Wed Aug 15 13:37:35 2001
@@ -794,6 +794,17 @@
 		goto retry;
 }

+static void free_more_memory(void)
+{
+	balance_dirty(NODEV);
+	page_launder(GFP_NOFS, 0);
+	wakeup_bdflush();
+	wakeup_kswapd();
+	current->policy |= SCHED_YIELD;
+	__set_current_state(TASK_RUNNING);
+	schedule();
+}
+
 /*
  * We used to try various strange things. Let's not.
  * We'll just try to balance dirty buffers, and possibly
@@ -802,15 +813,8 @@
  */
 static void refill_freelist(int size)
 {
-	if (!grow_buffers(size)) {
-		balance_dirty(NODEV);
-		page_launder(GFP_NOFS, 0);
-		wakeup_bdflush();
-		wakeup_kswapd();
-		current->policy |= SCHED_YIELD;
-		__set_current_state(TASK_RUNNING);
-		schedule();
-	}
+	if (!grow_buffers(size))
+		free_more_memory();
 }

 void init_buffer(struct buffer_head *bh, bh_end_io_t *handler, void *private)
@@ -1408,9 +1412,7 @@
 	 */
 	run_task_queue(&tq_disk);

-	current->policy |= SCHED_YIELD;
-	__set_current_state(TASK_RUNNING);
-	schedule();
+	free_more_memory();
 	goto try_again;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
