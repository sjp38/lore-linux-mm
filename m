Date: Tue, 21 Mar 2000 02:29:37 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: MADV_DONTNEED
Message-ID: <20000321022937.B4271@pcep-jamie.cern.ch>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org>; from Chuck Lever on Mon, Mar 20, 2000 at 02:09:26PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chuck

About MADV_DONTNEED
-------------------

> > In particular, using the name MADV_DONTNEED is a really bad idea.  It
> > means completely different things on different OSes.  For example your
> > meaning of MADV_DONTNEED is different to BSD's: a program that assumes
> > the BSD behaviour may well crash with your implementation and will
> > almost certainly give invalid results if it doesn't crash.
> 
> i'm more concerned about portability from operating systems like Solaris,
> because there are many more server applications there than on *BSD that
> have been designed to use these interfaces.
...
> my preference is for the DU semantic of tossing dirty data instead of
> flushing onto backing store, simply because that's what so many
> applications expect DONTNEED to do.

That's interesting.  When I saw MADV_DONTNEED, I immediately assumed it
was the natural counterpoint to MADV_WILLNEED.  Useful even for
sequential accesses, to say "my streaming window has moved beyond this
point".  Do you agree that a counterpoint to MADV_WILLNEED is useful?

The names are so similar, I consider using MADV_DONTNEED to mean "trash
this memory" quite misleading.  (If there was no MADV_WILLNEED I
wouldn't mind).

> i'm not saying the *BSD way is wrong, but i think it would be a more
> useful compromise to make *BSD functionality available via some other
> interface (like MADV_ZERO).

You got it the wrong way around.  MADV_ZERO is more like what your
implementation of MADV_DONTNEED does.  The BSD behaviour is nothing like
MADV_ZERO.  BSD simply means "increment the paging priority" -- the
page contents are unchanged.

BSD's behaviour is the obvious counterpoint to MADV_WILLNEED afaict.

> as far as i can tell, linux's msync(MS_INVALIDATE) behaves like freeBSD's
> MADV_DONTNEED.

Doesn't look like that.

1. MS_INVALIDATE only works on file mappings -- BSD's MADV_DONTNEED is
   defined (if you believe the documentation) for any mapping.

2. The msync() manual page doesn't agree with you, but I'm not sure
   about the implementation.  The manual says:

       MS_INVALIDATE asks to invalidate  other  mappings  of  the
       same file (so that they can be updated with the fresh values
       just written).

   The implementation seems to invalidate _this_ mapping.
   Either way, they are different from BSD's MADV_DONTNEED.

3. Your MADV_DONTNEED does different things to msync(MS_INVALIDATE)

Actually I like what MADV_DONTNEED does, but I would like it to have a
different name to avoid potentially dangerous ambiguity with BSD's
meaning.  If Linux MADV_DONTNEED were just a hint it would be fine, but
it actively trashes memory.

By the way, Linux MADV_DONTNEED does some of the things
msync(MS_INVALIDATE) does but not others (in the implementation --
ignore the man page).

Can you explain how the two things differ?  I.e., why does MS_INVALIDATE
fiddle with swap cache pages.  Does this indicate a bug in your
MADV_DONTNEED implementation?

> MADV_ZERO makes sense to me as an efficient way to zero a range of
> addresses in a mapping.  but i think it's useful as a *separate* function,
> not as combined with, say, MADV_DONTNEED.

Agreed.  I mention DONTNEED only because some OS's documentation of
DONTNEED appears to be equivalent to MADV_ZERO.  And of course, on a
mapping of /dev/zero they are equivalent.

To be honest, the MADV_DONTNEED behaviour on private mappings is
probably much more useful than zeroing a range anyway.  You've always
got read(/dev/zero) for the latter.

enjoy,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
