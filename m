Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA16973
	for <linux-mm@kvack.org>; Tue, 19 Jan 1999 10:16:01 -0500
Date: Tue, 19 Jan 1999 15:15:33 GMT
Message-Id: <199901191515.PAA05462@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Alpha quality write out daemon
In-Reply-To: <m1g19ep3p9.fsf@flinx.ccr.net>
References: <m1g19ep3p9.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On 14 Jan 1999 04:08:02 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
said:

> This patch is agains 2.2.0-pre5.
> I have been working and have implemented a daemon that does
> all swaping out except from shm areas (todo).

> What it does is add an extra kernel daemon that does nothing but
> walking through the page tables start I/O on dirty pages and mark them
> clean and write protected.  Sleep 30 seconds and do it again.

This feels like the wrong way of doing it.  We _already_ have a page
walking algorithm.  Why do we need another one?

My own feeling is that a laundry list (a list of pages needing written
out, either to swap or via filemap) is a better way of running the
background swapout thread.  That way we can cluster the IO appropriately
(using the ordering of the laundry list) while still making the IO
completely asynchronous.

> Unfortunantely this extra aggressiveness seems to be turning up lurking 
> bugs in other parts of the kernel.  I keep getting:

> Kernel Panic: Freeing swap cahce page
> or
> swap entry mismatch<7>clean_mm:0 found a page
> swap_cache: replacing non-empty entry 00076300 on page c18fe000
>    Which I have tracked down to finding dirty ptes that point at swap cache pages!

> Since I have only added one signficant function, and it only runs in a single
> thread I am 95% sure it's not my new code.

I'd suspect any new code first, and old code second: if my own experience
with the VM is anything to go by, seemingly trivial changes can have
unexpected and subtle side effects...

Looking at your code, it seems to be absolutely full of diabolical
races.  I'm sure that your problems are there!  To take the first two I
came across:

> +static int try_to_clean(struct vm_area_struct* vma, unsigned long address, pte_t * page_table)

> +	if (vma->vm_ops && vma->vm_ops->writeout) {
> +		if (vma->vm_ops->writeout(vma, address - vma->vm_start + vma->vm_offset, page)) {
> +			/* Find some appropriate process to tell,
> +			 * anyone with the same mm_struct is fine
> +			 */
...
> +			goto out;
> +		}
> +		result = 1;
> +		pte = pte_mkclean(pte);
> +		set_pte(page_table, pte);
> +		goto out;
> +	}

Ouch.  You are setting the pte stuff after calling writeout(), and the
page tables can have changed drastically during the sleep (indeed, the
process may even have died while you were asleep in the writout). 

> +	/*
> +	 * This is a dirty, swappable page.  First of all,
> +	 * get a suitable swap entry for it, and make sure
> +	 * we have the swap cache set up to associate the
> +	 * page with that swap entry.
> +	 */
> ...
> +	/* OK, do a physical asynchronous write to swap.  */
> +	rw_swap_page(WRITE, entry, (char *) page, 0);
> +
> +	result = 1; /* Could we have slept? Play it safe */
> +	/* Note:  We make the page read only here to maintain the invariant
> +	 * that swap cache pages are always read only.
> +	 * Once we have PG_dirty or a similar mechanism implemented we
> +	 * can relax this.
> +	 */
> +	pte = pte_wrprotect(pte_mkclean(pte));
> +	set_pte(page_table, pte);

Again, mucking about with ptes after the potential sleep in
rw_swap_page() is completely forbidden.  vmscan.c:try_to_swap_out() is
*really* careful to avoid this.  Have a good look at the order in which
we do things there, and also while you are at it look at the tlb and
cache flush logic we need to employ to keep things sane.  As it stands,
your daemon is a complete VM death trap!

--Stephen


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
