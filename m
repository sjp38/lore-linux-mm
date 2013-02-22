Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 353C36B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:17:16 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id ma3so511913pbc.11
        for <linux-mm@kvack.org>; Fri, 22 Feb 2013 09:17:15 -0800 (PST)
Date: Fri, 22 Feb 2013 09:16:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 5/7] mm,ksm: swapoff might need to copy
In-Reply-To: <20130221145316.GA23767@cmpxchg.org>
Message-ID: <alpine.LNX.2.00.1302220808020.4942@eggly.anvils>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <alpine.LNX.2.00.1302210023350.17843@eggly.anvils> <20130221145316.GA23767@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 21 Feb 2013, Johannes Weiner wrote:
> On Thu, Feb 21, 2013 at 12:25:40AM -0800, Hugh Dickins wrote:
> > Before establishing that KSM page migration was the cause of my
> > WARN_ON_ONCE(page_mapped(page))s, I suspected that they came from the
> > lack of a ksm_might_need_to_copy() in swapoff's unuse_pte() - which
> > in many respects is equivalent to faulting in a page.
> > 
> > In fact I've never caught that as the cause: but in theory it does
> > at least need the KSM_RUN_UNMERGE check in ksm_might_need_to_copy(),
> > to avoid bringing a KSM page back in when it's not supposed to be.
> 
> Maybe I am mistaken, maybe it was just too obvious to you to mention,
> but the main reason for me would be that this can break eviction,
> migration, etc. of that page when there is no rmap_item representing
> the vma->anon_vma (the cross-anon_vma merge case), no?

Hah, thank you for asking that question, sir.
(People will think that I planted you in the Cc just to ask it.)

I did write a longer paragraph there, but it got to rambling off the
point, with some vagueness: so I wasn't sure that I wanted it all in
the commit message, and deleted the trailing sentences.

For most of the time that I had this patch waiting in my tree, before
coming to write the description, I believed exactly as you do above.
But felt that I couldn't submit the patch, without understanding how
I had never actually come across such a serious problem in testing.
I only got around to looking into it a few days ago.

At first I suspected a weakness in the CONFIG_DEBUG_VM checking in
__page_check_anon_rmap() (no, it looks good), or the early PageAnon
return in __page_set_anon_rmap() (shouldn't that do some anon_vma
checking first? maybe, but I didn't think it through before moving
on, and don't want to be too quick to add spurious warnings).

But then I remembered how this actually was working,
the key lines are a few levels up in unuse_vma():
	if (page_anon_vma(page)) {
		addr = page_address_in_vma(page, vma);

Those lines started out, in 2004, as an optimization to swapoff:
that once brute force (searching every swapped mm) has found one pte
for the page (page->mapping and page->index then set to the right
place in the right anon_vma), we can locate any remaining references
to the page much more quickly, but just looking at the right offset
of other vmas sharing the same anon_vma.

When KSM swapping came along, it turned out that the only change needed
there was not assume that page->mapping is set to an anon_vma pointer:
page_anon_vma(page) returns NULL on a KSM page.  What happens (on a
page freshly read in from swap) is that once one pte has been found,
page->mapping is pointed to an anon_vma, and the quicker lookup only
finds ptes which do belong to that anon_vma.  Then try_to_unuse() gives
up on that swap entry for the moment, deletes the page from swap cache,
moves on to the next used swap entry, comes back to the unresolved
swap entry next cycle, reads it from swap into a new page, and locates
the next anon_vma for it.  Or, if the KSM page was still lingering in
swapcache when swapoff first reaches it (with page->mapping pointing
to a stable_node), it would be correctly fixed up to all the various
ptes found by the brute force search.

Re-reading the page from swap is obviously not optimal, when it would
be much faster to memcpy.  But swapoff has never been remotely optimal
anyway; and the complete lack of code for the KSM case was delightful -
the only problem being that there no code to place a comment in!

I did have a nasty moment (well, it lasted a bit longer than that)
in replying to you yesterday: but what about when the anon_vma_chains
came in?  Has swapoff been doing lots of unnecessary re-reading from
swap to match ptes belonging to different anon_vmas in the chain?  But
actually it's okay, Andrea fixed up page_address_in_vma() in 2.6.36,
and I added a comment on KSM there (I see my 4829b906 also speaks of
a bug with respect to "half-KSM" pages, that I promise to fix in the
next release: I have yet to reconstruct the full story of what that was
about, but for now I'm assuming that I failed to keep my promise there).

Anyway, long story short (oh, people are supposed to say that at the
beginning not the end, aren't they?), the KSM swapoff code was already
working almost right before adding in the ksm_might_need_to_copy():
that's only needed to fix up the case of swapoff racing with unmerge
(a check that didn't even exist for swapin before the NUMA series).

> 
> > I intended to copy how it's done in do_swap_page(), but have a strong
> > aversion to how "swapcache" ends up being used there: rework it with
> > "page != swapcache".
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
