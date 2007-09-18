Date: Tue, 18 Sep 2007 10:11:11 +0200
From: Wouter Verhelst <w@uter.be>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Message-ID: <20070918081111.GA4847@country.grep.be>
References: <20070814142103.204771292@sgi.com> <200709171728.26180.phillips@phunq.net> <170fa0d20709172027g3b83d606k6a8e641f71848c3@mail.gmail.com> <200709172211.26493.phillips@phunq.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200709172211.26493.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: Mike Snitzer <snitzer@gmail.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 17, 2007 at 10:11:25PM -0700, Daniel Phillips wrote:
> On Monday 17 September 2007 20:27, Mike Snitzer wrote:
> > >   - Statically prove bounded memory use of all code in the writeout
> > >     path.
> > >
> > >   - Implement any special measures required to be able to make such
> > > a proof.
> >
> > Once the memory requirements of a userspace daemon (e.g. nbd-server)
> > are known; should one mlockall() the memory similar to how is done in
> > heartbeat daemon's realtime library?
> 
> Yes, and also inspect the code to ensure it doesn't violate mlock_all by execing programs (no shell scripts!), dynamically loading libraries, etc.

In nbd-server, there's no dlopen(), and I do not currently plan to add
that. Are there problems with using libraries that are sharedly linked
at compile time that I'm not aware of?

There are plans to add the possibility for shell script callouts, but
those would always be optional. I see no reason why we couldn't make any
mlockall() call an option, too; preferably one that would be
incompatible with the shell script callout stuff.

> > Bigger question for me is what kind of hell am I (or others) in for
> > to try to cap nbd-server's memory usage?  All those glib-gone-wild
> > changes over the recent past feel problematic but I'll look to work
> > with Wouter to see if we can get things bounded.
> 
> Avoiding glib is a good start.  Look at your library dependencies and
> prune them merclilessly.  Just don't use any libraries that you can
> code up yourself in a few hundred bytes of program text for the
> functionalituy you need.

I'm currently using glib because I wanted some utility functions that it
provides, and since I already knew glib; to me, it feels stupid to
reimplement the same things over and over again if there are libraries
that provide them.

If using glib is problematic for whatever reason, I'll certainly be
willing to switch to "something else"; I just didn't feel like
reinventing the wheel for no particular reason.

[...]
> > to get nbd-server to to run in PF_MEMALLOC mode (could've just used
> > the _POSIX_PRIORITY_SCHEDULING hack instead right?)... it didn't help
> > on its own; I likely didn't have enough of the stars aligned to see
> > my MD+NBD mke2fs test not deadlock.
> 
> You do need the block IO throttling, and you need to bypass the dirty
> page limiting.
> 
> Without throttling, your block driver will quickly consume any amount
> of reserve memory you have, and you are dead.  Without an exemption
> from dirty page limiting, the number of pages your user space daemon
> can allocate without deadlocking is zero, which makes life very
> difficult.

Would having the server use O_DIRECT help here? I would think that it
would avoid it marking pages as dirty, but I'm not very familiar with
the in-kernel bits.

-- 
<Lo-lan-do> Home is where you have to wash the dishes.
  -- #debian-devel, Freenode, 2004-09-22

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
