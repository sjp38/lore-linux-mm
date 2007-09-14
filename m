Date: Thu, 13 Sep 2007 19:37:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: use pagevec to rotate reclaimable page
Message-Id: <20070913193711.ecc825f7.akpm@linux-foundation.org>
In-Reply-To: <6.0.0.20.2.20070907113025.024dfbb8@172.19.0.2>
References: <6.0.0.20.2.20070907113025.024dfbb8@172.19.0.2>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Sep 2007 18:31:12 +0900 Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp> wrote:

> Hi.
> While running some memory intensive load, system response
> deteriorated just after swap-out started.
> 
> The cause of this problem is that when a PG_reclaim page is
> moved to the tail of the inactive LRU list in rotate_reclaimable_page(),
> lru_lock spin lock is acquired every page writeback . This deteriorates
> system performance and makes interrupt hold off time longer when
> swap-out started.
> 
> Following patch solves this problem. I use pagevec in rotating reclaimable
> pages to mitigate LRU spin lock contention and reduce interrupt
> hold off time.
> 
> I did a test that allocating and touching pages in multiple processes, and
> pinging to the test machine in flooding mode to measure response under
> memory intensive load.
> The test result is:
> 
> 	-2.6.23-rc5
> 	--- testmachine ping statistics ---
> 	3000 packets transmitted, 3000 received, 0% packet loss, time 53222ms
> 	rtt min/avg/max/mdev = 0.074/0.652/172.228/7.176 ms, pipe 11, ipg/ewma 
> 17.746/0.092 ms
> 
> 	-2.6.23-rc5-patched
> 	--- testmachine ping statistics ---
> 	3000 packets transmitted, 3000 received, 0% packet loss, time 51924ms
> 	rtt min/avg/max/mdev = 0.072/0.108/3.884/0.114 ms, pipe 2, ipg/ewma 
> 17.314/0.091 ms
> 
> Max round-trip-time was improved.
> 
> The test machine spec is that 4CPU(3.16GHz, Hyper-threading enabled)
> 8GB memory , 8GB swap.
> 

Perfect changelog, thanks.  It really helps everyone.

> 
> diff -Nrup linux-2.6.23-rc5.org/include/linux/swap.h 
> linux-2.6.23-rc5/include/linux/swap.h
> --- linux-2.6.23-rc5.org/include/linux/swap.h	2007-09-06 18:44:06.000000000 +0900
> +++ linux-2.6.23-rc5/include/linux/swap.h	2007-09-06 18:45:28.000000000 +0900
> @@ -185,6 +185,7 @@ extern void FASTCALL(mark_page_accessed(
>   extern void lru_add_drain(void);
>   extern int lru_add_drain_all(void);
>   extern int rotate_reclaimable_page(struct page *page);
> +extern void move_tail_pages(void);
>   extern void swap_setup(void);

Your email client performs space-stuffing.  That means the recipient needs
to do s/^ / /g to apply the patch.

>   /* linux/mm/vmscan.c */
> diff -Nrup linux-2.6.23-rc5.org/mm/swap.c linux-2.6.23-rc5/mm/swap.c
> --- linux-2.6.23-rc5.org/mm/swap.c	2007-07-09 08:32:17.000000000 +0900
> +++ linux-2.6.23-rc5/mm/swap.c	2007-09-06 18:45:28.000000000 +0900
> @@ -93,25 +93,56 @@ void put_pages_list(struct list_head *pa
>   }
>   EXPORT_SYMBOL(put_pages_list);
> 
> +static void pagevec_move_tail(struct pagevec *pvec)
> +{
> +	int i;
> +	struct zone *zone = NULL;
> +	unsigned long flags = 0;
> +
> +	for (i = 0; i < pagevec_count(pvec); i++) {
> +		struct page *page = pvec->pages[i];
> +		struct zone *pagezone = page_zone(page);
> +
> +		if (!PageLRU(page) || !page_count(page))
> +			continue;
> +
> +		if (pagezone != zone) {
> +			if (zone)
> +				spin_unlock_irqrestore(&zone->lru_lock, flags);
> +			zone = pagezone;
> +			spin_lock_irqsave(&zone->lru_lock, flags);
> +		}
> +		if (PageLRU(page) && !PageActive(page) && page_count(page)) {
> +			list_move_tail(&page->lru, &zone->inactive_list);
> +			__count_vm_event(PGROTATED);
> +		}
> +	}
> +	if (zone)
> +		spin_unlock_irqrestore(&zone->lru_lock, flags);
> +	pagevec_reinit(pvec);
> +}

I really don't like the games we play with page refcounts here.  By the
time we consider a page, that page could have been freed and could be
reused for any purpose whatever.  We don't have any business playing around
with the page's internal state when we're unsure of what it is being used
for.

Nick is the guy who skates on thin ice.  If you join him, we all drown ;)

> +static DEFINE_PER_CPU(struct pagevec, rotate_pvecs) = { 0, };
> +
> +void move_tail_pages()
> +{
> +	struct pagevec *pvec = &per_cpu(rotate_pvecs, get_cpu());
> +
> +	if (pagevec_count(pvec))
> +		pagevec_move_tail(pvec);
> +	put_cpu();
> +}
> +
>   /*
>    * Writeback is about to end against a page which has been marked for immediate
>    * reclaim.  If it still appears to be reclaimable, move it to the tail of the
> - * inactive list.  The page still has PageWriteback set, which will pin it.
> - *
> - * We don't expect many pages to come through here, so don't bother batching
> - * things up.
> - *
> - * To avoid placing the page at the tail of the LRU while PG_writeback is still
> - * set, this function will clear PG_writeback before performing the page
> - * motion.  Do that inside the lru lock because once PG_writeback is cleared
> - * we may not touch the page.
> + * inactive list.
>    *
>    * Returns zero if it cleared PG_writeback.
>    */
>   int rotate_reclaimable_page(struct page *page)
>   {
> -	struct zone *zone;
> -	unsigned long flags;
> +	struct pagevec *pvec;
> 
>   	if (PageLocked(page))
>   		return 1;
> @@ -122,15 +153,16 @@ int rotate_reclaimable_page(struct page
>   	if (!PageLRU(page))
>   		return 1;
> 
> -	zone = page_zone(page);
> -	spin_lock_irqsave(&zone->lru_lock, flags);
> -	if (PageLRU(page) && !PageActive(page)) {
> -		list_move_tail(&page->lru, &zone->inactive_list);
> -		__count_vm_event(PGROTATED);
> -	}
>   	if (!test_clear_page_writeback(page))
>   		BUG();
> -	spin_unlock_irqrestore(&zone->lru_lock, flags);
> +
> +	if (PageLRU(page) && !PageActive(page) && page_count(page)) {

The page_count() test here is a bit of a worry, too.  Why do we need it? 
The caller must have pinned the page in some fashion else we couldn't use
it safely in this function at all.

I assume that you discovered that once we've cleared PageWriteback(), the
page can get reclaimed elsewhere?  If so, that could still happen
immediately after the page_count() test.  It's all a bit of a worry. 
Deferring the ClearPageWriteback() will fix any race concerns, but I do
think that we need to take a ref on the page for the pagevec ownership.

> 
> +	move_tail_pages();
>   	lru_add_drain();
>   	spin_lock_irq(&zone->lru_lock);
>   	do { 

The tricky part will be working out whether you've found all the places
which need to have move_tail_pages() added to them.

pagevec_move_tail() needs a comment explaining that it must be called with
preemption disabled.  Otherwise it has nasty races.

Actually, given that pagevec_move_tail() is called from both interrupt and
non-interrupt context, I guess that it needs local_irq_save() protection as
well.  In which case the preempt_disable() and preempt_enable() in
move_tail_pages() can be optimised away (use local_irq_save() and
__get_cpu_var()).



So I do think that for safety and sanity's sake, we should be taking a ref
on the pages when they are in a pagevec.  That's going to hurt your nice
performance numbers :(

Please consider doing a single call to __count_vm_events() in
pagevec_move_tail(), instead of multiple calls to __count_vm_event().

It's a bit of a concern that we can have ((num_online_cpus - 1) *
PAGEVEC_SIZE) pages outstanding in the other CPU's pagevecs.  But I _guess_
that'll be OK - it's a relatively small number of pages.

What happens during cpu hot-unplug?  If we take a ref on the pageved'ed
pages then we have pages stranded in the now-unplugged cpu's pagevec? 
Might need a hotplug notifier for that.

Memory hot-unplug?  What happens if we have pointers to hot-unplugged pages
in some cpu's pagevec?  Nothing, I guess.



Historical note on pagevecs: like just about everything else in page
reclaim, this is primarily an IO scheduling problem (if rotating disks ever
become obsolete, we get to throw out a huge amount of stuff).

When I first did the pagevec batching code I found that pageout was doing
increased amounts of disk seeking.  This was because a few pages were
getting stranded in the per-cpu pagevecs on "other" CPUs.  So pageout on
"this" CPU was doing large writes with small "holes" in them (small
problem).  But later, when the "other" CPU's pagevec was spilled, we ended
up with pages on the LRU which were dirty, but which were no longer
close-on-disk to any other dirty pages.  IOW: hiding dirty pages in the
per-cpu pagevecs was deoptimising IO patterns coming out of page reclaim. 
So lru_add_drain() got added and calls to it were sprinkled around the
place.

That's just an fyi.  I doubt if similar problems will occur with your
change, because these pages are clean.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
