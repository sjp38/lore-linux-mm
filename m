Date: Fri, 28 Mar 2008 05:04:42 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2]: x86: implement pte_special
Message-ID: <20080328040442.GE8083@wotan.suse.de>
References: <20080328025541.GB8083@wotan.suse.de> <20080327.202334.250213398.davem@davemloft.net> <20080328033149.GD8083@wotan.suse.de> <20080327.204431.201380891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080327.204431.201380891.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, shaggy@austin.ibm.com, axboe@oracle.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 27, 2008 at 08:44:31PM -0700, David Miller wrote:
> From: Nick Piggin <npiggin@suse.de>
> Date: Fri, 28 Mar 2008 04:31:50 +0100
> 
> > Basically, the pfn-based mapping insertion (vm_insert_pfn, remap_pfn_range)
> > calls pte_mkspecial. And that tells fast_gup "hands off".
> 
> I don't think it's wise to allocate a "soft PTE bit" for this on every
> platform, especially for such a limited use case.
 
Sure, it will be up to the arch to decide whether or not to use it. If
you can't spare a bit, then nothing changes, you just don't get a speedup ;)

But it is not limited to direct IO. If you have a look through
drivers, there are quite a few things using it that might see improvement.

And even if it were limited to direct IO... there will be some platforms
that want it, I suspect.


> Is it feasible to test the page instead?  Or are we talking about
> cases where there may not be a backing page?

Yes. Or there may be one but you are not allowed to touch it.

 
> If the issue is to discern things like I/O mappings and such vs. real
> pages, there are ways a platform can handle that without a special
> bit.
> 
> That would leave us with real memory that does not have backing
> page structs, and we have a way to test that too.
> 
> The special PTE bit seems superfluous to me.

It has to be quite fast.

There are some platforms that can't really do that easily, so the pte
bit isn't useless on all architectures. s390 for example, which is
why it was introduced in the other patchset.

x86 has 3 bits which are usable by system software, so are not likely
to be ever used by hardware. And in the entire life of Linux, nobody
has ever wanted to use one :) So I think we're safe to use one on x86.

If bits ever run out, and there are as you say other ways to implement
this, then it could be switched over then. Because nothing is going to
be as fast as testing the pte (which we already have loaded in a
register).

For sparc, if you can propose another method, we could look at that.
But if you think it is such a limited use case, then cleanest and eaisest
will just be to not implement it. I doubt many people to serious oltp
on sparc (on Linux), so for that platform you are probably right. If
another compelling use case comes up, then you can always reevaluate.

BTW. if you are still interested, then the powerpc64 patch might be a
better starting point for you. I don't know how the sparc tlb flush
design looks like, but if it doesn't do a synchronous IPI to invalidate
other threads, then you can't use the x86 approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
