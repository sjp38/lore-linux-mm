Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 74B8B6B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 03:57:34 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <Pine.LNX.4.64.0902051839540.1445@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de>
	 <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
	 <84144f020901220201g6bdc2d5maf3395fc8b21fe67@mail.gmail.com>
	 <Pine.LNX.4.64.0901221239260.21677@blonde.anvils>
	 <Pine.LNX.4.64.0901231357250.9011@blonde.anvils>
	 <1233545923.2604.60.camel@ymzhang>
	 <1233565214.17835.13.camel@penberg-laptop>
	 <1233646145.2604.137.camel@ymzhang>
	 <Pine.LNX.4.64.0902031150110.5290@blonde.anvils>
	 <1233714090.2604.186.camel@ymzhang>
	 <Pine.LNX.4.64.0902051839540.1445@blonde.anvils>
Date: Fri, 06 Feb 2009 10:57:29 +0200
Message-Id: <1233910649.29891.26.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Thu, 2009-02-05 at 19:04 +0000, Hugh Dickins wrote:
> I then tried a patch I thought obviously better than yours: just mask
> off __GFP_WAIT in that __GFP_NOWARN|__GFP_NORETRY preliminary call to
> alloc_slab_page(): so we're not trying to infer anything about high-
> order availability from the number of free order-0 pages, but actually
> going to look for it and taking it if it's free, forgetting it if not.
> 
> That didn't work well at all: almost as bad as the unmodified slub.c.
> I decided that was due to __alloc_pages_internal()'s
> wakeup_kswapd(zone, order): just expressing an interest in a high-
> order page was enough to send it off trying to reclaim them, though
> not directly.  Hacked in a condition to suppress that in this case:
> worked a lot better, but not nearly as well as yours.  I supposed
> that was somehow(?) due to the subsequent get_page_from_freelist()
> calls with different watermarking: hacked in another __GFP flag to
> break out to nopage just like the NUMA_BUILD GFP_THISNODE case does.
> Much better, getting close, but still not as good as yours.  

Did you look at it with oprofile? One thing to keep in mind is that if
there are 4K allocations going on, your approach will get double the
overhead of page allocations (which can be substantial performance hit
for slab).

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
