Received: from venus.star.net (root@venus.star.net [199.232.114.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA15787
	for <linux-mm@kvack.org>; Wed, 27 May 1998 11:23:46 -0400
Message-ID: <356C30C7.8F16177F@star.net>
Date: Wed, 27 May 1998 11:27:03 -0400
From: Bill Hawes <whawes@star.net>
MIME-Version: 1.0
Subject: Re: patch for 2.1.102 swap code
References: <356478F0.FE1C378F@star.net>
		<199805241728.SAA02816@dax.dcs.ed.ac.uk>
		<3569699E.6C552C74@star.net> <199805262138.WAA02811@dax.dcs.ed.ac.uk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:

> That's why read_swap_cache_async repeats the initial entry lookup after
> calling __get_free_page().  Unfortunately, I hadn't realised that
> swap_duplicate() had the error check against swap_map[entry]==0.  Moving
> the swap_duplicate up to before the call to __get_free_page should avoid
> that case.

Hi Stephen,

Moving the swap_duplicate() call above the get_free_page() helps, but
does not entirely avoid the race: it's possible for lookup_swap_cache()
to block on a locked page, and when the process wakes up the swap entry
may have disappeared. In order for read_swap_cache to fulfill its
contract ("this swap entry exists, go get it for me") it must increment
the swap map count before any blocking operation. Hence I moved the
swap_duplicate() call above the lookup.

I could check for the case of finding the unlocked swap cache page, and
only increment the map count if a wait was needed; this would avoid
having to increment and decrement the map count if the page is found, at
the expense of a little more complexity. I'll post a mopdified patch for
comment ...

> Excellent --- that should mean it's easy to reproduce, and I've got a
> test box set up to do tracing on all this code.  Is there anything in
> particular you do to trigger the situation?  I've been going over the
> obvious places in try_to_swap_out and friends, but haven't found
> anything yet where we might block between updating a pte and modifying
> the corresponding pte count.

I've observed the swapoff messages after running swapoff on a quiescent
system that had been swapping heavily previously, and also when running
swapoff with the system currently swapping. Try setting up a condition
of heavy swapping but with adequate memory available (e.g. two kernel
compiles in 32M), and then cycle swapoff -a and swapon -a.

Running swapoff is a good test for the VM system; unfortunately the
current kernels have an unrelated problem with kswapd trying too hard to
keep memory blocks, so that swapoff may put the system in an
unrecoverable kswapd loop. If you try swapoff when the system doesn't
have enough memory, the system will lock rather than let swapoff return
failure. But this is a problem of swap policy rather than mechanism, and
we can try to fix it after the swap mechanics are 100% solid.
 
Regards,
Bill
