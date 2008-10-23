Date: Thu, 23 Oct 2008 09:07:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081023070711.GB30765@wotan.suse.de>
References: <20081021112137.GB12329@wotan.suse.de> <87mygxexev.fsf@basil.nowhere.org> <20081022103112.GA27862@wotan.suse.de> <20081022230715.GX18495@disturbed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081022230715.GX18495@disturbed>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 23, 2008 at 10:07:15AM +1100, Dave Chinner wrote:
> On Wed, Oct 22, 2008 at 12:31:13PM +0200, Nick Piggin wrote:
> > On Tue, Oct 21, 2008 at 06:16:24PM +0200, Andi Kleen wrote:
> > > Nick Piggin <npiggin@suse.de> writes:
> > > 
> > > > IO error handling in the core mm/fs still doesn't seem perfect, but with
> > > > the recent round of patches and this one, it should be getting on the
> > > > right track.
> > > >
> > > > I kind of get the feeling some people would rather forget about all this
> > > > and brush it under the carpet. Hopefully I'm mistaken, but if anybody
> > > > disagrees with my assertion that error handling, and data integrity
> > > > semantics are first-class correctness issues, and therefore are more
> > > > important than all other non-correctness problems... speak now and let's
> > > > discuss that, please.
> > > >
> > > > Otherwise, unless anybody sees obvious problems with this, hopefully it
> > > > can go into -mm for some wider testing (I've tested it with a few filesystems
> > > > so far and no immediate problems)
> > > 
> > > I think the first step to get these more robust in the future would be to
> > > have a standard regression test testing these paths.  Otherwise it'll
> > > bit-rot sooner or later again.
> > 
> > The problem I've had with testing is that it's hard to trigger a specific
> > path for a given error, because write IO especially can be quite non
> > deterministic, and the filesystem or kernel may give up at various points.
> > 
> > I agree, but I just don't know exactly how they can be turned into
> > standard tests. Some filesystems like XFS seem to completely shut down
> > quite easily on IO errors.
> 
> XFS only shuts down on unrecoverable metadata I/O errors, and those
> I/Os do not go through the generic code paths at all (they go
> through the XFS buffer layer instead). Errors in data I/O will
> not trigger shutdowns at all - instead they get reported to the
> application doing the I/O...

Yes, but just for my testing of injecting random errors, it's hard to
get meaningful tests because of the shutdown problem. Not a criticism :)
Of the few fses I tested, XFS definitely seemed to be the best (at least
it detects and makes effort to handle failures somehow).

 
> > Others like ext2 can't really unwind from
> > a failure in a multi-block operation (eg. allocating a block to an
> > inode) if an error is detected, and it just gets ignored.
> 
> It's these sorts of situations that XFS will trigger a shutdown.
> 
> > I am testing, but mainly just random failure injections and seeing if
> > things go bug or go undetected etc.
> 
> I'd start with just data I/O. e.g. preallocate a large file, then do
> reads and writes to it and inject errors into those I/Os. That
> should avoid all the problems of I/O errors on metadata I/O and the
> problems that generates. If you do synchronous I/O, then the errors
> should pop straight out to the test application as well. All
> filesystems should report the same errors with this sort of test.
 
Yeah, that's probably a good idea. That should still provide all or
nearly all coverage for the core VM.


> You could do the same thing for metadata read operations. e.g. build
> a large directory structure, then do read operations on it (readdir,
> stat, etc) and inject errors into each of those. All filesystems
> should return the (EIO) error to the application in this case.
> 
> Those two cases should be pretty generic and deterministic - they
> both avoid the difficult problem of determining what the response
> to an I/O error during metadata modifcation should be....

Good suggestion.

I'll see what I can do. I'm using the fault injection stuff, which I
don't think can distinguish metadata, so I might just have to work
out a bio flag or something we can send down to the block layer to
distinguish.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
