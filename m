Date: Wed, 22 Mar 2000 18:43:57 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: MADV_DONTNEED
Message-ID: <20000322184357.C7271@pcep-jamie.cern.ch>
References: <20000321022937.B4271@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221125170.16476-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003221125170.16476-100000@funky.monkey.org>; from Chuck Lever on Wed, Mar 22, 2000 at 12:04:58PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chuck Lever wrote:
> > That's interesting.  When I saw MADV_DONTNEED, I immediately assumed it
> > was the natural counterpoint to MADV_WILLNEED.
> 
> yes, i did too.  but i realized later that "will" is *not* the opposite of
> "dont".

Agreed.

> if you look at the implementation of nopage_sequential_readahead, you'll
> see that it doesn't use MADV_DONTNEED, but the internal implementation of
> msync(MS_INVALIDATE).  i'm not completely confident in this
> implementation, but my intent was to release behind, not discard data.

If I knew what msync(MS_INVALIDATE) did I could think about this! :-)
But the msync documentation is unhelpful and possibly misleading.

> it is, but it's not the behavior that most applications expect.  i'd like
> to have something like this, but it should probably be named MADV_FREE, or
> how about MADV_WONTNEED ? :)

I like the name MADV_WONTNEED.  Thanks for thinking of it :-)

With that, even keeping the name MADV_DONTNEED is ok because there is a
distinction.  (But I'd prefer to rename MADV_DONTNEED to MADV_DISCARD,
to catch potential misuses).

> function 1 (could be MADV_DISCARD; currently MADV_DONTNEED):
>   discard pages.  if they are referenced again, the process causes page
>   faults to read original data (zero page for anonymous maps).

I like the name MADV_DISCARD too. :-)

> function 2 (could be MADV_FREE; currently msync(MS_INVALIDATE)):
>   release pages, syncing dirty data.  if they are referenced again, the
>   process causes page faults to read in latest data.

Oh, I see, this is what msync(MS_INVALIDATE) does :-)

> function 4 (for comparison; currently munmap):
>   release pages, syncing dirty data.  if they are referenced again, the
>   process causes invalid memory access faults.

> for MADV_DONTNEED, i re-used code.

>From where?

> i'm not convinced that it's correct, though, as i stated when i
> submitted the patch.  it may abandon swap cache pages, and there may
> be some undefined interaction between file truncation and
> MADV_DONTNEED.

Oh dear -- because it's in pre2.4 already :-)
Better work out what it's supposed to do and fix it :-)

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
