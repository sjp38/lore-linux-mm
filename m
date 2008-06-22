Date: Sun, 22 Jun 2008 19:10:41 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix race in COW logic
In-Reply-To: <alpine.LFD.1.10.0806221033200.2926@woody.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0806221854050.5466@blonde.site>
References: <20080622153035.GA31114@wotan.suse.de> <Pine.LNX.4.64.0806221742330.31172@blonde.site>
 <alpine.LFD.1.10.0806221033200.2926@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 22 Jun 2008, Linus Torvalds wrote:
> On Sun, 22 Jun 2008, Hugh Dickins wrote:
> 
> > One thing though, in moving the page_remove_rmap in that way, aren't
> > you assuming that there's an appropriate wmbarrier between the two
> > locations?  If that is necessarily so (there's plenty happening in
> > between), it may deserve a comment to say just where that barrier is.
> 
> In this case, I don't think memory ordering matters.
> 
> What matters is that the map count never goes down to one - and by 
> re-ordering the inc/dec accesses, that simply won't happen. IOW, memory 
> ordering is immaterial, only the ordering of count updates (from the 
> standpoint of the faulting CPU - so that's not even an SMP issue) matters.

I'm puzzled.  The page_remove_rmap has moved to the other side of the
page_add_new_anon_rmap, but they are operating on different pages.
It's true that the total of their mapcounts doesn't go down to one
in the critical area, but that total isn't computed anywhere.

After asking, I thought the answer was going to be that page_remove_rmap
uses atomic_add_negative, and atomic ops which return a value do
themselves provide sufficient barrier.  I'm wondering if that's so
obvious that you've generously sought out a different meaning to my query.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
