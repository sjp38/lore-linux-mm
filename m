Received: from venus.star.net (root@venus.star.net [199.232.114.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA03686
	for <linux-mm@kvack.org>; Mon, 25 May 1998 08:48:25 -0400
Message-ID: <3569699E.6C552C74@star.net>
Date: Mon, 25 May 1998 08:52:46 -0400
From: Bill Hawes <whawes@star.net>
MIME-Version: 1.0
Subject: Re: patch for 2.1.102 swap code
References: <356478F0.FE1C378F@star.net> <199805241728.SAA02816@dax.dcs.ed.ac.uk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:

> I don't think this should happen: do you have solid evidence that it is
> a problem?  The code in read_swap_cache_async() does
> 
>         if (!add_to_swap_cache(new_page, entry)) {
>                 free_page(new_page_addr);
>                 return 0;
>         }
>         swap_duplicate(entry);          /* Account for the swap cache */
>         set_bit(PG_locked, &new_page->flags);
>         rw_swap_page(READ, entry, (char *) new_page_addr, wait);
> 
> which should guarantee a used entry while the IO is in progress.  Even
> if the only use of the entry is the swap cache, it should still be
> there, and because the page is locked during the IO, it should not be
> possible for the swap cache reference to be removed before the check in
> rw_swap_page().  There may well be a more subtle problem here, but I
> don't think the solution is yet another swap_duplicate(), and I haven't
> seen reports that might suggest we're losing an unlock in the swapping
> code anywhere.

Hi Stephen,

The problem with the swap entry being unused could occur before reaching
the code above. If the swap cache lookup fails, the process will have to
allocate a page and may block, allowing multiple processes to block on
get_free_page. Then the process that completes first could end up
releasing the page and swap cache, so that when the other processes wake
up from get_free_page the swap entry will no longer be valid. In the
above code sequence, the add_to_swap_cache will succeed, swap_duplicate
will complain and fail, and rw_swap_cache will complain and return
leaving the page locked. There would be warning messages of the problem,
but I'd rather avoid it in the first place.

I'm reasonably certain this sequence of events could occur, and other
places in the kernel (e.g. swap_in) have tests for the case where
multiple processes try to read in the same swap page. The changes in my
patch will prevent the swap entry from disappearing when we want to read
it in, and will keep read_swap_cache from returning spurious failures.

> > In try_to_unuse_page there were some problems with swap counts still
> > non-zero after replacing all of the process references to a page,
> > apparently due to the swap map count being elevated while swapping is in
> > progress. (It shows up if a swapoff command is run while the system is
> > swapping heavily.) I've modified the code to make multiple passes in the
> > event that pages are still in use, and to report EBUSY if the counts
> > can't all be cleared.
> 
> Hmm.  That shouldn't be a problem if everything is working correctly.
> However, your first change (the extra swap_duplicate) will leave the
> swap count elevated while swapin is occurring, and that could certainly
> lead to this symptom in swapoff().  Does the swapoff problem still occur
> on an unmodified kernel?

Yes, I've seen the problem before making the other changes, and there
have been some problem reports on the kernel list. 

> There is also a matching atomic_inc() up above.  All swapout is done in
> try_to_swap_out(), which doesn't do a free_page() to match the unhook of
> the pte until after the rw_swap_page completes.  Swapin should all be
> done via the swap cache now, and that will also guarantee an extra
> reference against the page for as long as rw_swap_page is running.
> However, there are a few borderline cases such as trying to remove swap
> cache from a locked page which I'll have a check for, as they might make
> this dangerous.

I'm less certain of the possibility of the page being unused in this
case, but in any event replacing the atomic_dec() with a free_page seems
prudent to me, as there have been a number of other kernel memory leaks
caused by an atomic_dec instead of a free_page. But at the very least we
should put the printk warning there so that if the problem does occur it
can be corrected in the future.

> Me too, and I haven't found anything definitely incriminating so far.
> The one thing I _have_ found is a day-one threads bug in anonymous
> page-in.  do_no_page() handles write accesses to demand-zero memory
> with:
> 
> anonymous_page:
>         entry = pte_wrprotect(mk_pte(ZERO_PAGE, vma->vm_page_prot));
>         if (write_access) {
>                 unsigned long page = __get_free_page(GFP_KERNEL);
>                 if (!page)
>                         goto sigbus;
>                 clear_page(page);
>                 entry = pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
>                 vma->vm_mm->rss++;
>                 tsk->min_flt++;
>                 flush_page_to_ram(page);
>         }
>         put_page(page_table, entry);
> 
> The __get_free_page() may block, however, and in a threaded environment
> this will cause the loss of user data plus a memory leak if two threads
> hit this race.  However, I don't think it's related to the current
> writable cached page problems.
> 
> Could you cast your eyes over the patch below?  It builds fine and
> passes the tests I've thrown at it so far, but I'd like a second opinion
> before forwarding it as a patch for 2.0.

The patch looks reasonable to me, but as DaveM mentioned in a later
mail, the
do_wp_page case is supposed to be protected with a semaphore.

Regards,
Bill
