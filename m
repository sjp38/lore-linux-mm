Date: Tue, 22 May 2007 03:59:35 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070522105935.GR19966@holomorphy.com>
References: <20070520052229.GA9372@wotan.suse.de> <20070520084647.GF19966@holomorphy.com> <20070520092552.GA7318@wotan.suse.de> <20070521080813.GQ31925@holomorphy.com> <20070521092742.GA19642@wotan.suse.de> <20070521224316.GC11166@waste.org> <20070522013951.GP19966@holomorphy.com> <20070522015703.GE27743@wotan.suse.de> <20070522050410.GQ19966@holomorphy.com> <20070522062452.GA29807@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070522062452.GA29807@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, May 21, 2007 at 10:04:10PM -0700, William Lee Irwin III wrote:
>> The size isn't the advantage being cited; I'd actually expect the net
>> result to be larger. It's the control over the layout of the metadata
>> for cache locality and even things like having enough flags, folding
>> buffer_head -like affairs into the per-page metadata for filesystems
>> and so reaping cache locality benefits even there (assuming it works
>> out in other respects), and so on.
>> Passing pages between subsystems doesn't seem very significant to me.
>> There isn't going to be much locality of reference, or even any
>> guarantee that the subsystem gets fed a cache hot page structure. The
>> subsystem being passed the page will have its own cache hot accounting
>> structures to stick the information about the memory into.

On Tue, May 22, 2007 at 08:24:53AM +0200, Nick Piggin wrote:
> Well consider the page allocator and pagecache. The page allocator
> uses page metadata rather than eg. a bitmap, and it uses page list
> heads for the per-cpu allocator.
> If we were to instead perhaps use external bitmaps and arrays to 
> keep track of pages, then the pagecache would have to go and allocate
> its own structures rather than reuse the cache hot page allocator
> structures.
> Buffer heads might be something that would work well, but we'd still
> like to be able to deallocate them without freeing the whole pagecache
> (because they tend to be associated with less frequent operations like
> IO). But anyway, I don't know. I'm sure there would be cases where it
> works better.

The page allocator maintains a number of bitmaps, but anyway. Each
subsystem will basically have its own cache-hot structures. Instead
of passing around metadata that's hot, each tries to keep its own
"working set" of metadata hot. Basically yes, it will work better in
some situations and the current metadata passing will work better in
others. I'd expect the control over the layout to be more advantageous
more often, especially since it arranges cache contiguity while pages
are in use.


On Mon, May 21, 2007 at 10:04:10PM -0700, William Lee Irwin III wrote:
>> I'm not entirely sure what you're on about there, but it sounds
>> interesting.

On Tue, May 22, 2007 at 08:24:53AM +0200, Nick Piggin wrote:
> Heh :) Well the lockless pagecache would become basically trivial if we
> could RCU-free pagecache pages, however doing that is really awful for
> a number of reasons. However if you had a system where the metadata is
> decoupled, you could simply RCU-free the 'struct page' (while still
> immediately freeing the page itself) which would make lockless pagecache
> (and potentially similar things) equally trivial.
> I assumed K42 might have been into that angle.

That does sound convenient. I'll add that to the list of benefits.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
