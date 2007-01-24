Subject: Re: [RFC] Limit the size of the pagecache
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <6d6a94c50701240622n30f1092cq4570f84160fe87f7@mail.gmail.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
	 <1169625333.4493.16.camel@taijtu>
	 <6d6a94c50701240622n30f1092cq4570f84160fe87f7@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 24 Jan 2007 15:56:56 +0100
Message-Id: <1169650616.6189.41.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey Li <aubreylee@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Frysinger, Michael" <Michael.Frysinger@analog.com>, Bryan Wu <cooloney.lkml@gmail.com>, "Hennerich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-01-24 at 22:22 +0800, Aubrey Li wrote:
> On 1/24/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > On Tue, 2007-01-23 at 16:49 -0800, Christoph Lameter wrote:
> > > This is a patch using some of Aubrey's work plugging it in what is IMHO
> > > the right way. Feel free to improve on it. I have gotten repeatedly
> > > requests to be able to limit the pagecache. With the revised VM statistics
> > > this is now actually possile. I'd like to know more about possible uses of
> > > such a feature.
> > >
> > >
> > >
> > >
> > > It may be useful to limit the size of the page cache for various reasons
> > > such as
> > >
> > > 1. Insure that anonymous pages that may contain performance
> > >    critical data is never subject to swap.
> >
> > This is what we have mlock for, no?
> >
> > > 2. Insure rapid turnaround of pages in the cache.
> >
> > This sounds like we either need more fadvise hints and/or understand why
> > the VM doesn't behave properly.
> >
> > > 3. Reserve memory for other uses? (Aubrey?)
> >
> > He wants to make a nommu system act like a mmu system; this will just
> > never ever work.
> 
> Nope. Actually my nommu system works great with some of patches made by us.
> What let you think this will never work?

Because there are perfectly valid things user-space can do to mess you
up. I forgot the test-case but it had something to do with opening a
million files, this will scatter slab pages all over the place.

Also, if you cycle your large user-space allocations a bit unluckily
you'll also fragment it into oblivion.

So you can not guarantee it will not fragment into smithereens stopping
your user-space from using large than page size allocations.

If your user-space consists of several applications that do dynamic
memory allocation of various sizes its a matter of (run-) time before
things will start failing.

If you prealloc a large area at boot time (like we now do for hugepages)
and use that for user-space, you might 'reset' the status quo by cycling
the whole of userspace.

> > Memory fragmentation is a real issue not some gimmick
> > thought up by the hardware folks to sell these mmu chips.
> >
> I totally disagree. Memory fragmentations is the issue not only on
> nommu, it's also on mmu chips. That's not the reason mmu chips can be
> sold.

For MMU enabled chips these fragmentation issues (at the page allocation
level) will never reach (regular - !hugepages) user-space. Exactly
because of the MMU, it will make things virtually contiguous.

Yes, there are problem in kernel space, esp. when we want to use huge
pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
