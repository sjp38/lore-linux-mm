From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
Date: Mon, 6 Aug 2007 16:49:55 -0700
References: <20070806102922.907530000@chello.nl> <200708061559.41680.phillips@phunq.net> <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708061649.56487.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2007 16:14, Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Daniel Phillips wrote:
> > Correct.  That is what the throttling part of these patches is
> > about.
>
> Where are those patches?

Here is one user:

   http://zumastor.googlecode.com/svn/trunk/ddsnap/kernel/dm-ddsnap.c
   down(&info->throttle_sem);

Peter has another (swap over net).  A third is the network stack itself, 
which is in the full patch set that Peter has posted a number of times 
in the past but did not appear today because Peter broke the full patch 
set up into multiple sets to make it all easier to understand.

> AFAICT: This patchset is not throttling processes but failing
> allocations.

Failing allocations?  Where do you see that?  As far as I can see, 
Peter's patch set allows allocations to fail exactly where the user has 
always specified they may fail, and in no new places.  If there is a 
flaw in that logic, please let us know.

What the current patch set actually does is allow some critical 
allocations that would have failed or recursed into deadlock before to 
succeed instead, allowing vm writeout to complete successfully.  You 
may quibble with exactly how he accomplishes that, but preventing these 
allocations from failing is not optional.

> The patchset does not reconfigure the memory reserves as 
> expected.

What do you mean by that?  Expected by who?

> Instead new reserve logic is added.

Peter did not actually have to add a new layer of abstraction to 
alloc_pages to impose order on the hardcoded hacks that currently live 
in there to decide how far various callers can dig into reserves.  It 
would probably help people understand this patch set if that part were 
taken out for now and replaced with the original seat-of-the-pants two 
line hack I had in the original.  But I do not see anything wrong with 
what Peter has written there, it just takes a little more time to read.

> And I suspect that we  
> have the same issues as in earlier releases with various corner cases
> not being covered.

Do you have an example?

> Code is added that is supposedly not used.

What makes you think that?

> If it  ever is on a large config then we are in very deep trouble by
> the new code paths themselves that serialize things in order to give
> some allocations precendence over the other allocations that are made
> to fail ....

You mean by allocating the reserve memory on the wrong node in NUMA?  
That is on a code path that avoids destroying your machine performance 
or killing the machine entirely as with current kernels, for which a 
few cachelines pulled to another node is a small price to pay.  And you 
are free to use your special expertise in NUMA to make those fallback 
paths even more efficient, but first you need to understand what they 
are doing and why.

At your service for any more questions :-)

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
