From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH resend] ramdisk: fix zeroed ramdisk pages on memory pressure
Date: Tue, 16 Oct 2007 18:08:06 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710161645.58686.nickpiggin@yahoo.com.au> <m1abqjirmd.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1abqjirmd.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710161808.06405.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Tuesday 16 October 2007 14:57, Eric W. Biederman wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> writes:
> >> make_page_uptodate() is most hideous part I have run into.
> >> It has to know details about other layers to now what not
> >> to stomp.  I think my incorrect simplification of this is what messed
> >> things up, last round.
> >
> > Not really, it's just named funny. That's just a minor utility
> > function that more or less does what it says it should do.
> >
> > The main problem is really that it's implementing a block device
> > who's data comes from its own buffercache :P. I think.
>
> Well to put it another way, mark_page_uptodate() is the only
> place where we really need to know about the upper layers.
> Given that you can kill ramdisks by coding it as:
>
> static void make_page_uptodate(struct page *page)
> {
> 	clear_highpage(page);
> 	flush_dcache_page(page);
> 	SetPageUptodate(page);
> }
>
> Something is seriously non-intuitive about that function if
> you understand the usual rules for how to use the page cache.

You're overwriting some buffers that were uptodate and dirty.
That would be expected to cause problems.


> The problem is that we support a case in the buffer cache
> where pages are partially uptodate and only the buffer_heads
> remember which parts are valid.  Assuming we are using them
> correctly.
>
> Having to walk through all of the buffer heads in make_page_uptodate
> seems to me to be a nasty layering violation in rd.c

Sure, but it's not just about the buffers. It's the pagecache
in general. It is supposed to be invisible to the device driver
and sitting above it, and yet it is taking the buffercache and
using it to pull its data out of.


> > I think it's worthwhile, given that we'd have a "real" looking
> > block device and minus these bugs.
>
> For testing purposes I think I can agree with that.

What non-testing uses does it have?


> >> Having a separate store would
> >> solve some of the problems, and probably remove the need
> >> for carefully specifying the ramdisk block size.  We would
> >> still need the magic restictions on page allocations though
> >> and it we would use them more often as the initial write to the
> >> ramdisk would not populate the pages we need.
> >
> > What magic restrictions on page allocations? Actually we have
> > fewer restrictions on page allocations because we can use
> > highmem!
>
> With the proposed rewrite yes.
>
> > And the lowmem buffercache pages that we currently pin
> > (unsuccessfully, in the case of this bug) are now completely
> > reclaimable. And all your buffer heads are now reclaimable.
>
> Hmm.  Good point.  So in net it should save memory even if
> it consumes a little more in the worst case.

Highmem systems would definitely like it. For others, yes, all
the duplicated pages should be able to get reclaimed if memory
gets tight, along with the buffer heads, so yeah footprint may
be a tad smaller.


> > If you mean GFP_NOIO... I don't see any problem. Block device
> > drivers have to allocate memory with GFP_NOIO; this may have
> > been considered magic or deep badness back when the code was
> > written, but it's pretty simple and accepted now.
>
> Well I always figured it was a bit rude allocating large amounts
> of memory GFP_NOIO but whatever.

You'd rather not, of course, but with dirty data limits now,
it doesn't matter much. (and I doubt anybody outside testing
is going to be hammering like crazy on rd).

Note that the buffercache based ramdisk driver is going to
also be allocating with GFP_NOFS if you're talking about a
filesystem writing to its metadata. In most systems, GFP_NOFS
isn't much different to GFP_NOIO.

We could introduce a mode which allocates pages up front
quite easily if it were a problem (which I doubt it ever would
be).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
