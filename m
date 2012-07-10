Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 6D5166B006C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 06:47:27 -0400 (EDT)
Date: Tue, 10 Jul 2012 11:47:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: don't invoke __alloc_pages_direct_compact when order
 0
Message-ID: <20120710104722.GB14154@suse.de>
References: <1341588521-17744-1-git-send-email-js1304@gmail.com>
 <alpine.DEB.2.00.1207070139510.10445@chino.kir.corp.google.com>
 <CAAmzW4PXdpQ2zSnkx8sSScAt1OY0j4+HXVmf=COvP7eMLqrEvQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAAmzW4PXdpQ2zSnkx8sSScAt1OY0j4+HXVmf=COvP7eMLqrEvQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Jul 08, 2012 at 11:33:14AM +0900, JoonSoo Kim wrote:
> 2012/7/7 David Rientjes <rientjes@google.com>:
> > On Sat, 7 Jul 2012, Joonsoo Kim wrote:
> >
> >> __alloc_pages_direct_compact has many arguments so invoking it is very costly.
> >> And in almost invoking case, order is 0, so return immediately.
> >>
> >
> > If "zero cost" is "very costly", then this might make sense.
> >
> > __alloc_pages_direct_compact() is inlined by gcc.
> 
> In my kernel image, __alloc_pages_direct_compact() is not inlined by gcc.

Indeed it is due to their being two callsites. In most cases, the page
allocator takes care that functions have only one callsite so they get
inlined.

You say that invoking the function is very costly. I agree that a function
call with that many parameters is hefty but it is also in the slow path of
the allocator. For order-0 allocations we are about to enter direct reclaim
where I would expect the cost far exceeds the cost of a function call.

If the cost is indeed high and you have seen this in profiles then I
suggest you create a forced inline function alloc_pages_direct_compact
that does this;

if (order != 0)
	__alloc_pages_direct_compact(...)

and then call alloc_pages_direct_compact instead of
__alloc_pages_direct_compact. After that, recheck the profiles (although I
expect the difference to be marginal) and the size of vmlinux (if it gets
bigger, it's probably not worth it).

That would be functionally similar to your patch but it will preserve git
blame, churn less code and be harder to make mistakes with in the unlikely
event a third call to alloc_pages_direct_compact is ever added.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
