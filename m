Message-ID: <41BBF923.6040207@yahoo.com.au>
Date: Sun, 12 Dec 2004 18:54:11 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance
    tests
References: <Pine.LNX.4.44.0412091830580.17648-300000@localhost.localdomain> <Pine.LNX.4.58.0412101006200.8714@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412101006200.8714@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Thank you for the thorough review of my patches. Comments below
> 
> On Thu, 9 Dec 2004, Hugh Dickins wrote:
> 
> 
>>Your V12 patches would apply well to 2.6.10-rc3, except that (as noted
>>before) your mailer or whatever is eating trailing whitespace: trivial
>>patch attached to apply before yours, removing that whitespace so yours
>>apply.  But what your patches need to apply to would be 2.6.10-mm.
> 
> 
> I am still mystified as to why this is an issue at all. The patches apply
> just fine to the kernel sources as is. I have patched kernels numerous
> times with this patchset and never ran into any issue. quilt removes trailing
> whitespace from patches when they are generated as far as I can tell.
> 
> Patches will be made against mm after Nick's modifications to the 4 level
> patches are in.
> 

I've been a bit slow with them, sorry.... but there hasn't been a hard
decision to go one way or the other with the 4level patches yet.
Fortunately, it looks like 2.6.10 is having a longish drying out period,
so I should have something before it is released.

I would just sit on them for a while, and submit them to -mm when the
4level patches get merged / ready to merge into 2.6. It shouldn't slow
down the progress of your patch too much - they'll may have to wait until
after 2.6.11 anyway I'd say (probably depends on the progress of other
changes going in).


>>probably others (harder to think through).  Your 4/7 patch for i386 has
>>an unused atomic get_64bit function from Nick, I think you'll have to
>>define a get_pte_atomic macro and use get_64bit in its 64-on-32 cases.
> 
> 
> That would be a performance issue.
> 
> 

Problems were pretty trivial to reproduce here with non atomic 64-bit
loads being cut in half by atomic 64 bit stores. I don't see a way
around them, unfortunately.

Test case is to run with CONFIG_HIGHMEM (you needn't have > 4 GB of
memory in the system, of course), and run 2-4 threads on a dual CPU
system, doing parallel faulting of the *same* anonymous pages.

What happens is that the load (`entry = *pte`) in handle_pte_fault
gets cut in half, and handle_pte_fault drops down to do_swap_page,
and you get an infinite loop trying to read in a non existant swap
entry IIRC.

>>Hmm, that will only work if you're using atomic set_64bit rather than
>>relying on page_table_lock in the complementary places which matter.
>>Which I believe you are indeed doing in your 3level set_pte.  Shouldn't
>>__set_64bit be using LOCK_PREFIX like __get_64bit, instead of lock?
> 
> 
>>But by making every set_pte use set_64bit, you are significantly slowing
>>down many operations which do not need that atomicity.  This is quite
>>visible in the fork/exec/shell results from lmbench on i386 PAE (and is
>>the only interesting difference, for good or bad, that I noticed with
>>your patches in lmbench on 2*HT*P4), which run 5-20% slower.  There are
>>no faults on dst mm (nor on src mm) while copy_page_range is copying,
>>so its set_ptes don't need to be atomic; likewise during zap_pte_range
>>(either mmap_sem is held exclusively, or it's in the final exit_mmap).
>>Probably revert set_pte and set_pte_atomic to what they were, and use
>>set_pte_atomic where it's needed.
> 
> 
> Good suggestions. Will see what I can do but I will need some assistence
> my main platform is ia64 and the hardware and opportunities for testing on
> i386 are limited.
> 

I think I (and/or others) should be able to help with i386 if you are
having trouble :)

Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
