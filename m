Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 296016B00A4
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 18:19:57 -0500 (EST)
Date: Fri, 23 Nov 2012 08:20:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Lockdep complain for zram
Message-ID: <20121122232012.GD5121@bbox>
References: <20121121083737.GB5121@bbox>
 <50AD1829.7050709@vflare.org>
 <20121122083110.GC5121@bbox>
 <50ADF9AB.9030903@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50ADF9AB.9030903@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu, Nov 22, 2012 at 02:08:43AM -0800, Nitin Gupta wrote:
> On 11/22/2012 12:31 AM, Minchan Kim wrote:
> >Hi Nitin,
> >
> >On Wed, Nov 21, 2012 at 10:06:33AM -0800, Nitin Gupta wrote:
> >>On 11/21/2012 12:37 AM, Minchan Kim wrote:
> >>>Hi alls,
> >>>
> >>>Today, I saw below complain of lockdep.
> >>>As a matter of fact, I knew it long time ago but forgot that.
> >>>The reason lockdep complains is that now zram uses GFP_KERNEL
> >>>in reclaim path(ex, __zram_make_request) :(
> >>>I can fix it via replacing GFP_KERNEL with GFP_NOIO.
> >>>But more big problem is vzalloc in zram_init_device which calls GFP_KERNEL.
> >>>Of course, I can change it with __vmalloc which can receive gfp_t.
> >>>But still we have a problem. Althoug __vmalloc can handle gfp_t, it calls
> >>>allocation of GFP_KERNEL. That's why I sent the patch.
> >>>https://lkml.org/lkml/2012/4/23/77
> >>>Since then, I forgot it, saw the bug today and poped the question again.
> >>>
> >>>Yes. Fundamental problem is utter crap API vmalloc.
> >>>If we can fix it, everyone would be happy. But life isn't simple like seeing
> >>>my thread of the patch.
> >>>
> >>>So next option is to move zram_init_device into setting disksize time.
> >>>But it makes unnecessary metadata waste until zram is used really(That's why
> >>>Nitin move zram_init_device from disksize setting time to make_request) and
> >>>it makes user should set the disksize before using, which are behavior change.
> >>>
> >>>I would like to clean up this issue before promoting because it might change
> >>>usage behavior.
> >>>
> >>>Do you have any idea?
> >>>
> >>
> >>Maybe we can alloc_vm_area() right on device creation in
> >>create_device() assuming the default disksize. If user explicitly
> >>sets the disksize, this vm area is deallocated and a new one is
> >>allocated based on the new disksize.  When the device is reset, we
> >>should only free physical pages allocated for the table and the
> >>virtual area should be set back as if disksize is set to the
> >>default.
> >>
> >>At the device init time, all the pages can be allocated with
> >>GFP_NOIO | __GPF_HIGHMEM and since the VM area is preallocated,
> >>map_vm_area() will not hit any of those page-table allocations with
> >>GFP_KERNEL.
> >>
> >>Other allocations made directly from zram, for instance in the
> >>partial I/O case, should also be changed to GFP_NOIO |
> >>__GFP_HIGHMEM.
> >>
> >
> >Yes. It's a good idea and actually I thought about it.
> >My concern about that approach is following as.
> >
> >1) User of zram normally do mkfs.xxx or mkswap before using
> >    the zram block device(ex, normally, do it at booting time)
> >    It ends up allocating such metadata of zram before real usage so
> >    benefit of lazy initialzation would be mitigated.
> >
> >2) Some user want to use zram when memory pressure is high.(ie, load zram
> >    dynamically, NOT booting time). It does make sense because people don't
> >    want to waste memory until memory pressure is high(ie, where zram is really
> >    helpful time). In this case, lazy initialzation could be failed easily
> >    because we will use GFP_NOIO instead of GFP_KERNEL due to swap use-case.
> >    So the benefit of lazy initialzation would be mitigated, too.
> >
> >3) Current zram's documenation is wrong.
> >    Set Disksize isn't optional when we use zram firstly.
> >    Once user set disksize, it could be optional, but NOT optional
> >    at first usage time. It's very odd behavior. So I think user set to disksizes
> >    before using is more safe and clear.
> >
> >So my suggestion is following as.
> >
> >  * Let's change disksize setting to MUST before using for consistent behavior.
> >  * When user set to disksize, let's allocate metadata all at once.
> >    4K : 12 byte(64bit) -> 64G : 192M so 0.3% isn't big overhead.
> >    If insane user use such big zram device up to 20, it could consume 6% of ram
> >    but efficieny of zram will cover the waste.
> >  * If someone has a concern about this, let's guide for him set to disksize
> >    right before zram using.
> >
> >What do you think about it?
> >
> 
> I agree. This lazy initialization has been a problem since the
> beginning. So, lets just force user to first set the disksize and
> document this behavior as such.

Sure.

> 
> I plan to reduce struct table to just an array of handles (so
> getting rid of size, flag, count fields), but for now we could just
> use existing struct table and do this change later.

Good to hear.

Thanks for the quick feedback.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
