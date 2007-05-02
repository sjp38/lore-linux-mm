Message-ID: <4637EC95.2010501@yahoo.com.au>
Date: Wed, 02 May 2007 11:42:45 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans: mm-more-rmap-checking
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <Pine.LNX.4.64.0705011458060.16979@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0705011458060.16979@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Mon, 30 Apr 2007, Andrew Morton wrote:
> 
>>... 
>> mm-more-rmap-checking.patch
>>...
>>
>>Misc MM things.  Will merge.
> 
> 
> Would Nick mind very much if I ask you to drop this one?
> You did CC me ages ago, but I've only just run across it.
> It's a small matter, but I'd prefer it dropped for now.

I guess I would prefer it to go under CONFIG_DEBUG_VM. Speaking
of which, it would be nice to be able to turn that on unconditionally
in -rc1. Although I may have put a few too many things under it, so
it might slow down too much...


>>>Re-introduce rmap verification patches that Hugh removed when he removed
>>>PG_map_lock. PG_map_lock actually isn't needed to synchronise access to
>>>anonymous pages, because PG_locked and PTL together already do.
>>>
>>>These checks were important in discovering and fixing a rare rmap corruption
>>>in SLES9.
> 
> 
> It introduces some silly checks which were never in mainline,
> nor so far as I can tell in SLES9: I'm thinking of those
> +	BUG_ON(address < vma->vm_start || address >= vma->vm_end);

Yes, but IIRC I put that in because there was another check in
SLES9 that I actually couldn't put in, but used this one instead
because it also caught the bug we saw.


> There are few callsites for these rmap functions, I don't think
> they need to be checking their arguments in that way.
> 
> It also changes the inline page_dup_rmap (a single atomic increment)
> into a bugchecking out-of-line function: do we really want to slow
> down fork in that way, for 2.6.22 to fix a rare corruption in SLES9?

This was actually a rare corruption that is also in 2.6.21, and
as few rmap callsites as we have, it was never noticed until the
SLES9 bug check was triggered.


> What I really like about the patch is Nick's observation that my
> 	/* else checking page index and mapping is racy */
> is no longer true: a change we made to the do_swap_page sequence
> some while ago has indeed cured that raciness, and I'm happy to
> reintroduce the check on mapping and index in page_add_anon_rmap,
> and his BUG_ON(!PageLocked(page)) there (despite BUG_ONs falling
> out of fashion very recently).

Hmm, I didn't notice the do_swap_page change, rather just derived
its safety by looking at the current state of the code (which I
guess must have been post-do_swap_page change)...

Do you have a pointer to the patch, for my interest?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
