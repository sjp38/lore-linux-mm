Date: Sun, 9 Jul 2000 10:30:11 -0700
From: Philipp Rumpf <prumpf@uzix.org>
Subject: Re: sys_exit() and zap_page_range()
Message-ID: <20000709103011.A3469@fruits.uzix.org>
References: <3965EC8E.5950B758@uow.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3965EC8E.5950B758@uow.edu.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jul 08, 2000 at 12:43:26AM +1000, Andrew Morton wrote:
> On exit from mmap001, zap_page_range() is taking over 20 milliseconds on
> a 500MHz processor.   Is there anything easy which can be done about
> this?
> 
> No algorithmic optimisations leap out at me, so the options appear to
> be:
> 
> (1) Live with it.
> 
> (2) Pass the mm over to the swapper task and let it quietly
>     throw things away in the background.
> 
> (3) Put some conditional schedule calls in there.
> 
> I note that Ingo's low-latency patch does (3).  He's put `if
> (current->need_resched) schedule();' in the loop in zap_pte_range().  In
> 2.4, it looks like this won't work because of the lock held on
> mm->page_table_lock, and the lock held on mapping->i_shared_lock in
> vmtruncate().
> 
> Can anyone suggest a simple, clean way of decreasing zap_page_range's
> scheduling latency, in a way which you're prepared to support?

Here's a simple way:

void zap_page_range(struct mm_struct *mm, unsigned long address, unsigned long size)
{
	pgd_t * dir;
	unsigned long end = address + size;
	int freed = 0;

	if(size > PAGE_SIZE*4) {
		while(size > PAGE_SIZE*4) {
			conditional_schedule();
			zap_page_range(mm, address, PAGE_SIZE*4);
			size -= PAGE_SIZE*4;
			address += PAGE_SIZE*4;
		}
		conditional_schedule();
		zap_page_range(mm, address, size);
	}

	...
}

[PAGE_SIZE*4 is low, I suspect.]

For a clean solution, what I would love zap_page_range to look like is:

void zap_page_range(struct mm_struct *mm, unsigned long address, unsigned long size)
{
	pte_t * pte;
	unsigned long end = address + size;
	int freed = 0;

	/*
	 * This is a long-lived spinlock. That's fine.
	 * There's no contention, because the page table
	 * lock only protects against kswapd anyway, and
	 * even if kswapd happened to be looking at this
	 * process we _want_ it to get stuck.
	 */
	if (address >= end)
		BUG();
retry:
	spin_lock(&mm->page_table_lock);
	for_each_pte(pte, mm, address, end) {
		pte_t page;

		if(current->need_resched)
			goto reschedule;

		page = *pte;
		address += PAGE_SIZE;
		pte_clear(pte-1);
		if (pte_none(page))
			continue;
		freed += free_pte(page);
	}
	spin_unlock(&mm->page_table_lock);

		/*
	 * Update rss for the mm_struct (not necessarily current->mm)
	 */
	if (mm->rss > 0) {
		mm->rss -= freed;
		if (mm->rss < 0)
			mm->rss = 0;
	}

	return;

reschedule:
	spin_unlock(&mm->page_table_lock);
	schedule();
	spin_lock(&mm->page_table_lock);

	goto retry;
}

The main point here is having something like

for_each_pte(pte,mm,address,end)
which doesn't require any compiler magic to be efficient on two-level
page table machines and should work well with four- and five-level page
tables.  It looks to me like it'd simplify mm/*.c a lot, and would still
end up with preprocessed code very similar to what we have now.

In fact, I think it will become obvious soon that iterating through user
page tables without rescheduling isn't _ever_ a good idea - then both the
spin_lock and the conditional_reschedule could be moved into for_each_pte
(well, maybe for_each_pte_user or something) and we'd actually end up
with readable code for zap_page_range.

	Philipp Rumpf
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
