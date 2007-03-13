Date: Tue, 13 Mar 2007 04:15:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
Message-Id: <20070313041551.565891b5.akpm@linux-foundation.org>
In-Reply-To: <45F685C6.8070806@yahoo.com.au>
References: <20070313071325.4920.82870.sendpatchset@schroedinger.engr.sgi.com>
	<20070313005334.853559ca.akpm@linux-foundation.org>
	<45F65ADA.9010501@yahoo.com.au>
	<20070313035250.f908a50e.akpm@linux-foundation.org>
	<45F685C6.8070806@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Tue, 13 Mar 2007 22:06:46 +1100 Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Andrew Morton wrote:
> >>On Tue, 13 Mar 2007 19:03:38 +1100 Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> ...
>
> >>Page allocator still requires interrupts to be disabled, which this doesn't.

> >>it is worthwhile.
> > 
> > 
> > If you want a zeroed page for pagecache and someone has just stuffed a
> > known-zero, cache-hot page into the pagetable quicklists, you have good
> > reason to be upset.
> 
> The thing is, pagetable pages are the one really good exception to the
> rule that we should keep cache hot and initialise-on-demand. They
> typically are fairly sparsely populated and sparsely accessed. Even
> for last level page tables, I think it is reasonable to assume they will
> usually be pretty cold.

eh?  I'd have thought that a pte page which has just gone through
zap_pte_range() will very often have a _lot_ of hot cachelines, and
that's a common case.

Still.   It's pretty easy to test.

> > 
> > Maybe, dunno.  It was apparently a win on powerpc many years ago.  I had a
> > fiddle with it 5-6 years ago on x86 using a cache-disabled mapping of the
> > page.  But it needed too much support in core VM to bother.  Since then
> > we've grown per-cpu page magazines and __GFP_ZERO.  Plus I'm not aware of
> > anyone having tried doing it on x86 with non-temporal stores.
> 
> You can win on specifically constructed benchmarks, easily.
> 
> But considering all the other problems you're going to introduce, we'd need
> a significant win on a significant something, IMO.
> 
> You waste memory bandwidth. You also use more CPU and memory cycles
> speculatively, ergo you waste more power.

Yeah, prezeroing in idle is probably pointless.  But I'm not aware of
anyone having tried it properly...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
