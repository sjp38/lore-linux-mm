Date: Sat, 4 Nov 2000 03:07:33 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001104030733.A23119@athlon.random>
References: <20001103232721.D27034@athlon.random> <Pine.BSF.4.10.10011032029190.1962-100000@myrile.madriver.k12.oh.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.BSF.4.10.10011032029190.1962-100000@myrile.madriver.k12.oh.us>; from elowe@myrile.madriver.k12.oh.us on Fri, Nov 03, 2000 at 08:36:08PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Lowe <elowe@myrile.madriver.k12.oh.us>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 03, 2000 at 08:36:08PM -0500, Eric Lowe wrote:
> I agree with you on this one, and in fact, my 2.2 patches already
> do both these things.

My one against 2.2.x is here:

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.2/2.2.18pre17aa1/13_bigmem-rawio-2.2.18pre17aa1-5.bz2

It fix several bugs (not only the ones that you attempted to fix).  Since your
patch seems to have several problems I suggest you to base on my one (you
may need to fix some reject to apply to clean 2.2.x though).

> +	while (ptr < end) {
> +		if (!vma || ptr >= vma->vm_end) {
> +			vma = find_vma(current->mm, ptr);
> +			if (!vma)
> +				goto out_unlock;
> +		}

Here you miss the check for the vm_start and vma flags.

> +		pte = get_pte(vma, ptr);
> +		if (!pte)
> +			goto out_unlock;
> +
> +		if (!fault_page_in(vma, ptr, write_access, pte))
> +			goto out_unlock;

So your fault_page_in should also check that the pte is dirty if
writing to memory.

> +		if (map) {
> +			if (TryLockPage(map))
> +				goto retry;
> +			atomic_inc(&map->count);
> +			set_bit(PG_dirty, &map->flags);
> +		}
> +

This doesn't fix the MM corruption (obviously since PG_dirty doesn't mean
_anything_ in 2.2.x, and even if it would mean something like in 2.4.x you
would need to rework core parts of the memory balancing to solve the MM
corruption that way).  Note also that so far it was legal to do rawio on
MAP_SHARED so I must preserve that semantics at least in the 2.2.x short term
in case somebody was depending on it in previous aa kernels. So right now I'm
locking down the pages during writes to memory. The _only_ real world downside
is that you can't write to the same page from two tasks at the same time but
_nobody_ really cares about that so unlikely corner case in real life.

> +		if (!pte_present(*pte) || (write_access && !pte_write(*pte))) {
> +			err = -EAGAIN;
> +			goto out_unlock;
> +		}

This isn't necessary. If it would be necessary it would be wrong to do it here
after you just grabbed the page reference.

> +		if (write_access && !pte_dirty(*pte))
> +			panic("map_user_kiobuf: writable page w/o dirty pte\n");

As said above this case should be handled by follow_page.  You shouldn't panic
but re-enter the page fault handler.

All those problems should be just fixed properly in the rawio patch in the aa
patchkit (and my stress stess is now happy on all kind of vmas). Please use
it and let me know if you have any problem or you see any bug. thanks!

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
