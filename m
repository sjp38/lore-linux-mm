Date: Tue, 19 Feb 2002 12:22:28 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <E16d8c8-0001Ea-00@starship.berlin>
Message-ID: <Pine.LNX.4.21.0202191209570.1016-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2002, Daniel Phillips wrote:
> On February 19, 2002 04:22 am, Linus Torvalds wrote:
> > That still leaves the TLB invalidation issue, but we could handle that
> > with an alternate approach: use the same "free_pte_ctx" kind of gathering
> > that the zap_page_range() code uses for similar reasons (ie gather up the
> > pte entries that you're going to free first, and then do a global
> > invalidate later).
> 
> I think I'll fall back to unsharing the page table on swapout as Hugh 
> suggested, until we sort this out.

My proposal was to unshare the page table on read fault, to avoid race.
I suppose you could, just for your current testing, use that technique
in swapout, to avoid the much more serious TLB issue that Linus has now
raised.  But don't do so without realizing that it is a very deadlocky
idea for swapout (making pages freeable) to need to allocate pages.
And it's not much use for swapout to skip them either, since the shared
page tables become valuable on the very large address spaces which we'd
want swapout to be hitting.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
