Date: Tue, 22 May 2007 08:24:53 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070522062452.GA29807@wotan.suse.de>
References: <20070519181501.GC19966@holomorphy.com> <20070520052229.GA9372@wotan.suse.de> <20070520084647.GF19966@holomorphy.com> <20070520092552.GA7318@wotan.suse.de> <20070521080813.GQ31925@holomorphy.com> <20070521092742.GA19642@wotan.suse.de> <20070521224316.GC11166@waste.org> <20070522013951.GP19966@holomorphy.com> <20070522015703.GE27743@wotan.suse.de> <20070522050410.GQ19966@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070522050410.GQ19966@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, May 21, 2007 at 10:04:10PM -0700, William Lee Irwin III wrote:
> On Mon, May 21, 2007 at 06:39:51PM -0700, William Lee Irwin III wrote:
> >> address (virtual and physical are trivially inter-convertible), mock
> >> up something akin to what filesystems do for anonymous pages, etc.
> >> The real objection everyone's going to have is that driver writers
> >> will stain their shorts when faced with the rules for handling such
> >> things. The thing is, I'm not entirely sure who these driver writers
> >> that would have such trouble are, since the driver writers I know
> >> personally are sophisticates rather than walking disaster areas as such
> >> would imply. I suppose they may not be representative of the whole.
> 
> On Tue, May 22, 2007 at 03:57:03AM +0200, Nick Piggin wrote:
> > That's not the objection I would have. I would say that firstly, I
> > don't think the mem_map overhead is very significant (at any rate,
> > an allocated-on-demand metadata is not going to be any smaller if
> > you fill up on pagecache...). Secondly, I think there is merit to
> > having the same page metadata used by the major subsystems, because
> > it helps for locality of reference.
> 
> The size isn't the advantage being cited; I'd actually expect the net
> result to be larger. It's the control over the layout of the metadata
> for cache locality and even things like having enough flags, folding
> buffer_head -like affairs into the per-page metadata for filesystems
> and so reaping cache locality benefits even there (assuming it works
> out in other respects), and so on.
> 
> Passing pages between subsystems doesn't seem very significant to me.
> There isn't going to be much locality of reference, or even any
> guarantee that the subsystem gets fed a cache hot page structure. The
> subsystem being passed the page will have its own cache hot accounting
> structures to stick the information about the memory into.

Well consider the page allocator and pagecache. The page allocator
uses page metadata rather than eg. a bitmap, and it uses page list
heads for the per-cpu allocator.

If we were to instead perhaps use external bitmaps and arrays to 
keep track of pages, then the pagecache would have to go and allocate
its own structures rather than reuse the cache hot page allocator
structures.

Buffer heads might be something that would work well, but we'd still
like to be able to deallocate them without freeing the whole pagecache
(because they tend to be associated with less frequent operations like
IO). But anyway, I don't know. I'm sure there would be cases where it
works better.


> On Tue, May 22, 2007 at 03:57:03AM +0200, Nick Piggin wrote:
> > But I haven't explored the idea enough myself to know whether there
> > would be any really killer benefits to this. Delayed metadata freeing
> > via RCU without holding up the freeing of the actual page would have
> > been something, however I can do similar with speculative references
> > now (or whenever the code gets merged), which doesn't even require the
> > RCU overhead.
> 
> I'm not entirely sure what you're on about there, but it sounds
> interesting.

Heh :) Well the lockless pagecache would become basically trivial if we
could RCU-free pagecache pages, however doing that is really awful for
a number of reasons. However if you had a system where the metadata is
decoupled, you could simply RCU-free the 'struct page' (while still
immediately freeing the page itself) which would make lockless pagecache
(and potentially similar things) equally trivial.

I assumed K42 might have been into that angle.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
