Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA11674
	for <linux-mm@kvack.org>; Tue, 26 May 1998 17:39:43 -0400
Date: Tue, 26 May 1998 22:38:26 +0100
Message-Id: <199805262138.WAA02811@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: patch for 2.1.102 swap code
In-Reply-To: <3569699E.6C552C74@star.net>
References: <356478F0.FE1C378F@star.net>
	<199805241728.SAA02816@dax.dcs.ed.ac.uk>
	<3569699E.6C552C74@star.net>
Sender: owner-linux-mm@kvack.org
To: Bill Hawes <whawes@star.net>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi Bill,

On Mon, 25 May 1998 08:52:46 -0400, Bill Hawes <whawes@star.net> said:

> The problem with the swap entry being unused could occur before reaching
> the code above. If the swap cache lookup fails, the process will have to
> allocate a page and may block, allowing multiple processes to block on
> get_free_page. Then the process that completes first could end up
> releasing the page and swap cache, 
> ...

That's why read_swap_cache_async repeats the initial entry lookup after
calling __get_free_page().  Unfortunately, I hadn't realised that
swap_duplicate() had the error check against swap_map[entry]==0.  Moving
the swap_duplicate up to before the call to __get_free_page should avoid
that case.

>> > In try_to_unuse_page there were some problems with swap counts still
>> > non-zero after replacing all of the process references to a page,
>> > ...

>> Hmm.  That shouldn't be a problem if everything is working correctly.
>> Does the swapoff problem still occur on an unmodified kernel?

> Yes, I've seen the problem before making the other changes, and there
> have been some problem reports on the kernel list. 

Excellent --- that should mean it's easy to reproduce, and I've got a
test box set up to do tracing on all this code.  Is there anything in
particular you do to trigger the situation?  I've been going over the
obvious places in try_to_swap_out and friends, but haven't found
anything yet where we might block between updating a pte and modifying
the corresponding pte count.

>> There is also a matching atomic_inc() up above.  All swapout is done in
>> try_to_swap_out(), ...

> I'm less certain of the possibility of the page being unused in this
> case, but in any event replacing the atomic_dec() with a free_page seems
> prudent to me, as there have been a number of other kernel memory leaks
> caused by an atomic_dec instead of a free_page. But at the very least we
> should put the printk warning there so that if the problem does occur it
> can be corrected in the future.

Yes, the printk will help.  Swap should _definitely_ be done through the
swap cache, and anything which violates this is broken, so although
there should never be a chance of freeing the page, the warning is a
useful thing to have.

>> Me too, and I haven't found anything definitely incriminating so far.
>> The one thing I _have_ found is a day-one threads bug in anonymous
>> page-in.  do_no_page() handles write accesses to demand-zero memory
>> with:
>> ...

> The patch looks reasonable to me, but as DaveM mentioned in a later
> mail, the do_wp_page case is supposed to be protected with a
> semaphore.

Yep, I've responded to that separately.

--Stephen
