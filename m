Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 343946B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 03:57:03 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <Pine.LNX.4.64.0902061216001.23313@blonde.anvils>
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
	 <1233910649.29891.26.camel@penberg-laptop>
	 <Pine.LNX.4.64.0902061216001.23313@blonde.anvils>
Content-Type: text/plain; charset=UTF-8
Date: Tue, 10 Feb 2009 16:56:48 +0800
Message-Id: <1234256208.2604.363.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-02-06 at 12:33 +0000, Hugh Dickins wrote:
> On Fri, 6 Feb 2009, Pekka Enberg wrote:
> > On Thu, 2009-02-05 at 19:04 +0000, Hugh Dickins wrote:
> > > I then tried a patch I thought obviously better than yours: just mask
> > > off __GFP_WAIT in that __GFP_NOWARN|__GFP_NORETRY preliminary call to
> > > alloc_slab_page(): so we're not trying to infer anything about high-
> > > order availability from the number of free order-0 pages, but actually
> > > going to look for it and taking it if it's free, forgetting it if not.
> > > 
> > > That didn't work well at all: almost as bad as the unmodified slub.c.
> > > I decided that was due to __alloc_pages_internal()'s
> > > wakeup_kswapd(zone, order): just expressing an interest in a high-
> > > order page was enough to send it off trying to reclaim them, though
> > > not directly.  Hacked in a condition to suppress that in this case:
> > > worked a lot better, but not nearly as well as yours.  I supposed
> > > that was somehow(?) due to the subsequent get_page_from_freelist()
> > > calls with different watermarking: hacked in another __GFP flag to
> > > break out to nopage just like the NUMA_BUILD GFP_THISNODE case does.
> > > Much better, getting close, but still not as good as yours.  
I did the similiar hack. i>>?get_page_from_freelist, wakeup_kswapd, try_to_free_pages,
and drain_all_pages consume time. If I disable them one by one, I see the result
is improved gradually.

> > 
> > Did you look at it with oprofile?
> 
> No, I didn't.  I didn't say so, but again it was elapsed time that
> I was focussing on, so I don't think oprofile would be relevant.
The vmstat data varies very much when testing runs. The original test case
consists of 2 kbuild tasks and sometimes the 2 tasks almost run serially
because it takes a long time to untie kernel source tarball on the loop ext2
fs. So it's not appropriate to collect oprofile data.

I changed the script to run 2 tasks on tmpfs without loop ext2 device.
The result difference between slub_max_order=0 and default order is about 25%.
When kernel building is started, vmstat sys time is about 4%~10% on my
2 qual-core processor stoakley. io-wait is mostly 40%~80%. I collected the
oprofile data. Mostly, only free_pages_bulk seems a little abnormal. With
default order, i>>?free_pages_bulk is more than 1% while it's 0.23%. By changing
total memory quantity, i>>?free_pages_bulk difference between i>>?slub_max_order=0 and
default order is about 1%.


> There are some differences in system time, of course, consistent
> with your point; but they're generally an order of magnitude less,
> so didn't excite my interest.
> 
> > One thing to keep in mind is that if
> > there are 4K allocations going on, your approach will get double the
> > overhead of page allocations (which can be substantial performance hit
> > for slab).
> 
> Sure, and even the current allocate_slab() is inefficient in that
> respect: I've followed it because I do for now have an interest in
> the stats, but if stats are configured off then there's no point in
> dividing it into two stages; and if they are really intended to be
> ORDER_FALLBACK stats, then it shouldn't divide into two stages when
> oo_order(s->oo) == oo_order(s->min).
You are right theoretically. Under the real environment, the order mostly is 0
when i>>?oo_order(s->oo) == oo_order(s->min), and order 0 page allocation almost
doesn't fail even with flag i>>?__GFP_NORETRY. When default order isn't 0, mostly,
i>>?oo_order(s->oo) isn't equal to i>>?oo_order(s->min).

>   On the other hand, I find it
> interesting to see how often the __GFP_NORETRY fails, even when
> the order is the same each time (and usually 0).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
