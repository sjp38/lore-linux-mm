Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA02989
	for <linux-mm@kvack.org>; Mon, 25 May 1998 05:54:08 -0400
Date: Sun, 24 May 1998 18:28:48 +0100
Message-Id: <199805241728.SAA02816@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: patch for 2.1.102 swap code
In-Reply-To: <356478F0.FE1C378F@star.net>
References: <356478F0.FE1C378F@star.net>
Sender: owner-linux-mm@kvack.org
To: Bill Hawes <whawes@star.net>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi Bill,

On Thu, 21 May 1998 14:56:48 -0400, Bill Hawes <whawes@star.net> said:

> I've been reviewing the swap code

Thanks!

>  and spotted a couple of prolems, which the attached patch should take
> care of.

> In read_swap_cache there was a race condition that could lead to pages
> being left locked if the swap entry becomes unused while a process is
> trying to read it. The low level rw_read_swap() routine bails out if the
> entry isn't in use at the time, which would leave the page locked. The
> patch avoids this problem by calling swap_duplicate() before checking
> for the page.

I don't think this should happen: do you have solid evidence that it is
a problem?  The code in read_swap_cache_async() does 

	if (!add_to_swap_cache(new_page, entry)) {
		free_page(new_page_addr);
		return 0;
	}
	swap_duplicate(entry);		/* Account for the swap cache */
	set_bit(PG_locked, &new_page->flags);
	rw_swap_page(READ, entry, (char *) new_page_addr, wait);

which should guarantee a used entry while the IO is in progress.  Even
if the only use of the entry is the swap cache, it should still be
there, and because the page is locked during the IO, it should not be
possible for the swap cache reference to be removed before the check in
rw_swap_page().  There may well be a more subtle problem here, but I
don't think the solution is yet another swap_duplicate(), and I haven't
seen reports that might suggest we're losing an unlock in the swapping
code anywhere.

> In try_to_unuse_page there were some problems with swap counts still
> non-zero after replacing all of the process references to a page,
> apparently due to the swap map count being elevated while swapping is in
> progress. (It shows up if a swapoff command is run while the system is
> swapping heavily.) I've modified the code to make multiple passes in the
> event that pages are still in use, and to report EBUSY if the counts
> can't all be cleared.

Hmm.  That shouldn't be a problem if everything is working correctly.
However, your first change (the extra swap_duplicate) will leave the
swap count elevated while swapin is occurring, and that could certainly
lead to this symptom in swapoff().  Does the swapoff problem still occur
on an unmodified kernel?

> In rw_swap_page there was an atomic_dec() of the page count after a sync
> read or write, and I think it's possible that the page could have become
> unused while waiting for the I/O operation. I've changed the atomic_dec
> into a free_page() and added a printk to show whether it actually occurs
> in practice.

There is also a matching atomic_inc() up above.  All swapout is done in
try_to_swap_out(), which doesn't do a free_page() to match the unhook of
the pte until after the rw_swap_page completes.  Swapin should all be
done via the swap cache now, and that will also guarantee an extra
reference against the page for as long as rw_swap_page is running.
However, there are a few borderline cases such as trying to remove swap
cache from a locked page which I'll have a check for, as they might make
this dangerous.

> The patch also includes a few minor cleanups for unused code and
> prototypes in swap.h. I've tested it here and it seems to work OK, but
> would like some further testing. Also, it probably won't help with the
> "found a writable swap page" message reported recently; I'm continuing
> to look for that problem.

Me too, and I haven't found anything definitely incriminating so far.
The one thing I _have_ found is a day-one threads bug in anonymous
page-in.  do_no_page() handles write accesses to demand-zero memory
with:

anonymous_page:
	entry = pte_wrprotect(mk_pte(ZERO_PAGE, vma->vm_page_prot));
	if (write_access) {
		unsigned long page = __get_free_page(GFP_KERNEL);
		if (!page)
			goto sigbus;
		clear_page(page);
		entry = pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
		vma->vm_mm->rss++;
		tsk->min_flt++;
		flush_page_to_ram(page);
	}
	put_page(page_table, entry);

The __get_free_page() may block, however, and in a threaded environment
this will cause the loss of user data plus a memory leak if two threads
hit this race.  However, I don't think it's related to the current
writable cached page problems.

Could you cast your eyes over the patch below?  It builds fine and
passes the tests I've thrown at it so far, but I'd like a second opinion
before forwarding it as a patch for 2.0.

--Stephen

----------------------------------------------------------------
Index: mm/memory.c
===================================================================
RCS file: /home/rcs/CVS/kswap3/linux/mm/memory.c,v
retrieving revision 1.1.2.2
diff -u -r1.1.2.2 memory.c
--- memory.c	1998/03/08 16:32:57	1.1.2.2
+++ memory.c	1998/05/24 17:19:07
@@ -839,9 +839,14 @@
 anonymous_page:
 	entry = pte_wrprotect(mk_pte(ZERO_PAGE, vma->vm_page_prot));
 	if (write_access) {
+		pte_t old_entry = *page_table; 
 		unsigned long page = __get_free_page(GFP_KERNEL);
 		if (!page)
 			goto sigbus;
+		if (pte_val(old_entry) != pte_val(*page_table)) {
+			free_page(page);
+			return;
+		}
 		clear_page(page);
 		entry = pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 		vma->vm_mm->rss++;
