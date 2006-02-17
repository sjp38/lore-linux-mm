Date: Fri, 17 Feb 2006 08:22:47 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] 0/4 Migration Cache Overview
In-Reply-To: <1140190593.5219.22.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0602170816530.30999@schroedinger.engr.sgi.com>
References: <1140190593.5219.22.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Feb 2006, Lee Schermerhorn wrote:

> Marcello Tosatti introduced the migration cache back in Oct04 to obviate use
> of swap space for anon pages during page migration.  He posted the original
> migration patch [let's call this V0] to the linux-mm list:

Could add a justification of this feature? What is the benefit of having a 
migration cache instead of using swap pte (current migration is not really 
using swap space per se)?

> migration work has been submitted upstream, I have ported the migration
> cache patches to work with his direct migration in 2.6.16-rc3-mm1. I'm
> calling this "V8".

Direct migration is in Linus' tree and I am not aware of anything 
necessary in mm.

> One complication in all of this is when direct migration of an anon
> page falls back to swapping out the pages.  If the page had not already
> been in the swap cache, it will have been added to the migration 
> cache.  To swap the page out, we need to move if from the migration
> cache to the swap cache.  Note that this would also be required if
> shrink_list() encounters a page in the migration cache.  Both the
> page migration code and shrink_list() have been modified to call
> a new function "migration_move_to_swap()" in these cases.  Marcello
> mentions the need to do this in his first migration cache post linked
> above.

We could potentially remove the ability to fall back to swap or add an 
option to disallow the fallback. This is also necessary if we want to 
migration mlocked memory. Maybe this could simplify the code?

> QUESTION:  what does this mean for tasks that fault on the 
> migration cache pte while we're moving the page to the swap
> cache?  I think that if they manage to look up the page in the
> migration cache and get a reference on it, the current test
> in do_swap_page() will work OK.  However, is there a potential
> race between the time __handle_mm_fault() fetches the pte from
> the page table and when do_swap_page() does the cache lookup?
> [in a preemptible kernel?]

Yes there is since handle_mm_fault accesses the pte without locking.
do_swap_page acquires the lock and will then recheck if the pte is the 
same. If anything happened in between it should redo the page fault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
