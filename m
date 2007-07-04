Date: Wed, 4 Jul 2007 16:38:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-Id: <20070704163826.d0b7465b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <468B3EAA.9070905@yahoo.com.au>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
	<468B3EAA.9070905@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Mike.stroya@hp.com, GOTO <y-goto@jp.fujitsu.com>, dmosberger@gmail.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Wed, 04 Jul 2007 16:31:06 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> The only thing I noticed when I looked at the code is that some places
> may not have flushed icache when they should have? Did you get them all?

I think that I added flush_icache_page() to the place where any flush_(i)cache_xxx
is not called and lazy_mmu_prot_update was used instead of them.
But I want good review, of course.

> Minor nitpick: you have one place where you test VM_EXEC before flushing,
> but the flush routine itself contains the same test I think?
> 
Ah, yes...in do_anonymous_page(). my mistake.

> Regarding the ia64 code -- I'm not an expert so I can't say whether it
> is the right thing to do or not. However I still can't work out what it's
> rationale for the PG_arch_1 bit is, exactly. Does it assume that
> flush_dcache_page sites would only ever be encountered by pages that are
> not faulted in? A faulted in page kind of is "special" because it is
> guaranteed uptodate, but is the ia64 arch code relying on that? Should it?

(I'm sorry if I misses point.)
ia64's D-cache is coherent but I-cache and D-cache is not coherent and any
invalidation against d-cache will invalidate I-cache.

In my understanding :
PG_arch_1 is used for showing "there is no inconsistent data on any level of
cache". PG_uptodate is used for showing "this page includes the newest data
and contents are valid."
...maybe not used for the same purpose.

BTW, a page filled by DMA should have PG_arch_1 :(

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
