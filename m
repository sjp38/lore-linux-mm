Date: Thu, 16 Aug 2007 05:29:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Message-ID: <20070816032921.GA32197@wotan.suse.de>
References: <20070814142103.204771292@sgi.com> <20070815122253.GA15268@wotan.suse.de> <1187183526.6114.45.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187183526.6114.45.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 15, 2007 at 03:12:06PM +0200, Peter Zijlstra wrote:
> On Wed, 2007-08-15 at 14:22 +0200, Nick Piggin wrote:
> > On Tue, Aug 14, 2007 at 07:21:03AM -0700, Christoph Lameter wrote:
> > > The following patchset implements recursive reclaim. Recursive reclaim
> > > is necessary if we run out of memory in the writeout patch from reclaim.
> > > 
> > > This is f.e. important for stacked filesystems or anything that does
> > > complicated processing in the writeout path.
> > 
> > Filesystems (most of them) that require compilcated allocations at
> > writeout time suck. That said, especially with network ones, it
> > seems like making them preallocate or reserve required memory isn't
> > progressing very smoothly.
> 
> Mainly because we seem to go in circles :-(
> 
> >  I think these patchsets are definitely
> > worth considering as an alternative. 
> 
> Honestly, I don't. They very much do not solve the problem, they just
> displace it.

Well perhaps it doesn't work for networked swap, because dirty accounting
doesn't work the same way with anonymous memory... but for _filesystems_,
right?

I mean, it intuitively seems like a good idea to terminate the recursive
allocation problem with an attempt to reclaim clean pages rather than
immediately let them have-at our memory reserve that is used for other
things as well. Any and all writepage() via reclaim is allowed to eat
into all of memory (I hate that writepage() ever has to use any memory,
and have prototyped how to fix that for simple block based filesystems
in fsblock, but others will require it).


> Christoph's suggestion to set min_free_kbytes to 20% is ridiculous - nor
> does it solve all deadlocks :-(

Well of course it doesn't, but it is a pragmatic way to reduce some
memory depletion cases. I don't see too much harm in it (although I didn't
see the 20% suggestion?)


> > No substantial comments though. 
> 
> Please do ponder the problem and its proposed solutions, because I'm
> going crazy here.
 
Well yeah I think you simply have to reserve a minimum amount of memory in
order to reclaim a page, and I don't see any other way to do it other than
what you describe to be _technically_ deadlock free.

But firstly, you don't _want_ to start dropping packets when you hit a tough
patch in reclaim -- even if you are strictly deadlock free. And secondly,
I think recursive reclaim could reduce the deadlocks in practice which is
not a bad thing as your patches aren't merged.

How are your deadlock patches going anyway? AFAIK they are mostly a network
issue and I haven't been keeping up with them for a while. Do you really need
networked swap and actually encounter the deadlock, or is it just a question of
wanting to fix the bugs? If the former, what for, may I ask?


> <> What Christoph is proposing is doing recursive reclaim and not
> initiating writeout. This will only work _IFF_ there are clean pages
> about. Which in the general case need not be true (memory might be
> packed with anonymous pages - consider an MPI cluster doing computation
> stuff). So this gets us a workload dependant solution - which IMHO is
> bad!

Although you will quite likely have at least a couple of MB worth of
clean program text. The important part of recursive reclaim is that it
doesn't so easily allow reclaim to blow all memory reserves (including
interrupt context). Sure you still have theoretical deadlocks, but if
I understand correctly, they are going to be lessened. I would be
really interested to see if even just these recursive reclaim patches
eliminate the problem in practice.


> > I've been sick all week.
> 
> Do get well.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
