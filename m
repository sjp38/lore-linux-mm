Date: Wed, 15 Aug 2007 14:22:53 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Message-ID: <20070815122253.GA15268@wotan.suse.de>
References: <20070814142103.204771292@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070814142103.204771292@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 14, 2007 at 07:21:03AM -0700, Christoph Lameter wrote:
> The following patchset implements recursive reclaim. Recursive reclaim
> is necessary if we run out of memory in the writeout patch from reclaim.
> 
> This is f.e. important for stacked filesystems or anything that does
> complicated processing in the writeout path.

Filesystems (most of them) that require compilcated allocations at
writeout time suck. That said, especially with network ones, it
seems like making them preallocate or reserve required memory isn't
progressing very smoothly. I think these patchsets are definitely
worth considering as an alternative. 

No substantial comments though. I've been sick all week.

 

> Recursive reclaim works because it limits itself to only reclaim pages
> that do not require writeout. It will only remove clean pages from the LRU.
> The dirty throttling of the VM during regular reclaim insures that the amount
> of dirty pages is limited. If recursive reclaim causes too many clean pages
> to be removed then regular reclaim will throttle all processes until the
> dirty ratio is restored. This means that the amount of memory that can
> be reclaimed via recursive reclaim is limited to clean memory. The default
> ratio is 10%. This means that recursive reclaim can reclaim 90% of memory
> before failing. Reclaiming excessive amounts of clean pages may have a
> significant performance impact because this means that executable pages
> will be removed. However, it ensures that we will no longer fail in the
> writeout path.
> 
> A patch is included to test this functionality. The test involved allocating
> 12 Megabytes from the reclaim paths when __PF_MEMALLOC is set. This is enough
> to exhaust the reserves.
> 
> -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
