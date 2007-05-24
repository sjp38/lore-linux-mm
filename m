Date: Thu, 24 May 2007 03:42:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
Message-ID: <20070524014223.GA22998@wotan.suse.de>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org> <1179963619.32247.991.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1179963619.32247.991.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 24, 2007 at 09:40:19AM +1000, Benjamin Herrenschmidt wrote:
> On Fri, 2007-05-18 at 08:23 -0700, Linus Torvalds wrote:
> > 
> > If we are changing the calling semantics of "nopage", then we should also 
> > remove the horrible, horrible hack of making the "nopfn" function itself 
> > do the "populate the page tables".
> > 
> > It would be *much* better to just
> 
>   .../...
> 
> > and let the caller always insert the thing into the page tables.
> > 
> > Wouldn't it be nice if we never had drivers etc modifying page tables 
> > directly? Even with helpers like "vm_insert_pfn()"?
> 
> The problem is that this is racy vs. concurrent unmap_mapping_range().

Yeah, I decided against that after replying to Linus. Also, it is just
not a common path that we want to clutter up the core pagefault
handler with. As I said, if the handler already knows about pfns and
specifically doesn't want struct page backings etc etc.  (rather than
just looking up pagecache offsets like a filesystem), then we can assume
it has some idea about memory management and I don't think it is
particularly bad to have it install the pte.

So I do *not* want the normal fault path to do some weird nopfn stuff
based on return values of the handler.

At most, if Linus really doesn't want ->fault to do the nopfn thing, then
I would be happy to leave in ->nopfn... but I don't see much reason not
to just merge them anyway... one fewer branch and less code in the
page fault handler.


> As I explained in my previous email, spufs and the DRI are 2 examples
> where we need to expose to userland a mapping whose backing PFN's have
> to be switched between different physical storage.
> 
> The only way I've found to have this be race free is to have the
> ->nopfn() function do the actual PTE insertion while holding a
> lock/mutex that is also taken by whatever calles unmap_mapping_range()
> when the switching occurs).

Yep, thanks for the input.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
