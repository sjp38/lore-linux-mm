Date: Fri, 30 Mar 2007 03:46:34 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/2] mm: dont account ZERO_PAGE
Message-ID: <20070330014633.GA19407@wotan.suse.de>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, Mar 29, 2007 at 02:10:55PM +0100, Hugh Dickins wrote:
> On Thu, 29 Mar 2007, Nick Piggin wrote:
> > 
> > Special-case the ZERO_PAGE to prevent it from being accounted like a normal
> > mapped page. This is not illogical or unclean, because the ZERO_PAGE is
> > heavily special cased through the page fault path.
> 
> Thou dost protest too much!  By "heavily special cased through the page
> fault path" you mean do_wp_page() uses a pre-zeroed page when it spots
> it, instead of copying its data.  That's rather a different case.

That, and the use of the zero page _at all_ in the do_anonymous_page
and zeromap, and I guess our anti-wrapping hacks in the page allocator...
it is just done for a little optimisation, so I figure it wouldn't hurt
to optimise a bit more ;)

> Look, I don't have any vehement objection to exempting the ZERO_PAGE
> from accounting: if you remember before, I just suggested it was of
> questionable value to exempt it, and the exemption should be made a
> separate patch.
> 
> But this patch is not complete, is it?  For example, fremap.c's
> zap_pte?  I haven't checked further.  I was going to suggest you
> should make ZERO_PAGEs fail vm_normal_page, but I guess do_wp_page
> wouldn't behave very well then ;)  Tucking the tests away in some
> vm_normal_page-like function might make them more acceptable.

Yeah I was going to do that, but noted the do_wp_page thingy. I don't
know... it might be better though... vm_refcounted_page()?

> > A test-case which took over 2 hours to complete on a 1024 core Altix
> > takes around 2 seconds afterward.
> 
> Oh, it's easy to devise a test-case of that kind, but does it matter
> in real life?  I admit that what most people run on their 1024-core
> Altices will be significantly different from what I checked on my
> laptop back then, but in my case use of the ZERO_PAGE didn't look
> common enough to make special cases for.

Yeah I don't have access to the box, but it was a constructed test
of some kind. However this is basically a dead box situation... on
smaller systems we could still see performance improvements.

And the other thing is I'd like to be able to get rid of the wrapping
tests from the page allocator and PageReserved from the kernel entirely
at some point.

> You put forward a pagecache replication patch a few weeks ago.
> That's what I expected to happen to the ZERO_PAGE, once NUMA folks
> complained of the accounting.  Isn't that a better way to go?

Not sure how much remote memory access the ZERO_PAGE itself causes.
It is obviously readonly data, and itaniums have pretty big caches,
so it is more important to get rid of the bouncing cachelines.

Per node ZERO_PAGE could be a good idea, however you can still have
all pages come from a single node (eg. a forking server)...

> Or is there some important app on the Altix which uses the
> ZERO_PAGE so very much, that its interesting data remains shared
> between nodes forever, and it's only its struct page cacheline
> bouncing dirtily from one to another that slows things down?

Can't answer that. I think they are worried about this being hit in
the field.

Does the ZERO_PAGE help _any_ real workloads? It will cost an extra
fault any time you are not content with its interesting data. I
don't know why any performance critical app would read huge swaths
of zeroes, but there is probably a reason for it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
