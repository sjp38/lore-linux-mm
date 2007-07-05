Message-ID: <468C51A7.3070505@yahoo.com.au>
Date: Thu, 05 Jul 2007 12:04:23 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>	<468B3EAA.9070905@yahoo.com.au> <20070704163826.d0b7465b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070704163826.d0b7465b.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Mike.stroya@hp.com, GOTO <y-goto@jp.fujitsu.com>, dmosberger@gmail.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 04 Jul 2007 16:31:06 +1000
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>The only thing I noticed when I looked at the code is that some places
>>may not have flushed icache when they should have? Did you get them all?
> 
> 
> I think that I added flush_icache_page() to the place where any flush_(i)cache_xxx
> is not called and lazy_mmu_prot_update was used instead of them.
> But I want good review, of course.
> 
> 
>>Minor nitpick: you have one place where you test VM_EXEC before flushing,
>>but the flush routine itself contains the same test I think?
>>
> 
> Ah, yes...in do_anonymous_page(). my mistake.
> 
> 
>>Regarding the ia64 code -- I'm not an expert so I can't say whether it
>>is the right thing to do or not. However I still can't work out what it's
>>rationale for the PG_arch_1 bit is, exactly. Does it assume that
>>flush_dcache_page sites would only ever be encountered by pages that are
>>not faulted in? A faulted in page kind of is "special" because it is
>>guaranteed uptodate, but is the ia64 arch code relying on that? Should it?
> 
> 
> (I'm sorry if I misses point.)
> ia64's D-cache is coherent but I-cache and D-cache is not coherent and any
> invalidation against d-cache will invalidate I-cache.
> 
> In my understanding :
> PG_arch_1 is used for showing "there is no inconsistent data on any level of
> cache". PG_uptodate is used for showing "this page includes the newest data
> and contents are valid."
> ...maybe not used for the same purpose.

I think that's right, but why is set_pte-time the critical point for the
flush? It is actually possible to write into an executable page via the
dcache *after* it has ptes pointing to it.

 From what I can work out, it is something like "at this point the page
should be uptodate, so at least the icache won't contain *inconsistent*
data, just old data which userspace should take care of flushing if it
modifies". Is that always true? Could the page get modified by means
other than a direct write(2)? And even in the case of a write(2) writer,
how do they know if another process is mapping that particular page for
exec at that time? Should they always flush? Flushing would require they
have a virtual address on the page to begin with anyway, doesn't it? So
they'd have to mmap it... phew.

I guess it is mostly safe because it is probably very uncommon to do
such a thing, and chances are no non-write(2) write activity happens to
a page after it is brought uptodate. But I don't know if that has been
audited. I would really like to see the kernel always manage all aspects
of its pagecache though. I realise performance considerations may make
this not always possible... but it might be possible to do efficiently
using mapcount these days?

Anyway, ignore my tangent if you like :) Your patch doesn't make any of
this worse, so I'm getting off topic.

So I think your patch is nice, but would need ia64 people to actually ack
it.


> BTW, a page filled by DMA should have PG_arch_1 :(

The consequences of not are superfluous flushes?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
