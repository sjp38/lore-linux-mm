Message-ID: <45F685C6.8070806@yahoo.com.au>
Date: Tue, 13 Mar 2007 22:06:46 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
References: <20070313071325.4920.82870.sendpatchset@schroedinger.engr.sgi.com>	<20070313005334.853559ca.akpm@linux-foundation.org>	<45F65ADA.9010501@yahoo.com.au> <20070313035250.f908a50e.akpm@linux-foundation.org>
In-Reply-To: <20070313035250.f908a50e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>>On Tue, 13 Mar 2007 19:03:38 +1100 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

>>Page allocator still requires interrupts to be disabled, which this doesn't.
> 
> 
> Bah.  How many cli/sti statements fit into a single cachemiss?

On a Pentium 4? ;)

Sure, that is a minor detail, considering that you'll usually be allocating
an order of magnitude or three more anon/pagecache pages than page tables.

>>Considering there isn't much else that frees known zeroed pages, I wonder if
>>it is worthwhile.
> 
> 
> If you want a zeroed page for pagecache and someone has just stuffed a
> known-zero, cache-hot page into the pagetable quicklists, you have good
> reason to be upset.

The thing is, pagetable pages are the one really good exception to the
rule that we should keep cache hot and initialise-on-demand. They
typically are fairly sparsely populated and sparsely accessed. Even
for last level page tables, I think it is reasonable to assume they will
usually be pretty cold.

And you want to allocate cache cold pages as well, for the same reasons
(you want to keep your cache hot pages for when they actually will be
used - eg. for the anon/pagecache itself).

> In fact, if you want a _non_-zeroed page and someone has just stuffed a
> known-zero, cache-hot page into the pagetable quicklists, you still have
> reason to be upset.  You *want* that cache-hot page.
> 
> Generally, all these little private lists of pages (such as the ones which
> slab had/has) are a bad deal.  Cache effects preponderate and I do think
> we're generally better off tossing the things into a central pool.

For slab I understand. And a lot of users of slab constructers were also
silly, precisely because we should initialise on demand to keep the cache
hits up.

But cold(ish?) pagetable quicklists make sense, IMO (that is, if you *must*
avoid using slab).

>>Last time the zeroidle discussion came up was IIRC not actually real performance
>>gain, just cooking the 1024 CPU threaded pagefault numbers ;)
> 
> 
> Maybe, dunno.  It was apparently a win on powerpc many years ago.  I had a
> fiddle with it 5-6 years ago on x86 using a cache-disabled mapping of the
> page.  But it needed too much support in core VM to bother.  Since then
> we've grown per-cpu page magazines and __GFP_ZERO.  Plus I'm not aware of
> anyone having tried doing it on x86 with non-temporal stores.

You can win on specifically constructed benchmarks, easily.

But considering all the other problems you're going to introduce, we'd need
a significant win on a significant something, IMO.

You waste memory bandwidth. You also use more CPU and memory cycles
speculatively, ergo you waste more power.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
