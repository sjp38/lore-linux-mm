Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Page table sharing
Date: Tue, 19 Feb 2002 13:43:50 +0100
References: <Pine.LNX.4.21.0202191209570.1016-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.21.0202191209570.1016-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E16d9cc-0001Ep-00@starship.berlin>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On February 19, 2002 01:22 pm, Hugh Dickins wrote:
> On Tue, 19 Feb 2002, Daniel Phillips wrote:
> > On February 19, 2002 04:22 am, Linus Torvalds wrote:
> > > That still leaves the TLB invalidation issue, but we could handle that
> > > with an alternate approach: use the same "free_pte_ctx" kind of gathering
> > > that the zap_page_range() code uses for similar reasons (ie gather up the
> > > pte entries that you're going to free first, and then do a global
> > > invalidate later).
> > 
> > I think I'll fall back to unsharing the page table on swapout as Hugh 
> > suggested, until we sort this out.
> 
> My proposal was to unshare the page table on read fault, to avoid race.
> I suppose you could, just for your current testing, use that technique
> in swapout, to avoid the much more serious TLB issue that Linus has now
> raised.  But don't do so without realizing that it is a very deadlocky
> idea for swapout (making pages freeable) to need to allocate pages.

I didn't fail to notice that.  It's no worse than any other page reservation
issue, of which we have plenty.  One day we're going to have to solve them all.

> And it's not much use for swapout to skip them either, since the shared
> page tables become valuable on the very large address spaces which we'd
> want swapout to be hitting.

Unsharing is the route of least resistance at the moment.  If necessary I can
keep a page around for that purpose, then reestablish that reserve after using
it.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
