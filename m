Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B6D5A6B0095
	for <linux-mm@kvack.org>; Sat, 30 May 2009 03:02:22 -0400 (EDT)
Date: Sat, 30 May 2009 00:00:04 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530070004.GI29711@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <1242852158.6582.231.camel@laptop> <20090520212413.GF10756@oblivion.subreption.com> <20090529155859.2cf20823.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090529155859.2cf20823.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: peterz@infradead.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-mm@kvack.org, mingo@redhat.com, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On 15:58 Fri 29 May     , Andrew Morton wrote:
> And your proposed approach requires that developers remember to use
> GFP_SENSITIVE at allocation time.  In well-implemented code, there is a
> single memory-freeing site, so there's really no difference here.

In the current (latest) patch, unconditional sanitization is enabled via
boot time option. There's no page flag now, neither GFP_CONFIDENTIAL
since it is useless without the page flag.

> Other problems I see with the patch are:
> 
> - Adds a test-n-branch to all page-freeing operations.  Ouch.  The
>   current approach avoids that cost.
> 
> - Fails to handle kmalloc()'ed memory.  Fixing this will probably
>   require adding a test-n-branch to kmem_cache_alloc().  Ouch * N.

For the GFP_CONFIDENTIAL flag? Not there anymore. If you meant clearing
on allocation, that's hopeless. The current patch doesn't touch the
kmalloc layer, though I submitted a second one that takes care of
kfree/kmem_cache_free. Peter has objected to adding more branches
there...

> - Once kmalloc() is fixed, the page-allocator changes and
>   GFP_SENSITIVE itself can perhaps go away - I expect that little
>   security-sensitive memory is allocated direct from the page
>   allocator.  Most callsites are probably using
>   kmalloc()/kmem_cache_alloc() (might be wrong).

None of the currently hot spots use private caches, they use the
standard ones through kmalloc. Having separate caches for each of these
hot spots is beyond overkill and will have a higher performance hit than
any of the current or past patches I submitted.

>   If not wrong then we end up with a single requirement: zap the
>   memory in kmem_cache_free().

Done in the last patchset I submitted. There's an issue there: Peter
raised questions about the branches I introduced... truth is, those are
there (in sanitize_obj) to make sure we are dealing with a valid object
pointer. kmem_cache_free lacks these checks (albeit kfree has them)...

I'm not sure why they aren't there. In sanitize_obj we can skip those
since kfree takes care of it, but we should probably add them to
kmem_cache_free.

So this is what I propose:

	1. We remove sanitize_obj, saving the test branches there and
	any pointer validation (at the expense of trusting it in
	kmem_cache_free). No extra call depth. We will duplicate the
	clearing when the object is the last in the slab (a put_page
	ensues and the page allocator sanitizes it there).

	2. We move the memset to kfree and kmem_cache_free, and use a
	single test branch for sanitize_all_mem.

Should keep the instruction counting fellows happy. Is this acceptable
for you now?

>   But how to do that?  Particular callsites don't get to alter
>   kfree()'s behaviour.  So they'd need to use a new kfree_sensitive(). 
>   Which is just syntactic sugar around the code whihc we presently
>   implement.

This could work, but again it won't do anything unless sanitization is
enabled on boot time (or it should be independent). And we changed the
naming from sensitive to confidential, since some people opposed the
former.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
