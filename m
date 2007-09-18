From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Date: Mon, 17 Sep 2007 17:28:24 -0700
References: <20070814142103.204771292@sgi.com> <200709050916.04477.phillips@phunq.net> <170fa0d20709072212m4563ce76sa83092640491e4f3@mail.gmail.com>
In-Reply-To: <170fa0d20709072212m4563ce76sa83092640491e4f3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709171728.26180.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Snitzer <snitzer@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Friday 07 September 2007 22:12, Mike Snitzer wrote:
> Can you be specific about which changes to existing mainline code
> were needed to make recursive reclaim "work" in your tests (albeit
> less ideally than peterz's patchset in your view)?

Sorry, I was incommunicado out on the high seas all last week.  OK, the
measures that actually prevent our ddsnap driver from deadlocking are:

  - Statically prove bounded memory use of all code in the writeout
    path.

  - Implement any special measures required to be able to make such a
    proof.

  - All allocations performed by the block driver must have access
    to dedicated memory resources.

  - Disable the congestion_wait mechanism for our code as much as
    possible, at least enough to obtain the maximum memory resources
    that can be used on the writeout path.

The specific measure we implement in order to prove a bound is:

  - Throttle IO on our block device to a known amount of traffic for
    which we are sure that the MEMALLOC reserve will always be
    adequate.

Note that the boundedness proof we use is somewhat loose at the moment. 
It goes something like "we only need at most X kilobytes of reserve and 
there are X megabytes available".  Much of Peter's patch set is aimed 
at getting more precise about this, but to be sure, handwaving just 
like this has been part of core kernel since day one without too many 
ill effects.

The way we provide guaranteed access to memory resources is:

  - Run critical daemons in PF_MEMALLOC mode, including
    any userspace daemons that must execute in the block IO path
   (cluster coders take note!)

Right now, all writeout submitted to ddsnap gets handed off to a daemon
running in PF_MEMALLOC mode.  This is a needless inefficiency that we 
want to remove in future, and handle as many of those submissions as 
possible entirely in the context of the submitter.  To do this, further 
measures are needed:

  - Network writes performed by the block driver must have access to
    dedicated memory resources.

We have not yet managed to trigger network read memory deadlock, but it 
is just a matter of time, additional fancy virtual block devices, and 
enough stress.  So:

  - Network reads need some fancy extra support because dedicated
    memory resources must be consumed before knowing whether the
    network traffic belongs to a block device or not.

Now, the interesting thing about this whole discussion is, none of the 
measures that we are actually using at the moment are implemented in 
either Peter's or Christoph's patch set.  In other words, at present we 
do not require either patch set in order to run under heavy load 
without deadlocking.  But in order to generalize our solution to a 
wider range of virtual block devices and other problematic systems such 
as userspace filesystems, we need to incorporate a number of elements 
of Peter's patch set.

As far as Christoph's proposal goes, it is not required to prevent 
deadlocks.   Whether or not it is a good optimization is an open 
question.

Of all the patches posted so far related to this work, the only 
indispensable one is the bio throttling patch developed by Evgeniy and 
I in a parallel thread.  The other essential pieces are all implemented 
in our block driver for now.  Some of those can be generalized and 
moved at least partially into core, and some cannot.

I do need to write some sort of primer on this, because there is no 
fire-and-forget magic core kernel solution.  There are helpful things 
we can do in core, but some of it can only be implemented in the 
drivers themselves.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
