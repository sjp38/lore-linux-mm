Date: Wed, 22 Mar 2000 12:04:58 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: MADV_DONTNEED
In-Reply-To: <20000321022937.B4271@pcep-jamie.cern.ch>
Message-ID: <Pine.BSO.4.10.10003221125170.16476-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi jamie-

On Tue, 21 Mar 2000, Jamie Lokier wrote:
> > > In particular, using the name MADV_DONTNEED is a really bad idea.  It
> > > means completely different things on different OSes.  For example your
> > > meaning of MADV_DONTNEED is different to BSD's: a program that assumes
> > > the BSD behaviour may well crash with your implementation and will
> > > almost certainly give invalid results if it doesn't crash.
> > 
> > i'm more concerned about portability from operating systems like Solaris,
> > because there are many more server applications there than on *BSD that
> > have been designed to use these interfaces.
> ...
> > my preference is for the DU semantic of tossing dirty data instead of
> > flushing onto backing store, simply because that's what so many
> > applications expect DONTNEED to do.
> 
> That's interesting.  When I saw MADV_DONTNEED, I immediately assumed it
> was the natural counterpoint to MADV_WILLNEED.

yes, i did too.  but i realized later that "will" is *not* the opposite of
"dont".

> Useful even for
> sequential accesses, to say "my streaming window has moved beyond this
> point".  Do you agree that a counterpoint to MADV_WILLNEED is useful?

if you look at the implementation of nopage_sequential_readahead, you'll
see that it doesn't use MADV_DONTNEED, but the internal implementation of
msync(MS_INVALIDATE).  i'm not completely confident in this
implementation, but my intent was to release behind, not discard data.
so, yes, a counterpoint to WILLNEED is a good idea.  perhaps that *was*
the original intent of MADV_DONTNEED, but i don't see any documentation
that ties WILLNEED and DONTNEED together, semantically.

> > i'm not saying the *BSD way is wrong, but i think it would be a more
> > useful compromise to make *BSD functionality available via some other
> > interface (like MADV_ZERO).
> 
> You got it the wrong way around.  MADV_ZERO is more like what your
> implementation of MADV_DONTNEED does.  The BSD behaviour is nothing like
> MADV_ZERO.  BSD simply means "increment the paging priority" -- the
> page contents are unchanged.
> 
> BSD's behaviour is the obvious counterpoint to MADV_WILLNEED afaict.

it is, but it's not the behavior that most applications expect.  i'd like
to have something like this, but it should probably be named MADV_FREE, or
how about MADV_WONTNEED ? :)

so we agree that both behaviors might be useful to expose to an
application.  the only question is what to name them.

function 1 (could be MADV_DISCARD; currently MADV_DONTNEED):
  discard pages.  if they are referenced again, the process causes page
  faults to read original data (zero page for anonymous maps).

function 2 (could be MADV_FREE; currently msync(MS_INVALIDATE)):
  release pages, syncing dirty data.  if they are referenced again, the
  process causes page faults to read in latest data.

function 3 (could be MADV_ZERO):
  discard pages.  if they are referenced again, the process sees C-O-W 
  zeroed pages.

function 4 (for comparison; currently munmap):
  release pages, syncing dirty data.  if they are referenced again, the
  process causes invalid memory access faults.

i'm interested to hear what big database folks have to say about this.

> By the way, Linux MADV_DONTNEED does some of the things
> msync(MS_INVALIDATE) does but not others (in the implementation --
> ignore the man page).
> 
> Can you explain how the two things differ?  I.e., why does MS_INVALIDATE
> fiddle with swap cache pages.  Does this indicate a bug in your
> MADV_DONTNEED implementation?

for MADV_DONTNEED, i re-used code.  i'm not convinced that it's correct,
though, as i stated when i submitted the patch.  it may abandon swap cache
pages, and there may be some undefined interaction between file truncation
and MADV_DONTNEED.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
